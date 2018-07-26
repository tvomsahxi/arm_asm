#include<stdint.h>

#define UART0		((volatile unsigned int*)0x101f1000)
#define UARTFR		0x06
#define UARTFR_TXFF	0x20


void uart_puts(char *s){
	while(*s){
		while(*(UART0 + UARTFR) & UARTFR_TXFF);
		*UART0 = *s;
		s++;
	}
}


void output_mode()
{
	char buf[3] = "00\n";
	uint32_t val = get_processor_mode();
	buf[0] += val/0x10;
	buf[1] += val%0x10;
	uart_puts("mode=0x");
	uart_puts(buf);
}

void c_swi_handler(unsigned char swi_no, uint32_t swi_no2){
	uart_puts("swi");
	output_mode();
}



void boot_main(void) {
	uint32_t i =0;
	for(;;){
		i++;
		if(i > 0xf000000){
			uart_puts("boot_main");
			output_mode();
			call_swi();
			i = 0;
		}
	}
}
