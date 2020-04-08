looPACore<-function(otutable,tree,taxonomy,distanceMetric,outcome){
if(!is.rooted(tree)){
  tree$root.edge<-0
}
  if(distanceMetric=="Bray Curtis"){
    pairwiseDist<-vegdist(t(otutable), method="bray")
  }else if (distanceMetric=="Unweighted UniFrac"){
    temp<-GUniFrac(t(otutable),tree)
    pairwiseDist<-as.dist(temp$unifracs[,,"d_UW"])   
  }else if (distanceMetric=="Weighted UniFrac"){
    temp<-GUniFrac(t(otutable),tree)
    pairwiseDist<-as.dist(temp$unifracs[,,"d_1"])  
  }else{
    stop("The distance metric you provide is not supported by looPA right now!")
  }
  
  origResult<-adonis(pairwiseDist~outcome,permutations = 9999)$aov.tab
  origp<-origResult[1,6]

  uniquetax<-unique(as.vector(as.matrix(taxonomy)))
  prec<-rep(0,length(uniquetax))

  otutable2<-otutable
  
  for(i in 1:length(uniquetax)){
    temp<-rownames(otutable)[apply(taxonomy, 1, function(x) sum(any(x %in% uniquetax[i])))>0] 
    otutable2[temp,]<-0
    
    if(distanceMetric=="Bray Curtis"){
      pairwiseDist<-vegdist(t(otutable2), method="bray")
    }else if (distanceMetric=="Unweighted UniFrac"){
      temp<-GUniFrac(t(otutable2),tree)
      pairwiseDist<-as.dist(temp$unifracs[,,"d_UW"])   
    }else if (distanceMetric=="Weighted UniFrac"){
      temp<-GUniFrac(t(otutable2),tree)
      pairwiseDist<-as.dist(temp$unifracs[,,"d_1"])  
    }else{
      stop("The distance metric you provide is not supported by looPA right now!")
    }
    looPAResult<-adonis(pairwiseDist~outcome,permutations = 9999)$aov.tab
    prec[i]<-looPAResult[1,6]
    otutable2<-otutable
  }
  looPAnames<-c("original",uniquetax)
  prec<-c(origp,prec)
  names(prec)<-looPAnames
  prec
}