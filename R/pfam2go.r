suppressPackageStartupMessages(library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages'))
suppressPackageStartupMessages(library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages')) 

args <- commandArgs(TRUE)
list <- read.csv(args[1], header=TRUE, sep=",")
out <- args[2]
go <- args[3]

pdf(paste0(out))
plot <- ggplot(list, aes(x=pfam, y=perc, fill = pfam)) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_blank()) + ylab("% aller klassifizierten Sequenzen") + ggtitle(paste0("Pfam-Mapping zu ",go))
dev.off()