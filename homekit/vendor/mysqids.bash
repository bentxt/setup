#!/usr/bin/env bash

# -e: exit immediately if a command exits with a non-zero status
# -u: treat unset variables as an error and exit immediately
# -C: prevent overwriting files
set -euC

# Its a shuffled version of 
# (missing 1Il0O
# abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ2345678
#
MYALPHA=$HOME/kits/mykit/conf/sqids_alphabet_safe_mixedcase.txt
if [ -f "$MYALPHA" ] ; then
    readonly DEFAULT_ALPHABET="$(cat "$MYALPHA")"
else
    echo "Err: could not find alphabet in '$MYALPHA'" >&2
    exit 1
fi

if [ -z "$DEFAULT_ALPHABET" ] ; then
    echo "Err: could not find alphabet in '$MYALPHA'" >&2
    exit 1
fi

#readonly DEFAULT_ALPHABET="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
readonly DEFAULT_BLOCKLIST=(
    "0rgasm"
    "1d10t"
    "1d1ot"
    "1di0t"
    "1diot"
    "1eccacu10"
    "1eccacu1o"
    "1eccacul0"
    "1eccaculo"
    "1mbec11e"
    "1mbec1le"
    "1mbeci1e"
    "1mbecile"
    "a11upat0"
    "a11upato"
    "a1lupat0"
    "a1lupato"
    "aand"
    "ah01e"
    "ah0le"
    "aho1e"
    "ahole"
    "al1upat0"
    "al1upato"
    "allupat0"
    "allupato"
    "ana1"
    "ana1e"
    "anal"
    "anale"
    "anus"
    "arrapat0"
    "arrapato"
    "arsch"
    "arse"
    "ass"
    "b00b"
    "b00be"
    "b01ata"
    "b0ceta"
    "b0iata"
    "b0ob"
    "b0obe"
    "b0sta"
    "b1tch"
    "b1te"
    "b1tte"
    "ba1atkar"
    "balatkar"
    "bastard0"
    "bastardo"
    "batt0na"
    "battona"
    "bitch"
    "bite"
    "bitte"
    "bo0b"
    "bo0be"
    "bo1ata"
    "boceta"
    "boiata"
    "boob"
    "boobe"
    "bosta"
    "bran1age"
    "bran1er"
    "bran1ette"
    "bran1eur"
    "bran1euse"
    "branlage"
    "branler"
    "branlette"
    "branleur"
    "branleuse"
    "c0ck"
    "c0g110ne"
    "c0g11one"
    "c0g1i0ne"
    "c0g1ione"
    "c0gl10ne"
    "c0gl1one"
    "c0gli0ne"
    "c0glione"
    "c0na"
    "c0nnard"
    "c0nnasse"
    "c0nne"
    "c0u111es"
    "c0u11les"
    "c0u1l1es"
    "c0u1lles"
    "c0ui11es"
    "c0ui1les"
    "c0uil1es"
    "c0uilles"
    "c11t"
    "c11t0"
    "c11to"
    "c1it"
    "c1it0"
    "c1ito"
    "cabr0n"
    "cabra0"
    "cabrao"
    "cabron"
    "caca"
    "cacca"
    "cacete"
    "cagante"
    "cagar"
    "cagare"
    "cagna"
    "cara1h0"
    "cara1ho"
    "caracu10"
    "caracu1o"
    "caracul0"
    "caraculo"
    "caralh0"
    "caralho"
    "cazz0"
    "cazz1mma"
    "cazzata"
    "cazzimma"
    "cazzo"
    "ch00t1a"
    "ch00t1ya"
    "ch00tia"
    "ch00tiya"
    "ch0d"
    "ch0ot1a"
    "ch0ot1ya"
    "ch0otia"
    "ch0otiya"
    "ch1asse"
    "ch1avata"
    "ch1er"
    "ch1ng0"
    "ch1ngadaz0s"
    "ch1ngadazos"
    "ch1ngader1ta"
    "ch1ngaderita"
    "ch1ngar"
    "ch1ngo"
    "ch1ngues"
    "ch1nk"
    "chatte"
    "chiasse"
    "chiavata"
    "chier"
    "ching0"
    "chingadaz0s"
    "chingadazos"
    "chingader1ta"
    "chingaderita"
    "chingar"
    "chingo"
    "chingues"
    "chink"
    "cho0t1a"
    "cho0t1ya"
    "cho0tia"
    "cho0tiya"
    "chod"
    "choot1a"
    "choot1ya"
    "chootia"
    "chootiya"
    "cl1t"
    "cl1t0"
    "cl1to"
    "clit"
    "clit0"
    "clito"
    "cock"
    "cog110ne"
    "cog11one"
    "cog1i0ne"
    "cog1ione"
    "cogl10ne"
    "cogl1one"
    "cogli0ne"
    "coglione"
    "cona"
    "connard"
    "connasse"
    "conne"
    "cou111es"
    "cou11les"
    "cou1l1es"
    "cou1lles"
    "coui11es"
    "coui1les"
    "couil1es"
    "couilles"
    "cracker"
    "crap"
    "cu10"
    "cu1att0ne"
    "cu1attone"
    "cu1er0"
    "cu1ero"
    "cu1o"
    "cul0"
    "culatt0ne"
    "culattone"
    "culer0"
    "culero"
    "culo"
    "cum"
    "cunt"
    "d11d0"
    "d11do"
    "d1ck"
    "d1ld0"
    "d1ldo"
    "damn"
    "de1ch"
    "deich"
    "depp"
    "di1d0"
    "di1do"
    "dick"
    "dild0"
    "dildo"
    "dyke"
    "encu1e"
    "encule"
    "enema"
    "enf01re"
    "enf0ire"
    "enfo1re"
    "enfoire"
    "estup1d0"
    "estup1do"
    "estupid0"
    "estupido"
    "etr0n"
    "etron"
    "f0da"
    "f0der"
    "f0ttere"
    "f0tters1"
    "f0ttersi"
    "f0tze"
    "f0utre"
    "f1ca"
    "f1cker"
    "f1ga"
    "fag"
    "fica"
    "ficker"
    "figa"
    "foda"
    "foder"
    "fottere"
    "fotters1"
    "fottersi"
    "fotze"
    "foutre"
    "fr0c10"
    "fr0c1o"
    "fr0ci0"
    "fr0cio"
    "fr0sc10"
    "fr0sc1o"
    "fr0sci0"
    "fr0scio"
    "froc10"
    "froc1o"
    "froci0"
    "frocio"
    "frosc10"
    "frosc1o"
    "frosci0"
    "froscio"
    "fuck"
    "g00"
    "g0o"
    "g0u1ne"
    "g0uine"
    "gandu"
    "go0"
    "goo"
    "gou1ne"
    "gouine"
    "gr0gnasse"
    "grognasse"
    "haram1"
    "harami"
    "haramzade"
    "hund1n"
    "hundin"
    "id10t"
    "id1ot"
    "idi0t"
    "idiot"
    "imbec11e"
    "imbec1le"
    "imbeci1e"
    "imbecile"
    "j1zz"
    "jerk"
    "jizz"
    "k1ke"
    "kam1ne"
    "kamine"
    "kike"
    "leccacu10"
    "leccacu1o"
    "leccacul0"
    "leccaculo"
    "m1erda"
    "m1gn0tta"
    "m1gnotta"
    "m1nch1a"
    "m1nchia"
    "m1st"
    "mam0n"
    "mamahuev0"
    "mamahuevo"
    "mamon"
    "masturbat10n"
    "masturbat1on"
    "masturbate"
    "masturbati0n"
    "masturbation"
    "merd0s0"
    "merd0so"
    "merda"
    "merde"
    "merdos0"
    "merdoso"
    "mierda"
    "mign0tta"
    "mignotta"
    "minch1a"
    "minchia"
    "mist"
    "musch1"
    "muschi"
    "n1gger"
    "neger"
    "negr0"
    "negre"
    "negro"
    "nerch1a"
    "nerchia"
    "nigger"
    "orgasm"
    "p00p"
    "p011a"
    "p01la"
    "p0l1a"
    "p0lla"
    "p0mp1n0"
    "p0mp1no"
    "p0mpin0"
    "p0mpino"
    "p0op"
    "p0rca"
    "p0rn"
    "p0rra"
    "p0uff1asse"
    "p0uffiasse"
    "p1p1"
    "p1pi"
    "p1r1a"
    "p1rla"
    "p1sc10"
    "p1sc1o"
    "p1sci0"
    "p1scio"
    "p1sser"
    "pa11e"
    "pa1le"
    "pal1e"
    "palle"
    "pane1e1r0"
    "pane1e1ro"
    "pane1eir0"
    "pane1eiro"
    "panele1r0"
    "panele1ro"
    "paneleir0"
    "paneleiro"
    "patakha"
    "pec0r1na"
    "pec0rina"
    "pecor1na"
    "pecorina"
    "pen1s"
    "pendej0"
    "pendejo"
    "penis"
    "pip1"
    "pipi"
    "pir1a"
    "pirla"
    "pisc10"
    "pisc1o"
    "pisci0"
    "piscio"
    "pisser"
    "po0p"
    "po11a"
    "po1la"
    "pol1a"
    "polla"
    "pomp1n0"
    "pomp1no"
    "pompin0"
    "pompino"
    "poop"
    "porca"
    "porn"
    "porra"
    "pouff1asse"
    "pouffiasse"
    "pr1ck"
    "prick"
    "pussy"
    "put1za"
    "puta"
    "puta1n"
    "putain"
    "pute"
    "putiza"
    "puttana"
    "queca"
    "r0mp1ba11e"
    "r0mp1ba1le"
    "r0mp1bal1e"
    "r0mp1balle"
    "r0mpiba11e"
    "r0mpiba1le"
    "r0mpibal1e"
    "r0mpiballe"
    "rand1"
    "randi"
    "rape"
    "recch10ne"
    "recch1one"
    "recchi0ne"
    "recchione"
    "retard"
    "romp1ba11e"
    "romp1ba1le"
    "romp1bal1e"
    "romp1balle"
    "rompiba11e"
    "rompiba1le"
    "rompibal1e"
    "rompiballe"
    "ruff1an0"
    "ruff1ano"
    "ruffian0"
    "ruffiano"
    "s1ut"
    "sa10pe"
    "sa1aud"
    "sa1ope"
    "sacanagem"
    "sal0pe"
    "salaud"
    "salope"
    "saugnapf"
    "sb0rr0ne"
    "sb0rra"
    "sb0rrone"
    "sbattere"
    "sbatters1"
    "sbattersi"
    "sborr0ne"
    "sborra"
    "sborrone"
    "sc0pare"
    "sc0pata"
    "sch1ampe"
    "sche1se"
    "sche1sse"
    "scheise"
    "scheisse"
    "schlampe"
    "schwachs1nn1g"
    "schwachs1nnig"
    "schwachsinn1g"
    "schwachsinnig"
    "schwanz"
    "scopare"
    "scopata"
    "sexy"
    "sh1t"
    "shit"
    "slut"
    "sp0mp1nare"
    "sp0mpinare"
    "spomp1nare"
    "spompinare"
    "str0nz0"
    "str0nza"
    "str0nzo"
    "stronz0"
    "stronza"
    "stronzo"
    "stup1d"
    "stupid"
    "succh1am1"
    "succh1ami"
    "succhiam1"
    "succhiami"
    "sucker"
    "t0pa"
    "tapette"
    "test1c1e"
    "test1cle"
    "testic1e"
    "testicle"
    "tette"
    "topa"
    "tr01a"
    "tr0ia"
    "tr0mbare"
    "tr1ng1er"
    "tr1ngler"
    "tring1er"
    "tringler"
    "tro1a"
    "troia"
    "trombare"
    "turd"
    "twat"
    "vaffancu10"
    "vaffancu1o"
    "vaffancul0"
    "vaffanculo"
    "vag1na"
    "vagina"
    "verdammt"
    "verga"
    "w1chsen"
    "wank"
    "wichsen"
    "x0ch0ta"
    "x0chota"
    "xana"
    "xoch0ta"
    "xochota"
    "z0cc01a"
    "z0cc0la"
    "z0cco1a"
    "z0ccola"
    "z1z1"
    "z1zi"
    "ziz1"
    "zizi"
    "zocc01a"
    "zocc0la"
    "zocco1a"
    "zoccola"
)
readonly DEFAULT_MIN_LENGTH=0

# usage: ord "A" -> 65
ord() {
    printf -v __RETURN "%d" "'$1"
}

# usage: splitstr "abcde" -> "a b c d e"
splitstr() {
    local s="$1"
    local i
    arr=()
    for ((i = 0; i < ${#s}; i++)); do
        arr+=("${s:$i:1}")
    done

    __RETURN=${arr[*]}
}

# usage: joinchars "," a b c d e -> "a,b,c,d,e"
joinchars() {
    local separator=$1
    local str=""
    local i
    for ((i = 2; i < $#; i++)); do
        str+="${!i}"
        str+="$separator"
    done
    str+="${!#}"

    __RETURN="$str"
}

# usage: lower "AbCdE" -> "abcde"
lower() {
    __RETURN="${1,,}"
}

# usage: shuffle "abcdefg" -> "bcefgad"
shuffle() {
    local alphabet="$1"
    splitstr "$alphabet"
    local chars
    IFS=" " read -r -a chars <<<"$__RETURN"
    local len=${#alphabet}
    local i=0
    local j=$((len - 1))

    while [ $j -gt 0 ]; do

        ord "${chars[i]}"
        local i_ord=$__RETURN
        ord "${chars[j]}"
        local j_ord=$__RETURN

        local r=$(((i * j + i_ord + j_ord) % len))
        local temp=${chars[$i]}
        chars[i]=${chars[$r]}
        chars[r]=$temp
        i=$((i + 1))
        j=$((j - 1))
    done

    joinchars "" "${chars[@]}"
}

# usage: to_id 4 "abcde" -> "e"
to_id() {
    local num=$1
    local alphabet=$2
    local id_chars=()

    while true; do
        id_chars=("${alphabet:$((num % ${#alphabet})):1}" "${id_chars[@]+"${id_chars[@]}"}") # it can be "${id_chars[@]}" without `set -u`, workaround for bash 4.0
        num=$((num / ${#alphabet}))
        if [[ $num -eq 0 ]]; then
            break
        fi
    done

    joinchars "" "${id_chars[@]}"
}

# usage: to_number "abacdeecba" "abcde" -> 434305
to_number() {
    local id="$1"
    local alphabet="$2"
    local result=0
    local count=${#alphabet}

    splitstr "$id"
    for id_char in $__RETURN; do
        local index
        for ((index = 0; index < count; index++)); do
            if [ "${alphabet:$index:1}" == "$id_char" ]; then
                break
            fi
        done
        result=$((result * count + index))
    done

    __RETURN=$result
}

# usage: is_blocked_id "blockedword1 blockedword2 blockedword3" "abcde" -> false
is_blocked_id() {
    local block_list=$1
    local id="$2"
    lower "$id"
    id=$__RETURN

    for word in $block_list; do
        if [ ${#word} -gt ${#id} ]; then
            continue
        fi

        if [[ ${#id} -le 3 || ${#word} -le 3 ]]; then
            if [ "$id" == "$word" ]; then
                __RETURN=true
                return 0
            fi
        elif [[ "$word" == *[0-9]* ]]; then
            if [[ "$id" == "$word"* || "$id" == *"$word" ]]; then
                __RETURN=true
                return 0
            fi
        elif [[ "$id" == *"$word"* ]]; then
            __RETURN=true
            return 0
        fi
    done

    __RETURN=false
    return 0
}

# usage: encode_numbers -a $DEFAULT_ALPHABET -b "${DEFAULT_BLOCKLIST[*]}" -l $DEFAULT_MIN_LENGTH 1 2 3 0 -> "86Rf07"
encode_numbers() {
    local original_alphabet_str
    local block_list
    local min_length
    local i

    local OPTIND=0
    while getopts a:b:l: OPT; do
        case $OPT in
        a) original_alphabet_str="$OPTARG" ;;
        b) block_list="$OPTARG" ;;
        l) min_length="$OPTARG" ;;
        ?)
            echo "ERROR: Invalid option -$OPTARG" >&2
            exit 1
            ;;
        esac
    done

    shuffle "$original_alphabet_str"
    local alphabet_str=$__RETURN

    shift $((OPTIND - 1))

    local numbers=("${@:1:$#-1}")
    local increment="${!#}"

    if [ "$increment" -gt ${#alphabet_str} ]; then
        echo "Reached max attempts to re-generate the ID"
        return 1
    fi

    local offset=0

    for ((i = 0; i < ${#numbers[@]}; i++)); do
        local v=${numbers[i]}
        local char=${alphabet_str:$((v % ${#alphabet_str})):1}
        ord "$char"
        local char_ord=$__RETURN
        offset=$((offset + char_ord + i))
    done

    offset=$(((offset + ${#numbers[@]}) % ${#alphabet_str}))
    offset=$(((offset + increment) % ${#alphabet_str}))

    # rotate alphabet
    local rotated_alphabet=""
    for ((i = offset; i < ${#alphabet_str}; i++)); do
        rotated_alphabet+="${alphabet_str:$i:1}"
    done
    for ((i = 0; i < offset; i++)); do
        rotated_alphabet+="${alphabet_str:$i:1}"
    done

    local prefix=${rotated_alphabet:0:1}

    # reverse alphabet
    local reversed_rotated_alphabet=""
    for ((i = ${#alphabet_str} - 1; i >= 0; i--)); do
        reversed_rotated_alphabet+="${rotated_alphabet:$i:1}"
    done
    alphabet_str="$reversed_rotated_alphabet"

    local ret=("$prefix")

    for ((i = 0; i < ${#numbers[@]}; i++)); do
        local num=${numbers[$i]}
        to_id "$num" "${alphabet_str:1}"
        ret+=("$__RETURN")

        if [[ $i -ge $((${#numbers[@]} - 1)) ]]; then
            continue
        fi

        ret+=("${alphabet_str:0:1}")
        shuffle "$alphabet_str"
        alphabet_str=$__RETURN
    done

    joinchars "" "${ret[@]}"
    local id=$__RETURN

    if [ "$min_length" -gt "${#id}" ]; then
        id+=${alphabet_str:0:1}

        while [ $((min_length - ${#id})) -gt 0 ]; do
            shuffle "$alphabet_str"
            alphabet_str=$__RETURN
            joinchars "" "${alphabet_str:0:$((min_length - ${#id} < ${#alphabet_str} ? min_length - ${#id} : ${#alphabet_str}))}"
            id+=$__RETURN
        done
    fi

    is_blocked_id "$block_list" "$id"
    local is_blocked=$__RETURN
    if $is_blocked; then
        encode_numbers -a "$original_alphabet_str" -b "$block_list" -l "$min_length" "${numbers[@]}" $((increment + 1))
    else
        echo "$id"
    fi
}

# usage: encode -a $DEFAULT_ALPHABET -b "${DEFAULT_BLOCKLIST[*]}" -l $DEFAULT_MIN_LENGTH 1 2 3 -> "86Rf07"
encode() {
    local alphabet
    local block_list
    local min_length

    local OPTIND=0
    while getopts :a:b:l: OPT; do
        case $OPT in
        a) alphabet="$OPTARG" ;;
        b) block_list="$OPTARG" ;;
        l) min_length="$OPTARG" ;;
        ?)
            echo "ERROR: Invalid option -$OPTARG" >&2
            exit 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [[ -z "$*" ]]; then
        echo ""
    else
        nums=()
        for num in "$@"; do
            nums+=("$((10#$num))")
        done
        encode_numbers -a "$alphabet" -b "$block_list" -l "$min_length" "${nums[@]}" 0
    fi
}

# usage: decode -a $DEFAULT_ALPHABET "abcde" -> 10273415
decode() {
    local alphabet_str
    local i

    local OPTIND=0
    while getopts :a: OPT; do
        case $OPT in
        a) alphabet_str="$OPTARG" ;;
        ?)
            echo "ERROR: Invalid option -$OPTARG" >&2
            exit 1
            ;;
        esac
    done

    shuffle "$alphabet_str"
    alphabet_str=$__RETURN

    shift $((OPTIND - 1))

    local id="$1"
    local ret=()

    if [[ -z "$id" ]]; then
        echo ""
        return 0
    fi

    # check if any characters are not in the alphabet
    splitstr "$id"
    for c in $__RETURN; do
        local does_exist=false
        splitstr "$alphabet_str"
        for a in $__RETURN; do
            if [ "$a" == "$c" ]; then
                does_exist=true
                break
            fi
        done
        if ! $does_exist; then
            echo ""
            return 0
        fi
    done

    local prefix="${id:0:1}"
    local offset
    for ((i = 0; i < ${#alphabet_str}; i++)); do
        if [ "${alphabet_str:$i:1}" == "$prefix" ]; then
            offset=$i
            break
        fi
    done

    local alphabet_chars=()
    for ((i = offset; i < ${#alphabet_str}; i++)); do
        alphabet_chars+=("${alphabet_str:$i:1}")
    done
    for ((i = 0; i < offset; i++)); do
        alphabet_chars+=("${alphabet_str:$i:1}")
    done
    local alphabet_chars_rev=()
    for ((i = $((${#alphabet_chars[@]} - 1)); i >= 0; i--)); do
        alphabet_chars_rev+=("${alphabet_chars[$i]}")
    done

    joinchars "" "${alphabet_chars_rev[@]}"
    alphabet_str=$__RETURN

    id="${id:1}"

    while [[ -n $id ]]; do
        separator="${alphabet_str:0:1}"

        # split id into chunks by separator
        local chunks=()
        local tmp=""
        for ((i = 0; i < ${#id}; i++)); do
            if [ "${id:$i:1}" == "$separator" ]; then
                chunks+=("$tmp")
                tmp=""
            else
                tmp+="${id:$i:1}"
            fi
        done
        chunks+=("$tmp")

        if [ "${#chunks[@]}" -gt 0 ]; then
            if [[ -z "${chunks[0]}" ]]; then
                echo "${ret[@]}"
                return 0
            else
                to_number "${chunks[0]}" "${alphabet_str:1:${#alphabet_str}-1}"
                ret+=("$__RETURN")

                if [ "${#chunks[@]}" -gt 1 ]; then
                    shuffle "$alphabet_str"
                    alphabet_str=$__RETURN
                fi
            fi
        fi

        if [ "${#chunks[@]}" -gt 1 ]; then
            joinchars "$separator" "${chunks[@]:1}"
            id=$__RETURN
        else
            echo "${ret[@]}"
            return 0
        fi
    done

    echo "${ret[@]}"
    return 0
}

usage() {
    cat <<EOS
Description:
    Sqids (pronounced "squids") is a small library that lets you generate unique IDs from numbers.
    It's good for link shortening, fast & URL-safe ID generation and decoding back into numbers for quicker database lookups.

Usage:
    $0 [-h] [-v] [-a alphabet] [-b block_list] [-l min_length] [-d ID] [-e numbers...]

Options:
    -h  Show this help message.
    -v  Show version.
    -a  Set custom alphabet. Default is "$DEFAULT_ALPHABET".
    -b  Set custom block list. See https://github.com/sqids/sqids-blocklist for default block list.
    -l  Set minimum length of the ID. Default is 0.
    -d  Decode mode. Decodes the given ID into numbers. Cannot be used with -e.
    -e  Encode mode. Encodes the given numbers into an ID. Cannot be used with -d.

EOS
    exit 0
}

version() {
    echo "sqids-bash version 1.0.1"
    exit 0
}

main() {
    local mode
    local min_length="$DEFAULT_MIN_LENGTH"
    local alphabet="$DEFAULT_ALPHABET"
    local block_list="${DEFAULT_BLOCKLIST[*]}"
    local flag_a=false
    local flag_b=false
    local flag_e=false
    local flag_d=false

    local OPTIND=0
    while getopts :a:b:l:edhv OPT; do
        case $OPT in
        a)
            alphabet="$OPTARG"
            flag_a=true
            ;;
        b)
            block_list="$OPTARG"
            flag_b=true
            ;;
        l) min_length="$OPTARG" ;;
        e)
            mode="encode"
            flag_e=true
            ;;
        d)
            mode="decode"
            flag_d=true
            ;;
        h) usage ;;
        v) version ;;
        ?)
            echo "ERROR: Invalid option -$OPTARG" >&2
            exit 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [[ -z "$mode" ]]; then
        echo "ERROR: option -e (encode) or -d (decode) is required" >&2
        exit 1
    fi

    if $flag_e && $flag_d; then
        echo "ERROR: option -e (encode) and -d (decode) cannot be used together" >&2
        exit 1
    fi

    splitstr "$alphabet"
    for char in $__RETURN; do
        ord "$char"
        local char_ord=$__RETURN
        if [[ $char_ord -gt 127 ]]; then
            echo "ERROR: Alphabet cannot contain multibyte characters" >&2
            exit 1
        fi
    done

    if [[ ${#alphabet} -lt 3 ]]; then
        echo "ERROR: Alphabet length must be at least 3" >&2
        exit 1
    fi

    declare -A alphabet_dict
    splitstr "$alphabet"
    for char in $__RETURN; do
        if ${alphabet_dict[$char]:-false}; then
            echo "ERROR: Alphabet cannot contain duplicate characters" >&2
            exit 1
        else
            alphabet_dict[$char]=true
        fi
    done

    MIN_LENGTH_LIMIT=255
    if [[ $min_length -lt 0 || $min_length -gt $MIN_LENGTH_LIMIT ]]; then
        echo "ERROR: Minimum length has to be between 0 and $MIN_LENGTH_LIMIT" >&2
        exit 1
    fi

    local filtered_blocklist=()
    if $flag_a || $flag_b; then
        lower "$alphabet"
        local alphabet_lower=$__RETURN
        declare -A alphabet_lower_dict
        splitstr "$alphabet_lower"
        for char in $__RETURN; do
            alphabet_lower_dict[$char]=true
        done

        lower "$block_list"
        for word_lower in $__RETURN; do
            if [[ ${#word_lower} -ge 3 ]]; then
                local does_exist=true
                splitstr "$word_lower"
                for char in $__RETURN; do
                    if [[ -z "${alphabet_lower_dict[$char]:-false}" ]]; then
                        does_exist=false
                        break
                    fi
                done
                if $does_exist; then
                    filtered_blocklist+=("$word_lower")
                fi
            fi
        done
    fi

    case "$mode" in
    "encode")
        if $flag_a || $flag_b; then
            encode -a "$alphabet" -b "${filtered_blocklist[*]+"${filtered_blocklist[*]}"}" -l "$min_length" "$@" # it can be "${filtered_blocklist[*]}" without `set -u`, workaround for bash 4.0
        else
            encode -a "$alphabet" -b "${block_list[*]}" -l "$min_length" "$@"
        fi
        ;;
    "decode")
        decode -a "$alphabet" "$@"
        ;;
    esac
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
