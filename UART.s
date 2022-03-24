#include <xc.inc>
    
global  UART_Setup, UART_Transmit_Message, output_var, hex_to_ascii, hex_to_ascii_H, hex_to_ascii_L

psect	udata_acs   ; reserve data space in access ram
UART_counter: ds    1	    ; reserve 1 byte for variable UART_counter
output_var:   ds    1	    ; output variiable to be converted to ascii representation of hex number
hex_thresh:    ds    1	    ; 

psect	uart_code,class=CODE
UART_Setup:
    bsf	    SPEN	; enable
    bcf	    SYNC	; synchronous
    bcf	    BRGH	; slow speed
    bsf	    TXEN	; enable transmit
    bcf	    BRG16	; 8-bit generator only
    movlw   103		; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1, A	; set baud rate
    bsf	    TRISC, PORTC_TX1_POSN, A	; TX1 pin is output on RC6 pin
					; must set TRISC6 to 1
    
    movlw   0x0A
    movwf   hex_thresh, A
    
    return

UART_Transmit_Message:	    ; Message stored at FSR2, length stored in W
    movwf   UART_counter, A
UART_Loop_message:
    movf    POSTINC2, W, A
    call    UART_Transmit_Byte
    decfsz  UART_counter, A
    bra	    UART_Loop_message
    return

UART_Transmit_Byte:	    ; Transmits byte stored in W
    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte
    movwf   TXREG1, A
    return
    
hex_to_ascii:
    movlw	0xF0			    ; select high nibble
    andwf	output_var, W, A	    ; high nibble of output variable selected and stored in W
    cpfsgt	hex_thresh, A		    ; Is the nible W < 0x0A?
    call	hex_letter		    ; NO, W is >= 0x0A so it is a letter
    call	hex_number		    ; YES - it's a number
    movlw	0x0F			    ; select low nibble
    andwf	output_var, W, A	    ; low nibble of variable stored in W
    cpfsgt	hex_thresh, A		    ; Is the nible W < 0x0A?
    call	hex_letter		    ; NO, W is >= 0x0A so it is a letter
    call	hex_number		    ; YES - it's a number
    return
    
hex_number:
    addlw	0x30			    ; add 0x30 to convert to ascii and store in W
    movwf	POSTINC2, A		    ; move to FSR2 to be transmitted via UART
    return

hex_letter:
    addlw	0x37			    ; add 0x37 to convert to ascii and store in W
    movwf	POSTINC2, A		    ; move to FSR2 to be transmitted via UART
    return
    
hex_to_ascii_H:
    movwf	output_var, A	
    swapf	output_var, W, A	    ; high nibble first
    andlw	0x0F			    ; select high nibble and store in W
    movwf	output_var, A		    ; move high nibble to output_var
    movlw	0x0A			    ; determine if it is a hex number or hex letter
    cpfslt	output_var, A		    ; Is the nibble < 10?
    addlw	0x07			    ; NO, nibble is greater than 10 so it is a hex letter, so add 0x37(=0x0A + 0x07 + 0x26)
    addlw	0x26			    ; YES, nibble is a hex number, so add 0x30(=0x0A + 0x26)
    addwf	output_var, W, A	    ; move result to W
    return
    
hex_to_ascii_L:
    andlw	0x0F			    ; select low nibble and store in W
    movwf	output_var, A		    ; move high nibble to output_var
    movlw	0x0A			    ; determine if it is a hex number or hex letter
    cpfslt	output_var, A		    ; Is the nibble < 10?
    addlw	0x07			    ; NO, nibble is greater than 10 so it is a hex letter, so add 0x37(=0x0A + 0x07 + 0x26)
    addlw	0x26			    ; YES, nibble is a hex number, so add 0x30(=0x0A + 0x26)
    addwf	output_var, W, A	    ; move result to W
    return

end



