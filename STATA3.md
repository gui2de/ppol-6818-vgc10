# STATA 3 ASSIGNMENT

## Part 1: Sampling noise in a fixed population

### Tabstat Results
- The ***"tabstat"*** command provides summary statistics (mean, median, and standard deviation) of the beta estimates for each defined sample size (10, 100, 1,000, and 10,000).
- What we should expect is that as the sample size increases, the beta estimates become more concentrated around the true parameter value (which is 2 in the model) and their spread (i.e., standard deviation) decreases.

### Boxplot Results
- The boxplot shows the distribution of the beta estimates across the 500 simulations for each sample size.
- In smaller samples (e.g., N = 10), the box (which represents the interquartile range) and whiskers are likely to be more spread out, indicating high variability.
- In larger samples (e.g., N = 10,000), the boxplot should be much tighter and centered closer to the true value, illustrating increased precision.

### Density Graph
- This graph overlays kernel density estimates for the beta estimates from each sample size.
- You will notice that for N = 10 the density is spread out (more dispersion), whereas for larger sample sizes, the density curve becomes more peaked and narrow around the true value.

### Variation of the Standard Error (SEM)
- This section first uses the ***"collapse"*** command to calculate the average standard error (SEM) for the beta estimates for each sample size.
- The resulting graph (a scatter plot with a connecting line) illustrates how the average SEM decreases as the sample size increases—consistent with the statistical theory that larger samples yield more precise estimations.

### Conclusions
**1. Effect of Sample Size on Estimation Precision:** The summary table and boxplot demonstrate that with small samples (N = 10) the beta estimates exhibit high variability and are less precise. As the sample size increases, the beta estimates become more concentrated around the true value, and the standard deviation of these estimates decreases.

**2. Distribution of Beta Estimates:** The density graph distinctly shows that with smaller sample sizes the distribution of beta estimates is wide and flat, while for larger samples it becomes more concentrated (peaked) around the expected value.

**3. Reduction in Standard Error:** The graph displaying the average standard error confirms that the uncertainty in the beta estimation (SEM) is reduced as sample size grows—in line with theoretical expectations.





























