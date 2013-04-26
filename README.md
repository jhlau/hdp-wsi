This directory contains the scripts and various python tools for running HDP to induce word senses.

Directory structure and files
=============================
* run_wsi.sh: the main script for driving the WSI system.
* topicmodelling: contains various document preprocessing tools and the HDP program.
* wsi_input: contains the input for the WSI system.
* wsi_output: contains the output for the WSI system.

Running the system
==================
* Generate the input files for the system (format described below).
* Fix the GSL library path for compiling hdp (in topicmodelling/hdp/Makefile)
* Set up HDP parameters (such as the gamma and alpha paramters, stopwords); these settings are in the 
topic model script (topicmodelling/run_topicmodel.sh)
* Set up WSI parameters; these settings are in the WSI script (run_wsi.sh)
* Execute run_wsi.sh

WSI Input Format
================
* num_test_instances.all.txt: contains the number of TEST instances/documents for the WSI system, one 
line per lemma.
* all/<target_word>.lemma: contains the instances/documents for the WSI system, one file per lemma and 
one line per instance/document.

Note that the total number of instances may be greater than the TEST instances - the test instances 
are instances of interest that will be evaluated. The remaining instances are additional/training 
instances for the topic model to produce higher quality senses.  The test instances should ALWAYS be 
put at the beginning of the input file (all/<target_word>.lemma), i.e. if there are 100 test 
instances and 200 additional/training instances, the first 100 lines of the input file should 
contain the 100 test instances, and the next 200 lines are the additional/training instances.

WSI Output
==========
* tm_wsi: contains the sense distribution for each instance/document (one document per line). The 
instances correpond to the original order of the input file (all/<target_word>.lemma).
* tm_wsi.topics: gives the top-10 terms for the induced topics (one topic per line).
* topic_worprob: contains the pickle files which contains the word distribution of the induced senses 
for each lemma.
