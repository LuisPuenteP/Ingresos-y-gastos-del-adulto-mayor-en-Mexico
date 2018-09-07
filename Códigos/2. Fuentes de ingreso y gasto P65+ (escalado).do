#delimit;
clear all;

#delimit;
use "$bases\base_hogar.dta", clear;

global list_variables  laboral rentas contributivas no_contributivas donativos_otras_fam otras_transfer nomon ict
                       alimentos tab_alcoh vesti_calz vivienda hogar salud transporte educa_espa personales transf_gas gasto_mon;
   
					   
foreach variable of global list_variables {;
gen `variable'_pc=`variable'/tamhogesc_1;
};

keep folioviv foliohog laboral_pc rentas_pc contributivas_pc no_contributivas_pc donativos_otras_fam_pc otras_transfer_pc nomon_pc ict_pc
                       alimentos_pc tab_alcoh_pc vesti_calz_pc vivienda_pc hogar_pc salud_pc transporte_pc educa_espa_pc personales_pc transf_gas_pc gasto_mon_pc;

save "$bases\ingresos y gastos escalados.dta", replace;

use "$bases\base_individual.dta", clear;

merge m:1 folioviv foliohog using "$bases\ingresos y gastos escalados.dta";
drop _merge;


xtile cien_ict_pc = ict_pc [w=factor] if edad>=65 & ict_pc!=., nq(100);
xtile cien_gasto_mon_pc = gasto_mon_pc [w=factor] if edad>=65 & gasto_mon_pc!=., nq(100);

gen d_0_100=.;
replace d_0_100=1 if cien_ict_pc>=1 & cien_ict_pc<=100;
gen d_0_99=.;
replace d_0_99=1  if cien_ict_pc>=1 & cien_ict_pc<=99;

global list_genero d_hombre d_mujer;

#delimit;
svyset upm [w= factor], vce(linearized) strata(est_dis) singleunit(centered);


foreach variable of global list_variables {;

svy: mean `variable'_pc if edad>=65 & d_0_100==1;
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv;
matrix cv=r(cv);
matrix A=A\cv;
summarize `variable'_pc [w=factor] if edad>=65 & d_0_100==1, detail;
matrix A=A\r(sum_w)\r(p1)\r(p5)\r(p10)\r(p25)\r(p50)\r(p75)\r(p90)\r(p95)\r(p99);

#delimit;
svy: mean `variable'_pc if edad>=65 & d_0_99==1;
matrix B=r(table);
matrix A = A\B[1..2, 1...]\B[5..6, 1...];
estat cv;
matrix cv=r(cv);
matrix A=A\cv;
summarize `variable'_pc [w=factor] if edad>=65 & d_0_99==1, detail;
matrix A=A\r(sum_w)\r(p1)\r(p5)\r(p10)\r(p25)\r(p50)\r(p75)\r(p90)\r(p95)\r(p99);


matrix rename A M_`variable';
};


*Aquí se exporta la información a una tabla;
#delimit;
clear;
gen str pob_obj=".";
gen str u_analisis=".";
gen str u_medida=".";
gen str periodo=".";
gen str variable=".";
gen double valor=.;
gen double EE=.;
gen double LI=.;
gen double LS=.;
gen double CV=.;
gen double tamano=.;

gen double pc1=.;
gen double pc5=.;
gen double pc10=.;
gen double pc25=.;
gen double pc50=.;
gen double pc75=.;
gen double pc90=.;
gen double pc95=.;
gen double pc99=.;

gen double valor_0_99=.;
gen double EE_0_99=.;
gen double LI_0_99=.;
gen double LS_0_99=.;
gen double CV_0_99=.;
gen double tamano_0_99=.;

gen double pc1_0_99=.;
gen double pc5_0_99=.;
gen double pc10_0_99=.;
gen double pc25_0_99=.;
gen double pc50_0_99=.;
gen double pc75_0_99=.;
gen double pc90_0_99=.;
gen double pc95_0_99=.;
gen double pc99_0_99=.;

local renglon=0;


foreach variable of global list_variables {;

local renglon=`renglon'+1;
set obs `renglon';

replace pob_obj         = "Hogares con P65ymas en Mexico" in `renglon';
replace u_analisis      = "Hogares" in `renglon';
replace u_medida        = "Pesos mensuales por persona(escalado)" in `renglon';
replace periodo         = "2016" in `renglon';
replace variable        = "`variable'" in `renglon';
replace valor           = M_`variable'[1,1]   in `renglon';
replace EE              = M_`variable'[2,1]   in `renglon';
replace LI              = M_`variable'[3,1]   in `renglon';
replace LS              = M_`variable'[4,1]   in `renglon';
replace CV              = M_`variable'[5,1]   in `renglon';

replace tamano          = M_`variable'[6,1]   in `renglon';

replace pc1             = M_`variable'[7,1]   in `renglon';
replace pc5             = M_`variable'[8,1]   in `renglon';
replace pc10            = M_`variable'[9,1]   in `renglon';
replace pc25            = M_`variable'[10,1]   in `renglon';
replace pc50            = M_`variable'[11,1]  in `renglon';
replace pc75            = M_`variable'[12,1]  in `renglon';
replace pc90            = M_`variable'[13,1]  in `renglon';
replace pc95            = M_`variable'[14,1]  in `renglon';
replace pc99            = M_`variable'[15,1]  in `renglon';

replace valor_0_99           = M_`variable'[16,1]   in `renglon';
replace EE_0_99              = M_`variable'[17,1]   in `renglon';
replace LI_0_99              = M_`variable'[18,1]   in `renglon';
replace LS_0_99              = M_`variable'[19,1]   in `renglon';
replace CV_0_99              = M_`variable'[20,1]   in `renglon';

replace tamano_0_99          = M_`variable'[21,1]   in `renglon';

replace pc1_0_99             = M_`variable'[22,1]   in `renglon';
replace pc5_0_99             = M_`variable'[23,1]   in `renglon';
replace pc10_0_99            = M_`variable'[24,1]   in `renglon';
replace pc25_0_99            = M_`variable'[25,1]   in `renglon';
replace pc50_0_99            = M_`variable'[26,1]  in `renglon';
replace pc75_0_99            = M_`variable'[27,1]  in `renglon';
replace pc90_0_99            = M_`variable'[28,1]  in `renglon';
replace pc95_0_99            = M_`variable'[29,1]  in `renglon';
replace pc99_0_99            = M_`variable'[30,1]  in `renglon';

};

export delimited using "$bases\Fuente de ingresoy gasto P65 (escalado).csv", replace;

