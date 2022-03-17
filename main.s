#include <xc.inc>

;extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Hex_orig, LCD_delay, LCD_clear, LCD_delay_ms, LCD_shift_cursor, LCD_delay_x4us, measure_loop ; external LCD subroutines
extrn	ADC_Setup, ADC_Read, Mult_16_16, Mult_8_24, convert_voltage, convert_voltage_0A, convert		   ; external ADC subroutines
extrn	ARG1L, ARG2L, ARG1H, ARG2H, RES0, RES1, RES2, RES3, ARG1M ;global variables from ADC
extrn time_counter, gone_high, low_byte_thrsh, high_byte_thrsh
extrn timing_setup, is_low, is_high
	
psect	udata_acs   ; reserve data space in access ram
	
	raw_store    EQU 0x100
	counter:    ds 1
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	goto	start
	
	; ******* Main programme ****************************************
start:
	lfsr	0, raw_store	    ;store bits of raw data
    
loop:
	
	movlw	5
	call	LCD_delay_x4us
	
	call	ADC_Read
	movff	ADRESL, POSTINC0, A	;low bit to RAM, increment FSR0
	movff	ADRESH, POSTINC0, A	;high bit to RAM, increment FSR0
	
	decfsz	counter
	bra loop
	
	call timing_setup
	
	call is_low
	call is_high
	
	movlw 0x07
	movwf POSTDEC0, A
	
	movlw 0xD0
	movwf POSTDEC0, A
	
	goto $
	
	end	rst
