set.seed(67)
library(Rcpp)
library(RcppArmadillo)
sourceCpp("run_em.cpp")

runtime <- numeric(6) 
for (n_thread in c(1, 2, 4, 8, 16, 32)) {
    load(paste0("sim_set/sim_set", log2(n_thread), ".rda"))
    I <- nrow(sim$y)
    J <- ncol(sim$y)
    K <- 16
    p_init <- rgamma(K, 2, 2)
    p_init <- p_init / sum(p_init)
    q_init <- matrix(rbeta(K * J, 0.5, 0.5), K)

    print(n_thread)
    print(J)
    tstart <- proc.time()
    out <- run_em(sim$y, sim$bg.mean, sim$bg.sd, K, 1000, 0, n_thread, p_init, q_init,
                  rep(12, J), rep(1, J))
    elapsed <- proc.time() - tstart
    runtime[log2(n_thread)+1] <- elapsed[3]
}

save(runtime, file = "output/scaleup.rda")
