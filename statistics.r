library(permute, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(vegan, lib.loc = '/work/gi/software/R-3.0.2/packages')
# library(corrplot, lib.loc = '/home/stud2012/tmeier/Downloads')
library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(scales, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(reshape2, lib.loc = '/work/gi/software/R-3.0.2/packages')
require(gridExtra, lib.loc = '/work/gi/software/R-3.0.2/packages')

args <- commandArgs(TRUE)

mat <- read.csv(args[1], header=TRUE, sep=",")
# mat2 <- read.csv(args[2], header=TRUE, sep=",")
env <- read.csv(args[2], header=TRUE, sep="\t")
# 
# geo_mat <- read.csv(args[2], header=FALSE, sep=",")
# list <- read.csv(args[1], header=TRUE, sep=",")
# list2 <- read.csv(args[2], header=TRUE, sep=",")
# list3 <- read.csv(args[3], header=FALSE, sep=",")
# 
# pdf('neu/bla.pdf')
# 
# corr_eqn <- function(x,y, digits = 2) {
#   corr_coef <- round(cor(x, y), digits = digits)
#   paste("r =", corr_coef)
# }
# label = corr_eqn(list$uproc, list$tara)
# ggplot(data=list,aes(x=list$uproc,y=list$tara)) + geom_point() + geom_smooth(colour = "red", method = 'lm') +
# # geom_text(x = 0.25, y = 0.75, label = corr_eqn(list$uproc, list$tara), parse = TRUE) + 
# ggtitle(paste("meta_pipeline vs tara - order frequencies,",label))
# 
# dev.off()
# ratio  <- list$uproc/list$tara
# hist(ratio,xlim=c(0,5), breaks=c(-Inf,seq(0,5,0.1),Inf),freq=T, ylim=c(0,200))

# y <- list[order(-list$V8),]
# head(y)
# plot(as.vector(list$V3),as.vector(list$V8),main="sisters peak", xlab="sequence length", ylab="similarity score")
# plot(as.vector(list2$V3),as.vector(list2$V8),main="xie 4141-3", xlab="sequence length", ylab="similarity score")
# plot(as.vector(list3$V3),as.vector(list3$V8),main="axial seamount anemone", xlab="sequence length", ylab="similarity score")

# boxplot(data.frame(list))
# boxplot(data.frame(list2))

# library(ggplot2)
# ggplot(data = data.frame(list), las = 2, aes(x = pfam, y = prozant)) + geom_boxplot() +  theme(axis.text.x=element_blank())# + scale_y_log10(labels = comma)
  
# list.agg <- aggregate(list$frequency,by=list(phylum = list$phylum, superkingdom = list$superkingdom), mean) 
# list.agg.ord <- list.agg[order(-list.agg$x),]
# plot <- ggplot(list.agg.ord[1:8,], aes(x=factor(phylum, levels=unique(phylum)), y=x, fill=superkingdom)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("phylum") + ylab("frequency") 
# 
# list.agg <- aggregate(list$frequency,by=list(phylum = list$phylum, superkingdom = list$superkingdom),mean) 
# list.agg.ord <- list.agg[order(-list.agg$x),]
# plot <- ggplot(list.agg.ord[1:10,], aes(x=factor(phylum, levels=unique(phylum)), y=x, fill=superkingdom)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("phylum") + ylab("frequency") 
# 
# list.agg <- aggregate(list$frequency,by=list(class = list$class, phylum = list$phylum), sum) 
# list.agg.ord <- list.agg[order(-list.agg$x),]
# plot <- ggplot(list.agg.ord[1:8,], aes(x=factor(class, levels=unique(class)), y=x, fill=phylum)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("class") + ylab("frequency") 

# list.agg <- aggregate(list$frequency,by=list(order = list$order, class = list$class), sum) 
# list.agg.ord <- list.agg[order(-list.agg$x),]
# plot <- ggplot(list.agg.ord[1:10,], aes(x=factor(order, levels=unique(order)), y=x, fill=class)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("order") + ylab("frequency") + ggtitle("supercooler plot")
# 
# list.agg <- aggregate(list$frequency,by=list(family = list$family, order = list$order), sum) 
# list.agg.ord <- list.agg[order(-list.agg$x),]
# plot <- ggplot(list.agg.ord[1:10,], aes(x=factor(family, levels=unique(family)), y=x, fill=order)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("family") + ylab("frequency") + ggtitle("supercooler plot")
# 
# list.agg <- aggregate(list$frequency,by=list(genus = list$genus, order = list$family), sum) 
# list.agg.ord <- list.agg[order(-list.agg$x),]
# plot <- ggplot(list.agg.ord[1:10,], aes(x=factor(genus, levels=unique(genus)), y=x, fill=family)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("genus") + ylab("frequency") + ggtitle("supercooler plot")
# 
# list.agg <- aggregate(list$frequency,by=list(species = list$species, genus = list$genus), sum) 
# list.agg.ord <- list.agg[order(-list.agg$x),]
# plot <- ggplot(list.agg.ord[1:10,], aes(x=factor(species, levels=unique(species)), y=x, fill=genus)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("species") + ylab("frequency") + ggtitle("supercooler plot")


# data_long <- melt(list, id.vars=c("vent"))
# # data_long
# # list.agg <- aggregate(list$frequency,by=list(species = list$species, genus = list$genus), sum) 
# data_long_ord <- data_long[order(data_long$variable,-data_long$value),]
# head(data_long_ord)
# plot <- ggplot(data_long_ord, aes(x=factor(vent, levels=unique(vent)), y=value, fill=variable)) + geom_bar(stat='identity') 
# plot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("Projekt") + ylab("% aller klassifizierten Sequenzen") + ggtitle("Transposase-Aktivitaet")


# list.ord <- list[order(-list$count),]
# head(list.ord)
# plot <- ggplot(list.ord[1:10,], aes(x=factor(pfam, levels=unique(pfam)), y=count)) + geom_bar(stat='identity') 
# plot + xlab("PFAM") + ylab("Anzahl") + scale_y_continuous(labels = comma) + coord_flip()

# head(list)
# plot <- ggplot(list, aes(x=pfam, y=count, fill=tool)) + geom_bar(stat='identity', position='dodge') 
# plot + xlab("PFAM") + ylab("Anzahl") + scale_y_continuous(labels = comma) + coord_flip()

# list.ord <- list[order(-list$V2),]
# plot1 <- ggplot(list.ord[1:10,], aes(x=factor(V1, levels=unique(V1)), y=V2)) + geom_bar(stat='identity') + ggtitle("diamond") + xlab("PFAM") + ylab("count") + scale_y_continuous(labels = comma) + coord_flip()
# list2.ord <- list2[order(-list2$V2),]
# plot2 <- ggplot(list2.ord[1:10,], aes(x=factor(V1, levels=unique(V1)), y=V2)) + geom_bar(stat='identity') + ggtitle("uproc") + xlab("PFAM") + ylab("count") + scale_y_continuous(labels = comma) + coord_flip()
# 
# grid.arrange(plot1, plot2, ncol=2, top="anantharaman - abe")

# 
# attach(list)
# blo <- tapply(frequency, taxon, sum)
# blu <- as.matrix(blo)
# ble <- blu[order(blu[,1], decreasing=TRUE), ]
# bli <- as.table(ble)
# op <- par(mar = c(5,10,2,2) + 0.1)
# barplot(bli[1:10], las=2, cex.names=.75, horiz=TRUE)
# title(main=paste('Frequency for', 'abe_1: bacteria - phylum' , sep=' '))
# par(op)
# 
# list <- read.table(args[3], header=TRUE, sep=",")
# attach(list)cumsu
# blo <- tapply(frequency, taxon, mean)
# blu <- as.matrix(blo)
# ble <- blu[order(blu[,1], decreasing=TRUE), ]
# bli <- as.table(ble)
# op <- par(mar = c(5,10,2,2) + 0.1)
# barplot(bli[1:10], las=2, cex.names=.75, horiz=TRUE)
# title(main=paste('Frequency for', 'abe_1: bacteria - genus', sep=' '))
# par(op)





# stress plot
# plot(rep(1,10),replicate(10,metaMDS(mat,autotransform=T,k=1)$stress),xlim=c(1,5),ylim=c(0,1),xlab="# of Dimensions",ylab="Stress",main='NMDS stress plot')
# for (i in 1:5) {
#   points(rep(i+1,10),replicate(10,metaMDS(mat,autotransform=T,k=i+1)$stress))
# }


# d
# as.vector(d)
# av <- as.vector(as.matrix(geo_mat))
# av <- as.vector(geo_mat)
# av <- c(t(geo_mat))
# av <- av[!is.na(av)]
# av
# geo_mat
# as.matrix(geo_mat)
# d

# a = cor.test(as.vector(as.matrix(geo_mat)),as.vector(as.matrix(d)), method="kendall")
# b = cor.test(as.vector(as.matrix(geo_mat)),as.vector(as.matrix(d)), method="pearson")
# c = cor.test(as.vector(as.matrix(geo_mat)),as.vector(as.matrix(d)), method="spearman")
# a
# b
# c
# dim(geo_mat)
# as.matrix(d)
# a=cor(av,as.vector(d))
# # a=cor(as.matrix(geo_mat),as.matrix(d))
# plot(a)


#correlation matrix

# a = cor(mat, use="pairwise.complete.obs")
# 
# # a = cor.test(mat)
# cor.test.p <- function(x){
#     FUN <- function(x, y) cor.test(x, y)[["p.value"]]
#     z <- outer(
#       colnames(x), 
#       colnames(x), 
#       Vectorize(function(i,j) FUN(x[,i], x[,j]))
#     )
#     dimnames(z) <- list(colnames(x), colnames(x))
#     z
# }
# cor.test.p(a)
# p.adj = as.matrix(p.adjust(as.vector(cor.test.p(a)), method = 'BH'))
# dim(p.adj) <- c(13,13)
# p.adj
# corrplot(a, p.mat = p.adj, method='circle', type='lower',tl.srt=45, tl.col='black', tl.cex=0.6)

#PCOA
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
colvec <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99')
with(env, colvec[project])
plot(x,y, type='n', xlab=paste("MDS1 (",v1,"%)"), ylab=paste("MDS2 (",v2,"%)"), main='PCoA functional profile')
with(env, points(x,y, col = colvec[env$project], pch = 15, bg = colvec[env$project]))
with(env, legend("topright", legend = levels(env$project), bty = "n", col = colvec, pch = 15, pt.bg = colvec))
# # 
# # 
# nmds <- metaMDS(mat)
# with(env, levels(project))
# colvec <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99')
# with(env, colvec[project])
# plot(nmds, type='n', main='NMDS functional profile')
# with(env, points(nmds, display = "species", col = 'black', pch = '.'))
# with(env, points(nmds, display = "sites", col = colvec[project], pch = 15, bg = colvec[project]))
# with(env, legend("topleft", legend = levels(project), bty = "n", col = colvec, pch = 15, pt.bg = colvec))
# # 
# stressplot(nmds, main='stress plot')

# d = vegdist(mat, method="bray")
# d2 = vegdist(mat2, method="bray")
# nmds <- metaMDS(mat)
# nmds2 <- metaMDS(mat2)
# pr <- procrustes(d,d2)
# plot(pr)


# ord<-capscale(mat~1,distance="bray")
# with(env, levels(project))display = "sites"
# colvec <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a','#ffff99')
# with(env, colvec[project])

# plot(ord, type='n')
# with(env, points(ord, display = "sites", col = colvec[env$project], pch = 15, bg = colvec[env$project]))
# with(env, legend("topleft", legend = levels(env$project), bty = "n", col = colvec, pch = 15, pt.bg = colvec))
# 
# 
# anosim(d, env$project)
# anosim(d, env$ocean)
# anosim(d, env$platform)
# anosim(d, env$site)
# anosim(d, env$region)
# anosim(d, env$worldmap)
# anosim(d, env$depth)
# anosim(d, env$collection_year)

# plot(ord)
# # biplot(ord, type="n")
# text(ord, labels = c(1:nrow(mat)))
# title(main=paste('PCoA for Bray-Curtis dissimilarities', sep=' '))
# legend("bottomright", title="Vents", row.names(mat), cex=.45, horiz=F)



# ord <- rda(mat)
# biplot(ord, type=c('text', 'points'))
# title(main=paste('PCA for', args[1], sep=' '))
# legend("topright", title="Vents", row.names(mat), col=rainbow,, cex=.4, horiz=F)


#clustering
# d = (1 - vegdist(mat, method="bray")) * 100
# h = hclust(d)#, method="average")
# plot(h, labels = c(1:nrow(mat)))
# plot(h, sub = "", xlab="", axes = FALSE, hang = -1, labels = c(1:nrow(mat)), main=paste('Clustering for', args[1], 'using Bray-Curtis dissimilarity', sep=' '))
# lines(x = c(0,0), y = c(0,100), type = "n") # force extension of y axis
# axis(side = 2, at = seq(0,100,10), labels = seq(100,0,-10))
# legend("topright", title="Vents", row.names(mat), col=rainbow,, cex=.4, horiz=F)
  
