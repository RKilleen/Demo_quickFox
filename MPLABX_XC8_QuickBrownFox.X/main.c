/* The following is needed for the definition of CHAR_BIT */
#include <limits.h>

#include "C:\LDRA_Toolsuite\Compiler_spec\Microchip\xc8\ldra_port_pragmas.h"

#include "C:\LDRA_Toolsuite\Compiler_spec\Microchip\xc8\ldra_port.h"
#include "C:\LDRA_Toolsuite\Compiler_spec\Microchip\xc8\ldra_port_common.h"
#include "C:\LDRA_Toolsuite\Compiler_spec\Microchip\xc8\ldra_port.c"
#include "C:\LDRA_Toolsuite\Compiler_spec\Microchip\xc8\ldra_port_common.c"

static const char CPU[]="CPU = PIC16LF18856\n";

int main (void) {
  char msg[64];
  int count=0;

  ldra_port_open();
  ldra_port_write (CPU);
  (void)ldra_sprintf1 ( msg, "CHAR_BIT = %2d\n\n", CHAR_BIT );
  ldra_port_write (msg);

  ldra_port_write ( "<lang>vals.dat\n" );
  ldra_port_write ( "==============\n\n" );
  (void)ldra_sprintf1 ( msg, "127%5d      char - length in bytes.\n", sizeof(char) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "128%5d      short - length in bytes.\n", sizeof(short) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "129%5d      int - length in bytes.\n", sizeof(int) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "130%5d      long - length in bytes.\n", sizeof(long) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "131%5d      float - length in bytes.\n", sizeof(float) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "132%5d      double - length in bytes.\n", sizeof(double) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "133%5d      long double - length in bytes.\n", sizeof(long double) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "134%5d      pointer to any type - length in bytes.\n", sizeof(void*) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "197%5d      long long - length in bytes.\n", sizeof(long long) );
  ldra_port_write (msg);
  (void)ldra_sprintf1 ( msg, "382%5d      number of bits in a byte.\n\n", CHAR_BIT );
  ldra_port_write (msg);
  
  ldra_port_write ( "Quick Brown Fox Test\n" );
  ldra_port_write ( "====================\n\n" );
  while ( count < 25 ) {
    (void)ldra_sprintf1 ( msg, "%4d : ", count);
    ldra_port_write (msg);
    ldra_port_write ( "The quick brown fox jumps over the lazy dog\n" );
    count++;
  }
  ldra_port_close();
  return 0;
}
