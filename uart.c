#define UART0_BASE 0x1c090000
volatile unsigned int * const UART0DR = (unsigned int *)UART0_BASE;

void print_uart0(const char *s) {
   while(*s != '\0') {
      *UART0DR = (unsigned int)(*s);
      s++;
   }
}

char* alph = "0123456789abcdef";
void print_hex(unsigned long x) {
   int i=0;
   char* tmp = "                 \n";
   for(int j=0; j<17; ++j)
      tmp[j] = ' ';
   while(x>0) {
      short n = x % 16;
      x = x - n;
      x /= 16;
      tmp[16 - i] = alph[n];
      i++;
   }
   print_uart0(tmp);
}


