library(rstan)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(loo)


# DATA
df_res <- read.csv('ligue1-20192020-results.csv')
df_next <- read.csv('ligue1-20192020-cancelled-games.csv')
df_teams <- read.csv('ligue1-20192020-teams.csv')

#stan_data <- list(N=nrow(df_res), nteams=length(unique(df_res$home.team)), y1=df_res$h.g., y2=df_res$a.g, hometeam=df_res$home.team, awayteam=df_res$away.team,
#                  next_N=nrow(df_next), next_hometeam=df_next$home.team, next_awayteam=df_next$away.team)

# HIERARCHICAL MODEL
# sm <- rstan::stan_model(file = "model_init.stan")
# model_hierarchical <- rstan::sampling(sm, data = stan_data, iter=8000, warmup=2000,
#                         control = list(adapt_delta = 0.99, max_treedepth = 15))
# model_hierarchical
# saveRDS(model_hierarchical, "hierarchical_model.rds")
model_hierarchical <- readRDS("hierarchical_model.rds") 

# SEPARATE MODEL
# sm <- rstan::stan_model(file = "football_separate.stan")
# model_separate <- rstan::sampling(sm, data = stan_data, chains=4, iter=20000, warmup=4000,
#                         control = list(adapt_delta = 0.99, max_treedepth = 15))
#model_separate
#saveRDS(model_separate, "separate_model.rds")
model_separate <- readRDS("separate_model.rds")

# Computing the PSIS-LOO elpd values and the k-values for separate model.


log_lik_sep <- extract_log_lik(model_separate, merge_chains = FALSE)
r_eff_sep <- relative_eff(exp(log_lik_sep), cores = 2)
loo_sep <- loo(log_lik_sep, r_eff = r_eff_sep, cores = 2)



# Visualization of k-values for separate model.

plot(loo_sep,
     diagnostic = c("k", "n_eff"),
     label_points = FALSE,
     main = "PSIS diagnostic plot separate model"
)

# PSIS-LOO values for separate model.
loo_sep


#Computing the PSIS-LOO elpd values and the k-values for hierarchical model.

log_lik_hierarchical <- extract_log_lik(model_hierarchical,
                                        merge_chains = FALSE)
r_eff_hierarchical <- relative_eff(exp(log_lik_hierarchical), cores = 2)
loo_hierarchical <- loo(log_lik_hierarchical, r_eff = r_eff_hierarchical, 
                        cores = 2)

#Visualization of k-values for hierarchical model.

plot(loo_hierarchical,
     diagnostic = c("k", "n_eff"),
     label_points = FALSE,
     main = "PSIS diagnostic plot hierarchical model")

#PSIS-LOO values for hierarchical model.
loo_hierarchical