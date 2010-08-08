#include "ctrlpack.h"
#include "../calelm/calpack.h"

struct
{
  double ef2;
} no2f_;

#define no2f_1 no2f_

struct
{
  int nall;
} comall_;

#define comall_1 comall_

struct
{
  int nwf, info, ll;
} sortie_;

#define sortie_1 sortie_

/* Table of constant values */

static int c__1 = 1;
static int c__15 = 15;
static int c__14 = 14;

/*%but 
 *    cette subroutine contient les differents messages 
 *    a afficher suivant le deroulement de l execution. 
 *% liste d'appel 
 *    Entrees : 
 *    - ifich. est l'indice du message (-1 pour une 
 *       intersection avec la face, 1 pour une localisation 
 *       d un minimum local, 2 pour le resultat a un certain 
 *    degre ...) 
 *    - neq. est le degre (ou dimension) ou se situe 
 *       la recherche actuelle. 
 *    - neqbac. contient la valeur du degre avant le 1er 
 *       appel de lsoda 
 *    - tq. est le tableau contenant les coefficients du 
 *       polynome. 
 *    - w. trableau de travail 
 * 
 *    Sortie  : Aucune . 
 *% 
 *    Copyright INRIA 
 */

int
nsp_ctrlpack_outl2 (int *ifich, int *neq, int *neqbac, double *tq, double *v,
		    double *t, double *tout)
{
  int i__3;
  int lfree;
  double errel;
  int ltrti, mxsol, ng, nq;
  int ltqdot;
  char buf[80];
  int lpd, ltg, ltq, ltr;
  double phi0;

  /* Parameter adjustments */
  --v;
  --tq;
  --neq;
  /* Function Body */
  nq = neq[1];
  /* 
   * 
   */
  sprintf (buf, "(%3d)", neq[1]);
  if (*ifich >= 80)
    {
      goto L400;
    }
  if (*ifich >= 70)
    {
      goto L350;
    }
  if (*ifich >= 60)
    {
      goto L300;
    }
  if (*ifich >= 50)
    {
      goto L250;
    }
  if (*ifich >= 40)
    {
      goto L200;
    }
  if (*ifich >= 30)
    {
      goto L150;
    }
  if (*ifich >= 20)
    {
      goto L100;
    }
  ng = neq[2];
  ltq = 1;
  ltg = ltq + neq[3] + 1;
  ltqdot = ltg + ng + 1 + (nq + ng + 1);
  ltr = ltqdot + nq;
  lpd = ltr + ng + nq + 1;
  ltrti = lpd + nq * nq;
  lfree = ltrti + nq + 1;
  if (*ifich < 17)
    {
      sprintf (buf, "(%3d)", nq);
      Sciprintf
	("----------------- TRACE AT  ORDER: %s ----------------------", buf);
      if (*ifich < 0)
	{
	  /*Writing concatenation 
	   */
	  Sciprintf ("Intersection with a degree %s facet ", buf);
	}
      else if (*ifich == 1)
	{
	  Sciprintf (" Minimum found for order: %s", buf);
	}
      else if (*ifich == 2)
	{
	  Sciprintf (" Local minimum found for order: %s", buf);
	}
      else if (*ifich == 3)
	{
	  Sciprintf (" Maximum found for order: %s", buf);
	}
      else if (*ifich == 4)
	{
	  Sciprintf (" Local maximum found for order: %s", buf);
	}
      else if (*ifich == 14 || *ifich == 15 || *ifich == 16)
	{
	  Sciprintf (" Reached point:");
	}
      Sciprintf ("Denominator:");
      i__3 = nq + 1;
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &i__3, &c__15, &sortie_1.ll,
			   &sortie_1.nwf);
      Sciprintf ("Numerator", 9L);
      nsp_ctrlpack_dmdspf (&v[1], &c__1, &c__1, &nq, &c__15, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  else
    {
      Sciprintf ("Gradient :", 10L);
      nsp_ctrlpack_dmdspf (&v[1], &c__1, &c__1, &nq, &c__15, &sortie_1.ll,
			   &sortie_1.nwf);
      phi0 = *t;
      Sciprintf (" Error L2 norm                    : %14.7f\n", phi0);
      Sciprintf (" Datas L2 norm                    : %14.7f\n", *tout);
      errel = sqrt (phi0);
      Sciprintf (" Relative error norm              : %14.7f\n", errel);
      Sciprintf
	("---------------------------------------------------------------\n");
    }
L100:
  /*    messages du sous programme arl2 
   */
  if (*ifich == 20)
    {
      Sciprintf
	("LSODE 1  ------------------------------------------------------\n");
      Sciprintf (" dg=%d dgback = %d\n", nq, *neqbac);
    }
  else if (*ifich == 21)
    {
      Sciprintf
	("LSODE 2  ------------------------------------------------------\n");
    }
  else if (*ifich == 22)
    {
      Sciprintf (" Unwanted loop beetween two orders..., Stop\n");
    }
  else if (*ifich == 23)
    {
      Sciprintf ("found %d face returns\n", *neqbac);
    }
  return 0;
L150:
  /*    messages du sous programme optml2    */
  if (*ifich == 30)
    {
      Sciprintf
	("Optml2 ========== parameters before lsode call =================");
      Sciprintf ("t=%f tout=%f\n", *t, *tout);
      Sciprintf (" Q initial :");
      i__3 = nq + 1;
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &i__3, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  else if (*ifich == 31)
    {
      Sciprintf
	("Optml2 ========== parameters after lsode call   ================");
      Sciprintf ("|grad|= %f nbout=%d t=%f tout=%f\n", v[1], *neqbac, *t,
		 *tout);
      Sciprintf (" Q final :");
      i__3 = nq + 1;
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &i__3, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
      Sciprintf
	("Optml2 =========== End of LSODE description======================");
    }
  else if (*ifich == 32)
    {
      Sciprintf (" Lsode: no convergence (istate=-5)\n");
      Sciprintf (" new call with reduced tolerances\n");
    }
  else if (*ifich == 33)
    {
      Sciprintf (" Lsode: no convergence (istate=-6)\n");
    }
  else if (*ifich == 34)
    {
      Sciprintf ("t=%14.7f tout=%14.7f\n", *t, *tout);
      Sciprintf ("itol=%d rtol=%14.7f\n", *neqbac, v[1]);
      Sciprintf ("atol=");
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &nq, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  else if (*ifich == 35)
    {
      Sciprintf ("itol=%d \n", *neqbac);
      Sciprintf ("rtol=");
      nsp_ctrlpack_dmdspf (&v[1], &c__1, &c__1, &nq, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
      Sciprintf ("atol=");
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &nq, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  else if (*ifich == 36)
    {
      Sciprintf ("new call with increased tolerances");
    }
  else if (*ifich == 37)
    {
      Sciprintf (" LSODE stops with istate = %d\n", *neqbac);
    }
  else if (*ifich == 38)
    {
      Sciprintf (" Lsode stops: too many integration steps  (istate= -1)\n");
      Sciprintf ("   new call to go further");
    }
  else if (*ifich == 39)
    {
      Sciprintf ("Repeated LSODE failure --  OPTML2 stops");
    }
  return 0;
L200:
  /*message relatifs au sous programme domout */
  if (*ifich == 40)
    {
      Sciprintf
	("********LOOKING FOR INTERSECTION  WITH STABILITY DOMAIN BOUNDS ********");
      Sciprintf ("kmax=%d\n", (*neqbac));
    }
  else if (*ifich == 41)
    {
      Sciprintf
	("Domout ========== parameters before lsode call =================");
      Sciprintf ("t=%f tout=%f\n", *t, *tout);
      Sciprintf (" initial Q :");
      i__3 = nq + 1;
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &i__3, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  else if (*ifich == 42)
    {
      Sciprintf
	("Domout ========== parameters after lsode call  =================");
      Sciprintf (" nbout=%d t=%f tout=%f\n", *neqbac, *t, *tout);
      Sciprintf (" Q final :");
      i__3 = nq + 1;
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &i__3, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
      Sciprintf
	("Domout ========== End of LSODE description======================");
    }
  else if (*ifich == 43)
    {
      Sciprintf (" Lsode stops: too many integration steps  (istate= -1)");
      Sciprintf ("   new call to go further");
    }
  else if (*ifich == 44)
    {
      Sciprintf ("Number of unstable roots: %d\n", *neqbac);
    }
  else if (*ifich == 45)
    {
      Sciprintf
	(" lsode problem (istate=%d) when looking for intersection with ",
	 *neqbac);
      Sciprintf ("   stability domain bounds... Stop\n");
    }
  else if (*ifich == 46)
    {
      Sciprintf ("watface --> nface= %d", *neqbac);
      Sciprintf ("onface --> neq= %d", nq);
      Sciprintf (" yi=%f yf=%f", *t, *tout);
      i__3 = nq + 1;
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &i__3, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  else if (*ifich == 47)
    {
      Sciprintf (" goto 314 ===========================");
      Sciprintf (" qi = ", 6L);
      i__3 = nq + 1;
      nsp_ctrlpack_dmdspf (&v[1], &c__1, &c__1, &i__3, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  else if (*ifich == 47)
    {
      Sciprintf
	("********END OF INTERSECTION  WITH STABILITY DOMAIN BOUNDS SEARCH ********");
    }
  return 0;
L250:
  /*    messages de deg1l2 et degl2  */
  if (*ifich == 50)
    {
      Sciprintf (" Non convergence  ... look for next solution .");
    }
  else if (*ifich == 51)
    {
      Sciprintf
	("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      Sciprintf (" Look for all minina of degree: %d\n", nq);
      Sciprintf
	("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    }
  else if (*ifich == 52)
    {
      Sciprintf
	("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      Sciprintf (" End of search degree %d minima\n", nq);
      Sciprintf
	("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      mxsol = (int) (*tout);
      Sciprintf (" Q(0) :", 7L);
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &nq, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
      Sciprintf (" corresponding relatives errors");
      nsp_ctrlpack_dmdspf (&tq[mxsol + 1], &c__1, &c__1, neqbac, &c__14,
			   &sortie_1.ll, &sortie_1.nwf);
    }
  else if (*ifich == 53)
    {
      Sciprintf
	("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      Sciprintf (" End of search degree %d minima\n", nq);
      Sciprintf
	("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      mxsol = (int) (*tout);
      Sciprintf (" corresponding denominators:");
      nsp_ctrlpack_dmdspf (&tq[1], &mxsol, neqbac, &nq, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
      Sciprintf (" relatives errors");
      nsp_ctrlpack_dmdspf (&tq[mxsol * nq + 1], &mxsol, neqbac, &c__1, &c__14,
			   &sortie_1.ll, &sortie_1.nwf);
    }
  return 0;
L300:
  /*messages de roogp  */
  if (*ifich == 60)
    {
      Sciprintf
	("Rootgp : No value found for Beta when looking for intersection with a complex facet");
      Sciprintf ("        Stop");
    }
  return 0;
L350:
  /*messages de onface */
  if (*ifich == 70)
    {
      buf[3] = '\0';
      Sciprintf ("(%2d) Domain boundary reached,\n");
      Sciprintf ("    Order is deacreased by %s\n", buf);
    }
  else if (*ifich == 71)
    {
      Sciprintf ("Remainder:");
      nsp_ctrlpack_dmdspf (&tq[1], &c__1, &c__1, &nq, &c__14, &sortie_1.ll,
			   &sortie_1.nwf);
    }
  return 0;
L400:
  if (*ifich == 80)
    {
      Sciprintf ("Already reached minimum\n");
    }
  else if (*ifich == 81)
    {
      Sciprintf ("Preserve minimun in  tback\n");
    }
  return 0;
}
