#include <xc.inc>

global time_counter, gone_high, low_byte_thrsh, high_byte_thrsh
global timing_setup, is_high, is_low
    
psect timing_vars, class=DATA
    
    ; These are for the timing-loop process
    
	raw_end	    EQU 0x2ff
	time_counter:	ds 1
	gone_high:	ds 1
	low_byte_thrsh:	ds 1
	high_byte_thrsh: ds 1
        
psect timing_code, class=CODE

timing_setup:
    
	movlw	0xE8			;low byte threshold
	movwf	low_byte_thrsh, A
	
	movlw	0x03			;high byte threshold
	movwf   high_byte_thrsh, A
	
	lfsr	0, raw_end		;start from the beginning again
	
is_low:	
	;takes FSR0 and decrements through register, stops when signal is low.
	
	movf	POSTDEC0, W, A		;put the final high byte to W
	CPFSLT	high_byte_thrsh, A	;skip if point > threshold
	
	bra	eq1			;point <= threshold
	
	decf	FSR0, A			;point is still high, start the loop
	bra	is_low			;again, increment memory
eq1:
	CPFSEQ	high_byte_thrsh, A	;skip if equal to
	bra	fancy_return1
	bra	check_low_byte_low

fancy_return1:	
	decf	FSR0, A
	return				;if not equal to must be lower, return
		
check_low_byte_low:
					
	movf	POSTDEC0, W, A		;high byte is low, is the low byte?
	CPFSLT	low_byte_thrsh, A	;skip if point > threshold
	return
	bra	is_low
	
is_high:
	;takes FSR0 and decrements through register, stops when signal is high.
	
	movf	POSTDEC0, W, A		;put the final high byte to W
	CPFSGT	high_byte_thrsh, A	;skip if point < threshold
	
	bra	eq2			;point >= threshold
	
	decf	FSR0, A			;point is still low, start loop again,
	bra	is_high			;increment memory
	
eq2:
	CPFSEQ	high_byte_thrsh, A	;skip if equal to
	bra	fancy_return2
	bra	check_low_byte_high

fancy_return2:	
	decf	FSR0, A
	return				;if not equal to must be higher, return
	
check_low_byte_high:
	movf	POSTDEC0, W, A		;high byte is low, is the low byte?
	CPFSGT	low_byte_thrsh, A	;skip if point < threshold
	return
	bra	is_high