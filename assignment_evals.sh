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
    xargs -n3 < temp.txt >> $filename.temp
    cp /dev/null temp.txt
    grep -E "^map\s|^P_5\s|^num_rel\s|^num_rel_ret\s" $filename.temp >> $filename
    cp /dev/null $filename.temp

    # Adding additional non-default TREC measurements...
    echo $(./trec_eval/trec_eval "-q" "-m" "ndcg_cut.10" "$qrel" "$file") >> $filename.temp
    echo $(./trec_eval/trec_eval "-q" "-m" "recall.1000" "$qrel" "$file") >> $filename.temp
    xargs -n3 < $filename.temp >> $filename
    rm $filename.temp

done
rm temp.txt
