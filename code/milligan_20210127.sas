

%let rocpath=U:\Consulting\KEL\Texas_AM\Dobefest;
%include "&rocpath.\ROC_Optimal_Cutoff_031816.sas";
%let outdir=U:\Consulting\KEL\Fox\Berent\Milligan_20200921\output;
libname mlm "U:\Consulting\KEL\Fox\Berent\Milligan_20200921\input" ;

/*data mlm; set mlm.milligan_20210126; run;*/
data mlm; set mlm.mlm_20210221; run;

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
/* Updated mean list 20210227 */
%desc_mean(Post_creat_18mo, GroupCats , anova,21);
%desc_mean(Post_creat_1mo, GroupCats , anova,22);
%desc_mean(Post_creat_1week, GroupCats , anova,23);
%desc_mean(Post_creat_1yr, GroupCats , anova,24);
%desc_mean(Post_creat_2yr, GroupCats , anova,25);
%desc_mean(Post_creat_3mo, GroupCats , anova,26);
%desc_mean(Post_creat_3yr, GroupCats , anova,27);
%desc_mean(Post_creat_6mo, GroupCats , anova,28);
%desc_mean(Post_creat_9mo, GroupCats , anova,29);
%desc_mean(Post_creat_lastor3mo, GroupCats , anova,30);
%desc_mean(Post_Lastcreat, GroupCats , anova,34);
%desc_mean(PT_SURV_T, GroupCats , anova,37);
%desc_mean(TimeFirstUTI, GroupCats , anova,39);
%desc_mean(TimeMin, GroupDevices , anova,49);
%desc_mean(TimeMin, HighCa_Post , anova,58);
%desc_mean(TimeMin, pre_iCa , anova,72);
%desc_mean(TimeMin, Stone, anova,109);
%desc_mean(TimeStoneBlock, GroupDevices , anova,50);
%desc_mean(TimeStoneBlock, HighCa_Post , anova,59);
%desc_mean(TimeStoneBlock, pre_iCa , anova,73);
%desc_mean(TimeStoneBlock, Stone, anova,110);
%desc_mean(TimMinStoneBlock, GroupDevices , anova,51);
%desc_mean(UTI_Number, CystotIntraOp, anova,8);
%desc_mean(UTI_number, GroupCats , anova,43);
%desc_mean(UTI_Number, PreAbx72, anova,80);
%desc_mean(UTI_Number, PreSx_UTI , anova,91);
%desc_mean(UTI_Number, PU_Sx, anova,102);
%desc_mean(NumberofExchanges, GroupDevices , anova,45);






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

%penorm(NumberofExchanges, Flush_Time, regression,133);
%penorm(TimeFirstUTI, Flush_Time, regression,130);
%penorm(TimeFirstUTI, SUBT_noEDTA, regression,119);
%penorm(TimeMin, Flush_Time, regression,131);
%penorm(TimeMin, SUBT_noEDTA, regression,120);
%penorm(TimeStoneBlock, Flush_Time, regression,132);
%penorm(TimeStoneBlock, SUBT_noEDTA, regression,121);



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

%logit(Exchanged, Flush_Time, 1,logistic,122);
%logit(Exchanged, SUBT_noEDTA, 1,logistic,111);
%logit(HTF_mineral, Flush_Time, 1,logistic,123);
%logit(HTF_mineral, SUBT_noEDTA, 1,logistic,112);
%logit(Hx_SUBDeminProt, Flush_Time, 1,logistic,124);
%logit(Hx_SUBDeminProt, SUBT_noEDTA, 1,logistic,113);
%logit(Hx_SUBDeminReobstruct, Flush_Time, 1,logistic,125);
%logit(Hx_SUBDeminReobstruct, SUBT_noEDTA, 1,logistic,114);
%logit(Hx_SUBDeminWork, Flush_Time, 1,logistic,126);
%logit(Hx_SUBDeminWork, SUBT_noEDTA, 1,logistic,115);
%logit(Hx_SUBInfectionProt, Flush_Time, 1,logistic,127);
%logit(Hx_SUBInfectionProt, SUBT_noEDTA, 1,logistic,116);
%logit(Hx_SUBinfectionProtWork, Flush_Time, 1,logistic,128);
%logit(Hx_SUBinfectionProtWork, SUBT_noEDTA, 1,logistic,117);
%logit(Stone_CompleteOcclude, Flush_Time, 1,logistic,129);
%logit(Stone_CompleteOcclude, SUBT_noEDTA, 1,logistic,118);

/*ods trace on;*/
/*proc logistic data=&ds. ;*/
/*class PreSx_UTI (ref="1") / param=ref;*/
/*model ChronicUTI (event = "1") = PreSx_UTI  ;*/
/*oddsratio "PreSx_UTI" PreSx_UTI / diff=ref; */
/*run;*/
/*ods trace off;*/


%macro logit_cat(dv,iv,ref_grp,prob,model,research_q);
/*ods trace on;*/
 ods graphics on;            
      proc logistic data=&ds. /* plots=roc */;
	  class &iv. (ref="&ref_grp.") / param=ref;
         model &dv. (event = "1") = &iv. / rl outroc=roc1;
		 output out=out p=phat;
         ods output ParameterEstimates=pe Association=a CLoddsWald=cl;
		 run;
/*		 ods trace off;*/
 %if %sysfunc(exist(pe)) %then %do;
 %put pe &iv. or &dv.  exist;
 %end;
 %else %do;
 %put pe &iv. or &dv. Inadequate ;
 %end;

data pe (rename=(probchisq=p_value) drop=variable); 
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

proc datasets delete nolist nodetails;
delete pe a cl; run;
%mend;
data all_pe; set _null_; data all_a; set _null_; data all_cl; set _null_; run;


/*proc printto ; run;*/
proc printto log="&outdir.\logfile1.txt"; run;
/*ods pdf file= "&outdir.\mlm_logit.pdf";*/
/*ods excel file= "&outdir.\mlm_logit.xlsx" options(sheet_name="log_cat" embedded_titles='yes' SHEET_INTERVAL="NONE");*/
%logit_cat(ChronicUTI, CystotIntraOp,1, 1,Logistic Categorical,2);
%logit_cat(ChronicUTI, GroupCats ,1, 1,Logistic Categorical,14);
%logit_cat(ChronicUTI, PreAbx72,0, 1,Logistic Categorical,74);
%logit_cat(ChronicUTI, PreSx_UTI ,1, 1,Logistic Categorical,83);
%logit_cat(ClearIFX, CystotIntraOp,0, 1,Logistic Categorical,3);
%logit_cat(ClearIFX, GroupCats ,1, 1,Logistic Categorical,15);
%logit_cat(ClearIFX, PreAbx72,1, 1,Logistic Categorical,75);
%logit_cat(ClearIFX, PreSx_UTI ,0, 1,Logistic Categorical,84);
%logit_cat(DefRenal, GroupCats ,1, 1,Logistic Categorical,16);
%logit_cat(DefUreter, GroupCats ,1, 1,Logistic Categorical,17);
%logit_cat(Exchanged, GroupDevices ,1, 1,Logistic Categorical,44);
%logit_cat(Exchanged, HighCa_Post ,1, 1,Logistic Categorical,52);
%logit_cat(Exchanged, pre_iCa ,1, 1,Logistic Categorical,66);
%logit_cat(Exchanged, Stone,1, 1,Logistic Categorical,103);
%logit_cat(ExchgeStone_Comp, GroupDevices ,1, 1,Logistic Categorical,46);
%logit_cat(Hematuria_Gross, GroupCats ,1, 1,Logistic Categorical,18);
%logit_cat(HTF_mineral, GroupDevices ,1, 1,Logistic Categorical,47);
%logit_cat(HTF_mineral, HighCa_Post ,1, 1,Logistic Categorical,53);
%logit_cat(HTF_mineral, pre_iCa ,1, 1,Logistic Categorical,67);
%logit_cat(HTF_mineral, Stone,1, 1,Logistic Categorical,104);
%logit_cat(Hx_SUBDeminProt, EDTACombo,1, 1,Logistic Categorical,10);
%logit_cat(Hx_SUBDeminProt, HighCa_Post ,1, 1,Logistic Categorical,54);
%logit_cat(Hx_SUBDeminProt, pre_iCa ,1, 1,Logistic Categorical,68);
%logit_cat(Hx_SUBDeminProt, Stone,1, 1,Logistic Categorical,105);
%logit_cat(Hx_SUBDeminReobstruct, EDTACombo,1, 1,Logistic Categorical,11);
%logit_cat(Hx_SUBDeminReobstruct, HighCa_Post ,1, 1,Logistic Categorical,55);
%logit_cat(Hx_SUBDeminReobstruct, pre_iCa ,1, 1,Logistic Categorical,69);
%logit_cat(Hx_SUBDeminReobstruct, Stone,1, 1,Logistic Categorical,106);
%logit_cat(Hx_SUBDeminWork, EDTACombo,1, 1,Logistic Categorical,12);
%logit_cat(Hx_SUBDeminWork, HighCa_Post ,0, 1,Logistic Categorical,56);
%logit_cat(Hx_SUBDeminWork, pre_iCa ,1, 1,Logistic Categorical,70);
%logit_cat(Hx_SUBDeminWork, Stone,0, 1,Logistic Categorical,107);
%logit_cat(Hx_SUBInfectionProt, EDTACombo,1, 1,Logistic Categorical,9);
%logit_cat(Hx_SUBinfectionProtWork, EDTACombo,1, 1,Logistic Categorical,13);
%logit_cat(LikelyRenal, GroupCats ,1, 1,Logistic Categorical,19);
%logit_cat(NotRenal, GroupCats ,1, 1,Logistic Categorical,20);
%logit_cat(Post_Dysuria, GroupCats ,1, 1,Logistic Categorical,31);
%logit_cat(Post_Ecoli, GroupCats ,1, 1,Logistic Categorical,32);
%logit_cat(Post_Entero, GroupCats ,1, 1,Logistic Categorical,33);
%logit_cat(Post_Staph, GroupCats ,1, 1,Logistic Categorical,35);
%logit_cat(Post_UTIany, CystotIntraOp,1, 1,Logistic Categorical,4);
%logit_cat(Post_UTIany, PreAbx72,0, 1,Logistic Categorical,76);
%logit_cat(Post_UTIany, PreSx_UTI ,1, 1,Logistic Categorical,85);
%logit_cat(Post_UTIany, GroupCats ,1, 1,Logistic Categorical,36);
%logit_cat(PreSx_UTI, Hx_Cystot ,1, 1,Logistic Categorical,60);
%logit_cat(PreSx_UTI, HxPreUTI ,1, 1,Logistic Categorical,63);
%logit_cat(PurulentDebris, Hx_Cystot ,1, 1,Logistic Categorical,61);
%logit_cat(PurulentDebris, HxPreUTI ,1, 1,Logistic Categorical,64);
%logit_cat(PurulentDebris, PreAbx72 ,0, 1,Logistic Categorical,81);
%logit_cat(PurulentDebris, PreSx_UTI ,1, 1,Logistic Categorical,86);
%logit_cat(Stone_CompleteOcclude, GroupDevices ,1, 1,Logistic Categorical,48);
%logit_cat(Stone_CompleteOcclude, HighCa_Post ,1, 1,Logistic Categorical,57);
%logit_cat(Stone_CompleteOcclude, pre_iCa ,1, 1,Logistic Categorical,71);
%logit_cat(Stone_CompleteOcclude, Stone,1, 1,Logistic Categorical,108);
%logit_cat(SymptomUTI, CystotIntraOp,1, 1,Logistic Categorical,5);
%logit_cat(SymptomUTI, GroupCats ,1, 1,Logistic Categorical,38);
%logit_cat(SymptomUTI, PreAbx72,0, 1,Logistic Categorical,77);
%logit_cat(SymptomUTI, PreSx_UTI ,1, 1,Logistic Categorical,87);
%logit_cat(Uculture_Pyelo_Result, Hx_Cystot ,1, 1,Logistic Categorical,62);
%logit_cat(Uculture_Pyelo_Result, HxPreUTI ,1, 1,Logistic Categorical,65);
%logit_cat(Uculture_Pyelo_Result, PreAbx72 ,0, 1,Logistic Categorical,82);
%logit_cat(Uculture_Pyelo_Result, PreSx_UTI ,1, 1,Logistic Categorical,88);
%logit_cat(UnlikRenal, GroupCats ,1, 1,Logistic Categorical,40);
%logit_cat(UTI_ChronicBac, AnyUcathPost,1, 1,Logistic Categorical,1);
%logit_cat(UTI_ChronicBac, CystotIntraOp,1, 1,Logistic Categorical,6);
%logit_cat(UTI_ChronicBac, GroupCats ,1, 1,Logistic Categorical,41);
%logit_cat(UTI_ChronicBac, PreAbx72,0, 1,Logistic Categorical,78);
%logit_cat(UTI_ChronicBac, PreSx_UTI ,1, 1,Logistic Categorical,89);
%logit_cat(UTI_ChronicFungal, CystotIntraOp,1, 1,Logistic Categorical,7);
%logit_cat(UTI_ChronicFungal, GroupCats ,1, 1,Logistic Categorical,42);
%logit_cat(UTI_ChronicFungal, PreAbx72,0, 1,Logistic Categorical,79);
%logit_cat(UTI_ChronicFungal, PreSx_UTI ,1, 1,Logistic Categorical,90);


/*ods pdf close;*/
ods excel close;



/* Moving ChiSquare to bottom, appears to be abandoned and replaced with logit as of 20210227 */




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
ods pdf file= "&outdir.\mlm_chi.pdf";
data ctf_all; set _null_; data f_p; set _null_; data chi_p; set _null_; run;
%chi(ChronicUTI, CystotIntraOp, Chi_Square,2);
%chi(ClearIFX, CystotIntraOp, Chi_Square,3);
%chi(DefUreter, GroupCats, Chi_Square,17);
%chi(Post_Dysuria, GroupCats, Chi_Square,31);
%chi(UnlikRenal, GroupCats, Chi_Square,40);
%chi(ChronicUTI, GroupCats, Chi_Square,41);
%chi(UTI_ChronicBac, GroupCats, Chi_Square,41);
%chi(UTI_ChronicFungal, GroupCats, Chi_Square,41);
%chi(Post_UTIany, GroupCats, Chi_Square,41);
%chi(HTF_mineral, GroupDevices, Chi_Square,46);
%chi(ExchgeStone_Comp, GroupDevices, Chi_Square,46);
%chi(Exchanged, GroupDevices, Chi_Square,46);
%chi(PreSx_UTI, Hx_Cystot, Chi_Square,60);
%chi(PurulentDebris, Hx_Cystot, Chi_Square,61);
%chi(Uculture_Pyelo_Result, Hx_Cystot, Chi_Square,62);
%chi(ChronicUTI, PreAbx72, Chi_Square,74);
%chi(PurulentDebris, PreAbx72, Chi_Square,81);
%chi(SymptomUTI, PreAbx72, Chi_Square,77);
%chi(Post_UTIany, PreAbx72, Chi_Square,76);
%chi(Uculture_Pyelo_Result, PreAbx72, Chi_Square,82);
%chi(Uculture_Pyelo_Result, PreSx_UTI, Chi_Square,88);
%chi(Hx_SUBDeminReobstruct, Stone, Chi_Square,106);
ods pdf close;

