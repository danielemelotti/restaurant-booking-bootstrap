# Objective
This project is based on the bookings made by customers on an online restaurant reservation platform. The goal of to analyze when new members typically make their first bookings, with a specific focus on identifying the average and median booking times. Imagine that EZTABLE would like to start a promotion for new members to make their bookings earlier in the day. This analysis will help EZTABLE in strategizing such promotion to encourage early-day bookings, thereby potentially optimizing restaurant reservations and customer flow. The type of analysis on which we focus in this project is bootstrapping.

# Dataset
The dataset used in this project consists of a sample drawn from a larger population which records the time and day each booking was made by a new customer.

# Task Descriptions

## 1. Data Exploration
* Load the data and convert _datetime_ into a POSIXlt date-time format.
* Calculate the time of each booking in minutes since the start of the day. Store the result in a new variable - _minday_.
* Plot the density of _minday_.

## 2. Mean Booking Times - Bootstrapping
* Calculate the mean booking time and its standard error.
* Develop a 95% confidence interval for the mean booking time.
* Implement a bootstrap approach to generate 2000 new samples from the original dataset.
* Visualize the distribution of the means from the bootstrapped samples.
* Calculate and interpret the 95% confidence interval of the bootstrapped means.

## 3. Median Booking Times - Bootstrapping
* Determine the median booking time.
* Conduct a bootstrap analysis for the median booking time, similar to the mean.
* Visualize the distribution of the medians from the bootstrapped samples.
* Estimate and interpret the 95% confidence interval of the bootstrapped medians.

## 4. Business Implications
* Insights
* Business Strategy Recommendations