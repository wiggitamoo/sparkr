library('RUnit')
library('Spark')
test.suite <- defineTestSuite("SparkTestSuite",
                              dirs = file.path("tests"),
                              testFileRegexp = '^\\d+\\.R')

test.result <- runTestSuite(test.suite)

printTextProtocol(test.result)
