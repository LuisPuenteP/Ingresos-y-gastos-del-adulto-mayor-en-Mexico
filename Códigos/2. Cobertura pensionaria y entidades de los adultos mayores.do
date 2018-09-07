#delimit;
clear all;
#delimit;
use "$bases\base_individual.dta", clear;

*Aquí se declaran las variables muestrales;
svyset upm [w= factor], vce(linearized) strata(est_dis) singleunit(centered);


ta ent, gen(ent);


global list_variables 

ent1 ent2 ent3 ent4 ent5
 ent6
 ent7
 ent8
 ent9
 ent10
 ent11
 ent12
 ent13
 ent14
 ent15
 ent16
 ent17
 ent18
 ent19
 ent20
 ent21
 ent22
 ent23
 ent24
 ent25
 ent26
 ent27
 ent28
 ent29
 ent30
 ent31
 ent32
;

rename d_no_contributivas d_no_contri, replace;
rename d_sin_pension d_sin_pen, replace;

global list_tipo_pension 
d_contributivas
d_no_contri
d_pension
d_sin_pen
unos
;


foreach variable of global list_variables  {;
foreach categoria of global list_tipo_pension  {;

svy: total `categoria' if edad>=65 & `variable'==1;
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;

svy: mean `categoria' if edad>=65 & `variable'==1;
matrix B=r(table);
matrix A = A\B[1..2, 1...]\B[5..6, 1...] ;
estat cv;
matrix cv=r(cv);
matrix A=A\cv;

matrix rename A M_`variable'_`categoria';

};
};



*Aquí se exporta la información a una tabla;
#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str periodo=".";
gen str variable=".";
gen str categoria=".";

gen double valor_f=.;
gen double EE_f=.;
gen double LI_f=.;
gen double LS_f=.;
gen double CV_f=.;

gen double valor_p=.;
gen double EE_p=.;
gen double LI_p=.;
gen double LS_p=.;
gen double CV_p=.;

local renglon=0;


foreach variable of global list_variables  {;
foreach categoria of global list_tipo_pension  {;

local renglon=`renglon'+1;
set obs `renglon';

replace pob_obj         = "P65ymas en Mexico" in `renglon';
replace u_analisis      = "Personas" in `renglon';
replace u_medida        = "Personas" in `renglon';
replace periodo         = "2016" in `renglon';
replace variable        = "`variable'" in `renglon';
replace categoria       = "`categoria'" in `renglon';

replace valor_f           = M_`variable'_`categoria'[1,1]  in `renglon';
replace EE_f              = M_`variable'_`categoria'[2,1]  in `renglon';
replace LI_f              = M_`variable'_`categoria'[3,1]  in `renglon';
replace LS_f              = M_`variable'_`categoria'[4,1]  in `renglon';
replace CV_f              = M_`variable'_`categoria'[5,1]  in `renglon';

replace valor_p           = M_`variable'_`categoria'[6,1]  in `renglon';
replace EE_p              = M_`variable'_`categoria'[7,1]  in `renglon';
replace LI_p              = M_`variable'_`categoria'[8,1]  in `renglon';
replace LS_p              = M_`variable'_`categoria'[9,1]  in `renglon';
replace CV_p              = M_`variable'_`categoria'[10,1]  in `renglon';


};
};


export delimited using "$bases\cobertura pensionaria y entidad de los AM.csv", replace;
