#delimit;
clear all;

use "$bases\base_hogar.dta", clear;

global list_variables alimentos tab_alcoh vesti_calz vivienda hogar salud transporte educa_espa personales transf_gas gasto_mon ict;
   
					   
foreach variable of global list_variables {;
gen `variable'_pc=`variable'/tamhogesc_1;
};

foreach variable of global list_variables {;
gen `variable'_pc_porc=`variable'_pc/gasto_mon_pc*100;
};

foreach variable of global list_variables {;
recode `variable'_pc_porc (. = 0);
};

*Quintil de ingreso (escalado);
xtile cien   = ict_pc [w=factor], nq(100);
xtile quintil= ict_pc [w=factor] if cien!=100, nq(5);


*Con pensión contributiva(Hogar con P65+);
gen H65_contri=0;
replace H65_contri=1 if d_edad_65ymas==1 & clasificador_h==1;
*Con pensión no contributiva (Hogar con P65+);
gen H65_nocontri=0;
replace H65_nocontri=1 if d_edad_65ymas==1 & clasificador_h==2;
*Con pensión: contributiva y no contributiva) (Hogar con P65+);
gen H65_ambos=0;
replace H65_ambos=1 if d_edad_65ymas==1 & clasificador_h==3;
*Sin pensión (Hogar con P65+);
gen H65_sinpen=0;
replace H65_sinpen=1 if d_edad_65ymas==1 & clasificador_h==4; 
*Hogares sin personas de 65 años y más (Hogar con P65+);
gen sinH65=0;
replace sinH65=1  if d_edad_65ymas==0;



global list_gastos alimentos tab_alcoh vesti_calz vivienda hogar salud transporte educa_espa personales transf_gas;
global list_hogar H65_contri H65_nocontri H65_ambos H65_sinpen sinH65;

svyset upm [w= factor], vce(linearized) strata(est_dis) singleunit(centered);

foreach variable of global list_gastos{;
foreach hogar of global list_hogar{;
forvalues i=1(1)5{;

svy: mean `variable'_pc if `hogar'==1 & quintil==`i' ;
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv;
matrix cv=r(cv);
matrix A=A\cv;

matrix rename A M_`variable'_`hogar'_`i';

};
};
};

#delimit;
foreach variable of global list_gastos{;
foreach hogar of global list_hogar{;
forvalues i=1(1)5{;

svy: mean `variable'_pc_porc if `hogar'==1 & quintil==`i' ;
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv;
matrix cv=r(cv);
matrix A=A\cv;

matrix rename A P_`variable'_`hogar'_`i';

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
gen str tipo_hog =".";
gen double quintil=.;
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;


local renglon=0;

foreach variable of global list_gastos{;
foreach hogar of global list_hogar{;
forvalues i=1(1)5{;

local renglon=`renglon'+1;
set obs `renglon';

replace pob_obj         = "Hogares en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Pesos mensuales (escalado)" in `renglon';
replace periodo         = "2016" in `renglon';
replace variable        = "`variable'" in `renglon';
replace tipo_hog        = "`hogar'" in `renglon';
replace quintil         = `i' in `renglon';
replace valor           = M_`variable'_`hogar'_`i'[1,1]   in `renglon';
replace EE              = M_`variable'_`hogar'_`i'[2,1]   in `renglon';
replace LI              = M_`variable'_`hogar'_`i'[3,1]   in `renglon';
replace LS              = M_`variable'_`hogar'_`i'[4,1]   in `renglon';
replace CV              = M_`variable'_`hogar'_`i'[5,1]   in `renglon';

};
};
};

export delimited using "$bases\Ingresos y gastos (por quintil).csv", replace;

*Aquí se exporta la información a una tabla;
#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str periodo=".";
gen str variable=".";
gen str tipo_hog =".";
gen double quintil=.;
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;


local renglon=0;

foreach variable of global list_gastos{;
foreach hogar of global list_hogar{;
forvalues i=1(1)5{;

local renglon=`renglon'+1;
set obs `renglon';

replace pob_obj         = "Hogares en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Porcentaje del gasto (escalado)" in `renglon';
replace periodo         = "2016" in `renglon';
replace variable        = "`variable'" in `renglon';
replace tipo_hog        = "`hogar'" in `renglon';
replace quintil         = `i' in `renglon';
replace valor           = P_`variable'_`hogar'_`i'[1,1]   in `renglon';
replace EE              = P_`variable'_`hogar'_`i'[2,1]   in `renglon';
replace LI              = P_`variable'_`hogar'_`i'[3,1]   in `renglon';
replace LS              = P_`variable'_`hogar'_`i'[4,1]   in `renglon';
replace CV              = P_`variable'_`hogar'_`i'[5,1]   in `renglon';

};
};
};


export delimited using "$bases\Ingresos y gastos (por quintil)_porcentaje.csv", replace;







