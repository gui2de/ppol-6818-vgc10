****Problem Set 2*****
*****PPOL-6818-01*****
***Vanessa Coronado***

global wd "C:\Users\vanes\Documents\Vanessa\Geogertown University\MIDP '26\2. Second Semester\Experimental Design\week_05\03_assignment\01_data"

if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818\week_05\03_assignment\01_data"
}

***Question 1***

global education "$wd/q1_psle_student_raw"

capture program drop studentleveldata
program define studentleveldata

gen school_name = regexs(1) if regexm(s, "([A-Z ]+) - PS[0-9]+")
gen school_code = substr(schoolcode, 5, 9)
gen num_exam_takers = regexs(1) if regexm(s, "WALIOFANYA MTIHANI : ([0-9]+)")
destring num_exam_takers, replace

split s, gen(part) parse(":")
list part3
display part3
gen school_avg = substr(part3, 1, 8)
destring school_avg, replace

local vargroup part1 part2 part3 part4 part5 part6 part7
foreach var of local vargroup {
	drop `var'	
}

gen student_group = 0
replace student_group = 1 if num_exam_takers >=40

gen ranking_council = regexs(1) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KIHALMASHAURI: ([0-9]+) kati ya ([0-9]+)")
destring ranking_council, replace

gen total_council_schools = regexs(2) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KIHALMASHAURI: ([0-9]+) kati ya ([0-9]+)")
destring total_council_schools, replace

gen ranking_region = regexs(1) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KIMKOA  : ([0-9]+) kati ya ([0-9]+)")
destring ranking_region, replace

gen total_region_schools = regexs(2) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KIMKOA  : ([0-9]+) kati ya ([0-9]+)")
destring total_region_schools, replace

gen ranking_national = regexs(1) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KITAIFA : ([0-9]+) kati ya ([0-9]+)")
destring ranking_national, replace

gen total_national_schools = regexs(2) if regexm(s, "NAFASI YA SHULE KWENYE KUNDI LAKE KITAIFA : ([0-9]+) kati ya ([0-9]+)")
destring total_national_schools, replace

gen s_reversed = reverse(s)
gen reversed_match = regexs(1) if regexm(s_reversed, ">DT/<>TNOF/<([0-9]+)-")
gen total_students = reverse(reversed_match), a(num_exam_takers)
destring total_students, replace
drop s_reversed
drop reversed_match

//Starting to build the student level data
expand total_students
sort school_name

gen blocks = subinstr(s, "</TR>", "|", .)
split blocks, parse("|") gen(section)

foreach var of varlist section* {
    replace `var' = ustrregexra(`var', "([A-Za-z])'([A-Za-z])", "")
}

//To extract students names each by each
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen student_name`i' = regexs(1) if regexm(section`i', "<P>([A-Z ]+)</FONT>")
}

gen student_name = ""
forvalues i = 6/`=`num'+5' {
    replace student_name = student_name`i' in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop student_name`i'
}

//To extract students candidate number each by each
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    replace section`i' = regexr(section`i', "[\r\n\t]+", "") // Remove line breaks and tabs
    replace section`i' = trim(section`i')                   // Remove extra spaces
}

forvalues i = 1/`=`num'+6' {
    gen candidate_num`i' = regexs(1) if regexm(section`i', ">([A-Za-z0-9\-]+)</FONT>")
}

gen candidate_num = ""
forvalues i = 6/`=`num'+5' {
    replace candidate_num = candidate_num`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop candidate_num`i'
}

// To extract students id each by each
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen id`i' = regexs(1) if regexm(section`i', "([0-9]{11})")
}

gen student_id = ""
forvalues i = 6/`=`num'+5' {
    replace student_id = id`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop id`i'
}

// To extract students gender each by each
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen gender`i' = regexs(1) if regexm(section`i', ">([MF])</FONT>")
}

gen student_gender = ""
forvalues i = 6/`=`num'+5' {
    replace student_gender = gender`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop gender`i'
}

//To extract students grades for Kiswahili course
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen kiswahili_grade`i' = regexs(1) if regexm(section`i', "Kiswahili - ([A-E])")
}

gen kiswahili = ""
forvalues i = 6/`=`num'+5' {
    replace kiswahili = kiswahili_grade`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop kiswahili_grade`i'
}

//To extract students grades for English course
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen english_grade`i' = regexs(1) if regexm(section`i', "English - ([A-E])")
}

gen english = ""
forvalues i = 6/`=`num'+5' {
    replace english = english_grade`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop english_grade`i'
}

//To extract students grades for Maarifa course
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen maarifa_grade`i' = regexs(1) if regexm(section`i', "Maarifa - ([A-E])")
}

gen maarifa = ""
forvalues i = 6/`=`num'+5' {
    replace maarifa = maarifa_grade`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop maarifa_grade`i'
}

//To extract students grades for Hisabati course
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen hisabati_grade`i' = regexs(1) if regexm(section`i', "Hisabati - ([A-E])")
}

gen hisabati = ""
forvalues i = 6/`=`num'+5' {
    replace hisabati = hisabati_grade`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop hisabati_grade`i'
}

//To extract students grades for Science course
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen science_grade`i' = regexs(1) if regexm(section`i', "Science - ([A-E])")
}

gen science = ""
forvalues i = 6/`=`num'+5' {
    replace science = science_grade`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop science_grade`i'
}

//To extract students grades for Uraia course
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen uraia_grade`i' = regexs(1) if regexm(section`i', "Uraia - ([A-E])")
}

gen uraia = ""
forvalues i = 6/`=`num'+5' {
    replace uraia = uraia_grade`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop uraia_grade`i'
}

//To extract students grades for Average Grade
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    gen average_grade`i' = regexs(1) if regexm(section`i', "Average Grade - ([A-E])")
}

gen average_grade = ""
forvalues i = 6/`=`num'+5' {
    replace average_grade = average_grade`i'[1] in `=`i'-5'
}

forvalues i = 1/`=`num'+6' {
    drop average_grade`i'
}

//Eliminating the auxiliar columns
sum total_students
local num r(mean)
display `num'
display `=`num'+6'
forvalues i = 1/`=`num'+6' {
    drop section`i'
}

drop blocks
drop s
drop schoolcode

end

tempfile tanzania
clear
save `tanzania', replace emptyok

forvalues i = 1/138 {
	use "$education", clear
    keep in `i'
    studentleveldata
    append using `tanzania'
    save `tanzania', replace
}


***Question 2***
clear all

global density "$wd/q2_CIV_populationdensity"
global Cotedivoire "$wd/q2_CIV_Section_0"


import excel "$density", sheet("Population density") firstrow clear
br

gen district = ""
gen region = ""
gen department = ""
gen commune = ""

replace district = NOMCIRCONSCRIPTION if regexm(NOMCIRCONSCRIPTION, "(?i)DISTRICT")
replace region = NOMCIRCONSCRIPTION if regexm(NOMCIRCONSCRIPTION, "(?i)REGION")
replace department = NOMCIRCONSCRIPTION if regexm(NOMCIRCONSCRIPTION, "(?i)DEPARTEMENT")
replace commune = NOMCIRCONSCRIPTION if district == "" & region == "" & department == ""


replace department = department[_n-1] if department == "" & _n > 1 & district == "" & region == ""
replace region = region[_n-1] if region == "" & _n > 1 & district == ""
replace district = district[_n-1] if district == "" & _n > 1

bysort commune (commune): gen counter = _N
list commune counter if counter > 1 & counter != 153

rename commune commune_first
gen commune = ""
replace commune = commune_first + " " + substr(department, 13, 20) if counter > 1 & counter != 153 
replace commune = commune_first if counter == 1
rename commune commune_lc
gen commune = lower(commune_lc)

drop if counter == 153
drop counter
drop commune_first
drop commune_lc

save "$wd\density.dta", replace 

global density2 "$wd/density"

use "$Cotedivoire", clear
br

decode b07_souspref, gen(commune)


tempfile master
save `master'
joinby commune using "$density2", unmatched(using)
tab _merge


***Question 3***
clear all
global gps "$wd/q3_GPS Data"
use "$gps", clear

/*
tempfile households
save `households', replace

geonear id latitude longitude using `households', n(id latitude longitude) ignoreself wide gen(nr_dist) nearcount(5)

drop age
drop female
rename nr_dist1 id1
rename nr_dist2 id2
rename nr_dist3 id3
rename nr_dist4 id4
rename nr_dist5 id5
rename km_to_nr_dist1 km1
rename km_to_nr_dist2 km2
rename km_to_nr_dist3 km3
rename km_to_nr_dist4 km4
rename km_to_nr_dist5 km5

order latitude longitude id id2 id3 id4 id5 km1 km2 km3 km4 km5

rename id id_0

reshape long id km , i(id_0) j(id_num)

bysort id_0: egen sum_km = total(km)


*/


//In the code which is commented before I created for each household its five nearest neighbors with their respective distances. Therefore, in that new dataset, there exists an optimal allocation of enumerators based on mapping the 5 nearest neighbors of each household. The only part I could not compute was finding those specific 19 optimal groups. 


//Thus, I decided to do this alternative. I created a cross database of each household against all other households and found the geo.distance for each pair. Then, for each household, I ordered by distance and, then I create a enumerator_id that is based on lower sum of the distances. This can be seen in the code below: 

preserve
    rename latitude lat1
    rename longitude lon1
	rename id id_using
    tempfile households
    save `households'
restore

cross using `households'
drop if id == id_using
drop if id > id_using

geodist latitude longitude lat1 lon1, gen(distance)
*duplicates tag distance, generate(duplicate)
save "$wd\lat_lon.dta", replace
global latlon "$wd/lat_lon.dta"

tempfile enumerators
clear
save `enumerators', replace emptyok

forvalues i = 655/760 {
use "$latlon", clear
keep if id == `i'
sort distance
gen index = .
local j = 761-`i'

replace index = `j' in 1/5
drop if index == .
append using `enumerators'
save `enumerators', replace
}

bysort index: egen sum_distance = total(distance)
sort sum_distance	
egen enumerator = group(sum_distance)

drop if enumerator > 19




***Question 4***
clear all
global election "$wd/q4_Tz_election_2010_raw"
import excel "$election", sheet("Sheet1") firstrow clear
br

drop in 1/3
rename THEUNITEDREPUBLICOFTANZANIA region
rename B district
rename C costituency
rename D ward
rename E candidate_name
gen sex = F if F != ""
replace sex = G if sex == ""
drop F
drop G
rename H political_party
rename I votes
drop J
drop K 
drop in 2
drop in 1

replace ward = ward[_n-1] if ward == "" & _n > 1 & costituency == "" & district == "" & region == ""
replace costituency = costituency[_n-1] if costituency == "" & _n > 1 & district == "" & region == ""
replace district = district[_n-1] if district == "" & _n > 1 & region == ""
replace region = region[_n-1] if region == ""
replace votes = "" if votes == "UN OPPOSSED"
replace votes = "." if votes == ""

destring votes, replace force

sort ward
bysort ward: egen votes_ward = total(votes)

bysort ward (candidate_name): egen total_cand = count(candidate_name)

gen id_ward = _n

drop candidate_name
drop sex

replace political_party = "NCCRMAGEUZI" if political_party == "NCCR-MAGEUZI"
replace political_party = "APPTMAENDELEO" if political_party == "APPT - MAENDELEO"
replace political_party = "JAHAZIASILIA" if political_party == "JAHAZI ASILIA"

encode political_party, gen(pparty_num)
label list pparty_num

gen ward_nospace = subinstr(ward, " ", "", .)
replace ward_nospace = subinstr(ward, "-", "", .)
replace ward_nospace = subinstr(ward, "/", "", .)
replace ward_nospace = subinstr(ward, "-", "", .)
replace ward_nospace = subinstr(ward, "/", "", .)
replace ward_nospace = subinstr(ward, "'", "", .)

encode ward_nospace, gen(ward_num)
label list ward_num

save "$wd\votes.dta", replace

global votes "$wd/votes"
capture program drop electiondata
program define electiondata   
   
   levelsof political_party, local(parties)
   scalar j = 1
   
   foreach pp in `parties' {
   gen votes_`pp' = votes[j]
   scalar j = j +1
	  
    }
end

tempfile elections
clear
save `elections', replace emptyok

use "$votes", clear
levelsof ward_num, local(www)
forvalues i = 1/3111 {
	use "$votes", clear
    keep if ward_num == `i'
    electiondata
	keep in 1 
    drop political_party
    drop votes
    drop id_ward

    append using `elections'
    save `elections', replace
}

sort ward
drop pparty_num
drop ward_nospace
drop ward_num

***Question 5***
clear all
global schools "$wd/q5_psle_2020_data"
global locations "$wd/q5_school_location"

use "$locations", clear
gen school_name = School + " - " + NECTACentreNo, a(School)
rename NECTACentreNo school_code
rename School school
rename Ward ward
duplicates drop school_code, force

save "$wd\schoolward.dta", replace
global schoolward "$wd/schoolward"


use "$schools", clear
gen school_name = substr(schoolname, 1, strpos(schoolname, " ") - 1), a(schoolname)
gen region = lower(region_name), a(region_name)
gen district = lower(district_name), a(district_name)
gen schoolname2 = substr(schoolname, 1, strlen(schoolname) - 2), a(schoolname)
gen school_code = substr(schoolname2, -9, .), a(schoolname2)

drop schoolname2
drop region_name
drop district_name

rename school_name school
rename schoolname school_name

save "$wd\psle.dta", replace
global psle "$wd/psle"

merge 1:1 school_code using "$schoolward"

keep if _merge == 3

keep region district school_name school_code school school_code_address region_code district_code ward serial


































