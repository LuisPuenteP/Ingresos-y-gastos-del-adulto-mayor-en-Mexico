#delimit;
clear all;
#delimit;
use "$bases\base_individual.dta", clear;

*Aquí se declaran las variables muestrales;
svyset upm [w= factor], vce(linearized) strata(est_dis) singleunit(centered);


global list_dummies

d_hombre
rangos_edad
educacion
serv_sal
edo_civil
clase_hog
tipo_viv
rururb
;

foreach variable of global list_dummies  {;
ta `variable', gen(`variable');
 
};

global list_variables 

d_hombre1	d_hombre2
rangos_edad1	rangos_edad2	rangos_edad3	rangos_edad4
educacion1	educacion2	educacion3	educacion4	educacion5	educacion6
serv_sal1	serv_sal2	serv_sal3	serv_sal4	serv_sal5	serv_sal6	serv_sal7
edo_civil1	edo_civil2	edo_civil3	edo_civil4
clase_hog1	clase_hog2	clase_hog3	clase_hog4	clase_hog5
tipo_viv1	tipo_viv2	tipo_viv3	
rururb1	rururb2
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

svy: total `variable' if edad>=65 & `categoria'==1;
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;

svy: mean `variable' if edad>=65 & `categoria'==1;
matrix B=r(table);
matrix A = A\B[1..2, 1...]\B[5..6, 1...] ;
estat cv;
matrix cv=r(cv);
matrix A=A\cv;

matrix rename A M_`variable'_`categoria';

};
};

#delimit;
gen d_hom_trab=0;
replace d_hom_trab=1 if d_hombre==1 & d_trabaja==1; 
gen d_hom_notrab=0;
replace d_hom_notrab=1 if d_hombre==1 & d_trabaja==0; 
gen d_muj_trab=0;
replace d_muj_trab=1 if d_hombre==0 & d_trabaja==1; 
gen d_muj_notrab=0;
replace d_muj_notrab=1 if d_hombre==0 & d_trabaja==0; 

global list_variables2 
d_hom_trab
d_hom_notrab
d_muj_trab
d_muj_notrab
;

foreach variable of global list_variables2  {;
foreach categoria of global list_tipo_pension  {;

forvalues i=0(1)1{;

svy: total `variable' if edad>=65 & `categoria'==1 & d_hombre==`i';
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;

svy: mean `variable' if edad>=65 & `categoria'==1 & d_hombre==`i';
matrix B=r(table);
matrix A = A\B[1..2, 1...]\B[5..6, 1...] ;
estat cv;
matrix cv=r(cv);
matrix A=A\cv;

matrix rename A M_`variable'_`categoria'_`i';

};
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
replace LI_p             = M_`variable'_`categoria'[8,1]  in `renglon';
replace LS_p              = M_`variable'_`categoria'[9,1]  in `renglon';
replace CV_p              = M_`variable'_`categoria'[10,1]  in `renglon';


};
};

foreach variable of global list_variables2  {;
foreach categoria of global list_tipo_pension  {;

forvalues i=0(1)1{;

local renglon=`renglon'+1;
set obs `renglon';

replace pob_obj         = "P65ymas en Mexico" in `renglon';
replace u_analisis      = "Personas" in `renglon';
replace u_medida        = "Personas" in `renglon';
replace periodo         = "2016" in `renglon';
replace variable        = "`variable'" in `renglon';
replace categoria       = "`categoria'" in `renglon';

replace valor_f           = M_`variable'_`categoria'_`i'[1,1]  in `renglon';
replace EE_f              = M_`variable'_`categoria'_`i'[2,1]  in `renglon';
replace LI_f              = M_`variable'_`categoria'_`i'[3,1]  in `renglon';
replace LS_f              = M_`variable'_`categoria'_`i'[4,1]  in `renglon';
replace CV_f              = M_`variable'_`categoria'_`i'[5,1]  in `renglon';

replace valor_p           = M_`variable'_`categoria'_`i'[6,1]  in `renglon';
replace EE_p              = M_`variable'_`categoria'_`i'[7,1]  in `renglon';
replace LI_p              = M_`variable'_`categoria'_`i'[8,1]  in `renglon';
replace LS_p              = M_`variable'_`categoria'_`i'[9,1]  in `renglon';
replace CV_p              = M_`variable'_`categoria'_`i'[10,1]  in `renglon';


};
};
};


export delimited using "$bases\cobertura pensionaria y características de los AM.csv", replace;
