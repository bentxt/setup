#!/usr/bin/env sh

# This is a wrapper script, that automatically download mill from GitHub release pages
# You can give the required mill version with --mill-version parameter
# If no version is given, it falls back to the value of DEFAULT_MILL_VERSION
#
# Project page: https://github.com/lefou/millw
# Script Version: 0.4.11
#
# If you want to improve this script, please also contribute your changes back!
#
# Licensed under the Apache License, Version 2.0

set -e

if [ -z "${DEFAULT_MILL_VERSION}" ] ; then
  DEFAULT_MILL_VERSION="0.11.4"
fi


if [ -z "${GITHUB_RELEASE_CDN}" ] ; then
  GITHUB_RELEASE_CDN=""
fi


MILL_REPO_URL="https://github.com/com-lihaoyi/mill"

if [ -z "${CURL_CMD}" ] ; then
  CURL_CMD=curl
fi

# Explicit commandline argument takes precedence over all other methods
if [ "$1" = "--mill-version" ] ; then
  shift
  if [ "x$1" != "x" ] ; then
    MILL_VERSION="$1"
    shift
  else
    echo "You specified --mill-version without a version." 1>&2
    echo "Please provide a version that matches one provided on" 1>&2
    echo "${MILL_REPO_URL}/releases" 1>&2
    false
  fi
fi

# Please note, that if a MILL_VERSION is already set in the environment,
# We reuse it's value and skip searching for a value.

# If not already set, read .mill-version file
if [ -z "${MILL_VERSION}" ] ; then
  if [ -f ".mill-version" ] ; then
    MILL_VERSION="$(head -n 1 .mill-version 2> /dev/null)"
  elif [ -f ".config/mill-version" ] ; then
    MILL_VERSION="$(head -n 1 .config/mill-version 2> /dev/null)"
  fi
fi

MILL_USER_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/mill"

if [ -z "${MILL_DOWNLOAD_PATH}" ] ; then
  MILL_DOWNLOAD_PATH="${MILL_USER_CACHE_DIR}/download"
fi

# If not already set, try to fetch newest from Github
if [ -z "${MILL_VERSION}" ] ; then
  # TODO: try to load latest version from release page
  echo "No mill version specified." 1>&2
  echo "You should provide a version via '.mill-version' file or --mill-version option." 1>&2

  mkdir -p "${MILL_DOWNLOAD_PATH}"
  LANG=C touch -d '1 hour ago' "${MILL_DOWNLOAD_PATH}/.expire_latest" 2>/dev/null || (
    # we might be on OSX or BSD which don't have -d option for touch
    # but probably a -A [-][[hh]mm]SS
    touch "${MILL_DOWNLOAD_PATH}/.expire_latest"; touch -A -010000 "${MILL_DOWNLOAD_PATH}/.expire_latest"
  ) || (
    # in case we still failed, we retry the first touch command with the intention
    # to show the (previously suppressed) error message
    LANG=C touch -d '1 hour ago' "${MILL_DOWNLOAD_PATH}/.expire_latest"
  )

  # POSIX shell variant of bash's -nt operator, see https://unix.stackexchange.com/a/449744/6993
  # if [ "${MILL_DOWNLOAD_PATH}/.latest" -nt "${MILL_DOWNLOAD_PATH}/.expire_latest" ] ; then
  if [ -n "$(find -L "${MILL_DOWNLOAD_PATH}/.latest" -prune -newer "${MILL_DOWNLOAD_PATH}/.expire_latest")" ]; then
    # we know a current latest version
    MILL_VERSION=$(head -n 1 "${MILL_DOWNLOAD_PATH}"/.latest 2> /dev/null)
  fi

  if [ -z "${MILL_VERSION}" ] ; then
    # we don't know a current latest version
    echo "Retrieving latest mill version ..." 1>&2
    LANG=C ${CURL_CMD} -s -i -f -I ${MILL_REPO_URL}/releases/latest 2> /dev/null  | grep --ignore-case Location: | sed s'/^.*tag\///' | tr -d '\r\n' > "${MILL_DOWNLOAD_PATH}/.latest"
    MILL_VERSION=$(head -n 1 "${MILL_DOWNLOAD_PATH}"/.latest 2> /dev/null)
  fi

  if [ -z "${MILL_VERSION}" ] ; then
    # Last resort
    MILL_VERSION="${DEFAULT_MILL_VERSION}"
    echo "Falling back to hardcoded mill version ${MILL_VERSION}" 1>&2
  else
    echo "Using mill version ${MILL_VERSION}" 1>&2
  fi
fi

MILL="${MILL_DOWNLOAD_PATH}/${MILL_VERSION}"

try_to_use_system_mill() {
  if [ "$(uname)" != "Linux" ]; then
    return 0
  fi

  MILL_IN_PATH="$(command -v mill || true)"

  if [ -z "${MILL_IN_PATH}" ]; then
    return 0
  fi

  SYSTEM_MILL_FIRST_TWO_BYTES=$(head --bytes=2 "${MILL_IN_PATH}")
  if [ "${SYSTEM_MILL_FIRST_TWO_BYTES}" = "#!" ]; then
	  # MILL_IN_PATH is (very likely) a shell script and not the mill
	  # executable, ignore it.
	  return 0
  fi

  SYSTEM_MILL_PATH=$(readlink -e "${MILL_IN_PATH}")
  SYSTEM_MILL_SIZE=$(stat --format=%s "${SYSTEM_MILL_PATH}")
  SYSTEM_MILL_MTIME=$(stat --format=%y "${SYSTEM_MILL_PATH}")

  if [ ! -d "${MILL_USER_CACHE_DIR}" ]; then
    mkdir -p "${MILL_USER_CACHE_DIR}"
  fi

  SYSTEM_MILL_INFO_FILE="${MILL_USER_CACHE_DIR}/system-mill-info"
  if [ -f "${SYSTEM_MILL_INFO_FILE}" ]; then
    parseSystemMillInfo() {
        LINE_NUMBER="${1}"
        # Select the line number of the SYSTEM_MILL_INFO_FILE, cut the
        # variable definition in that line in two halves and return
        # the value, and finally remove the quotes.
        sed -n "${LINE_NUMBER}p" "${SYSTEM_MILL_INFO_FILE}" |\
            cut -d= -f2 |\
            sed 's/"\(.*\)"/\1/'
    }

    CACHED_SYSTEM_MILL_PATH=$(parseSystemMillInfo 1)
    CACHED_SYSTEM_MILL_VERSION=$(parseSystemMillInfo 2)
    CACHED_SYSTEM_MILL_SIZE=$(parseSystemMillInfo 3)
    CACHED_SYSTEM_MILL_MTIME=$(parseSystemMillInfo 4)

    if [ "${SYSTEM_MILL_PATH}" = "${CACHED_SYSTEM_MILL_PATH}" ] \
           && [ "${SYSTEM_MILL_SIZE}" = "${CACHED_SYSTEM_MILL_SIZE}" ] \
           && [ "${SYSTEM_MILL_MTIME}" = "${CACHED_SYSTEM_MILL_MTIME}" ]; then
      if [ "${CACHED_SYSTEM_MILL_VERSION}" = "${MILL_VERSION}" ]; then
          MILL="${SYSTEM_MILL_PATH}"
          return 0
      else
          return 0
      fi
    fi
  fi

  SYSTEM_MILL_VERSION=$(${SYSTEM_MILL_PATH} --version | head -n1 | sed -n 's/^Mill.*version \(.*\)/\1/p')

  cat <<EOF > "${SYSTEM_MILL_INFO_FILE}"
CACHED_SYSTEM_MILL_PATH="${SYSTEM_MILL_PATH}"
CACHED_SYSTEM_MILL_VERSION="${SYSTEM_MILL_VERSION}"
CACHED_SYSTEM_MILL_SIZE="${SYSTEM_MILL_SIZE}"
CACHED_SYSTEM_MILL_MTIME="${SYSTEM_MILL_MTIME}"
EOF

  if [ "${SYSTEM_MILL_VERSION}" = "${MILL_VERSION}" ]; then
    MILL="${SYSTEM_MILL_PATH}"
  fi
}
try_to_use_system_mill

# If not already downloaded, download it
if [ ! -s "${MILL}" ] ; then

  # support old non-XDG download dir
  MILL_OLD_DOWNLOAD_PATH="${HOME}/.mill/download"
  OLD_MILL="${MILL_OLD_DOWNLOAD_PATH}/${MILL_VERSION}"
  if [ -x "${OLD_MILL}" ] ; then
    MILL="${OLD_MILL}"
  else
    case $MILL_VERSION in
      0.0.* | 0.1.* | 0.2.* | 0.3.* | 0.4.* )
        DOWNLOAD_SUFFIX=""
        DOWNLOAD_FROM_MAVEN=0
        ;;
      0.5.* | 0.6.* | 0.7.* | 0.8.* | 0.9.* | 0.10.* | 0.11.0-M* )
        DOWNLOAD_SUFFIX="-assembly"
        DOWNLOAD_FROM_MAVEN=0
        ;;
      *)
        DOWNLOAD_SUFFIX="-assembly"
        DOWNLOAD_FROM_MAVEN=1
        ;;
    esac

    DOWNLOAD_FILE=$(mktemp mill.XXXXXX)

    if [ "$DOWNLOAD_FROM_MAVEN" = "1" ] ; then
      DOWNLOAD_URL="https://repo1.maven.org/maven2/com/lihaoyi/mill-dist/${MILL_VERSION}/mill-dist-${MILL_VERSION}.jar"
    else
      MILL_VERSION_TAG=$(echo "$MILL_VERSION" | sed -E 's/([^-]+)(-M[0-9]+)?(-.*)?/\1\2/')
      DOWNLOAD_URL="${GITHUB_RELEASE_CDN}${MILL_REPO_URL}/releases/download/${MILL_VERSION_TAG}/${MILL_VERSION}${DOWNLOAD_SUFFIX}"
      unset MILL_VERSION_TAG
    fi

    # TODO: handle command not found
    echo "Downloading mill ${MILL_VERSION} from ${DOWNLOAD_URL} ..." 1>&2
    ${CURL_CMD} -f -L -o "${DOWNLOAD_FILE}" "${DOWNLOAD_URL}"
    chmod +x "${DOWNLOAD_FILE}"
    mkdir -p "${MILL_DOWNLOAD_PATH}"
    mv "${DOWNLOAD_FILE}" "${MILL}"

    unset DOWNLOAD_FILE
    unset DOWNLOAD_SUFFIX
  fi
fi

if [ -z "$MILL_MAIN_CLI" ] ; then
  MILL_MAIN_CLI="${0}"
fi

MILL_FIRST_ARG=""
if [ "$1" = "--bsp" ] || [ "$1" = "-i" ] || [ "$1" = "--interactive" ] || [ "$1" = "--no-server" ] || [ "$1" = "--repl" ] || [ "$1" = "--help" ] ; then
  # Need to preserve the first position of those listed options
  MILL_FIRST_ARG=$1
  shift
fi

unset MILL_DOWNLOAD_PATH
unset MILL_OLD_DOWNLOAD_PATH
unset OLD_MILL
unset MILL_VERSION
unset MILL_REPO_URL

# We don't quote MILL_FIRST_ARG on purpose, so we can expand the empty value without quotes
# shellcheck disable=SC2086
exec "${MILL}" $MILL_FIRST_ARG -D "mill.main.cli=${MILL_MAIN_CLI}" "$@"
