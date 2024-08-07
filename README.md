# minigraph-barley

This repository contains scripts used for the construction and analysis of minigraph-based graphs for version 2 of the barley pan-genome. 

Scripts are written in BASH and R and were developed and tested on Rocky Linux v8.8. Other Linux distributions may be compatible but no testing has taken place in this regard. 

The scripts are organised as follows:

scripts/graphConstruction:
- buildGraph_incremental.sh: a Slurm array job script for the incremental construction and SV calling of pan-genome graphs with minigraph, using a single chromosome for each subtask
- combineGraphs.sh: combines all graphs built for individual chromosomes into a single graph and builds a GBWT index 
- convert.sh: converts the chromosome-based graphs from GFA to VG format for downstream analysis
- convertToGFA.sh: converts the combined, genome-wide graph from VG to GFA format for compatibility with other tools

scripts/SVstats:
- extractSVCoordsByType.sh: extracts structural variant entries from the final BED files produced during graph construction/SV calling and separates them by type (simple inversions, deletions and insertions, but no nested complex variants)
- violinPlot.r: takes the output from extractSVCoordsByType.sh and plots the length statistics of each SV category in a violin plot
- SV_comparison.sh: extracts deletions and insertions from both Minigraph and Assemblytics SV files and feeds their coordinates to bedtools intersect for overlap comparison

scripts/graphStats:
- odgiheaps_byGroup.sh: runs odgi heaps command for each group (domesticated, wild and all lines) and then plots a saturation plot using script heaps_fit.R which is supplied with the odgi package
- vgStat.sh and vgStat_joint.sh: computes basic statistics for chromosome-based graphs and combined graph respectively

scripts/mappingExperiment:
- mapWGS.sh: a Slurm array job script for downloading and mapping five public barley whole genome shotgun datasets from the European Nucleotide Archive (ENA); mappings are carried out using both bwa mem and vg giraffe for comparison
- extractStats.sh: extracts and formats mapping statistics from each mapping for further analysis
- calcMappingStats.r: takes the output from the preceding script and calculates comparative mapping statistics such as % reads mapped, % properly paired reads, etc. 

scripts/mappingExperiment/linearisedGraph:
- 00_gfa2fa.sh: converts separate GFA format graphs (one per chromosome) into FASTA files using gfatools gfa2fa
- 01_concat.sh: combines the per-chromosome FASTA files
- 02_indexBWA.sh: builds BWA index for mapping
- 03_mapWGS.sh: array job for downloading and mapping of the five public WGS samples

scripts/srh1_analysis:
- 01_extractNodesToFASTA.sh: extracts all individual nodes from genome-wide graph to a FASTA file
- 02_blastVsNodes.sh: BLASTs the srh1 enhancer region from cv. Barke against all 76 pan-genome accessions
- 03_extractSubgraph.sh: extracts a smaller subgraph containing the nodes spanning the deletion and flanking regions
- 04_odgiviz.sh: code for plotting the subgraph
- 05_mapToGraph.sh: mapping of the eight core800 samples to the graph
- 06_chunkGam.sh: extraction of a smaller portion of the GAM files produced in the previous step
- 07_genotype.sh: genotyping of the srh1 region in the graph for the eight core800 samples


Input data for graph construction was 76 barley genomes (approx. 5 gigabases each), split into separate chromosome input files each. Graph construction was carried out incrementally with minigraph on a per-chromosome basis and required 44-49 GB peak RAM and 10-22 days of wallclock time per subtask. Minigraph offers multithreading but this is effectively disabled when single, entire chromosome sequences are used as input (see https://github.com/lh3/minigraph/issues/62) and results in a single thread of execution for graph construction.

