library(rstan)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# DATA
df_res <- read.csv('ligue1-20192020-results.csv')
df_next <- read.csv('ligue1-20192020-cancelled-games.csv')
df_teams <- read.csv('ligue1-20192020-teams.csv')

stan_data <- list(N=nrow(df_res), nteams=length(unique(df_res$home.team)), y1=df_res$h.g., y2=df_res$h.a., hometeam=df_res$home.team, awayteam=df_res$away.team,
                  next_N=nrow(df_next), next_hometeam=df_next$home.team, next_awayteam=df_next$away.team)

# HIERARCHICAL MODEL
sm <- rstan::stan_model(file = "model_init.stan")
model <- rstan::sampling(sm, data = stan_data, iter=8000, warmup=2000,
                         control = list(adapt_delta = 0.99, max_treedepth = 15))
model
saveRDS(model, "hierarchical_model.rds")

# SEPARATE MODEL
sm <- rstan::stan_model(file = "separate_model.stan")
model <- rstan::sampling(sm, data = stan_data, chains=4, iter=20000, warmup=4000,
                         control = list(adapt_delta = 0.99, max_treedepth = 15))
model
saveRDS(model, "separate_model.rds")
