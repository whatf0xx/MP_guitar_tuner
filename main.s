#include <xc.inc>

;***Import external routines and variables***
extrn	UART_Setup, UART_output, hex_to_ascii_H, hex_to_ascii_L
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Hex_orig
extrn	LCD_space, LCD_clear, LCD_shift_cursor
extrn	LCD_delay, LCD_delay_ms, LCD_delay_x4us
extrn	ADC_Setup, ADC_Read
extrn	timer_flag, time_counter, low_byte_thrsh, high_byte_thrsh
extrn	timing_setup, is_low, is_high
	
;***Reserve space in access RAM for variables ad define names***
psect	udata_acs
	
	raw_store	EQU 0x100	;where to store sound data
	counter:	ds 1		;for data acquisition loop
	run_counter:	ds 1
	run_low:	ds 1
	
;***Reserve space for and write code***
psect	code, abs
	
rst: 	org 0x0
 	goto	setup

setup:	
	call	LCD_Setup	
	call	ADC_Setup	
	call	UART_Setup

	movlw	5
	movwf	run_counter, A
	
	goto	start

start:
	lfsr	0, raw_store		;store bits of raw data
    

meas_loop:
	call	ADC_Read		;voltage at RA0 to digital signal
	movff	ADRESL, POSTINC0, A	;low bit to RAM, increment FSR0
	movff	ADRESH, POSTINC0, A	;high bit to RAM, increment FSR0
	
	decfsz	counter, A	;iterate over allocated memory
	bra	meas_loop

timing:
	call	timing_setup		;reset variables, set FSR0
	
	call	is_low			;get to a good point to start timing
	call	is_high			;start with the signal high
	
	movlw	1
	movwf	timer_flag, A		;start timing
	
	call	is_low			;timer increments on each loop
	call	is_high			;finish when the timer goes high again
	
output:
	movf	time_counter, W, A
	call	UART_output
	
	goto	start			;loop
	
	end	rst
