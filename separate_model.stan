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
  home ~ normal(0,100) T[0,];
  
  for (t in 1:nteams){
    att_star[t] ~ normal(0, 1) T[0,];
    def_star[t] ~ normal(0, 1) T[0,];
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
  
  for (g in 1:next_N){
    // Average Scoring intensities (accounting for mixing components)
    next_lambda[g,1] = exp(att[next_hometeam[g]] + def[next_awayteam[g]]);
    next_lambda[g,2] = exp(att[next_awayteam[g]] + def[next_hometeam[g]]);
    
    // Predicted number of goals scored by each team
    next_y1[g] = poisson_rng(next_lambda[g,1]);
    next_y2[g] = poisson_rng(next_lambda[g,2]);
  }
}

