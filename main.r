library(stan)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

df <- read.csv('ligue1-20192020-results.csv')

stan_data <- list(N=nrow(df), nteams=length(unique(df$home.team)), y1=df$h.g., y2=df$h.a., hometeam=df$home.team, awayteam=df$away.team)
sm <- rstan::stan_model(file = "model_init.stan")

model <- rstan::sampling(sm, data = stan_data, control = list(adapt_delta = 0.99, max_treedepth = 15))