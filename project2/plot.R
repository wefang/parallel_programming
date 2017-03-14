library(readr)
library(dplyr)
library(ggplot2)

serial <- read_csv("serial.txt", skip = 1, n_max = 480, col_names = F)
parallel <- read_csv("parallel.txt", skip = 1, n_max = 200, col_names = F)

serial_ave <- serial %>% group_by(X2, X4) %>% summarise(Time = mean(X3), 
                                                        lower = t.test(X3)$conf.int[1],
                                                        upper = t.test(X3)$conf.int[2])
ggplot(aes(x = X4, y = Time, color = X2), data = serial_ave) +
#      geom_ribbon(aes(x = X4, ymin = lower, ymax = upper, col = X2), alpha = 0.3) +
      geom_point() +geom_line() + xlab("Filter Size") + ylab("Time (sec)") + 
      scale_color_discrete(name = "Type")

serial_ave <- serial_ave %>% mutate(nTime = Time / X4)
ggplot(aes(x = log2(X4), y = nTime, color = X2), data = serial_ave) +
      geom_point() +geom_line() + xlab("log2 of Filter Size") + ylab("Average Run Time / Filter Size (sec)") + 
      scale_color_discrete(name = "Type")




parallel_ave <- parallel %>% group_by(X1, X3) %>% summarise(Time = mean(X4), 
                                                            lower = t.test(X3)$conf.int[1],
                                                            upper = t.test(X3)$conf.int[2])
parallel_ave$Speedup = NA
data_first <- parallel_ave$X3 == "Data First"
parallel_ave$Speedup[data_first] <- 
      parallel_ave$Time[data_first][1]/parallel_ave$Time[data_first]

filter_first <- parallel_ave$X3 == "Filter First"
parallel_ave$Speedup[filter_first] <- 
      parallel_ave$Time[filter_first][1]/parallel_ave$Time[filter_first]
ggplot(aes(x = X1, y = Speedup, color = X3), data = parallel_ave) + geom_point() + xlab("Filter Size")
