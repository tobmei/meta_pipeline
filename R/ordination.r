library(permute, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(vegan, lib.loc = '/work/gi/software/R-3.0.2/packages')
# library(corrplot, lib.loc = '/home/stud2012/tmeier/Downloads')
library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages')


args <- commandArgs(TRUE)

mat <- read.csv(args[1], header=TRUE, sep=",")
env <- read.csv(args[2], header=TRUE, sep="\t")
out <- args[3]
ctgs <- args[4]


pdf(paste0(out,'pcoa.pdf'))
# PCOA
d = vegdist(mat, method="bray")
write.csv(as.matrix(d),file="ddistmat.csv")
pcoa<-cmdscale(d, eig=TRUE, add=TRUE)
eig <- eigenvals(pcoa)
eigs <- eig / sum(eig)
v1 <- round(eigs[1]*100,digits=2)
v2 <- round(eigs[2]*100,digits=2)
x <- pcoa$points[,1]
y <- pcoa$points[,2]
with(env, levels(project))
# colvec <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99')
colvec <- rainbow(length(levels(env$project)))
with(env, colvec[project])
plot(x,y, type='n', xlab=paste("MDS1 (",v1,"%)"), ylab=paste("MDS2 (",v2,"%)"), main='PCoA')
with(env, points(x,y, col = colvec[env$project], pch = 15, bg = colvec[env$project]))
with(env, legend("topright", legend = levels(env$project), bty = "n", col = colvec, pch = 15, pt.bg = colvec))
dev.off()

pdf(paste0(out,'nmds.pdf'))
#NMDS
nmds <- metaMDS(mat)
gof <- goodness(nmds)
with(env, levels(project))
# colvec <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99')
colvec <- rainbow(length(levels(env$project)))
with(env, colvec[project])
plot(nmds, type='n', main=paste0('NMDS, stress = ', round(mean(gof),digits=2)))
with(env, points(nmds, display = "species", col = 'black', pch = '.'))
with(env, points(nmds, display = "sites", col = colvec[project], pch = 15, bg = colvec[project]))
with(env, legend("topleft", legend = levels(project), bty = "n", col = colvec, pch = 15, pt.bg = colvec))
# 
stressplot(nmds, main='stress plot')
dev.off()


