*********************************************************************************
use "C:\Users\User\Desktop\Μαθήματα ΠαΠει_2018-19\Ειδικά Θέματα Μακροοικονομικής\STATA_files\Greece.dta", clear
*********************************************************************************
*We define the dataset "time series dataset"
tsset year1
*********************************************************************************

*********************************************************************************
**Analysis of variables
*********************************************************************************
/*GFCF: Gross Fixed Capital Formation
Generally: It shows something about how much of the new value added in the economy is invested rather than consumed.
Gross: it does not calculate any depraciation.
Fixed: It calculates only fixed assets and not financial assets or inventory stocks.

Trade: It adds the imports and exports of goods and services*/
*********************************************************************************

*********************************************************************************
**Descriptive statistics
*********************************************************************************
sum ggd1 gfcf1 fdi_infl1
sum ggd1 gfcf1 fdi_infl1, detail
tabulate ggd1
describe
*********************************************************************************

*********************************************************************************
**How to calculate the standard deviation of "ggd1"
*********************************************************************************
egen m_ggd1=mean(ggd1)
gen sq_dif=(ggd1-m_ggd1)^2
egen sum_sq_dif=total(sq_dif)
gen N_obs=_N
gen std_dev_ggd1=sqrt(sum_sq_dif/(_N-1))
*********************************************************************************

*********************************************************************************
**Correlation between variables
*********************************************************************************
pwcorr ggd1 gfcf1 gdp_per_cap1
*********************************************************************************

*********************************************************************************
***End-26/2/2019**********************************************************************
*********************************************************************************

*********************************************************************************
**Graphs
*********************************************************************************
//Time series line
tsline ggd1
tsline gdp_real1
tsline ggd1 gfcf1 
//Scatter plot
twoway (scatter fdi_infl1 year)
graph matrix ggd1 gfcf1 gdp_per_cap1
tsline ggd1 gfcf1
sum ggd1 gfcf1
//Two-scales graphs
twoway (tsline ggd1, yaxis(1)) (tsline gfcf1, yaxis(2))
*********************************************************************************

*********************************************************************************
**Plots
*********************************************************************************
***Boxplots
/*Definition: Box plots are a way of graphically showing groups of numerical data using their quartiles. 
Box plots may also have lines from the boxes indicating variability outside the upper and lower quartiles.
More details: 
a) The upper and lower end of the box is the 1st and 3rd quantile of this variable, 
b) the line inside the box is the median, 
c) the upper and the lower limit of the graph shows usually more than 90% or even 100% of all values of the variable*/

graph box ggd1
graph hbox ggd1
**An extended analysis in the panel dataset
*********************************************************************************

*********************************************************************************
**Histograms
*********************************************************************************
histogram ggd1
histogram ggd1, kdensity
**Density: If we find the frequency, then we divide it with the width of each bar.
histogram ggd1, kdensity normal
//Frequency
twoway histogram ggd1, freq 
twoway histogram gfcf1, freq
//Time distribution (bars)
twoway bar ggd1 year
//Time distribution (area)
twoway area gfcf1 year, sort
*********************************************************************************

*********************************************************************************
***End-1/3/2019**********************************************************************
*********************************************************************************

*********************************************************************************
///Basic commands
*********************************************************************************
**"rename" : ("rename" "old name" "new name"
rename exports1 exp1

**"order" : Put variables in any order you want
order year gdp_real1 gfcf1
order ggd1 gfcf1

**"sort" : It puts the obs of the specific variable in order beginning from the smaller. 
sort ggd1

**"keep" vs "drop" : They keep or drop certain variables.

**"label" : set label to a variable
label variable ggd1 "Gross Gobernment Debt in terms of GDP" 

**"list" :
list gfcf1 ggd1 exp1 in 1, 2, 3 /*Explore first 20 observations of the variables*/
list gfcf1 ggd1 if trade1<50

**Convert a string variable "standard_name" to a manageable one*/
tostring var1, replace /*numeric to string type*/
encode var1, gen (var2) /*string to long type (non-numeric)*/
destring var1, gen (var2) /*string to numeric type*/

**Obtain specific metrics
egen mean_ggd=mean(ggd1) /* it presents the mean value of the variable "ggd1"*/
egen median_ggd=median(ggd1) /* it presents the median value of the variable "ggd1"*/
egen min_ggd=min(ggd1) /*it presents the minimum value of the variable "ggd1"*/
egen max_ggd=max(ggd1) /*it presents the maximum value of the variable "ggd1"*/
gen sum_ggd=sum(ggd1) /*the cumulative sum of the values of the variable "ggd1" up to the current value*/
egen tot_ggd=total(ggd1) /*the cumulative sum of the values of the variable "ggd1"*/

//Create group identifiers
gen k1=_n /*It creates a list of consecutive numbers, one for each observation.*/
gen k2=_N /*It creates the sum of all observations for each line.*/

//Create new variables
**General command
gen lfpr=labor_force1/population1
**The "labor force participation rate (lfpr)" refers to the number of people available for work in terms of total population.
gen imports1=trade1-exports1

**Square root, square, product 
gen sq_exp=sqrt(exports1)
gen ggd_sq=ggd1^2
gen ggd_value=ggd1*gdp_nom1

**"describe"
describe ggd1 gfcf1 /*explore data types*/

**"codebook" : it presents statistical and other characteristics of specific variables 
codebook ggd1 gfcf1, all

**"if" (anaysis)

**"clear" : We turn-off our dataset.

**Dummy variable
//1st way
gen high_ggd=1 if ggd1>140
replace high_ggd=0 if high_ggd==.

gen med_ggd=1 if ggd1>100 & ggd1<120
replace med_ggd=0 if med_ggd==.
**Note: By using command "if" we can combine sets "σύνολα". We can apply operations, e.g. addition (+), subtraction (-) between them.

//2nd way
ta year1, gen(yr)

**"quietly": Run anything without reporting it
quietly ta year1, gen(yer2)

*********************************************************************************
***End-5/3/2019**********************************************************************
*********************************************************************************
