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

; The following lines store strings (as array of characters) in memory
O: .string "OFF\n\r"
G: .string "GREEN\n\r"
R: .string "RED\n\r"
P: .string "PURPLE\n\r"
Y: .string "YELLOW\n\r"
B: .string "BLUE\n\r"
W: .string "WHITE\n\r"
CY: .string "CYAN\n\r"
.p2align 1,0

; Stores addresses (2 bytes) referencing first character in strings (character 
; arrays) stored in previous block
COLOR:
	.word O
	.word R
	.word G
	.word Y
	.word B
	.word P
	.word CY
	.word W

; Stores appropriate P2OUT bit paterns corresponding to indexes in the previous
; (COLOR) array 
COLOROUT:
	.byte 0b0
	.byte BIT1
	.byte BIT3
	.byte 0b00001010
	.byte BIT5
	.byte 0b00100010
	.byte 0b00101000
	.byte 0b00101010

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

		; initialize serial communication
		mov		#9600, r15
		call	#serial_init

		; execute once
		bis.b #BIT1|BIT3|BIT5, &P2DIR ;tells which bits will be used to ouput in P2
		bic.b #BIT3, &P1DIR ;tells which bit will be used to input in P1
		mov.b #0, &P1OUT ;makes sure nothing is being outputted in P1
		mov.b #0, &P2OUT ;makes sure nothing is being outputted in P2		

		bis.b #BIT3, &P1IE ;enables interrupt through Bit 3 of P1 (button)
		bis.b #BIT3, &P1IES ;tells to consider an interrupt when high-to-low
				    ;transition occurs at bit 3 of P1
		bic.b #BIT3, &P1IFG ;makes sure that our interrupt is not pending

		; enable maskable interrupts
		eint

; Jumps to GoThroughColors label repeatedly
.Lloop:
		; execute forever
		mov #0, r5
		jmp	GoThroughColors
		jmp		.Lloop

; Traverses through all the eight color states stored in COLOROUT array
GoThroughColors:
		mov #COLOROUT, r7
		add r5, r7
		mov.b @r7, &P2OUT
		mov #500, r15
		Call #delay_ms
		add #1, r5
		cmp #8, r5
		jeq .Lloop
		jmp GoThroughColors

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
; Prints the color that corresponds with sate of P2OUT at the time this
; interupt occurs
BUTTON_ISR:
		mov #COLOR, r6
		add r5, r6
		add r5, r6
		push @r6
		push #FORMAT
		Call #cio_printf
		pop r8
		pop r8

		;following copy (in stack and later from stack) was made because an 
		;interrupt can occur at a time when delay_ms function is under call 
		;by GoThroughColors function and so call to the same function from
		;here leads to overwriting of values in r15 and r14
		push r15
		push r14
		mov #500, r15
		Call #delay_ms
		pop r14
		pop r15
		bic.b #BIT3, &P1IFG	
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

