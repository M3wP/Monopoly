;===============================================================================
;M O N O P O L Y   L O A D E R
;-------------------------------------------------------------------------------
;
;VERSION 0.02.80 BETA
;
;
;FOR THE COMMODORE 64
;BY DANIEL ENGLAND FOR ECCLESTIAL SOLUTIONS
;
;(C) 2018 DANIEL ENGLAND
;ALL RIGHTS RESERVED
;
;
;MONOPOLY IS THE PROPERTY OF HASBRO INC.
;(C) 1935, 2016 HASBRO
;
;
;You probably need to own a copy of the official board game to even have this.
;*ugh*
;
;
;Please see readme.md and changelog.md for further information.
;
;
;-------------------------------------------------------------------------------
;BASIC bootstrap
;-------------------------------------------------------------------------------
	.code
	.org		$07FF			;start 2 before load address so
						;we can inject it into the binary
						
	.byte		$01, $08		;load address
	
	.word		_basNext, $000A		;BASIC next addr and this line #
	.byte		$9E			;SYS command
	.asciiz		"2061"			;2061 and line end
_basNext:
	.word		$0000			;BASIC prog terminator
	.assert	* = $080D, error, "BASIC interface incorrect!"

bootstrap:
		JMP	initialise
		
		RTS

krnlOutChr	= 	$E716
krnlLoad	=	$FFD5
krnlSetLFS	=	$FFBA
krnlSetNam	=	$FFBD
knrlClAll	=	$FFE7

CIA1_PRA        = 	$DC00        		
CIA1_DDRA	=	$DC02


LANGCOUNT	= 	$C000
LANGSTART	=	$C001
LANGFRSTD	= 	$C003


oldIRQ:
		.word 	$0000
		

strText0Load0:		;LOADING RESOURCES...
			.byte $0C, $0F, $01, $04, $09, $0E, $07
			.byte $20, $12, $05, $13, $0F, $15, $12, $03
			.byte $05, $13, $2E, $2E, $2E
strText1Load0:		;LOADING RULES...
			.byte $0C, $0F, $01, $04, $09, $0E, $07
			.byte $20, $12, $15, $0C, $05, $13, $2E, $2E
			.byte $2E
strText2Load0:		;LOADING PROGRAM... $12, 
			.byte $0C, $0F, $01, $04, $09, $0E, $07
			.byte $20, $10, $12, $0F, $07, $12, $01, $0D
			.byte $2E, $2E, $2E

LANGFILE:
		.byte 	"LANGS"
FILENAME:
		.byte	"STRINGSU"
FILENAME_2:
		.byte	"RULES"
FILENAME_3:
		.byte	"SCREEN"
FILENAME_4:
		.byte	"C64CLIENT"
FILENAME_5:


langSelected:
		.byte	$00
langFound:
		.byte	$00
langKeyPress:
		.byte	$00
		
maxRowPos:
		.word	$0450
	
JoySelected:
		.byte	$00
		
JoyUp:
		.byte	$00
JoyDown:
		.byte	$00
JoyLeft:
		.byte	$00
JoyRight:
		.byte	$00
JoyButton:
		.byte	$00
JoyAck:
		.byte	$00
JoyDly:
		.byte	$00
		
JOYSTICKDELAY	=	27


strText0Ref0:		;SELECT LANGUAGE:	$10
			.byte $13, $05, $0C, $05, $03, $14, $20
			.byte $0C, $01, $0E, $07, $15, $01, $07, $05
			.byte $3A


;-------------------------------------------------------------------------------
loaderIRQ:
;-------------------------------------------------------------------------------
		JSR	processJoystick
		
		JMP	(oldIRQ)
		


;-------------------------------------------------------------------------------
processJoystick:
;-------------------------------------------------------------------------------
;		tests joystick in port 2
;
;		bits on when pressed (EOR of CIA)
;
;		0	up
;		1	down
;		2	left
;		3	right
;		4	button

		LDA	JoyAck
		BEQ	@proc
	
		RTS
		
@proc:
		LDX     #$00
		
		STX	JoyUp
		STX	JoyDown
		STX	JoyLeft
		STX	JoyRight
		STX	JoyButton
		
		LDA	JoyDly
		BEQ	@test
		
		DEC	JoyDly
		RTS
		
@test:
		LDA	#JOYSTICKDELAY
		STA	JoyDly

		LDA     #$E0
		LDY     #$FF
		STA     CIA1_DDRA
		LDA     CIA1_PRA
		STY	CIA1_DDRA
		AND	#$1F
		EOR	#$1F
		
		LDX	#$01
		
		BIT	$2F
		BNE	@isUp
		
		BIT	$30
		BNE	@isDown
		
		BIT	$2D
		BNE	@isLeft
		
		BIT	$2E
		BNE	@isRight
		
		BIT	$31			
		BNE	@isButton		
						
		RTS
	
@isUp:
		STX	JoyUp
		STX	JoyAck
		
		RTS
		
@isDown:
		STX	JoyDown
		STX	JoyAck
		
		RTS
		
@isLeft:
		STX	JoyLeft
		STX	JoyAck
		
		RTS
		
@isRight:
		STX	JoyRight
		STX	JoyAck
		
		RTS
		
@isButton:
		STX	JoyButton
		STX	JoyAck
		
		RTS



;-------------------------------------------------------------------------------
initialise:
;-------------------------------------------------------------------------------
		LDA	#$01
		STA	$2F
		LDA	#$02
		STA	$30
		LDA	#$10
		STA 	$31
		LDA	#$04
		STA	$2D
		LDA	#$08
		STA	$2E

		LDA	#$8E			;go to uppercase characters
		JSR	krnlOutChr
		LDA	#$08			;disable change character case
		JSR	krnlOutChr
		LDA	#$93			;clear screen
		JSR	krnlOutChr

		LDA	#FILENAME - LANGFILE
		STA	$A3
		LDA	#<LANGFILE
		STA	$A4
		LDA	#>LANGFILE
		STA	$A5
		
		JSR	initLoadFile		

		LDA	#<1064
		STA	$FB
		LDA	#>1064
		STA	$FC
		
		LDA	#<strText0Ref0
		STA	$FD
		LDA	#>strText0Ref0
		STA	$FE
		
		LDY	#$0F
		
		JSR	initOutString
		JSR	initNewLine

		JSR	initDispLangs

		LDA	$0314
		STA	oldIRQ
		LDA	$0315
		STA	oldIRQ + 1
		
		SEI
		LDA	#<loaderIRQ
		STA	$0314
		LDA	#>loaderIRQ
		STA	$0315
		CLI
		
		JSR	initGetLang
		
		SEI
		LDA	oldIRQ
		STA	$0314
		LDA	oldIRQ + 1
		STA	$0315
		CLI
		
		JSR	initLoadDataFiles

		JSR	initLoadProgram

		RTS


;-------------------------------------------------------------------------------
initLoadProgram:
;-------------------------------------------------------------------------------
		LDA	#<strText2Load0
		STA	$FD
		LDA	#>strText2Load0
		STA	$FE
		
		LDY	#$11
		JSR	initOutString

		LDA	#FILENAME_5 - FILENAME_4
		STA	$A3
		LDA	#<FILENAME_4
		STA	$A4
		LDA	#>FILENAME_4
		STA	$A5
		
		LDA	#<lowMemData
		STA	$FB
		LDA	#>lowMemData
		STA	$FC
		
		LDA	#<$0334
		STA	$FD
		LDA	#>$0334
		STA	$FE
		
		LDY	#(lowMemPrgLdEnd - lowMemPrgLoader)
		DEY
		
@loop:
		LDA	($FB), Y
		STA	($FD), Y
		
		DEY
		BPL	@loop
		
		LDA	langSelected
		STA	$FB
		
		JMP	$0334


;-------------------------------------------------------------------------------
initLoadDataFiles:
;-------------------------------------------------------------------------------
		LDA	#$93			;clear screen
		JSR	krnlOutChr

		LDA	#<1064
		STA	$FB
		LDA	#>1064
		STA	$FC
		
		LDA	#<strText0Load0
		STA	$FD
		LDA	#>strText0Load0
		STA	$FE
		
		LDY	#$13
		JSR	initOutString
		JSR	initNewLine

		LDA	#FILENAME_2 - FILENAME
		STA	$A3
		LDA	#<FILENAME
		STA	$A4
		LDA	#>FILENAME
		STA	$A5
		
		JSR	initLoadFile

		LDA	#FILENAME_4 - FILENAME_3
		STA	$A3
		LDA	#<FILENAME_3
		STA	$A4
		LDA	#>FILENAME_3
		STA	$A5
		
		JSR	initLoadFile
		
		LDA	#<strText1Load0
		STA	$FD
		LDA	#>strText1Load0
		STA	$FE
		
		LDY	#$0F
		JSR	initOutString
		JSR	initNewLine

		LDA	#FILENAME_3 - FILENAME_2
		STA	$A3
		LDA	#<FILENAME_2
		STA	$A4
		LDA	#>FILENAME_2
		STA	$A5

		JSR	initLoadFile

		RTS
		

;-------------------------------------------------------------------------------
initTestKeys:
;-------------------------------------------------------------------------------
		STA	langKeyPress
		
		JSR 	initFirstLang
		
		LDX	LANGCOUNT
		DEX

		LDY	#$00

@loop:
		LDA	($FD), Y
		CMP	langKeyPress
		BEQ	@found
			
		JSR	initNextLang
			
		DEX
		BPL	@loop
		
		RTS
		
@found:
		LDY	#$01
		LDA	($FD), Y
		STA	langSelected
		STY	langFound
		
		RTS


;-------------------------------------------------------------------------------
initClearJoySel:
;-------------------------------------------------------------------------------
		LDA	#$20
		LDY	#$00
		STA	($FB), Y
		
		RTS


;-------------------------------------------------------------------------------
initSetJoySel:
;-------------------------------------------------------------------------------
		LDA	#$DA
		LDY	#$00
		STA	($FB), Y
		
		RTS


;-------------------------------------------------------------------------------
initJoyUp:
;-------------------------------------------------------------------------------
		JSR	initClearJoySel
		
		LDA	JoySelected
		BEQ	@wrap
		
		DEC	JoySelected
		
		SEC
		LDA	$FB
		SBC	#$28
		STA	$FB
		LDA	$FC
		SBC	#$00
		STA	$FC
		
		JMP	@done
		
@wrap:
		LDX	LANGCOUNT
		DEX
		STX	JoySelected
		
		LDA	maxRowPos
		STA	$FB
		LDA	maxRowPos + 1
		STA	$FC
		
@done:
		JSR	initSetJoySel
		
		RTS
		

;-------------------------------------------------------------------------------
initJoyDown:
;-------------------------------------------------------------------------------
		JSR	initClearJoySel
		
		INC	JoySelected
		LDA	JoySelected
		CMP	LANGCOUNT
		BEQ	@wrap
		
		CLC
		LDA	$FB
		ADC	#$28
		STA	$FB
		LDA	$FC
		ADC	#$00
		STA	$FC
		
		JMP	@done
		
@wrap:
		LDX	#$00
		STX	JoySelected
		
		LDA	#<$0450
		STA	$FB
		LDA	#>$0450
		STA	$FC
		
@done:
		JSR	initSetJoySel
		
		RTS
		

;-------------------------------------------------------------------------------
initJoyButton:
;-------------------------------------------------------------------------------
		JSR	initFirstLang
		LDX	JoySelected
		BEQ	@proc
		
@loop:
		JSR	initNextLang
		
		DEX
		BNE	@loop
		
@proc:
		LDY	#$01
		LDA	($FD), Y
		STA	langSelected
		STY	langFound
		
		RTS


;-------------------------------------------------------------------------------
initTestJoy:
;-------------------------------------------------------------------------------
		LDA	JoyAck
		BNE	@tstUp
		
		RTS

@tstUp:
		LDA	#$00
		STA	JoyAck

		LDA	JoyUp
		BEQ	@tstDown
		
		JSR	initJoyUp
		RTS
		
@tstDown:
		LDA	JoyDown
		BEQ	@tstButton
		
		JSR	initJoyDown
		RTS
		
@tstButton:
		LDA	JoyButton
		BEQ	@done
		
		JSR	initJoyButton
		
@done:
		RTS


;-------------------------------------------------------------------------------
initGetLang:
;-------------------------------------------------------------------------------
		LDA	maxRowPos
		STA	$FB
		LDA	maxRowPos + 1
		STA	$FC
		
		JSR	initSetJoySel
		
		LDX	LANGCOUNT
		DEX
		BEQ	@loop
		
@mul:
		CLC
		LDA	maxRowPos
		ADC	#$28
		STA	maxRowPos
		LDA	maxRowPos + 1
		ADC	#$00
		STA	maxRowPos + 1
		
		DEX
		BNE	@mul

@loop:
		JSR	$FFE4
		BNE	@tstkeys
		
		JSR	initTestJoy
		LDA	langFound
		BNE	@found
		
		JMP	@loop

@tstkeys:
		JSR	initTestKeys
		LDA	langFound
		BNE	@found

		JMP	@loop
		
@found:
		LDA	langSelected
		BEQ	@done

		STA	FILENAME_2 - 1

@done:
		RTS


;-------------------------------------------------------------------------------
initDispLangs:
;-------------------------------------------------------------------------------
		LDA	#<LANGFRSTD
		STA	$FD
		LDA	#>LANGFRSTD
		STA	$FE
		
		LDX	LANGCOUNT
		DEX

@loop0:
		LDY	#$13
		
		JSR	initOutString
		JSR	initNewLine
			
		JSR	initNextLang
			
		DEX
		BPL	@loop0

		RTS


;-------------------------------------------------------------------------------
initFirstLang:
;-------------------------------------------------------------------------------
		LDA	#<LANGSTART
		STA	$FD
		LDA	#>LANGSTART
		STA	$FE
		
		RTS


;-------------------------------------------------------------------------------
initNextLang:
;-------------------------------------------------------------------------------
		CLC
		LDA	$FD
		ADC	#$16
		STA	$FD
		LDA	$FE
		ADC	#$00
		STA	$FE

		RTS
		

;-------------------------------------------------------------------------------
initLoadFile:
;-------------------------------------------------------------------------------
		LDA	#$01
		LDX	#$08
		LDY	#$01
		
		JSR	krnlSetLFS
		
		LDA	$A3
		LDX	$A4
		LDY	$A5
		
		JSR	krnlSetNam
		
		LDA	#$00
		JSR	krnlLoad
		
		JSR	knrlClAll

		RTS


;-------------------------------------------------------------------------------
initOutString:
;-------------------------------------------------------------------------------
@loop:
		LDA	($FD), Y
		STA	($FB), Y
		DEY
		BPL	@loop
		
		RTS


;-------------------------------------------------------------------------------
initNewLine:
;-------------------------------------------------------------------------------
		CLC
		LDA	$FB
		ADC	#$28
		STA	$FB
		LDA	$FC
		ADC	#$00
		STA	$FC
		
		RTS
		


lowMemData:

	.org	$0334
lowMemPrgLoader:
		LDA	#$01
		LDX	#$08
		LDY	#$01
		
		JSR	krnlSetLFS
		
		LDA	$A3
		LDX	$A4
		LDY	$A5
		
		JSR	krnlSetNam
		
		LDA	#$00
		JSR	krnlLoad
		
		JSR	knrlClAll

		LDX	#$FF
		TXS

		JMP	$080D
		
lowMemPrgLdEnd:
