
* Este código fue elaborado en la Cordinación General de Planeación Estratégica y Proyectos Especiales de la CONSAR.
* Este código es material de CONSAR y forma parte del proyecto "Ingresos y gastos del adulto mayor en México: La importancia de las pensiones"
* por lo que no podrá citarse hasta que el trabajo esté publicado por CONSAR.

* Contacto: Luis Federico Puente Peña, lfpuente@consar.gob.mx

#delimit;
clear;
cap clear;
cap log close;
scalar drop _all;
set mem 400m;
set more off;

*Este do-file utiliza de insumo las bases de datos de la ENIGH 2016;
*Las bases originales se encuentran en la siguiente ruta: ;
gl original="D:\Mis Documentos\Stata\ENIGH-2016";
*Las bases generadas se encuentran en la siguiente ruta: ;
gl bases="D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\Bases";

**************************************************************************************************************************;
***************************************GENERACIÓN DE BASES Y VARIABLES****************************************************;
**************************************************************************************************************************;

*NOTA: La base principal que se utiliza es la de "población" sin huespedes ni trabajadores domésticos;

**********************************************************;
**********************Base:población**********************;
**********************************************************;
*Aquí se obtienen las variables a nivel persona;
use "$original\poblacion.dta", clear;

*Se eliminan a huespedes y trabajadores domésticos;
drop if parentesco>="400" & parentesco <"500";
drop if parentesco>="700" & parentesco <"800";

sort folioviv foliohog numren;
gen sar_vol=0;
replace sar_vol=1 if segvol_1=="1";

label define sar_vol 1 "con SAR"
			        0 "sin SAR";
label value sar_vol sar_vol;
			  
*Nivel educativo;
destring nivelaprob gradoaprob antec_esc, replace;

gen educacion=.;
*Sin educación;
replace educacion=1 if nivelaprob==0;
replace educacion=1 if nivelaprob==1;
replace educacion=1 if nivelaprob==2 & gradoaprob<6;
*Primaria;
replace educacion=2 if (nivelaprob==2 & gradoaprob==6);
replace educacion=2 if nivelaprob==3 & gradoaprob<3;
*Secundaria;
replace educacion=3 if (nivelaprob==3 & gradoaprob==3) | ( (nivelaprob==5 | nivelaprob==6) & antec_esc==1);
replace educacion=3 if nivelaprob==4 & gradoaprob<3;
*Preparatoria;
replace educacion=4 if (nivelaprob==4 & gradoaprob==3) | ( (nivelaprob==5 | nivelaprob==6) & antec_esc==2);
replace educacion=4 if nivelaprob==7 & gradoaprob<4;
*Profesional;
replace educacion=5 if (nivelaprob==7 & gradoaprob>=4) | ( (nivelaprob==5 | nivelaprob==6) & antec_esc==3);
*Posgrado;
replace educacion=6 if (nivelaprob==8 | nivelaprob==9) | ( (nivelaprob==5 | nivelaprob==6) & (antec_esc==4 | antec_esc==5));


label define educacion 1 "Sin educación"
                       2 "Primaria"
					   3 "Secundaria"
					   4 "Preparatoria"
					   5 "Profesional"
					   6 "Posgrado";
						 
label value educacion educacion; 

*Servicios de salud;
*Instituciones que brindan el servicio de salud;
gen serv_sal=.;
replace serv_sal=0 if segpop=="2" & atemed=="2";
replace serv_sal=1 if segpop=="1";
replace serv_sal=2 if segpop=="2" & atemed=="1" & inst_1=="1";
replace serv_sal=3 if segpop=="2" & atemed=="1" & inst_2=="2";
replace serv_sal=3 if segpop=="2" & atemed=="1" & inst_3=="3";
replace serv_sal=4 if segpop=="2" & atemed=="1" & inst_4=="4";
replace serv_sal=5 if segvol_2=="2";
replace serv_sal=6 if segpop=="2" & atemed=="1" & (inst_5=="5" | inst_6=="6");

label var serv_sal "Servicios de salud";
label define serv_sal         0 "No cuenta con servicios médicos" 
                              1 "Seguro Popular" 
                              2 "IMSS" 
                              3 "ISSSTE o ISSSTE estatal" 
                              4 "Pemex, Defensa o Marina"
							  5 "Seguro privado de gastos médicos"
							  6 "Otros";
label value serv_sal;
							  
*Estado civil;
gen edo_civil=.;
replace edo_civil=1 if edo_conyug=="6" ;
replace edo_civil=2 if edo_conyug=="1" | edo_conyug=="2";
replace edo_civil=3 if edo_conyug=="3" | edo_conyug=="4";
replace edo_civil=4 if edo_conyug=="5";


label define edo_civil 1 "Soltero"
                       2 "Casado/unión libre"
					   3 "Separado/divorciado"
					   4 "Viudo";
						 
label value edo_civil edo_civil; 

keep folioviv foliohog numren parentesco sar_vol educacion serv_sal edo_civil sexo edad;

sort folioviv foliohog numren;

save "$bases\población.dta", replace;


**********************************************************;
**********************Base:población**********************;
**********************************************************;
*Aquí se obtienen varaibles demográficas a nivel hogar;
#delimit;
use "$original\poblacion.dta", clear;

*Se eliminan a huespedes y trabajadores domésticos;
drop if parentesco>="400" & parentesco <"500";
drop if parentesco>="700" & parentesco <"800";

*Variables de edad;
gen edad_0_5=0;
replace edad_0_5=1 if edad>=0 & edad<=5;

gen edad_6_12=0;
replace edad_6_12=1 if edad>=6 & edad<=12;

gen edad_13_18=0;
replace edad_13_18=1 if edad>=13 & edad<=18;

gen edad_19_64=0;
replace edad_19_64=1 if edad>=19 & edad<=64;

gen edad_65ymas=0;
replace edad_65ymas=1 if edad>=65 & edad!=.;

gen adulto=0;
replace adulto=1 if edad>=18;

gen menor_18=0;
replace menor_18=1 if edad<18;

*Variables de jefe de familia y edad;
gen jefe_p65=0;
replace jefe_p65=1 if edad>=65 & parentesco=="101";

collapse (sum) edad_0_5 edad_6_12 edad_13_18 edad_19_64 edad_65ymas adulto menor_18 jefe_p65, by (folioviv foliohog); 

label var edad_0_5 "Número de personas de 0 a 5 años en el hogar";
label var edad_6_12 "Número de personas de 6 a 12 años en el hogar";
label var edad_13_18 "Número de personas de 13 a 18 años en el hogar";
label var edad_19_64 "Número de personas de 19 a 64 años en el hogar";
label var edad_65ymas "Número de personas de 65 años y más en el hogar";
label var adulto "Número de personas de 18 años y más en el hogar";
label var menor_18 "Número de personas menores a 18 años en el hogar";
label var jefe_p65 "Indicadora de jefe de jefe de hogar de 65 años y más";

gen d_edad_65ymas=0;
replace d_edad_65ymas=1 if edad_65ymas>0;

label var d_edad_65ymas "Indicador de personas de 65 años y más en el hogar";
label define d_edad_65ymas 1 "Hogar con P65+" 
						   0 "Hogar sin P65+";
label value d_edad_65ymas d_edad_65ymas;

gen tamhog=0;
replace tamhog=menor_18+adulto;
label var tamhog "Tamaño del hogar";

gen ln_tamhog=ln(tamhog);
gen menor_18_tamhog=(menor_18/tamhog);
gen adulto2=(adulto*adulto);
gen menor_18_2=(menor_18*menor_18);
gen adulto_menor_18=(adulto*menor_18);
sort folioviv foliohog;

gen composicion_demog=0;
replace composicion_demog=1 if edad_0_5==0 & edad_6_12==0 & edad_13_18==0 & edad_19_64==2 & edad_65ymas==0;
replace composicion_demog=2 if edad_0_5==1 & edad_6_12==0 & edad_13_18==0 & edad_19_64==2 & edad_65ymas==0;
replace composicion_demog=3 if edad_0_5==0 & edad_6_12==1 & edad_13_18==0 & edad_19_64==2 & edad_65ymas==0;
replace composicion_demog=4 if edad_0_5==0 & edad_6_12==0 & edad_13_18==1 & edad_19_64==2 & edad_65ymas==0;
replace composicion_demog=5 if edad_0_5==0 & edad_6_12==0 & edad_13_18==0 & edad_19_64==3 & edad_65ymas==0;
replace composicion_demog=6 if edad_0_5==0 & edad_6_12==0 & edad_13_18==0 & edad_19_64==2 & edad_65ymas==1;

label var composicion_demog "Composición demográfica de los hogares";

label define composicion_demog  0 "Otra composición"
								1 "Hogar con dos individuos de 19-64"
							    2 "Hogar con dos individuos de 19-64 y un individuo de 0-5"
                                3 "Hogar con dos individuos de 19-64 y un individuo de 6-12"	
								4 "Hogar con dos individuos de 19-64 y un individuo de 13-18"
								5 "Hogar con tres individuos de 19-64"
								6 "Hogar con dos individuos de 19-64 y uno de 65 y más";
								
save "$bases\características_del_hogar.dta", replace;

**********************************************************;
********************Base:trabajos*************************;
**********************************************************;
*Aquí se obtiene la variable de SAR (pres_14) a nivel trabajador;
use "$original\trabajos.dta", clear;
sort folioviv foliohog numren id_trabajo;
gen sar=0;
replace sar=1 if pres_14=="14";
tab sar;
collapse (sum) sar, by(folioviv foliohog numren);
tab sar;
replace sar=1 if sar>0;
tab sar;
save "$bases\SAR_trabajo.dta", replace;

**********************************************************;
********************Base:concentrado**********************;
**********************************************************;
*Aquí se obtiene las variables muestrales;
use "$original\concentradohogar.dta", clear;
destring clase_hog, replace;
label define clase_hog  1 "Unipersonal"
						2 "Nuclear"
						3 "Ampliado"
						4 "Compuesto"
						5 "Corresidente";
label value clase_hog clase_hog;

keep folioviv foliohog factor est_dis upm clase_hog;
save "$bases\variables_muestrales.dta", replace;

**********************************************************;
**********************Base:vivienda***********************;
**********************************************************;
#delimit;
*Aquí se obtienen las variables de la vivienda;
use "$original\viviendas.dta", clear;

gen rururb=1 if tam_loc=="4";
replace rururb=0 if tam_loc<="3";
label define rururb 1 "Rural" 
                    0 "Urbano";
label value rururb rururb;

gen viv_prop=.;
replace viv_prop=1 if tenencia=="3" | tenencia=="4";
replace viv_prop=0 if tenencia=="1" | tenencia=="2" | tenencia=="5" | tenencia=="6";


*Entidad federativa;
gen ent=real(substr(folioviv,1,2));
label var ent "Identificador de la entidad federativa";

label define ent 
1	"Aguascalientes"
2	"Baja California"
3	"Baja California Sur"
4	"Campeche"
5	"Coahuila"
6	"Colima"
7	"Chiapas"
8	"Chihuahua"
9	"Ciudad de México"
10	"Durango"
11	"Guanajuato"
12	"Guerrero"
13	"Hidalgo"
14	"Jalisco"
15	"México"
16	"Michoacán"
17	"Morelos"
18	"Nayarit"
19	"Nuevo León"
20	"Oaxaca"
21	"Puebla"
22	"Querétaro"
23	"Quintana Roo"
24	"San Luis Potosí"
25	"Sinaloa"
26	"Sonora"
27	"Tabasco"
28	"Tamaulipas"
29	"Tlaxcala"
30	"Veracruz"
31	"Yucatán"
32	"Zacatecas";
label value ent ent;

keep folioviv rururb tenencia num_dueno1 hog_dueno1 num_dueno2 hog_dueno2 viv_prop ent;
sort folioviv;
save "$bases\viviendas.dta", replace;

**********************************************************;
***************Base: ingreso por persona******************;
**********************************************************;

*Para la construcción del ingreso corriente del hogar es necesario utilizar
información sobre la condición de ocupación y los ingresos de los individuos.
Se utiliza la información contenida en la base "$bases\trabajo.dta" para 
identificar a la población ocupada que declara tener como prestación laboral aguinaldo, 
ya sea por su trabajo principal o secundario, a fin de incorporar los ingresos por este 
concepto en la medición;

use "$original\trabajos.dta", clear;

keep  folioviv foliohog numren id_trabajo pres_8;
destring pres_8 id_trabajo, replace;
reshape wide pres_8, i( folioviv foliohog numren) j(id_trabajo);

gen trab=1;

label var trab "Población con al menos un empleo";

gen aguinaldo1=.;
replace aguinaldo1=1 if pres_81==8;
recode aguinaldo1 (.=0);

gen aguinaldo2=.;
replace aguinaldo2=1 if pres_82==8;
recode aguinaldo2 (.=0);

label var aguinaldo1 "Aguinaldo trabajo principal";
label define aguinaldo 0 "No dispone de aguinaldo"
                       1 "Dispone de aguinaldo";
label value aguinaldo1 aguinaldo;
label var aguinaldo2 "Aguinaldo trabajo secundario";
label value aguinaldo2 aguinaldo;

keep  folioviv foliohog numren aguinaldo1 aguinaldo2 trab;

sort  folioviv foliohog numren ;

save "$bases\aguinaldo.dta", replace;

*Ahora se incorpora a la base de ingresos;

use "$original\ingresos.dta", clear;

sort  folioviv foliohog numren;

merge  folioviv foliohog numren using "$bases\aguinaldo.dta";

tab _merge;
drop _merge;

sort  folioviv foliohog numren;

drop if (clave=="P009" & aguinaldo1!=1);
drop if (clave=="P016" & aguinaldo2!=1);

*Una vez realizado lo anterior, se procede a deflactar el ingreso recibido
por los hogares a precios de agosto de 2016. Para ello, se utilizan las 
variables meses, las cuales toman los valores 2 a 10 e indican el mes en
que se recibió el ingreso respectivo;

*Definición de los deflactores 2016 ;

scalar	dic15	=	0.9915096155	;
scalar	ene16	=	0.9952905552	;
scalar	feb16	=	0.9996486737	;
scalar	mar16	=	1.0011208981	;
scalar	abr16	=	0.9979505968	;
scalar	may16	=	0.9935004643	;
scalar	jun16	=	0.9945962676	;
scalar	jul16	=	0.9971893899	;
scalar	ago16	=	1.0000000000	;
scalar	sep16	=	1.0061063849	;
scalar	oct16	=	1.0122127699	;
scalar	nov16	=	1.0201259756	;
scalar	dic16	=	1.0248270555	;

destring mes_*, replace;
replace ing_6=ing_6/feb16 if mes_6==2;
replace ing_6=ing_6/mar16 if mes_6==3;
replace ing_6=ing_6/abr16 if mes_6==4;
replace ing_6=ing_6/may16 if mes_6==5;


replace ing_5=ing_5/mar16 if mes_5==3;
replace ing_5=ing_5/abr16 if mes_5==4;
replace ing_5=ing_5/may16 if mes_5==5;
replace ing_5=ing_5/jun16 if mes_5==6;

replace ing_4=ing_4/abr16 if mes_4==4;
replace ing_4=ing_4/may16 if mes_4==5;
replace ing_4=ing_4/jun16 if mes_4==6;
replace ing_4=ing_4/jul16 if mes_4==7;

replace ing_3=ing_3/may16 if mes_3==5;
replace ing_3=ing_3/jun16 if mes_3==6;
replace ing_3=ing_3/jul16 if mes_3==7;
replace ing_3=ing_3/ago16 if mes_3==8;

replace ing_2=ing_2/jun16 if mes_2==6;
replace ing_2=ing_2/jul16 if mes_2==7;
replace ing_2=ing_2/ago16 if mes_2==8;
replace ing_2=ing_2/sep16 if mes_2==9;

replace ing_1=ing_1/jul16 if mes_1==7;
replace ing_1=ing_1/ago16 if mes_1==8;
replace ing_1=ing_1/sep16 if mes_1==9;
replace ing_1=ing_1/oct16 if mes_1==10;


*Se deflactan las claves P008 y P015 (Reparto de utilidades) 
y P009 y P016 (aguinaldo)
con los deflactores de mayo a agosto 2016 
y de diciembre de 2015 a agosto 2016, 
respectivamente, y se obtiene el promedio mensual.;

replace ing_1=(ing_1/may16)/12 if clave=="P008" | clave=="P015";
replace ing_1=(ing_1/dic15)/12 if clave=="P009" | clave=="P016";

recode ing_2 ing_3 ing_4 ing_5 ing_6 (0=.) if clave=="P008" | clave=="P009" | clave=="P015" | clave=="P016";

*Una vez realizada la deflactación, se procede a obtener el 
ingreso mensual promedio en los últimos seis meses, para 
cada persona y clave de ingreso;

egen double ing_mens=rmean(ing_1 ing_2 ing_3 ing_4 ing_5 ing_6);

*Trabajo (sueldos,horext,comisiones,otra_rem);
gen double sueldos=ing_mens if clave=="P001" | clave=="P002" | clave=="P011" | clave=="P014" | clave=="P018" | clave=="P067";
recode sueldos (. = 0);
gen double horext=ing_mens if clave=="P004";
recode horext (. = 0);
gen double comisiones=ing_mens if clave=="P003";
recode comisiones (. = 0 );
gen double otra_rem=ing_mens if (clave>="P005" & clave<="P007") | clave=="P013" | clave=="P020";
recode otra_rem (. = 0 );
gen double trabajo=sueldos+horext+comisiones+otra_rem;
recode trabajo (. = 0 );

*Negocio (noagrop, agrope y ganancias);
gen double industria=ing_mens if clave=="P068" | clave=="P075";
recode industria ( . = 0); 
gen double comercio=ing_mens if clave=="P069" | clave=="P076";
recode comercio ( . = 0); 
gen double servicios=ing_mens if clave=="P070" | clave=="P077";
recode servicios ( . = 0); 
gen double noagrop=industria+comercio+servicios;
recode noagrop (. = 0 );

gen double agricolas=ing_mens if clave=="P071" | clave=="P078";
recode agricolas ( . = 0); 
gen double pecuarios=ing_mens if clave=="P072" | clave=="P079";
recode pecuarios ( . = 0); 
gen double reproducc=ing_mens if clave=="P073" | clave=="P080";
recode reproducc ( . = 0); 
gen double pesca=ing_mens if clave=="P074" | clave=="P081";
recode pesca ( . = 0); 
gen double agrope=agricolas+pecuarios+reproducc+pesca;
recode agrope (. = 0 );

gen double ganancias=ing_mens if clave=="P012";
recode ganancias (. = 0 );

gen double negocio=noagrop+agrope+ganancias;
recode negocio (. = 0 );

gen double aguinaldo=ing_mens if clave=="P009" | clave=="P016";
recode aguinaldo(. = 0 );
gen double rep_utilidades=ing_mens if clave=="P008" | clave=="P015";
recode rep_utilidades (. = 0 );
gen double otros_trab=ing_mens if clave=="P019" | clave=="P021" | clave=="P022"; 
recode otros_trab (. = 0 );

gen double laboral=trabajo+negocio+aguinaldo+rep_utilidades+otros_trab;
recode laboral (. = 0 );

* Rentas (propiedades, financieras y otras_rentas);
gen double propiedades=ing_mens if (clave>="P023" & clave<= "P025");
recode propiedades (. = 0 );
gen double financieras=ing_mens if (clave>="P026" & clave<= "P029");
recode financieras (. = 0 );
gen double otras_rentas=ing_mens if clave=="P030" | clave== "P031";
recode otras_rentas (. = 0 );
gen double rentas=propiedades+financieras+otras_rentas;
recode rentas (. = 0 );

*Transferencias (pensión, indemnizaciones, donativos_no_gub, donativos_otras_fam, remesas, bene_gob);
gen double contributivas=ing_mens if clave=="P032" | clave=="P033";
recode contributivas (. = 0 );
gen double no_contributivas=ing_mens if (clave>="P044" & clave<="P045");
recode no_contributivas (. = 0 );
gen double pension=contributivas+no_contributivas;
recode pension (. = 0 );

gen double indemnizaciones=ing_mens if (clave>="P034" & clave<="P036");
recode indemnizaciones (. = 0 );
gen double becas=ing_mens if clave=="P037" | clave=="P038";
recode becas (. = 0 );
gen double donativos_no_gub=ing_mens if clave=="P039";
recode donativos_no_gub (. = 0 );
gen double donativos_otras_fam=ing_mens if clave=="P040";
recode donativos_otras_fam (. = 0 );
gen double remesas=ing_mens if clave=="P041";
recode remesas (. = 0 );
gen double bene_gob=ing_mens if (clave>="P042" & clave<="P043") | (clave>="P046" & clave<="P048");
recode bene_gob (. = 0);

gen double transfer=pension+indemnizaciones+becas+donativos_no_gub+donativos_otras_fam+remesas+bene_gob;
recode transfer (. = 0 );

gen otras_transfer=transfer - contributivas - no_contributivas - donativos_otras_fam;
recode transfer (. = 0 );

gen double ingreso_mon=laboral+rentas+transfer;
recode ingreso (. = 0 );

*METODOLOGÍA CONEVAL: ;
*Para obtener el ingreso corriente monetario, se seleccionan 
las claves de ingreso correspondientes;

gen double ing_mon=ing_mens if (clave>="P001" & clave<="P009") | (clave>="P011" & clave<="P016") 
                             | (clave>="P018" & clave<="P048") | (clave>="P067" & clave<="P081");

*Para obtener el ingreso laboral, se seleccionan 
las claves de ingreso correspondientes;
gen double ing_lab=ing_mens if (clave>="P001" & clave<="P009") | (clave>="P011" & clave<="P016") 
                             | (clave>="P018" & clave<="P022") | (clave>="P067" & clave<="P081");

*Para obtener el ingreso por rentas, se seleccionan 
las claves de ingreso correspondientes;
gen double ing_ren=ing_mens if (clave>="P023" & clave<="P031");

*Para obtener el ingreso por transferencias, se seleccionan 
las claves de ingreso correspondientes;
gen double ing_tra=ing_mens if (clave>="P032" & clave<="P048");

*Se estima el total de ingresos de cada integrante;

collapse (sum) sueldos horext comisiones otra_rem trabajo industria comercio servicios noagrop agricolas 
pecuarios reproducc pesca agrope ganancias negocio aguinaldo rep_utilidades otros_trab laboral propiedades
financieras otras_rentas rentas contributivas no_contributivas pension indemnizaciones becas donativos_no_gub
donativos_otras_fam remesas bene_gob transfer otras_transfer ingreso_mon

ing_lab ing_ren ing_tra ing_mon, by(folioviv foliohog numren);
							 
sort  folioviv foliohog num ren;

label var ing_mon "Ingreso corriente monetario (individual)";
label var ing_lab "Ingreso corriente monetario laboral (individual)";
label var ing_ren "Ingreso corriente monetario por rentas (individual)";
label var ing_tra "Ingreso corriente monetario por transferencias (individual)";

save "$bases\ingreso_monetario_individual.dta", replace;


use "$bases\ingreso_monetario_individual.dta", clear;

collapse (sum) sueldos horext comisiones otra_rem trabajo industria comercio servicios noagrop agricolas 
pecuarios reproducc pesca agrope ganancias negocio aguinaldo rep_utilidades otros_trab laboral propiedades
financieras otras_rentas rentas contributivas no_contributivas pension indemnizaciones becas donativos_no_gub
donativos_otras_fam remesas bene_gob transfer otras_transfer ingreso_mon

ing_lab ing_ren ing_tra ing_mon, by(folioviv foliohog);

label var ing_mon "Ingreso corriente monetario del hogar";
label var ing_lab "Ingreso corriente monetario laboral del hogar";
label var ing_ren "Ingreso corriente monetario por rentas del hogar";
label var ing_tra "Ingreso corriente monetario por transferencias del hogar";

save "$bases\ingreso_monetario_hogar.dta", replace;

*********************************************************

Creación del ingreso no monetario deflactado a pesos de 
agosto del 2016.

*********************************************************;

*No Monetario;

use "$original\gastoshogar.dta", clear;
gen base=1;
append using "$original\gastospersona.dta";
recode base (.=2);

replace frecuencia=frec_rem if base==2;

label var base "Origen del monto";
label define base 1 "Monto del hogar"
                       2 "Monto de personas";
label value base base;

*En el caso de la información de gasto no monetario, para 
deflactar se utiliza la decena de levantamiento de la 
encuesta, la cual se encuentra en la octava posición del 
folio de la vivienda. En primer lugar se obtiene una variable que 
identifique la decena de levantamiento;

gen decena=real(substr(folioviv,8,1));

*Definición de los deflactores;		
		
*Rubro 1.1 semanal, Alimentos;		
scalar d11w07=	0.9985457696	;
scalar d11w08=	1.0000000000	;
scalar d11w09=	1.0167932672	;
scalar d11w10=	1.0199415214	;
scalar d11w11=	1.0251086805	;
		
*Rubro 1.2 semanal, Bebidas alcohólicas y tabaco;		
scalar d12w07=	0.9959845820	;
scalar d12w08=	1.0000000000	;
scalar d12w09=	1.0066744829	;
scalar d12w10=	1.0087894741	;
scalar d12w11=	1.0100998490	;
		
*Rubro 2 trimestral, Vestido, calzado y accesorios;		
scalar d2t05=	0.9920067602	;
scalar d2t06=	0.9948005139	;
scalar d2t07=	0.9986462366	;
scalar d2t08=	1.0053546946	;
		
*Rubro 3 mensual, viviendas;		
scalar d3m07=	1.0017314941	;
scalar d3m08=	1.0000000000	;
scalar d3m09=	0.9978188915	;
scalar d3m10=	1.0133832055	;
scalar d3m11=	1.0358543632	;
		
*Rubro 4.2 mensual, Accesorios y artículos de limpieza para el hogar;		
scalar d42m07=	0.9936894797	;
scalar d42m08=	1.0000000000	;
scalar d42m09=	1.0041605121	;
scalar d42m10=	1.0056376169	;
scalar d42m11=	1.0087477433	;
		
*Rubro 4.2 trimestral, Accesorios y artículos de limpieza para el hogar;		
scalar d42t05=	0.9932545544	;
scalar d42t06=	0.9960501122	;
scalar d42t07=	0.9992833306	;
scalar d42t08=	1.0032660430	;
		
*Rubro 4.1 semestral, Muebles y aparatos dómesticos;		
scalar d41s02=	1.0081456317	;
scalar d41s03=	1.0057381027	;
scalar d41s04=	1.0038444337	;
scalar d41s05=	1.0025359940	;
		
*Rubro 5.1 trimestral, Salud;		
scalar d51t05=	0.9948500567	;
scalar d51t06=	0.9974422922	;
scalar d51t07=	1.0000318717	;
scalar d51t08=	1.0028179937	;
		
*Rubro 6.1.1 semanal, Transporte público urbano;		
scalar d611w07=	0.9998162514	;
scalar d611w08=	1.0000000000	;
scalar d611w09=	1.0010465683	;
scalar d611w10=	1.0030038907	;
scalar d611w11=	1.0040584480	;
		
*Rubro 6 mensual, Transporte;		
scalar d6m07=	0.9907765708	;
scalar d6m08=	1.0000000000	;
scalar d6m09=	1.0049108739	;
scalar d6m10=	1.0097440440	;
scalar d6m11=	1.0137147031	;
		
*Rubro 6 semestral, Transporte;		
scalar d6s02=	0.9749314912	;
scalar d6s03=	0.9796636466	;
scalar d6s04=	0.9851637735	;
scalar d6s05=	0.9917996695	;
		
*Rubro 7 mensual, Educación y esparcimiento;		
scalar d7m07=	0.9997765641	;
scalar d7m08=	1.0000000000	;
scalar d7m09=	1.0128930818	;
scalar d7m10=	1.0131744455	;
scalar d7m11=	1.0158805031	;
		
*Rubro 2.3 mensual, Accesorios y cuidados del vestido;		
scalar d23m07=	0.9923456541	;
scalar d23m08=	1.0000000000	;
scalar d23m09=	1.0029207372	;
scalar d23m10=	1.0029710948	;
scalar d23m11=	1.0057155806	;
		
*Rubro 2.3 trimestral,  Accesorios y cuidados del vestido;		
scalar d23t05=	0.9913748727	;
scalar d23t06=	0.9950229966	;
scalar d23t07=	0.9984221305	;
scalar d23t08=	1.0019639440	;
		
*INPC semestral;		
scalar dINPCs02=	0.9973343817	;
scalar dINPCs03=	0.9973929361	;
scalar dINPCs04=	0.9982238506	;
scalar dINPCs05=	1.0006008794	;


*Una vez definidos los deflactores, se seleccionan los rubros;

gen double gasnomon=gas_nm_tri/3;

gen esp=1 if tipo_gasto=="G4";
gen reg=1 if tipo_gasto=="G5";
replace reg=1 if tipo_gasto=="G6";

****************************************************************************************************************************************************;
*Esta sección se cambia con respecto a la de CONEVAL;
gen consumo=1 if tipo_gasto=="G1";
replace consumo=1 if tipo_gasto=="G2";

gen double gastomon=gasto_tri/3;

save "$bases\gasto.dta", replace;

use "$bases\gasto.dta", clear;

****************************************************************************************************************************************************;

drop if tipo_gasto=="G2" | tipo_gasto=="G3" | tipo_gasto=="G7";

*Control para la frecuencia de los regalos recibidos por el hogar;
drop if ((frecuencia>="5" & frecuencia<="6") | frecuencia==" " | frecuencia=="0") & base==1 & tipo_gasto=="G5";

*Control para la frecuencia de los regalos recibidos por persona;

drop if ((frecuencia=="9") | frecuencia==" ") & base==2 & tipo_gasto=="G5";

*Gasto en Alimentos deflactado (semanal) ;

gen ali_nm=gasnomon if (clave>="A001" & clave<="A222") | 
(clave>="A242" & clave<="A247");

replace ali_nm=ali_nm/d11w08 if decena==1;
replace ali_nm=ali_nm/d11w08 if decena==2;
replace ali_nm=ali_nm/d11w08 if decena==3;
replace ali_nm=ali_nm/d11w09 if decena==4;
replace ali_nm=ali_nm/d11w09 if decena==5;
replace ali_nm=ali_nm/d11w09 if decena==6;
replace ali_nm=ali_nm/d11w10 if decena==7;
replace ali_nm=ali_nm/d11w10 if decena==8;
replace ali_nm=ali_nm/d11w10 if decena==9;
replace ali_nm=ali_nm/d11w11 if decena==0;

*Gasto en Alcohol y tabaco deflactado (semanal);

gen alta_nm=gasnomon if (clave>="A223" & clave<="A241");

replace alta_nm=alta_nm/d12w08 if decena==1;
replace alta_nm=alta_nm/d12w08 if decena==2;
replace alta_nm=alta_nm/d12w08 if decena==3;
replace alta_nm=alta_nm/d12w09 if decena==4;
replace alta_nm=alta_nm/d12w09 if decena==5;
replace alta_nm=alta_nm/d12w09 if decena==6;
replace alta_nm=alta_nm/d12w10 if decena==7;
replace alta_nm=alta_nm/d12w10 if decena==8;
replace alta_nm=alta_nm/d12w10 if decena==9;
replace alta_nm=alta_nm/d12w11 if decena==0;

*Gasto en Vestido y calzado deflactado (trimestral);

gen veca_nm=gasnomon if (clave>="H001" & clave<="H122") | 
(clave=="H136");

replace veca_nm=veca_nm/d2t05 if decena==1;
replace veca_nm=veca_nm/d2t05 if decena==2;
replace veca_nm=veca_nm/d2t06 if decena==3;
replace veca_nm=veca_nm/d2t06 if decena==4;
replace veca_nm=veca_nm/d2t06 if decena==5;
replace veca_nm=veca_nm/d2t07 if decena==6;
replace veca_nm=veca_nm/d2t07 if decena==7;
replace veca_nm=veca_nm/d2t07 if decena==8;
replace veca_nm=veca_nm/d2t08 if decena==9;
replace veca_nm=veca_nm/d2t08 if decena==0;

*Gasto en viviendas y servicios de conservación deflactado (mensual);

gen viv_nm=gasnomon if (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") 
						| clave=="R013";

replace viv_nm=viv_nm/d3m07 if decena==1;
replace viv_nm=viv_nm/d3m07 if decena==2;
replace viv_nm=viv_nm/d3m08 if decena==3;
replace viv_nm=viv_nm/d3m08 if decena==4;
replace viv_nm=viv_nm/d3m08 if decena==5;
replace viv_nm=viv_nm/d3m09 if decena==6;
replace viv_nm=viv_nm/d3m09 if decena==7;
replace viv_nm=viv_nm/d3m09 if decena==8;
replace viv_nm=viv_nm/d3m10 if decena==9;
replace viv_nm=viv_nm/d3m10 if decena==0;

*Gasto en Artículos de limpieza deflactado (mensual);

gen lim_nm=gasnomon if (clave>="C001" & clave<="C024");

replace lim_nm=lim_nm/d42m07 if decena==1;
replace lim_nm=lim_nm/d42m07 if decena==2;
replace lim_nm=lim_nm/d42m08 if decena==3;
replace lim_nm=lim_nm/d42m08 if decena==4;
replace lim_nm=lim_nm/d42m08 if decena==5;
replace lim_nm=lim_nm/d42m09 if decena==6;
replace lim_nm=lim_nm/d42m09 if decena==7;
replace lim_nm=lim_nm/d42m09 if decena==8;
replace lim_nm=lim_nm/d42m10 if decena==9;
replace lim_nm=lim_nm/d42m10 if decena==0;

*Gasto en Cristalería y blancos deflactado (trimestral);

gen cris_nm=gasnomon if (clave>="I001" & clave<="I026");

replace cris_nm=cris_nm/d42t05 if decena==1;
replace cris_nm=cris_nm/d42t05 if decena==2;
replace cris_nm=cris_nm/d42t06 if decena==3;
replace cris_nm=cris_nm/d42t06 if decena==4;
replace cris_nm=cris_nm/d42t06 if decena==5;
replace cris_nm=cris_nm/d42t07 if decena==6;
replace cris_nm=cris_nm/d42t07 if decena==7;
replace cris_nm=cris_nm/d42t07 if decena==8;
replace cris_nm=cris_nm/d42t08 if decena==9;
replace cris_nm=cris_nm/d42t08 if decena==0;

*Gasto en Enseres domésticos y muebles deflactado (semestral);

gen ens_nm=gasnomon if (clave>="K001" & clave<="K037");

replace ens_nm=ens_nm/d41s02 if decena==1;
replace ens_nm=ens_nm/d41s02 if decena==2;
replace ens_nm=ens_nm/d41s03 if decena==3;
replace ens_nm=ens_nm/d41s03 if decena==4;
replace ens_nm=ens_nm/d41s03 if decena==5;
replace ens_nm=ens_nm/d41s04 if decena==6;
replace ens_nm=ens_nm/d41s04 if decena==7;
replace ens_nm=ens_nm/d41s04 if decena==8;
replace ens_nm=ens_nm/d41s05 if decena==9;
replace ens_nm=ens_nm/d41s05 if decena==0;

*Gasto en Salud deflactado (trimestral);

gen sal_nm=gasnomon if (clave>="J001" & clave<="J072");

replace sal_nm=sal_nm/d51t05 if decena==1;
replace sal_nm=sal_nm/d51t05 if decena==2;
replace sal_nm=sal_nm/d51t06 if decena==3;
replace sal_nm=sal_nm/d51t06 if decena==4;
replace sal_nm=sal_nm/d51t06 if decena==5;
replace sal_nm=sal_nm/d51t07 if decena==6;
replace sal_nm=sal_nm/d51t07 if decena==7;
replace sal_nm=sal_nm/d51t07 if decena==8;
replace sal_nm=sal_nm/d51t08 if decena==9;
replace sal_nm=sal_nm/d51t08 if decena==0;

*Gasto en Transporte público deflactado (semanal);

gen tpub_nm=gasnomon if (clave>="B001" & clave<="B007");

replace tpub_nm=tpub_nm/d611w08 if decena==1;
replace tpub_nm=tpub_nm/d611w08 if decena==2;
replace tpub_nm=tpub_nm/d611w08 if decena==3;
replace tpub_nm=tpub_nm/d611w09 if decena==4;
replace tpub_nm=tpub_nm/d611w09 if decena==5;
replace tpub_nm=tpub_nm/d611w09 if decena==6;
replace tpub_nm=tpub_nm/d611w10 if decena==7;
replace tpub_nm=tpub_nm/d611w10 if decena==8;
replace tpub_nm=tpub_nm/d611w10 if decena==9;
replace tpub_nm=tpub_nm/d611w11 if decena==0;


*Gasto en Transporte foráneo deflactado (semestral);

gen tfor_nm=gasnomon if (clave>="M001" & clave<="M018") | 
(clave>="F007" & clave<="F014");

replace tfor_nm=tfor_nm/d6s02 if decena==1;
replace tfor_nm=tfor_nm/d6s02 if decena==2;
replace tfor_nm=tfor_nm/d6s03 if decena==3;
replace tfor_nm=tfor_nm/d6s03 if decena==4;
replace tfor_nm=tfor_nm/d6s03 if decena==5;
replace tfor_nm=tfor_nm/d6s04 if decena==6;
replace tfor_nm=tfor_nm/d6s04 if decena==7;
replace tfor_nm=tfor_nm/d6s04 if decena==8;
replace tfor_nm=tfor_nm/d6s05 if decena==9;
replace tfor_nm=tfor_nm/d6s05 if decena==0;

*Gasto en Comunicaciones deflactado (mensual);

gen com_nm=gasnomon if (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008")
| (clave>="R010" & clave<="R011");

replace com_nm=com_nm/d6m07 if decena==1;
replace com_nm=com_nm/d6m07 if decena==2;
replace com_nm=com_nm/d6m08 if decena==3;
replace com_nm=com_nm/d6m08 if decena==4;
replace com_nm=com_nm/d6m08 if decena==5;
replace com_nm=com_nm/d6m09 if decena==6;
replace com_nm=com_nm/d6m09 if decena==7;
replace com_nm=com_nm/d6m09 if decena==8;
replace com_nm=com_nm/d6m10 if decena==9;
replace com_nm=com_nm/d6m10 if decena==0;

*Gasto en Educación y recreación deflactado (mensual);

gen edre_nm=gasnomon if (clave>="E001" & clave<="E034") | 
(clave>="H134" & clave<="H135") | (clave>="L001" & 
clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009";

replace edre_nm=edre_nm/d7m07 if decena==1;
replace edre_nm=edre_nm/d7m07 if decena==2;
replace edre_nm=edre_nm/d7m08 if decena==3;
replace edre_nm=edre_nm/d7m08 if decena==4;
replace edre_nm=edre_nm/d7m08 if decena==5;
replace edre_nm=edre_nm/d7m09 if decena==6;
replace edre_nm=edre_nm/d7m09 if decena==7;
replace edre_nm=edre_nm/d7m09 if decena==8;
replace edre_nm=edre_nm/d7m10 if decena==9;
replace edre_nm=edre_nm/d7m10 if decena==0;

*Gasto en Educación básica deflactado (mensual);

gen edba_nm=gasnomon if (clave>="E002" & clave<="E003") | 
(clave>="H134" & clave<="H135");

replace edba_nm=edba_nm/d7m07 if decena==1;
replace edba_nm=edba_nm/d7m07 if decena==2;
replace edba_nm=edba_nm/d7m08 if decena==3;
replace edba_nm=edba_nm/d7m08 if decena==4;
replace edba_nm=edba_nm/d7m08 if decena==5;
replace edba_nm=edba_nm/d7m09 if decena==6;
replace edba_nm=edba_nm/d7m09 if decena==7;
replace edba_nm=edba_nm/d7m09 if decena==8;
replace edba_nm=edba_nm/d7m10 if decena==9;
replace edba_nm=edba_nm/d7m10 if decena==0;

*Gasto en Cuidado personal deflactado (mensual);

gen cuip_nm=gasnomon if (clave>="D001" & clave<="D026") | 
(clave=="H132");

replace cuip_nm=cuip_nm/d23m07 if decena==1;
replace cuip_nm=cuip_nm/d23m07 if decena==2;
replace cuip_nm=cuip_nm/d23m08 if decena==3;
replace cuip_nm=cuip_nm/d23m08 if decena==4;
replace cuip_nm=cuip_nm/d23m08 if decena==5;
replace cuip_nm=cuip_nm/d23m09 if decena==6;
replace cuip_nm=cuip_nm/d23m09 if decena==7;
replace cuip_nm=cuip_nm/d23m09 if decena==8;
replace cuip_nm=cuip_nm/d23m10 if decena==9;
replace cuip_nm=cuip_nm/d23m10 if decena==0;

*Gasto en Accesorios personales deflactado (trimestral);

gen accp_nm=gasnomon if (clave>="H123" & clave<="H131") | 
(clave=="H133");

replace accp_nm=accp_nm/d23t05 if decena==1;
replace accp_nm=accp_nm/d23t05 if decena==2;
replace accp_nm=accp_nm/d23t06 if decena==3;
replace accp_nm=accp_nm/d23t06 if decena==4;
replace accp_nm=accp_nm/d23t06 if decena==5;
replace accp_nm=accp_nm/d23t07 if decena==6;
replace accp_nm=accp_nm/d23t07 if decena==7;
replace accp_nm=accp_nm/d23t07 if decena==8;
replace accp_nm=accp_nm/d23t08 if decena==9;
replace accp_nm=accp_nm/d23t08 if decena==0;

*Gasto en Otros gastos y transferencias deflactado (semestral);

gen otr_nm=gasnomon if (clave>="N001" & clave<="N002") | 
(clave>="N006" & clave<="N016") | (clave>="T901" & 
clave<="T915") | (clave=="R012");

replace otr_nm=otr_nm/dINPCs02 if decena==1;
replace otr_nm=otr_nm/dINPCs02 if decena==2;
replace otr_nm=otr_nm/dINPCs03 if decena==3;
replace otr_nm=otr_nm/dINPCs03 if decena==4;
replace otr_nm=otr_nm/dINPCs03 if decena==5;
replace otr_nm=otr_nm/dINPCs04 if decena==6;
replace otr_nm=otr_nm/dINPCs04 if decena==7;
replace otr_nm=otr_nm/dINPCs04 if decena==8;
replace otr_nm=otr_nm/dINPCs05 if decena==9;
replace otr_nm=otr_nm/dINPCs05 if decena==0;

*Gasto en Regalos Otorgados deflactado;

gen reda_nm=gasnomon if (clave>="T901" & clave<="T915") | (clave=="N013");

replace reda_nm=reda_nm/dINPCs02 if decena==1;
replace reda_nm=reda_nm/dINPCs02 if decena==2;
replace reda_nm=reda_nm/dINPCs03 if decena==3;
replace reda_nm=reda_nm/dINPCs03 if decena==4;
replace reda_nm=reda_nm/dINPCs03 if decena==5;
replace reda_nm=reda_nm/dINPCs04 if decena==6;
replace reda_nm=reda_nm/dINPCs04 if decena==7;
replace reda_nm=reda_nm/dINPCs04 if decena==8;
replace reda_nm=reda_nm/dINPCs05 if decena==9;
replace reda_nm=reda_nm/dINPCs05 if decena==0;

save "$bases\ingresonomonetario_def16.dta", replace;

use "$bases\ingresonomonetario_def16.dta", clear;

*Construcción de la base de pagos en especie a partir de la base 
de gasto no monetario;

keep if esp==1;

collapse (sum) *_nm, by( folioviv foliohog);

rename  ali_nm ali_nme;
rename  alta_nm alta_nme;
rename  veca_nm veca_nme;
rename  viv_nm viv_nme;
rename  lim_nm lim_nme;
rename  cris_nm cris_nme;
rename  ens_nm ens_nme;
rename  sal_nm sal_nme;
rename  tpub_nm tpub_nme;
rename  tfor_nm tfor_nme;
rename  com_nm com_nme; 
rename  edre_nm edre_nme;
rename  edba_nm edba_nme;
rename  cuip_nm cuip_nme;
rename  accp_nm accp_nme;
rename  otr_nm otr_nme;
rename  reda_nm reda_nme;

sort  folioviv foliohog;

save "$bases\esp_def16.dta", replace;

use "$bases\ingresonomonetario_def16.dta", clear;

*Construcción de base de regalos a partir de la base no 
monetaria ;

keep if reg==1;

collapse (sum) *_nm, by( folioviv foliohog);

rename  ali_nm ali_nmr;
rename  alta_nm alta_nmr;
rename  veca_nm veca_nmr;
rename  viv_nm viv_nmr;
rename  lim_nm lim_nmr;
rename  cris_nm cris_nmr;
rename  ens_nm ens_nmr;
rename  sal_nm sal_nmr;
rename  tpub_nm tpub_nmr;
rename  tfor_nm tfor_nmr;
rename  com_nm com_nmr; 
rename  edre_nm edre_nmr;
rename  edba_nm edba_nmr;
rename  cuip_nm cuip_nmr;
rename  accp_nm accp_nmr;
rename  otr_nm otr_nmr;
rename  reda_nm reda_nmr;

sort  folioviv foliohog;

save "$bases\reg_def16.dta", replace;


****************************************************************************************************************************************************;

*********************************************************

Construcción del ingreso corriente total

*********************************************************;

use "$original\concentradohogar.dta", clear;

keep  folioviv foliohog tam_loc factor tot_integ est_dis upm ubica_geo;

*Incorporación de la base de ingreso monetario deflactado;

sort  folioviv foliohog;

merge  folioviv foliohog using "$bases\ingreso_monetario_hogar.dta";
tab _merge;
drop _merge;

*Incorporación de la base de ingreso no monetario deflactado: pago en especie;

sort  folioviv foliohog;

merge  folioviv foliohog using "$bases\esp_def16.dta";
tab _merge;
drop _merge;

*Incorporación de la base de ingreso no monetario deflactado: regalos en especie;

sort  folioviv foliohog;

merge  folioviv foliohog using "$bases\reg_def16.dta";
tab _merge;
drop _merge;

gen rururb=1 if tam_loc=="4";
replace rururb=0 if tam_loc<="3";
label define rururb 1 "Rural" 
                    0 "Urbano";
label value rururb rururb;

egen double pago_esp=rsum(ali_nme alta_nme veca_nme 
viv_nme lim_nme ens_nme cris_nme sal_nme 
tpub_nme tfor_nme com_nme edre_nme cuip_nme 
accp_nme otr_nme);

egen double reg_esp=rsum(ali_nmr alta_nmr veca_nmr 
viv_nmr lim_nmr ens_nmr cris_nmr sal_nmr 
tpub_nmr tfor_nmr com_nmr edre_nmr cuip_nmr 
accp_nmr otr_nmr);

egen double nomon=rsum(pago_esp reg_esp);

egen double ict=rsum(ing_mon nomon);

label var ict "Ingreso corriente total del hogar";
label var nomon "Ingreso corriente no monetario del hogar";
label var pago_esp "Ingreso corriente no monetario pago especie del hogar";
label var reg_esp "Ingreso corriente no monetario regalos especie del hogar";

sort  folioviv foliohog;

save "$bases\ingresotot16.dta", replace;

***********************************************************

Construcción del tamaño de hogar con economías de escala
y escalas de equivalencia

***********************************************************;

use "$original\poblacion.dta", clear;
*Población objetivo: no se incluye a huéspedes ni trabajadores domésticos;

drop if parentesco>="400" & parentesco <"500";
drop if parentesco>="700" & parentesco <"800";

*Total de integrantes del hogar;
gen ind=1;
egen tot_ind=sum(ind), by (folioviv foliohog);

*************************
*Escalas de equivalencia*
*************************;

gen n_05=.;
replace n_05=1 if edad>=0 & edad<=5;
recode n_05 (.=0) if edad!=.;

gen n_6_12=0;
replace n_6_12=1 if edad>=6 & edad<=12;
recode n_6_12 (.=0) if edad!=.;

gen n_13_18=0;
replace n_13_18=1 if edad>=13 & edad<=18;
recode n_13_18 (.=0) if edad!=.;

gen n_19_64=0;
replace n_19_64=1 if edad>=19 & edad<=64;
recode n_19_64 (.=0) if edad!=.;

gen n_65=0;
replace n_65=1 if edad>=65 & edad<.;
recode n_65 (.=0) if edad!=.;

gen tamhogesc_1=n_05*.4315814;
replace tamhogesc_1=n_6_12*.8531331 if n_6_12==1;
replace tamhogesc_1=n_13_18*.8281782 if n_13_18==1;
replace tamhogesc_1=n_19_64*1 if n_19_64==1;
replace tamhogesc_1=n_65*.6785257 if n_65==1 ;
replace tamhogesc_1=1 if tot_ind==1;

collapse (sum)  tamhogesc_1, by( folioviv foliohog);

sort folioviv foliohog;

save "$bases\tamhogesc16.dta", replace;

*************************************************************************

*Bienestar por ingresos

*************************************************************************;

use "$bases\ingresotot16.dta", clear;

*Incorporación de la información sobre el tamaño del hogar ajustado;

merge  folioviv foliohog using "$bases\tamhogesc16.dta";
tab _merge;
drop _merge;

*Información per capita;

gen double ictpc= ict/tamhogesc_1;

label var  ictpc "Ingreso corriente total per capita";

*Aquí nos quedamos con las variables relevantes a nivel hogar;

keep folioviv foliohog nomon ict tamhogesc_1 ictpc;


sort folioviv foliohog;
save "$bases\ingreso_total_escalado.dta", replace;

****************************************************************************************************************************************************;
****************************************************************************************************************************************************;
****************************************************************************************************************************************************;
*Aquí se construye el gasto monetario del hogar;

use "$bases\gasto.dta", clear;

keep if gastomon>0 & gastomon!=.;

tab tipo_gasto;

*Alimentos (ali_dentro, ali_fuera, tabaco, bebidas alcoholicas);
*1.1 Deflactor de Alimentos;
replace gastomon=gastomon/d11w08 if decena==1 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w08 if decena==2 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w08 if decena==3 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w09 if decena==4 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w09 if decena==5 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w09 if decena==6 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w10 if decena==7 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w10 if decena==8 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w10 if decena==9 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );
replace gastomon=gastomon/d11w11 if decena==0 & ( (clave>="A001" & clave<="A222") | (clave>="A242" & clave<="A247") );

gen cereales=gastomon if (clave>="A001" & clave<="A024");
gen carnes=gastomon if (clave>="A025" & clave<="A065");
gen pescados_mariscos=gastomon if (clave>="A066" & clave<="A074");
gen leche_derivados=gastomon if (clave>="A075" & clave<="A092");
gen huevo=gastomon if clave=="A093" | clave=="A094";
gen aceites=gastomon if (clave>="A095" & clave<="A100");
gen tuberculo=gastomon if (clave>="A101" & clave<="A106");
gen verduras=gastomon if (clave>="A107" & clave<="A146");
gen frutas=gastomon if (clave>="A147" & clave<="A172");
gen azucar=gastomon if (clave>="A173" & clave<="A175");
gen cafe=gastomon if (clave>="A176" & clave<="A182");
gen especias=gastomon if (clave>="A183" & clave<="A194");
gen otros_alimentos_diversos=gastomon if (clave>="A195" & clave<="A214") | clave=="A242";
gen bebidas_no_alcoholicas=gastomon if (clave>="A215" & clave<="A222");

recode cereales carnes pescados_mariscos leche_derivados huevo aceites tuberculo verduras frutas azucar cafe especias otros_alimentos_diversos bebidas_no_alcoholicas ( . = 0 );

gen ali_dentro=cereales+carnes+pescados_mariscos+leche_derivados+huevo+aceites+tuberculo+verduras+
               frutas+azucar+cafe+especias+otros_alimentos_diversos+bebidas_no_alcoholicas;
recode ali_dentro(. = 0);		   

gen ali_fuera=gastomon if (clave>="A243" & clave<="A247"); 						   
recode ali_fuera (. = 0);

gen alimentos= ali_dentro+ali_fuera;
recode alimentos (. = 0);

*1.2 Gasto en Alcohol y tabaco deflactado (semanal);
replace gastomon=gastomon/d12w08 if decena==1 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w08 if decena==2 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w08 if decena==3 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w09 if decena==4 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w09 if decena==5 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w09 if decena==6 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w10 if decena==7 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w10 if decena==8 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w10 if decena==9 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );
replace gastomon=gastomon/d12w11 if decena==0 & ( (clave>="A239" & clave<="A241") | (clave>="A223" & clave<="A238") );

gen tabaco=gastomon if (clave>="A239" & clave<="A241");
gen alcoholicas=gastomon if (clave>="A223" & clave<="A238");
recode tabaco alcoholicas (. = 0);

gen tab_alcoh= tabaco+alcoholicas;
recode tab_alcoh (. = 0);

 
*2 Gasto en Vestido y calzado deflactado (trimestral);

replace gastomon=gastomon/d2t05 if decena==1 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t05 if decena==2 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t06 if decena==3 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t06 if decena==4 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t06 if decena==5 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t07 if decena==6 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t07 if decena==7 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t07 if decena==8 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t08 if decena==9 & ( (clave>="H001" & clave<="H122") | clave=="H136" );
replace gastomon=gastomon/d2t08 if decena==0 & ( (clave>="H001" & clave<="H122") | clave=="H136" );

*vestido (hombres 0 a 4, 5 a 17 y 18 o más años); 
gen hvestido0_4=gastomon if (clave>="H001" & clave<="H013");
gen hvestido5_17=gastomon if (clave>="H028" & clave<="H039");
gen hvestido18_mas=gastomon if (clave>="H056" & clave<="H067");
gen mvestido0_4=gastomon if (clave>="H014" & clave<="H027");
gen mvestido5_17=gastomon if (clave>="H040" & clave<="H055");
gen mvestido18_mas=gastomon if (clave>="H068" & clave<="H083");
gen hcalzado0_4=gastomon if (clave>="H084" & clave<="H089");
gen hcalzado5_17=gastomon if (clave>="H096" & clave<="H101");
gen hcalzado18_mas=gastomon if (clave>="H108" & clave<="H113");
gen mcalzado0_4=gastomon if (clave>="H090" & clave<="H095");
gen mcalzado5_17=gastomon if (clave>="H102" & clave<="H107");
gen mcalzado18_mas=gastomon if (clave>="H114" & clave<="H119");
gen reparacion_calzado=gastomon if (clave>="H120" & clave<="H122");
gen telas_reparaciones=gastomon if clave=="H136";

recode hvestido0_4 hvestido5_17 hvestido18_mas mvestido0_4 mvestido5_17 mvestido18_mas hcalzado0_4 hcalzado5_17 hcalzado18_mas 
        mcalzado0_4 mcalzado5_17 mcalzado18_mas reparacion_calzado telas_reparaciones (. = 0);

gen vestido_hombre=hvestido0_4+hvestido5_17+hvestido18_mas;
gen vestido_mujer=mvestido0_4+mvestido5_17+mvestido18_mas;
gen calzado_hombre=hcalzado0_4+hcalzado5_17+hcalzado18_mas;
gen calzado_mujer=mcalzado0_4+mcalzado5_17+mcalzado18_mas;

gen vestido= vestido_hombre+vestido_mujer;
gen calzado=calzado_hombre+calzado_mujer;

recode vestido_hombre vestido_mujer calzado_hombre calzado_mujer vestido calzado (.=0);

gen vesti_calz=vestido+calzado+reparacion_calzado+telas_reparaciones;
recode vesti_calz (. = 0);

*3 Gasto en viviendas y servicios de conservación deflactado (mensual);
replace gastomon=gastomon/d3m07 if decena==1 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m07 if decena==2 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m08 if decena==3 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m08 if decena==4 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m08 if decena==5 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m09 if decena==6 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m09 if decena==7 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m09 if decena==8 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m10 if decena==9 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );
replace gastomon=gastomon/d3m10 if decena==0 & ( (clave>="G001" & clave<="G016") | (clave>="R001" & clave<="R004") | clave=="R013" | (clave>="K038" & clave<="K045") );

*vivienda(alquiler,pred_cons,agua, energia, alarmas);
gen alquiler=gastomon if ( (clave>="G001" & clave<="G004") | clave=="G101" );
gen pred_cons=gastomon if ( (clave>="G005" & clave<="G008") | clave=="R004" );
gen agua=gastomon if clave=="R002";
gen energia=gastomon if ( (clave>="G009" & clave<="G016") | clave=="R001"| clave=="R003" );
gen alarma= gastomon if clave=="R013";
gen mant_const=gastomon if clave>="K038" & clave<="K045";

recode alquiler pred_cons agua energia alarma mant_const( . = 0 );

gen vivienda=alquiler+pred_cons+agua+energia + alarma + mant_const;
recode vivienda ( . = 0 );

*4.2 (Hogar) Gasto en Artículos de limpieza deflactado (mensual);
replace gastomon=gastomon/d42m07 if decena==1 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m07 if decena==2 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m08 if decena==3 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m08 if decena==4 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m08 if decena==5 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m09 if decena==6 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m09 if decena==7 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m09 if decena==8 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m10 if decena==9 & (clave>="C001" & clave<="C024");
replace gastomon=gastomon/d42m10 if decena==0 & (clave>="C001" & clave<="C024");

replace gastomon=gastomon/d42t05 if decena==1 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t05 if decena==2 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t06 if decena==3 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t06 if decena==4 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t06 if decena==5 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t07 if decena==6 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t07 if decena==7 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t07 if decena==8 & (clave>="I001" & clave<="I026"); 
replace gastomon=gastomon/d42t08 if decena==9 & (clave>="I001" & clave<="I026");
replace gastomon=gastomon/d42t08 if decena==0 & (clave>="I001" & clave<="I026");

replace gastomon=gastomon/d41s02 if decena==1 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s02 if decena==2 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s03 if decena==3 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s03 if decena==4 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s03 if decena==5 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s04 if decena==6 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s04 if decena==7 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s04 if decena==8 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s05 if decena==9 & (clave>="K001" & clave<="K037");
replace gastomon=gastomon/d41s05 if decena==0 & (clave>="K001" & clave<="K037");

*limpieza(cuidados,utensilios,enseres); 
gen limpieza=gastomon if (clave>="C001" & clave<="C024");
gen cristaleria=gastomon if (clave>="I001" & clave<="I026");
gen enseres=gastomon if (clave>="K001" & clave<="K037");

recode limpieza cristaleria enseres( . = 0 );

gen hogar=limpieza+cristaleria+enseres;
recode limpieza ( . = 0 );

*5.1 (Salud) Gasto en Salud deflactado (trimestral);
replace gastomon=gastomon/d51t05 if decena==1 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t05 if decena==2 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t06 if decena==3 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t06 if decena==4 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t06 if decena==5 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t07 if decena==6 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t07 if decena==7 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t07 if decena==8 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t08 if decena==9 & (clave>="J001" & clave<="J072");
replace gastomon=gastomon/d51t08 if decena==0 & (clave>="J001" & clave<="J072");

*Cuidados de la salud(atenc_ambu,hospital,medicinas);
gen atenc_ambu=gastomon if (clave>="J016" & clave<="J043");
gen hospital=gastomon if ( (clave>="J001" & clave<="J015") | (clave>="J070" & clave<="J072") );
gen medicinas=gastomon if (clave>="J044" & clave<="J069");

recode atenc_ambu hospital medicinas ( . = 0 );

gen salud= atenc_ambu+hospital+medicinas; 
recode salud ( . = 0 );

*6.1 (Transporte) Transporte(publico, foraneo,adqui_vehi,refaccion,combus,comunica);
replace gastomon=gastomon/d611w08 if decena==1 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w08 if decena==2 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w08 if decena==3 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w09 if decena==4 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w09 if decena==5 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w09 if decena==6 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w10 if decena==7 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w10 if decena==8 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w10 if decena==9 & (clave>="B001" & clave<="B007");
replace gastomon=gastomon/d611w11 if decena==0 & (clave>="B001" & clave<="B007");

replace gastomon=gastomon/d6s02 if decena==1 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s02 if decena==2 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s03 if decena==3 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s03 if decena==4 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s03 if decena==5 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s04 if decena==6 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s04 if decena==7 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s04 if decena==8 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s05 if decena==9 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );
replace gastomon=gastomon/d6s05 if decena==0 & ( (clave>="M001" & clave<="M018") | (clave>="F007" & clave<="F014") );

replace gastomon=gastomon/d6m07 if decena==1 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m07 if decena==2 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m08 if decena==3 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m08 if decena==4 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m08 if decena==5 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m09 if decena==6 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m09 if decena==7 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m09 if decena==8 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m10 if decena==9 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );
replace gastomon=gastomon/d6m10 if decena==0 & ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );

gen publico=gastomon if (clave>="B001" & clave<="B007");
gen foraneo=gastomon if (clave>="M001" & clave<="M006");
gen adqui_vehi=gastomon if (clave>="M007" & clave<="M011");
gen refaccion=gastomon if (clave>="M012" & clave<="M018");
gen combus=gastomon if (clave>="F007" & clave<="F014");
gen comunica=gastomon if ( (clave>="F001" & clave<="F006") | (clave>="R005" & clave<="R008") | (clave>="R010" & clave<="R011") );

recode publico foraneo adqui_vehi refaccion  combus comunica( . = 0 );

gen transporte= publico+foraneo+adqui_vehi+refaccion+combus+comunica; 
recode transporte ( . = 0 );

*7 Gasto en Educación y recreación deflactado (mensual); 
replace gastomon=gastomon/d7m07 if decena==1 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m07 if decena==2 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m08 if decena==3 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m08 if decena==4 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m08 if decena==5 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m09 if decena==6 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m09 if decena==7 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m09 if decena==8 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m10 if decena==9 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );
replace gastomon=gastomon/d7m10 if decena==0 & ( (clave>="E001" & clave<="E034") | (clave>="H134" & clave<="H135") | (clave>="L001" & clave<="L029") | (clave>="N003" & clave<="N005") | clave=="R009" );

*Educacion y esparcimiento;
gen educacion=gastomon if ( (clave>="E001" & clave<="E021")| clave=="H134" | clave=="H135" );
gen esparci=gastomon if ( (clave>="E022" & clave<="E034") | (clave>="L001" & clave<="L029") | clave=="R009" | clave=="N005" );
gen paq_turist=gastomon if (clave>="N003" & clave<="N004");

recode educacion esparci paq_turist ( . = 0 );

gen educa_espa=educacion+esparci+paq_turist; 
recode educa_espa ( . = 0 );

*8.1 Gasto en Cuidado personal deflactado (mensual);

replace gastomon=gastomon/d23m07 if decena==1 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m07 if decena==2 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m08 if decena==3 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m08 if decena==4 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m08 if decena==5 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m09 if decena==6 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m09 if decena==7 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m09 if decena==8 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m10 if decena==9 & ( (clave>="D001" & clave<="D026") | clave=="H132" );
replace gastomon=gastomon/d23m10 if decena==0 & ( (clave>="D001" & clave<="D026") | clave=="H132" );

replace gastomon=gastomon/d23t05 if decena==1 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t05 if decena==2 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t06 if decena==3 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t06 if decena==4 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t06 if decena==5 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t07 if decena==6 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t07 if decena==7 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t07 if decena==8 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t08 if decena==9 & ( (clave>="H123" & clave<="H131") | clave=="H133" );
replace gastomon=gastomon/d23t08 if decena==0 & ( (clave>="H123" & clave<="H131") | clave=="H133" );

replace gastomon=gastomon/dINPCs02 if decena==1 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs02 if decena==2 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs03 if decena==3 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs03 if decena==4 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs03 if decena==5 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs04 if decena==6 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs04 if decena==7 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs04 if decena==8 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs05 if decena==9 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );
replace gastomon=gastomon/dINPCs05 if decena==0 & ( (clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N016") | (clave>="T901" & clave<="T915") | (clave=="R012") );


*Personales(cuida_pers,acces_pers,otros_gas); 
gen cuida_pers=gastomon if ( (clave>="D001" & clave<="D026") | clave=="H132" );
gen acces_pers=gastomon if ( (clave>="H123" & clave<="H131") | clave=="H133" );
gen otros_gas=gastomon if ( ( clave>="N001" & clave<="N002") | (clave>="N006" & clave<="N010") |  clave=="R012" );

recode cuida_pers acces_pers otros_gas ( . = 0 );

gen personales=cuida_pers+acces_pers+otros_gas; 
recode personales ( . = 0 );

*Transferencias de gasto; 
gen transf_gas=gastomon if ( (clave>="N011" & clave<="N016") | (clave>="T901" & clave<="T915") );
recode transf_gas ( . = 0 );

*Gasto corriente monetario;
gen gasto_mon= alimentos + tab_alcoh + vesti_calz + vivienda + hogar + salud + transporte + educa_espa + personales + transf_gas;

gen total= gastomon if (clave!="G102" & clave!="G103" & clave!="G104" & clave!="G105" & clave!="G106" & clave!="T916");
recode total ( . = 0 );

tabstat gasto_mon total, stats(sum);

*Estimacion del gasto corriente monetario para del hogar; 

collapse (sum) cereales carnes pescados_mariscos leche_derivados huevo aceites tuberculo verduras frutas azucar cafe especias otros_alimentos_diversos bebidas_no_alcoholicas ali_dentro ali_fuera alimentos
			   tabaco alcoholicas tab_alcoh
			   hvestido0_4 hvestido5_17 hvestido18_mas mvestido0_4 mvestido5_17 mvestido18_mas hcalzado0_4 hcalzado5_17 hcalzado18_mas mcalzado0_4 mcalzado5_17 mcalzado18_mas reparacion_calzado telas_reparaciones vestido_hombre vestido_mujer vestido calzado_hombre calzado_mujer calzado vesti_calz
			   alquiler pred_cons agua energia alarma mant_const vivienda
			   limpieza cristaleria enseres hogar
			   atenc_ambu hospital medicinas salud
			   publico foraneo adqui_vehi refaccion combus comunica transporte
			   educacion esparci paq_turist educa_espa
			   cuida_pers acces_pers otros_gas personales
			   transf_gas
			   gasto_mon total, by (folioviv foliohog); 


save "$bases\gasto_monetario_hogar.dta", replace;


**************************************************************************************************************************;
************************************UNIÓN DE BASES DE DATOS (NIVEL PERSONA)***********************************************;
**************************************************************************************************************************;

*Aquí se combinan las bases de datos (la base principal es la población sin huespedes ni trabajadores domésticos creada arriba);
#delimit;
use "$bases\población.dta", clear;
sort folioviv foliohog numren;

merge 1:1 folioviv foliohog numren using "$bases\SAR_trabajo.dta";
gen trabaja=0;
replace trabaja=1 if _merge==3;
drop _merge;
recode sar (.=0);
merge m:1 folioviv foliohog using "$bases\variables_muestrales.dta";
drop _merge;
merge 1:1 folioviv foliohog numren using "$bases\ingreso_monetario_individual.dta";
drop _merge;
merge m:1 folioviv using "$bases\viviendas.dta";
drop _merge;
merge m:1 folioviv foliohog using "$bases\ingreso_total_escalado.dta";
drop _merge;

********************************************************************************;
*****************************Generación de variables****************************;
********************************************************************************;

*Aquí se substitueyen los "." por cero para quienes reportan ingreso positivo;
recode sueldos horext comisiones otra_rem trabajo industria comercio servicios noagrop agricolas
       pecuarios reproducc pesca agrope ganancias negocio aguinaldo rep_utilidades otros_trab laboral
	   propiedades financieras otras_rentas rentas contributivas no_contributivas pension indemnizaciones
	   becas donativos_no_gub donativos_otras_fam remesas bene_gob transfer otras_transfer ingreso_mon 
	
	   ing_lab ing_ren ing_tra ing_mon (.=0);
	   
**************Cobertura de pensión 65 y más************;
*Aquí se generan las variables de cobertura de pensión;
*Se segmenta por quienes tienen 1)solo pensión contributiva, 2) solo pensión no contrubutiva, 3) ambas tipos de pensión y 4) sin pensión;

gen clasificador=.;
*Solo pensión contributiva;
replace clasificador=1 if (contributivas>0 & contributivas!=.) & (no_contributivas==0 | no_contributivas==.) & edad>=65;
*Solo pensión no contrubutiva;
replace clasificador=2 if (no_contributivas>0 & no_contributivas!=.) & (contributivas==0 | contributivas==.) & edad>=65;
*Pensión contributiva y pensión no contributiva;
replace clasificador=3 if (contributivas>0 & contributivas!=.) & (no_contributivas>0 & no_contributivas!=.) & edad>=65;
*Sin pensión;
replace clasificador=4 if (contributivas==0 | contributivas==.) & (no_contributivas==0 | no_contributivas==.) & edad>=65;

label var clasificador "Cobertura de pensiones";
label define clasificador 1 "Contributiva" 
						  2 "No contributiva"
						  3 "Cont y no cont"
						  4 "Sin pensión";
label value clasificador clasificador;
tab clasificador [w=factor];

*Identificadores de pensión;
gen d_contributivas=0;
replace d_contributivas=1 if contributivas>0 & contributivas!=.;

gen d_no_contributivas=0;
replace d_no_contributivas=1 if no_contributivas>0 & no_contributivas!=.;

gen d_pension=0;
replace d_pension=1 if pension>0 & pension!=.;

gen d_sin_pension=0;
replace d_sin_pension=1 if pension==0 | pension==.; 

gen d_mujer=0.;
replace d_mujer=1 if sexo=="2";

gen d_hombre=0.;
replace d_hombre=1 if sexo=="1";

*Identificadores de trabajo a partir de ingresos laborales;
gen d_trabaja=0;
replace d_trabaja=1 if laboral>0 & contributivas!=.;


gen unos=1;

*NOTA: falta agregar labes;

**************Variables de ingreso************;

*Aquí se crea la variable de quintil/decil/cien de ingreso monetario individual;
xtile quintil_con_0 = ingreso_mon [w=factor] if edad>=65 & ingreso_mon!=., nq(5);
xtile quintil_sin_0 = ingreso_mon [w=factor] if edad>=65 & ingreso_mon>0, nq(5);

xtile decil_con_0   = ingreso_mon [w=factor] if edad>=65 & ingreso_mon!=., nq(10);
xtile decil_sin_0   = ingreso_mon [w=factor] if edad>=65 & ingreso_mon>0, nq(10);

xtile cien_sin_0    = ingreso_mon [w=factor] if edad>=65 & ingreso_mon>0 & ingreso_mon!=., nq(100); 
xtile cien_con_0    = ingreso_mon [w=factor] if edad>=65 & ingreso_mon!=., nq(100);


*Logaritmo del ingreso;
gen ln_ingreso_mon=ln(ingreso_mon);
gen ln_laboral=ln(laboral);
gen ln_rentas=ln(rentas);
gen ln_contributivas=ln(contributivas);
gen ln_no_contributivas=ln(no_contributivas);
gen ln_donativos_otras_fam=ln(donativos_otras_fam);
gen ln_otras_transfer=ln(otras_transfer);

*Fuente de ingreso como porcentaje del ingreso monetario;
gen p_laboral = laboral/ingreso_mon;
gen p_rentas = rentas/ingreso_mon;
gen p_contributivas = contributivas/ingreso_mon;
gen p_no_contributivas=no_contributivas/ingreso_mon;
gen p_donativos_otras_fam=donativos_otras_fam/ingreso_mon;
gen p_otras_transfer=otras_transfer/ingreso_mon;
gen p_ingreso_mon=ingreso_mon/ingreso_mon;

recode p_laboral
       p_rentas  
	   p_contributivas
	   p_no_contributivas
	   p_donativos_otras_fam
	   p_otras_transfer
	   p_ingreso_mon
	   (.=0);


**************Variables personales************;
*Edad;
gen rangos_edad=.;
replace rangos_edad=1 if edad>=65 & edad<=69;
replace rangos_edad=2 if edad>=70 & edad<=74;
replace rangos_edad=3 if edad>=75 & edad<=79;
replace rangos_edad=4 if edad>=80;

label define rangos_edad 1 "65-69"
                         2 "70-74"
						 3 "75-79"
						 4 "80 y más";
label value rangos_edad rangos_edad; 

*Sexo;
destring sexo, replace;
label define  sexo 1 "Hombres"
                   2 "Mujeres";
label value sexo sexo;



**************Combinaciones de ingreso************;
gen comb_ingreso=.;

*Solo laboral;
replace comb_ingreso=1 if ( laboral>0 & rentas==0 & contributivas==0 & no_contributivas==0 & donativos_otras_fam==0 & otras_transfer==0 ); 
*Pensión contributivas;
replace comb_ingreso=2 if ( laboral==0 & rentas==0 & contributivas>0 & no_contributivas==0 & donativos_otras_fam==0 & otras_transfer==0 ); 
*Pensión no contributivas;
replace comb_ingreso=3 if ( laboral==0 & rentas==0 & contributivas==0 & no_contributivas>0 & donativos_otras_fam==0 & otras_transfer==0 ); 
*Donativos de otras familias;
replace comb_ingreso=4 if ( laboral==0 & rentas==0 & contributivas==0 & no_contributivas==0 & donativos_otras_fam>0 & otras_transfer==0 ); 
*Laboral y pensión contributivas;
replace comb_ingreso=5 if ( laboral>0 & rentas==0 & contributivas>0 & no_contributivas==0 & donativos_otras_fam==0 & otras_transfer==0 ); 
*Laboral y pensión no contributivas;
replace comb_ingreso=6 if ( laboral>0 & rentas==0 & contributivas==0 & no_contributivas>0 & donativos_otras_fam==0 & otras_transfer==0 ); 
*Pensión contributiva y pensión no contributiva;
replace comb_ingreso=7 if ( laboral==0 & rentas==0 & contributivas>0 & no_contributivas>0 & donativos_otras_fam==0 & otras_transfer==0 ); 
*Otras combinaciones;
recode comb_ingreso (.=8);
*Sin ingreso;
replace comb_ingreso=9 if ( laboral==0 & rentas==0 & contributivas==0 & no_contributivas==0 & donativos_otras_fam==0 & otras_transfer==0 ); 

label define comb_ingreso 1 "Laboral"
                         2 "Pensión contributiva"
						 3 "Pensión no contributiva"
						 4 "Donativos de otras familias"
						 5 "Laboral y pensión contributiva"
						 6 "Laboral y pensión no contributiva"
						 7 "Pensión contributiva y pensión no contributiva"
						 8 "Otras combinaciones"
						 9 "Sin ingreso"
						 ;
label value comb_ingreso comb_ingreso;

tab comb_ingreso [w=factor] if edad>=65;

**************Variables de vivienda************;
tab tenencia [w=factor] if edad>=60;	

gen duenio=0;
replace duenio=1 if (foliohog==hog_dueno1 & numren==num_dueno1) | (foliohog==hog_dueno2 & numren==num_dueno2);

gen tipo_viv=.;

replace tipo_viv=1 if viv_prop==1 & duenio==1;
replace tipo_viv=2 if viv_prop==1 & duenio==0;
replace tipo_viv=3 if viv_prop==0;


label define tipo_viv 1"Vivienda propia y dueño"
                  2 "Vivienda propia y no dueño"
                  3 "Vivienda no propia";
label value tipo_viv tipo_viv;


save "$bases\base_individual.dta", replace;

export delimited using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\base_individual.csv", replace;

**************************************************************************************************************************;
************************FUENTES DE INGRESO MONETARIO (SEPARANDO POR EDAD DE LOS INTEGRANTES DEL HOGAR)********************;
**************************************************************************************************************************;

#delimit;
use "$bases\base_individual.dta", clear;

gen laboral_65ymas = laboral if edad>=65;
gen rentas_65ymas = rentas if edad>=65;
gen contributivas_65ymas = contributivas if edad>=65;
gen no_contributivas_65ymas = no_contributivas if edad>=65;
gen donativos_otras_fam_65ymas = donativos_otras_fam if edad>=65;
gen otras_transfer_65ymas = otras_transfer if edad>=65;

gen laboral_64ymenos = laboral if edad<=64;
gen rentas_64ymenos = rentas if edad<=64;
gen contributivas_64ymenos = contributivas if edad<=64;
gen no_contributivas_64ymenos = no_contributivas if edad<=64;
gen donativos_otras_fam_64ymenos = donativos_otras_fam if edad<=64;
gen otras_transfer_64ymenos = otras_transfer if edad<=64;


collapse (sum) laboral_65ymas rentas_65ymas contributivas_65ymas no_contributivas_65ymas donativos_otras_fam_65ymas otras_transfer_65ymas
               laboral_64ymenos rentas_64ymenos contributivas_64ymenos no_contributivas_64ymenos donativos_otras_fam_64ymenos otras_transfer_64ymenos
               ,by (folioviv foliohog);

save "$bases\ingresos_del_hogar_edades.dta", replace;

**************************************************************************************************************************;
*************************************UNIÓN DE BASES DE DATOS (NIVEL HOGAR)************************************************;
**************************************************************************************************************************;

*Aquí se combinan las bases de datos (la base principal es la población sin huespedes ni trabajadores domésticos creada arriba, a partir de la cual
*se genera una base a nivel hogar);

#delimit;
use "$bases\población.dta", clear;
gen unos=1;
collapse (sum) unos , by (folioviv foliohog);
drop unos;
sort folioviv foliohog;

merge 1:1 folioviv foliohog using "$bases\variables_muestrales.dta";
drop _merge;
merge 1:1 folioviv foliohog using "$bases\ingreso_monetario_hogar.dta";
drop _merge;
merge 1:1 folioviv foliohog using "$bases\ingreso_total_escalado.dta";
drop _merge;
merge 1:1 folioviv foliohog using "$bases\gasto_monetario_hogar.dta";
drop _merge;
merge 1:1 folioviv foliohog using "$bases\características_del_hogar.dta";
drop _merge;
merge 1:1 folioviv foliohog using "$bases\ingresos_del_hogar_edades.dta";
drop _merge;
merge m:1 folioviv using "$bases\viviendas.dta";
drop _merge;

**************Recode a variables************;
*Aquí se substitueyen los "." por "0" ya que al hacer el merge hay hogares no tenían ingresos (using) pero si aparecían en los datos base (master);

recode sueldos horext comisiones otra_rem trabajo industria comercio servicios noagrop agricolas
       pecuarios reproducc pesca agrope ganancias negocio aguinaldo rep_utilidades otros_trab laboral
	   propiedades financieras otras_rentas rentas contributivas no_contributivas pension indemnizaciones
	   becas donativos_no_gub donativos_otras_fam remesas bene_gob transfer otras_transfer ingreso_mon 
	
	   ing_lab ing_ren ing_tra ing_mon (.=0);

recode laboral_65ymas rentas_65ymas contributivas_65ymas no_contributivas_65ymas donativos_otras_fam_65ymas otras_transfer_65ymas
       laboral_64ymenos rentas_64ymenos contributivas_64ymenos no_contributivas_64ymenos donativos_otras_fam_64ymenos otras_transfer_64ymenos (.=0);
			   

*Aquí se substitueyen los "." por "0" ya que al hacer el merge hay hogares no tenían gastos (using) pero si aparecían en los datos base (master);
recode cereales carnes pescados_mariscos leche_derivados huevo aceites tuberculo verduras frutas azucar cafe especias otros_alimentos_diversos bebidas_no_alcoholicas ali_dentro ali_fuera alimentos
			   tabaco alcoholicas tab_alcoh
			   hvestido0_4 hvestido5_17 hvestido18_mas mvestido0_4 mvestido5_17 mvestido18_mas hcalzado0_4 hcalzado5_17 hcalzado18_mas mcalzado0_4 mcalzado5_17 mcalzado18_mas reparacion_calzado telas_reparaciones vestido_hombre vestido_mujer vestido calzado_hombre calzado_mujer calzado vesti_calz
			   alquiler pred_cons agua energia alarma mant_const vivienda
			   limpieza cristaleria enseres hogar
			   atenc_ambu hospital medicinas salud
			   publico foraneo adqui_vehi refaccion combus comunica transporte
			   educacion esparci paq_turist educa_espa
			   cuida_pers acces_pers otros_gas personales
			   transf_gas
			   gasto_mon total (.=0);


			   
***************Identificadores de pensión en el hogar*****************;
gen d_contributivas_h=0;
replace d_contributivas_h=1 if contributivas>0 & contributivas!=.;

gen d_no_contributivas_h=0;
replace d_no_contributivas_h=1 if no_contributivas>0 & no_contributivas!=.;

gen d_pension_h=0;
replace d_pension_h=1 if pension>0 & pension!=.;

gen d_sin_pension_h=0;
replace d_sin_pension_h=1 if pension==0 | pension==.; 


*Variable categórica de pensión;
gen clasificador_h=.;
*Solo pensión contributiva;
replace clasificador_h=1 if (contributivas>0 & contributivas!=.) & (no_contributivas==0 | no_contributivas==.);
*Solo pensión no contrubutiva;
replace clasificador_h=2 if (no_contributivas>0 & no_contributivas!=.) & (contributivas==0 | contributivas==.);
*Pensión contributiva y pensión no contributiva;
replace clasificador_h=3 if (contributivas>0 & contributivas!=.) & (no_contributivas>0 & no_contributivas!=.);
*Sin pensión;
replace clasificador_h=4 if (contributivas==0 | contributivas==.) & (no_contributivas==0 | no_contributivas==.);

label var clasificador_h "Cobertura de pensiones";
label define clasificador_h 1 "Contributiva" 
						  2 "No contributiva"
						  3 "Cont y no cont"
						  4 "Sin pensión";
label value clasificador_h clasificador_h;


*Variable categórica de pensión e integrantes de P65+ en el hogar;
gen clase=.;
*Solo pensión contributiva;
replace clase=1 if (contributivas>0 & contributivas!=.) & (no_contributivas==0 | no_contributivas==.) & d_edad_65ymas==1;
*Solo pensión no contrubutiva;
replace clase=2 if (no_contributivas>0 & no_contributivas!=.) & (contributivas==0 | contributivas==.) & d_edad_65ymas==1;
*Pensión contributiva y pensión no contributiva;
replace clase=3 if (contributivas>0 & contributivas!=.) & (no_contributivas>0 & no_contributivas!=.) & d_edad_65ymas==1;
*Sin pensión;
replace clase=4 if (contributivas==0 | contributivas==.) & (no_contributivas==0 | no_contributivas==.) & d_edad_65ymas==1;
*Sin personas de 65+;
replace clase=5 if d_edad_65ymas==0;



label var clase "Pensiones y P65+";
label define clase  1 "Contributiva y P65+" 
					2 "No contributiva y P65+"
			        3 "Cont y no cont y P65+"
		            4 "Sin pensión y P65+"
					5 "Sin personas de P65+";
label value clase clase;


*****************************Variables de ingreso********************************;

*Porcentaje de cada fuente de ingreso;
gen pt_laboral = laboral/ict;
gen pt_rentas = rentas/ict;
gen pt_contributivas = contributivas/ict;
gen pt_no_contributivas=no_contributivas/ict;
gen pt_donativos_otras_fam=donativos_otras_fam/ict;
gen pt_otras_transfer=otras_transfer/ict;
gen pt_nomon=nomon/ict;

*De personas de 64 años y menos;
gen pt_laboral_64ymenos = laboral_64ymenos/ict;
gen pt_rentas_64ymenos = rentas_64ymenos/ict;
gen pt_contributivas_64ymenos = contributivas_64ymenos/ict;
gen pt_no_contributivas_64ymenos=no_contributivas_64ymenos/ict;
gen pt_donativos_otras_fam_64ymenos=donativos_otras_fam_64ymenos/ict;
gen pt_otras_transfer_64ymenos=otras_transfer_64ymenos/ict;

*De personas de 65 años y más;
gen pt_laboral_65ymas = laboral_65ymas/ict;
gen pt_rentas_65ymas = rentas_65ymas/ict;
gen pt_contributivas_65ymas = contributivas_65ymas/ict;
gen pt_no_contributivas_65ymas=no_contributivas_65ymas/ict;
gen pt_donativos_otras_fam_65ymas=donativos_otras_fam_65ymas/ict;
gen pt_otras_transfer_65ymas=otras_transfer_65ymas/ict;

recode pt_laboral pt_rentas pt_contributivas pt_no_contributivas pt_donativos_otras_fam pt_otras_transfer pt_nomon
pt_laboral_64ymenos pt_rentas_64ymenos pt_contributivas_64ymenos pt_no_contributivas_64ymenos pt_donativos_otras_fam_64ymenos pt_otras_transfer_64ymenos
pt_laboral_65ymas pt_rentas_65ymas pt_contributivas_65ymas pt_no_contributivas_65ymas pt_donativos_otras_fam_65ymas pt_otras_transfer_65ymas  (.=0);

 			   
#delimit;

*Quintiles;

*Aquí se crean las variables de quintil, decil y cientil;
xtile quintil_i_con_0 = ict [w=factor] if ict!=., nq(5);
xtile quintil_i_sin_0= ict [w=factor] if ict>0 & ict!=., nq(5);

xtile decil_i_con_0 = ict [w=factor] if ict!=., nq(10);
xtile decil_i_sin_0= ict [w=factor] if ict>0 & ict!=., nq(10);

xtile cien_i_sin_0 = ict [w=factor] if ict>0 & ict!=., nq(100);
xtile cien_i_con_0 = ict [w=factor] if ict!=., nq(100); 

*Logaritmo del ingreso;
gen ln_ict=ln(ict);


*****************************Variables de gasto********************************;			   

*Aquí se crea la variable de quintil/decil/cien de gasto;
xtile quintil_g_con_0 = gasto_mon [w=factor] if gasto_mon!=., nq(5);
xtile quintil_g_sin_0= gasto_mon [w=factor] if gasto_mon>0 & gasto_mon!=., nq(5);

xtile decil_g_con_0 = gasto_mon [w=factor] if gasto_mon!=., nq(10);
xtile decil_g_sin_0= gasto_mon [w=factor] if gasto_mon>0 & gasto_mon!=., nq(10);

xtile cien_g_con_0 = gasto_mon [w=factor] if  gasto_mon!=., nq(100);
xtile cien_g_sin_0 = gasto_mon [w=factor] if gasto_mon>0 & gasto_mon!=., nq(100); 


*Logaritmo del gasto;
gen ln_gasto_mon=ln(gasto_mon);
gen ln_gasto_mon_2=(ln(gasto_mon))^.5;
*Logaritmos del los ingresos (contributiva, no contributiva y otros ingresos);
gen ln_contributivas = ln(contributivas);
gen ln_no_contributivas = ln(no_contributivas);
gen ln_otro_ingreso =ln(ict-contributivas-no_contributivas);

*Logaritmos de las fuentes de gasto;
gen ln_alimentos = ln(alimentos);
gen ln_tab_alcoh  = ln(tab_alcoh);
gen ln_vesti_calz = ln(vesti_calz);
gen ln_vivienda = ln(vivienda);
gen ln_hogar = ln(hogar);
gen ln_salud = ln(salud);
gen ln_transporte = ln(transporte);
gen ln_educa_espa = ln(educa_espa);
gen ln_personales = ln(personales);
gen ln_transf_gas = ln(transf_gas);



* Proporción de fuente de gastos de los hogares;

*1. Alimentos;
gen p_ali_dentro           =ali_dentro/gasto_mon;
gen p_ali_fuera            =ali_fuera/gasto_mon;
gen p_alimentos            =alimentos/gasto_mon;

*2. Tabaco y alcohol;
gen p_tab_alcoh            =tab_alcoh/gasto_mon;

*3. Vestido y calzado;
gen p_vestido_hombre       =vestido_hombre/gasto_mon;
gen p_vestido_mujer        =vestido_mujer/gasto_mon;
gen p_calzado_hombre       =calzado_hombre/gasto_mon;
gen p_calzado_mujer        =calzado_mujer/gasto_mon;
gen p_vesti_calz           =vesti_calz/gasto_mon;

*Vivienda;
gen p_vivienda             =vivienda/gasto_mon;

*Hogar;
gen p_hogar                =hogar/gasto_mon;

*Cuidados de salud;
gen p_salud                =salud/gasto_mon;

*Transporte;
gen p_transporte           =transporte/gasto_mon;

*Educación y esparciminento;
gen p_educa_espa           =educa_espa/gasto_mon;

*Personales;
gen p_personales           =personales/gasto_mon;

*Transferencias;
gen p_transf_gas           =transf_gas/gasto_mon;

recode p_ali_dentro p_ali_fuera p_alimentos
	   p_tab_alcoh  
	   p_alimentos
	   p_vestido_hombre p_vestido_mujer p_calzado_hombre p_calzado_mujer p_vesti_calz
	   p_vivienda 
	   p_hogar
	   p_salud 
	   p_transporte
	   p_educa_espa
	   p_personales
	   p_transf_gas	(.=0);

gen ln_gasto_hog_tamhog=ln(gasto_mon/tamhog);
			   
save "$bases\base_hogar.dta", replace;

export delimited using "D:\Mis Documentos\Proyectos\Ingreso y gasto del adulto mayor\Stata\Ejercicios\ENIGH-2016\base_hogar.csv", replace;


