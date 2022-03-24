#include <xc.inc>

;***Import external routines and variables***
extrn	UART_Setup, UART_Transmit_Message, hex_to_ascii_H, hex_to_ascii_L
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Hex_orig
extrn	LCD_space, LCD_clear, LCD_shift_cursor
extrn	LCD_delay, LCD_delay_ms, LCD_delay_x4us
extrn	ADC_Setup, ADC_Read
extrn	timer_flag, time_counter, low_byte_thrsh, high_byte_thrsh
extrn	timing_setup, is_low, is_high
	
;***Reserve space in access RAM for variables ad define names***
psect	udata_acs
	
	raw_store	EQU 0x100	;where to store sound data
	output_start	EQU 0x400	;where to store UART output
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
	lfsr	2, output_start		;UART sends from FSR2
	
	movf	time_counter, W, A
	call	hex_to_ascii_H		;find the ascii for high bit
	movwf	POSTINC2, A
	
	movf	time_counter, W, A	;find the ascii for low bit
	call	hex_to_ascii_L
	movwf	POSTINC2, A
	
	
	movlw	10			;ascii for new line
	movwf	POSTINC2, A
	
	movlw	13			;ascii for carriage return
	movwf	POSTINC2, A
	
	lfsr	2, output_start		;ready to send message
	
	;use UART functions to send data to PC
	movlw	4
	call	UART_Transmit_Message
	
	goto	start			;loop
	
	end	rst
