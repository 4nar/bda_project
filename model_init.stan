data {
  int<lower=0> N;
  int<lower=0> nteams;
  int y1[N];
  int y2[N];
  int hometeam[N];
  int awayteam[N];
  
  int<lower=0> next_N;
  int next_hometeam[next_N];
  int next_awayteam[next_N];
}


parameters {
  //hyperparameters
  // real mu_att;
  real<lower=0> sigma_att;
  
  // real mu_def;
  real<lower=0> sigma_def;
  
  //parameters
  real<lower=0> home;
  
  vector<lower=0>[nteams] att_star;
  vector<lower=0>[nteams] def_star;
}


transformed parameters{
  vector[nteams] att;
  vector[nteams] def;
  real<lower=0> lambda[N, 2];
  
  // center attacking and defending (sum to zero)
  for (t in 1:nteams){
    att[t] = att_star[t] - mean(att_star);
    def[t] = def_star[t] - mean(def_star);
  }
  
  for (g in 1:N){
    // Average Scoring intensities (accounting for mixing components)
    lambda[g,1] = exp(home + att[hometeam[g]] + def[awayteam[g]]);
    lambda[g,2] = exp(att[awayteam[g]] + def[hometeam[g]]);
    
  }
}


model {
  home ~ normal(0,100);
  
  // mu_att ~ normal(0,100) T[0,];
  sigma_att ~ gamma(5,15);
  
  // mu_def ~ normal(0,100) T[0,];
  sigma_def ~ gamma(5,15);
  
  for (t in 1:nteams){
    att_star[t] ~ normal(0, sigma_att); //normal(mu_att, sigma_att) T[0,];
    def_star[t] ~ normal(0, sigma_def); //normal(mu_def, sigma_def) T[0,];
  }
  
  for (g in 1:N) {
    // Observed number of goals scored by each team
    y1[g] ~ poisson(lambda[g,1]);
    y2[g] ~ poisson(lambda[g,2]);
  }
}


generated quantities {
  real<lower=0> next_lambda[next_N, 2];
  int next_y1[next_N];
  int next_y2[next_N];
  vector[N] log_lik[2];
  real y_rep1[N];
  real y_rep2[N];
  
  for (g in 1:next_N){
    // Average Scoring intensities (accounting for mixing components)
    next_lambda[g,1] = exp(att[next_hometeam[g]] + def[next_awayteam[g]]);
    next_lambda[g,2] = exp(att[next_awayteam[g]] + def[next_hometeam[g]]);
    
    // Predicted number of goals scored by each team
    next_y1[g] = poisson_rng(next_lambda[g,1]);
    next_y2[g] = poisson_rng(next_lambda[g,2]);
  }
  
     for (g in 1:N){
      y_rep1[g] = poisson_rng(lambda[g,1]);
      y_rep2[g] = poisson_rng(lambda[g,2]);
      log_lik[1,g] = poisson_lpmf(y1[g] | lambda[g,1]);
      log_lik[2,g] = poisson_lpmf(y2[g] | lambda[g,2]);
}
}

