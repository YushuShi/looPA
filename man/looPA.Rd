\name{looPA}
\alias{looPA}
\docType{package}
\title{
Microbiome feature identification using leave-one-out with Permanova assessment
}
\description{
looPA is a permutation based method, which can account for phylogenetic relatedness between taxonomic features and identify important features for further investigation.}
\usage{
looPA(otutable,taxonomy, sampleInfo, outcomeVar, numRep=200,useMoreCores=TRUE,
tree=NULL,distanceMetric="Bray Curtis")
}

\arguments{
  \item{otutable}{OTU table. Rows correspond to OTUs while columns correspond to samples. Row names (OTU names) and column names(sample names) must be provided.}
  \item{taxonomy}{Taxonomy table. Rows correspond to OTUs while columns correspond to the taxonomic levels. Row names (OTU names) must match the row names of the OTU table.}
  \item{sampleInfo}{Patient information. Rows correspond to samples while columns correspond to covariates. Row names (sample names) must match the column names of the OTU table.}
  \item{outcomeVar}{The outcome of interest. For now we only accept single covariate.}
  \item{numRep}{Number of repeated PERMANOVA test for each feature. Default is 200.}
  \item{useMoreCores}{Shall we use more cores of the computer for this job? If you select TRUE (recommended), the number of cores used will be the number of cores of the computer -1. If you give an integer value, looPA will use it as the number of cores you want to use. }
  \item{tree}{The phylogenetic information correspond to OTU table.}
  \item{distanceMetric}{The distance metric used in PERMANOVA test. We offer three choices, "Bray Curtis" (the default), "Unweighted UniFrac"(requires tree information), and "Weighted UniFrac"(requires tree information).}
}

\value{
  \item{looPAresult}{A dataframe with the names of the selected taxa and their medians and confidence intervals over repeated PERMANOVA tests.}
\item{looPAplot}{A plot showing the selected features.}}

\examples{
library(vegan)
library(GUniFrac)
library(ape)
library(ggplot2)
library(foreach)
library(parallel)
library(iterators)
library(doParallel)
library(looPA)
options(stringsAsFactors = FALSE)

outcomeVar<-"Response"

looPAResult<-looPA(otutable,taxonomy, sampleInfo, outcomeVar,
tree=tree,distanceMetric="Weighted UniFrac")
}

