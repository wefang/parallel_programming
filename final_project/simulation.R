set.seed(37)

generate_data <- function(I, J, K) {
    q <- matrix(sample(c(0, 1), K * J, prob = c(0.8, 0.2), replace = T), nrow = K)

    bg.mean.vec <- runif(I, 0, 1)
    bg.sd.vec <- rgamma(I, 5, 20)
    bg.mean <- matrix(bg.mean.vec, I, J, byrow= F)
    bg.sd <- matrix(bg.sd.vec, I, J, byrow= F)

    theta1 <- runif(J, 8, 12)
    sigma1 <- rgamma(J, 10, 5)

    p <- rgamma(K, 2, 2)
    p <- p / sum(p)
    d <- sample(1:K, I, prob=p, replace=T)
    A <- matrix(0, I, J)
    for (i in 1:I){
        A[i,] <- q[d[i], ]
    }
    y<- matrix(0, I, J)
    for (i in 1:I){
        for (j in 1:J){
            y[i, j] <- A[i, j] * rnorm(1, theta1[j], sigma1[j]) + 
                (1 - A[i, j]) * rnorm(1, bg.mean[i, j], bg.sd[i, j])
        }
    }
    list(y = y, p = p, q = q, bg.mean = bg.mean, bg.sd = bg.sd, theta1 = theta1, sigma1 = sigma1)
}

for (i in 0:5){
    sim <- generate_data(256, 2^(7+i), 8)
    save(sim, file = paste0("sim_set/sim_set", i, ".rda"))
}
