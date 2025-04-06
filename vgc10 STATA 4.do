****Problem Set 4*****
*****PPOL-6818-01*****
***Vanessa Coronado***

clear 
set seed 1
set more off


if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818\week_10\03_assignment"
}


if c(username)=="vanes" {
	
	global wd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_10\03_assignment"
}

cd "$wd"



***Part 1: Power calculations for individual-level randomization***

*We need a power of 80%
*We need to estimate the sample size, we know that Y is normally distributed with a 0 mean and sd of 1.
*The average treatment effect should be 0.1sd (which is the average for treatment sample) but the effects are uniformly distributed between 0 and 0.2sd, which means that the mean tends to 0.1
*We want a treatment effect of 0.1sd

power twomeans 0 0.1, sd(1) power(0.8)
return list

power twomeans 0, sd(1) n(`r(N)') power(0.8)
return list

capture program drop power_calc
program define power_calc, rclass
    syntax, obs(integer)
clear
set obs `obs'

generate treatment_effect = runiform(0, 0.2)

duplicates tag treatment_effect, generate(effect_tag)
count if effect_tag > 0
replace treatment_effect = runiform(0, 0.2) if effect_tag > 0
duplicates report treatment_effect
sum treatment_effect
drop effect_tag

generate id = _n
generate treatment = 0
replace treatment = 1 if mod(id, 2) == 0 
tab treatment
drop id

generate Y = rnormal(0,1) + treatment * treatment_effect
summarize Y

reg Y treatment

matrix results = r(table)
matrix list results
return scalar coef = results[1,1]
return scalar pval = results[4,1]
return scalar N = results[7,1] + 2
end

power_calc, obs(1000)
display `r(coef)'
display `r(pval)'
display `r(N)'

clear
tempfile simulations
save `simulations', replace emptyok

forvalues num = 3000(10)3200 {
	clear
	 quietly {
        simulate samplesize = r(N) beta = r(coef) pval = r(pval), reps(10000): power_calc, obs(`num')
    
	append using `simulations'
	save `simulations', replace
	}
	    di "Completed simulations for sample size = `num'"

}

gen sig = pval < 0.05
collapse (mean) power=sig, by(samplesize)

twoway line power samplesize, ///
    title("Empirical Power by Sample Size") ///
    ytitle("Power") xtitle("Sample Size") ///
    ylabel(0(.1)1) xlabel(3000(10)3200) ///
    lwidth(medium) lcolor(navy)

// The optimal sample size would be 3142	

**When we incorporate 15% atrittion rate to control and treatment groups...

//The optimal sample size without attrition is 3142, then...
display 3142/(1-0.15) //The new sample size with 15% atrittion rates would be 3697

clear
tempfile simulations2
save `simulations2', replace emptyok

forvalues num = 3600(10)3800 {
	clear
	 quietly {
        simulate samplesize = r(N) beta = r(coef) pval = r(pval), reps(10000): power_calc, obs(`num')
    
	append using `simulations2'
	save `simulations2', replace
	}
	    di "Completed simulations for sample size = `num'"

}

gen sig = pval < 0.05
collapse (mean) power=sig, by(samplesize)

twoway line power samplesize, ///
    title("Empirical Power by Sample Size") ///
    ytitle("Power") xtitle("Sample Size") ///
    ylabel(0(.1)1) xlabel(3600(10)3800) ///
    lwidth(medium) lcolor(navy)

**Now, we can only provide the treatment to 30% of the sample, so the control group would be 80% of the sample. How should I change sample size needed to get 80% power...

capture program drop power_calc2
program define power_calc2, rclass
    syntax, obs(integer)
clear
set obs `obs'

generate treatment_effect = runiform(0, 0.2)

duplicates tag treatment_effect, generate(effect_tag)
count if effect_tag > 0
replace treatment_effect = runiform(0, 0.2) if effect_tag > 0
duplicates report treatment_effect
sum treatment_effect
drop effect_tag

generate id = _n
generate treatment = 0
count
scalar num_treatment = ceil(_N * 0.3)
generate random = runiform()
sort random
replace treatment = 1 in 1/`=num_treatment'
tab treatment
drop random
drop id

generate Y = rnormal(0,1) + treatment * treatment_effect
summarize Y

reg Y treatment

matrix results = r(table)
matrix list results
return scalar coef = results[1,1]
return scalar pval = results[4,1]
return scalar N = results[7,1] + 2
end

power_calc2, obs(1000)
display `r(coef)'
display `r(pval)'
display `r(N)'

clear
tempfile simulations3
save `simulations3', replace emptyok

forvalues num = 3750(10)3850 {
	clear
	 quietly {
        simulate samplesize = r(N) beta = r(coef) pval = r(pval), reps(10000): power_calc2, obs(`num')
    
	append using `simulations3'
	save `simulations3', replace
	}
	    di "Completed simulations for sample size = `num'"

}

gen sig = pval < 0.05
collapse (mean) power=sig, by(samplesize)

twoway line power samplesize, ///
    title("Empirical Power by Sample Size") ///
    ytitle("Power") xtitle("Sample Size") ///
    ylabel(0(.1)1) xlabel(3750(10)3850) ///
    lwidth(medium) lcolor(navy)

//The new sample size when there are only 30% of the sample size in the treatment group is around 3800


***Part 2: Power calculations for cluster randomization***
set seed 1

capture program drop clusters
program define clusters, rclass
    syntax, obs(integer) obs_per_school(integer)

clear

set obs `obs'

gen schools = _n
expand `obs_per_school'
by schools, sort: gen students = _n

local rho = 0.3
local sd_u = sqrt(`rho')

by schools (students), sort: gen u = rnormal(0, `sd_u') if _n == 1
by schools (students): replace u = u[1]

gen treated_school = 0
gen school_rank = _n if students == 1
bysort schools (students): replace treated_school = 1 if school_rank <= `obs'/2
drop school_rank
generate treatment_effect = runiform(0.15, 0.25)

gen y = u + treated_school * treatment_effect

reg y treated_school, cluster(schools)

sum treatment_effect if treated_school == 1

mixed y || schools:
estat icc

reg y treated_school, cluster(schools)
matrix results = r(table)
matrix list results
return scalar df = results[7,1]
return scalar coef = results[1,1]
return scalar pval = results[4,1]
end

clusters, obs(200) obs_per_school(10)
display `r(df)'
local c_size = (`r(df)'+1)
display `c_size'

//If we hold the number of cluster fixed at 200 to find to increase the cluster size and see what happen to the power to find the optimal cluster size...

clear
tempfile simulations4
save `simulations4', replace emptyok

local powerof2 "2 4 8 16 32 64 128 256 512 1024"
foreach value in `powerof2' {
	clear
	 quietly {
	 	simulate beta = r(coef) pval = r(pval), reps(1000): clusters, obs(200) obs_per_school(`value')
    generate cluster_size = `value'
	append using `simulations4'
	save `simulations4', replace
	}
	    di "Completed simulations for sample size = `value'"

}

gen sig = pval < 0.05
collapse (mean) power=sig, by(cluster_size)

**The power increases when the cluster size increase. I would recommend to use a cluster size of 1024 because it gives us a power of 90% which is the highest.



//If we hold the cluster size fixed at 15 to find the optimal number of schools to get a power of 80%...

clear
tempfile simulations5
save `simulations5', replace emptyok

forvalues num = 1450(10)1550 {
	clear
	 quietly {
        simulate beta = r(coef) pval = r(pval), reps(1000): clusters, obs(`num') obs_per_school(15)
		generate samplesize = `num'
	append using `simulations5'
	save `simulations5', replace
	}
	    di "Completed simulations for sample size = `num'"

}

gen sig = pval < 0.05
collapse (mean) power=sig, by(samplesize)

**The number of schools needed to get a power of 80% and a treatment effect of 0.2 is close to 1500.


//If only 70% of the school can adopt the treatment, how many schools do we need to get 80% of power?

capture program drop clusters2
program define clusters2, rclass
    syntax, obs(integer) obs_per_school(integer)

clear

set obs `obs'

gen schools = _n
expand `obs_per_school'
by schools, sort: gen students = _n

local rho = 0.3
local sd_u = sqrt(`rho')

by schools (students), sort: gen u = rnormal(0, `sd_u') if _n == 1
by schools (students): replace u = u[1]

gen rand = runiform() if students == 1
gen rank = .
sort rand
replace rank = _n if students == 1
count if rank != .
gen treated_school = 1 if schools <= r(N)*0.7
replace treated_school = 0 if treated_school == .
tab treated_school

generate treatment_effect = runiform(0.2, 0.25)

gen y = u + treated_school * treatment_effect

reg y treated_school, cluster(schools)

sum treatment_effect if treated_school == 1

mixed y || schools:
estat icc

reg y treated_school, cluster(schools)
matrix results = r(table)
matrix list results
return scalar df = results[7,1]
return scalar coef = results[1,1]
return scalar pval = results[4,1]
end

clusters2, obs(200) obs_per_school(10)

clear
tempfile simulations6
save `simulations6', replace emptyok

forvalues num = 950(10)1050 {
	clear
	 quietly {
        simulate beta = r(coef) pval = r(pval), reps(1000): clusters2, obs(`num') obs_per_school(15)
		generate samplesize = `num'
	append using `simulations6'
	save `simulations6', replace
	}
	    di "Completed simulations for sample size = `num'"

}

simulate beta = r(coef) pval = r(pval), reps(1000): clusters2, obs(300) obs_per_school(15)

gen sig = pval < 0.05
collapse (mean) power=sig, by(samplesize)

**When 70% of the sample size get the treatment, the number of observations required to get 80% of power is close to 300.

***Part 3: De-biasing a parameter estimate using controls***
clear

capture program drop dgp_sim
program define dgp_sim, rclass
    syntax, obs(integer) obs_strata(integer)

    * --- Step 1: Create a stratum-level dataset ---
    clear
    set obs 4 // 4 strata groups

    gen strata = _n
    label define strata_lbl 1 "North" 2 "South" 3 "East" 4 "West"
    label values strata strata_lbl

    * --- Stratum-level effect on the outcome ---
    gen strata_effect = 0.3 * strata

    * Save strata-level dataset
    tempfile strata_data
    save `strata_data', replace

    * --- Step 2: Create individual-level dataset and expand ---
    clear
    set obs `obs'  // Number of individuals
    gen strata = mod(_n, 4) + 1  // Assign each individual to one of the strata

    * Expand to generate multiple observations per strata
    expand `obs_strata'  // Assume 10 individuals per stratum
    gen id = _n

    * --- Merge stratum-level data to individual-level dataset ---
    merge m:1 strata using `strata_data', nogen

    * --- Step 3: Add covariates ---
    gen X1 = rnormal()  // Confounder: Affects both treatment & outcome
    gen X2 = rnormal()  // Affects only outcome
    gen X3 = rnormal()  // Affects only treatment
    gen X4 = rnormal()  // Noise

    * --- Step 4: Treatment assignment based on covariates (confounder X1 and treatment-assignment variable X3) ---
    gen propensity = invlogit(0.3 * X1 + 0.5 * X3)  // Logit model for treatment assignment
    gen treat = rbinomial(1, propensity)

    * --- Random noise and true treatment effect ---
    local true_effect = 0.5  // True treatment effect
    gen epsilon = rnormal(0, 1)

    * --- Step 5: Outcome ---
    gen Y = `true_effect' * treat + 0.4 * X1 + 0.6 * X2 + strata_effect + epsilon

    * Save true treatment effect for later comparison
    return scalar true_beta = `true_effect'
end

dgp_sim, obs(1000) obs_strata(10)
display `r(true_beta)'

capture program drop models
program define models, rclass
    syntax, obs(integer) obs_strata(integer)

    * Generate data
    dgp_sim, obs(`obs') obs_strata(`obs_strata')

    * Model 1: Only treatment
    reg Y treat
    return scalar beta1 = _b[treat]

    * Model 2: + Confounder (X1)
    reg Y treat X1
    return scalar beta2 = _b[treat]

    * Model 3: + X1 + X2 (outcome-relevant)
    reg Y treat X1 X2
    return scalar beta3 = _b[treat]

    * Model 4: + X1 + X2 + X3 (all covariates)
    reg Y treat X1 X2 X3
    return scalar beta4 = _b[treat]

    * Model 5: + X1 + X2 + X3 + strata FE
    reg Y treat X1 X2 X3 i.strata
    return scalar beta5 = _b[treat]

    return scalar true_beta = r(true_beta)
end

models, obs(1000) obs_strata(10)
display `r(beta5)'

clear
tempfile results
save `results', emptyok

foreach N in 100 200 500 1000 2000 {
    quietly{
	simulate beta1 = r(beta1) beta2 = r(beta2) beta3 = r(beta3) beta4 = r(beta4) beta5 = r(beta5), reps(500) nodots: models, obs(`N') obs_strata(10)
    gen N = `N'
    append using `results'
    save `results', replace
	}
	di "Completed simulations for sample size = `N'"
}

preserve
collapse (mean) mean_beta1=beta1, by(N)
line mean_beta1 N
graph box mean_beta1, over(N) ytitle("Beta1 Means") title("Distribution of beta means")
restore

preserve
collapse (sd) sd_beta1=beta1, by(N)
line sd_beta1 N
graph box sd_beta1, over(N) ytitle("Beta1 Standard Dev") title("Distribution of beta sd")
restore

preserve
collapse (mean) mean_beta2=beta2, by(N)
line mean_beta2 N
graph box mean_beta2, over(N) ytitle("Beta2 Means") title("Distribution of beta means")
restore

preserve
collapse (sd) sd_beta2=beta2, by(N)
line sd_beta2 N
graph box sd_beta2, over(N) ytitle("Beta2 Standard Dev") title("Distribution of beta sd")
restore

preserve
collapse (mean) mean_beta3=beta3, by(N)
line mean_beta3 N
graph box mean_beta3, over(N) ytitle("Beta3 Means") title("Distribution of beta means")
restore

preserve
collapse (sd) sd_beta3=beta3, by(N)
line sd_beta3 N
graph box sd_beta3, over(N) ytitle("Beta3 Standard Dev") title("Distribution of beta sd")
restore

preserve
collapse (mean) mean_beta4=beta4, by(N)
line mean_beta4 N
graph box mean_beta4, over(N) ytitle("Beta4 Means") title("Distribution of beta means")
restore

preserve
collapse (sd) sd_beta4=beta4, by(N)
line sd_beta4 N
graph box sd_beta4, over(N) ytitle("Beta4 Standard Dev") title("Distribution of beta sd")
restore

preserve
collapse (mean) mean_beta5=beta5, by(N)
line mean_beta4 N
graph box mean_beta5, over(N) ytitle("Beta5 Means") title("Distribution of beta means")
restore

preserve
collapse (sd) sd_beta5=beta5, by(N)
line sd_beta5 N
graph box sd_beta5, over(N) ytitle("Beta5 Standard Dev") title("Distribution of beta sd")
restore




