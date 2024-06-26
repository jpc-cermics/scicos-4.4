/* xermsg.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static int c__2 = 2;
static int c__0 = 0;
static int c_false = FALSE;
static int c__4 = 4;
static int c_n1 = -1;
static int c__72 = 72;
static int c__1 = 1;
static int c_true = TRUE;

/*DECK XERMSG 
 */
int
nsp_calpack_xermsg (char *librar, char *subrou, char *messg, int *nerr,
		    int *level, long int librar_len, long int subrou_len,
		    long int messg_len)
{
  /* System generated locals */
  address a__1[2];
  int i__1, i__2, i__3[2];
  char ch__1[87];
  icilist ici__1;

  /* Builtin functions */
  int s_copy (char *, char *, long int, long int);
  int i_len (char *, long int), s_wsfi (icilist *), do_fio (int *, char *,
							    long int),
    e_wsfi (void);
  int s_cat (char *, char **, int *, int *, long int);

  /* Local variables */
  int lerr;
  char temp[72];
  int i__;
  char xlibr[8];
  int ltemp, kount;
  char xsubr[8];
  int llevel, maxmes;
  char lfirst[20];
  int lkntrl, kdummy;
  int mkntrl;

  /****BEGIN PROLOGUE  XERMSG 
   ****PURPOSE  Process error messages for SLATEC and other libraries. 
   ****LIBRARY   SLATEC (XERROR) 
   ****CATEGORY  R3C 
   ****TYPE      ALL (XERMSG-A) 
   ****KEYWORDS  ERROR MESSAGE, XERROR 
   ****AUTHOR  Fong, Kirby, (NMFECC at LLNL) 
   ****DESCRIPTION 
   * 
   *  XERMSG processes a diagnostic message in a manner determined by the 
   *  value of LEVEL and the current value of the library error control 
   *  flag, KONTRL.  See subroutine XSETF for details. 
   * 
   *   LIBRAR   A character constant (or character variable) with the name 
   *            of the library.  This will be 'SLATEC' for the SLATEC 
   *            Common Math Library.  The error handling package is 
   *            general enough to be used by many libraries 
   *            simultaneously, so it is desirable for the routine that 
   *            detects and reports an error to identify the library name 
   *            as well as the routine name. 
   * 
   *   SUBROU   A character constant (or character variable) with the name 
   *            of the routine that detected the error.  Usually it is the 
   *            name of the routine that is calling XERMSG.  There are 
   *            some instances where a user callable library routine calls 
   *            lower level subsidiary routines where the error is 
   *            detected.  In such cases it may be more informative to 
   *            supply the name of the routine the user called rather than 
   *            the name of the subsidiary routine that detected the 
   *            error. 
   * 
   *   MESSG    A character constant (or character variable) with the text 
   *            of the error or warning message.  In the example below, 
   *            the message is a character constant that contains a 
   *            generic message. 
   * 
   *                  CALL XERMSG ('SLATEC', 'MMPY', 
   *                 *'THE ORDER OF THE MATRIX EXCEEDS THE ROW DIMENSION', 
   *                 *3, 1) 
   * 
   *            It is possible (and is sometimes desirable) to generate a 
   *            specific message--e.g., one that contains actual numeric 
   *            values.  Specific numeric values can be converted into 
   *            character strings using formatted WRITE statements into 
   *            character variables.  This is called standard Fortran 
   *            internal file I/O and is exemplified in the first three 
   *            lines of the following example.  You can also catenate 
   *            substrings of characters to construct the error message. 
   *            Here is an example showing the use of both writing to 
   *            an internal file and catenating character strings. 
   * 
   *                  CHARACTER*5 CHARN, CHARL 
   *                  WRITE (CHARN,10) N 
   *                  WRITE (CHARL,10) LDA 
   *               10 FORMAT(I5) 
   *                  CALL XERMSG ('SLATEC', 'MMPY', 'THE ORDER'//CHARN// 
   *                 *   ' OF THE MATRIX EXCEEDS ITS ROW DIMENSION OF'// 
   *                 *   CHARL, 3, 1) 
   * 
   *            There are two subtleties worth mentioning.  One is that 
   *            the // for character catenation is used to construct the 
   *            error message so that no single character constant is 
   *            continued to the next line.  This avoids confusion as to 
   *            whether there are trailing blanks at the end of the line. 
   *            The second is that by catenating the parts of the message 
   *            as an actual argument rather than encoding the entire 
   *            message into one large character variable, we avoid 
   *            having to know how long the message will be in order to 
   *            declare an adequate length for that large character 
   *            variable.  XERMSG calls XERPRN to print the message using 
   *            multiple lines if necessary.  If the message is very long, 
   *            XERPRN will break it into pieces of 72 characters (as 
   *            requested by XERMSG) for printing on multiple lines. 
   *            Also, XERMSG asks XERPRN to prefix each line with ' *  ' 
   *            so that the total line length could be 76 characters. 
   *            Note also that XERPRN scans the error message backwards 
   *            to ignore trailing blanks.  Another feature is that 
   *            the substring '$$' is treated as a new line sentinel 
   *            by XERPRN.  If you want to construct a multiline 
   *            message without having to count out multiples of 72 
   *            characters, just use '$$' as a separator.  '$$' 
   *            obviously must occur within 72 characters of the 
   *            start of each line to have its intended effect since 
   *            XERPRN is asked to wrap around at 72 characters in 
   *            addition to looking for '$$'. 
   * 
   *   NERR     An int value that is chosen by the library routine's 
   *            author.  It must be in the range -99 to 999 (three 
   *            printable digits).  Each distinct error should have its 
   *            own error number.  These error numbers should be described 
   *            in the machine readable documentation for the routine. 
   *            The error numbers need be unique only within each routine, 
   *            so it is reasonable for each routine to start enumerating 
   *            errors from 1 and proceeding to the next int. 
   * 
   *   LEVEL    An int value in the range 0 to 2 that indicates the 
   *            level (severity) of the error.  Their meanings are 
   * 
   *           -1  A warning message.  This is used if it is not clear 
   *               that there really is an error, but the user's attention 
   *               may be needed.  An attempt is made to only print this 
   *               message once. 
   * 
   *            0  A warning message.  This is used if it is not clear 
   *               that there really is an error, but the user's attention 
   *               may be needed. 
   * 
   *            1  A recoverable error.  This is used even if the error is 
   *               so serious that the routine cannot return any useful 
   *               answer.  If the user has told the error package to 
   *               return after recoverable errors, then XERMSG will 
   *               return to the Library routine which can then return to 
   *               the user's routine.  The user may also permit the error 
   *               package to terminate the program upon encountering a 
   *               recoverable error. 
   * 
   *            2  A fatal error.  XERMSG will not return to its caller 
   *               after it receives a fatal error.  This level should 
   *               hardly ever be used; it is much better to allow the 
   *               user a chance to recover.  An example of one of the few 
   *               cases in which it is permissible to declare a level 2 
   *               error is a reverse communication Library routine that 
   *               is likely to be called repeatedly until it integrates 
   *               across some interval.  If there is a serious error in 
   *               the input such that another step cannot be taken and 
   *               the Library routine is called again without the input 
   *               error having been corrected by the caller, the Library 
   *               routine will probably be called forever with improper 
   *               input.  In this case, it is reasonable to declare the 
   *               error to be fatal. 
   * 
   *   Each of the arguments to XERMSG is input; none will be modified by 
   *   XERMSG.  A routine may make multiple calls to XERMSG with warning 
   *   level messages; however, after a call to XERMSG with a recoverable 
   *   error, the routine should return to the user.  Do not try to call 
   *   XERMSG with a second recoverable error after the first recoverable 
   *   error because the error package saves the error number.  The user 
   *   can retrieve this error number by calling another entry point in 
   *   the error handling package and then clear the error number when 
   *   recovering from the error.  Calling XERMSG in succession causes the 
   *   old error number to be overwritten by the latest error number. 
   *   This is considered harmless for error numbers associated with 
   *   warning messages but must not be done for error numbers of serious 
   *   errors.  After a call to XERMSG with a recoverable error, the user 
   *   must be given a chance to call NUMXER or XERCLR to retrieve or 
   *   clear the error number. 
   ****REFERENCES  R. E. Jones and D. K. Kahaner, XERROR, the SLATEC 
   *                Error-handling Package, SAND82-0800, Sandia 
   *                Laboratories, 1982. 
   ****ROUTINES CALLED  FDUMP, J4SAVE, XERCNT, XERHLT, XERPRN, XERSVE 
   ****REVISION HISTORY  (YYMMDD) 
   *  880101  DATE WRITTEN 
   *  880621  REVISED AS DIRECTED AT SLATEC CML MEETING OF FEBRUARY 1988. 
   *          THERE ARE TWO BASIC CHANGES. 
   *          1.  A NEW ROUTINE, XERPRN, IS USED INSTEAD OF XERPRT TO 
   *              PRINT MESSAGES.  THIS ROUTINE WILL BREAK LONG MESSAGES 
   *              INTO PIECES FOR PRINTING ON MULTIPLE LINES.  '$$' IS 
   *              ACCEPTED AS A NEW LINE SENTINEL.  A PREFIX CAN BE 
   *              ADDED TO EACH LINE TO BE PRINTED.  XERMSG USES EITHER 
   *              ' ***' OR ' *  ' AND LONG MESSAGES ARE BROKEN EVERY 
   *              72 CHARACTERS (AT MOST) SO THAT THE MAXIMUM LINE 
   *              LENGTH OUTPUT CAN NOW BE AS GREAT AS 76. 
   *          2.  THE TEXT OF ALL MESSAGES IS NOW IN UPPER CASE SINCE THE 
   *              FORTRAN STANDARD DOCUMENT DOES NOT ADMIT THE EXISTENCE 
   *              OF LOWER CASE. 
   *  880708  REVISED AFTER THE SLATEC CML MEETING OF JUNE 29 AND 30. 
   *          THE PRINCIPAL CHANGES ARE 
   *          1.  CLARIFY COMMENTS IN THE PROLOGUES 
   *          2.  RENAME XRPRNT TO XERPRN 
   *          3.  REWORK HANDLING OF '$$' IN XERPRN TO HANDLE BLANK LINES 
   *              SIMILAR TO THE WAY FORMAT STATEMENTS HANDLE THE / 
   *              CHARACTER FOR NEW RECORDS. 
   *  890706  REVISED WITH THE HELP OF FRED FRITSCH AND REG CLEMENS TO 
   *          CLEAN UP THE CODING. 
   *  890721  REVISED TO USE NEW FEATURE IN XERPRN TO COUNT CHARACTERS IN 
   *          PREFIX. 
   *  891013  REVISED TO CORRECT COMMENTS. 
   *  891214  Prologue converted to Version 4.0 format.  (WRB) 
   *  900510  Changed test on NERR to be -9999999 < NERR < 99999999, but 
   *          NERR .ne. 0, and on LEVEL to be -2 < LEVEL < 3.  Added 
   *          LEVEL=-1 logic, changed calls to XERSAV to XERSVE, and 
   *          XERCTL to XERCNT.  (RWC) 
   *  920501  Reformatted the REFERENCES section.  (WRB) 
   ****END PROLOGUE  XERMSG 
   ****FIRST EXECUTABLE STATEMENT  XERMSG 
   */
  lkntrl = nsp_calpack_j4save (&c__2, &c__0, &c_false);
  maxmes = nsp_calpack_j4save (&c__4, &c__0, &c_false);
  /* 
   *      LKNTRL IS A LOCAL COPY OF THE CONTROL FLAG KONTRL. 
   *      MAXMES IS THE MAXIMUM NUMBER OF TIMES ANY PARTICULAR MESSAGE 
   *         SHOULD BE PRINTED. 
   * 
   *      WE PRINT A FATAL ERROR MESSAGE AND TERMINATE FOR AN ERROR IN 
   *         CALLING XERMSG.  THE ERROR NUMBER SHOULD BE POSITIVE, 
   *         AND THE LEVEL SHOULD BE BETWEEN 0 AND 2. 
   * 
   */
  if (*nerr < -9999999 || *nerr > 99999999 || *nerr == 0 || *level < -1
      || *level > 2)
    {
      nsp_calpack_xerprn (" ***", &c_n1,
			  "FATAL ERROR IN...$$ XERMSG -- INVALID ERROR NUMBER OR LEVEL$$ JOB ABORT DUE TO FATAL ERROR.",
			  &c__72, 4L, 91L);
      nsp_calpack_xersve (" ", " ", " ", &c__0, &c__0, &c__0, &kdummy, 1L,
			  1L, 1L);
      nsp_calpack_xerhlt (" ***XERMSG -- INVALID INPUT", 27L);
      return 0;
    }
  /* 
   *      RECORD THE MESSAGE. 
   * 
   */
  i__ = nsp_calpack_j4save (&c__1, nerr, &c_true);
  nsp_calpack_xersve (librar, subrou, messg, &c__1, nerr, level, &kount,
		      librar_len, subrou_len, messg_len);
  /* 
   *      HANDLE PRINT-ONCE WARNING MESSAGES. 
   * 
   */
  if (*level == -1 && kount > 1)
    {
      return 0;
    }
  /* 
   *      ALLOW TEMPORARY USER OVERRIDE OF THE CONTROL FLAG. 
   * 
   */
  s_copy (xlibr, librar, 8L, librar_len);
  s_copy (xsubr, subrou, 8L, subrou_len);
  s_copy (lfirst, messg, 20L, messg_len);
  lerr = *nerr;
  llevel = *level;
  nsp_calpack_xercnt (xlibr, xsubr, lfirst, &lerr, &llevel, &lkntrl, 8L, 8L,
		      20L);
  /* 
   *Computing MAX 
   */
  i__1 = -2, i__2 = Min (2, lkntrl);
  lkntrl = Max (i__1, i__2);
  mkntrl = Abs (lkntrl);
  /* 
   *      SKIP PRINTING IF THE CONTROL FLAG VALUE AS RESET IN XERCNT IS 
   *      ZERO AND THE ERROR IS NOT FATAL. 
   * 
   */
  if (*level < 2 && lkntrl == 0)
    {
      goto L30;
    }
  if (*level == 0 && kount > maxmes)
    {
      goto L30;
    }
  if (*level == 1 && kount > maxmes && mkntrl == 1)
    {
      goto L30;
    }
  if (*level == 2 && kount > Max (1, maxmes))
    {
      goto L30;
    }
  /* 
   *      ANNOUNCE THE NAMES OF THE LIBRARY AND SUBROUTINE BY BUILDING A 
   *      MESSAGE IN CHARACTER VARIABLE TEMP (NOT EXCEEDING 66 CHARACTERS) 
   *      AND SENDING IT OUT VIA XERPRN.  PRINT ONLY IF CONTROL FLAG 
   *      IS NOT ZERO. 
   * 
   */
  if (lkntrl != 0)
    {
      s_copy (temp, "MESSAGE FROM ROUTINE ", 21L, 21L);
      /*Computing MIN 
       */
      i__1 = i_len (subrou, subrou_len);
      i__ = Min (i__1, 16);
      s_copy (temp + 21, subrou, i__, i__);
      i__1 = i__ + 21;
      s_copy (temp + i__1, " IN LIBRARY ", i__ + 33 - i__1, 12L);
      ltemp = i__ + 33;
      /*Computing MIN 
       */
      i__1 = i_len (librar, librar_len);
      i__ = Min (i__1, 16);
      i__1 = ltemp;
      s_copy (temp + i__1, librar, ltemp + i__ - i__1, i__);
      i__1 = ltemp + i__;
      s_copy (temp + i__1, ".", ltemp + i__ + 1 - i__1, 1L);
      ltemp = ltemp + i__ + 1;
      nsp_calpack_xerprn (" ***", &c_n1, temp, &c__72, 4L, ltemp);
    }
  /* 
   *      IF LKNTRL IS POSITIVE, PRINT AN INTRODUCTORY LINE BEFORE 
   *      PRINTING THE MESSAGE.  THE INTRODUCTORY LINE TELLS THE CHOICE 
   *      FROM EACH OF THE FOLLOWING THREE OPTIONS. 
   *      1.  LEVEL OF THE MESSAGE 
   *             'INFORMATIVE MESSAGE' 
   *             'POTENTIALLY RECOVERABLE ERROR' 
   *             'FATAL ERROR' 
   *      2.  WHETHER CONTROL FLAG WILL ALLOW PROGRAM TO CONTINUE 
   *             'PROG CONTINUES' 
   *             'PROG ABORTED' 
   *      3.  WHETHER OR NOT A TRACEBACK WAS REQUESTED.  (THE TRACEBACK 
   *          MAY NOT BE IMPLEMENTED AT SOME SITES, SO THIS ONLY TELLS 
   *          WHAT WAS REQUESTED, NOT WHAT WAS DELIVERED.) 
   *             'TRACEBACK REQUESTED' 
   *             'TRACEBACK NOT REQUESTED' 
   *      NOTICE THAT THE LINE INCLUDING FOUR PREFIX CHARACTERS WILL NOT 
   *      EXCEED 74 CHARACTERS. 
   *      WE SKIP THE NEXT BLOCK IF THE INTRODUCTORY LINE IS NOT NEEDED. 
   * 
   */
  if (lkntrl > 0)
    {
      /* 
       *      THE FIRST PART OF THE MESSAGE TELLS ABOUT THE LEVEL. 
       * 
       */
      if (*level <= 0)
	{
	  s_copy (temp, "INFORMATIVE MESSAGE,", 20L, 20L);
	  ltemp = 20;
	}
      else if (*level == 1)
	{
	  s_copy (temp, "POTENTIALLY RECOVERABLE ERROR,", 30L, 30L);
	  ltemp = 30;
	}
      else
	{
	  s_copy (temp, "FATAL ERROR,", 12L, 12L);
	  ltemp = 12;
	}
      /* 
       *      THEN WHETHER THE PROGRAM WILL CONTINUE. 
       * 
       */
      if (mkntrl == 2 && *level >= 1 || mkntrl == 1 && *level == 2)
	{
	  i__1 = ltemp;
	  s_copy (temp + i__1, " PROG ABORTED,", ltemp + 14 - i__1, 14L);
	  ltemp += 14;
	}
      else
	{
	  i__1 = ltemp;
	  s_copy (temp + i__1, " PROG CONTINUES,", ltemp + 16 - i__1, 16L);
	  ltemp += 16;
	}
      /* 
       *      FINALLY TELL WHETHER THERE SHOULD BE A TRACEBACK. 
       * 
       */
      if (lkntrl > 0)
	{
	  i__1 = ltemp;
	  s_copy (temp + i__1, " TRACEBACK REQUESTED", ltemp + 20 - i__1,
		  20L);
	  ltemp += 20;
	}
      else
	{
	  i__1 = ltemp;
	  s_copy (temp + i__1, " TRACEBACK NOT REQUESTED", ltemp + 24 - i__1,
		  24L);
	  ltemp += 24;
	}
      nsp_calpack_xerprn (" ***", &c_n1, temp, &c__72, 4L, ltemp);
    }
  /* 
   *      NOW SEND OUT THE MESSAGE. 
   * 
   */
  nsp_calpack_xerprn (" *  ", &c_n1, messg, &c__72, 4L, messg_len);
  /* 
   *      IF LKNTRL IS POSITIVE, WRITE THE ERROR NUMBER AND REQUEST A 
   *         TRACEBACK. 
   * 
   */
  if (lkntrl > 0)
    {
      ici__1.icierr = 0;
      ici__1.icirnum = 1;
      ici__1.icirlen = 72;
      ici__1.iciunit = temp;
      ici__1.icifmt = "('ERROR NUMBER = ', I8)";
      s_wsfi (&ici__1);
      do_fio (&c__1, (char *) &(*nerr), (long int) sizeof (int));
      e_wsfi ();
      for (i__ = 16; i__ <= 22; ++i__)
	{
	  if (*(unsigned char *) &temp[i__ - 1] != ' ')
	    {
	      goto L20;
	    }
	  /* L10: */
	}
      /* 
       */
    L20:
      /*Writing concatenation 
       */
      i__3[0] = 15, a__1[0] = temp;
      i__3[1] = 23 - (i__ - 1), a__1[1] = temp + (i__ - 1);
      s_cat (ch__1, a__1, i__3, &c__2, 87L);
      nsp_calpack_xerprn (" *  ", &c_n1, ch__1, &c__72, 4L,
			  23 - (i__ - 1) + 15);
      nsp_calpack_fdump ();
    }
  /* 
   *      IF LKNTRL IS NOT ZERO, PRINT A BLANK LINE AND AN END OF MESSAGE. 
   * 
   */
  if (lkntrl != 0)
    {
      nsp_calpack_xerprn (" *  ", &c_n1, " ", &c__72, 4L, 1L);
      nsp_calpack_xerprn (" ***", &c_n1, "END OF MESSAGE", &c__72, 4L, 14L);
      nsp_calpack_xerprn ("    ", &c__0, " ", &c__72, 4L, 1L);
    }
  /* 
   *      IF THE ERROR IS NOT FATAL OR THE ERROR IS RECOVERABLE AND THE 
   *      CONTROL FLAG IS SET FOR RECOVERY, THEN RETURN. 
   * 
   */
L30:
  if (*level <= 0 || *level == 1 && mkntrl <= 1)
    {
      return 0;
    }
  /* 
   *      THE PROGRAM WILL BE STOPPED DUE TO AN UNRECOVERED ERROR OR A 
   *      FATAL ERROR.  PRINT THE REASON FOR THE ABORT AND THE ERROR 
   *      SUMMARY IF THE CONTROL FLAG AND THE MAXIMUM ERROR COUNT PERMIT. 
   * 
   */
  if (lkntrl > 0 && kount < Max (1, maxmes))
    {
      if (*level == 1)
	{
	  nsp_calpack_xerprn (" ***", &c_n1,
			      "JOB ABORT DUE TO UNRECOVERED ERROR.", &c__72,
			      4L, 35L);
	}
      else
	{
	  nsp_calpack_xerprn (" ***", &c_n1, "JOB ABORT DUE TO FATAL ERROR.",
			      &c__72, 4L, 29L);
	}
      nsp_calpack_xersve (" ", " ", " ", &c_n1, &c__0, &c__0, &kdummy, 1L,
			  1L, 1L);
      nsp_calpack_xerhlt (" ", 1L);
    }
  else
    {
      nsp_calpack_xerhlt (messg, messg_len);
    }
  return 0;
}				/* xermsg_ */
