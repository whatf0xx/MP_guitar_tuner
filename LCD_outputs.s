#include <xc.inc>
    
extrn	LCD_Write_Message

global	output_sharp, output_flat, output_on, Flash_setup
    
psect	out_data, class=DATA
    
    out_count:	ds 1
    
psect	udata_bank6
    f_msg:	ds 16
    s_msg:	ds 16
    o_msg:	ds 16
    
Flat_word:
    db		'F','l','a','t'
    f_length	EQU 4
    align	2
    
Sharp_word:
    db		'S','h','a','r','p'
    s_length	EQU 5
    align	2
    
On_word:
    db		'O','n',' ','P','i','t','c','h'
    o_length	EQU 8
    align	2
    
Flash_setup:
    bcf		CFGS		; Point to Flash programme memory
    bsf		EEPGD		; access Flash programme memory
    return

;******************************************************************************
  
output_flat:
    lfsr	1, f_msg
    movlw	low highword(Flat_word)
    movwf	TBLPTRU, A
    movlw	high(Flat_word)
    movwf	TBLPTRH, A
    movlw	low(Flat_word)
    movwf	TBLPTRL, A
    movlw	f_length
    movwf	out_count, A
flat_loop:
    tblrd*+
    movff	TABLAT, POSTINC1
    decfsz	out_count, A
    bra		flat_loop
flat_write:    
    movlw	f_length
    lfsr	1, f_msg
    call	LCD_Write_Message
    return
    
;******************************************************************************
    
output_sharp:
    lfsr	1, s_msg
    movlw	low highword(Sharp_word)
    movwf	TBLPTRU, A
    movlw	high(Sharp_word)
    movwf	TBLPTRH, A
    movlw	low(Sharp_word)
    movwf	TBLPTRL, A
    movlw	s_length
    movwf	out_count, A
sharp_loop:
    tblrd*+
    movff	TABLAT, POSTINC1
    decfsz	out_count, A
    bra		sharp_loop
sharp_write:    
    movlw	s_length
    lfsr	1, s_msg
    call	LCD_Write_Message
    return
    
;******************************************************************************
    
output_on:
    lfsr	1, o_msg
    movlw	low highword(On_word)
    movwf	TBLPTRU, A
    movlw	high(On_word)
    movwf	TBLPTRH, A
    movlw	low(On_word)
    movwf	TBLPTRL, A
    movlw	o_length
    movwf	out_count, A
on_loop:
    tblrd*+
    movff	TABLAT, POSTINC1
    decfsz	out_count, A
    bra		on_loop
on_write:    
    movlw	o_length
    lfsr	1, o_msg
    call	LCD_Write_Message
    return