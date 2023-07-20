#!/bin/bash

#SBATCH --mem=50G
#SBATCH -o slurm-%x_%A.out  
#SBATCH --partition long


prefix=minigraph_76lines_combinedGraph
graphDir=$1

source activate vg

echo "combine graphs"
date
vg combine \
chr1H.vg \
chr2H.vg \
chr3H.vg \
chr4H.vg \
chr5H.vg \
chr6H.vg \
chr7H.vg \
> $prefix.vg


#we need to split up nodes > 1000 bp -- this seems to be a limitation in vg
echo "split up nodes of length > 1000 in VG graph"
date
vg mod \
--chop 1000 \
$prefix.vg \
> $prefix.mod.vg

echo "convert combined graph to XG representation"
date
vg index \
-x $prefix.xg \
$prefix.mod.vg

echo "build GBWT index for combined graph"
date
vg gbwt \
-x $prefix.xg \
--index-paths \
-o $prefix.gbwt

echo "workflow complete"
date


