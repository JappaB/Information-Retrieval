#!/usr/bin/env bash

arg0="-q"
touch temp.txt

for file in run/*; do

    qrel=ap_88_89/qrel_test
    echo "Running TREC-eval on: $file"

    filename="${file//.run/}".txt
    if [[ -e "$filename" ]] || [[ ${file:(-4)} == ".txt" ]] ; then
        len=${#file}
        echo "TREC-eval file for ${file::len-4} already exists, skipping..."
        continue
    fi

    if [[ $file = *"validation"* ]]; then
        qrel=ap_88_89/qrel_validation
    fi

    # Retrieves standard TREC output and filters for MAP, P@5 and standard stats:
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
