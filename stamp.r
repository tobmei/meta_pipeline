library(ggplot2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(reshape2, lib.loc = '/work/gi/software/R-3.0.2/packages')
library(labeling, lib.loc = '/work/gi/software/R-3.0.2/packages')

args <- commandArgs(TRUE)


stamp <- read.csv(args[1], header=TRUE, sep="\t")
# stamp2 <- read.csv(args[2], header=TRUE, sep="\t")
# label <-args[2]






# ggplot(stamp, aes(x=factor(vent,levels=unique(vent)), y=value, fill=group)) + geom_bar(stat='identity')  + ggtitle("Desulfomonile tiedjei, effect size = 0.527653140803") + ylab("Frequenz") 
# # 
# # 
# ggplot(data = stamp, las = 2, aes(x = group, y = value, fill=group)) + geom_boxplot() +  theme(axis.text.x=element_blank()) + ggtitle("Desulfomonile tiedjei, effect size = 0.527653140803") + ylab("Frequenz") 
# 
# hist(stamp2[,3],breaks=20,freq=T, main='Verteilung der p-values')
# 
# hist(stamp2[,4],breaks=20,freq=T, main='Verteilung der Effect sizes')
# head(stamp)
# stamp <-  melt(stamp)
# stamp.ord <- stamp[order(-stamp$value),]
# head(stamp.ord)
# ggplot(data = stamp.ord[200:230,], las = 2, aes(x = variable, y = Species, fill=value)) + geom_tile()








#
# #######laeuft#######
#

stamp.ord <- stamp[order(-stamp[,6]),]
c(head(stamp.ord[,1]))
x1 <- head(stamp.ord[,6],30)
x2 <- head(stamp.ord[,7],30)
x1
x2
height <- rbind(x1,x2)
label=c(colnames(stamp)[2],colnames(stamp)[3])
label

barplot(height, beside=TRUE, names.arg=head(stamp.ord[,1],30), las=2, col=rainbow(2), horiz=T)
legend("topright", fill=rainbow(2), legend=label)

# hist(stamp[,9],xlim=c(0,0.01), breaks=c(-Inf,seq(0,0.01,1e-5),Inf),freq=F)
# hist(stamp[,9],xlim=c(0,0.05), breaks=seq(0,0.05,1e-5),freq=F)
hist(stamp[,9],breaks=20,freq=T, main='Verteilung der p-values')
hist(stamp[,11],breaks=20,freq=T, main='Verteilung der Effect sizes')


corr_eqn <- function(x,y, digits = 2) {
  corr_coef <- round(cor(x, y), digits = digits)
  paste("r =", corr_coef)
}
r = corr_eqn(stamp[,6], stamp[,7])
ggplot(data=stamp,aes(x=stamp[,6],y=stamp[,7])) + geom_point() + geom_smooth(colour = "red", method = 'lm') +
# geom_text(x = 0.25, y = 0.75, label = corr_eqn(stamp[,6], stamp[,6]), parse = TRUE) 
ggtitle(paste(r)) + xlab(paste(label[1],"(%)")) + ylab(paste(label[2],"(%)"))

