library(permute, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(vegan, lib.loc = '/work/gi/software/R-3.0.2/packages')

args <- commandArgs(TRUE)

mat <- read.csv(args[1], header=TRUE, sep=",")
env <- read.csv(args[2], header=TRUE, sep="\t")
ctgs <- args[3]


d = vegdist(mat, method="bray")
a <- anosim(d, env[,paste0(ctgs)])
ctgs
a$statistic
a$signif

