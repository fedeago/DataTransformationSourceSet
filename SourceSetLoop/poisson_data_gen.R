library(XMRF)

W1 <- matrix(0, ncol = 5, nrow = 5)
rownames(W1) <- colnames(W1) <- c('A', 'B', 'C', 'D', 'E')
W1["A","B"] <- W1["B","A"] <- 1
W1["B","C"] <- W1["C","B"] <- 1
W1["C","D"] <- W1["D","C"] <- 1
W1["D","E"] <- W1["E","D"] <- 1
W1["C","E"] <- W1["E","C"] <- 1

W2 <- W1
W2['A', 'B'] <- W2['B', 'A'] <- 0

adj2A <-
  function(B,type="full"){
    # if(nrow(B)!=ncol(B)){
    #   print("not a symmetric matrix")
    #   return;
    # }
    A=diag(1,nrow=nrow(B),ncol=ncol(B))
    for(i in 1:(nrow(B)-1)){
      for( j in (i+1):ncol(B)){
        
        if(type=="full"){
          tmp=rep(0,nrow(B))
          tmp[c(i,j)]=1
          A=cbind(A,tmp)	
          
        }else if(B[i,j]==1){
          tmp=rep(0,nrow(B))
          tmp[c(i,j)]=1
          A=cbind(A,tmp)				
        }
      }
    }
    return(A)
  }


rmpois <-
  function(n,lambda.v){
    tmp=c();
    tmp =  do.call(rbind, parallel::mclapply(lambda.v,function(i) { rpois(n,i)}))
    return(tmp)
  }

XMRF.Sim <- function(B, n, p, model, graph.type){
  mydata <- list()
  #B <- W1 #simGraph(p=p, type=graph.type)
  mydata$B <- B
  
  if(model == "LPGM" || model == "SPGM" || model == "TPGM"){
    ## implement the speed.pois="fast" in mp.generator
    lambda = lambda_true #2
    lambda.c = lambda_noise #0.5
    
    A = adj2A(B,type=graph.type)
    sigma=lambda*B
    ltri.sigma=sigma[lower.tri(sigma)]
    nonzero.sigma = ltri.sigma[which(ltri.sigma !=0 )]
    Y.lambda = c(rep(lambda,nrow(sigma)), nonzero.sigma)
    
    Y = rmpois(n,Y.lambda)
    X =A%*%Y
    # add the labmda.c to all the nodes. 
    X = X + rmpois(ncol(X), rep(lambda.c,nrow(X)))
    mydata$X=X
    mydata$A=A
    mydata$sigma=sigma
  }
  return(mydata)
}
