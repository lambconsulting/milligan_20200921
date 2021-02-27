

%let rocpath=U:\Consulting\KEL\Texas_AM\Dobefest;
%include "&rocpath.\ROC_Optimal_Cutoff_031816.sas";

libname mlm "U:\Consulting\KEL\Fox\Berent\Milligan_20200921\input" access=readonly; 

data mlm; set mlm.milligan_20210126; run;

%let ds = mlm;

/* Descriptive statistics by group (Table 1) Continuous with p-values */
%macro desc_mean(dv,iv,model,research_q);
data ds; set &ds.; run;
proc means data = ds n nmiss min max mean p25 median p75 std var;
class &iv; 
var &dv.;
ods output summary = xxx;
run;
data m_&dv.;
length iv dv research_q model $50.;
set xxx;
rename &iv = iv_level;
rename &dv._n = n;
rename &dv._NMiss = n_Miss;
rename &dv._mean = mean;
rename &dv._stddev = stddev;
rename &dv._var = variance;
rename &dv._min = min;
rename &dv._max = max;
rename &dv._p25 = p25;
rename &dv._median = median;
rename &dv._p75 = p75;
dv = "&dv."; iv = "&iv."; research_q = "&research_q."; model = "&model."; ;
run;
data rawmean;
set rawmean m_&dv.;
run;
proc datasets lib=work nodetails nolist;
delete mean_&dv.;
run;
proc mixed data=ds;
class &iv. ;
model &dv. = &iv. ;
lsmeans &iv. / pdiff =all; 
ods output tests3 = t3 lsmeans = lsout diffs=d;
data t (rename=probf = p_value); length var research_q model $50.;
set  t3 (keep=ProbF); var = "&dv."; research_q = "&research_q."; model = "&model."; run;
data ls (rename=(estimate = lsmean &iv. = iv_level effect=iv  )); length  dv research_q model $50.;
set  lsout (keep=&iv. estimate stderr effect); dv = "&dv."; research_q = "&research_q."; model = "&model."; run;
data d (drop=df tvalue) ; length iv dv research_q model $50.;
set  d (rename=(&iv=iv_grp1 _&iv. = iv_grp2 estimate=grp_mn_diff effect=iv)); dv = "&dv."; research_q = "&research_q."; model = "&model."; run;
data t3 ; set t3 t ; data lsmean ; set lsmean ls ; data diffs; set diffs d ;   run;
%mend;

data rawmean; set _null_; data t3; set _null_; data lsmean; set _null_; data diffs; set _null_; run;
/*%desc_mean(UTI_Number,CystoIntraOp,anova,257);*/
%desc_mean(AUSPelvis_post1st, EDTA_Study , anova,158);
%desc_mean(Flush_TmToMin, EDTA_Study , anova,163);
%desc_mean(Post_creat_18mo, EDTA_Study , anova,178);
%desc_mean(Post_creat_1mo, EDTA_Study , anova,173);
%desc_mean(Post_creat_1week, EDTA_Study , anova,172);
%desc_mean(Post_creat_1yr, EDTA_Study , anova,177);
%desc_mean(Post_creat_2yr, EDTA_Study , anova,179);
%desc_mean(Post_creat_3mo, EDTA_Study , anova,174);
%desc_mean(Post_creat_3yr, EDTA_Study , anova,180);
%desc_mean(Post_creat_6mo, EDTA_Study , anova,175);
%desc_mean(Post_creat_9mo, EDTA_Study , anova,176);
%desc_mean(Post_creat_lastor3mo, EDTA_Study , anova,181);
%desc_mean(Post_Lastcreat, EDTA_Study , anova,182);
%desc_mean(Post_PelvisAUS, EDTA_Study , anova,191);
%desc_mean(PT_SURV_T, EDTA_Study , anova,147);
%desc_mean(SUB_T1, EDTA_Study , anova,153);
%desc_mean(TimeFirstUTI, EDTA_Study , anova,190);
%desc_mean(TimeMin, EDTA_Study , anova,164);
%desc_mean(TimeStoneBlock, EDTA_Study , anova,165);
%desc_mean(TimMinStoneBlock, EDTA_Study , anova,166);
%desc_mean(UTI_number, EDTA_Study , anova,155);
%desc_mean(AUSPelvis_post1st, EDTAGroup , anova,108);
%desc_mean(Flush_TmToMin, EDTAGroup , anova,113);
%desc_mean(Post_creat_18mo, EDTAGroup , anova,128);
%desc_mean(Post_creat_1mo, EDTAGroup , anova,123);
%desc_mean(Post_creat_1week, EDTAGroup , anova,122);
%desc_mean(Post_creat_1yr, EDTAGroup , anova,127);
%desc_mean(Post_creat_2yr, EDTAGroup , anova,129);
%desc_mean(Post_creat_3mo, EDTAGroup , anova,124);
%desc_mean(Post_creat_3yr, EDTAGroup , anova,130);
%desc_mean(Post_creat_6mo, EDTAGroup , anova,125);
%desc_mean(Post_creat_9mo, EDTAGroup , anova,126);
%desc_mean(Post_creat_lastor3mo, EDTAGroup , anova,131);
%desc_mean(Post_Lastcreat, EDTAGroup , anova,132);
%desc_mean(Post_PelvisAUS, EDTAGroup , anova,141);
%desc_mean(PT_SURV_T, EDTAGroup , anova,97);
%desc_mean(SUB_T1, EDTAGroup , anova,103);
%desc_mean(TimeFirstUTI, EDTAGroup , anova,140);
%desc_mean(TimeMin, EDTAGroup , anova,114);
%desc_mean(TimeStoneBlock, EDTAGroup , anova,115);
%desc_mean(TimMinStoneBlock, EDTAGroup , anova,116);
%desc_mean(UTI_number, EDTAGroup , anova,105);
%desc_mean(TimeMin, HighCa_Post , anova,208);
%desc_mean(TimeStoneBlock, HighCa_Post , anova,209);
%desc_mean(AUSPelvis_post1st, MixedGroup, anova,57);
%desc_mean(Flush_TmToMin, MixedGroup, anova,62);
%desc_mean(Post_creat_18mo, MixedGroup, anova,77);
%desc_mean(Post_creat_1mo, MixedGroup, anova,72);
%desc_mean(Post_creat_1week, MixedGroup, anova,71);
%desc_mean(Post_creat_1yr, MixedGroup, anova,76);
%desc_mean(Post_creat_2yr, MixedGroup, anova,78);
%desc_mean(Post_creat_3mo, MixedGroup, anova,73);
%desc_mean(Post_creat_3yr, MixedGroup, anova,79);
%desc_mean(Post_creat_6mo, MixedGroup, anova,74);
%desc_mean(Post_creat_9mo, MixedGroup, anova,75);
%desc_mean(Post_creat_lastor3mo, MixedGroup, anova,80);
%desc_mean(Post_Lastcreat, MixedGroup, anova,81);
%desc_mean(Post_PelvisAUS, MixedGroup, anova,90);
%desc_mean(PT_SURV_T, MixedGroup, anova,46);
%desc_mean(SUB_T1, MixedGroup, anova,52);
/*%desc_mean(SUBT_noEDTA, MixedGroup, anova,96);*/
%desc_mean(TimeFirstUTI, MixedGroup, anova,89);
%desc_mean(TimeMin, MixedGroup, anova,63);
%desc_mean(TimeStoneBlock, MixedGroup, anova,64);
%desc_mean(TimMinStoneBlock, MixedGroup, anova,65);
%desc_mean(UTI_number, MixedGroup, anova,54);
%desc_mean(TimeMin, pre_iCa , anova,199);
%desc_mean(TimeStoneBlock, pre_iCa , anova,200);
%desc_mean(UTI_Number, PreAbx72, anova,238);
%desc_mean(UTI_Number, PreSx_UTI , anova,228);
%desc_mean(UTI_Number, PU_Sx, anova,248);
%desc_mean(AUSPelvis_post1st, SalineGroup, anova,12);
%desc_mean(Flush_TmToMin, SalineGroup, anova,17);
%desc_mean(Post_creat_18mo, SalineGroup, anova,32);
%desc_mean(Post_creat_1mo, SalineGroup, anova,27);
%desc_mean(Post_creat_1week, SalineGroup, anova,26);
%desc_mean(Post_creat_1yr, SalineGroup, anova,31);
%desc_mean(Post_creat_2yr, SalineGroup, anova,33);
%desc_mean(Post_creat_3mo, SalineGroup, anova,28);
%desc_mean(Post_creat_3yr, SalineGroup, anova,34);
%desc_mean(Post_creat_6mo, SalineGroup, anova,29);
%desc_mean(Post_creat_9mo, SalineGroup, anova,30);
%desc_mean(Post_creat_lastor3mo, SalineGroup, anova,35);
%desc_mean(Post_Lastcreat, SalineGroup, anova,36);
%desc_mean(Post_PelvisAUS, SalineGroup, anova,45);
%desc_mean(PT_SURV_T, SalineGroup, anova,1);
%desc_mean(SUB_T1, SalineGroup, anova,7);
%desc_mean(TimeFirstUTI, SalineGroup, anova,44);
%desc_mean(TimeMin, SalineGroup, anova,18);
%desc_mean(TimeStoneBlock, SalineGroup, anova,19);
%desc_mean(TimMinStoneBlock, SalineGroup, anova,20);
%desc_mean(UTI_number, SalineGroup, anova,9);
%desc_mean(TimeMin, Stone, anova,217);
%desc_mean(TimeStoneBlock, Stone, anova,218);





	*** Chi Square Cross-Tab Frequency Anlaysis Set-up;
%macro chi(dv,iv1,model,research_q);
data ds; set &ds.; run;
proc freq data =  ds;
tables &iv1.*&dv. / chisq;
ods output CrossTabFreqs = freqs ChiSq= chi FishersExact = fish ;run;
run;
data freqs_in; set freqs (drop =  _table_ rowpercent colpercent); 
where _type_ in ("11" "00"); drop _type_; run;

data ctf_&research_q. (drop =  &iv1. &dv.); retain model /* analysis */ research_q; length model research_q $50.; set freqs_in; 
/* analysis = "&analysis."; */ research_q = "&research_q."; model = "&model."; 
iv1 = put(&iv1.,5.0); iv2 = put(&dv.,5.0);
run;
data ctf_all; set ctf_all ctf_&research_q.; run;

	%if %sysfunc(exist(fish)) %then %do;
data f_&research_q. (rename=nvalue1=P_FISH); set fish (keep =  table name1 nvalue1); 
where name1 in ("P_TABLE"); drop name1; run;
data f_p; set f_p f_&research_q.; run;
	%end;
	%if %sysfunc(exist(chi)) %then %do;
data chi_&research_q. (rename=prob=P_CHI); length model research_q $50.;
set chi (keep =  table statistic prob); 
where statistic in ("Chi-Square");  drop statistic; 
model = "&model."; research_q = "&research_q."; run;
data chi_p; set chi_p chi_&research_q.; run;
	%end;

proc datasets library=work nolist nodetails; delete chi fish freq p_&research_q. chi_&research_q.; 
run;
	%mend;

data ctf_all; set _null_; data f_p; set _null_; data chi_p; set _null_; run;
/*%chi(ChronicUTI, CystoIntraOp, Chi_Square,261);*/
/*%chi(ChronicUTI_PreandPost, CystoIntraOp, Chi_Square,262);*/
/*%chi(ClearIFX, CystoIntraOp, Chi_Square,256);*/
/*%chi(Post_UTI_any, CystoIntraOp, Chi_Square,260);*/
/*%chi(SymptomUTI, CystoIntraOp, Chi_Square,263);*/
/*%chi(UTI_ChronicBac, CystoIntraOp, Chi_Square,258);*/
/*%chi(UTI_ChronicFungal, CystoIntraOp, Chi_Square,259);*/
%chi(ChronicUTI, EDTA_Study , Chi_Square,187);
%chi(ChronicUTI_PreandPost, EDTA_Study , Chi_Square,188);
%chi(ClearIFX, EDTA_Study , Chi_Square,154);
%chi(DefRenal, EDTA_Study , Chi_Square,149);
%chi(DefUreter, EDTA_Study , Chi_Square,148);
%chi(Exchanged, EDTA_Study , Chi_Square,161);
%chi(ExchgeStone_Comp, EDTA_Study , Chi_Square,169);
%chi(ExchgeStone_Needed, EDTA_Study , Chi_Square,167);
%chi(ExchgeStone_YN, EDTA_Study , Chi_Square,168);
%chi(Hematuria_Gross, EDTA_Study , Chi_Square,171);
%chi(HTF_mineral, EDTA_Study , Chi_Square,162);
%chi(LikelyRenal, EDTA_Study , Chi_Square,150);
%chi(NotRenal, EDTA_Study , Chi_Square,152);
%chi(Post_Dysuria, EDTA_Study , Chi_Square,170);
%chi(Post_Ecoli, EDTA_Study , Chi_Square,184);
%chi(Post_Entero, EDTA_Study , Chi_Square,183);
%chi(Post_Staph, EDTA_Study , Chi_Square,185);
/*%chi(Post_UTIany, EDTA_Study , Chi_Square,159);*/
/*%chi(Post_UTIany, EDTA_Study , Chi_Square,186);*/
%chi(Stone_CompleteOcclude, EDTA_Study , Chi_Square,160);
%chi(SymptomUTI, EDTA_Study , Chi_Square,189);
%chi(UnlikRenal, EDTA_Study , Chi_Square,151);
%chi(UTI_ChronicFungal, EDTA_Study , Chi_Square,157);
%chi(UTI_ChronicBac, EDTA_Study , Chi_Square,156);
%chi(ChronicUTI, EDTAGroup , Chi_Square,137);
%chi(ChronicUTI_PreandPost, EDTAGroup , Chi_Square,138);
%chi(ClearIFX, EDTAGroup , Chi_Square,104);
%chi(DefRenal, EDTAGroup , Chi_Square,99);
%chi(DefUreter, EDTAGroup , Chi_Square,98);
%chi(Exchanged, EDTAGroup , Chi_Square,111);
%chi(ExchgeStone_Comp, EDTAGroup , Chi_Square,119);
%chi(ExchgeStone_Needed, EDTAGroup , Chi_Square,117);
%chi(ExchgeStone_YN, EDTAGroup , Chi_Square,118);
%chi(Hematuria_Gross, EDTAGroup , Chi_Square,121);
%chi(HTF_mineral, EDTAGroup , Chi_Square,112);
%chi(Hx_SUBDeminProt, EDTAGroup , Chi_Square,142);
%chi(Hx_SUBDeminReobstruct, EDTAGroup , Chi_Square,144);
%chi(Hx_SUBDeminWork, EDTAGroup , Chi_Square,143);
%chi(Hx_SUBInfectionProt, EDTAGroup , Chi_Square,145);
%chi(Hx_SUBinfectionProtWork, EDTAGroup , Chi_Square,146);
%chi(LikelyRenal, EDTAGroup , Chi_Square,100);
%chi(NotRenal, EDTAGroup , Chi_Square,102);
%chi(Post_Dysuria, EDTAGroup , Chi_Square,120);
%chi(Post_Ecoli, EDTAGroup , Chi_Square,134);
%chi(Post_Entero, EDTAGroup , Chi_Square,133);
%chi(Post_Staph, EDTAGroup , Chi_Square,135);
/*%chi(Post_UTIany, EDTAGroup , Chi_Square,109);*/
/*%chi(Post_UTIany, EDTAGroup , Chi_Square,136);*/
%chi(Stone_CompleteOcclude, EDTAGroup , Chi_Square,110);
%chi(SymptomUTI, EDTAGroup , Chi_Square,139);
%chi(UnlikRenal, EDTAGroup , Chi_Square,101);
%chi(UTI_ChronicFungal, EDTAGroup , Chi_Square,107);
%chi(UTI_ChronicBac, EDTAGroup , Chi_Square,106);
%chi(Exchanged, HighCa_Post , Chi_Square,204);
%chi(ExchgeStone_Needed, HighCa_Post , Chi_Square,203);
%chi(HTF_mineral, HighCa_Post , Chi_Square,201);
%chi(Hx_SUBDeminProt, HighCa_Post , Chi_Square,205);
%chi(Hx_SUBDeminReobstruct, HighCa_Post , Chi_Square,207);
%chi(Hx_SUBDeminWork, HighCa_Post , Chi_Square,206);
%chi(Stone_CompleteOcclude, HighCa_Post , Chi_Square,202);
%chi(PreSx_UTI, Hx_Cystot , Chi_Square,219);
%chi(PurulentDebris, Hx_Cystot , Chi_Square,220);
%chi(Uculture_Pyelo_Result, Hx_Cystot , Chi_Square,221);
/*%chi(PreSx_UTI, Hx_Pre_UTI , Chi_Square,222);*/
/*%chi(PurulentDebris, Hx_Pre_UTI , Chi_Square,223);*/
/*%chi(Uculture_Pyelo_Result, Hx_Pre_UTI , Chi_Square,224);*/
%chi(ChronicUTI, MixedGroup, Chi_Square,86);
%chi(ChronicUTI_PreandPost, MixedGroup, Chi_Square,87);
%chi(ClearIFX, MixedGroup, Chi_Square,53);
%chi(DefRenal, MixedGroup, Chi_Square,48);
%chi(DefUreter, MixedGroup, Chi_Square,47);
%chi(Exchanged, MixedGroup, Chi_Square,60);
%chi(ExchgeStone_Comp, MixedGroup, Chi_Square,68);
%chi(ExchgeStone_Needed, MixedGroup, Chi_Square,66);
%chi(ExchgeStone_YN, MixedGroup, Chi_Square,67);
%chi(Hematuria_Gross, MixedGroup, Chi_Square,70);
%chi(HTF_mineral, MixedGroup, Chi_Square,61);
/*%chi(Hx_, MixedGroup, Chi_Square,94);*/
%chi(Hx_SUBDeminProt, MixedGroup, Chi_Square,91);
%chi(Hx_SUBDeminReobstruct, MixedGroup, Chi_Square,93);
%chi(Hx_SUBDeminWork, MixedGroup, Chi_Square,92);
%chi(Hx_SUBinfectionProtWork, MixedGroup, Chi_Square,95);
%chi(LikelyRenal, MixedGroup, Chi_Square,49);
%chi(NotRenal, MixedGroup, Chi_Square,51);
%chi(Post_Dysuria, MixedGroup, Chi_Square,69);
%chi(Post_Ecoli, MixedGroup, Chi_Square,83);
%chi(Post_Entero, MixedGroup, Chi_Square,82);
%chi(Post_Staph, MixedGroup, Chi_Square,84);
/*%chi(Post_UTIany, MixedGroup, Chi_Square,58);*/
/*%chi(Post_UTIany, MixedGroup, Chi_Square,85);*/
%chi(Stone_CompleteOcclude, MixedGroup, Chi_Square,59);
%chi(SymptomUTI, MixedGroup, Chi_Square,88);
%chi(UnlikRenal, MixedGroup, Chi_Square,50);
%chi(UTI_ChronicFungal, MixedGroup, Chi_Square,56);
%chi(UTI_ChronicBac, MixedGroup, Chi_Square,55);
%chi(Exchanged, pre_iCa , Chi_Square,195);
%chi(ExchgeStone_Needed, pre_iCa , Chi_Square,194);
%chi(HTF_mineral, pre_iCa , Chi_Square,192);
%chi(Hx_SUBDeminProt, pre_iCa , Chi_Square,196);
%chi(Hx_SUBDeminReobstruct, pre_iCa , Chi_Square,198);
%chi(Hx_SUBDeminWork, pre_iCa , Chi_Square,197);
%chi(Stone_CompleteOcclude, pre_iCa , Chi_Square,193);
%chi(ChronicUTI, PreAbx72, Chi_Square,242);
%chi(ChronicUTI_PreandPost, PreAbx72, Chi_Square,243);
%chi(ClearIFX, PreAbx72, Chi_Square,237);
/*%chi(Post_UTI_any, PreAbx72, Chi_Square,241);*/
%chi(SymptomUTI, PreAbx72, Chi_Square,244);
%chi(UTI_ChronicBac, PreAbx72, Chi_Square,239);
%chi(UTI_ChronicFungal, PreAbx72, Chi_Square,240);
%chi(PurulentDebris, PreAbx72 , Chi_Square,235);
%chi(Uculture_Pyelo_Result, PreAbx72 , Chi_Square,236);
%chi(ChronicUTI, PreSx_UTI , Chi_Square,232);
%chi(ChronicUTI_PreandPost, PreSx_UTI , Chi_Square,233);
%chi(ClearIFX, PreSx_UTI , Chi_Square,227);
/*%chi(Post_UTI_any, PreSx_UTI , Chi_Square,231);*/
%chi(PurulentDebris, PreSx_UTI , Chi_Square,225);
%chi(SymptomUTI, PreSx_UTI , Chi_Square,234);
%chi(Uculture_Pyelo_Result, PreSx_UTI , Chi_Square,226);
%chi(UTI_ChronicBac, PreSx_UTI , Chi_Square,229);
%chi(UTI_ChronicFungal, PreSx_UTI , Chi_Square,230);
%chi(ChronicUTI, PU_Sx, Chi_Square,252);
%chi(ChronicUTI_PreandPost, PU_Sx, Chi_Square,253);
%chi(ClearIFX, PU_Sx, Chi_Square,247);
/*%chi(Post_UTI_any, PU_Sx, Chi_Square,251);*/
%chi(PreSx_UTI, PU_Sx, Chi_Square,255);
%chi(PurulentDebris, PU_Sx, Chi_Square,245);
%chi(SymptomUTI, PU_Sx, Chi_Square,254);
%chi(Uculture_Pyelo_Result, PU_Sx, Chi_Square,246);
%chi(UTI_ChronicBac, PU_Sx, Chi_Square,249);
%chi(UTI_ChronicFungal, PU_Sx, Chi_Square,250);
%chi(ChronicUTI, SalineGroup, Chi_Square,41);
%chi(ChronicUTI_PreandPost, SalineGroup, Chi_Square,42);
%chi(ClearIFX, SalineGroup, Chi_Square,8);
%chi(DefRenal, SalineGroup, Chi_Square,3);
%chi(DefUreter, SalineGroup, Chi_Square,2);
%chi(Exchanged, SalineGroup, Chi_Square,15);
%chi(ExchgeStone_Comp, SalineGroup, Chi_Square,23);
%chi(ExchgeStone_Needed, SalineGroup, Chi_Square,21);
%chi(ExchgeStone_YN, SalineGroup, Chi_Square,22);
%chi(Hematuria_Gross, SalineGroup, Chi_Square,25);
%chi(HTF_mineral, SalineGroup, Chi_Square,16);
%chi(LikelyRenal, SalineGroup, Chi_Square,4);
%chi(NotRenal, SalineGroup, Chi_Square,6);
%chi(Post_Dysuria, SalineGroup, Chi_Square,24);
%chi(Post_Ecoli, SalineGroup, Chi_Square,38);
%chi(Post_Entero, SalineGroup, Chi_Square,37);
%chi(Post_Staph, SalineGroup, Chi_Square,39);
/*%chi(Post_UTIany, SalineGroup, Chi_Square,13);*/
/*%chi(Post_UTIany, SalineGroup, Chi_Square,40);*/
%chi(Stone_CompleteOcclude, SalineGroup, Chi_Square,14);
%chi(SymptomUTI, SalineGroup, Chi_Square,43);
%chi(UnlikRenal, SalineGroup, Chi_Square,5);
%chi(UTI_ChronicBac, SalineGroup, Chi_Square,10);
%chi(UTI_ChronicFungal, SalineGroup, Chi_Square,11);
%chi(Exchanged, Stone, Chi_Square,213);
%chi(ExchgeStone_Needed, Stone, Chi_Square,212);
%chi(HTF_mineral, Stone, Chi_Square,210);
%chi(Hx_SUBDeminProt, Stone, Chi_Square,214);
%chi(Hx_SUBDeminReobstruct, Stone, Chi_Square,216);
%chi(Hx_SUBDeminWork, Stone, Chi_Square,215);
%chi(Stone_CompleteOcclude, Stone, Chi_Square,211);
%chi(AnyUcathPost, UTI_ChronicBac, Chi_Square,264);
%chi(Hx_SUBInfectionProt, UTI_ChronicBac, Chi_Square,265);
%chi(Hx_SUBInfectionProtWork, UTI_ChronicBac, Chi_Square,266);



%macro penorm (dv,iv,mod_ty,research_q);
proc reg data=&ds.;
  model &dv.= &iv. ;
  output out=res rstudent=&dv.r /*h=lev cookd=cd dffits=dffit*/ ;
  ods output ParameterEstimates=pe;
run;
quit;
data pe (drop=variable);
length iv dv  $50. ;
set pe (drop=model dependent df tvalue);
research_q = &research_q.;
iv = "&iv.";
dv = "&dv.";
model="&mod_ty.";
where variable not in ("Intercept");
run;
data pe_all;
set pe_all pe;
run;
* Examine residuals for normality ;
proc univariate data=res plots plotsize=30 normal;
  var &dv.r;
  ods output TestsForNormality=norm;
run;
data norm;
length iv dv $50.;
set norm (drop=varname);
research_q = &research_q.;
iv = "&iv.";
dv = "&dv.";
run;
data norm_all;
set norm_all norm;
run;

%mend;
data norm_all; set _null_; data pe_all; set _null_; run;
%penorm(TimeFirstUTI,SUBT_noEDTA,regression,276);
%penorm(TimeMin,SUBT_noEDTA,regression,274);
%penorm(TimeStoneBlock, SUBT_noEDTA, regression,275);



%macro logit(dv,iv,prob,model,research_q);
 ods graphics on;            
      proc logistic data=&ds. /* plots=roc */;
         model &dv. (event = "1") = &iv. / rl outroc=roc1;
         output out=out p=phat;
         ods output ParameterEstimates=pe Association=a CLoddsWald=cl;
		 run;

data pe (rename=(variable=iv probchisq=p_value)); 
length iv dv model research_q $25;
retain dv; set pe (drop=df); where variable ne "Intercept"; 
dv = "&dv."; 
iv = "&iv."; 
model = "&model."; 
research_q = "&research_q."; 
run;
data a(keep=c_stat); set a (rename=cvalue2=c_stat); where label1="Pairs";
data cl(drop=effect); set cl ;
data pe_a_cl (drop=_esttype_); merge pe a cl; run;


	data all_pe; set all_pe pe_a_cl; run;

ods graphics off;
      title  "ROC plot for &dv. = &iv.";  
      title2 " ";
          %rocplot( inroc = roc1, inpred = out, p = phat,
                id = &iv. _sens_ _spec_ _OPTEFF_ _opty_ _cutpt_,
                optcrit = youden , pevent = &prob.,
                optsymbolstyle = size=0, optbyx = panelall, x = &iv.)

    data rocme; retain _id &iv. _CORRECT_ _sens_ _spec_ _FALPOS_ _FALNEG_ _opty_;
set _rocplot (keep=_id &iv. &dv. _CORRECT_ _sens_ _spec_    _sensit_ _FALPOS_ _FALNEG_ _opty_ __spec_ _POS_ _NEG_ );
if (_sens_ in (0 1)) or (_spec_ in (0 1)) or (_opty_ = "Y")
then output;
run;
%mend;
data all_pe; set _null_; data all_a; set _null_; data all_cl; set _null_; run;


/*%logit(Exchanged, SUBT_noEDTA,1,logistic,270); * Exchanged 3 levels should be Chi Square but SUBT_noEDTA continuous and not enough data ;*/
/*%logit(ExchgeStone_Needed, SUBT_noEDTA, logistic,269); * ExchgeStone_Needed 3 levels should be Chi Square but SUBT_noEDTA continuous and not enough data;*/
%logit(HTF_mineral, SUBT_noEDTA,1, logistic,267); * Next two are identical given imited data on SUBT_noEDTA;
%logit(Hx_SUBDeminProt, SUBT_noEDTA,1, logistic,271);
/*%logit(Hx_SUBDeminReobstruct, SUBT_noEDTA, logistic,273); * 1/0 but Too few observatons ;*/
/*%logit(Hx_SUBDeminWork, SUBT_noEDTA, logistic,272); * 1/0 but Too few observatons ;*/
%logit(Hx_SUBInfectionProt, SUBT_noEDTA,1, logistic,277);
/*%logit(Hx_SUBinfectionProtWork, SUBT_noEDTA, logistic,278); * 1/0 but Too few observatons ;*/
%logit(Stone_CompleteOcclude, SUBT_noEDTA,1,logistic,268);

