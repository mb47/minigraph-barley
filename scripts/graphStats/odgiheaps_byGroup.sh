#!/bin/bash

#SBATCH --mem=1g
#SBATCH -o slurm-%x_%A.out  

numPermutations=100
graph=../../../minigraph_76lines_combinedGraph.og

runs=( domesticatedLines wildLines allLines )
for run in ${runs[*]}
do
	echo -e "\nrun = $run"
	
	source activate odgi
	
	pathsFile="paths_"$run".txt"
	
	echo "running odgi paths"
	date
	odgi paths \
	--threads $SLURM_CPUS_PER_TASK \
	-i $graph \
	-Ll \
	| grep -f $pathsFile \
	| awk -v OFS='\t' '{print($1,$2-1,$3)}' \
	| sort \
	> $run.odgipaths.bed

	echo "running odgi heaps"
	date
	odgi heaps \
	--threads $SLURM_CPUS_PER_TASK \
	-i $graph \
	-n $numPermutations \
	-b $run.odgipaths.bed \
	-S \
	> $run.heaps.txt

	echo "plot output"
	date
	source activate R_env

	Rscript heaps_fit.R \
	$run.heaps.txt \
	$run.heaps.png

done 


echo "workflow complete"
date
