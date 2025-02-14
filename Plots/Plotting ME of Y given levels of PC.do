********************************************************************************
***PLOTTING INTERACTIONS BETWEEN MEAN INCOME GROWTH AND private-sector credit*************
**********Here we plot marginal effect for X (Mean Income)**********************
version 14.2


log using "C:\Users\Yusuf Konyalicetin\Desktop\plotting_interaction_yPC.log", replace

*Setting Working Directory

cd "C:\Users\Yusuf Konyalicetin\Dropbox\Thesis\Data"

*Loading in my Data
use "C:\Users\Yusuf Konyalicetin\Dropbox\Thesis\Data\Stata_Thesis_Data_w_FD.dta", clear

*Encoding and setting data to panel
xtset Country_Code period

***************************************************************************************************************

set obs 10000

*regression model (4) with PC
reg dlnPov_190 dlnMI dlnGini lnPC c.dlnMI#c.lnPC, robust

*Grabbing elements of estimated coefficient vector b abd variance-covariance matrix V
matrix b=e(b)
matrix V=e(V)

*Grabbing coefficients of interest(b1) and (b4); see matrix with command "matrix list e(b)"
scalar b1=b[1,1]
scalar b4=b[1,4]

*Grabbing estimated variances for b1 and b4; display with "matrix list e(V)"
scalar varb1=V[1,1]
scalar varb4=V[4,4]

*Grabbing covariance for b1 and b4
scalar covb1b4=V[1,4]

*Creating and listing scalars equal to the coefficients, variances and covariance
scalar list b1 b4 varb1 varb4 covb1b4

********************Calculating Data that is necessary for top marginal plot**********************************

*Generating variable MVZ that takes on all values of logPC (-1.296461  to 4.978817) at each increment of 0.01
generate MVZ=((_n-4)/100)

*Maybe this is the reason why he put observations to 10000. However, here the last value is set where observations are bigger then 441
replace  MVZ=. if _n>500

*Calculating Marginal Effect of Mean Income on Poverty Reduction for the desired values of modifying variable lnPC
gen conbx=b1+b4*MVZ if _n<500

*Calculating Standard Error for marginal effect of Mean Income Growth on Poverty Reduction for desired values of modifying variable lnPC
gen consx=sqrt(varb1+varb4*(MVZ^2)+2*covb1b4*MVZ) ///if _n<450

*Creating two tailed Confidence Intervals at 95%

gen ax=1.96*consx

gen upperx=conbx+ax

gen lowerx=conbx-ax

*For the rug-plot, first number has to be determined by trial and error

gen where=-7

gen pipe = "|" if lnPC >= 0 & lnPC <= 5

egen tag_lnPC = tag(lnPC) if lnPC >= 0 & lnPC <= 5

*Creating horizontal line at 0 on vertical axis

gen yline=0

*Creating plot
graph twoway hist lnPC if lnPC >= 0 & lnPC <= 5, width(0.25) percent color(gs14) yaxis(2) 						/// if lnPC >= 0
		||	 scatter where lnPC if tag_lnPC,											///
			 plotr(m(b4)) ms(none) mlabcolor(gs5) mlabel(pipe) mlabpos(6) legend(off)	///
		||   line conbx   MVZ, clpattern(solid) clwidth(medium) clcolor(black) yaxis(1)	///
        ||   line upperx  MVZ, clpattern(dash) clwidth(thin) clcolor(black)				///
        ||   line lowerx  MVZ, clpattern(dash) clwidth(thin) clcolor(black)				///
        ||   line yline  MVZ,  clwidth(thin) clcolor(black) clpattern(solid)			///
	    ||   ,																			///
             xlabel(0 1 2 3 4 5, nogrid labsize(2))								///
		     ylabel(-8 -6 -4 -2 0 2, axis(1) nogrid labsize(2))				///
		     ylabel(0 2.5 5 7.5 10 12.5 15, axis(2) nogrid labsize(2))					///
	         yscale(noline alt)															///
		     yscale(noline alt axis(2))													///
             xscale(noline)																///
             legend(off)																///
             xtitle("Private-sector credit to GDP (log)", size(2.5)  )										///
             ytitle("Percentage of Observations"  , axis(2) size(2.5))					///
			 ytitle("Marginal Effect of Mean Income Growth", axis(1) size(2.5))			///
             xsca(titlegap(2))															///
             ysca(titlegap(2))															///
			 scheme(s2mono) graphregion(fcolor(white) ilcolor(white) lcolor(white))
	 
log close
