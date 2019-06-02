library(tidyverse)
library(glue)

# get recommendation function
source("00_Scripts/simulate.R")


# SETUP ----

# set theme for plots
theme_set(theme_minimal(base_family = "Avenir"))

# The palette with grey:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", 
               "#0072B2", "#D55E00", "#CC79A7")


# PLOT FUNCTIONS ----

# plot guest count distribution with 95% confidence interval
plot_guest_count <- function(simulation_tbl) {
  
  # generate 2.5 and 97.5 percentiles from simulation data
  ci_int_guest <- quantile(simulation_tbl$total_guests, p = c(0.025, .975))
  
  # create histogram plot of results
  p <- simulation_tbl %>%
    ggplot(aes(total_guests)) +
    geom_histogram(binwidth = 1, 
                   fill = cbPalette[6],
                   color = "white") +
    geom_hline(yintercept = 0, size = .5, colour="#333333") +
    geom_vline(xintercept = ci_int_guest[1], linetype = "dashed") +
    geom_vline(xintercept = ci_int_guest[2], linetype = "dashed") +
    labs(title = "Total Guest Count",
         subtitle = glue("95% Confidence Estimate: {ci_int_guest[1]} -",
                         "{ci_int_guest[2]} guests"),
         x = "Total Guests",
         y = "Simulation Trials",
         caption = "Source: Simulation Results")
  
  return(p) 
}


# plot cost distribution with 95% confidence interval
plot_cost <- function(simulation_tbl, variable_guest_cost = 125) {
  
  ci_int_cost <- quantile(simulation_tbl$total_cost, p = c(0.025, .975))
  
  # create histogram of results
  p <- simulation_tbl %>%
    ggplot(aes(total_cost)) +
    # histogram bin size should be equal to per guest variable cost
    geom_histogram(binwidth = variable_guest_cost,
                   fill = cbPalette[8],
                   color = "white") +
    geom_hline(yintercept = 0, size = .5, colour="#333333") +
    labs(title = "Total Guest Cost",
         subtitle = glue("95% Confidence Estimate: ${ci_int_cost[1]} -",
                         "${ci_int_cost[2]}"),
         x = "Total Cost",
         y = "Simulation Trials",
         caption = "Source: Simulation Results") +
    geom_vline(xintercept = ci_int_cost[1], linetype = "dashed") +
    geom_vline(xintercept = ci_int_cost[2], linetype = "dashed")
  
  return(p)
}


# plot the risk profile with probability of going over budget
plot_risk <- function(simulation_tbl, variable_guest_cost = 125) {
  
  ci_int_risk <- quantile(simulation_tbl$risk, p = c(0.025, .975))
  
  # risk profile
  p_over_budget <- simulation_tbl %>%
    summarise(p_val = mean(risk < 0))
  
  # plot risk profile with 95% confidence interval
  p <- simulation_tbl %>%
    # color histrogram bins based on positive/negative risk
    ggplot(aes(risk, fill = over_budget)) +
    # histogram bin size should be equal to per guest variable cost
    geom_histogram(binwidth = variable_guest_cost,
                   color = "white") +
    geom_hline(yintercept = 0, size = .5, colour = "#333333") +
    scale_fill_manual(values = c(cbPalette[4], cbPalette[5], cbPalette[7])) +
    labs(title = "Total Budget Risk",
         subtitle = glue("95% Confidence Estimate: ${ci_int_risk[1]} - ${ci_int_risk[2]} ",
                         "({p_over_budget * 100}% risk)"),
         x = "Net Risk",
         y = "Simulation Trials",
         caption = "Source: Simulation Results") +
    guides(fill = FALSE) +
    geom_vline(xintercept = ci_int_risk[1], linetype = "dashed") +
    geom_vline(xintercept = ci_int_risk[2], linetype = "dashed")
  
  # if there are no even budget outcomes
  if (length(unique(simulation_tbl$over_budget)) < 3) {
    p <- p +
      scale_fill_manual(values = c(cbPalette[4], cbPalette[7]))
  }
  
  return(p)
}

# plot the distribution of recommendation outcomes
plot_recommendation <- function(simulation_tbl, risk_tolerance) {
  
  # get recommendation for subtitle
  ovr_recommendation <- recommend(simulation_tbl, risk_tolerance)
  
  # build main plot
  p <- simulation_tbl %>%
    ggplot(aes(recommendation, fill = recommendation)) +
    # convert counts to percentages
    geom_bar(aes(y = (..count..) / sum(..count..))) + 
    scale_y_continuous(labels = function(x) glue("{round(x * 100, 2)}%")) +
    labs(
      title = "Recommendation Outcomes",
      subtitle = glue("Overall Recommendation: {ovr_recommendation}"),
      x = "",
      y = "Simulation Trials",
      caption = "Source: Simulation Results"
    ) +
    guides(fill = FALSE) +
    geom_hline(yintercept = 0, size = .5, colour = "#333333") +
    # add dashed line for risk tolernace
    geom_hline(yintercept = risk_tolerance, linetype = "dashed")
  
  # if risk tolerance is exceeded, color the Invite Less bar 
  if (mean(simulation_tbl$risk < 0) >= risk_tolerance) {
    p <- p + 
      scale_fill_manual(values = c(cbPalette[1], cbPalette[7]))
  } else {
    # else color the Invite All bar
    p <- p + 
      scale_fill_manual(values = c(cbPalette[4], cbPalette[1]))
  }
  
  return(p)
}