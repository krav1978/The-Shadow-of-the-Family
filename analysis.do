***Create initial family indicators based on IPUMS and Mosaic files (for each country we used a separate datafile)
***England 1901 (based on IPUMS) as an example. The same code was applied to all the other countries but the variables names in the original country specific datasets may slightly differ.
  **Remove not family households (group quarters)
drop if gq==20
  **Create indicators of VERTICAL EXTENSIONS (relateh refer to relationship to the household head)
	*Child (stepp child, adopted child, fostered child) 
gen child =1 if  relateh==301|  relateh==303|  relateh==305| relateh==401
replace  child= 0 if  child !=1
	*Adult child (20+)
gen adult_child =1 if  child==1 &  age >=20
replace  adult_child =0 if  adult_child !=1

	*Married son
gen child_mar_m =1 if sex ==1 & child==1 &  (marst==1|  marst==2)
replace  child_mar_m = 0 if  child_mar_m !=1

	*Vertical extensions in households headed by the father (adult or married children of the household head, children in law, grandchildren, great grandchildren)
gen vert_ext = 1 if child_mar_m==1 | adult_child==1 | relateh==901| relateh==902| relateh==903| relateh==904| relateh==1051
replace vert_ext = 0 if vert_ext !=1
	*Calculate a dummy variable whether the household has vertical extension
by serial, sort : egen float number_vertext= sum(vert_ext) 
gen vert_ext_dummy= 1 if number_vertext>0
replace vert_ext_dummy =0 if vert_ext_dummy !=1
	
	*Vertical extension in households headed by the son (parents or parents in law of the household head)
gen parents =1 if relateh ==501| relateh==502| relateh==601| relateh==602
replace  parents =0 if  parents !=1
	*All types of vertical extensions
gen all_3gener= parents + vert_ext
by serial, sort : egen hh_3gener=sum (all_3gener) if  relateh !=.
replace hh_3gener=1 if hh_3gener>1
 ***save the data file to your directory***
	*Calculate the proportion of vertically extended households headed by father at the UK level
collapse vert_ext_dummy, by (serial countyuk)
collapse vert_ext_dummy, by (countyuk)
rename vert_ext_dummy prop_vert_ext 
	
	*Calculate the proportion of all vertically extended families at the UK county level
collapse hh_3gener, by (serial countyuk)
collapse hh_3gener, by (countyuk)
rename hh_3gener prop_3gener
	
	*Proportion of households where the father lives together with his son but the household head is the son (the household includes "father" of the household head) 
	*Father of the household head
gen father=1 if relateh==501 & sex==1
replace father=0 if father !=1
by serial, sort : egen float hh_father = sum(father)if  relateh !=.
***save the data file to your directory***

	*Calculate the proportion of households where father lives together with his son but the household head is the son
collapse hh_father, by (serial countyuk)
collapse hh_father, by (countyuk)
rename hh_father prop_father

**FAMILY EXTENDEDDNESS indicators
	*Mean household size 
    *number of persons in the household
by serial, sort : egen float personhh= count(serial) if  relateh !=.
***save the data file to your directory***

collapse personhh, by (serial countyuk)
collapse personhh, by (countyuk)
rename personhh siztot
	
	*single households
gen sing = 1 if   personhh==1
replace sing = 0 if  personhh >1
				***save the data file to your directory***
collapse sing, by (serial countyuk)
collapse sing, by (countyuk)
  
  *mean household size without one person households  
gen fhh = personhh
replace fhh =. if sing==1
			***save the data file to your directory***
collapse fhh, by (serial countyuk)
collapse fhh, by (countyuk)
	
	*mean kin group size without one person households
gen non_relative = 1 if relate==5
replace non_relative=0 if non_relative !=1
by serial, sort : egen float number_nonrelat= sum(non_relative) if  relateh !=.
gen fhhsi = fhh - number_nonrelat 
	***save the data file to your directory***
collapse fhhsi, by (serial countyuk)
collapse fhhsi, by (countyuk)
	
	*mean household size without children
gen child14=1 if age<14
replace child14=0 if child14 !=1
by serial, sort : egen float number_children= sum(child14) if  relateh !=.
gen siztoc = personhh - number_children
	***save the data file to your directory***
collapse siztoc, by (serial countyuk)
collapse siztoc, by (countyuk)

	*Lateral extensions no vertical

*Calculate a dummy variable whether the household has lateral extension
gen lateral =1 if relateh ==701|relateh ==703|relateh == 704 |relateh ==801 |relateh ==1021 |relateh == 1022 |relateh == 1023 |relateh == 1024 |relateh == 1031 |relateh == 1032 |relateh == 1034 |relateh == 1035 |relateh == 1036 |relateh == 1037 |relateh == 1041 |relateh == 1043 |relateh == 1044
replace lateral =0 if lateral !=1
by serial, sort : egen float number_lateral= sum(lateral) if relateh !=. 
gen lateral_dummy =1 if number_lateral> 0
replace lateral_dummy=0 if lateral_dummy !=1

*lateral extensions without vertical
gen lanom=1 if lateral_dummy==1 & vert_ext_dummy==0
replace lanom=0 if lateral_novertext !=1
***save the data file to your directory***
collapse lanom, by (serial countyuk)
collapse lanom, by (countyuk)

**HOUSEHOLD COMPOSITION indicators

	*children adults ratio
gen adult =1 if age >=14
replace adult=0 if adult !=1
by serial, sort : egen float number_adult = sum(adult) if relateh !=.
gen chiad = number_children/number_adult
***save the data file to your directory***
collapse chiad, by (serial countyuk)
collapse chiad, by (countyuk)

**proportion of households with servants

gen servant=1 if relateh==1211
replace servant = 0 if servant !=1
by serial, sort : egen float number_serv= sum(servant) if relateh !=.
***save the data file to your directory***
collapse number_serv, by (serial countyuk)
gen serv_dummy=1 if number_serv>0
replace serv_dummy=0 if serv_dummy !=1
collapse serv_dummy, by ( countyuk)

 **GENDER HIERARCHY indicators
	*Proportion of never married women 20-29
gener females_20_29 = 1 if sex==2 & age>=20 &age<=29
gener females_20_29_never_married = 1 if sex==2 & age>=20 &age<=29 & marst==6
by countyuk, sort : egen float N_females_20_29 = total(females_20_29)
by countyuk, sort : egen float N_females_20_29_never_married = total( females_20_29_never_married)
gen women =  N_females_20_29_never_married /  N_females_20_29
***save the data file to your directory***
collapse women, by (countyuk)

***Other variables (proportion of married women 15-19, proportion of female household heads, proportion of wives older than husbands, proportion of young women living as non-kin) were borrowed from Gruber and Szoltysek’s (2016). 

 **GENERATIONAL HIERARCHY index (use the resulting file for subnational regions for a subset of countries)
	*ratio proportion of vertically extended households headed by the son (where the parent is listed as "father" of the household head)/proportion of vertically extended households headed by the father.
 gen prev_sonhead= prop_father/prop_vert_ext
 
	*Principal component from the percentage of all vertically extended households and prevalence of vertically extended households headed by son instead of father.
factor prev_sonhead prop_3gener, pcf
predict generat_h
	*adjust the index so that higher values mean more hiearchy
replace generat_h= -1*generat_h
  
  **GENDER HIERARCHY index
 factor  fhhh ybrid owife nonkin women, pcf
 predict gender_h


 ***Merge LiTS data with historical data
 use "C:\Users\user\Documents\shadow of the family\lits.dta", clear
 sort nomce
 merge m:1 nomce using "C:\Users\user\Documents\shadow of the family\regional level historical data.dta"
 
***REGRESSION ANALYSIS"

cd "C:\Users\user\Documents\òåíü ñåìüè\hlm\new hlm"

global controls_1 "age sex educ i.inc urban  i.chist"
global controls_2 "age sex educ i.inc urban dens cw4 i.chist "
global controls_3 "age sex educ i.inc urban siztot dens cw4 i.chist "
global controls_4 "age sex educ i.inc urban fhh  sing chiad dens cw4 i.chist "
global controls_5 "age sex educ i.inc urban chiad lanom dens cw4 i.chist"
global controls_6 "age sex educ i.inc urban siztoc  dens cw4 i.chist "
global controls_7 "age sex educ i.inc urban fhhsi sing chiad serv dens cw4 i.chist"



**OLS regressions of out-group trust on family indicators (TABLE 4)
regress outg generat_h $controls_1, robust cluster (nomce)
outreg2 using Table_ne123.xls, replace 
regress outg gender_h $controls_1, robust cluster (nomce)
outreg2 using Table_ne123.xls, append 
regress outg generat_h gender_h $controls_1, robust cluster (nomce)
outreg2 using Table_ne123.xls, append 
regress outg generat_h gender_h $controls_2, robust cluster (nomce)
outreg2 using Table_ne123.xls, append 
regress outg generat_h gender_h $controls_3, robust cluster (nomce)
outreg2 using Table_ne123.xls, append 
regress outg generat_h gender_h $controls_4, robust cluster (nomce)
outreg2 using Table_ne123.xls, append
regress outg generat_h gender_h $controls_5, robust cluster (nomce)
outreg2 using Table_ne123.xls, append 
regress outg generat_h gender_h $controls_6, robust cluster (nomce)
outreg2 using Table_ne123.xls, append 
regress outg generat_h gender_h $controls_7, robust cluster (nomce)
outreg2 using Table_ne123.xls, append

***Table 6: regression with generational index components instead of generational hierarchy index 
regress outg  prev_sonhead prop_3gener gender_h fhh $controls_2, robust cluster (nomce) 
outreg2 using Table_new1211.xls, replace 

***Table A6 in the Appendix, extended sample analysis 
global controls_1 "age sex educ i.inc urban  i.chist "
global controls_2 "age sex educ i.inc urban  dens cwi4 i.chist"

regress outg  women $controls_1, robust cluster (nomce) 
outreg2 using Table_new223.xls, replace
regress outg    women $controls_2, robust cluster (nomce) 
outreg2 using Table_new223.xls, append

***OLS regressions of out-group trust on family indicators controlled for geographical varibles.
global controls_1 "age sex educ i.inc urban dens cw4 caloric_ind i.chist"
global controls_2 "age sex educ i.inc urban dens cw4 ruggedness i.chist"
global controls_3 "age sex educ i.inc urban dens cw4 distance_river_dummy i.chist"
global controls_4 "age sex educ i.inc urban dens cw4 distance_sea_dummy i.chist"
global controls_5 "age sex educ i.inc urban dens cw4  huntgath_vs_agr i.chist"
global controls_6 "age sex educ i.inc urban dens cw4  church_exp i.chist"



regress outg  generat_h gender_h  fhh $controls_1, robust cluster (nomce)
outreg2 using Table_new345.xls, replace 
regress outg  generat_h gender_h fhh $controls_2, robust cluster (nomce)
outreg2 using Table_new345.xls, append
regress outg  generat_h gender_h fhh $controls_3, robust cluster (nomce)
outreg2 using Table_new345.xls, append
regress outg   generat_h gender_h fhh $controls_4, robust cluster (nomce)
outreg2 using Table_new345.xls, append
regress outg  generat_h gender_h fhh $controls_5, robust cluster (nomce)
outreg2 using Table_new345.xls, append
regress outg  generat_h gender_h fhh $controls_6, robust cluster (nomce)
outreg2 using Table_new345.xls, append



***Robustness check: OLS regressions of out-group trust on family indicators (Table A5 in the Appendix) where gender hierarchy index does not include female hh heads
cd "C:\Users\user\Documents\òåíü ñåìüè\hlm\new hlm"
global controls_1 "age sex educ i.inc urban  i.chist"
global controls_2 "age sex educ i.inc urban dens cw4 i.chist "
global controls_3 "age sex educ i.inc urban siztot dens cw4 i.chist "
global controls_4 "age sex educ i.inc urban fhh  sing chiad dens cw4 i.chist "
global controls_5 "age sex educ i.inc urban chiad lanom dens cw4 i.chist"
global controls_6 "age sex educ i.inc urban siztoc  dens cw4 i.chist "
global controls_7 "age sex educ i.inc urban fhhsi sing chiad serv dens cw4 i.chist"


 

regress outg generat_h $controls_1, robust cluster (nomce)
outreg2 using Table_new1.xls, replace 
regress outg sexhfactor_short $controls_1, robust cluster (nomce)
outreg2 using Table_new1.xls, append 
regress outg generat_h sexhfactor_short $controls_1, robust cluster (nomce)
outreg2 using Table_new1.xls, append 
regress outg generat_h sexhfactor_short $controls_2, robust cluster (nomce)
outreg2 using Table_new1.xls, append 
regress outg generat_h sexhfactor_short $controls_3, robust cluster (nomce)
outreg2 using Table_new1.xls, append 
regress outg generat_h sexhfactor_short $controls_4, robust cluster (nomce)
outreg2 using Table_new1.xls, append
regress outg generat_h sexhfactor_short $controls_5, robust cluster (nomce)
outreg2 using Table_new1.xls, append 
regress outg generat_h sexhfactor_short $controls_6, robust cluster (nomce)
outreg2 using Table_new1.xls, append 
regress outg generat_h sexhfactor_short $controls_7, robust cluster (nomce)
outreg2 using Table_new1.xls, append

