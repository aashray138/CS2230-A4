#include <msp430.h>

#define PC r0
#define SP r1
#define SR r2
#define CG r3

;------------------------------------------------------------------------------
; PROGRAM DATA (READ-ONLY)
		.section .rodata	; this should be placed in ROM
;------------------------------------------------------------------------------
FORMAT:	.string "> %s\n\r"

;------------------------------------------------------------------------------
; PROGRAM DATA (READ AND WRITE)
		.section .data		; this should be placed in RAM
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; PROGRAM INSTRUCTIONS
		.text				; this section is for instructions
		.global MAIN
;------------------------------------------------------------------------------
MAIN:
		; disable watchdog and run at 1Mhz
		mov		#WDTPW|WDTHOLD, &WDTCTL
		mov.b	&CALBC1_1MHZ,	&BCSCTL1
		mov.b	&CALDCO_1MHZ,	&DCOCTL

		; initialize stack pointer
		mov		#0x400, SP

		; execute once

		; enable maskable interrupts
		eint

.Lloop:
		; execute forever
		jmp		.Lloop

;------------------------------------------------------------------------------
; DELAY_MS FUNCTION
;------------------------------------------------------------------------------
delay_ms:
		mov		r15, r14
1:		mov		#245, r15
2:		dec		r15
		tst		r15
		jnz		2b
		dec		r14
		jnz		1b
		ret

;------------------------------------------------------------------------------
; UNEXPECTED INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
UNEXPECTED_ISR:
		reti

;------------------------------------------------------------------------------
; BUTTON INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
BUTTON_ISR:
		reti

;------------------------------------------------------------------------------
; INTERRUPT VECTORS
;------------------------------------------------------------------------------
		.section ".vectors", "ax", @progbits
		.word UNEXPECTED_ISR	;0xffe0
		.word UNEXPECTED_ISR	;0xffe2
		.word BUTTON_ISR		;0xffe4 (PORT1_VECTOR)
		.word UNEXPECTED_ISR	;0xffe6 (PORT2_VECTOR)
		.word UNEXPECTED_ISR	;0xffe8
		.word UNEXPECTED_ISR	;0xffea (ADC10_VECTOR)
		.word UNEXPECTED_ISR	;0xffec (USCIAB0TX_VECTOR)
		.word UNEXPECTED_ISR	;0xffee (USCIAB0RX_VECTOR)
		.word UNEXPECTED_ISR	;0xfff0 (TIMER0_A1_VECTOR)
		.word UNEXPECTED_ISR	;0xfff2 (TIMER0_A0_VECTOR)
		.word UNEXPECTED_ISR	;0xfff4 (WDT_VECTOR)
		.word UNEXPECTED_ISR	;0xfff6 (COMPARATORA_VECTOR)
		.word UNEXPECTED_ISR	;0xfff8 (TIMER1_A1_VECTOR)
		.word UNEXPECTED_ISR	;0xfffa (TIMER1_A0_VECTOR)
		.word UNEXPECTED_ISR	;0xfffc (NMI_VECTOR)
		.word MAIN				;0xfffe (RESET_VECTOR)
		.end

