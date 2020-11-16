data {
  int<lower=0> N;
  int<lower=0> nteams;
  int y1[N];
  int y2[N];
  int hometeam[N];
  int awayteam[N];
}

parameters {
  //hyperparameters
  real mu_att;
  real<lower=0> sigma_att;
  
  real mu_def;
  real<lower=0> sigma_def;
  
  //parameters
  real<lower=0> home;
  
  vector<lower=0>[nteams] att_star;
  vector<lower=0>[nteams] def_star;

}

transformed parameters{
    //vector[nteams] att;
    //vector[nteams] def;
    real theta[N, 2];
    
    //for (t in 1:nteams){
      //att[t] = att_star[t] - mean(att_star);
      //def[t] = def_star[t] - mean(def_star);
    //}
    for (g in 1:N) {
    // Average Scoring intensities (accounting for mixing components)
      theta[g,1] = home + att_star[hometeam[g]] + def_star[awayteam[g]];
      theta[g,2] = att_star[awayteam[g]] + def_star[hometeam[g]];
  
}
}

model {

  home ~ normal(0,100) T[0,];
  
  mu_att ~ normal(0,100) T[0,];
  sigma_att ~ gamma(0.1,0.1);
  
  mu_def ~ normal(0,100) T[0,];
  sigma_def ~ gamma(0.1,0.1);
  

  for (t in 1:nteams){
    att_star[t] ~ normal(mu_att, sigma_att) T[0,];
    def_star[t] ~ normal(mu_def, sigma_def) T[0,];
  }
  
  
  for (g in 1:N) {
    // Observed number of goals scored by each team
    y1[g] ~ poisson(theta[g,1]);
    y2[g] ~ poisson(theta[g,2]);
}
}

