
#delimit;
clear all;

#delimit;
use "$bases\base_hogar.dta", clear;


global list_variables 
laboral_64ymenos
rentas_64ymenos
contributivas_64ymenos
no_contributivas_64ymenos
donativos_otras_fam_64ymenos
otras_transfer_64ymenos

laboral_65ymas
rentas_65ymas
contributivas_65ymas
no_contributivas_65ymas
donativos_otras_fam_65ymas
otras_transfer_65ymas
nomon
ict
;

gen ict_pc=ict/tamhogesc_1;

xtile cien   = ict_pc [w=factor], nq(100);
drop if cien==100;

#delimit;
svyset upm [w= factor], vce(linearized) strata(est_dis) singleunit(centered);

foreach variable of global list_variables {;

svy: mean `variable' if d_edad_65ymas==1;
matrix A=r(table);
matrix A = A[1..2, 1...]\A[5..6, 1...] ;
estat cv;
matrix cv=r(cv);
matrix A=A\cv;
summarize `variable' [w=factor] if d_edad_65ymas==1, detail;
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
replace pc25            = M_`variable'[10,1]  in `renglon';
replace pc50            = M_`variable'[11,1]  in `renglon';
replace pc75            = M_`variable'[12,1]  in `renglon';
replace pc90            = M_`variable'[13,1]  in `renglon';
replace pc95            = M_`variable'[14,1]  in `renglon';
replace pc99            = M_`variable'[15,1]  in `renglon';

};

gen edad="";
replace edad="P64 y menos" if variable== "laboral_64ymenos" | variable== "rentas_64ymenos" | variable== "contributivas_64ymenos" |  variable== "no_contributivas_64ymenos" | variable== "donativos_otras_fam_64ymenos" | variable== "otras_transfer_64ymenos";
replace edad="P65 y más"   if variable== "laboral_65ymas" | variable== "rentas_65ymas" | variable== "contributivas_65ymas" | variable== "no_contributivas_65ymas" | variable== "donativos_otras_fam_65ymas" | variable== "otras_transfer_65ymas";
replace edad="Hogar"   if variable== "nomon";
replace edad="Hogar"   if variable== "ict";

gen porcentaje =valor/11154.061*100;


export delimited using "$bases\Ingresos P64ymenos y P65ymás en hogares con P65ymás.csv", replace;
