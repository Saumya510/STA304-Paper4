# SIMULATION

# This file is used to simulate data found in the DHS Fact Sheet. 

library(ggplot2)

set.seed(19)

states = rep(letters[1:5])

col1 = rnorm(n = 5, mean = 50, sd = 10)
col2 = rnorm(n = 5, mean = 50, sd = 10)
col3 = rnorm(n = 5, mean = 50, sd = 10)

sim_df <- data.frame(states, col1, col2, col3)

ggplot(sim_df, aes(states, col1)) +
  geom_point()
