*********************************************************************************
use "C:\Users\User\Desktop\Μαθήματα ΠαΠει_2018-19\Ειδικά Θέματα Μακροοικονομικής\2019\proj_2019.dta", clear
*********************************************************************************

*We define the dataset
xtset country1 year1

*********************************************************************************
///General commands
*********************************************************************************
**As in Greece.do file. 

*********************************************************************************
///GRAPHS & PLOTS
*********************************************************************************
***xtline 
xtline gdp_per_cap1 if G7==1, overlay

**twoway
bysort year1: egen m_ggd=mean(ggd1)
bysort year1: egen m_gdppc=mean(gdp_per_cap1)
twoway (tsline m_ggd, yaxis(1)) (tsline m_gdppc, yaxis(2))
twoway (tsline m_ggd, scheme(economist) yaxis(1)) (tsline m_gdppc, yaxis(2)) /*different presentation*/
twoway (tsline m_ggd, scheme(economist) tline(2005) yaxis(1)) (tsline m_gdppc, yaxis(2)) /*Highlighting specific period of time*/

**Histograms
**As in Greece.do file. 

**Box-plots
/*Using multiple -over()- options*/
graph box ggd1 /*Box plot with outliers*/
graph box ggd1, nooutsides /*Box plot without outliers*/
graph box ggd1, nooutsides name(box1, replace) /*Box plot with a file name*/
graph box ggd1, over(G7) nooutsides name(box2, replace) /*Box plot with one split*/
graph box ggd1, over(G7) over(EU) nooutsides name(box3, replace) asy /*Box plot with two splits*/

tostring G7, gen (G7n1)
replace G7n1="G7" if G7==1
replace G7n1="non-G7" if G7==0
tostring EU, gen (EUn1)
replace EUn1="EU" if EU==1
replace EUn1="non-EU" if EU==0
graph box ggd1, over(G7n1) over(EUn1) nooutsides name(box4, replace) asy /*Box plot with two splits with different colours*/

*********************************************************************************
//Create new variables
*********************************************************************************
*growth rate
by country1: gen gr_gdp2=((gdp_real1-l.gdp_real1)/l.gdp_real1)*100
by country1: gen gr_gdp1=(ln(gdp_real1)-ln(l.gdp_real1))*100
by country1: gen dggd=d.ggd1

*********************************************************************************
*********************************************************************************
**Econometric view**
*********************************************************************************
*********************************************************************************

*********************************************************************************
//Problems with models
*********************************************************************************
/*We always follow the following order to test for problems in models, i.e. multicollinearity, autocorrelation, heteroskedasticity.*/
 
**Pooled OLS
by country1: gen gr_gdp11=(ln(gdp_real1)-ln(l.gdp_real1))*100
reg gr_gdp11 ggd1 fdi_infl1 gfcf1 ir_real1 

//Multicollinearity
/*Definition: the problem that arises from a strong correlation between one or more independent variables*/.

***How to detect multicollinearity?
***Graphically
twoway (scatter ggd1 fdi_infl1)
twoway (scatter ggd1 gfcf1)
twoway (scatter ggd1 ir_real1)
twoway (scatter fdi_infl1 gfcf1)
twoway (scatter fdi_infl1 ir_real1)
twoway (scatter gfcf1 ir_real1)
twoway (scatter trade1 exports1) /*multicollinearity*/

***Statistically
**1st way
pwcorr ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1, star(0.05) sig
**2nd way
reg gr_gdp11 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1
abar, lags(10)

vif
/* High VIF equals to high problem of multicollinearity
vif=1 (no correlation), 
1<vif<5 (moderate correlation), 
vif>5 (high correlation)*/

*How to correct multicollinearity?
/*Some times automatically from stata or we drop these variables that have high values of "vif".*/


//Autocorrelation
/*Definition: The problem of strong correlation between current and previous residuals (e.g. 1st order autocorrelation)*/
***How to detect autocorrelation?
***Graphically
reg gr_gdp11 l.gr_gdp11 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1
predict e1, res
twoway (scatter e1 l.e1)

***Statistically
**1st way (Arellano-Bond test)
reg gr_gdp11 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1
abar, lags(10)
/*Note: When "Prob > z" in the previous test is more than 0.05 then we do not have any problem of autocorrelation*/

**2nd way (Wooldridge test)
xtserial gr_gdp11 l.gr_gdp11 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1
/*When the "Prob > F" in the previous test is more than 0.05 then we do not have any problem of autocorrelation*/ 

***How to correct autocorrelation?
/*1st way: If we have a mild autocorrelation (i.e. a coef. in previous regression less than one), we use a new independent variable 
the lag of the dependent variable.*/
reg gr_gdp11 l.gr_gdp11 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1
gen lgr_gdp11=l.gr_gdp11
xtserial gr_gdp11 lgr_gdp11 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1

/*2nd way: If we have a strong autocorrelation we use first differences in all variables*/
by country1: gen dif_gr_gdp=d.gr_gdp1 
by country1: gen dif_debt=d.ggd1
by country1: gen dif_fdi_infl=d.fdi_infl1
by country1: gen dif_fdi_outfl=d.fdi_outfl1
by country1: gen dif_gfcf=d.gfcf1
by country1: gen dif_ir=d.ir_real1

reg dif_gr_gdp dif_debt dif_fdi_infl dif_fdi_outfl dif_gfcf dif_ir
abar, lags(10)
xtserial dif_gr_gdp dif_debt dif_fdi_infl dif_fdi_outfl dif_gfcf dif_ir

/*3rd way: We can apply an AR(1) model with fixed-effects*/
**We use the command "xtregar" which assumes that the model suffers from 1st order autocorrelation. This command finally runs a RE model.
xtregar gr_gdp1 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1
//We can also test if after correction still suffers from AR(1), by applying the following:
xtregar gr_gdp1 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1, lbi
/*The Baltagi-Wu LBI test shows a value in which if it is around 2 we do not have further problem with auto-correlation.*/
/*Problems: 
1) We can use after fixed-effects this command but we cannot test if problem of autocorrelation exists. The following just correct without
detecting the problem.
2) We cannot apply time fixed-effects.*/
xtregar gr_gdp1 ggd1 fdi_infl1 exports1 trade1 gfcf1 ir_real1,fe lbi
estimates store AR_1

//Heteroskedasticity
/*Definition: The problem of having unequal variance in your residuals.*/

**How to detect heteroskedasticity
*Graphically (dependent with independent variables)
reg gr_gdp11 ggd1 fdi_infl1 trade1 gfcf1 ir_real1
*It calculates the predicted value of dependent variable
predict grgdp_hat, xb
*It calculates the residuals
predict u1,res
*It computes the square of the residuals
by country1: gen u1_sq=u1^2

**Now we run scatters between the square of residuals and the predicted value of the dependent variable or independent variables
twoway (scatter u1_sq grgdp_hat)
twoway (scatter u1_sq ggd1)
twoway (scatter u1_sq fdi_infl1)

*Statistically
reg gr_gdp1 ggd1 fdi_infl1 trade1 gfcf1 ir_real1
estat hettest ggd1 fdi_infl1 trade1 gfcf1 ir_real1, mtest
/*If p-value is more than 0.05 then we have constant variance and we do not have heteroskedasticity.*/

*How to correct this problem
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, vce (robust)

**Compare baseline with robust results
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1
estimates store OLS
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, vce (robust)
estimates store WLS
estimates table OLS WLS, star stats(N F r2)

*********************************************************************************
//Individual effects
*********************************************************************************

//Pooled vs fixed-effects vs random effects
*Fixed-effects
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, fe
estimates store FE_estimator
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, fe vce (robust)
estimates store FE_estimator_robust

*Random effects
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, re
estimates store RE_estimator
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, re vce (robust)
estimates store RE_estimator_robust

estimates table FE_estimator FE_estimator_robust RE_estimator RE_estimator_robust, star stats(N F r2)

**Exporting results to a file (e.g. excel)
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1
outreg2 using C:\Users\User\Desktop\TableA1.xls, tstat dec(3) ctitle(OLS) nonotes  bracket addtext(Year effects, N, Country effects, N) label r2 replace
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, fe
outreg2 using C:\Users\User\Desktop\TableA1.xls, tstat dec(3) ctitle(FE) nonotes  bracket addtext(Year effects, N, Country effects, Y) label r2 append
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, re
outreg2 using C:\Users\User\Desktop\TableA1.xls, tstat dec(3) ctitle(RE) nonotes  bracket addtext(Year effects, N, Country effects, Y) label append

/*Note:
1. Our aim is to test graphically or statistically the existence of individual effects, i.e. heterogeneity among countries and years.
2. There two ways more to run fixed-effects estimation: 
xi: reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 i.country1
areg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, absorb(country1)
*/

//Graphical tests
**Country fixed-effects
bysort country1: egen gdp_mean2=mean(gr_gdp1) 
twoway scatter gr_gdp1 country if country1<15, msymbol(circle_hollow) || connected gdp_mean2 country if country1<15, msymbol(diamond) /*For the first 15 countries*/
**Year fixed-effects
bysort year: egen gdp_mean3=mean(gr_gdp1) 
twoway scatter gr_gdp year1 if country1<15, msymbol(circle_hollow) || connected gdp_mean3 year1 if country1<15, msymbol(diamond) || , xlabel(1993 (2) 2016)

/*Notes: 
1. If the red line is almost parallel to the horizontal axis, we do not deal with any individual effects problem.
2. All bubbles for each year or country, which are far away from the red line, are propably outliers. 
3. For each country or year, we could observe the distribution function, i.e. normal, bynomial (with tails). 
*/

//Statistical tests (firstly for fe ns re and then pooled vs re).

//Testing FE vs RE
hausman FE_estimator RE_estimator
/*Note: 
1. The null hypothesis is that the preferred model is random effects. So, if p-value<0.05, we reject the null hypothesis and we accept fixed-effects.
2. If we accept RE, then we continue by using the following test*/

//Testing Pooled vs RE
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 i.year1, re 
xttest0
**Note1: Breusch and Pagan LM test for random effects
**Note2: The null hypothesis is that preferred model is OLS. So, if p-value<0.05, we reject the null hypothesis and we accept random-effects. 



//Testing Pooled vs FE
/*It is not a statistical test rather it is the value of F-test distribution. In particular, if the p-value of F when we run for fe-estimation is 
less than 0.05, we prefer the fe estimation.*/

//Testing Pooled vs FE (for long panel datasets with more than 30 years)
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, fe 
xtcsd, pesaran abs
xttest2
**Note1: Breusch-Pagan LM test for fixed-effects
**Note2: The null hypothesis is that preferred model is OLS. So, if p-value<0.05, we reject the null hypothesis and we accept random-effects.
**Note3: Both tests are for high datasets and balanced.

//Testing for time-fixed effects
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 i.year1, fe
testparm i.year1
**Note: If the Prob>F is >0.05 we failed to reject the null hypothesis that the coefficients for all years are jointly equal to zero.
**Therefore, no time-fixed effects are needed in this case. 

//Robustness analysis
**We test for outliers and leverage.

**OUTLIERS
/*Definition: They are observations with large residuals. An observation whose dependent-variable value is unusual 
given its values on the predictor variables. An outlier may indicate a sample peculiarity or may indicate a data
entry error or other problem.*/ 

**LEVERAGE
/*Definition: An observation with an extreme value on a predictor variable. Leverage is a measure of how far 
an independent variable deviates from its mean.*/

**How to detect the problem??

//Graphical way
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1
gen id1=_n
lvr2plot, mlabel(id1)
lvr2plot, mlabel(year)
lvr2plot, mlabel(country1)
/*Notes: 
-The lines on the chart show the average values of leverage and the (normalized) residuals squared.
-Points above the horizontal line have higher-than-average leverage; 
-Points to the right of the vertical line have larger-than-average residuals.*/


//Statistical way
**Measure leverage
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1
predict lev, leverage
**display m=(2*k+2)/n, 
display (2*4+2)/2084
**where k:predictors and n:observations
**list gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 country1 lev if lev > m
list year country1 lev if lev>0.00479846 & !missing(lev)

**Measure abs(rstudent)
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1
predict r, rstudent
list year country1 if abs(r) > 2 & !missing(r)

**Measure Cook's distance
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1
predict d, cooksd
**list gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 country1 d if d > p
**where p=4/obs
display 4/2084
list gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 country1 d if d > 0.00191939 & !missing(d)

**Measure abs(dfits)
reg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1
predict dfit, dfits
**list gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 country1 dfits if abs(dfits) > g
**where g=2*sqrt(k/n)
**where k:predictors and n:observations
display 2*sqrt(4/2084)
list gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 country1 dfit if abs(dfit) > 0.08762159 & !missing(dfit)

**Measure abs(DFBETA)
dfbeta
**Note: STATA creates the following variables: DFggd1 DFfdi_infl1 DFgfcf1 DFir_real1
display 2/sqrt(2084)
list country1 _dfbeta_1 gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 if abs(_dfbeta_1)>0.0438108 & !missing(_dfbeta_1)
list country1 _dfbeta_2 gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 if abs(_dfbeta_2)>0.0438108 & !missing(_dfbeta_2)
list country1 _dfbeta_3 gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 if abs(_dfbeta_3)>0.0438108 & !missing(_dfbeta_3)
list country1 _dfbeta_4 gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1 if abs(_dfbeta_4)>0.0438108 & !missing(_dfbeta_4)

**To choose which one of all previous observations denotes an outlier, we just find the repeated obs in all previous tests.

*********************************************************************************
//Instrumental Variable estimation (IV)
*********************************************************************************
**Two Stages Least Squares (2SLS) 
xtreg gr_gdp1 ggd1 fdi_infl1 gfcf1 ir_real1, fe
predict ggd1_hat, xb
 
xtreg gr_gdp1 ggd1_hat fdi_infl1 gfcf1 ir_real1,fe

**Direct IV
ta year, gen(yr)

xtivreg2 gr_gdp1 gfcf1 fdi_infl1 ir_real1 (ggd1=l2.ggd1 l3.ggd1), fe endog(ggd1) robust
estimates store IV

estimates table AR_1 IV
/*Analysis of the tests.*/

**The underidentification test**
/*It applies a Kleibergen-Paap rk LM statistic, in which the null-hypothesis is that our
model is under-identified. If a model is not identified, we should add more independent
variables or we should reduce the parameters of estimation.*/

**The weak identification test**
/*It applies a Kleibergen-Paap rk Wald F statistic, in which the null hypothesis is that the
instruments used are weak. If the value of this test is more than all critical values of
Stock-Yogo weak ID test, then we do not deal with the problem of weak instruments.*/

**The instruments exogeneity test**
/*It applies a Hansen J-test for instruments exogeneity where the null hypothesis is that the
instruments are exogeneous.*/

**The IV estimation appropriateness**
/*It applies a Durbin-Wu-Hausman test which shows that the IV technique is not required
(null-hypothesis) or is appropriate.*/
