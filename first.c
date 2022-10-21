/*
Most Documentation on this is vague as this was designed as a small learning
process. Therefore some code was provided pre-implementation of my own in main().

See FIRST.S for further details since both function the same.
*/


#define _DEFAULT_SOURCE 1  /* don't worry about this - simply needed for IO stuff */

#include <stdio.h>
#include <termios.h>
#include <stdlib.h>
#include <time.h>


#define CR 13
#define LF 10

#define bool int
#define true 1
#define false 0


/* 
Note: read_char is written to simulate the 68000 implementation, where
         the high 24 bits of d0 are left in an undefined state after the
	 call.
*/

void read_char();   /* output passed back in low 8 bits of d0 */
void write_char();  /* input passed in low 8 bits of d0 */

void cleanup();     /* don't worry about this */

                    /* don't worry about this */
struct termios orig;                    
                    /* simulate 68000 data registers */
int d0, d1, d2, d3, d4, d5, d6, d7;


/* ===== Made for output testing purposes only ===== */
void hexValue(int);
void newLine();
/* ================================================= */


int main()
{
    /* Read First Character (Digit) */
    read_char();
    d0 = d0 & 0x000000FF;
    d3 = d0;
    d3 = d3 - '0';
    d3 = d3 * 10;
    d4 = d3;
	
/* -------------------- */
    
    /* Read second Character (Digit) */
    read_char();
    d0 = d0 & 0x000000FF;
    d2 = d0;
    d2 = d2 - '0';
    d4 = d4 + d2;
    d4 = d4 * 10;
	
/* -------------------- */

    /* Read Third Character (Digit) */
    read_char();
    d0 = d0 &  0x000000FF;
    d1 = d0;
    d1 = d1 - '0';
    d4 = d4 + d1;
	
// /* -------------------- */

//     /* Constructing Equation y = ((3 * x)^2 / 8 + 45) % 10,000 */
//     d4 = d4 * 3;
//     d4 = d4 * d4;
//     d4 = d4 / 8;
//     d4 = d4 + 45;
//     d4 = d4 % 10000;
	
/* -------------------- */

/* Constructing Equation y = (4 * x^2 + (23 * x + 136) / 3) % 1000 */
    
    /* Evaluating two separate instances of x */
    d5 = d4;

    /* (4 * x^2) */
    d4 = d4 * d4;
    d4 = d4 * 4;

    /* (23 * x + 136) / 3 */
    d5 = d5 * 23;
    d5 = d5 + 136;
    d5 = d5 / 3;

    /* (4 * x^2 + (23 * x + 136) / 3) */ 
    d4 = d4 + d5;

    /* (4 * x^2 + (23 * x + 136) / 3) % 1000 */
    d4 = d4 % 1000;

/* -------------------- */

    /* Start a new line */
    d0 = CR;
    write_char();
    d0 = LF;
    write_char();
	
/* -------------------- */
    
    /* One's Digit */
    d5 = d4;
    d5 = d5 % 10;
    d5 = d5 + '0';
	
/* -------------------- */

    /* Ten's Digit */
    d6 = d4;
    d6 = d6 / 10;
    d6 = d6 % 10;
    d6 = d6 + '0';
	
/* -------------------- */

    /* Hundred's Digit */
    d7 = d4;
    d7 = d7 / 10;
    d7 = d7 / 10;
    d7 = d7 % 10;
    d7 = d7 + '0';
	
/* -------------------- */

    /* Print the result of the Equation */
    d0 = d7;
    write_char();
    d0 = d6;
    write_char();
    d0 = d5;
    write_char();
	
/* -------------------- */

    /* Start a new line */
    d0 = CR;
    write_char();
    d0 = LF;
    write_char();
    
    return 0;
}

/* -------------------- */

/* don't worry about how this works, just call it */
void read_char()
{
  static bool first_call = true;
  struct termios term;
  char ch;
  time_t now;

  if (first_call)
    {
      time(&now);
      srand((unsigned int)now);
      tcgetattr(0, &orig);
      term = orig;
      atexit(cleanup);
      cfmakeraw(&term);
      term.c_lflag |= ECHO;
      tcsetattr(0, 0, &term);
      first_call = false;
    }

  ch = (char) getchar();
  d0 = (int) ((rand() & 0x00FF0000) | (unsigned int)ch);

}


void write_char()
{
  putchar((int)d0);
}


/* don't worry about this */
void cleanup()
{
  tcsetattr(0, 0, &orig);
}



/* ===== Testing Functions only ===== */
void hexValue(int value)
{
  newLine();
  printf("0x%08X\n", value);
  newLine();
  return;
}

void newLine() {
  d0 = CR;
  write_char();
  d0 = LF;
  write_char();
  return;
}
/* ================================== */
