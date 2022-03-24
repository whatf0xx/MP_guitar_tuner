#include <xc.inc>
    
    global	num1L, num1H, num2L, num2H, resL, resH, add_div, sub_div
    
    psect	udata_acs   ; named variables in access ram
    num1L:	ds 1	; Lower byte of div_add
    num1H:	ds 1	; Higher byte of div_add
    num2L:	ds 1	; timer_count
    num2H:	ds 1
    resL:	ds 1	; Lower byte of addition result
    resH:	ds 1	; Higher byte of addition result
    
    
    
    psect	div_calcs_code, class=CODE
    
    add_div:
    
	movff	num2L, resL	
    
	movf	num1L, W
	addwf	resL, F		; num1L + num2
	
	movf	num1H, W	; store the higher byte in resH
	addwfc	resH, F		; add the carry bit from previous calc to num1H and store in higher byte of result.
	
	
	;or...
	;movff	num1H, resH	;
	;clrf	WREG		; clear the working registry from previous calc
	;addwfc	resH		; so that only the carry bit is added to num1H and stored in higher byte of result
	
	return
	
    sub_div:
	
	movf	num2L, W	; move low byte of num2 to working reg
	subwfb	num1L, W, A	; do num1L - num2L (with borrow) and store in resL
	movwf	resL, A
	
	BTFSC	STATUS, 0x07	;is the carry bit 0?
	bra	sub_step2	;no
	return			; YES, return and result is stored in resL
    
    sub_step2:
    
	movlw	0x00
	;subfwb	resL, W, A	; 0-resL (W-f), store in W
	;movwf	resL, A		; move result from W to resL
	subfwb	resL, F, A	; 0-resL (W-f), store in F
	return
;add_div_test:
	
	;	;******Testing to see if add_div works with test values*******
;	movlw	0x12	    ; setting up the variables
;	movwf	num1H, A
;	movlw	0xFF
;	movwf	num1L, A
;	movlw	0x46
;	movwf	num2L, A
;	call	add_div	    ; do the addition
;	
;	call	LCD_shift_cursor    ;preparing to write to LCD on next line
;	movf	resH, W, A	    
;	call	LCD_Write_Hex_orig  ;write higher byte to LCD
;	movf	resL, W, A
;	call	LCD_Write_Hex_orig  ; followed by lower byte
;	; *******The add_div works!!!!! ********
	

end