library(reshape2)

df <- read.table("comparativeStats_mappingExpt.txt", header=F)

colnames(df) <- c("accession", "statName", "values")
str(df)

castDF <- dcast(df, accession ~ statName)
str(castDF)

# For the comparison we need:
# reads mapped (%)
# properly paired reads (%)
# error rate (%)
# # mismatches
# ===================
# graph stats to compute (from GAM file):
castDF$gam_pctReadsMapped <- (castDF$gam_Total_aligned / castDF$gam_Total_alignments)*100
castDF$gam_pctPropPairReads <- (castDF$gam_Total_properly_paired / castDF$gam_Total_alignments) *100
# bases mapped = (Total aligned * read length) - Softclips
castDF$gam_basesMapped <- (castDF$gam_Total_aligned * castDF$bam_maximum_length) - castDF$gam_Softclips
# error rate (%) = (Substitutions / bases mapped) * 100
castDF$gam_errorRatePct <- (castDF$gam_Substitutions / castDF$gam_basesMapped) * 100
# # mismatches = Substitutions
castDF$gam_numMismatches <- castDF$gam_Substitutions

# ===================
# linear reference stats to compute (from BAM file): 
# reads mapped (%) = (reads mapped / raw total sequences) *100 
castDF$bam_pctReadsMapped <- (castDF$bam_reads_mapped / castDF$bam_raw_total_sequences)*100
# properly paired reads (%) = (reads properly paired / raw total sequences) * 100
castDF$bam_pctPropPairReads <- (castDF$bam_reads_properly_paired / castDF$bam_raw_total_sequences)*100
# error rate (%) = (mismatches / bases mapped (cigar)) * 100
castDF$bam_errorRatePct <- (castDF$bam_mismatches / castDF$bam_bases_mapped_cigar)*100
# # mismatches = castDF$bam_mismatches

#write data to tab delimited output file
write.table(castDF,file="comparativeStats_mappingExpt_withComputedVars.txt",row.names = F,col.names = T,quote = F,sep='\t')