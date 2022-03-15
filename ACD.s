#include <xc.inc>

global  ADC_Setup, ADC_Read, Mult_16_16, ARG1L, ARG2L, ARG1H, ARG2H, RES0, RES1, RES2, RES3, ARG1M, Mult_8_24, convert_voltage, measure_loop, convert_voltage_0A, convert
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Write_Hex_orig, LCD_delay, LCD_clear, LCD_shift_cursor, LCD_delay_x4us ; external LCD subroutines
psect	udata_acs   ; named variables in access ram
ARG1L:	ds 1	; reserve 1 byte
ARG2L:	ds 1
ARG1H:	ds 1
ARG2H:	ds 1
RES0:	ds 1
RES1:	ds 1
RES2:	ds 1
RES3:	ds 1
ARG1M:	ds 1
    
psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference``\
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return
	
Mult_16_16:		    ; 16x16 bit unsigned multiply routine p.g. 134
	movf    ARG1L, W 
	mulwf   ARG2L	    ;ARG1L * ARG2L->
			    ; PRODH:PRODL
	movff	PRODH, RES1
	movff	PRODL, RES0
	
	movf	ARG1H, W
	mulwf	ARG2H	    ;ARG1H * ARG2H->
			    ; PRODH:PRODL
	movff	PRODH, RES3
	movff	PRODL, RES2
	
	movf	ARG1L, W
	mulwf	ARG2H	    ;ARG1L * ARG2H->
			    ; PRODH:PRODL
	movf	PRODL, W
	addwf	RES1, F	    ; Add cross
	movf	PRODH, W    ; products
	addwfc	RES2, F
	clrf	WREG
	addwfc	RES3, F
	
	movf	ARG1H, W
	mulwf	ARG2L	    ;ARG1H * ARG2L->
			    ; PRODH:PRODL
	movf	PRODL, W
	addwf	RES1, F	    ; Add cross
	movf	PRODH, W    ; products
	addwfc	RES2, F
	clrf	WREG
	addwfc	RES3, F
	
	return
	
Mult_8_24:		    ;8x24 bit unsigned multiply routine
	movf	ARG1L, W    ; ARG1L will be RES0 from previous calc
	mullw	0x0A	    ; Multiply literal with working registry
	
	movff	PRODH, RES1
	movff	PRODL, RES0
	
	movf	ARG1M, W
	mullw	0x0A
	
	movf	PRODL, W
	addwf	RES1, F	    ; Add cross products
	movff	PRODH, RES2
	
	movf	ARG1H, W
	mullw	0x0A
	
	movf	PRODL, W
	addwfc	RES2, F	    ; Add cross products
	movf	PRODH, W
	addwfc	RES3, F	    ; Add cross products
	
	return
	
convert_voltage:
	movff	ADRESH, ARG1H, A	; The measured value is ARG1. Separate it into its higher part
	movff	ADRESL, ARG1L, A	; and lower part
	movlw	0x41			; ARG2 is the 'k' value i.e. 0x418A
	movwf	ARG2H, A		; separate it into its higher part
	movlw	0x8A
	movwf	ARG2L, A		; and lower part
	call	Mult_16_16		; the variables are now ready to be used by the multiplying routine
	
	return
	
convert_voltage_0A:			; The result from convert_voltage, RES2:RES0, will be ARG1 which is 24 bits
	movff	RES0, ARG1L, A		; Lower 8 bits are RES0
	movff	RES1, ARG1M, A		; Middle 8 bits are RES1
	movff	RES2, ARG1H, A		; Higher 8 bits are RES2
	clrf	RES0, A			; Clearing the RES registers as they will store values
	clrf	RES1, A			; from the next calculation
	clrf	RES2, A
	clrf	RES3, A
	call	Mult_8_24
	
	return
	
convert: ;This routine just gathers together the convert voltage routines and does each step of the algorithm
	call	convert_voltage		;Step 1
	movf	RES3, W, A
	call	LCD_Write_Hex
	;movf	RES2, W, A
	;call	LCD_Write_Hex
	;movf	RES1, W, A
	;call	LCD_Write_Hex
	;movf	RES0, W, A
	;call	LCD_Write_Hex
	
	call	convert_voltage_0A	;Step 2
	movf	RES3, W, A
	call	LCD_Write_Hex
	
	call	convert_voltage_0A	;Step 3
	movf	RES3, W, A
	call	LCD_Write_Hex
	
	call	convert_voltage_0A	;Step 4
	movf	RES3, W, A
	call	LCD_Write_Hex
	
	return
	
measure_loop:
	
	call	ADC_Read
	movf	ADRESH, W, A
	
	call	LCD_Write_Hex_orig
	movf	ADRESL, W, A
	call	LCD_Write_Hex_orig
	
	;call	LCD_delay	
	call	LCD_shift_cursor    ;shift cursor to second line for the output voltage
	;call	LCD_delay
	
	call	convert
	
	call	LCD_delay
	call	LCD_delay
	call	LCD_delay
	call	LCD_delay
	call	LCD_clear
	goto	measure_loop		; goto current line in code
	
end


