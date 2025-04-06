/* vim: set et ts=4 sw=4: */

/*
  --  -- -- ----- ---- ----  -- -- --
 / / / / / / /o )/ \/ \| o )/  \|| //
 \ \/ / / / /  (/ ^  ^ \  (  o /||//
 / /  --\  / /\ \/ \/ \/ o )  / / /
 ----------------  -- --------  --


rom.c: Test program

License: MIT License

Copyright 2023 J.R.Sharp

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#define UART_REG 0x20000000

#include <stdarg.h>

void my_putc(char c)
{
    char* uart = (char*)UART_REG;
    *uart = c;

    while (*uart == 0) ;
}

void print_hex_num(unsigned short n)
{
	static const char convertBuffer[] = "0123456789abcdef";

	short i = 0;

	while (i < 4) {
		unsigned short a = (n & 0xf000U) >> 12;
		my_putc(convertBuffer[a]);

		n <<= 4;
		i++;
	}
}

void my_printf(char* format, ...)
{
	va_list arg;
	char c;
	va_start(arg, format);


	while (c = *format++)
	{
		if (c == '%')
		{
			c = *format++;

			if (c == '%')
				my_putc('%');
			else if (c == 'x') {
				int a = va_arg(arg, unsigned int);
				print_hex_num(a);
			}
			else if (c == 'c')
				my_putc(va_arg(arg, char));
			else my_putc('?');
		}
		else
			my_putc(c);
	}

	va_end(arg);

}



int main()
{
	#define MAX_PRIME 20
	int array[MAX_PRIME];
	int i;
	int j;

	my_printf("Sieve of Eratosthenes\r\n");
	my_printf("=====================\r\n");

	for (i = 0; i < MAX_PRIME; i++)
		array[i] = 1;

	for (i = 2; i < MAX_PRIME / 2; i++)
	{
		if (array[i])
			for (j = i + i; j < MAX_PRIME; j += i)
				array[j] = 0;
	}

	for (i = 2; i < MAX_PRIME; i++)
		if (array[i])
			my_printf("%x is prime\r\n", i);

	my_printf("done!\r\n");

}

