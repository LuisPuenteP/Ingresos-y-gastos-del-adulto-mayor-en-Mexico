#delimit;
clear all;
#delimit;
use "$bases\base_individual.dta", clear;

rename laboral labo, replace;
rename rentas rent, replace;
rename contributivas cont, replace;
rename no_contributivas no_cont, replace;
rename donativos_otras_fam don, replace;
rename otras_transfer o_trans, replace;
*rename ingreso_mon ing_mon, replace;


gen d_0_100=.;
replace d_0_100=1 if cien_con_0>=1 & cien_con_0<=100;

gen d_0_99=.;
replace d_0_99=1 if cien_con_0>=1 & cien_con_0<=99;

global list_1 labo rent cont no_cont don o_trans ing_mon;
global list_2 d_0_100 d_0_99;
global list_3 d_contributivas d_no_contributivas d_pension d_sin_pension unos;

*Aquí se declaran las variables muestrales;
svyset upm [w= factor], vce(linearized) strata(est_dis) singleunit(centered);

local i=0;

foreach variable of global list_1  {;
foreach cien of global list_2  {;
foreach condicion of global list_3  {;
local i=`i'+1;
di in red "`variable'" ;
di in red "`cien'" ;
di in red "`condicion'" ;
di in red "`i'";

svy: mean `variable' if edad>=65 & `cien'==1  & `condicion'==1 ;
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;
matrix rename A prom_`variable'_`cien'_`i';

};
local i=0;
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
gen str cien=".";
gen str condicion=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;

local renglon=0;
local i=0;

foreach variable of global list_1  {;
foreach cien of global list_2  {;
foreach condicion of global list_3  {;
local i=`i'+1;
local renglon=`renglon'+1;
set obs `renglon';

replace pob_obj         = "P65ymas en Mexico" in `renglon';
replace u_analisis      = "Personas" in `renglon';
replace u_medida        = "Pesos mensuales" in `renglon';
replace periodo         = "2016" in `renglon';
replace variable        = "`variable'" in `renglon';
replace cien            = "`cien'" in `renglon'; 
replace condicion       = "`condicion'" in `renglon';
replace valor           = prom_`variable'_`cien'_`i'[1,1]  in `renglon';
replace EE              = prom_`variable'_`cien'_`i'[2,1]  in `renglon';
replace LI              = prom_`variable'_`cien'_`i'[3,1]  in `renglon';
replace LS              = prom_`variable'_`cien'_`i'[4,1]  in `renglon';
replace CV              = prom_`variable'_`cien'_`i'[5,1]  in `renglon';

};
local i=0;
};
};


sort condicion cien;
by condicion cien: egen porcentaje = sum(valor);
replace porcentaje=(valor/porcentaje)*100/0.5;

gen orden=.;
replace orden=1 if variable=="labo";
replace orden=2 if variable=="rent";
replace orden=3 if variable=="cont";
replace orden=4 if variable=="no_cont";
replace orden=5 if variable=="don";
replace orden=6 if variable=="o_trans";
replace orden=7 if variable=="ing_mon";

sort condicion cien orden;

bysort condicion cien : gen cum_porcen = sum(porcentaje);


export delimited using "$bases\ingresos_por_catacterística_pensión.csv", replace;
