; Program Purpose:
;	To read 3 digits of user input as an 'X' value and
;	calculate the input as follows:
;	
;	y = (((3 * X)^2)/8 + 45) % 1,000
;
;	The output will be the last 3 digits of the final
;	value.


; Program Details:
;	Input into the program are 3 digits ranging
;	from 0 - 9, such that the available numbers
;	are 000 - 999 to be worked on.
;
;	Output are the last 3 digits of a result. Example,
;	if the resulting number is 6075 then the digits are
;	075.
;
;	To divide by 8, the program used a right-shifting
;	instruction as opposed to the div instruction. As
;	the resulting number may be to large to store in
;	a memory size of word.
;
;	The usage of Horner's Rule is applied for each
;	digit expansion to obtain the initial entry value.

; Program Status:
;	Tests:		Expected:	Result:
;	999		796		796
;	000		045		045
;	555		573		573
;
;	I chose these specific tests to assert that the low
;	end, upper end, and approx. middle, function accordingly
;	based on the limits of sizing and widening.

; Register Table:
;	d0 = The input/output register
;	d1 = Hundred's digit entered
;	d2 = Ten's digit entered
;	d3 = One's digit entered
;	d4 = sum of the entered digits
;	d5 = One's digit of result
;	d6 = Ten's digit of result
;	d7 = Hundred's digit of result

; Declared Constants:
; CLRBYTE = Clears all of the register except the LSB
; CLRWORD = CLears all of the register except the LSW
; LF = Line feed to move cursor to a new line
; CR = Carriage return which moves the cursor to the left most column
; CHARZERO = The low end of the ASCII for digits to obtain correct value
	
CLRBYTE		equ	$FF
CLRWORD		equ	$FFFF
LF		equ	$A
CR		equ	$D
CHARZERO	equ	'0'
	



start:	jsr	read_char	;READ FIRST CHARACTER (HUNDRED'S)
	and.l	#CLRBYTE,d0	;Clear excess values in d0
	move.b	d0,d3
	sub.b	#CHARZERO,d3	;Subtract lowest range char for binary value
	mulu.w	#10,d3		
	move.b	d3,d4		

	
	jsr	read_char	;READ SECOND CHARACTER (TEN'S)	
	and.l	#CLRBYTE,d0
	move.b	d0,d2
	sub.b	#CHARZERO,d2
	add.b	d2,d4
	mulu.w	#10,d4		

	
	jsr	read_char	;READ THIRD CHRACTER (ONE'S)	
	and.l	#CLRBYTE,d0
	move.b	d0,d1		
	sub.b	#CHARZERO,d1		
	add.w	d1,d4		

	
	move.b	#CR,d0		;WRITE A NEW LINE FOR PRINTING
	jsr	write_char
	move.b	#LF,d0
	jsr	write_char
	

	mulu.w	#3,d4		;Equation y=(((3 * X)^2)/8 + 45) % 1,000
	mulu.w	d4,d4
	lsr.l	#3,d4
	add.l	#45,d4
	divu	#1000,d4
	swap	d4

	
	move.w	d4,d5		;Initialize one's storage
	move.w	d4,d6		;Initialize ten's storage
	move.w	d4,d7		;Initialize hundred's storage

	
	divu	#10,d5		;RETRIEVE THE ONE'S DIGIT
	swap	d5
	add.b	#CHARZERO,d5		

	
	divu	#10,d6		;RETRIEVE THE TEN'S DIGIT
	and.l	#CLRWORD,d6	;Clear MSW to clear remainder from longword
	divu	#10,d6
	swap	d6
	add.b	#CHARZERO,d6	;Convert value back to a char for printing
	
	
	divu	#10,d7		;RETRIEVE THE HUNDRED'S DIGIT
	and.l	#CLRWORD,d7
	divu	#10,d7		
	and.l	#CLRWORD,d7
	divu	#10,d7
	swap	d7
	add.b	#CHARZERO,d7		


	
	move.b	d7,d0				
	jsr	write_char	;Print hundred's digit
	move.b	d6,d0
	jsr	write_char	;Print ten's digit
	move.b	d5,d0
	jsr	write_char	;Print one's digit
	jsr	exit


;----- SUBROUTINE: read_char -----
;
; PURPOSE: waits for and reads a single keystroke from the keyboard.
;
; CALLER OUTPUT: returns the ASCII value of the key in the low byte
;                of D0.
;
; IMPORTANT: NOTE THAT THE HIGHER_ORDER BYTES OF D0 ARE UNDEFINED.
;            DON'T ASSUME THEY ARE ZEROED OUT!
;
; E.G. CALL:	jsr	read_char
;		... now use D0.b ...

read_char:	movem.l	d1-d2/a0-a2,-(sp)
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp	
		movem.l	(sp)+,d1-d2/a0-a2
		rts


;----- SUBROUTINE: write_char -----
;
; PURPOSE: writes a single character to the screen.
;
; CALLER INPUT: takes the ASCII value of the character in the low byte
;               of D0.
;
; E.G. CALL:	move.b	#'a',d0
;		jsr	write_char

write_char:	movem.l	d0-d2/a0-a2,-(sp)
		and.w	#$00FF,d0
		move.w	d0,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


;----- SUBROUTINE: exit -----
;
; PURPOSE: terminates the program.  This routine never returns.

exit:		clr.w	-(sp)
		trap	#1
