# Function that accepts a number of minutes and converts it to the time of the day
mins_to_time <- function(minutes) {
  
  minutes <- round(minutes) # round the number of minutes
  minutes <- minutes %% (24 * 60) # ensure that the input is within a day's range

  # Calculate hours and minutes
  hours <- minutes %/% 60
  minutes <- minutes %% 60
  
  # Format the time in HH:MM format
  daytime <- sprintf("%02d:%02d", hours, minutes)
  
  return(daytime)
}

# Function that plots the density of a sample and computes its mean
plot_resamples <- function(sample_i) {
  lines(density(sample_i), col=rgb(0.5, 0.5, 1, 0.05))
  return(mean(sample_i))
}
