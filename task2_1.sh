#!/bin/bash

help=$(cat <<-END
    -f    	: path to dataset in csv format
    -c    	: the column in which the data links are located
    -s		: separator
    -n    	: number of workers
    -p      	: folder for saving data
    -h     	: help
END
)

while getopts f:c:n:s:p:h: flag
do
  case "${flag}" in
  f) 
  csvfile=${OPTARG}
  ;;
  c) 
  column=${OPTARG}
  ;;
  n) 
  n=${OPTARG}
  ;;
  s) 
  sep=${OPTARG}
  ;;
  p) 
  path=${OPTARG}
  ;;
  h) 
  echo "$help"
  exit 0
  ;;
  *) 
  echo "unsupported flag used"
  ;;
  esac
done

read -r headers < "$csvfile"

index=-1

IFS="$sep"
read -r -a strarr <<< "$headers"

for i in "${!strarr[@]}"
do
	if [ "$column" = "${strarr[$i]}" ];
		then
		index=$(($i+1))
	fi
done

if [ $index = -1 ]; then
    echo "No '$column' column found"
    exit 1
fi

(cut -d "$sep" -f"$index" "$csvfile" | parallel -j"$n" wget -t 3 -P "$path") 2> /dev/null

echo "Success"
