
dev=$HOME/dev
cwd=$(pwd)

item=$(basename $cwd)

sec= 
type=
case "$item" in
   *.*_*.*)
      sec=${item##*.}
      type=$(echo $item | perl -pe 's/\w+\.(\w+)_\w+\.\w+/$1/g')
      [ -n "$type" ] || { echo "Err: couldnt detect data type"; exit 1; }
      ;;
   *)
      echo "Err: item $item not the correct form"
      exit 1;
      ;;
esac

unisondir=$HOME/.unison
mkdir -p $unisondir

rm -f $dev/.unison
ln -s $unisondir $dev/.unison

for d in *; do
   if [ -d "$d" ]; then 
      case "$d" in 
         *.*)
            folder=${d##*.}s
            mkdir -p "$dev/$folder"

            if [  "$folder" = "clouds" ]; then
               rm -f $dev/$folder/$item
               ln -s $cwd $dev/$folder/$item
            else
               user=${d%.*}
               rm -f $dev/$folder/$user.$type.$sec
               ln -s $cwd/$d $dev/$folder/$user.$type.$sec
            fi
            
            
      ;;
         *)
         continue
      ;; 
      esac
   else
      case "$d" in
         *.prf)
            rm -f $unisondir/$d
            ln -s $cwd/$d $unisondir/$d
            ;;
         *)
            continue
            ;;
      esac
   fi
done
