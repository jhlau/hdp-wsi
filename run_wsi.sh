#!/bin/bash
#Main script that drives the WSI system. Uses HDP as the topic model for inducing senses.

#parameters
input_dir="wsi_input/example"
output_dir="wsi_output"
wsd_output="tm_wsi" #output file that contains the sense distribution for each document

#variables (shouldn't need to change this)
wsi_type="all"

#check if necessary output directories are created
if ! [ -d $output_dir/topic_wordprob ]
then
    mkdir -p $output_dir/topic_wordprob
fi

#delete the any previously generated wsd prediction
rm $output_dir/$wsd_output 2>/dev/null
rm $output_dir/$wsd_output.topics 2>/dev/null

#extract the sentences from the dataset (test then train)
for file in `ls $input_dir/$wsi_type`
do
    echo "============================================================================"
    echo "--------------------------------"
    echo "Processing $file"
    echo "--------------------------------"

    #get the word
    word=`basename $file .lemma`
    word_pat=`echo $word | sed -e 's/\./\\\./g'`

    #get the number of test_instances
    num_test_inst=`grep "^$word_pat" $input_dir/num_test_instances.$wsi_type.txt | cut -f 2-2 -d \ `
    echo -e "\tNumber of test instances = $num_test_inst"

    #link the input text in the hdp directory
    cd topicmodelling/
    rm input.txt 2>/dev/null
    ln -s ../$input_dir/$wsi_type/$word.lemma input.txt

    #do topic modelling
    target_word=`echo $word | cut -f 1-1 -d\.`
    #remove hyphen
    target_word=`echo $target_word | cut -f 1-1 -d-`
    rm topicmodel_output/* 2>/dev/null
    ./run_topicmodel.sh $target_word

    #get the sense distribution and print it to the output file
    for i in `seq 1 $num_test_inst`
    do
        instance_id="$word.$i"
      
        data=`head -n $i topicmodel_output/topicsindocs.txt | tail -n 1 | cut -f 3- -d \ `
        if ! [ ${#data} -eq 0 ]
        then
            echo "$word $instance_id $data" >> ../$output_dir/$wsd_output
        #no data, default to topic 1
        else
            echo "$word $instance_id t.1/1.0000" >> ../$output_dir/$wsd_output
        fi
    done

    #get the topics
    sed "s/^/$word: /g" topicmodel_output/topics.txt >> ../$output_dir/$wsd_output.topics
    #get the topic word prob pickle file
    cp topicmodel_output/topics.pickle ../$output_dir/topic_wordprob/$word.topics.pickle

    #remove the softlinked file
    rm input.txt

    #change back to wsi directory
    cd ../

done
