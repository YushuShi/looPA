looPA<-function(otutable,taxonomy, sampleInfo, outcomeVar, numRep=200, useMoreCores=TRUE, tree=NULL,distanceMetric="Bray Curtis"){
  if((sum(rownames(otutable)%in%rownames(taxonomy))!=
     nrow(otutable))|(sum(rownames(taxonomy)%in%rownames(otutable))!=
    nrow(taxonomy))){
    stop("The OTU table and taxonomy table do not match!")
  }
  
  if((sum(rownames(otutable) %in% tree$tip.label)!=
      nrow(otutable))|(sum(tree$tip.label %in%rownames(otutable))!=
                                 length(tree$tip.label))){
    stop("The OTU table and the phylogenetic tree do not match!")
  }
  
  if((sum(colnames(otutable) %in% rownames(sampleInfo))!=
      ncol(otutable))|(sum(rownames(sampleInfo) %in%colnames(otutable))!=
                       nrow(sampleInfo))){
    stop("The OTU table and the sample information do not match!")
  }
  
  taxonomy<-taxonomy[rownames(otutable),]
  outcome<-sampleInfo[,outcomeVar]
  names(outcome)<-rownames(sampleInfo)
  outcome<-outcome[colnames(otutable)]

if(useMoreCores==TRUE){
no_cores <- detectCores() - 1  
if(.Platform$OS.type=="windows"){
  cl <- makeCluster(no_cores)  
}else{
  cl <- makeCluster(no_cores, type="FORK")  
}
}else if(is.integer(useMoreCores)){
  no_cores <-useMoreCores
  if(.Platform$OS.type=="windows"){
    cl <- makeCluster(no_cores)  
  }else{
    cl <- makeCluster(no_cores, type="FORK")  
  }
}else{
  no_cores <- 2L
  if(.Platform$OS.type=="windows"){
    cl <- makeCluster(no_cores)  
  }else{
    cl <- makeCluster(no_cores, type="FORK")  
  }
}
print(paste("Number of Cores Used"),cl)
registerDoParallel(cl) 

looPAmat<- foreach(icount(numRep), .combine=rbind) %dopar% {
  looPACore(otutable,tree,taxonomy,distanceMetric,outcome)
}
looPAmedian<-apply(looPAmat,2,median)
looPAupper<-apply(looPAmat,2,quantile,0.975)
looPAlower<-apply(looPAmat,2,quantile,0.025)

names(looPAupper)<-colnames(looPAmat)
names(looPAlower)<-colnames(looPAmat)
names(looPAmedian)<-colnames(looPAmat)

looPAintnames<-c(colnames(looPAmat)[looPAlower>looPAupper["original"]],"original")

looPAmedian<-looPAmedian[looPAintnames]
looPAmedian<-looPAmedian[order(looPAmedian)]
looPAupper<-looPAupper[names(looPAmedian)]
looPAlower<-looPAlower[names(looPAmedian)]


looPAresult<- data.frame(
  Taxa=factor(names(looPAmedian),levels=names(looPAmedian)),
  pvalue=looPAmedian,
  upper=looPAupper,
  lower=looPAlower)

looPAplot<-ggplot(looPAresult) +
  geom_bar(aes_string(x='Taxa', y='pvalue'), stat="identity", fill="skyblue", alpha=0.7) +
  geom_errorbar( aes_string(x='Taxa', ymin='lower', ymax='upper'), width=0.2, colour="orange", alpha=1, size=1)+coord_flip()
plot(looPAplot)
result<-list(looPAresult=looPAresult,looPAplot=looPAplot)
result
}