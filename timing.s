#include <xc.inc>

global timer_flag, time_counter, low_byte_thrsh, high_byte_thrsh
global timing_setup, is_high, is_low
    
psect timing_vars, class=DATA
    
    ; These are for the timing-loop process
    
	raw_end	    EQU 0x2ff
	timer_flag:	    ds 1
	time_counter:	    ds 1
	low_byte_thrsh:	    ds 1
	high_byte_thrsh:    ds 1
        
psect timing_code, class=CODE

timing_setup:
    
	movlw	0xE8			;low byte threshold
	movwf	low_byte_thrsh, A
	
	movlw	0x03			;high byte threshold
	movwf   high_byte_thrsh, A
	
	movlw	0
	movwf	timer_flag, A
	movwf	time_counter, A
	
	lfsr	0, raw_end		;start from the end
	
	return
	
is_low:
	movf	POSTDEC0, W, A		;high byte to W
	cpfslt	high_byte_thrsh, A	;is W > f?
	bra	check_eq1		;NO, check equality
	decf	FSR0, A			;YES, look at next high byte
	tstfsz	timer_flag, A		;increment timer?
	incf	time_counter, A		;if timer_flag is high, count timestep
	bra	is_low			;loop
	
check_eq1:
	cpfsgt	high_byte_thrsh, A	;is W < f?
	bra	check_low1		;NO, it's equal - check the low byte
	decf	FSR0, A			;YES, it's lower - leave the loop
	return
	
check_low1:
	movf	POSTDEC0, W, A		;low byte to W
	cpfslt	low_byte_thrsh, A	;is W > f?
	return				;NO, finish loop
	tstfsz	timer_flag, A		;YES, increment timer?
	incf	time_counter, A		;if timer_flag is high, count timestep
	bra	is_low			;loop
	
is_high:
	movf	POSTDEC0, W, A		;high byte to W
	cpfsgt	high_byte_thrsh, A	;is W < f?
	bra	check_eq2		;NO, check equality
	decf	FSR0, A			;YES, look at next high byte
	tstfsz	timer_flag, A		;increment timer?
	incf	time_counter, A		;if timer_flag is high, count timestep
	bra	is_high			;loop
	
check_eq2:
	cpfslt	high_byte_thrsh, A	;is W < f?
	bra	check_low2		;it's equal - check the low byte
	decf	FSR0, A			;it's higher - leave the loop
	return
	
check_low2:
	movf	POSTDEC0, W, A		;low byte to W
	cpfsgt	low_byte_thrsh, A	;is W < f?
	return				;NO, finish loop
	tstfsz	timer_flag, A		;YES, increment timer?
	incf	time_counter, A		;if timer_flag is high, count timestep
	bra	is_high			;loop
	
end