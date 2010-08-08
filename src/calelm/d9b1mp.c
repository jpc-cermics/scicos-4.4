/* d9b1mp.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static int c__3 = 3;
static int c__37 = 37;
static int c__39 = 39;
static int c__40 = 40;
static int c__44 = 44;
static int c__4 = 4;
static int c__1 = 1;
static int c__2 = 2;

/*DECK D9B1MP 
 */
int nsp_calpack_d9b1mp (double *x, double *ampl, double *theta)
{
  /* Initialized data */

  static double bm1cs[37] =
    { .1069845452618063014969985308538, .003274915039715964900729055143445,
    -2.987783266831698592030445777938e-5, 8.331237177991974531393222669023e-7,
    -4.112665690302007304896381725498e-8, 2.855344228789215220719757663161e-9,
    -2.485408305415623878060026596055e-10,
    2.543393338072582442742484397174e-11,
    -2.941045772822967523489750827909e-12,
    3.743392025493903309265056153626e-13,
    -5.149118293821167218720548243527e-14,
    7.552535949865143908034040764199e-15,
    -1.169409706828846444166290622464e-15,
    1.89656244943479157172182460506e-16,
    -3.201955368693286420664775316394e-17,
    5.599548399316204114484169905493e-18,
    -1.010215894730432443119390444544e-18,
    1.873844985727562983302042719573e-19,
    -3.563537470328580219274301439999e-20,
    6.931283819971238330422763519999e-21,
    -1.376059453406500152251408930133e-21,
    2.783430784107080220599779327999e-22,
    -5.727595364320561689348669439999e-23,
    1.197361445918892672535756799999e-23,
    -2.539928509891871976641440426666e-24,
    5.461378289657295973069619199999e-25,
    -1.189211341773320288986289493333e-25, 2.620150977340081594957824e-26,
    -5.836810774255685901920938666666e-27,
    1.313743500080595773423615999999e-27,
    -2.985814622510380355332778666666e-28,
    6.848390471334604937625599999999e-29,
    -1.58440156822247672119296e-29, 3.695641006570938054301013333333e-30,
    -8.687115921144668243012266666666e-31,
    2.057080846158763462929066666666e-31,
    -4.905225761116225518523733333333e-32
  };
  static double bt12cs[39] =
    { .73823860128742974662620839792764, -.0033361113174483906384470147681189,
    6.1463454888046964698514899420186e-5,
    -2.4024585161602374264977635469568e-6,
    1.4663555577509746153210591997204e-7,
    -1.1841917305589180567005147504983e-8,
    1.1574198963919197052125466303055e-9,
    -1.3001161129439187449366007794571e-10,
    1.6245391141361731937742166273667e-11,
    -2.2089636821403188752155441770128e-12,
    3.2180304258553177090474358653778e-13,
    -4.9653147932768480785552021135381e-14,
    8.0438900432847825985558882639317e-15,
    -1.3589121310161291384694712682282e-15,
    2.3810504397147214869676529605973e-16,
    -4.3081466363849106724471241420799e-17,
    8.02025440327710024349935125504e-18,
    -1.5316310642462311864230027468799e-18,
    2.9928606352715568924073040554666e-19,
    -5.9709964658085443393815636650666e-20,
    1.2140289669415185024160852650666e-20,
    -2.5115114696612948901006977706666e-21,
    5.2790567170328744850738380799999e-22,
    -1.1260509227550498324361161386666e-22,
    2.43482773595763266596634624e-23, -5.3317261236931800130038442666666e-24,
    1.1813615059707121039205990399999e-24,
    -2.6465368283353523514856789333333e-25,
    5.9903394041361503945577813333333e-26,
    -1.3690854630829503109136383999999e-26,
    3.1576790154380228326413653333333e-27,
    -7.3457915082084356491400533333333e-28,
    1.722808148072274793070592e-28, -4.07169079612865079410688e-29,
    9.6934745136779622700373333333333e-30,
    -2.3237636337765716765354666666666e-30,
    5.6074510673522029406890666666666e-31,
    -1.3616465391539005860522666666666e-31,
    3.3263109233894654388906666666666e-32
  };
  static double bm12cs[40] =
    { .09807979156233050027272093546937, .001150961189504685306175483484602,
    -4.312482164338205409889358097732e-6, 5.951839610088816307813029801832e-8,
    -1.704844019826909857400701586478e-9,
    7.798265413611109508658173827401e-11,
    -4.958986126766415809491754951865e-12,
    4.038432416421141516838202265144e-13,
    -3.993046163725175445765483846645e-14,
    4.619886183118966494313342432775e-15,
    -6.089208019095383301345472619333e-16,
    8.960930916433876482157048041249e-17,
    -1.449629423942023122916518918925e-17,
    2.546463158537776056165149648068e-18,
    -4.80947287464783644425926371862e-19,
    9.687684668292599049087275839124e-20,
    -2.067213372277966023245038117551e-20,
    4.64665155915038473180276780959e-21,
    -1.094966128848334138241351328339e-21,
    2.693892797288682860905707612785e-22,
    -6.894992910930374477818970026857e-23,
    1.83026826275206290989066855474e-23,
    -5.025064246351916428156113553224e-24,
    1.423545194454806039631693634194e-24,
    -4.152191203616450388068886769801e-25,
    1.244609201503979325882330076547e-25,
    -3.827336370569304299431918661286e-26,
    1.205591357815617535374723981835e-26,
    -3.884536246376488076431859361124e-27,
    1.278689528720409721904895283461e-27,
    -4.295146689447946272061936915912e-28,
    1.470689117829070886456802707983e-28,
    -5.128315665106073128180374017796e-29,
    1.819509585471169385481437373286e-29,
    -6.563031314841980867618635050373e-30,
    2.404898976919960653198914875834e-30,
    -8.945966744690612473234958242979e-31,
    3.37608516065723102663714897824e-31,
    -1.291791454620656360913099916966e-31,
    5.008634462958810520684951501254e-32
  };
  static double bth1cs[44] =
    { .74749957203587276055443483969695, -.0012400777144651711252545777541384,
    9.9252442404424527376641497689592e-6,
    -2.0303690737159711052419375375608e-7,
    7.5359617705690885712184017583629e-9,
    -4.1661612715343550107630023856228e-10,
    3.0701618070834890481245102091216e-11,
    -2.8178499637605213992324008883924e-12,
    3.0790696739040295476028146821647e-13,
    -3.8803300262803434112787347554781e-14,
    5.5096039608630904934561726208562e-15,
    -8.6590060768383779940103398953994e-16,
    1.4856049141536749003423689060683e-16,
    -2.7519529815904085805371212125009e-17,
    5.4550796090481089625036223640923e-18,
    -1.1486534501983642749543631027177e-18,
    2.5535213377973900223199052533522e-19,
    -5.9621490197413450395768287907849e-20,
    1.4556622902372718620288302005833e-20,
    -3.7022185422450538201579776019593e-21,
    9.7763074125345357664168434517924e-22,
    -2.6726821639668488468723775393052e-22,
    7.5453300384983271794038190655764e-23,
    -2.1947899919802744897892383371647e-23,
    6.5648394623955262178906999817493e-24,
    -2.0155604298370207570784076869519e-24,
    6.341776855677614349214466718567e-25,
    -2.0419277885337895634813769955591e-25,
    6.7191464220720567486658980018551e-26,
    -2.2569079110207573595709003687336e-26,
    7.7297719892989706370926959871929e-27,
    -2.696744451229464091321142408092e-27,
    9.5749344518502698072295521933627e-28,
    -3.4569168448890113000175680827627e-28,
    1.2681234817398436504211986238374e-28,
    -4.7232536630722639860464993713445e-29,
    1.7850008478186376177858619796417e-29,
    -6.8404361004510395406215223566746e-30,
    2.6566028671720419358293422672212e-30,
    -1.045040252791445291771416148467e-30,
    4.1618290825377144306861917197064e-31,
    -1.6771639203643714856501347882887e-31,
    6.8361997776664389173535928028528e-32,
    -2.817224786123364116673957462281e-32
  };
  static double pi4 = .785398163397448309615660845819876;
  static int first = TRUE;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  static int nbm12, nbt12;
  static double xmax;
  static int nbth1;
  double z__;
  double eta;
  static int nbm1;

  /****BEGIN PROLOGUE  D9B1MP 
   ****SUBSIDIARY 
   ****PURPOSE  Evaluate the modulus and phase for the J1 and Y1 Bessel 
   *           functions. 
   ****LIBRARY   SLATEC (FNLIB) 
   ****CATEGORY  C10A1 
   ****TYPE      DOUBLE PRECISION (D9B1MP-D) 
   ****KEYWORDS  BESSEL FUNCTION, FNLIB, MODULUS, PHASE, SPECIAL FUNCTIONS 
   ****AUTHOR  Fullerton, W., (LANL) 
   ****DESCRIPTION 
   * 
   *Evaluate the modulus and phase for the Bessel J1 and Y1 functions. 
   * 
   *Series for BM1        on the interval  1.56250E-02 to  6.25000E-02 
   *                                       with weighted error   4.91E-32 
   *                                        log weighted error  31.31 
   *                              significant figures required  30.04 
   *                                   decimal places required  32.09 
   * 
   *Series for BT12       on the interval  1.56250E-02 to  6.25000E-02 
   *                                       with weighted error   3.33E-32 
   *                                        log weighted error  31.48 
   *                              significant figures required  31.05 
   *                                   decimal places required  32.27 
   * 
   *Series for BM12       on the interval  0.          to  1.56250E-02 
   *                                       with weighted error   5.01E-32 
   *                                        log weighted error  31.30 
   *                              significant figures required  29.99 
   *                                   decimal places required  32.10 
   * 
   *Series for BTH1       on the interval  0.          to  1.56250E-02 
   *                                       with weighted error   2.82E-32 
   *                                        log weighted error  31.55 
   *                              significant figures required  31.12 
   *                                   decimal places required  32.37 
   * 
   ****SEE ALSO  DBESJ1, DBESY1 
   ****REFERENCES  (NONE) 
   ****ROUTINES CALLED  D1MACH, DCSEVL, INITDS, XERMSG 
   ****REVISION HISTORY  (YYMMDD) 
   *  770701  DATE WRITTEN 
   *  890531  Changed all specific intrinsics to generic.  (WRB) 
   *  890531  REVISION DATE from Version 3.2 
   *  891214  Prologue converted to Version 4.0 format.  (BAB) 
   *  900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ) 
   *  900720  Routine changed from user-callable to subsidiary.  (WRB) 
   *  920618  Removed space from variable name and code restructured to 
   *          use IF-THEN-ELSE.  (RWC, WRB) 
   ****END PROLOGUE  D9B1MP 
   */
  /****FIRST EXECUTABLE STATEMENT  D9B1MP 
   */
  if (first)
    {
      eta = nsp_calpack_d1mach (&c__3) * .1;
      nbm1 = nsp_calpack_initds (bm1cs, &c__37, &eta);
      nbt12 = nsp_calpack_initds (bt12cs, &c__39, &eta);
      nbm12 = nsp_calpack_initds (bm12cs, &c__40, &eta);
      nbth1 = nsp_calpack_initds (bth1cs, &c__44, &eta);
      /* 
       */
      xmax = 1. / nsp_calpack_d1mach (&c__4);
    }
  first = FALSE;
  /* 
   */
  if (*x < 4.)
    {
      nsp_calpack_xermsg ("SLATEC", "D9B1MP", "X must be .GE. 4", &c__1,
			  &c__2, 6L, 6L, 16L);
      *ampl = 0.;
      *theta = 0.;
    }
  else if (*x <= 8.)
    {
      z__ = (128. / (*x * *x) - 5.) / 3.;
      *ampl = (nsp_calpack_dcsevl (&z__, bm1cs, &nbm1) + .75) / sqrt (*x);
      *theta = *x - pi4 * 3. + nsp_calpack_dcsevl (&z__, bt12cs, &nbt12) / *x;
    }
  else
    {
      if (*x > xmax)
	{
	  nsp_calpack_xermsg ("SLATEC", "D9B1MP",
			      "No precision because X is too big", &c__2,
			      &c__2, 6L, 6L, 33L);
	}
      /* 
       */
      z__ = 128. / (*x * *x) - 1.;
      *ampl = (nsp_calpack_dcsevl (&z__, bm12cs, &nbm12) + .75) / sqrt (*x);
      *theta = *x - pi4 * 3. + nsp_calpack_dcsevl (&z__, bth1cs, &nbth1) / *x;
    }
  return 0;
}				/* d9b1mp_ */
