test.examples <- function()
{
#   checkEquals(6, factorial(3));
#   checkEqualsNumeric(6, factorial(3));
#   checkIdentical(6, factorial(3));
#   checkTrue(2 + 2 == 4, 'Arithmetic works');
#   checkException(log('a'), 'Unable to take the log() of a string');

  library(Spark)
  library(SparkR)
  pi = pi()
  
  checkEqualsNumeric(length(pi), 1, "Checking that there are 6 columns being returned. (Years, Critical, Bad, Fair, Good, Excellent)")
  checkTrue(pi>3, "Checking that the spark function returns 1.")
  checkTrue(pi<4, "Checking that the spark function returns 1.")
}

# test.deactivation <- function()
# {
#   DEACTIVATED('Deactivating this test function')
# }

