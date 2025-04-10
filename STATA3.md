# Stata 3 Assignment

## Part 1: Sampling noise in a fixed population

### Tabstat Results
- The ***"tabstat"*** command provides summary statistics (mean, median, and standard deviation) of the beta estimates for each defined sample size (10, 100, 1,000, and 10,000).
- What we should expect is that as the sample size increases, the beta estimates become more concentrated around the true parameter value (which is 2 in the model) and their spread (i.e., standard deviation) decreases.


| sample |   Mean   |   p50   |   SD   |
|--------|----------|---------|--------|
|     10 |   1.998  |  1.989  |  0.209 |
|    100 |   2.001  |  2.003  |  0.052 |
|   1000 |   2.000  |  2.000  |  0.016 |
|  10000 |   1.999  |  1.999  |  0.000 |
|  Total |   2.000  |  1.999  |  0.108 |


### Boxplot Results
- The boxplot shows the distribution of the beta estimates across the 500 simulations for each sample size.
- In smaller samples (e.g., N = 10), the box (which represents the interquartile range) and whiskers are likely to be more spread out, indicating high variability.
- In larger samples (e.g., N = 10,000), the boxplot should be much tighter and centered closer to the true value, illustrating increased precision.

Figure 1: ![My Picture](/Part1/Boxplot1.jpg)

### Density Graph
- This graph overlays kernel density estimates for the beta estimates from each sample size.
- You will notice that for N = 10 the density is spread out (more dispersion), whereas for larger sample sizes, the density curve becomes more peaked and narrow around the true value.

Figure 2: ![My Picture](/Part1/Distribution1.jpg)

### Variation of the Standard Error (SEM)
- This section first uses the ***"collapse"*** command to calculate the average standard error (SEM) for the beta estimates for each sample size.
- The resulting graph (a scatter plot with a connecting line) illustrates how the average SEM decreases as the sample size increases—consistent with the statistical theory that larger samples yield more precise estimations.

Figure 3: ![My Picture](/Part1/SEM1.jpg)

### Conclusions
**1. Effect of Sample Size on Estimation Precision:** The summary table and boxplot demonstrate that with small samples (N = 10) the beta estimates exhibit high variability and are less precise. As the sample size increases, the beta estimates become more concentrated around the true value, and the standard deviation of these estimates decreases.

**2. Distribution of Beta Estimates:** The density graph distinctly shows that with smaller sample sizes the distribution of beta estimates is wide and flat, while for larger samples it becomes more concentrated (peaked) around the expected value.

**3. Reduction in Standard Error:** The graph displaying the average standard error confirms that the uncertainty in the beta estimation (SEM) is reduced as sample size grows—in line with theoretical expectations.


## Part 2: Sampling noise in an infinite superpopulation

### Tabstat Results
- The ***"tabstat"*** command is used to display the mean, median, standard deviation, minimum, and maximum of the beta estimates for each sample size.
- The table is organized by the different sample sizes (e.g., 4, 8, 10, 16, …, 1,000,000).
- For each sample size, five statistics are reported for the estimated beta values from 500 simulation replications:
     - **Mean:** The average beta estimate.
     - **Median:** The middle value when the beta estimates are sorted.
     - **Standard Deviation (sd):** A measure of how much the beta estimates vary from the mean.
     - **Min and Max:** The extreme values observed in the simulation replications.

#### Comments and interpretaion:
- **Small sample sizes:** When the sample size is very small (e.g., N = 4 or N = 8), you would expect a high standard deviation because the estimates are subject to a lot of sampling variability. The mean and median might deviate notably from the true value.
- **Larger Sample Sizes:** As the sample size increases, the mean and median should converge toward the true parameter value. The standard deviation should shrink, reflecting a reduction in estimation variability. The range (min–max) will narrow, indicating that extreme outliers become less frequent as the sample size grows. See the results in the table below:

|  sample |     Mean   |    p50    |    SD    |   Min    |    Max    |
|---------|------------|-----------|----------|----------|-----------|
|      4  |  2.026951  | 1.992611  | .4992957 | .6596098 | 5.825044  |
|      8  |  2.014678  | 2.019964  | .2283867 | 1.133855 | 2.775716  |
|     10  |  1.985491  | 1.984657  | .1865603 | 1.014354 | 2.7634    |
|     16  |  2.002315  | 1.995722  | .1494681 | 1.397868 | 2.553326  |
|     32  |  1.993269  | 1.993972  | .0908234 | 1.731158 | 2.256501  |
|     64  |  1.998781  | 1.995083  | .0660932 | 1.780488 | 2.242492  |
|    100  |  2.000752  | 2.000592  | .0515442 | 1.852485 | 2.17289   |
|    128  |   2.00249  | 2.001762  | .0461668 | 1.831948 | 2.142309  |
|    256  |  2.000865  | 1.999959  | .0308105 | 1.905441 | 2.091883  |
|    512  |  1.998682  | 1.998174  | .0221467 | 1.931286 | 2.071273  |
|   1000  |  2.000899  | 2.000979  | .0153916 | 1.960082 | 2.044011  |
|   1024  |  1.999738  | 1.999042  | .0155298 | 1.95522  | 2.043283  |
|   2048  |  2.000421  | 2.00081   | .0105944 | 1.962619 | 2.029778  |
|   4096  |  2.000406  | 2.000369  | .0076054 | 1.980206 | 2.02283   |
|   8192  |  1.999945  | 2.000044  | .0056445 | 1.981554 | 2.016493  |
|  10000  |  1.999938  | 2.0001    | .0051148 | 1.982281 | 2.012379  |
|  16384  |  2.000192  | 1.999962  | .0040867 | 1.98853  | 2.012556  |
|  32768  |  2.000124  | 2.000214  | .0028213 | 1.991278 | 2.008207  |
|  65536  |  2.000007  | 1.999996  | .0019738 | 1.993705 | 2.005805  |
| 100000  |  1.999987  | 1.999929  | .001611  | 1.993471 | 2.005521  |
| 131072  |  2.000157  | 2.000156  | .0013538 | 1.995746 | 2.004045  |
| 262144  |  2.000042  | 2.000045  | .000948  | 1.997491 | 2.003012  |
| 524288  |  1.999987  | 1.999983  | .0007173 | 1.997496 | 2.002279  |
| 1000000 |  2.000038  | 2.000042  | .0004779 | 1.998786 | 2.001517  |
| 1048576 |   2.00001  | 2.00001   | .0005022 | 1.998527 | 2.001538  |
| 2097152 |  2.000029  | 2.000031  | .0003462 | 1.999129 | 2.001044  |
|  Total  | 2.001008   | 2.000019  | .1206791 | .6596098 | 5.825044  |

This table provides numerical evidence for the law of large numbers: with larger N, the sampling distribution of the estimator concentrates around the true value. Moreover, the reduced variability (lower sd) supports the theoretical (1/\sqrt{N}) relationship for the standard error of the estimator.

### Boxplot Results
- The boxplots produced to visualize the distribution of the beta estimates for each defined sample size.
- Each box in the graph represents the distribution (based on the 500 replications) of beta estimates for one specific sample size
- The box’s central line indicates the median, while the upper and lower edges of the box represent the first and third quartiles (Q1 and Q3).
- “Whiskers” extend from the box to depict the range—typically up to 1.5 times the interquartile range—and any points beyond are plotted as outliers.

Figure 4: ![My Picture](/Part2/Boxplot_Q2.jpg)

#### Interpretation
- **Wide Boxes for Small N:** In small samples, expect large boxes and long whiskers, signifying high variability in the beta estimates.
- **Tight Boxes for Large N:** For larger samples, the box and whiskers tend to become much narrower and centered closer to 2. This shows that increased N produces more stable and precise estimates.
- **Outliers:** Outliers or extreme values might be visible in smaller samples, whereas in larger samples they become rare.

The boxplot graphically confirms the numerical trends from the summary table. It clearly shows that with increasing sample size, not only do the average beta estimates converge to the true parameter but also the variability (spread) in the estimates decreases.

### Density Graphs
- The kernel density curves, each representing the distribution of beta estimates from simulations at a particular small sample size.
- We have 3 different density graphs to avoid distortion of the graphs because because we have very different sample sizes from each other.

Figure 5: ![My Picture](/Part2/Distribution_4to100.jpg)

Figure 6: ![My Picture](/Part2/Distribution_100to5000.jpg)

Figure 7: ![My Picture](/Part2/Distribution_5000to1000000.jpg)

- For very large sample sizes, the density curves become extremely narrow and sharply peaked around 2.
- The overlapping curves show very little variability, and any differences between the mid-sized and the very large samples are very subtle.
- This graph reinforces that, with enough data, the randomness in the beta estimator effectively “averages out.

### Variation of the Standard Error (SEM)
- The graph typically shows a clear inverse relationship: as sample size increases, the SEM decreases.
- For very small N, the SEM is high; as N grows to millions, the SEM becomes extremely small, leading to very narrow confidence intervals

Figure 8: ![My Picture](/Part2/SEM.jpg)

### Confidence Interval Width 
- The graph plots the average width of the confidence interval against sample size.
- Just like the SEM graph, it shows a scatter of points with a connecting line.
- With increasing sample size, the CI width decreases. This is expected because more data leads to a more precise estimate with less uncertainty.
- This plot makes it apparent that the benefits of having a larger sample are especially pronounced when moving from very small samples to moderate or large samples.

Figure 9: ![My Picture](/Part2/CI.jpg)

### Conclusions

**Comparison to Part 1**

**Ability to Draw Larger Sample Sizes**
   - In the previous simulation in Part 1, we always drew subsamples from a fixed dataset (with a fixed maximum of 10,000 observations).
   - In this new model, the program generates a fresh dataset each time with the exact sample size we request.
   - As a result, we are not limited by the original population size; we can simulate datasets with millions of observations.

**Differences in SEM and Confidence Intervals at Powers-of-Ten Compared to Previous Results**
   - With a fixed, relatively small maximum sample size (e.g., 10,000), the reduction in SEM and the narrowing of the CI were observable but limited to that range.
   - With the new simulation we are ncreasing the sample size and, as a result, the SEM further decreases, and the CIs become even narrower, consistent with the theoretical inverse relationship.
   - The dramatic contrast between the very high variability at small sample sizes and the extremely tight distributions at very large sample sizes is now very apparent.
   - Differences between powers-of-ten (e.g., going from 10,000 to 100,000) become more pronounced because the relative gain in precision is larger when you start with a relatively small sample versus an extremely large one. 

The ability to simulate with very large sample sizes is a key improvement because it removes the fixed-population limitation, allowing us to observe the full effect of increasing sample size on estimation precision. In turn, when we examine the powers-of-ten simulations, the SEM and CI widths are much smaller than what we observed in Part 1, smaller-sample simulations.





























