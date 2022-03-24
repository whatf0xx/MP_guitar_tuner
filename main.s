#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message, output_var, hex_to_ascii, hex_to_ascii_H, hex_to_ascii_L  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Hex_orig, LCD_Send_Byte_D, LCD_space, LCD_delay, LCD_clear, LCD_delay_ms, LCD_shift_cursor, LCD_delay_x4us, measure_loop ; external LCD subroutines
extrn	ADC_Setup, ADC_Read, Mult_16_16, Mult_8_24, convert_voltage, convert_voltage_0A, convert		   ; external ADC subroutines
extrn	ARG1L, ARG2L, ARG1H, ARG2H, RES0, RES1, RES2, RES3, ARG1M ;global variables from ADC
extrn	timer_flag, time_counter, low_byte_thrsh, high_byte_thrsh
extrn	timing_setup, is_low, is_high
extrn	num1L, num1H, num2L, resL, resH, add_div, sub_div
	
psect	udata_acs   ; reserve data space in access ram
	
	raw_store	EQU 0x100
	counter:	ds 1
	div_add_low:	ds 1
	div_add_high:	ds 1
	div_co:		ds 1
	ns_high:	ds 1
	ns_low:		ds 1
	delta:		ds 1
	
	output_start	EQU 0x400
    
psect	code, abs
	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	call	UART_Setup

	movlw	0
	movwf	div_add_low, A	;start variable from 0 each run
	movwf	div_add_high, A
	movwf	div_co, A
	
	movlw	0x76		; setting up the sampling rate
	movwf	ns_high, A
	movlw	0x5F
	movwf	ns_low, A
	
	goto	start
	
	; ******* Main programme ****************************************
start:
	lfsr	0, raw_store	    ;store bits of raw data
    
meas_loop:
	
	call	ADC_Read
	movff	ADRESL, POSTINC0, A	;low bit to RAM, increment FSR0
	movff	ADRESH, POSTINC0, A	;high bit to RAM, increment FSR0
	
	decfsz	counter
	bra	meas_loop
	
	call	timing_setup
	
	call	is_low			;get to a good point to start timing
	call	is_high			;start with the signal high
	
	movlw	1
	movwf	timer_flag, A		;start timing
	
	call	is_low			;timer increments on each loop
	call	is_high			;finish when the timer goes high again
	
Div_loop:
  
    
	; Setting up the variables to be used by div_add
	movff	div_add_high, num1H, A
	movff	div_add_low, num1L, A
	movff	time_counter, num2L, A
	; add
	call	add_div
	movff	resH, div_add_high, A	;relabel so that they can
	movff	resL, div_add_low, A	; be used by the loop again
	
	incf	div_co, A		;increment div_counter (m)

	; need to do comparison - is div_add greater than ns?
div_low:
	movf	div_add_high, W, A	;high byte to W
	cpfslt	ns_high, A		;is W > f?
	call	div_check_eq1		;NO, check equality
	clrf	num1L, A		;YES, find delta...
	clrf	num2L, A		;...but first clear these variables
	movff	div_add_low, num1L, A	;YES, find delta
	movff	ns_low, num2L, A
	call	sub_div
	movff	resL, delta, A
	goto	output
	
	
	
div_check_eq1:
	cpfsgt	ns_high, A		;is W < f?
	bra	div_check_low1		;it's equal - check the low byte
	return				;it's lower - leave the loop
	
div_check_low1:
	movf	div_add_low, W, A	;low byte to W
	cpfslt	ns_low, A		;is W > f?
	bra	Div_loop		;NO, add again
	return				;YES, finish loop

output:
	
	;put our variables to FSR2
	;NB they need to be ascii vals!
	lfsr	2, output_start
	
;	movff	time_counter, output_var, A
;	call	hex_to_ascii
	
;	movlw	0xF0			    ; select high nibble
;	andwf	time_counter, W, A	    ; high nibble of variable stored in W
;	addlw	0x30			    ; add 0x30 to convert to ascii and store in W
;	movwf	POSTINC2, A		    ; move to FSR2 to be transmitted via UART
;	movlw	0x0F			    ; select low nibble
;	andwf	time_counter, W, A	    ; low nibble of variable stored in W
;	addlw	0x30			    ; add 0x30 to convert to ascii and store in W
;	movwf	POSTINC2, A		    ; move to FSR2 to be transmitted via UART
	
	movf	time_counter, W, A
	call	hex_to_ascii_H
	movwf	POSTINC2, A
	movf	time_counter, W, A
	call	hex_to_ascii_L
	movwf	POSTINC2, A
	
	
	movlw	0x20			    ; ascii for space
	movwf	POSTINC2, A
	
	movf	div_co, W, A
	call	hex_to_ascii_H
	movwf	POSTINC2, A
	movf	div_co, W, A
	call	hex_to_ascii_L
	movwf	POSTINC2, A
	
	movlw	0x20			    ; ascii for space
	movwf	POSTINC2, A
	
	movf	delta, W, A
	call	hex_to_ascii_H
	movwf	POSTINC2, A
	movf	delta, W, A
	call	hex_to_ascii_L
	movwf	POSTINC2, A
	
	
	movlw	10			    ; ascii for carriage return
	movwf	POSTINC2, A
	
	movlw	13			    ; ascii for carriage return
	movwf	POSTINC2, A
	
;	movlw	0x30
;	addwf	time_counter, F, A
;	movff	time_counter, POSTINC2, A
;	movlw	0x20
;	movwf	POSTINC2, A
;	movlw	0x30
;	addwf	div_co, F, A
;	movff	div_co, POSTINC2, A
;	movlw	0x20
;	movwf	POSTINC2, A
;	movlw	0x30
;	addwf	delta, F, A
;	movff	delta, POSTINC2, A
;	movlw	0x0D
;	movwf	POSTINC2, A
	
	lfsr	2, output_start
	
	;use UART functions to send data to PC
	movlw	10
	call	UART_Transmit_Message
	
	goto $
	
	end	rst
