library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages')


args <- commandArgs(TRUE)

list <- read.csv(args[1], header=TRUE, sep=",")

ggplot(data = data.frame(list), las = 2, aes(x = pfam, y = prozant)) + geom_boxplot() +  theme(axis.text.x=element_blank())# + scale_y_log10(labels = comma) 
