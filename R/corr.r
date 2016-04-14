library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages')

args <- commandArgs(TRUE)
list <- read.csv(args[1], header=TRUE, sep=",")
title <- args[2]
out <- args[3]


label = round(cor(list[,1], list[,2]), digits = 3)
pvalue = cor.test(list[,1], list[,2],method = "pearson")$p.value
# cor.test(list[,1], list[,2],method = "spearman")
# cor.test(list[,1], list[,2],method = "kendall")
pdf(paste0(out))
ggplot(data=list,aes(x=list[,1],y=list[,2])) + geom_point() + geom_smooth(colour = "red", method = 'lm') +
ggtitle(paste(title, ", r = ", label, ", pvalue = ",pvalue, sep="")) + 
xlab('Meta-Pipeline') + 
ylab('Tara')
dev.off()
# ratio  <- list[,1]/list[,2]
# h <- ggplot(list, aes(x=list[,1],y=list[,2])) + geom_histogram()

# ggsave(paste(out,tax,".pdf", sep=""),p)
# ggsave(paste(out,tax,"_hist.pdf", sep=""),h)