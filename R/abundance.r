suppressPackageStartupMessages(library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages'))
suppressPackageStartupMessages(library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages'))
suppressPackageStartupMessages(library(scales, lib.loc = '/work/gi/software/R-3.0.2/packages'))

args <- commandArgs(TRUE)
list <- read.csv(args[1], header=TRUE, sep="\t", comment.char="")
list2 <- read.csv(args[2], header=TRUE, sep=",", comment.char="")
out1 <- args[3]
out2 <- args[4]

pdf(paste0(out1,'_taxonomy_levels.pdf'))
plot <- ggplot(list, aes(x=factor(superkingdom, levels=unique(superkingdom)), y=list[,1])) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Superkingdom") + ylab("Frequenz")  

list.agg <- aggregate(list[,1],by=list(phylum = list$phylum, superkingdom = list$superkingdom), sum)
list.agg.ord <- list.agg[order(-list.agg$x),]
plot <- ggplot(list.agg.ord[1:10,], aes(x=factor(phylum, levels=unique(phylum)), y=x, fill=superkingdom)) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Phylum") + ylab("Frequenz")  

list.agg <- aggregate(list[,1],by=list(class = list$class, phylum = list$phylum), sum) 
list.agg.ord <- list.agg[order(-list.agg$x),]
plot <- ggplot(list.agg.ord[1:8,], aes(x=factor(class, levels=unique(class)), y=x, fill=phylum)) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Class") + ylab("Frequenz") 

list.agg <- aggregate(list[,1],by=list(order = list$order, class = list$class), sum) 
list.agg.ord <- list.agg[order(-list.agg$x),]
plot <- ggplot(list.agg.ord[1:10,], aes(x=factor(order, levels=unique(order)), y=x, fill=class)) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Order") + ylab("Frequenz") 

list.agg <- aggregate(list[,1],by=list(family = list$family, order = list$order), sum) 
list.agg.ord <- list.agg[order(-list.agg$x),]
plot <- ggplot(list.agg.ord[0:10,], aes(x=factor(family, levels=unique(family)), y=x, fill=order)) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Family") + ylab("Frequenz") 

list.agg <- aggregate(list[,1],by=list(genus = list$genus, family = list$family), sum) 
list.agg.ord <- list.agg[order(-list.agg$x),]
plot <- ggplot(list.agg.ord[0:10,], aes(x=factor(genus, levels=unique(genus)), y=x, fill=family)) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Genus") + ylab("Frequenz") 

list.agg <- aggregate(list[,1],by=list(species = list$species, genus = list$genus), sum) 
list.agg.ord <- list.agg[order(-list.agg$x),]
plot <- ggplot(list.agg.ord[0:10,], aes(x=factor(species, levels=unique(species)), y=x, fill=genus)) + geom_bar(stat='identity') 
plot + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Species") + ylab("Frequenz") 
dev.off()


pdf(paste0(out2,'_pfams.pdf'))
list2.ord <- list2[order(-list2[,2]),]
plot <- ggplot(list2.ord[1:10,], aes(x=factor(list2.ord[1:10,][,1], levels=unique(list2.ord[1:10,][,1])), y=list2.ord[1:10,][,2])) + geom_bar(stat='identity') 
plot + xlab("PFAM") + ylab("Anzahl") + scale_y_continuous(labels = comma) + coord_flip()
dev.off()