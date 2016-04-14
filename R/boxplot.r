library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages')


args <- commandArgs(TRUE)

list <- read.csv(args[1], header=TRUE, sep=",")
label <- args[2]
out <- args[3]

pdf(paste0(out))

ggplot(data = data.frame(list), aes(x = list[,1], y = list[,2], fill = tax)) + geom_boxplot() +  
theme(axis.text.x=element_blank()) + xlab(paste0(label)) + ylab("Frequenz")

dev.off()