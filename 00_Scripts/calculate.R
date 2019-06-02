# CALCULATION FUNCTIONS ----

# function to calculate total cost
calculate_wedding_cost <- function(fixed_cost, 
                                   variable_guest_cost, 
                                   guest_base, total_guests) {
  # calculate added guest cost
  variable_cost <- variable_guest_cost * (total_guests - guest_base)
  # add to fixed cost
  total_cost <- variable_cost + fixed_cost
  return(total_cost)
}

# function to calculate risk
calculate_risk <- function(budget, total_cost) {
  return(budget - total_cost)
}

# function to recommend action
calculate_recommendation <- function(risk) {
  recommendation <- ifelse(risk >= 0, "Invite All", "Invite Less")
  return(recommendation)
  
}