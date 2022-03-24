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
	run_counter:	ds 1
	run_low:	ds 1
	
	output_start	EQU 0x400
    
psect	code, abs
	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	call	UART_Setup

	movlw	5
	movwf	run_counter, A
	
	goto	start
	
	; ******* Main programme ****************************************
rset:
	movlw	0
	movwf	run_low, A

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
	
output:
	
	;put our variables to FSR2
	;NB they need to be ascii vals!
	lfsr	2, output_start
	
	movf	time_counter, W, A
	call	hex_to_ascii_H
	movwf	POSTINC2, A
	movf	time_counter, W, A
	call	hex_to_ascii_L
	movwf	POSTINC2, A
	
	
	movlw	10			    ; ascii for new line
	movwf	POSTINC2, A
	
	movlw	13			    ; ascii for carriage return
	movwf	POSTINC2, A
	
	lfsr	2, output_start
	
	;use UART functions to send data to PC
	movlw	4
	call	UART_Transmit_Message
	
;	decfsz	run_low
;	goto	start
;	
;	decfsz	run_counter
;	goto	rset
	
	goto	start
	
	end	rst
