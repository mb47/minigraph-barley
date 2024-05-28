#!/bin/bash

#SBATCH -o slurm-%x_%A.out 
#SBATCH --mem=15g
#SBATCH -p short

graphDir=$1
xgFileWholeGraph=minigraph_76lines_combinedGraph.xg

prefix=subgraph_srh1Region

nodeRange="3177308:3177312"
extendByNodeSteps=6

echo "activate vg"
date

source activate vg

echo "extract subgraph"
date
vg find \
-r $nodeRange \
-c $extendByNodeSteps \
-x $graphDir/$xgFileWholeGraph \
> $prefix.vg

echo "convert graph from vg to gfa format"
date
vg convert \
--gfa-out \
--no-wline \
$prefix.mod.vg \
> $prefix.gfa

echo "add path with BLAST hits to GFA file"
date
echo -e "P\tBLAST_Hits_deletion\t3177308+,6997187+,6997188+,3177310+,3177312+\t*" >> $prefix.gfa

source deactivate
source activate odgi

echo "build og graph from srh1 graph"
date
odgi build \
-g $prefix.gfa \
-o $prefix.og

echo "optimise og graph "
date
odgi sort \
--optimize \
-i $prefix.og \
-o $prefix.opt.og

echo "apply topological sort "
date
odgi sort \
-Y \
-i $prefix.opt.og \
-o $prefix.opt.sorted.og


echo "plot"
date
bash 02_odgiviz.sh

echo "done"
date