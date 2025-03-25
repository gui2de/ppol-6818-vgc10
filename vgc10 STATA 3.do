****Problem Set 3*****
*****PPOL-6818-01*****
***Vanessa Coronado***

clear 
set seed 1
set more off

global wd "C:\Users\vanes\Box\PPOL-6818-01\Stata 03"

if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\Box\PPOL-6818-01\Stata 03"
}


***PART 1***
set obs 10000

generate x1 = rnormal(0, 1)
*generate x2 = runiform()

*generate y = 1 + 2*x1 + 3*x2 + rnormal(0, 0.5)
generate y = 1 + 2*x1 + rnormal(0, 0.5)
br

save "$wd\dataxxy.dta", replace
global dataxxy "$wd\dataxxy.dta"

capture program drop reg_outcome
program define reg_outcome, rclass
    syntax, nsample(integer)
	
	preserve
	use "$dataxxy", clear
	gen double rdnum = runiform()
	sort rdnum
	keep in 1/`nsample'
	reg y x1
	return scalar N = _N
    return scalar beta = _b[x1]
    return scalar SEM = _se[x1]
	scalar tvalue = _b[x1] / _se[x1]
    scalar pvalue = 2*ttail(e(df_r), abs(tvalue))
    return scalar p_value = pvalue
	scalar ci_lower = _b[x1] - invttail(e(df_r), 0.025) * _se[x1]
    scalar ci_upper = _b[x1] + invttail(e(df_r), 0.025) * _se[x1]
    return scalar ci_lower = ci_lower
    return scalar ci_upper = ci_upper
	restore
	
end

* Testing the program with a sample size of 100
reg_outcome, nsample(100)
return list


clear
set more off

* Simulation when N = 10
simulate N=r(N) beta=r(beta) SEM=r(SEM) p_value=r(p_value) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) nodots: reg_outcome, nsample(10)
gen sample = 10
tempfile sim10
save `sim10', replace

* Simulation when N = 100
simulate N=r(N) beta=r(beta) SEM=r(SEM) p_value=r(p_value) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) nodots: reg_outcome, nsample(100)
gen sample = 100
tempfile sim100
save `sim100', replace

* Simulation when N = 1,000
simulate N=r(N) beta=r(beta) SEM=r(SEM) p_value=r(p_value) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) nodots: reg_outcome, nsample(1000)
gen sample = 1000
tempfile sim1000
save `sim1000', replace

* Simulation when N = 10,000
simulate N=r(N) beta=r(beta) SEM=r(SEM) p_value=r(p_value) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) nodots: reg_outcome, nsample(10000)
gen sample = 10000
tempfile sim10000
save `sim10000', replace

* Appending results for each simulation
use `sim10', clear
append using `sim100'
append using `sim1000'
append using `sim10000'
save "$wd\simdata.dta", replace
global simulation "$wd\simdata.dta"


clear
set more off

* Cargar los resultados de la simulación
use "$simulation", clear

* Summary table: mean, median and standard deviation for beta for each sample size
tabstat beta, statistics(mean median sd) by(sample) format(%9.3f)

* Boxplot graph to visualize the distribution of the beta estimates for each sample size
graph box beta, over(sample) ytitle("Beta estimates for x1") title("Distribution of beta estimates according to sample size")
*graph export "$wd", replace

*Density graph
twoway ///
    (kdensity beta if sample==10,   lcolor(blue)   lpattern(solid)    lwidth(medium)) ///
    (kdensity beta if sample==100,  lcolor(red)    lpattern(dash)     lwidth(medium)) ///
    (kdensity beta if sample==1000, lcolor(green)  lpattern(dot)      lwidth(medium)) ///
    (kdensity beta if sample==10000, lcolor(black) lpattern(longdash) lwidth(medium)), ///
    legend(order(1 "N = 10" 2 "N = 100" 3 "N = 1000" 4 "N = 10000") region(lcolor(white))) ///
    xtitle("Beta Estimates") ///
    ytitle("Density") ///
    title("Distribution of beta estimates according to sample size")

* Analyzing the variation of the standard error (SEM)
preserve
collapse (mean) beta SEM, by(sample)
twoway (scatter SEM sample) (line SEM sample, sort), ///
    ytitle("Average Standard Error") xtitle("Sample Size") ///
    title("Standar error variation according to sample size")
*graph export "$wd", replace
restore


***PART 2***
clear 
set seed 1
set more off

global wd "C:\Users\vanes\Box\PPOL-6818-01\Stata 03\Part 2"

if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\Box\PPOL-6818-01\Stata 03\Part 2"
}

capture program drop reg_outcome
program define reg_outcome, rclass
    version 18.5
    // Define argument: the sample size (must be an integer)
    syntax, nsample(integer)

    preserve  // Keep current state
    clear
    // Set sample size
    set obs `nsample'
    // Generate x1 from the standard normal distribution
    generate x1 = rnormal(0, 1)
    // Generate y according to the true relationship plus error
    generate y = 1 + 2*x1 + rnormal(0, 0.5)
    
    // Run regression of y on x1
    regress y x1

    // Return key results
    return scalar N = _N
    return scalar beta = _b[x1]
    return scalar SEM = _se[x1]
    // Compute two-tailed p-value from the t-statistic
    scalar tstat = _b[x1] / _se[x1]
    scalar p = 2 * ttail(e(df_r), abs(tstat))
    return scalar p_value = p
    // Calculate 95% confidence interval for beta
    scalar ci_lower = _b[x1] - invttail(e(df_r), 0.025)*_se[x1]
    scalar ci_upper = _b[x1] + invttail(e(df_r), 0.025)*_se[x1]
    return scalar ci_lower = ci_lower
    return scalar ci_upper = ci_upper

    restore  // Restore data state
end

* Testing the program with a sample size of 100
reg_outcome, nsample(100)
return list

clear
set more off

* Define the list of sample sizes:
local sizes "4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 10 100 1000 10000 100000 1000000"

tempfile master
local first = 1

foreach s of local sizes {
    display "Simulating for sample size: " `s'
    simulate N=r(N) beta=r(beta) SEM=r(SEM) p_value=r(p_value) ci_lower=r(ci_lower) ci_upper=r(ci_upper), reps(500) nodots: reg_outcome, nsample(`s')
    // Create a variable to label the simulation by sample size
    gen sample = `s'
    // Save output for the current sample size to a temporary file
    tempfile simtemp
    save `simtemp', replace

    // If this is the first iteration, initialize the master dataset:
    if `first' {
        use `simtemp', clear
        save `master', replace
        local first = 0
    }
    else {
        append using `master'
        save `master', replace
    }
}

* Load the combined simulation dataset (13,000 observations) into memory
use `master', clear
save "$wd\simdata.dta", replace
global simulation "$wd\simdata.dta"


* Load simulation results
use "$simulation", clear

* Create a summary table of beta estimates by sample size
tabstat beta, statistics(mean median sd min max) by(sample)

* Boxplot graph to visualize the distribution of the beta estimates for each sample size
graph box beta, over(sample) ytitle("Beta estimates for x1") title("Distribution of Beta Estimates by Sample Size")


*Density graph to sizes from 4 to 100
twoway ///
    (kdensity beta if sample==4,   lcolor(blue)   lpattern(solid)    lwidth(medium)) ///
    (kdensity beta if sample==8,  lcolor(red)    lpattern(dash)     lwidth(medium)) ///
	(kdensity beta if sample==10, lcolor(brown)  lpattern(dash)      lwidth(medium)) ///
    (kdensity beta if sample==16, lcolor(green)  lpattern(dot)      lwidth(medium)) ///
    (kdensity beta if sample==32, lcolor(black) lpattern(longdash) lwidth(medium)) ///
    (kdensity beta if sample==64, lcolor(purple) lpattern(dash)    lwidth(medium)) ///
    (kdensity beta if sample==100, lcolor(yellow) lpattern(solid)  lwidth(medium)), ///
    legend(order(1 "N = 4" 2 "N = 8" 3 "N = 10" 4 "N = 16" 5 "N = 32" 6 "N = 64" 7 "N = 100") region(lcolor(white))) ///
    xtitle("Beta Estimates") ///
    ytitle("Density") ///
    title("Distribution of beta estimates - Sample Size 4 to 100")

*Density graph to sizes up to 100 and less than 5000
twoway ///
    (kdensity beta if sample==128,   lcolor(blue)   lpattern(solid)    lwidth(medium)) ///
    (kdensity beta if sample==256,  lcolor(red)    lpattern(dash)     lwidth(medium)) ///
	(kdensity beta if sample==512, lcolor(brown)  lpattern(dash)      lwidth(medium)) ///
    (kdensity beta if sample==1000, lcolor(green)  lpattern(dot)      lwidth(medium)) ///
    (kdensity beta if sample==1024, lcolor(black) lpattern(longdash) lwidth(medium)) ///
    (kdensity beta if sample==2048, lcolor(purple) lpattern(dash)    lwidth(medium)) ///
    (kdensity beta if sample==4096, lcolor(yellow) lpattern(solid)  lwidth(medium)), ///
    legend(order(1 "N = 128" 2 "N = 256" 3 "N = 512" 4 "N = 1000" 5 "N = 1024" 6 "N = 2048" 7 "N = 4096") region(lcolor(white))) ///
    xtitle("Beta Estimates") ///
    ytitle("Density") ///
    title("Distribution of beta estimates - Sample Size 100 to 5000")

*Density graph to sizes up to 5000 until 1000000
twoway ///
    (kdensity beta if sample==8192,   lcolor(blue)   lpattern(solid)    lwidth(medium)) ///
    (kdensity beta if sample==10000,   lcolor(orange)   lpattern(dash)    lwidth(medium)) ///
    (kdensity beta if sample==16384,   lcolor(red)      lpattern(dash)    lwidth(medium)) ///
    (kdensity beta if sample==32768,   lcolor(brown)    lpattern(dash)    lwidth(medium)) ///
    (kdensity beta if sample==65536,   lcolor(green)    lpattern(dot)     lwidth(medium)) ///
    (kdensity beta if sample==131072,  lcolor(black)    lpattern(longdash) lwidth(medium)) ///
    (kdensity beta if sample==262144,  lcolor(purple)   lpattern(dash)    lwidth(medium)) ///
    (kdensity beta if sample==524288,  lcolor(yellow)   lpattern(solid)   lwidth(medium)) ///
    (kdensity beta if sample==100000,  lcolor(green)    lpattern(longdash) lwidth(medium)) ///
    (kdensity beta if sample==1048576, lcolor(grey)     lpattern(solid)   lwidth(medium)) ///
    (kdensity beta if sample==2097152, lcolor(blue)     lpattern(dot)     lwidth(medium)) ///
    (kdensity beta if sample==1000000, lcolor(red)      lpattern(dash)    lwidth(medium)) ///
    , legend(order(1 "N = 8192" 2 "N = 10000" 3 "N = 16384" 4 "N = 32768" 5 "N = 65536" 6 "N = 131072" 7 "N = 262144" 8 "N = 524288" 9 "N = 100000" 10 "N = 1048576" 11 "N = 2097152" 12 "N = 1000000") region(lcolor(white))) ///
      xtitle("Beta Estimates") ///
      ytitle("Density") ///
      title("Distribution of beta estimates - Sample Size 5000 to 1000000")


preserve
collapse (mean) SEM ci_lower ci_upper, by(sample)
gen ci_width = ci_upper - ci_lower

* Plot average SEM vs. sample size:
twoway (scatter SEM sample) (line SEM sample, sort), ///
    ytitle("Average Standard Error") xtitle("Sample Size") ///
    title("SEM Variation with Increasing Sample Size")
restore

preserve
collapse (mean) SEM ci_lower ci_upper, by(sample)
gen ci_width = ci_upper - ci_lower
* Plot average CI width vs. sample size:
twoway (scatter ci_width sample) (line ci_width sample, sort), ///
    ytitle("Average CI Width") xtitle("Sample Size") ///
    title("Confidence Interval Width vs. Sample Size")
restore












