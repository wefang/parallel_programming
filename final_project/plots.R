load("output/speedup.rda")
speedup <- runtime[1] / runtime
plot(x = c(1, 2, 4, 8, 16, 32), y = speedup, ylab = "Speedup", xlab = "Number of Threads")
lines(x = c(1, 2, 4, 8, 16, 32), y = speedup)

load("output/scaleup.rda")
scaleup <- runtime[1] / runtime
plot(x = log2(c(1, 2, 4, 8, 16, 32)), y = scaleup, ylab = "Scaleup", xlab = "Number of Threads")
lines(x = c(1, 2, 4, 8, 16, 32), y = scaleup)

library(beanplot)
load("output/loop_time.rda")
beanplot(list("Loop 1" = time_mat[-1, 1], "Loop 2" = time_mat[-1, 2]))
