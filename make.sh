arm-none-eabi-gcc -mcpu=arm926ej-s -c -marm -o irq_timer.o irq_timer.c 
#arm-none-eabi-gcc -mcpu=arm926ej-s -c -marm -o swi.o swi.c 
arm-none-eabi-gcc -mcpu=arm926ej-s -c -o vectors.o vectors.S 
arm-none-eabi-gcc -T link.ld -nostdlib -Xlinker --build-id=none  vectors.o irq_timer.o -o obj
arm-none-eabi-objcopy -O binary obj obj.bin
