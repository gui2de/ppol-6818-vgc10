****Problem Set 1*****
*****PPOL-6818-01*****
***Vanessa Coronado***

***Question 1***
cd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data\q1_data"
global wd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"

global teacher "$wd/q1_data/teacher.dta"
global school "$wd/q1_data/school.dta"
global student "$wd/q1_data/student.dta"
global subject "$wd/q1_data/subject.dta"

use "$teacher", clear

*A)
merge m:1 school using "$school"
save "school-teacher.dta", replace

br
sort teacher
drop _merge 
save "school-teacher.dta", replace

merge m:1 subject using "$subject"
save "sch-teach-subj.dta", replace

br
sort teacher
drop _merge
save "sch-teach-subj.dta", replace

rename teacher primary_teacher
merge m:m primary_teacher using "$student"
save "Education.dta", replace

br
drop _merge
save "Education.dta", replace

rename primary_teacher teacher
sum attendance if loc=="South"
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  attendance |      1,181    177.4776    3.140854        158        180

What is the mean attendance of students at southern schools?
The attendance of students at southern schools is 177.4776.

*/

*B)
tab tested level
display 610/1379
/*
           |              level
    tested | Element..       High     Middle |     Total
-----------+---------------------------------+----------
         0 |     2,072        769        520 |     3,361 
         1 |         0        610        519 |     1,129 
-----------+---------------------------------+----------
     Total |     2,072      1,379      1,039 |     4,490 

Of all students in high school, what proportion of them have a primary teacher who teaches a tested subject?
The proportion of all students in high school who have a primary teacher who teaches a tested subject is 610/1379 which is basically 44.23%.

*/

*C)
sum gpa
/*

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         gpa |      4,490     3.60144      .23159   2.974333   3.769334

What is the mean gpa of all students in the district?
The mean gpa of all students in the district is 3.60144.

*/

*D)
egen mean_attendance = mean(attendance), by(school)
tab school if level=="Middle", summarize(mean_attendance)
/*

                                 |     Summary of mean_attendance
                          school |        Mean   Std. dev.       Freq.
---------------------------------+------------------------------------
      Joseph Darby Middle School |    177.4408           0         304
    Mahatma Ghandi Middle School |   177.33438           0         317
  Malala Yousafzai Middle School |   177.54785           0         418
---------------------------------+------------------------------------
                           Total |    177.4514   .08922495       1,039

What is the mean attendance of each middle school? 
There are 3 middle schools in the sample: Joseph, Mahatma and Malala and their mean attendance are 177.44, 177.33 and 177.54, respectively.
						   
*/


clear all


***Question 2***
cd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"
global wd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"
global village_pixel "$wd/q2_village_pixel.dta"
use "$village_pixel", clear

br
codebook

*A)
bysort pixel: egen max_payout = max(payout)
bysort pixel: egen min_payout = min(payout)
generate pixel_consistent = (max_payout == min_payout)

*B)
egen tag_pix_vill = tag(village pixel)
by village: egen count_pix_vill = total(tag_pix_vill)
generate pixel_village = (count_pix_vill > 1)

*C)
egen tag_payout_vill = tag(village payout)
by village: egen count_payout_vill = total(tag_payout_vill)

gen village_category = 0
replace village_category = 1 if count_pix_vill == 1
replace village_category = 2 if count_pix_vill > 1 & count_payout_vill == 1
list hhid if village_category == 2
replace village_category = 3 if count_pix_vill > 1 & count_payout_vill > 1
tab village_category, miss

clear all


***Question 3***
cd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"
global wd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"
global proposals "$wd/q3_proposal_review.dta"
use "$proposals", clear

rename Rewiewer1 Reviewer1
rename Review1Score Reviewer1Score
rename Reviewer1Score Score1
rename Reviewer2Score Score2
rename Reviewer3Score Score3

reshape long Reviewer Score, i(proposal_id) j(Reviewer_num)

bysort Reviewer: egen mean_score = mean(Score)
bysort Reviewer: egen sd_score = sd(Score)

gen stand_score = (Score - mean_score) / sd_score
gen stand_r1_score = .
replace stand_r1_score = stand_score if Reviewer_num == 1
gen stand_r2_score = .
replace stand_r2_score = stand_score if Reviewer_num == 2
gen stand_r3_score = .
replace stand_r3_score = stand_score if Reviewer_num == 3

egen average_stand_score = mean(stand_score), by(proposal_id)

save "q3_proposals_full.dta", replace
global proposalsfull "$wd/q3_proposals_full.dta"

preserve
keep proposal_id average_stand_score
bysort proposal_id: keep if _n == 1
save "aux_table.dta", replace
restore

global aux_table "$wd/aux_table.dta"
use "$aux_table", clear
sort average_stand_score
gen rank = _N - _n + 1
save "$aux_table", replace

use "$proposalsfull", clear
merge m:1 proposal_id using "$aux_table"
tab rank, summarize(average_stand_score)
drop _merge

reshape wide Reviewer Score mean_score sd_score stand_score stand_r1_score stand_r2_score stand_r3_score, i(proposal_id) j(Reviewer_num)

drop stand_r2_score1
drop stand_r3_score1
drop stand_r1_score2
drop stand_r3_score2
drop stand_r1_score3
drop stand_r2_score3
rename stand_r1_score1 stand_r1_score
rename stand_r2_score2 stand_r2_score
rename stand_r3_score3 stand_r3_score

save "q3_proposals_final.dta", replace

clear all


***Question 4***
cd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"

global wd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"
global excel_t21 "$wd/q4_Pakistan_district_table21.xlsx"

clear

*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135)
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring 
	display as error `i' 

	keep if regexm(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	keep in 1 
	rename TABLE21PAKISTANICITIZEN1 table21

	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' 
	save `table21', replace //saving the tempfile so that we don't lose any data
}

*load the tempfile
use `table21', clear
*fix column width issue to make it easier to with with it
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y  Z AA AB AC

order table, last
drop AC


//Convert string variables to numeri
foreach var of varlist B-AB {  
    destring `var', replace ignore(" ")  // Convert to numeric format ignoring empty spaces
}

ds, has(type string)
foreach var of varlist M N O Q U W {
    replace `var' = subinstr(`var', ",", "", .)  // Remove commas
    replace `var' = subinstr(`var', "$", "", .)  // Remove dollar signs or other characters
    replace `var' = regexr(`var', "[^0-9.]", "")  // Remove non-numeric characters except decimal point
}
destring M N O Q U W, replace

ds, has(type string)
destring U W, replace force

// Move data to the left in each row
local cols "B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB" 
local numvars: word count `cols'  // Count the number of variables

    forvalues i = 1/`=_N' {  // Iterating over each row
        local temp_values ""  // Start a temporary list for the row values
        
        foreach var of local cols {  
            local val = `var'[`i']  
            if !missing(`val') {  
                local temp_values "`temp_values' `val'"  // Store only non-empty values
            }  
        }
        
        // Replace row with left-aligned values
        local j = 1  
        foreach val of local temp_values {  
            local varname: word `j' of `cols'  
            replace `varname' = `val' in `i'  
            local ++j  
        }
        
        // Empty the remaining columns
        forvalues k = `j'/`numvars' {  
            local varname: word `k' of `cols'  
            replace `varname' = . in `i'  
        }
    }

// Delete empty variables
local vargroup N O P Q R S T U V W X Y Z AA AB
foreach var of local vargroup {
	drop `var'	
}

// Renaming the variables with the labels in the excel 
drop table21
rename B all_total_pop
rename C all_card_obtained
rename D all_card_not_obtained
rename E male_total_pop
rename F male_card_obtained
rename G male_card_not_obtained
rename H female_total_pop
rename I female_card_obtained
rename J female_card_not_obtained
rename K trans_total_pop
rename L trans_card_obtained
rename M trans_card_not_obtained

clear all


***Question 5***
cd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"
global wd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_03\04_assignment\01_data"
global education "$wd/q5_Tz_student_roster_html.dta"
use "$education", clear

display s[1]

gen school_name = substr(s, strpos(s, "ALBEHIJE PRIMARY SCHOOL"), 24)
gen school_code = substr(s, strpos(s, "PS0101114"), 9)
gen num_students = regexs(1) if regexm(s, "WALIOFANYA MTIHANI : ([0-9]+)")

split s, gen(part) parse(":")
list part3
display part3
gen school_avg = substr(part3, 1, 8)

local vargroup part1 part2 part3 part4 part5 part6 part7
foreach var of local vargroup {
	drop `var'	
}

gen student_group = 0
*replace student_group = 1 if num_students >=40

gen ranking_council = regexs(1) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KIHALMASHAURI: ([0-9]+) kati ya ([0-9]+)")
gen total_council_schools = regexs(2) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KIHALMASHAURI: ([0-9]+) kati ya ([0-9]+)")

gen cleaned_s = trim(itrim(regexr(s, "[^[:print:]]", "")))
gen match_cleaned = regexm(cleaned_s, "NAFASI YA SHULE KWENYE KUNDI LAKE KIMKOA : ([0-9]+) kati ya ([0-9]+)")
gen ranking_region = regexs(1) if match_cleaned
gen total_region_schools = regexs(2) if match_cleaned

drop cleaned_s
drop match_cleaned

gen ranking_national = regexs(1) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KITAIFA : ([0-9]+) kati ya ([0-9]+)")
gen total_national_schools = regexs(2) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KITAIFA : ([0-9]+) kati ya ([0-9]+)")

drop s

clear all



















































