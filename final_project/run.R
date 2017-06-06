set.seed(67)
library(Rcpp)
library(RcppArmadillo)
sourceCpp("time_loop.cpp")

load("sim_set/sim_set1.rda")
I <- nrow(sim$y)
J <- ncol(sim$y)
K <- 16 
p_init <- rgamma(K, 2, 2)
p_init <- p_init / sum(p_init)
q_init <- matrix(rbeta(K * J, 0.5, 0.5), K)

time_mat <- matrix(,50, 2)
for (i in 1:50){
    out <- run_em(sim$y, sim$bg.mean, sim$bg.sd, K, 1, 0, 32, p_init, q_init,
                  rep(12, J), rep(1, J))
    time_mat[i, ] <- diff(out$time)/1e6
}
save(time_mat, file = "output/loop_time.rda")
