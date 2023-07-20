#!/bin/bash

#SBATCH --mem=60g
#SBATCH --cpus-per-task=32
#SBATCH --array=1-7
#SBATCH -o slurm-%x_%A_%a.out 
#SBATCH --partition=long

chroms[1]=chr1H
chroms[2]=chr2H
chroms[3]=chr3H
chroms[4]=chr4H
chroms[5]=chr5H
chroms[6]=chr6H
chroms[7]=chr7H

#the name of the reference genotype
referenceGenotype=Morex_V3
#its genome assembly
refAssembly=210316_Morex_V3_pseudomolecules_and_unplaced_scaffolds_ENA.fasta.gz
#a text file with full paths to all the genotype assemblies to be used for the pan-genome, one per line
#the order of files in this will be the order of addition when we build the graph
fileWithAssemblyPaths=allFiles_IPK_order.txt

workingDir=`pwd`
#we need a file with path prefixes so we can export the paths correctly from RGFA to GFA format
pathPrefixSampleFile=$workingDir/pathPrefixes.txt

#####################################################################
#preparation
#####################################################################
#the chromosome to process in the current instance of the script
chrom=${chroms[SLURM_ARRAY_TASK_ID]}

#make an array with the paths to the assembly filePaths - these are in FASTA format and gzipped
#for this we parse an input file with all the file paths
#split the input by line
IFS=$'\n'
#read the whole file with the sample info
filePaths=( `cat $fileWithAssemblyPaths` )

echo "starting minigraph build"
date

echo -e "\nprocess chromosome $chrom\n"

#make a dedicated directory for each chromosome and do the work in there
mkdir $chrom
cd $chrom

#########################################################################################################
#first extract sequence for reference genotype so we can use this as the backbone for the graph
#########################################################################################################
echo "extract $chrom from $referenceGenotype"
newChromName="$referenceGenotype#1#"$chrom
echo "newChromName = $newChromName"

seqkit grep \
-p $chrom \
$refAssembly \
| sed "s|$chrom|$newChromName|g" \
> $chrom.$referenceGenotype.fasta

#########################################################################################################
#extract the sequence for the first sample in the array (use index 1, reference genotype is index 0)
#########################################################################################################
path=${filePaths[1]}
file=`basename $path`
#extract name of sample from file name
pattern='(?<=\d{6}_).*(?=_pseudo)'
sample1=`echo $file | grep -o -P $pattern`
echo "sample1 = $sample1"
echo "extract $chrom from sample1 $sample1"
newChromName=$sample1"#1#"$chrom
echo "newChromName = $newChromName"
echo "path = $path"

#extract the sequence
seqkit grep \
-p $chrom \
$path \
| sed "s|$chrom|$newChromName|g" \
> $chrom.$sample1.fasta

#########################################################################################################
#build the initial graph from the reference genotype and the first sample in the list
#########################################################################################################
echo "construct initial graph"
date
minigraph \
-cxggs \
-t $SLURM_CPUS_PER_TASK \
$chrom.$referenceGenotype.fasta \
$chrom.$sample1.fasta \
> $chrom.out.rgfa

#a counter for the iterations of RGFA graphs we produce
COUNT=1

#call SVs now so we can track the increase of the number of SVs as a function of the number of samples added
echo "call SVs on initial graph"
date
gfatools bubble $chrom.out.rgfa > SVs.bubble.$sample1.$COUNT.bed

#rename the graph so it's ready for the loop that follows
mv $chrom.out.rgfa $chrom.current.rgfa

#########################################################################################################
#loop over all the other samples and add to the graph the current chromosome from each of them 
#########################################################################################################
for path in ${filePaths[*]}
do

	file=`basename $path`
	echo -e "\nprocessing $file"
	echo "path = $path"
	#extract name of sample from file name
	pattern='(?<=\d{6}_).*(?=_pseudo)'
	sample=`echo $file | grep -o -P $pattern`
	echo "sample = $sample"

	#now check this sample is not the reference sample or sample1 -- we don't want to add these twice
	if [[ $sample != $referenceGenotype ]] && [[ $sample != $sample1 ]]
	then
		################################################
		#extract the current chromosome from this sample
		################################################
		#increment our count of RGFA graphs
		let COUNT=COUNT+1

		echo "extract $chrom from sample $sample"
		newChromName=$sample"#1#"$chrom
		echo "newChromName = $newChromName"
		date
		
		seqkit grep \
		-p $chrom \
		$path \
		| sed "s|$chrom|$newChromName|g" \
		> $chrom.$sample.fasta
		
		################################################
		#now add this sample's chromosome to the current graph
		################################################
		echo "add chrom $chrom from sample $sample to the current graph"
		date
		minigraph \
		-cxggs \
		-t $SLURM_CPUS_PER_TASK \
		$chrom.current.rgfa \
		$chrom.$sample.fasta \
		> $chrom.out.rgfa
		
		#call SVs now so we can track the increase of the number of SVs as a function of the number of samples added
		echo "call SVs on RGFA graph"
		date
		gfatools bubble $chrom.out.rgfa > SVs.bubble.$sample.$COUNT.bed

		#rename the graph so we're ready for the next iteration
		mv $chrom.out.rgfa $chrom.current.rgfa
		
	else
		echo "skipping this sample"
	fi

done

echo -e "\n\n=================finished minigraph build for chrom $chrom"
date

#rename the final graph
mv $chrom.current.rgfa $chrom.rgfa


#########################################################################################################
#loop over all the samples and map their sequence for this chromosome to the graph
#########################################################################################################
echo "map paths for all samples"
date

for path in ${filePaths[*]}
do

	file=`basename $path`
	echo -e "\nprocessing $file"
	#extract name of sample from file name
	pattern='(?<=\d{6}_).*(?=_pseudo)'
	sample=`echo $file | grep -o -P $pattern`
	echo "sample = $sample"

	echo "call path for genotype $genotype"
	date
	minigraph \
	-xasm \
	-l10k \
	--call \
	-t $SLURM_CPUS_PER_TASK \
	$chrom.rgfa \
	$chrom.$sample.fasta \
	> $chrom.$sample.call.bed
	
done


#########################################################################################################
#gather up all the BED files from the path mapping, combine them and append them to the RGFA graph
#########################################################################################################

#we need a file with path prefixes so we can export the paths correctly from RGFA to GFA format
#we have a central example file that we simply modify by doing a global replace of the chromosome name
echo "modify file with path prefixes for current chromosome"
date
sed 's/chr1H//g'
sed "s|chr1H|$chrom|g" $pathPrefixSampleFile > pathPrefixes.$chrom.txt

echo "combine BED files and convert to GFA P lines"
date
paste *.call.bed \
| mgutils.js path pathPrefixes.$chrom.txt - \
> $chrom.paths.mgutils.gfa

echo "combine RGFA graph with paths"
date
cat \
$chrom.rgfa \
$chrom.paths.mgutils.gfa \
> $chrom.withPaths.rgfa

echo "convert RGFA file with paths to GFA file"
date
source activate pggb
vg convert \
--threads $SLURM_CPUS_PER_TASK \
--gfa-in \
--gfa-out \
--in-rgfa-rank 10000 \
$chrom.withPaths.rgfa \
> $chrom.withPaths.gfa


echo "workflow complete"

