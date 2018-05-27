/*
-------------------------------------------------------
SHA-1.s
Secured Hash Algorithm ARM implementation
-------------------------------------------------------
Author:  Jikyung Colin kim
Email:   Colinjkim1997@gmail.com
Date:    2018-05-24  
-------------------------------------------------------
*/

.equ SWI_Exit, 0x11     @ Terminate program code
.equ SWI_Open, 0x66     @ Open a file
                        @ inputs - R0: address of file name, R1: mode (0: input, 1: write, 2: append)
                        @ outputs - R0: file handle, -1 if open fails
.equ SWI_Close, 0x68    @ Close a file
                        @ inputs - R0: file handle
.equ SWI_RdInt, 0x6c    @ Read integer from a file
                        @ inputs - R0: file handle
                        @ outputs - R0: integer
.equ SWI_PrInt, 0x6b    @ Write integer to a file
                        @ inputs - R0: file handle, R1: integer
.equ SWI_RdStr, 0x6a    @ Read string from a file
                        @ inputs - R0: file handle, R1: buffer address, R2: buffer size
                        @ outputs - R0: number of bytes stored
.equ SWI_PrStr, 0x69    @ Write string to a file
                        @ inputs- R0: file handle, R1: address of string
.equ SWI_PrChr, 0x00    @ Write a character to stdout
                        @ inputs - R0: character

.equ inputMode, 0     @ Set file mode to input
.equ outputMode, 1    @ Set file mode to output
.equ appendMode, 2    @ Set file mode to append
.equ stdout, 1        @ Set output target to be Stdout
.equ padlen, 512	  @ Set length of the padded message
.equ kzero,	448		@number used for calculating zeros for padding

@-------------------------------------------------------
@ Main Program
	LDR R1, =message	@load address of message to R1
	LDR R2, =_message	@load end of message address
	BL	strlen			@branch to string length
	MOV R4, R0			@move length to R4 for later use
	LDR R2, =paddedMessage	@load space preserved for padded message
	LDR R1, [R1]			@load value in memory location in R1(message) to R1
	STR R1, [R2]			@store values in message to space for paddedmessage
	ADD R2, R2, R0			@move up memory location by length of the string
	MOV R3, #0x80			@move bit 1 to end of the original string in padded message 
	STRB R3, [R2]		
	STMFD SP!, {R0}
	BL PreProcessing
	
	
	
	
	
	SWI	SWI_Exit
	
@-------------------------------------------------------
strlen:
    /*
    -------------------------------------------------------
    Determines the length of a string.
    -------------------------------------------------------
    Uses:
    R0 - returned length
    R1 - address of string
    R2 - current character
    -------------------------------------------------------
    */
    STMFD   SP!, {R1-R2, LR}
    MOV     R0, #0          @ Initialize length    
	SUB		R0, R2, R1
	SUB		R0, R0, #1
    
    LDMFD   SP!, {R1-R2, PC}

@-------------------------------------------------------
PreProcessing:
    /*
    -------------------------------------------------------
    Determines number of zero padding required.
    -------------------------------------------------------
    Uses:
	R0 - memory location where zero padding ends 
    R1 - length of the string
    R2 - 8bits for 1 determine where string ended
    -------------------------------------------------------
    */
	STMFD	SP!, {FP,LR}
	MOV		FP, SP
	STMFD	SP!, {R1-R3}	@ preserve other registers 
	
	LDR	R0, =_paddedMessage
	SUB R0, R0, #1
	LDR R1, [FP,#8]
	MOV R1, R1, LSL #3
	CMP R1, #0x100
	BGE three
	BLT	two
	
three:
	SUB	R0,R0,#1
	B _PreProcessing
two:
	STRB R1, [R0]
	B _PreProcessing
	
_PreProcessing:
    LDMFD	SP!, {R1-R3}
	LDMFD	SP!, {FP,PC}

@-------------------------------------------------------

.data

message: .asciz "abc"
_message:
paddedMessage: .space 64
_paddedMessage:
Kconstant: .word 0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6

