#!/bin/bash

#SBATCH -o slurm-%x_%A.out 
#SBATCH --mem=15g
#SBATCH -p short

##################################################################
#command line parameters
##################################################################
#FASTA file with query sequences
query=deletion_Barke.fasta

#BLAST database with subject sequences
#this script assumes the required index files have already been built with makeblastdb
db=minigraph_76lines_combinedGraph_nodes.fasta

#tab-delimited output with additional fields (.txt extension)
outputFile=deletion_vs_graph.txt

#cutoff for % identity
perc_identity=90

##################################################################
#get processing
##################################################################

echo "make a header file for the output table"
echo -e "qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tqlen\tslen\tqcovs\tqcovhsp" > BLAST_tableHeader.txt 

#extract a prefix for temp file naming from the output file name
prefix=`basename $outputFile .txt`
echo "prefix for output file = $prefix"

source activate blast

echo "run the BLAST job"
blastn \
-query $query \
-db $db \
-outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp" \
-out $prefix.raw \
-perc_identity $perc_identity 

echo "add a header to the output table"
cat BLAST_tableHeader.txt $prefix.raw > $prefix.withHeader

#extract top blast hit for each query
awk '! a[$1]++' $prefix.withHeader > $outputFile

rm BLAST_tableHeader.txt

echo "BLAST run complete"

