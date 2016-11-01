#run roxygen2::roxygenise() to create man for the package.

#The following lines are documentation at the package level (hence followed by NULL since no function)
#' Spark Package
#'
#'The Spark package is a tutorial for using Spark
#'
#' @docType package
#' @name Spark
NULL

# .onLoad <- function(...) 
# {
#   .packageStartupMessage("loaded")
#   cat("Space-Time Insight AI package version",packageDescription("AI")$Version,"loaded...\n");
#   source("R/Spark.R");
# }

#' Pi calculator
#'
#' This script reads the aggregated_measurements table, searches for the latest record for each device and calculates the Asset Health Index (AHI).
#' @param none no parameters are required
#' @return default value of 1
#' @note This is a spark function
#' @examples 
#' pi()
#' @export
pi = function(slices=2) {
  library(SparkR)
  
  if(missing(slices)) {
    slices = 2
    print("Missing slices.")
  }
  print(paste("Slices: ", slices))
  sc <- sparkR.init(master="local", "PiR")
  
  n <- 100000 * slices
  piFunc <- function(elem) {
    rands <- runif(n = 2, min = -1, max = 1)
    val <- ifelse((rands[1]^2 + rands[2]^2) < 1, 1.0, 0.0)
    val
  }
  piFuncVec <- function(elems) {
    message(length(elems))
    rands1 <- runif(n = length(elems), min = -1, max = 1)
    rands2 <- runif(n = length(elems), min = -1, max = 1)
    val <- ifelse((rands1^2 + rands2^2) < 1, 1.0, 0.0)
    sum(val)
  }
  rdd <- parallelize(sc, 1:n, slices)
  count <- reduce(lapplyPartition(rdd, piFuncVec), sum)
  cat("Pi is roughly", 4.0 * count / n, "\n")
  cat("Num elements in RDD ", count(rdd), "\n")
  
  sparkR.stop()
  return(4.0 * count / n)
}




#' k means function
#'
#' This script reads the aggregated_measurements table, searches for the latest record for each device and calculates the Asset Health Index (AHI).
#' @param none no parameters are required
#' @return default value of 1
#' @note This is a spark function
#' @examples 
#' kmeans(K, convergeDist, xxx)
#' @export
kmeans = function(K, convergeDist, xxx) {
  library(SparkR)
  
  # Logistic regression in Spark.
  # Note: unlike the example in Scala, a point here is represented as a vector of
  # doubles.
  
  parseVectors <-  function(lines) {
    lines <- strsplit(as.character(lines) , " ", fixed = TRUE)
    list(matrix(as.numeric(unlist(lines)), ncol = length(lines[[1]])))
  }
  
  dist.fun <- function(P, C) {
    apply(
      C,
      1, 
      function(x) { 
        colSums((t(P) - x)^2)
      }
    )
  }
  
  closestPoint <-  function(P, C) {
    max.col(-dist.fun(P, C))
  }
  # Main program
  
  sc <- sparkR.init(master="local", "RKMeans")
  K <- as.integer(K)
  convergeDist <- as.double(convergeDist)
  
  lines <- textFile(sc, xxx)
  points <- cache(lapplyPartition(lines, parseVectors))
  # kPoints <- take(points, K)
  kPoints <- do.call(rbind, takeSample(points, FALSE, K, 16189L))
  tempDist <- 1.0
  
  while (tempDist > convergeDist) {
    closest <- lapplyPartition(
      lapply(points,
             function(p) {
               cp <- closestPoint(p, kPoints); 
               mapply(list, unique(cp), split.data.frame(cbind(1, p), cp), SIMPLIFY=FALSE)
             }),
      function(x) {do.call(c, x)
      })
    
    pointStats <- reduceByKey(closest,
                              function(p1, p2) {
                                t(colSums(rbind(p1, p2)))
                              },
                              2L)
    
    newPoints <- do.call(
      rbind,
      collect(lapply(pointStats,
                     function(tup) {
                       point.sum <- tup[[2]][, -1]
                       point.count <- tup[[2]][, 1]
                       point.sum/point.count
                     })))
    
    D <- dist.fun(kPoints, newPoints)
    tempDist <- sum(D[cbind(1:3, max.col(-D))])
    kPoints <- newPoints
    cat("Finished iteration (delta = ", tempDist, ")\n")
  }
  
  cat("Final centers:\n")
  writeLines(unlist(lapply(kPoints, paste, collapse = " ")))
}