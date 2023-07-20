library(ggplot2)
library(scales)


#PNG output stream
png("simpleSVsByType.png",width=1000,height=700)

write("read the input file", stdout())
svLengthData <- read.table("simpleSVsByType.txt",sep="\t",header=F)

#set the column names
colnames(svLengthData)<-c("chrom", "start", "end", "numSeqs", "numPaths", "inversionFlag", "lengthShortestPath", "lengthLongestPath","type")

# write("calculate the length from the path lengths", stdout())
# svLengthData$length <- svLengthData$lengthLongestPath - svLengthData$lengthShortestPath

message("compute descriptive stats by type")
descrStatsByChromo <- aggregate(lengthLongestPath ~ chrom+type, svLengthData, FUN = summary)
write.table(descrStatsByChromo,file="stats.txt",row.names = F,col.names = T,quote = F,sep='\t')

write("make the plot", stdout())
vPlot <- ggplot(svLengthData, aes(x=type, y=lengthLongestPath, fill=type)) + 
geom_violin() + 
scale_y_log10() + 
theme(plot.title = element_text(hjust = 0.5), text = element_text(size=20)) +
ggtitle("Structural variant size by type") + 
xlab("SV type") + 
ylab("log10 SV length (bp)") + 


write("export to a PNG file", stdout())
vPlot
dev.off()

