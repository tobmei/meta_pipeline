library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(reshape2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages')

args <- commandArgs(TRUE)


stamp_bar <- read.csv(args[1], header=TRUE, sep="\t")
stamp_heat <- read.csv(args[2], header=TRUE, sep="\t")
stamp_orig <- read.csv(args[3], header=TRUE, sep="\t")
effect <- args[4]
pvalue <- args[5]
feature <- args[6]
out <- args[7]

pdf(paste0(out))

#barplot
ggplot(stamp_bar, aes(x=factor(vent,levels=unique(vent)), y=value, fill=Gruppe)) + geom_bar(stat='identity')  + 
ggtitle(paste(feature,",","effect size =",effect,",", "p-value =",pvalue)) + 
ylab("Frequenz") +
xlab("") + 
# theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
coord_flip()

#boxplot
ggplot(data = stamp_bar, las = 2, aes(x = Gruppe, y = value, fill=Gruppe)) + geom_boxplot() +  theme(axis.text.x=element_blank()) + ggtitle(paste(feature,",","effect size =",effect,",", "p-value =",pvalue)) + ylab("Frequenz") 

#histograms
hist(stamp_orig[,3],breaks=20,freq=T, main='Verteilung der p-values', xlab="", ylab="Frequenz")
hist(stamp_orig[,4],breaks=20,freq=T, main='Verteilung der Effect sizes', xlab="", ylab="Frequenz")

#heatmap
ggplot(data = stamp_heat, las = 2, aes(x = vent, y = feature, fill=Frequenz)) + geom_tile() + 
theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 6),axis.text.y = element_text(size = 6)) +
ylab("") +
xlab("") 

dev.off()






#stamp two samples

# stamp.ord <- stamp[order(-stamp[,6]),]
# c(head(stamp.ord[,1]))
# x1 <- head(stamp.ord[,6],30)
# x2 <- head(stamp.ord[,7],30)
# x1
# x2
# height <- rbind(x1,x2)
# label=c(colnames(stamp)[2],colnames(stamp)[3])
# label
# 
# barplot(height, beside=TRUE, names.arg=head(stamp.ord[,1],30), las=2, col=rainbow(2), horiz=T)
# legend("topright", fill=rainbow(2), legend=label)
# 
# # hist(stamp[,9],xlim=c(0,0.01), breaks=c(-Inf,seq(0,0.01,1e-5),Inf),freq=F)
# # hist(stamp[,9],xlim=c(0,0.05), breaks=seq(0,0.05,1e-5),freq=F)
# hist(stamp[,9],breaks=20,freq=T, main='Verteilung der p-values')
# hist(stamp[,11],breaks=20,freq=T, main='Verteilung der Effect sizes')
# 
# 
# corr_eqn <- function(x,y, digits = 2) {
#   corr_coef <- round(cor(x, y), digits = digits)
#   paste("r =", corr_coef)
# }
# r = corr_eqn(stamp[,6], stamp[,7])
# ggplot(data=stamp,aes(x=stamp[,6],y=stamp[,7])) + geom_point() + geom_smooth(colour = "red", method = 'lm') +
# # geom_text(x = 0.25, y = 0.75, label = corr_eqn(stamp[,6], stamp[,6]), parse = TRUE) 
# ggtitle(paste(r)) + xlab(paste(label[1],"(%)")) + ylab(paste(label[2],"(%)"))

