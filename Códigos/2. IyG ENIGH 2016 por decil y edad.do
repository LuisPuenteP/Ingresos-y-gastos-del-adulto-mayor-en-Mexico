
#delimit;
clear all;
cap clear;
cap log close;
scalar drop _all;
set mem 400m;
set more off;

use "D:\ENIGH\bases\base_final2016.dta", clear;
keep if numren=="01";

merge 1:1 folioviv foliohog using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\base_hogar.dta";

**************************************************************;
*Generación de variable de composición de los hogares por edad;
*Adultos mayores segmentado en 3 grupos
**************************************************************;
gen edad_hog=0;
replace edad_hog=1 if g1_edad_1==1; 
replace edad_hog=2 if g1_edad_2==1;
replace edad_hog=3 if g1_edad_3==1;
replace edad_hog=4 if g1_edad_4==1;
replace edad_hog=5 if g1_edad_5==1;
* Nos saltamos g1_edad_6 para dejar únicamente a los;
replace edad_hog=6 if g1_edad_7==1;
replace edad_hog=7 if g1_edad_8==1;
replace edad_hog=8 if g1_edad_9==1;

label var edad_hog "Composición de los hogares por edad";
label define edad_hog 0 "Otra"
				      1 "2 adultos"
					  2 "2 adultos + 1 0-5 años"
					  3 "2 adultos + 1 6-12 años"
					  4 "2 adultos + 1 13-18 años"
					  5 "3 adultos"				  
					  6 "2 adultos + 1 65-74 años"
					  7 "2 adultos + 1 75-84 años"
					  8 "2 adultos + 1 85 y más años"
					  ; 
label value	edad_hog edad_hog;

**************************************************************;
*Generación de variable de composición de los hogares por edad;
*Adultos mayores en 1 solo grupo;
**************************************************************;
gen edad_hog2=0;
replace edad_hog2=1 if g1_edad_1==1; 
replace edad_hog2=2 if g1_edad_2==1;
replace edad_hog2=3 if g1_edad_3==1;
replace edad_hog2=4 if g1_edad_4==1;
replace edad_hog2=5 if g1_edad_5==1;
replace edad_hog2=6 if g1_edad_6==1;

label var edad_hog2 "Composición de los hogares por edad";
label define edad_hog2 0 "Otra"
				      1 "2 adultos"
					  2 "2 adultos + 1 0-5 años"
					  3 "2 adultos + 1 6-12 años"
					  4 "2 adultos + 1 13-18 años"
					  5 "3 adultos"				  
					  6 "2 adultos + 1 am"
					  ; 
label value	edad_hog2 edad_hog2;

*Generación de variable decil de los hogares (apartir de ictpc con escalas de equivalencia de Santana(2009));

xtile decil =ictpc [w=factor], nq(10);
xtile quintil =ictpc [w=factor], nq(5);

save "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\IyG ENIGH 2016 por decil y edad.dta", replace;

************************************************************************************************************************;
*************************************Caso 1: deciles y adultos mayores segmentado en 3 grupos***************************;
************************************************************************************************************************;
#delimit;
clear all;
cap clear;
cap log close;
scalar drop _all;
set mem 400m;
set more off;


use "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\IyG ENIGH 2016 por decil y edad.dta", clear;

svyset upm [w= factor] , vce(linearized) strata(est_dis) singleunit(centered);

*Aquí se generan 80 dummies para cada una de las combinaciones de deciles (10) y composiciones de hogares (8);


forvalues edad_hog= 1(1)8 {;

forvalues decil= 1(1)10 {;

gen d_`edad_hog'_`decil'=0;
replace d_`edad_hog'_`decil'=1 if decil==`decil' & edad_hog==`edad_hog';

};
};


*Aquí se realizan las estimaciones de frecuencia para cada una de las 80 combinaciones ;


forvalues edad_hog= 1(1)8 {;

forvalues decil= 1(1)10 {;

svy: total d_`edad_hog'_`decil';
matrix A=r(table);
matrix A = A[1..2, 1]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;
matrix rename A M_d_`edad_hog'_`decil';

};
};


*********************************************;
*Aquí se exporta la información a una tabla;

#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str decil=".";
gen str edades_en_hog=".";
gen str periodo=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;

local renglon=0;


forvalues edad_hog= 1(1)8 {;

forvalues decil= 1(1)10 {;

local renglon=`renglon'+1;

set obs `renglon';

replace pob_obj         = "Hogares en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Frecuencia de hogares" in `renglon';
replace decil           = "`decil'" in `renglon';
replace edades_en_hog   = "`edad_hog'" in `renglon';
replace periodo         = "2016" in `renglon';
replace valor           = M_d_`edad_hog'_`decil'[1,1]  in `renglon';
replace EE              = M_d_`edad_hog'_`decil'[2,1]  in `renglon';
replace LI              = M_d_`edad_hog'_`decil'[3,1]  in `renglon';
replace LS              = M_d_`edad_hog'_`decil'[4,1]  in `renglon';
replace CV              = M_d_`edad_hog'_`decil'[5,1]  in `renglon';

};
};

export delimited using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\Frecuencia_gastos_decil_edad_3am.csv", replace;



************************************************************************************************************************;
*************************************Caso 2: deciles y adultos mayores en 1 grupo***************************************;
************************************************************************************************************************;

#delimit;
clear all;
cap clear;
cap log close;
scalar drop _all;
set mem 400m;
set more off;

use "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\IyG ENIGH 2016 por decil y edad.dta", clear;

svyset upm [w= factor] , vce(linearized) strata(est_dis) singleunit(centered);

*Aquí se generan 60 dummies para cada una de las combinaciones de deciles (10) y composiciones de hogares (6);

forvalues edad_hog2= 1(1)6 {;

forvalues decil= 1(1)10 {;

gen d_`edad_hog2'_`decil'=0;
replace d_`edad_hog2'_`decil'=1 if decil==`decil' & edad_hog2==`edad_hog2';

};
};


*Aquí se realizan las estimaciones de frecuencia para cada una de las 60 combinaciones ;

forvalues edad_hog2= 1(1)6 {;

forvalues decil= 1(1)10 {;

svy: total d_`edad_hog2'_`decil';
matrix A=r(table);
matrix A = A[1..2, 1]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;
matrix rename A M_d_`edad_hog2'_`decil';

};
};


*********************************************;
*Aquí se exporta la información a una tabla;

#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str decil=".";
gen str edades_en_hog=".";
gen str periodo=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;

local renglon=0;


forvalues edad_hog2= 1(1)6 {;

forvalues decil= 1(1)10 {;

local renglon=`renglon'+1;

set obs `renglon';

replace pob_obj         = "Hogares en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Frecuencia de hogares" in `renglon';
replace decil           = "`decil'" in `renglon';
replace edades_en_hog   = "`edad_hog2'" in `renglon';
replace periodo         = "2016" in `renglon';
replace valor           = M_d_`edad_hog2'_`decil'[1,1]  in `renglon';
replace EE              = M_d_`edad_hog2'_`decil'[2,1]  in `renglon';
replace LI              = M_d_`edad_hog2'_`decil'[3,1]  in `renglon';
replace LS              = M_d_`edad_hog2'_`decil'[4,1]  in `renglon';
replace CV              = M_d_`edad_hog2'_`decil'[5,1]  in `renglon';

};
};


export delimited using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\Frecuencia_gastos_decil_edad_1am.csv", replace;


************************************************************************************************************************;
*************************************Caso 3: quintiles y adultos mayores segmentado en 3 grupos*************************;
************************************************************************************************************************;

#delimit;
clear all;
cap clear;
cap log close;
scalar drop _all;
set mem 400m;
set more off;

use "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\IyG ENIGH 2016 por decil y edad.dta", clear;

svyset upm [w= factor] , vce(linearized) strata(est_dis) singleunit(centered);


*Aquí se generan 40 dummies para cada una de las combinaciones de quintiles (5) y composiciones de hogares (8);


forvalues edad_hog= 1(1)8 {;

forvalues quintil= 1(1)5 {;

gen d_`edad_hog'_`quintil'=0;
replace d_`edad_hog'_`quintil'=1 if quintil==`quintil' & edad_hog==`edad_hog';

};
};

*Aquí se realizan las estimaciones de frecuencia para cada una de las 40 combinaciones ;

forvalues edad_hog= 1(1)8 {;

forvalues quintil= 1(1)5 {;

svy: total d_`edad_hog'_`quintil';
matrix A=r(table);
matrix A = A[1..2, 1]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;
matrix rename A M_d_`edad_hog'_`quintil';

};
};


*********************************************;
*Aquí se exporta la información a una tabla;

#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str quintil=".";
gen str edades_en_hog=".";
gen str periodo=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;

local renglon=0;


forvalues edad_hog= 1(1)8 {;

forvalues quintil= 1(1)5 {;

local renglon=`renglon'+1;

set obs `renglon';

replace pob_obj         = "Hogares en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Frecuencia de hogares" in `renglon';
replace quintil         = "`quintil'" in `renglon';
replace edades_en_hog   = "`edad_hog'" in `renglon';
replace periodo         = "2016" in `renglon';
replace valor           = M_d_`edad_hog'_`quintil'[1,1]  in `renglon';
replace EE              = M_d_`edad_hog'_`quintil'[2,1]  in `renglon';
replace LI              = M_d_`edad_hog'_`quintil'[3,1]  in `renglon';
replace LS              = M_d_`edad_hog'_`quintil'[4,1]  in `renglon';
replace CV              = M_d_`edad_hog'_`quintil'[5,1]  in `renglon';

};
};

export delimited using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\Frecuencia_gastos_quintil_edad_3am.csv", replace;


************************************************************************************************************************;
*************************************Caso 4: quintiles y adultos mayores en 1 grupo*************************************;
************************************************************************************************************************;

#delimit;
clear all;
cap clear;
cap log close;
scalar drop _all;
set mem 400m;
set more off;

use "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\IyG ENIGH 2016 por decil y edad.dta", clear;

svyset upm [w= factor] , vce(linearized) strata(est_dis) singleunit(centered);


*Aquí se generan 30 dummies para cada una de las combinaciones de quintiles (5) y composiciones de hogares (6);

forvalues edad_hog2= 1(1)6 {;

forvalues quintil= 1(1)5 {;

gen d_`edad_hog2'_`quintil'=0;
replace d_`edad_hog2'_`quintil'=1 if quintil==`quintil' & edad_hog2==`edad_hog2';

};
};

*Aquí se realizan las estimaciones de frecuencia para cada una de las 30 combinaciones ;

forvalues edad_hog2= 1(1)6 {;

forvalues quintil= 1(1)5 {;

svy: total d_`edad_hog2'_`quintil';
matrix A=r(table);
matrix A = A[1..2, 1]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;
matrix rename A M_d_`edad_hog2'_`quintil';

};
};

*********************************************;
*Aquí se exporta la información a una tabla;

#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str quintil=".";
gen str edades_en_hog=".";
gen str periodo=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;

local renglon=0;


forvalues edad_hog2= 1(1)6 {;

forvalues quintil= 1(1)5 {;

local renglon=`renglon'+1;

set obs `renglon';

replace pob_obj         = "Hogares en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Frecuencia de hogares" in `renglon';
replace quintil         = "`quintil'" in `renglon';
replace edades_en_hog   = "`edad_hog2'" in `renglon';
replace periodo         = "2016" in `renglon';
replace valor           = M_d_`edad_hog2'_`quintil'[1,1]  in `renglon';
replace EE              = M_d_`edad_hog2'_`quintil'[2,1]  in `renglon';
replace LI              = M_d_`edad_hog2'_`quintil'[3,1]  in `renglon';
replace LS              = M_d_`edad_hog2'_`quintil'[4,1]  in `renglon';
replace CV              = M_d_`edad_hog2'_`quintil'[5,1]  in `renglon';

};
};

export delimited using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\Frecuencia_gastos_quintil_edad_1am.csv", replace;


************************************************************************************************************************;
************************************************************************************************************************;
************************************************************************************************************************;
****************************************Proporción de gastos por quintil************************************************;
************************************************************************************************************************;
************************************************************************************************************************;
************************************************************************************************************************;


#delimit;
clear all;
cap clear;
cap log close;
scalar drop _all;
set mem 400m;
set more off;

use "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\IyG ENIGH 2016 por decil y edad.dta", clear;

svyset upm [w= factor] , vce(linearized) strata(est_dis) singleunit(centered);

global list 
"p_alimentos p_tab_alcoh p_vesti_calz p_vivienda p_hogar p_salud p_transporte p_educa_espa p_personales p_transf_gas";


foreach var of global list {;

forvalues edad_hog2= 1(1)6 {;

forvalues quintil= 1(1)5 {;

svy: mean `var' if quintil==`quintil' & edad_hog2==`edad_hog2';
matrix A=r(table);
matrix A = A[1..2, 1]\A[5..6, 1...] ;
estat cv ;
matrix cv=r(cv);
matrix A=A\cv;
matrix rename A M_`var'_`edad_hog2'_`quintil';
 
};
};
};

*********************************************;
*Aquí se exporta la información a una tabla;

#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str variable=".";
gen str quintil=".";
gen str edades_en_hog=".";
gen str periodo=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;

global list 
"p_alimentos p_tab_alcoh p_vesti_calz p_vivienda p_hogar p_salud p_transporte p_educa_espa p_personales p_transf_gas";

local renglon=0;

foreach var of global list {;

forvalues edad_hog2= 1(1)6 {;

forvalues quintil= 1(1)5 {;

local renglon=`renglon'+1;

set obs `renglon';

replace pob_obj         = "Hogares en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Proporción promedio" in `renglon';
replace variable        = "`var'" in `renglon';
replace quintil         = "`quintil'" in `renglon';
replace edades_en_hog   = "`edad_hog2'" in `renglon';
replace periodo         = "2016" in `renglon';
replace valor           = M_`var'_`edad_hog2'_`quintil'[1,1] in `renglon';
replace EE              = M_`var'_`edad_hog2'_`quintil'[2,1]  in `renglon';
replace LI              = M_`var'_`edad_hog2'_`quintil'[3,1]  in `renglon';
replace LS              = M_`var'_`edad_hog2'_`quintil'[4,1] in `renglon';
replace CV              = M_`var'_`edad_hog2'_`quintil'[5,1] in `renglon';

};
};
};

export delimited using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases\proporción de gastos por quintil.csv", replace;







