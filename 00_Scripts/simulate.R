library(tidyverse)
source("00_Scripts/calculate.R")

# SIMULATION FUNCTIONS ----

# function to return a sample of guests for a single trial
sample_guests <- function(n, p) {
  # sum of random sample of size n with prob p of attending
  count <- sum(rbinom(n, 1, p))
}

# a function to simulate k weddings of n guests with probability p[1] to p[2]
simulate_weddings <- function(k, n, p,
                              fixed_cost, 
                              variable_guest_cost, 
                              guest_base, budget) {
  
  total_guests  <- replicate(
    # for k trials...
    k, 
    # sample n guests of probability p_1 to p_2
    sample_guests(n, p = runif(1, min = p[1], max = p[2]))
  )
  
  df <- data.frame(total_guests) %>%
    as.tibble() %>%
    mutate(trial = row_number()) %>%
    # total cost 
    mutate(total_cost = calculate_wedding_cost(fixed_cost, 
                                               variable_guest_cost,
                                               guest_base, total_guests)
    ) %>%
    # total risk
    mutate(risk = calculate_risk(budget, total_cost)) %>%
    # budget indicator
    mutate(over_budget = case_when(
      risk < 0 ~ "Yes",
      risk == 0 ~ "Even",
      risk > 0 ~ "No"),
      # used for coloring risk profile
      over_budget = factor(over_budget, levels = c("No", "Even", "Yes"))
    ) %>%
    # recommendation
    mutate(recommendation = calculate_recommendation(risk)) %>%
    select(trial, everything())
  
  return(df)
}

# function to provide recommendation based on simulation outcomes
recommend <- function(simulation_tbl, risk_tolerance) {
  
  # percentage of simulations that go over budget
  risk_pct <- simulation_tbl %>%
    summarize(mean(risk < 0)) %>% 
    pull()
  
  # determine if risk percentage exceeds tolerance
  recommendation <- ifelse(risk_pct > risk_tolerance, "Invite Less", "Invite All")
  
  return(recommendation)
}