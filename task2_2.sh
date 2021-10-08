#!/bin/bash

help=$(cat <<-END
    -i --input       : path to dataset csv file with data
    -r --train_ratio : percentage of objects in train sample
    -y --y_column    : name of the column, where objects class labels are located (not used)
    -t --train       : path to train samples
    -v --validaton   : path to validaton samples
    -h --help        : help
END
)

while [ $# -gt 0 ]
do
    case "$1" in
    (-i | --input) 
    input=$2
    ;;
    (-r | --train_ratio) 
    train_ratio=$2
    ;;
    (-y | --y_column) 
    y_column=$2
    ;;
    (-t | --train) 
    train=$2
    ;;
    (-v | --validaton) 
    validaton=$2
    ;;
    (-h | --help) 
    echo "$help"
    exit 0
    ;;
    esac
    shift
done

read -r headers < $input

lines_number=$(expr $(wc -l $input | cut -d " " -f 1) - 1)
train_lines_number=$(echo $lines_number*$train_ratio | bc)
train_lines_number=$(echo ${train_lines_number%%.*})
validation_lines_number=$(expr $lines_number - $train_lines_number)

echo $headers >> $train
echo $headers >> $validaton

awk -v train="$train" -v validaton="$validaton" -v ratio="$train_ratio" -v tln="$train_lines_number" -v vln="$validation_lines_number" '{ 
tl = 0; 
vl = 0; 
if (NR != 1) if((rand()<ratio && tl < tln) || vl >vln) 
{tl++
 print >> train}
else {
vl++
print >> validaton
}}' $input
