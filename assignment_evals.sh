#!/usr/bin/env bash

qrel=ap_88_89/qrel_test
arg0="-q"
touch temp.txt
for file in run/*; do

    echo "Running TREC-eval on: $file"

    filename="${file//.run/}".txt
    if [[ -e "$filename" ]]; then
        echo "File $filename already exists, rename: $file. Skipping..."
        break
    fi

    #./trec_eval/trec_eval -q ap_88_89/qrel_test run/TF-IDF.run | grep -E "^map\s"
    echo $(./trec_eval/trec_eval "$arg0" "$qrel" "$file") >> temp.txt
    xargs -n3 < temp.txt >> $filename
    cp /dev/null temp.txt
    grep -E "^map\s|^P_5\s" $filename >> $filename.temp
    mv $filename.temp $filename

done
rm temp.txt
