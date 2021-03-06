#include <xc.inc>

;***Import external routines and variables***
extrn	UART_Setup, UART_output, hex_to_ascii_H, hex_to_ascii_L
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Hex_orig
extrn	LCD_space, LCD_clear, LCD_shift_cursor
extrn	LCD_delay, LCD_delay_ms, LCD_delay_x4us
extrn	ADC_Setup, ADC_Read
extrn	timer_flag, time_counter, low_byte_thrsh, high_byte_thrsh
extrn	timing_setup, is_low, is_high
extrn	output_sharp, output_flat, output_on, Flash_setup
	
;***Reserve space in access RAM for variables ad define names***
psect	udata_acs
	
	raw_store	EQU 0x100	;where to store sound data
	counter:	ds 1		;for data acquisition loop
	accept:		ds 1		;is the measurement sensical?
	a4:		ds 1		;measured pitch of a4
    
	sharp_bin:	ds 1		;these bins store the state of 
	flat_bin:	ds 1		;a measurement relative to the 
	on_bin:		ds 1		;known pitch of a4
    
	a_count:	ds 1		;counter for the analysis loop
	diff_thrsh:	ds 1		;threshold before assume on pitch
	
;***Reserve space for and write code***
psect	code, abs
	
rst: 	org 0x0
 	goto	setup

setup:	
	call	LCD_Setup	
	call	ADC_Setup	
	call	UART_Setup
	call	Flash_setup
	
	movlw	70			;measured value for a4
	movwf	a4, A
	
	movlw	0x30
	movwf	accept, A		;minimum value to accept as result
	
	movlw	10
	movwf	diff_thrsh, A		;if bins within 10, assume equal

bin_reset:
	movlw	0
	movwf	sharp_bin, A		;start with all the bins = 0
	movwf	flat_bin, A
	movwf	on_bin, A
	
	movlw	60			;number of measurements for decision
	movwf	a_count, A

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
	
analysis:
	movf	time_counter, W, A
	cpfslt	accept, A		;is the measurement acceptable? i.e. is time_counter > threshold f
	goto	start			;NO, start again
	
pitching:
	;Take 10 measurements, for each,
	;bin into SHARP, FLAT or 
	;ON-PITCH. Output largest
	
	cpfslt	a4, A			;is time counter above a4?
	bra	is_eq			;NO, check equality
	incf	flat_bin, A		;YES, increment flat_bin
	bra	done
	
is_eq:
	cpfseq	a4, A			;is time counter = a4?
	bra	less			;NO, it's less than
	incf	on_bin, A		;YES, increment on_bin
	bra	done
	
less:
	incf	sharp_bin, A		;YES, increment sharp_bin
	bra	done
	
done:
	decfsz	a_count, A		;Have you checked enough measurements?
	goto	start			;NO, go to start
	bra	output			;YES, go to output

output:
	movf	time_counter, W, A	;output time_counter to UART
	call	UART_output
	
	call	LCD_clear
	
	movf	on_bin, W, A
	cpfslt	sharp_bin, A		;More ons than sharps?
	bra	is_sharp		;NO, is it sharp?
	cpfslt	flat_bin, A		;YES, more ons than flats?
	bra	flat			;NO, must be flat or about the same
	bra	on_pitch		;YES, run code to display ON-PITCH
	
is_sharp:
	movf	sharp_bin, W, A
	cpfslt	flat_bin, A	    	;More sharp than flats?
	bra	flat			;NO, it might be flat or about on
	movf	flat_bin, W, A		;YES, flats are smaller
	subwf	sharp_bin, W, A		;do sharps - flats
	cpfslt	diff_thrsh		;is diff > thrsh?
	bra	on_pitch		;NO, they're about the same
	bra	sharp			;YES, its must be sharp
	
is_flat:
	movf	sharp_bin, W, A		;YES, sharps are smaller
	subwf	flat_bin, W, A		;do flats - sharps
	cpfslt	diff_thrsh		;is diff > thrsh?
	bra	on_pitch		;NO, they're about the same
	bra	flat			;YES, it must be flat
	
on_pitch:
	call	output_on
	goto	bin_reset
	
flat:
	call	output_flat
	goto	bin_reset
	
sharp:
	call	output_sharp
	goto	bin_reset
	
	
	end	rst