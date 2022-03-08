	#include <xc.inc>

psect	code, abs
	
main:
	org 0x0
	start EQU 0x1		;start the array at this position in the RAM
	length EQU 0x0		;array length here
	movlw 0xa
	movwf length, A
	lfsr 0, start		;set FSR0 to the origin
loop:
	movff FSR0, POSTINC0	;set the element value, increment
	decfsz length, A	;decrease the counter, if good continue
	goto loop
	
	movlw 0xa
	movwf length, A
	lfsr 1, start		;set FSR1 to the origin
	
loop2:	
	movf INDF1, W, A	;take the current value of the array to W
	cpfseq POSTINC1, A	;Skip if value matches position
	goto failure
	decfsz length, A	;decrease the counter, if good continue
	goto loop2
	goto success
	
failure:
	movlw 0x00
	movwf TRISJ, A
	movlw 0xff
	movwf PORTJ, A		;FAILURE LIGHTS UP PORT J
	goto finish
	
success:
	movlw 0x00
	movwf TRISH, A
	movlw 0xff
	movwf PORTH, A		;SUCCESS LIGHTS UP PORT H
	
finish:
	end