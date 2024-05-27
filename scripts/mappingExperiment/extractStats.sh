#!/bin/bash

outputFile=comparativeStats_mappingExpt.txt

rm $outputFile

gamStats[1]="Total alignments:"
gamStats[2]="Total properly paired:"
gamStats[3]="Substitutions:"
gamStats[4]="Total aligned:"
gamStats[5]="Softclips:"
gamStats[6]="Total perfect:"

bamStats[1]="raw total sequences:"
bamStats[2]="reads mapped:"
bamStats[3]="reads properly paired:"
bamStats[4]="bases mapped (cigar):"
bamStats[5]="mismatches:"
bamStats[6]="maximum length:"


#dirs with stats files, by category
gamStatsDir=./mappingExpt/gam

bamStatsDir=./mappingExpt/bam

filteredBamStatsDir=./mappingExpt/bam/filtered/strict

LPGGstatsDir=./mapping_linearisedPanG/linearisedPanG

filteredLPGGstatsDir=./mapping_linearisedPanG/linearisedPanG/strictFilter


accessions=( ERR2766176 SRR10200200 SRR5197485 SRR5197496 SRR6281633 )

for accession in ${accessions[*]}
do
	echo -e "\naccession = $accession"
	
	gamStatsFile=$gamStatsDir/$accession.gam.stats
	bamStatsFile=$bamStatsDir/$accession.sorted.bam.stats
	filteredBamStatsFile=$filteredBamStatsDir/$accession.filtered.bam.stats
	LPGGstatsFile=$LPGGstatsDir/$accession.sorted.bam.stats
	filteredLPGGstatsFile=$filteredLPGGstatsDir/$accession.filtered.bam.stats
	
	for gamStat in "${gamStats[@]}"
	do
		echo -e "extract gamStat "$gamStat""
		statNameFormatted="gam_"`echo "$gamStat" | sed 's/ /_/g' | sed 's/://g'`
		value=`grep "$gamStat" $gamStatsFile | cut -f 2 -d ":" | cut -f 2 -d " "`
		echo -e "$accession\t$statNameFormatted\t$value" >> $outputFile
	done
	
	
	for bamStat in "${bamStats[@]}"
	do
		echo -e "extract bamStat "$bamStat""
		statNameFormatted="bam_"`echo "$bamStat" | sed 's/ /_/g' | sed 's/://g' | sed 's/(//g' | sed 's/)//g'`
		value=`grep "$bamStat" $bamStatsFile | cut -f 3`
		echo -e "$accession\t$statNameFormatted\t$value" >> $outputFile
	done
	
	
	for bamStat in "${bamStats[@]}"
	do
		echo -e "extract bamStat "$bamStat""
		statNameFormatted="filtered_bam_"`echo "$bamStat" | sed 's/ /_/g' | sed 's/://g' | sed 's/(//g' | sed 's/)//g'`
		value=`grep "$bamStat" $filteredBamStatsFile | cut -f 3`
		echo -e "$accession\t$statNameFormatted\t$value" >> $outputFile
	done


	for bamStat in "${bamStats[@]}"
	do
		echo -e "extract bamStat "$bamStat""
		statNameFormatted="LPGG_bam_"`echo "$bamStat" | sed 's/ /_/g' | sed 's/://g' | sed 's/(//g' | sed 's/)//g'`
		value=`grep "$bamStat" $LPGGstatsFile | cut -f 3`
		echo -e "$accession\t$statNameFormatted\t$value" >> $outputFile
	done
	
	
	for bamStat in "${bamStats[@]}"
	do
		echo -e "extract bamStat "$bamStat""
		statNameFormatted="filteredLPGG_bam_"`echo "$bamStat" | sed 's/ /_/g' | sed 's/://g' | sed 's/(//g' | sed 's/)//g'`
		value=`grep "$bamStat" $filteredLPGGstatsFile | cut -f 3`
		echo -e "$accession\t$statNameFormatted\t$value" >> $outputFile
	done
	
done
