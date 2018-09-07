
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

rename sexo sex, replace;
rename quintil_con_0 quin0, replace;
rename decil_con_0 dec0, replace;
rename rangos_edad eda, replace;
rename educacion edu, replace;
rename ent ent, replace;

gen d_0_100=.;
replace d_0_100=1 if cien_con_0>=1 & cien_con_0<=100;

gen d_0_99=.;
replace d_0_99=1 if cien_con_0>=1 & cien_con_0<=99;

global list labo rent cont no_cont don o_trans ing_mon;
global list_1 sex quin0 dec0 eda edu ent;
global list_2 d_0_100 d_0_99;

*Aquí se declaran las variables muestrales;
svyset upm [w= factor], vce(linearized) strata(est_dis) singleunit(centered);

foreach variable of global list  {;
foreach categoria of global list_1  {;
foreach cien of global list_2  {;

di in red "`variable'" ;
di in red "`categoria'" ;
svy: mean `variable' if edad>=65 & `cien'==1 , over(`categoria');
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;
matrix rename A prom_`variable'_`categoria'_`cien';

};
};
};


*Aquí se exporta la información a una tabla;
#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str variable=".";
gen str periodo=".";
gen str categoria=".";
gen str categoria2=".";
gen str cien=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;

local renglon=0;


foreach variable of global list  {;
foreach categoria of global list_1  {;
foreach cien of global list_2  {;

local tamano = colsof(prom_`variable'_`categoria'_`cien');

forvalues j=1(1)`tamano'{;

local renglon=`renglon'+1;
set obs `renglon';

replace pob_obj         = "P65ymas en Mexico" in `renglon';
replace u_analisis      = "Personas" in `renglon';
replace u_medida        = "Pesos mensuales" in `renglon';
replace variable        = "`variable'" in `renglon';
replace periodo         = "2016" in `renglon';
replace categoria       = "`categoria'_`j'" in `renglon';
replace categoria2       = "`categoria'" in `renglon';
replace cien            = "`cien'" in `renglon'; 
replace valor           = prom_`variable'_`categoria'_`cien'[1,`j']  in `renglon';
replace EE              = prom_`variable'_`categoria'_`cien'[2,`j']  in `renglon';
replace LI              = prom_`variable'_`categoria'_`cien'[3,`j']  in `renglon';
replace LS              = prom_`variable'_`categoria'_`cien'[4,`j']  in `renglon';
replace CV              = prom_`variable'_`categoria'_`cien'[5,`j']  in `renglon';

};
};
};
};

sort categoria categoria cien;
by categoria categoria cien: egen porcentaje = sum(valor);
replace porcentaje=(valor/porcentaje)*100/0.5;

gen orden=.;
replace orden=1 if variable=="labo";
replace orden=2 if variable=="rent";
replace orden=3 if variable=="cont";
replace orden=4 if variable=="no_cont";
replace orden=5 if variable=="don";
replace orden=6 if variable=="o_trans";
replace orden=7 if variable=="ing_mon";

sort categoria cien orden;

bysort categoria cien : gen cum_porcen = sum(porcentaje);


export delimited using "$bases\ingresos_por_catacterística.csv", replace;
