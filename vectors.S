	.text
	.code 32

	.global vectors_start
	.global vectros_end


vectors_start:
	LDR	PC, reset_handler_addr
	LDR	PC, undef_handler_addr
	LDR	PC, swi_handler_addr
	LDR	PC, prefetch_abort_handler_addr
	LDR	PC, data_abort_handler_addr
	B	.
	LDR	PC, irq_handler_addr
	LDR	PC, fiq_handler_addr

reset_handler_addr:		.word reset_handler
undef_handler_addr:		.word halt
swi_handler_addr:		.word swi_handler
prefetch_abort_handler_addr:	.word halt
data_abort_handler_addr:	.word halt
irq_handler_addr:		.word irq_handler
fiq_handler_addr:		.word halt
vectors_end:

halt:	B	.



reset_handler:

	LDR	sp, =stack_top

	MOV	r0, #0x00
	LDR	r1, =vectors_start
	LDR	r3, =vectors_end
keep_loading:
	LDR	r2, [r1, #0x0]
	STR	r2, [r0, #0x0]
	ADD	r0, r0, #0x4
	ADD	r1, r1, #0x4
	CMP	r1, r3
	BNE	keep_loading

	
	MRS	r0,cpsr

	BIC	r1, r0, #0x1F
	ORR	r1, r1, #0x12
	MSR	cpsr, r1

	LDR	sp, =irq_stack_top
	
	MSR	cpsr, r0


	BIC	r1, r0, #0x1F
	ORR	r1, r1, #0x10
	MSR	cpsr, r1
	LDR	sp, =user_stack_top

	MRS	r0,cpsr
	BIC	r0,r0,#0x1F
	ORR	r0,r0,#0x13
	MSR	cpsr, r0

	BL	boot_main
	B	.


	.global swi_handler
swi_handler:
	STMFD 	sp!, {r0-r12,lr}
	LDR	r1,[lr, #-4]
	BIC	r1, r1, #0xff000000
	BL	c_swi_handler
	LDMFD	sp!, {r0-r12,pc}

	.global	get_processor_mode
get_processor_mode:
	MRS	r0, cpsr
	BIC	r0, r0, #0xffffffe0
	BX	lr

	.global call_swi
call_swi:
	PUSH	{r0-r12,lr}
	SWI	0x120001
	POP	{r0-r12,lr}
	BX	lr
	.global irq_handler
irq_handler:
	PUSH	{r0-r12,lr}
	BL	c_irq_handler
	POP	{r0-r12,lr}
	SUBS	pc,lr,#4

	.global enable_irq
enable_irq:
	MRS	r0,cpsr
	BIC	r0,r0,#0x80
	MSR	cpsr_c,r0
	BX	lr
	.end

