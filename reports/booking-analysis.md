Restaurant Booking Analysis with Bootstrapping
================

**Author:** Daniele Melotti<br> **Date:** Dec 2023

*See README for info about data and list of tasks*.

# 1. Data Exploration

## Load the data and convert *datetime* into a POSIXlt date-time format

We start by loading and taking a peek at the dataset:

``` r
bookings <- read.table("../data/first_bookings_datetime_sample.txt",
                       header=TRUE) # loading the data
str(bookings$datetime) # understanding what data type we are dealing with
```

    ##  chr [1:100000] "4/16/2014 17:30" "1/11/2014 20:00" "3/24/2013 12:00" ...

Our data is contained in a character vector, which is not ideal for
performing statistical operations. Therefore, we will convert the
content of *datetime* to a POSIXlt date-time format and extract the
components that interest us.

## Calculate the time of each booking in minutes since the start of the day. Store the result in a new variable - *minday*

Since we know that EZTABLE would like to start a promotion for new
members to make their bookings earlier in the day, we focus on
extracting the hours and minutes after converting *datetime* to a
POSIXlt object. We do not focus on date.

``` r
# Converting datetime to a POSIXlt object, extracting hours and minutes
hours <- as.POSIXlt(bookings$datetime, format="%m/%d/%Y %H:%M")$hour 
mins <- as.POSIXlt(bookings$datetime, format="%m/%d/%Y %H:%M")$min
```

Afterwards, we calculate the time of each booking in minutes since the
start of the day. So, we multiply the hours by 60 and add the minutes,
resulting in a single numerical value that represents the minute of the
day:

``` r
minday <- hours * 60 + mins
```

## Plot the density of *minday*

Now, we shall see the density of *minday* so as to get an idea of how
the values of this vector are distributed:

``` r
plot(density(minday), main="Minute of the day of first ever booking",
     ylab = "", xlab = "Minutes", col="cornflowerblue", lwd=2)
```

<img src="booking-analysis_files/figure-gfm/minday density-1.png" style="display: block; margin: auto;" />

We see a *distribution that is similar to a bimodal*, with a peek of
booking times around 700 minutes and another around 1100 minutes, which
likely represent booking requests before lunch and dinner time. Next, we
are going to conduct an analysis of the mean booking time.

# 2. Mean Booking Times - Bootstrapping

## Calculate the mean booking time and its standard error

We shall start by computing the mean booking time and its standard
error. The standard error is computed by dividing the standard deviation
of the booking time by the square root of the total number of bookings:

``` r
minday_mean <- mean(minday) # mean
minday_mean
```

    ## [1] 942.4964

``` r
minday_se <- sd(minday)/sqrt(length(minday)) # standard error
minday_se
```

    ## [1] 0.5997673

The *mean booking time corresponds to 942.4964 minutes*. To convert the
time back to a familiar format, we use a custom function, located in the
*functions.R* script:

``` r
source(file = "../R/functions.R")
mins_to_time(minday_mean) # custom function that converts number of minutes to time of the day
```

    ## [1] "15:42"

So, we know that the time at which a first booking is made on average is
15:42.

## Develop a 95% confidence interval for the mean booking time

Recall that the data we have available is only a sample; now that we
know mean and standard error, we are able to build a confidence interval
and get a clearer idea about the true average booking time:

``` r
# 95% CI:
lower_bound <- minday_mean - 1.96 * minday_se
lower_bound
```

    ## [1] 941.3208

``` r
upper_bound <- minday_mean + 1.96 * minday_se
upper_bound
```

    ## [1] 943.6719

The interval we just built suggests that we can be 95% confident that
the *true average booking time is between 941.2308 and 943.2308
minutes*, or that it is included between 15:41 and 15:44.

``` r
mins_to_time(lower_bound)
```

    ## [1] "15:41"

``` r
mins_to_time(upper_bound)
```

    ## [1] "15:44"

## Implement a bootstrap approach to generate 2000 new samples from the original dataset

Next, we are going to employ bootstrapping. This is a technique that
resamples a dataset to create several simulated samples. To implement
bootstrapping, we use the `replicate()` function, paired with
`sample()`. Let’s generate 2000 new samples from the original sample
data:

``` r
# Setting seed
set.seed(100)

# Creating 2000 new samples (bootstrapped samples) from the starting data
new_samples <- replicate(n = 2000,
                         sample(minday, length(minday), replace = TRUE))
```

## Visualize the distribution of the means from the bootstrapped samples

We might be interested in seeing how the 2000 bootstrapped samples look
like in comparison with the starting sample. We can display them on the
same plot. We achieve this by applying the custom function
`plot_resamples()`, included in the `functions.R` script. This function
plots the density of a sample and then applies a function on the sample;
if paired with `apply()`, it allows us to plot each bootstraped samples’
density and compute their means.

``` r
# Create an empty plotting space
plot(density(minday), lwd=0, ylim=c(0, 0.004), xlab = "Minutes", ylab = "",
     main = "Original sample vs. Bootstrapped samples with Mean indicators")

# Plot and get means of all bootstrapped samples
sample_means <- apply(new_samples, 2,
                      FUN = function(x) plot_resamples(x, mean))

# Add starting sample density to the plot
lines(density(minday), lwd = 2)

# add vertical lines for the means of each the original sample and each new sample 
abline(v = sample_means, col = rgb(0.0, 0.4, 0.0, 0.05))
abline(v = minday_mean, lwd = 1, col = "red")
```

<img src="booking-analysis_files/figure-gfm/minday density + means-1.png" style="display: block; margin: auto;" />

We notice that the *bootstrapped samples’ densities are all very close
to the original sample*. The same goes for the bootstrapped means, the
confidence interval is certainly *very narrow*. Now, let’s visualize the
density of the 2000 bootstrapped means. We can take a look at how they
compare with the original mean value from the starting sample.

``` r
plot(density(sample_means), lwd = 2, col = "cornflowerblue",
     main = "Density of Bootstrapped samples with Original mean indicator",
     ylab = "", xlab = "Minutes")
abline(v = minday_mean, lwd = 2, col = "tomato") # adding vertical line for original sample mean
```

<img src="booking-analysis_files/figure-gfm/means density-1.png" style="display: block; margin: auto;" />

We see that the *bootstrapped means do not vary largely from the mean of
the original sample*. Most values are included between 941 and 944
minutes, with only a few means being outside of this interval.

## Calculate and interpret the 95% confidence interval of the bootstrapped means

We know what the 95% confidence interval is for the original sample’s
mean, now we can build a new interval for the resampled means. We can
build this interval using the `quantile()` function:

``` r
resampled_means_CI <- quantile(sample_means, probs = c(0.025, 0.975))
resampled_means_CI
```

    ##     2.5%    97.5% 
    ## 941.2731 943.7660

The 95% CI of the bootstrapped means ranges from 941.2731 to 943.766 (or
from 15:41 to 15:44), which is very similar to the CI of the original
sample’s mean.

``` r
mins_to_time(resampled_means_CI)
```

    ## [1] "15:41" "15:44"

This means that we are 95% confident that the *true average booking time
falls between 15:41 and 15:44*. With this confidence interval, we
complete the analysis of the average booking time.

# 3. Median Booking Times - Bootstrapping

## Determine the median booking time

Now, we focus on the median booking time, in other words, the time of
the day by which half of the customers has made their first booking.

``` r
# Computing median booking time
minday_median <- median(minday)
minday_median
```

    ## [1] 1040

``` r
# Converting minutes to time
mins_to_time(minday_median)
```

    ## [1] "17:20"

We see that the *median booking time is 1040 minutes*, in other words,
it’s 17:20.

## Visualize the distribution of the medians from the bootstrapped samples

We can display the bootstrapped medians and compare them with the
original sample’s median booking time. We shall use `plot_resamples()`
again.

``` r
# Create an empty plotting space
plot(density(minday), lwd=0, ylim=c(0, 0.004), xlab = "Minutes", ylab = "",
     main = "Original sample vs. Bootstrapped samples with Median indicators")

# Plot and get means of all bootstrapped samples
sample_medians <- apply(new_samples, 2,
                        FUN = function(x) plot_resamples(x, median))

# Add starting sample density to the plot
lines(density(minday), lwd = 2)

# add vertical lines for the means of each the original sample and each new sample 
abline(v = sample_medians, col = rgb(0.0, 0.4, 0.0, 0.05))
abline(v = minday_median, lwd = 1, col = "red")
```

<img src="booking-analysis_files/figure-gfm/minday density + medians-1.png" style="display: block; margin: auto;" />

Interestingly, we see that the *bootstrapped medians are close to the
original sample’s median*, however, there are gaps in between these
values. This is due to the fact that all the bootstrapped median values
are represented by one of these discrete values:

``` r
sort(unique(sample_medians))
```

    ## [1] 1020.0 1025.0 1030.0 1032.5 1035.0 1037.5 1040.0 1045.0 1050.0

Now, let’s visualize the density of the 2000 bootstrapped medians:

``` r
plot(density(sample_medians), lwd = 2, col = "cornflowerblue",
     main = "Density of Bootstrapped samples with Original median indicator",
     ylab = "", xlab = "Minutes")
abline(v = minday_median, lwd = 2, col = "tomato") # add vertical line for original sample median
```

<img src="booking-analysis_files/figure-gfm/medians density-1.png" style="display: block; margin: auto;" />

As we can see, the *bootstrapped medians are distributed quite widely
and non-normally*. This makes it hard to use them for inference.

## Estimate and interpret the 95% confidence interval of the bootstrapped medians

Let’s compute the 95% CI:

``` r
resampled_median_CI <- quantile(sample_medians, probs = c(0.025, 0.975))
resampled_median_CI
```

    ##  2.5% 97.5% 
    ##  1020  1050

The confidence interval shows that we can be 95% confident that the
*true median booking time is included between minutes 1020 and 1050*,
else:

``` r
mins_to_time(resampled_median_CI)
```

    ## [1] "17:00" "17:30"

Between 17:00 and 17:30. This is a window of 30 minutes, which is quite
large. The calculation of the confidence interval for the median
concludes the median analysis.

# 4. Business Implications

## Insights

The bimodal distribution seen [at the end of the data exploration
section](#sec1c) suggests **two peak periods**, likely corresponding to
lunch and dinner times. This pattern indicates that new members to
EZTABLE prefer these periods for their first bookings. This trend
presents an **opportunity to shift some of this demand to earlier
times**. For example, offering special promotions or incentives for
bookings made before the usual lunch peak could help redistribute the
customer flow. The narrow confidence interval for the mean booking time
seen in the [mean analysis section](#sec2e) suggests a consistent
pattern in customer behavior. Since the mean is later in the day
(15:42), **EZTABLE can design targeted promotions aimed at times just
before the average**, gradually encouraging customers to book earlier.
On the other hand, the median analysis [showed us a distribution](sec3b)
that doesn’t allow us to conduct inference easily.

## Business Strategy Recommendations

Considering what we have discovered so far, EZTABLE could employ the
following strategies in order to encourage early bookings:

1.  **Targeted promotions for early bookings**: Implement special offers
    or discounts for reservations made during off-peak morning hours.
    This could include ‘early bird’ specials or exclusive deals for
    bookings made before a certain time. Such promotions can incentivize
    customers to book earlier, potentially redistributing the demand
    away from peak periods.
2.  **Personalized Marketing Campaigns**: Use customer data to send
    personalized messages or offers to those who typically book during
    peak times, encouraging them to try booking earlier. Personalized
    communication can be more effective in changing customer behavior,
    as it directly addresses their habits.
3.  **Loyalty Program Enhancements**: Introduce or enhance loyalty
    programs that reward early bookings. Points or rewards could be
    increased for reservations made during targeted early hours. A
    loyalty program can create a long-term incentive for customers to
    change their booking habits.

These are a few simple recommendations for EZTABLE, which are designed
to leverage the insights from the booking time analysis to effectively
encourage early-day bookings, thereby aiding EZTABLE in optimizing
restaurant reservations and enhancing customer flow.
