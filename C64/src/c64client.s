;===============================================================================
;MONOPOLY 
;-------------------------------------------------------------------------------
;FOR THE COMMODORE 64
;BY DANIEL ENGLAND FOR ECCLESTIAL SOLUTIONS
;
;
;(C) 2018 DANIEL ENGLAND
;ALL RIGHTS RESERVED
;
;MONOPOLY IS THE PROPERTY OF HASBRO INC.
;(C) 1935, 2016 HASBRO
;
;
;You probably need to own a copy of the official board game to even have this.
;*ugh*
;
;I feel this is how the game should be played...
;
;
;Please see readme.md for further information.
;
;
;Free memory information (as of last update from 0.02.39A):
;	* Between strings and rules data, 801 bytes (free for data)
;	* Between rules data and action cache, 239 bytes (free for data)
;	* Between heap and reserved, 4393 bytes (free for program)
;	* Reserved areas, 768 bytes (unavailable/unused)
;
;By my calculation, there are 655 bytes unaccounted for somewhere...  Where did
;they go?
;
;
;Memory map (as of last update from 0.02.39A):
;	0000 -	00FF	Zero page
;	0100 -	01FF	System stack
;	0200 - 	03FF	Global state
;	0400 - 	07FF	Screen data and sprite pointers
;	0800 - 	08FF	Sprite data/bootstrap
;	0900 -  BCD7	Program area
;	BCD8 - 	CDFF	Discard/heap
;	CE00 - 	CFFF	Reserved (may be used for additional discard/heap)
;	D000 - 	DFFF	System IO
;	E000 -	F3FF	Strings data (ends at F0DF)
;	F400 - 	FAFF	Rules data (ends at FA11)
;	FB00 - 	FEFF	Action cache
;	FF00 -  FFF9	Reserved (unused on purpose)
;	FFFA -	FFFF	System vectors
;
;===============================================================================


;===============================================================================
;C64CLIENT.S
;===============================================================================


;-------------------------------------------------------------------------------
;Compile switch definitions
;-------------------------------------------------------------------------------
	.define DEBUG_IRQ 	0
	.define DEBUG_KEYS	0
	.define DEBUG_CPU 	0


;-------------------------------------------------------------------------------
;General definitions
;-------------------------------------------------------------------------------
;***	screendefs.inc
spriteMem20	= 	$0800

spritePtr0	=	$07F8
spritePtr1	=	$07F9

offsX		=	24
offsY		=	50

	.struct	BUTTON
		fType	.byte			;0 = regular disabled 
						;1 = regular enabled
						;2 = regular hidden
						;3 = footer (2 char ind, hacked)
						;4 = single cell button
						;C = colour visible
						;D = colour hidden
						;E = Simple (trd sel dialog)
						;F = Full Screen
						;FF = end of buttons
		pY	.byte
		pX1	.byte
		pX2	.byte
		wResv	.word
		fColour	.byte
		cKey	.byte
	.endstruct

	.struct	MENUPAGE
		aKeys	.word
		aDraw	.word
		bDef	.byte
		aCPU	.word
	.endstruct

	.struct	DIALOG
		fKeys	.word
		fDraw	.word
		bDef	.byte
	.endstruct
	
	.struct BQUADP
		pPosHY	.byte
		pPos0X	.word
		pPos1X	.word
		pPos2X	.word
		pPos3X	.word
		pPos4X	.word
		pPos5X	.word
		pPosVX	.word
		pPos0Y	.byte
		pPos1Y	.byte
		pPos2Y	.byte
		pPos3Y	.byte
		pPos4Y	.byte
	.endstruct
	
	.struct	SQRQUAD				;Currently must be 2 bytes
		pSqrHY 	.byte
		pSqrVX	.byte
	.endstruct
	
	.struct	SQRQLOC				;Currently must be 2 bytes
		pSqrA	.byte
		pImprvA	.byte			;#$FF = none, else X or Y
	.endstruct


;***	machinedefs.inc
VIC     	= 	$D000         		; VIC REGISTERS
vicSprPos0	=	$D000
vicSprPos1	=	$D002
VICXPOS    	= 	VIC + $00      		; LOW ORDER X POSITION
VICYPOS    	= 	VIC + $01      		; Y POSITION
VICXPOSMSB 	=	VIC + $10      		; BIT 0 IS HIGH ORDER X POS
vicSprPosM	=	$D010
vicCtrlReg	=	$D011
vicRstrVal	=	$D012
vicSprEnab	= 	$D015
vicSprExpY	=	$D017
vicMemCtrl	=	$D018
vicIRQFlgs	=	$D019
vicIRQMask	=	$D01A
vicSprCMod	= 	$D01C
vicSprExpX	= 	$D01D
vicBrdrClr	=	$D020
vicBkgdClr	= 	$D021
vicSprMCl0	= 	$D025
vicSprMCl1	= 	$D026
vicSprClr0	= 	$D027
vicSprClr1	= 	$D028

SID     	= 	$D400         		; SID REGISTERS
sidVoc2FLo	=	$D40E
sidVoc2FHi	=	$D40F
sidVoc2Ctl	=	$D412
sidV2EnvOu	=	$D41B
SID_ADConv1    	= 	SID + $19
SID_ADConv2    	= 	SID + $1A

CIA1_PRA        = 	$DC00        ; Port A
CIA1_PRB	=	$DC01
CIA1_DDRA	=	$DC02
CIA1_DDRB	=	$DC03
cia1IRQCtl	=	$DC0D

cpuIRQ		=	$FFFE
cpuRESET	=	$FFFC
cpuNMI		=	$FFFA

krnlOutChr	= 	$E716
krnlLoad	=	$FFD5
krnlSetLFS	=	$FFBA
krnlSetNam	=	$FFBD
knrlClAll	=	$FFE7


;***	uidefs.inc
buttonLeft	=	$10
buttonRight	=	$01
JSTKSENS_LOW	=	27
JSTKSENS_MED	=	18
JSTKSENS_HIGH	=	9

	.struct	UI
		fHveInp .byte
		fMseEnb	.byte
		fJskEnb	.byte
		fJskAck	.byte
		cJskSns .byte
		cJskDly	.byte

		fWntJFB	.byte
		
		iSelBtn .byte
		fSelSgl .byte
		cHotDly .byte
		fHotSta	.byte
		
		fBtUpd0 .byte
		fBtSta0 .byte
		
		fBtUpd1 .byte
		fBtSta1 .byte
		
		cActns	.byte
		gMdAct	.byte
		pActBak .byte
		fActTyp .byte			;type (regular, elimin)
		fActInt .byte			;interactive
		
		fInjKey .byte
	.endstruct


;***	musicdefs.inc
musTuneIntro	=	$00
musTuneSilence  =	$01
musTuneDice0    =	$02
musTuneDice1    =	$03
musTuneDice2    =	$04
musTuneDice3    =	$05
musTuneDice4    =	$06
musTuneDice5    =	$07
musTuneGaol     =	$08
musTuneBuy	=	$09
musTuneBuyAll   =	$0A
musTuneHouse    =	$0B
musTuneHotel    =	$0C
musTuneGameOver =	$0D
musTunePlyrElim =	$0E
musTuneStart	=	$0F


;***	keydefs.inc
keyF1		= 	$85
keyF3		=	$86
keyF5		=	$87
keyF7		=	$88
keyF2		=	$89
keyF4		=	$8A
keyF6		=	$8B
keyF8		=	$8C

keyZPKeyDown	=	$C5			;byte
keyZPKeyCount	=	$C6			;byte
keyZPKeyScan	= 	$CB			;byte
keyZPDecodePtr	=	$F5			;word


;***	gamedefs.inc
	.struct SHRTSTR
		_COUNT	.byte
		_0	.byte
		_1	.byte
		_2	.byte
		_3	.byte
		_4	.byte
		_5	.byte
		_6	.byte
		_7	.byte
	.endstruct
	
	.struct TOKEN
		_0	.byte
		_1	.byte
		_2	.byte
		_3	.byte
		_4	.byte
		_5	.byte
		_6	.byte
		_7	.byte
		_8	.byte
		_9	.byte
		_A	.byte
		_B	.byte
		_C	.byte
		_D	.byte
		_E	.byte
		_F	.byte
	.endstruct

	.struct GAME
		sig	.byte
		lock	.byte
		term	.byte
		dirty	.byte			;bit 7: Shuffle chest
						;    6: Shuffle chance
						;    5: Prompt dirty
						;    4: Dialog dirty
						;    3: Menu dirty
						;    2: Selection dirty
						;    1: Stats dirty
						;    0:	All screen dirty***FIXME
		qVis	.byte
		pCount	.byte
		pFirst	.byte
		pActive	.byte
		pLast	.byte
		dlgVis	.byte
		fShwNxt	.byte
		pVis	.byte
		sSelect	.byte
		kWai	.byte
		aWai	.word
		dieA	.byte
		dieB	.byte
		dieDbl	.byte
		dieRld	.byte
		nDbls	.byte
		pGF0Crd	.byte
		pGF1Crd	.byte
		fGF0Out .byte
		fGF1Out .byte
		fMBuy	.byte
		
		fFPTax	.byte
		mFPTax	.word

		gMdActn .byte
		pRecall	.byte
		pWAuctn	.byte
		pAFirst .byte
		mAuctn	.word
		mACurr	.word
		fAPass	.byte
		fAForf	.byte
		sAuctn	.byte
		
		cntHs	.byte
		cntHt	.byte

		fMngmnt	.byte
		sMngBak .byte
		
		fDoJump	.byte
		iStpCnt .byte
		fStpSig .byte
		
		fAmStep .byte
		sStpDst .byte
		fStpPsG .byte
		fPayDbl .byte
		gMdStep .byte
		
		fTrdSlM .byte
		fTrdSlL .byte
		sTrdSel .byte
		aTrdSlH .word
		cTrdSlB .byte
		
		gMdMPyI	.byte			;Back up game mode for must pay
		pMstPyI	.byte			;Back up of player for must pay
		pMPyLst	.byte			;Last player to check in mpay
		pMPyCur	.byte			;Current player checked in mpay
		
		gMdElim	.byte			;Back up game mode for elimin. 
		pElimin .byte			;Back up player for elimin.
		
		gMdTrdI .byte			;Back up gmode for trade intrpt
		pTrdICP	.byte			;Back up player for trade intrpt
		
		
		fTrdStg .byte			;stage
		iTrdStp .byte			;step
		fTrdPhs .byte			;phase
		fTrdTyp .byte			;type (regular, elimin)
		
		gMdQuit .byte			
		pQuitCP	.byte
		
		gMode	.byte			;0:  Normal (Play)
						;1:  Auction
						;2:  Interrupt (Trade Approve)
						;3:  Interrupt (Must Pay)
						;4:  Interrupt (Elimin Xfer)
						;5:  Game Over
						;6:  Player stepping (f/e)
						;7:  Trade selection (f/e)
						;8:  Action stepping (f/e)
						;9:  Quit request
		
		varA	.byte
		varB	.byte
		varC	.byte
		varD	.byte
		varE	.byte
		varF	.byte
		varG	.byte
		varH	.byte
		varI	.byte
		varJ	.byte
		varK	.byte
		varL	.byte
		varM	.byte
		varN	.byte
		varO	.byte
		varP	.byte
		varQ	.byte
		varR	.byte
		varS	.byte
		varT	.byte
		varU	.byte
		varV	.byte
		varW	.byte
		varX	.byte
	.endstruct
	
	
	.struct PLAYER
		dirty	.byte
		square	.byte
		colour	.byte
		money	.word
		equity  .word
		status	.byte			;Bit 7: In Gaol
						;Bit 6: Gone Gaol
						;Bit 5: Must Post
						;Bit 4: Only Move
						;Bit 3: In Debt
						;Bit 2: 
						;Bit 1: Losing
						;Bit 0: Alive
		fCPU	.byte
		fCPUHvI .byte
		
		nGRls	.byte

		name	.tag	SHRTSTR
		
		oGrp01	.byte			;Brown
		oGrp02	.byte			;Light Blue
		oGrp03	.byte			;Purple
		oGrp04	.byte			;Orange
		oGrp05	.byte			;Red
		oGrp06	.byte			;Yellow
		oGrp07	.byte			;Green
		oGrp08	.byte			;Blue
		oGrp09	.byte			;Stations		
		oGrp0A	.byte			;Utilities
		
		mDAcc0	.word			;Accounts for players
		mDAcc1	.word			;Same acc# as player# is
		mDAcc2	.word			;bank (general)
		mDAcc3	.word
		mDAcc4	.word
		mDAcc5	.word
		mDAcc6	.word			;Bank (taxes)
	.endstruct


	.struct	SQUARE				;Currently must be 2 bytes
		owner	.byte			;#$FF = none
		imprv	.byte			;Bit 7:	Mortgage flag
						;    6: All group flag
						;    5:	Select flag
						;    4: Unused
						;    3: Hotel flag
						;  0-2: Houses count
	.endstruct
	
	
	.struct TRADE
		player 	.byte
		money	.word
		gofree	.byte
		cntDeed .byte
	.endstruct
	
	

;***	ruledefs.inc
	.struct	SQRDEED
		group	.byte
		index	.byte
	.endstruct
	
	.struct GROUP
;		type	.byte			;I was going to use this to 
						;indicate card/deed/street etc
		colour	.byte
		count	.byte
		pImprv	.byte
		aScrTab .word
		mDeed1	.word			;***FIXME: Should be "card"?
		mDeed2	.word
		mDeed3	.word
		mDeed4	.word
	.endstruct

;groups:
;		00	-	Corners
;		01	-	Brown
;		02	- 	Light Blue
;		03	-	Purple
;		04	-	Orange
;		05	-	Red
;		06	-	Yellow
;		07	-	Green
;		08	-	Blue
;		09	-	Stations
;		0A	-	Utilities
;		0B	-	Chest
;		0C	-	Chance
;		0D	- 	Tax


	.struct CARD
		sTitle0	.word
		sTitle1 .word
	.endstruct

	.struct	DEED
		cCard	.tag	CARD
		pPurch	.word
		mValue	.word			;could be byte
		mFee	.word			;could be byte
	.endstruct

	.struct	STREET
		cCard	.tag	CARD
		pPurch	.word
		mValue	.word			;***TODO:  Change to mMrtg
		mFee	.word			;could be byte
		mRent	.word			;could be byte
		m1Hse	.word
		m2Hse	.word
		m3Hse	.word
		m4Hse	.word
		mHotl	.word
	.endstruct
	
	.struct	STATION
		cCard	.tag	CARD
		pPurch	.word
		mValue	.word			;could be byte
		mFee	.word			;could be byte
		rRent	.word			;could be byte
	.endstruct
	
	.struct	UTILITY
		cCard	.tag	CARD
		pPurch	.word
		mValue	.word			;could be byte
		mFee	.word			;could be byte
	.endstruct
	
	
;-------------------------------------------------------------------------------
;Global data defines
;-------------------------------------------------------------------------------
ui		=	$0200
game		=	ui + .sizeof(UI)		
plr0		=	game + .sizeof(GAME)
plr1		=	plr0 + .sizeof(PLAYER)
plr2		=	plr1 + .sizeof(PLAYER)
plr3		=	plr2 + .sizeof(PLAYER)
plr4		=	plr3 + .sizeof(PLAYER)
plr5		=	plr4 + .sizeof(PLAYER)
sqr00		=	plr5 + .sizeof(PLAYER)

keyBuffer0	=	sqr00 + (.sizeof(SQUARE) * 40)
keyBufferSize 	=	keyBuffer0 + 10
keyRepeatFlag 	=	keyBufferSize + 1
keyRepeatSpeed  =	keyRepeatFlag + 1
keyRepeatDelay	=	keyRepeatSpeed + 1
keyModifierFlag = 	keyRepeatDelay + 1
keyModifierLast =	keyModifierFlag + 1
;keyModifierVect =	keyModifierLast + 1
;keyModifierLock =	keyModifierVect + 2

	.assert keyModifierLast < $0400, error, "Global data space too large!"



;-------------------------------------------------------------------------------
;String data defines
;-------------------------------------------------------------------------------
	.include 	"strings.inc"


;-------------------------------------------------------------------------------
;BASIC launcher
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
	.assert         * = $080D, error, "BASIC interface incorrect!"
bootstrap:
;	Exclude BASIC (include Kernal and IO)
		LDA	$00
		ORA	#$07
		STA	$00
		LDA	#$1E
		STA	$01		

		JSR	initVICII

		JSR	initDataLoad
		
		LDA	#$7F			;disable standard CIA irqs
		STA	cia1IRQCtl
		
		CLD
		SEI
		
		JMP	initCore
	
	.assert         * < $0840, error, "Bootstrap incorrect!"
	
;	We need this space in order to use it for the mouse pointer (from $0800)
	.repeat	($0840 - *), I
		.byte	$00
	.endrep

plrToken:
			.byte	%00111100, $00, $00
			.byte 	%01111110, $00, $00
			.byte	%11111111, $00, $00
			.byte	%11111111, $00, $00
			.byte	%11111111, $00, $00
			.byte	%11111111, $00, $00
			.byte 	%01111110, $00, $00
			.byte	%00111100, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00

plrMinimap:
			.byte	$C0, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00, $00, $00
			.byte	$00

brdMiniMap:
			.byte	%10011111, %11111111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%11101111, %11011011, %11110111
			.byte	%11111111, %11111111, %11111111
			.byte	%11111111, %11111111, %11111111
			.byte	%11111111, %11011011, %11111111
			.byte	%10000000, %00000000, %00000001
			.byte	%11111111, %11011011, %11111111
			.byte	%11111111, %11111111, %11111111
			.byte	%11111111, %11111111, %11111111
			.byte	%11101111, %11011011, %11110111
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11100111, %11111001
			.byte	%10011111, %11111111, %11111001
			.byte  	$00
;			.byte	%11111111, %11111111, %11111111
;			.byte	%10000000, %00010000, %00000001
;			.byte	%10100000, %00001000, %00000101
;			.byte	%10000000, %00010000, %00000001
;			.byte	%10100000, %00001000, %00000101
;			.byte	%10000000, %00010000, %00000001
;			.byte	%10010000, %00100100, %00001001
;			.byte	%10000000, %00000000, %00000001
;			.byte	%10000000, %00000000, %00000001
;			.byte	%10000000, %00100100, %00000001
;			.byte	%10101010, %10000001, %01010101
;			.byte	%10000000, %00100100, %00000001
;			.byte	%10000000, %00000000, %00000001
;			.byte	%10000000, %00000000, %00000001
;			.byte	%10010000, %00100100, %00001001
;			.byte	%10000000, %00001000, %00000001
;			.byte	%10100000, %00010000, %00000101
;			.byte	%10000000, %00001000, %00000001
;			.byte	%10100000, %00010000, %00000101
;			.byte	%10000000, %00001000, %00000001
;			.byte	%11111111, %11111111, %11111111
;			.byte  	$00

	.assert         * = $0900, error, "Program header incorrect!"

;Include the sound driver and music data
SNDBASE:		
	.include	"tune.s"
	
;Include the SFX data
SFXDING:
	.include	"ding.inc"
SFXDONG:
	.include	"dong.inc"
SFXBUZZ:
	.include 	"buzz.inc"
SFXNUDGE:
	.include	"nudge.inc"
SFXSPLAT:
	.include	"splat.inc"
SFXSLAM:
        .include	"slam.inc"
SFXGONG:
	.include	"gong.inc"
SFXLOWZAP:
	.include	"lowzap.inc"
SFXRENT0:
	.include	"rent0.inc"
SFXRENT1:
	.include	"rent1.inc"
SFXRENT2:
	.include	"rent2.inc"
SFXRENT3:
	.include	"rent3.inc"
SFXCASH:
	.include	"cash.inc"
SFXSLIDE:
	.include	"slide.inc"
SFXSLIDELOW:
	.include	"slidelow.inc"
SFXBELL:
	.include	"bell.inc"


;Lookups for rent SFX
sfxRentLo:	
		.byte	<SFXRENT0, <SFXRENT1, <SFXRENT2, <SFXRENT3
sfxRentHi:	
		.byte	>SFXRENT0, >SFXRENT1, >SFXRENT2, >SFXRENT3
			
	
;-------------------------------------------------------------------------------
;Global variable data
;-------------------------------------------------------------------------------
prmptTok0:	.tag	TOKEN
prmptTok1:	.tag	TOKEN
prmptClr0:	.tag	TOKEN
prmptClr1:	.tag	TOKEN

trade0:		.tag	TRADE
trddeeds0:		
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00
;		.byte			    $00, $00, $00, $00
;		.byte	$00, $00, $00, $00, $00, $00, $00, $00
trdrepay0:		
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00
;		.byte			    $00, $00, $00, $00
;		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		
trade1:		.tag	TRADE
trddeeds1:		
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00
;		.byte			    $00, $00, $00, $00
;		.byte	$00, $00, $00, $00, $00, $00, $00, $00
trdrepay1:		
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00
;		.byte			    $00, $00, $00, $00
;		.byte	$00, $00, $00, $00, $00, $00, $00, $00

trade2:		.tag	TRADE
trddeeds2:		
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00		;Need an extra two bytes to 
						;"unpack" the gofree cards.
trdrepay2:		
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00, $00, $00, $00, $00, $00, $00


;-------------------------------------------------------------------------------
;game consts/tables
;-------------------------------------------------------------------------------
plrColours:
			.byte	$02, $04, $05, $06, $07, $08, $09, $0A
			.byte   $0D, $0E
			
plrFlags:		.byte	$01, $02, $04, $08, $10, $20
	
plrLo:
			.byte	<plr0, <plr1, <plr2
			.byte	<plr3, <plr4, <plr5
plrHi:
			.byte	>plr0, >plr1, >plr2
			.byte	>plr3, >plr4, >plr5
plrNameLo:		
			.byte	<(plr0 + PLAYER::name)
			.byte	<(plr1 + PLAYER::name) 
			.byte	<(plr2 + PLAYER::name)
			.byte	<(plr3 + PLAYER::name)
			.byte	<(plr4 + PLAYER::name)
			.byte	<(plr5 + PLAYER::name)
plrNameHi:
			.byte	>(plr0 + PLAYER::name)
			.byte	>(plr1 + PLAYER::name) 
			.byte	>(plr2 + PLAYER::name)
			.byte	>(plr3 + PLAYER::name)
			.byte	>(plr4 + PLAYER::name)
			.byte	>(plr5 + PLAYER::name)

	
;-------------------------------------------------------------------------------
;main
;-------------------------------------------------------------------------------
main:
		CLI				;does this fix the race condition?
		
uloop:
		SEI				;does this fix the race condition?
		LDA	game + GAME::lock
		BNE	main
		
		LDA	#$01
		STA	game + GAME::sig
		CLI				;does this fix the race condition?

		JSR	handleUpdates

		SEI				;does this fix the race condition?
		LDA	#$00
		STA	game + GAME::sig
		CLI				;does this fix the race condition?

		JMP	main
		
hang:
		JMP	hang


;-------------------------------------------------------------------------------
;handleUpdates
;-------------------------------------------------------------------------------
handleUpdates:
		LDX	game + GAME::pActive
		CPX	game + GAME::pLast
		BEQ	@tststep
		
		LDA	game + GAME::fShwNxt
		BEQ	@tststep
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::fCPU
		LDA	($FB), Y
		BNE	@tststep
		
		JSR	gameShowPlayerDlg
	
@tststep:
		LDA	game + GAME::gMode
		CMP	#$06
		BNE	@tsttrdsel
		
		LDA	game + GAME::dlgVis	;***FIXME: I'm not sure this is
		BNE	@tsttrdsel		;really required but makes sense
		
		JSR	gamePerfStepping
		
@tsttrdsel:
		CMP	#$07
		BNE	@tsttrdstep
		
		JSR	gamePerfTrdSelBlink
		
@tsttrdstep:
		LDA	game + GAME::gMode
		CMP	#$08
		BNE	@tstdirty

		LDA	game + GAME::dlgVis
		BNE	@tstdirty

		JSR	uiProcessActions

@tstdirty:
		LDA	game + GAME::dirty
		BNE	@chest
		
		JMP	updatesExit
		
@chest:
		LDA	game + GAME::dirty
		AND	#$80
		BEQ	@chnce
		
		JSR 	rulesShuffleChest
		
@chnce:
		LDA	game + GAME::dirty
		AND	#$40
		BEQ	@begin
		
		JSR 	rulesShuffleChance
		
@begin:
		LDA	game + GAME::dirty
		AND	#$10
		BEQ	@updTstCont0
		
		LDA	game + GAME::dlgVis
		BNE	@updDialog
		
		JSR	gameRebuildScreen
		JMP	updatesExit

@updTstCont0:
		LDA	game + GAME::dirty
		AND	#$01
		BNE	@updAll
		
		LDA	game + GAME::dirty
		AND	#$04
		BNE	@updSelOnly
		
		LDA	game + GAME::dirty
		AND	#$02
		BNE	@updStats

		LDA	game + GAME::dirty
		AND	#$08
		BNE	@updMenu

@updAll:
	.if	DEBUG_IRQ
		LDA	#$0E
		STA	vicBrdrClr
	.endif
		
		LDX 	#$00
		JSR	boardDisplayQuad
		
	.if	DEBUG_IRQ
		LDA	#$0B
		STA	vicBrdrClr
	.endif
		
@updStats:
	.if	DEBUG_IRQ
		LDA	#$0E
		STA	vicBrdrClr
	.endif

		JSR	statsDisplay

	.if	DEBUG_IRQ
		LDA	#$0B
		STA	vicBrdrClr
	.endif

@updMenu:
		JSR	menuDisplay

		LDA	game + GAME::dirty
		AND	#$20
		BEQ	@updTstCont1

		JSR	prmptUpdate
		JSR	prmptDisplay
		
@updTstCont1:
		LDA	game + GAME::dlgVis
		BEQ	@tstcpu
		
@updDialog:
		JSR	dialogDisplay
		LDA	#$00
		STA	game+GAME::dirty

		JMP	updatesExit

@tstcpu:
		LDA	#$00
		STA	game+GAME::dirty
		
		LDA	game + GAME::gMode
		CMP	#$09
		BEQ	@tstcpu1
		
		CMP	#$05
		BPL	@human
		
@tstcpu1:
		LDA	keyQueueEnPos
		BNE	@human
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::fCPU
		LDA	($FB), Y
		BEQ	@human
		
		LDA	menuActivePage0 + MENUPAGE::aCPU
		STA	cpuThisPerform
		LDA	menuActivePage0 + MENUPAGE::aCPU + 1
		STA	cpuThisPerform + 1
		
		JSR	cpuEngageBehaviour

@human:
		JMP	updatesExit
		
@updSelOnly:
	.if	DEBUG_IRQ
		LDA	#$0E
		STA	vicBrdrClr
	.endif
	
		LDX 	#$01
		JSR	boardDisplayQuad

		LDA	#$00
		STA	game+GAME::dirty
		
	.if	DEBUG_IRQ
		LDA	#$0B
		STA	vicBrdrClr
	.endif
	
updatesExit:
		LDA	game + GAME::pActive
		STA	game + GAME::pLast

		LDA	ui + UI::fBtUpd0
		CMP	#$FF
		BEQ	@tstUpd1
		
		LDA	ui + UI::fBtSta0
		BNE	@upd0hot
		
		LDA	ui + UI::fBtUpd0
		JSR	screenDrawButton
		
		LDA	#$FF
		STA	ui + UI::fBtUpd0
		
		JMP	@tstUpd1
		
@upd0hot:
		LDA	ui + UI::fBtUpd0
		JSR	screenHotButton
		
		LDA	#$FF
		STA	ui + UI::fBtUpd0
		
@tstUpd1:
		LDA	ui + UI::fBtUpd1
		CMP	#$FF
		BEQ	@realexit

		LDA	ui + UI::fBtSta1
		BNE	@upd1hot
		
		LDA	ui + UI::fBtUpd1
		JSR	screenDrawButton
		
		LDA	#$FF
		STA	ui + UI::fBtUpd1
		
		RTS
		
@upd1hot:
		LDA	ui + UI::fBtUpd1
		JSR	screenHotButton
		
		LDA	#$FF
		STA	ui + UI::fBtUpd1

@realexit:
		RTS


;-------------------------------------------------------------------------------
;gameRebuildScreen
;-------------------------------------------------------------------------------
gameRebuildScreen:
		JSR	screenBeginButtons	

		LDA	#<screenQErase0
		STA	$FD
		LDA	#>screenQErase0
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	statsClear
		
		LDA	#$01
;		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;==============================================================================
;FOR KEYS.S
;==============================================================================

;keyBuffer0	=	$0277			;to 0280 so 10 bytes
;keyBufferSize 	=	$0289       		;byte
;keyRepeatFlag 	=	$028A       		;byte
;keyRepeatSpeed  =	$028B			;byte
;keyRepeatDelay	=	$028C       		;byte
;keyModifierFlag = 	$028D			;byte
;keyModifierLast =	$028E			;byte
;keyModifierVect =	$028F			;word
;keyModifierLock =	$0291			;byte

keyQueue0:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00
		.byte	$00, $00

keyQueueDePos:	
		.byte	$00
keyQueueEnPos:
		.byte	$00


keyEnqueueKey:
		LDX	keyQueueEnPos
		STA	keyQueue0, X
		
		INC	keyQueueEnPos
		
		RTS


keyDequeueKeys:
		LDA	ui + UI::fInjKey
		BEQ	@exit

@loop:
		LDX	keyQueueDePos
		CPX	keyQueueEnPos
		BEQ	@normalise
		
		LDA	keyQueue0, X
		JSR	keyInjectKey
		
		INC	keyQueueDePos
		
		JMP	@loop
		
@normalise:
		LDA	#$00
		STA	keyQueueDePos
		STA	keyQueueEnPos
	
@exit:
		RTS


;-------------------------------------------------------------------------------
keyInjectKey:	
;-------------------------------------------------------------------------------
;TODO:		Should check buffer size

		LDX	keyZPKeyCount		;Put a key into the buffer
		STA	keyBuffer0, X
		INC	keyZPKeyCount
		
		RTS

keyScanKey:
;.,EA87 A9 00    clear A
		LDA 	#$00        
		
;.,EA89 8D 8D 02 clear the keyboard shift/control/c= flag
		STA 	keyModifierFlag
;.,EA8C A0 40    set no key
		LDY 	#$40
;.,EA8E 84 CB    save which key
		STY 	keyZPKeyScan         
;.,EA90 8D 00 DC clear VIA 1 DRA, keyboard column drive
		STA 	$DC00       
;.,EA93 AE 01 DC read VIA 1 DRB, keyboard row port
		LDX 	$DC01       
;.,EA96 E0 FF    compare with all bits set
		CPX 	#$FF        
;.,EA98 F0 61    if no key pressed clear current key and exit (does
;                                further BEQ to $EBBA)
		BEQ 	keysTstSave		;$EAFB       
;.,EA9A A8       clear the key count
		TAY             
;.,EA9B A9 81    get the decode table low byte
		LDA 	#<keyTableStandard	;$81        
;.,EA9D 85 F5    save the keyboard pointer low byte
		STA 	keyZPDecodePtr         
;.,EA9F A9 EB    get the decode table high byte
		LDA 	#>keyTableStandard	;$EB        
;.,EAA1 85 F6    save the keyboard pointer high byte
		STA 	keyZPDecodePtr + 1         
;.,EAA3 A9 FE    set column 0 low
		LDA 	#$FE
;.,EAA5 8D 00 DC save VIA 1 DRA, keyboard column drive
		STA 	$DC00    
@loopcol:		
;.,EAA8 A2 08    set the row count
		LDX 	#$08        
;.,EAAA 48       save the column
		PHA          
@pollport:		
;.,EAAB AD 01 DC read VIA 1 DRB, keyboard row port
		LDA 	$DC01       
;.,EAAE CD 01 DC compare it with itself
		CMP 	$DC01       
;.,EAB1 D0 F8    loop if changing
		BNE 	@pollport		;$EAAB       
@loop0:
;.,EAB3 4A       shift row to Cb
		LSR             
;.,EAB4 B0 16    if no key closed on this row go do next row
		BCS 	@next			;$EACC       
;.,EAB6 48       save row
		PHA             
;.,EAB7 B1 F5    get character from decode table
		LDA 	(keyZPDecodePtr),Y     
;.,EAB9 C9 05    compare with $05, there is no $05 key but the control
;                                keys are all less than $05
		CMP 	#$05        
;.,EABB B0 0C    if not shift/control/c=/stop go save key count
;                                else was shift/control/c=/stop key
		BCS 	@nextfix		;$EAC9       
;.,EABD C9 03    compare with $03, stop
		CMP 	#$03        
;.,EABF F0 08    if stop go save key count and continue
;                                character is $01 - shift, $02 - c= or $04 - control
		BEQ 	@nextfix		;$EAC9       
;.,EAC1 0D 8D 02 OR it with the keyboard shift/control/c= flag
		ORA 	keyModifierFlag       
;.,EAC4 8D 8D 02 save the keyboard shift/control/c= flag
		STA 	keyModifierFlag       
;.,EAC7 10 02    skip save key, branch always
		BPL 	@nextfix1		;$EACB       
@nextfix:
;.,EAC9 84 CB    save key count
		STY 	keyZPKeyScan      
@nextfix1:
;.,EACB 68       restore row
		PLA             
@next:
;.,EACC C8       increment key count
		INY             
;.,EACD C0 41    compare with max+1
		CPY 	#$41        
;.,EACF B0 0B    exit loop if >= max+1
		BCS 	@evalspecialfix		;$EADC       
;                                else still in matrix
;.,EAD1 CA       decrement row count
		DEX             
;.,EAD2 D0 DF    loop if more rows to do
		BNE 	@loop0			;$EAB3       
;.,EAD4 38       set carry for keyboard column shift
		SEC             
;.,EAD5 68       restore the column
		PLA             
;.,EAD6 2A       shift the keyboard column
		ROL             
;.,EAD7 8D 00 DC save VIA 1 DRA, keyboard column drive
		STA 	$DC00       
;.,EADA D0 CC    loop for next column, branch always
		BNE 	@loopcol		;$EAA8       
@evalspecialfix:
;.,EADC 68       dump the saved column
		PLA             
		
;;.,EADD 6C 8F 02 evaluate the SHIFT/CTRL/C= keys, $EBDC
;;                                key decoding continues here after the SHIFT/CTRL/C= keys are evaluated
;		JMP 	(keyModifierVect)     
		
keysCont:
;.,EAE0 A4 CB    get saved key count
		LDY 	keyZPKeyScan         
;.,EAE2 B1 F5    get character from decode table
		LDA 	(keyZPDecodePtr), Y     
;.,EAE4 AA       copy character to X
		TAX             
;.,EAE5 C4 C5    compare key count with last key count
		CPY 	keyZPKeyDown         
;.,EAE7 F0 07    if this key = current key, key held, go test repeat
		BEQ 	@tstrepeat		;$EAF0 
;.,EAE9 A0 10    set the repeat delay count
		LDY 	#$10        
;.,EAEB 8C 8C 02 save the repeat delay count
		STY 	keyRepeatDelay
;.,EAEE D0 36    go save key to buffer and exit, branch always
		BNE 	keysSave		;$EB26       
@tstrepeat:
;.,EAF0 29 7F    clear b7
		AND 	#$7F        
;.,EAF2 2C 8A 02 test key repeat
		BIT 	keyRepeatFlag
;.,EAF5 30 16    if repeat all go ??
		BMI 	keysNextRep		;$EB0D       
;.,EAF7 70 49    
		BVS 	exitKeys		;$EB42       if repeat none go ??
;.,EAF9 C9 7F    compare with end marker
		CMP 	#$7F        
keysTstSave:
;.,EAFB F0 29           if $00/end marker go save key to buffer and exit
		BEQ 	keysSave		;$EB26
;.,EAFD C9 14    compare with [INSERT]/[DELETE]
		CMP 	#$14        
;.,EAFF F0 0C    if [INSERT]/[DELETE] go test for repeat
		BEQ 	keysNextRep		;$EB0D       
;.,EB01 C9 20    compare with [SPACE]
		CMP 	#$20        
;.,EB03 F0 08    if [SPACE] go test for repeat
		BEQ 	keysNextRep		;$EB0D       
;.,EB05 C9 1D    compare with [CURSOR RIGHT]
		CMP 	#$1D        
;.,EB07 F0 04    if [CURSOR RIGHT] go test for repeat
		BEQ 	keysNextRep		;$EB0D       
;.,EB09 C9 11    compare with [CURSOR DOWN]
		CMP 	#$11        
;.,EB0B D0 35    if not [CURSOR DOWN] just exit
;                               was one of the cursor movement keys, insert/delete
;                                key or the space bar so always do repeat tests
		BNE 	exitKeys		;$EB42       

keysNextRep:
;.,EB0D AC 8C 02 get the repeat delay counter
		LDY 	keyRepeatDelay 
;.,EB10 F0 05    if delay expired go ??
		BEQ 	@decrephigh		;$EB17       
;.,EB12 CE 8C 02 else decrement repeat delay counter
		DEC 	keyRepeatDelay 
;.,EB15 D0 2B    if delay not expired go ??
;                                repeat delay counter has expired
		BNE 	exitKeys		;$EB42       
@decrephigh:
;.,EB17 CE 8B 02 decrement the repeat speed counter
		DEC 	keyRepeatSpeed      
;.,EB1A D0 26    branch if repeat speed count not expired
		BNE 	exitKeys		;$EB42       
;.,EB1C A0 04    set for 4/60ths of a second
		LDY 	#$04        
;.,EB1E 8C 8B 02 save the repeat speed counter
		STY 	keyRepeatSpeed       
;.,EB21 A4 C6    get the keyboard buffer index
		LDY 	keyZPKeyCount         
;.,EB23 88       decrement it
		DEY             
;.,EB24 10 1C    if the buffer isn't empty just exit
;                                else repeat the key immediately
;                                possibly save the key to the keyboard buffer. if there was no key pressed or the key
;                                was not found during the scan (possibly due to key bounce) then X will be $FF here
		BPL 	exitKeys		;$EB42       
keysSave:
;.,EB26 A4 CB    get the key count
		LDY 	keyZPKeyScan         
;.,EB28 84 C5    save it as the current key count
		STY 	keyZPKeyDown        
;.,EB2A AC 8D 02 get the keyboard shift/control/c= flag
		LDY 	keyModifierFlag       
;.,EB2D 8C 8E 02 save it as last keyboard shift pattern
		STY 	keyModifierLast      
;.,EB30 E0 FF    compare the character with the table end marker or no key
		CPX 	#$FF        
;.,EB32 F0 0E    if it was the table end marker or no key just exit
		BEQ 	exitKeys		;$EB42       
;.,EB34 8A       copy the character to A
		TXA             
;.,EB35 A6 C6    get the keyboard buffer index
		LDX 	keyZPKeyCount         
;.,EB37 EC 89 02 compare it with the keyboard buffer size
		CPX 	keyBufferSize
;.,EB3A B0 06    if the buffer is full just exit
		BCS 	exitKeys		;$EB42       
;.,EB3C 9D 77 02 save the character to the keyboard buffer
		STA 	keyBuffer0, X     
;.,EB3F E8       increment the index
		INX             
;.,EB40 86 C6    save the keyboard buffer index
		STX 	keyZPKeyCount         
exitKeys:
;.,EB42 A9 7F    enable column 7 for the stop key
		LDA 	#$7F        
;.,EB44 8D 00 DC save VIA 1 DRA, keyboard column drive
		STA 	$DC00       
;.,EB47 60       
		RTS             
		

;keyEvaluateSpecial:
;;				*** evaluate the SHIFT/CTRL/C= keys
;;.,EB48 AD 8D 02 get the keyboard shift/control/c= flag
;		LDA 	keyModifierFlag
;;.,EB4B C9 03    compare with [SHIFT][C=]
;		CMP 	#$03        
;;.,EB4D D0 15    if not [SHIFT][C=] go ??
;		BNE 	@control		;$EB64       
;;.,EB4F CD 8E 02 compare with last
;		CMP 	keyModifierLast
;;.,EB52 F0 EE    exit if still the same
;		BEQ 	exitKeys		;$EB42       
;;.,EB54 AD 91 02 get the shift mode switch $00 = enabled, $80 = locked
;		LDA 	keyModifierLock      
;;.,EB57 30 1D    if locked continue keyboard decode
;;                               toggle text mode
;		BMI 	@done			;$EB76       
;;.,EB59 AD 18 D0 get the start of character memory address
;		LDA 	$D018       
;;.,EB5C 49 02    toggle address b1
;		EOR 	#$02        
;;.,EB5E 8D 18 D0 save the start of character memory address
;		STA 	$D018       
;;.,EB61 4C 76 EB continue the keyboard decode
;;                                select keyboard table
;		JMP 	@done			;$EB76       
;@control:
;;.,EB64 0A       << 1
;		ASL             
;;.,EB65 C9 08    compare with [CTRL]
;		CMP 	#$08        
;;.,EB67 90 02    if [CTRL] is not pressed skip the index change
;		BCC 	@copy			;$EB6B       
;;.,EB69 A9 06    else [CTRL] was pressed so make the index = $06
;		LDA 	#$06        
;@copy:
;;.,EB6B AA       copy the index to X
;		TAX             
;;.,EB6C BD 79 EB get the decode table pointer low byte
;		LDA 	keyTableAddresses, X     
;;.,EB6F 85 F5    save the decode table pointer low byte
;		STA 	keyZPDecodePtr         
;;.,EB71 BD 7A EB get the decode table pointer high byte
;		LDA 	keyTableAddresses + 1,X     
;;.,EB74 85 F6    save the decode table pointer high byte
;		STA 	keyZPDecodePtr + 1         
;@done:
;;.,EB76 4C E0 EA continue the keyboard decode
;		JMP 	keysCont		;$EAE0       



;;                                *** table addresses
;keyTableAddresses:
;;.:EB79 81 EB                    standard
;	.word	keyTableStandard
;;.:EB7B C2 EB                    shift
;	.word	keyTableShifted
;;.:EB7D 03 EC                    commodore
;	.word	keyTableSys
;;.:EB7F 78 EC                    control
;	.word	keyTableControl


;				*** standard keyboard table
keyTableStandard:
;.:EB81 14 0D 1D 88 85 86 87 11
	.byte	$14, $0D, $1D, $88, $85, $86, $87, $11
;.:EB89 33 57 41 34 5A 53 45 01
	.byte	$33, $57, $41, $34, $5A, $53, $45, $01
;.:EB91 35 52 44 36 43 46 54 58
	.byte	$35, $52, $44, $36, $43, $46, $54, $58
;.:EB99 37 59 47 38 42 48 55 56
	.byte	$37, $59, $47, $38, $42, $48, $55, $56
;.:EBA1 39 49 4A 30 4D 4B 4F 4E
	.byte	$39, $49, $4A, $30, $4D, $4B, $4F, $4E
;.:EBA9 2B 50 4C 2D 2E 3A 40 2C
	.byte	$2B, $50, $4C, $2D, $2E, $3A, $40, $2C
;.:EBB1 5C 2A 3B 13 01 3D 5E 2F
	.byte	$5C, $2A, $3B, $13, $01, $3D, $5E, $2F
;.:EBB9 31 5F 04 32 20 02 51 03
	.byte	$31, $5F, $04, $32, $20, $02, $51, $03
;.:EBC1 FF
	.byte	$FF
	
	
;                                *** shifted keyboard table
keyTableShifted:
;.:EBC2 94 8D 9D 8C 89 8A 8B 91
	.byte	$94, $8D, $9D, $8C, $89, $8A, $8B, $91
;.:EBCA 23 D7 C1 24 DA D3 C5 01
	.byte	$23, $D7, $C1, $24, $DA, $D3, $C5, $01
;.:EBD2 25 D2 C4 26 C3 C6 D4 D8
	.byte	$25, $D2, $C4, $26, $C3, $C6, $D4, $D8
;.:EBDA 27 D9 C7 28 C2 C8 D5 D6
	.byte	$27, $D9, $C7, $28, $C2, $C8, $D5, $D6
;.:EBE2 29 C9 CA 30 CD CB CF CE
	.byte	$29, $C9, $CA, $30, $CD, $CB, $CF, $CE
;.:EBEA DB D0 CC DD 3E 5B BA 3C
	.byte	$DB, $D0, $CC, $DD, $3E, $5B, $BA, $3C
;.:EBF2 A9 C0 5D 93 01 3D DE 3F
	.byte	$A9, $C0, $5D, $93, $01, $3D, $DE, $3F
;.:EBFA 21 5F 04 22 A0 02 D1 83
	.byte	$21, $5F, $04, $22, $A0, $02, $D1, $83
;.:EC02 FF
	.byte	$FF

;;                                *** CBM key keyboard table
;keyTableSys:
;;.:EC03 94 8D 9D 8C 89 8A 8B 91
;	.byte	$94, $8D, $9D, $8C, $89, $8A, $8B, $91
;;.:EC0B 96 B3 B0 97 AD AE B1 01
;	.byte	$96, $B3, $B0, $97, $AD, $AE, $B1, $01
;;.:EC13 98 B2 AC 99 BC BB A3 BD
;	.byte	$98, $B2, $AC, $99, $BC, $BB, $A3, $BD
;;.:EC1B 9A B7 A5 9B BF B4 B8 BE
;	.byte	$9A, $B7, $A5, $9B, $BF, $B4, $B8, $BE
;;.:EC23 29 A2 B5 30 A7 A1 B9 AA
;	.byte	$29, $A2, $B5, $30, $A7, $A1, $B9, $AA
;;.:EC2B A6 AF B6 DC 3E 5B A4 3C
;	.byte	$A6, $AF, $B6, $DC, $3E, $5B, $A4, $3C
;;.:EC33 A8 DF 5D 93 01 3D DE 3F
;	.byte	$A8, $DF, $5D, $93, $01, $3D, $DE, $3F
;;.:EC3B 81 5F 04 95 A0 02 AB 83
;	.byte	$81, $5F, $04, $95, $A0, $02, $AB, $83
;;.:EC43 FF
;	.byte	$FF


;;                                *** control keyboard table
;keyTableControl:
;;.:EC78 FF FF FF FF FF FF FF FF
;	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
;;.:EC80 1C 17 01 9F 1A 13 05 FF
;	.byte	$1C, $17, $01, $9F, $1A, $13, $05, $FF
;;.:EC88 9C 12 04 1E 03 06 14 18
;	.byte	$9C, $12, $04, $1E, $03, $06, $14, $18
;;.:EC90 1F 19 07 9E 02 08 15 16
;	.byte	$1F, $19, $07, $9E, $02, $08, $15, $16
;;.:EC98 12 09 0A 92 0D 0B 0F 0E
;	.byte	$12, $09, $0A, $92, $0D, $0B, $0F, $0E
;;.:ECA0 FF 10 0C FF FF 1B 00 FF
;	.byte	$FF, $10, $0C, $FF, $FF, $1B, $00, $FF
;;.:ECA8 1C FF 1D FF FF 1F 1E FF
;	.byte	$1C, $FF, $1D, $FF, $FF, $1F, $1E, $FF
;;.:ECB0 90 06 FF 05 FF FF 11 FF
;	.byte	$90, $06, $FF, $05, $FF, $FF, $11, $FF
;;.:ECB8 FF
;	.byte	$FF


;==============================================================================
;FOR SCREEN.S
;==============================================================================
button0:	.tag	BUTTON
button1:	.tag	BUTTON
button2:	.tag	BUTTON
button3:	.tag	BUTTON
button4:	.tag	BUTTON
button5:	.tag	BUTTON
button6:	.tag	BUTTON
button7:	.tag	BUTTON
button8:	.tag	BUTTON
button9:	.tag	BUTTON
buttonA:	.tag	BUTTON
buttonB:	.tag	BUTTON
buttonC:	.tag	BUTTON
buttonD:	.tag	BUTTON

buttonLo:		.byte 	<button0, <button1, <button2, <button3
			.byte	<button4, <button5, <button6, <button7
			.byte	<button8, <button9, <buttonA, <buttonB
			.byte 	<buttonC, <buttonD
buttonHi:		.byte 	>button0, >button1, >button2, >button3
			.byte	>button4, >button5, >button6, >button7
			.byte	>button8, >button9, >buttonA, >buttonB
			.byte 	>buttonC, <buttonD


screenBtnCnt:
			.byte	$00
screenBtnSglSeen:
			.byte	$00
screenBtnSglStart:
			.byte	$00
screenRedirectNull:
			.byte	$00

screenRowsLo:
			.byte	<$0400, <$0428, <$0450, <$0478, <$04A0
			.byte	<$04C8, <$04F0, <$0518, <$0540, <$0568
			.byte 	<$0590, <$05B8, <$05E0, <$0608, <$0630
			.byte	<$0658, <$0680, <$06A8, <$06D0, <$06F8
			.byte	<$0720, <$0748, <$0770, <$0798, <$07C0

screenRowsHi:
			.byte	>$0400, >$0428, >$0450, >$0478, >$04A0
			.byte	>$04C8, >$04F0, >$0518, >$0540, >$0568
			.byte 	>$0590, >$05B8, >$05E0, >$0608, >$0630
			.byte	>$0658, >$0680, >$06A8, >$06D0, >$06F8
			.byte	>$0720, >$0748, >$0770, >$0798, >$07C0

colourRowsLo:
			.byte	<$D800, <$D828, <$D850, <$D878, <$D8A0
			.byte	<$D8C8, <$D8F0, <$D918, <$D940, <$D968
			.byte 	<$D990, <$D9B8, <$D9E0, <$DA08, <$DA30
			.byte	<$DA58, <$DA80, <$DAA8, <$DAD0, <$DAF8
			.byte	<$DB20, <$DB48, <$DB70, <$DB98, <$DBC0

colourRowsHi:
			.byte	>$D800, >$D828, >$D850, >$D878, >$D8A0
			.byte	>$D8C8, >$D8F0, >$D918, >$D940, >$D968
			.byte 	>$D990, >$D9B8, >$D9E0, >$DA08, >$DA30
			.byte	>$DA58, >$DA80, >$DAA8, >$DAD0, >$DAF8
			.byte	>$DB20, >$DB48, >$DB70, >$DB98, >$DBC0


;-------------------------------------------------------------------------------
screenBeginButtons:
;-------------------------------------------------------------------------------
		LDA	#$00
		STA	screenBtnCnt
		
		TAX
		LDA	#$FF
		STA	button0, X
		
		RTS


;-------------------------------------------------------------------------------
screenTestSelBtn:
;-------------------------------------------------------------------------------
		TAX
		
		LDA	buttonLo, X
		STA	$44
		LDA	buttonHi, X
		STA	$45
		
		LDY	#BUTTON::fType
		
		LDA	($44), Y
						;0 = regular disabled 
						;2 = regular hidden
						;D = colour hidden
						;FF = end of buttons		
		BEQ	@invalid

		CMP	#$02
		BEQ	@invalid
		
		CMP	#$0D
		BEQ	@invalid
		
		CMP	#$FF
		BEQ 	@invalid
		
		LDA	#$01
		RTS
		
@invalid:
		LDA	#$00
		RTS


;-------------------------------------------------------------------------------
screenDoSelectBtn:
;-------------------------------------------------------------------------------
		STA	ui + UI::iSelBtn
		
		STA	ui + UI::fBtUpd0
		LDA	#$01
		STA	ui + UI::fBtSta0
		STA	ui + UI::fHotSta

		LDA	#$FF
		STA	ui + UI::fBtUpd1

		LDX	ui + UI::iSelBtn
		LDA	buttonLo, X
		STA	$44
		LDA	buttonHi, X
		STA	$45

		LDY	#BUTTON::fType
		LDA	($44), Y
		CMP	#$04
		BNE	@exit
		
		LDA	#$01
		STA	ui + UI::fSelSgl

@exit:
		RTS


;-------------------------------------------------------------------------------
screenResetSelBtn:
;-------------------------------------------------------------------------------
		LDA	ui + UI::fJskEnb
		BNE	@joystick
		
		LDA	ui + UI::fMseEnb
		BEQ	@exit

		LDA	#$01
		STA	mouseCheck
	
		LDA	#$00
		JSR	handleMouse
		RTS

@joystick:
		LDA	#$00
		STA	ui + UI::iSelBtn
		STA	ui + UI::fSelSgl
		
		CMP	screenBtnCnt
		BNE	@findbest
		
@invalid:
		LDA	#$FF
		STA	ui + UI::iSelBtn
		LDA	#$00
		STA	ui + UI::fSelSgl
		STA	ui + UI::fHotSta		
		
		RTS
		
@findbest:
		TAY
@loop0:
		TYA
		PHA

		JSR	screenTestSelBtn
		BNE	@found
		
		PLA
		TAY
		
		INY	
		CPY	screenBtnCnt
		BNE	@loop0
		
		JMP	@invalid

@found:
		PLA

		JSR	screenDoSelectBtn
		
@exit:
		RTS
		

;-------------------------------------------------------------------------------
screenDoCalcBtnRow:
;-------------------------------------------------------------------------------
		LDY	#BUTTON::pX1
		LDA	($A3), Y
		STA	game + GAME::varA	;X
		STA	game + GAME::varC
		
		LDY	#BUTTON::pY
		LDA	($A3), Y
		STA	game + GAME::varB	;Y
		
		LDY	#BUTTON::pX2
		LDA	($A3), Y
		
		SEC
		SBC	game + GAME::varC
		STA	game + GAME::varC	;Width

		RTS
		
		
;-------------------------------------------------------------------------------
screenDoCalcBtnPt:
;-------------------------------------------------------------------------------
		LDY	#BUTTON::pX1
		LDA	($A3), Y
		STA	game + GAME::varA	;X
		
		LDY	#BUTTON::pY
		LDA	($A3), Y
		STA	game + GAME::varB	;Y
		
		LDY	#BUTTON::fType
		LDA	($A3), Y
		CMP	#$0E
		BPL	@exit
		
		CMP	#$04
		BEQ	@exit
		
		INC	game + GAME::varA
		
		RTS
		
@exit:
		RTS
		

;-------------------------------------------------------------------------------
screenDoGetBtnColours:
;-------------------------------------------------------------------------------
		LDY	#BUTTON::fType
		LDA	($A3), Y
		BEQ	@regulardisb
		
		CMP	#$03
		BNE	@tstregenb
		
		JMP	@regular
		
@regulardisb:
		LDA	#$0B
		STA	game + GAME::varM
		LDA	#$0C
		STA	game + GAME::varN
		
		RTS

@tstregenb:
		CMP	#$01
		BNE	@tstclrvis
		
@regular:
		LDA	#$0F
		STA	game + GAME::varM
		LDA	#$01
		STA	game + GAME::varN
		
		RTS
		
@tstclrvis:
		CMP	#$0C
		BNE	@tstsimple
		
		LDY	#BUTTON::fColour
		LDA	($A3), Y
		STA	game + GAME::varM
		LDA	#$01
		STA	game + GAME::varN

		RTS
		
@tstsimple:
		CMP	#$0E
		BNE	@other
	
		LDA	#$0F
		STA	game + GAME::varM
		LDA	#$01
		STA	game + GAME::varN

		RTS

@other:
		LDA	#$01
		STA	game + GAME::varM
		LDA	#$01
		STA	game + GAME::varN

		RTS
		

;-------------------------------------------------------------------------------
screenDoGetHotColours:
;-------------------------------------------------------------------------------
		LDY	#BUTTON::fType
		LDA	($A3), Y
		BEQ	@regulardisb
		
		CMP	#$03
		BNE	@tstregenb
		
		JMP	@regular
		
@regulardisb:
		LDA	#$0F
		STA	game + GAME::varM
		LDA	#$0B
		STA	game + GAME::varN
		
		RTS

@tstregenb:
		CMP	#$01
		BNE	@tstclrvis
		
@regular:
		LDA	#$01
		STA	game + GAME::varM
		LDA	#$01
		STA	game + GAME::varN
		
		RTS
		
@tstclrvis:
		CMP	#$0C
		BNE	@other
		
		LDA	#$01
		STA	game + GAME::varM
		LDA	#$01
		STA	game + GAME::varN

		RTS
		
@other:
		LDA	#$01
		STA	game + GAME::varM
		LDA	#$01
		STA	game + GAME::varN

		RTS


;-------------------------------------------------------------------------------
screenHotButton:
;-------------------------------------------------------------------------------
		TAX
		LDA	buttonLo, X
		STA	$A3
		LDA	buttonHi, X
		STA	$A4
		
		JSR	screenDoGetHotColours
		
		LDY	#BUTTON::fType
		LDA	($A3), Y
						;0 = regular disabled 
						;1 = regular enabled
						;2 = regular hidden
						;3 = footer button
						;4 = single cell button
						;C = colour visible
						;D = colour hidden
						;E = Simple (trd sel dialog)
						;F = full screen

		CMP	#$02
		BEQ	@exit
		
		CMP	#$0D
		BEQ	@exit

		CMP	#$04
		BEQ	@dokeyind

;		Text is already or otherwise drawn.  Just need colours.
		JSR	screenDoCalcBtnRow
		
		LDX	game+GAME::varB
		JSR	screenSetColourPtr

		LDA	game + GAME::varM
		JSR	screenFillRowV

@dokeyind:
		JSR	screenDoCalcBtnPt
		
		LDX	game + GAME::varB	
		JSR	screenSetColourPtr

		LDA	game + GAME::varN
		LDY	#$00
		STA	($FB), Y
		
		LDY	#BUTTON::fType
		LDA	($A3), Y
		CMP	#$03
		BNE	@tstchars
		
		DEC	$FB			;***Naughty but works
		
		LDA	game + GAME::varN
		LDY	#$00
		STA	($FB), Y
		
@tstchars:
		LDY	#BUTTON::fType
		LDA	($A3), Y
		CMP	#$04
		BNE	@tstsimple
		
		LDX	game + GAME::varB	
		JSR	screenSetScreenPtr
		
		LDY	#$00
		LDA	($FB), Y
		AND	#$7F
		STA	($FB), Y
		
		RTS

		
@tstsimple:
		CMP	#$0E
		BNE	@exit

		LDX	game + GAME::varB	
		JSR	screenSetScreenPtr
		
		LDY	game + GAME::varC
		DEY
		BEQ	@exit
		
@loop:
		LDA	($FB), Y
		ORA	#$80
		STA	($FB), Y

		DEY
		BNE	@loop
		
@exit:
		RTS


;-------------------------------------------------------------------------------
screenDrawButton:
;-------------------------------------------------------------------------------
		TAX
		LDA	buttonLo, X
		STA	$A3
		LDA	buttonHi, X
		STA	$A4
		
		JSR	screenDoGetBtnColours
		
		LDY	#BUTTON::fType
		LDA	($A3), Y
						;0 = regular disabled 
						;1 = regular enabled
						;2 = regular hidden
						;3 = footer button
						;4 = single cell button
						;C = colour visible
						;D = colour hidden
						;E = Simple (trd sel dialog)
						;F = full screen

		CMP	#$02
		BEQ	@exit
		
		CMP	#$0D
		BEQ	@exit

		CMP	#$04
		BEQ	@dokeyind

;		Text is already or otherwise drawn.  Just need colours.
		JSR	screenDoCalcBtnRow
		
		LDX	game+GAME::varB
		JSR	screenSetColourPtr

		LDA	game + GAME::varM
		JSR	screenFillRowV

@dokeyind:
		JSR	screenDoCalcBtnPt
		
		LDX	game + GAME::varB	
		JSR	screenSetColourPtr

		LDA	game + GAME::varN
		LDY	#$00
		STA	($FB), Y
		
		LDY	#BUTTON::fType
		LDA	($A3), Y
		CMP	#$03
		BNE	@tstchars
		
		DEC	$FB			;***Naughty but works
		
		LDA	game + GAME::varN
		LDY	#$00
		STA	($FB), Y
		
@tstchars:
		LDY	#BUTTON::fType
		LDA	($A3), Y
		CMP	#$04
		BNE	@tstsimple
		
		LDX	game + GAME::varB	
		JSR	screenSetScreenPtr
		
		LDY	#$00
		LDA	($FB), Y
		ORA	#$80
		STA	($FB), Y
		
		RTS

		
@tstsimple:
		CMP	#$0E
		BNE	@exit

		LDX	game + GAME::varB	
		JSR	screenSetScreenPtr
		
		LDY	game + GAME::varC
		DEY
		BEQ	@exit
		
@loop:
		LDA	($FB), Y
		AND	#$7F
		STA	($FB), Y

		DEY
		BNE	@loop
		
@exit:
		RTS
		

;-------------------------------------------------------------------------------
screenPerformList:
;-------------------------------------------------------------------------------
		LDA	#$00
		STA	screenBtnSglSeen
		
		LDA	screenRedirectNull
		BEQ	@start
		
		RTS

@start:
		JSR	screenReadByte
		
		CMP	#$00
		BEQ	@exit
		
		TAX
		
		LSR
		LSR
		LSR
		LSR
		
@1:
		CMP	#$01
		BNE	@2

		JSR	screenFillRectM
		JMP	@start

@2:
		CMP	#$02
		BNE	@3

		JSR	screenFillColHM
		JMP	@start
		
@3:
		CMP	#$03
		BNE	@4

		JSR	screenFillColVM
		JMP	@start
		
@4:
		CMP	#$04
		BNE	@5

		JSR	screenFillLineHM
		JMP	@start

@5:
		CMP	#$05
		BNE	@6

		JSR	screenFillLineVM
		JMP	@start

@6:
		CMP	#$06
		BNE	@7

		JSR	screenFillPointsM
		JMP	@start
		
@7:
		CMP	#$07
		BNE	@8

		JSR	screenFillBrushM
		JMP	@start

@8:
		CMP	#$08
		BNE	@9

		JSR	screenFillPtClrM
		JMP	@start
		
@9:
		CMP	#$09
		BNE	@A

		JSR	screenFillTextM
		JMP	@start
		
@A:
		CMP	#$0A
		BNE	@exit
		
		JSR	screenFillButtonM
		JMP	@start
		
@exit:		
		RTS
	
	
;-------------------------------------------------------------------------------
screenReadByte:
;-------------------------------------------------------------------------------
		LDY	#$00
		LDA	($FD), Y
		
		INC	$FD
		BNE	@exit
		
		INC	$FE
		
@exit:
		RTS
		
		
;-------------------------------------------------------------------------------
screenReadBrush:
;-------------------------------------------------------------------------------
		LDY	#$00
		LDA	($A3), Y
		
		INC	$A3
		BNE	@exit
		
		INC	$A4
		
@exit:
		RTS
		
		
;-------------------------------------------------------------------------------
screenSetScreenPtr:
;-------------------------------------------------------------------------------
		LDA	screenRowsLo, X
		STA	$FB
		LDA	screenRowsHi, X
		STA	$FC
		
		CLC
		LDA	game+GAME::varA
		ADC	$FB
		
		BCC	@1
		
		INC	$FC
		
@1:
		STA	$FB

		RTS
		
		
;-------------------------------------------------------------------------------
screenSetColourPtr:
;-------------------------------------------------------------------------------
		LDA	colourRowsLo, X
		STA	$FB
		LDA	colourRowsHi, X
		STA	$FC
		
		CLC
		LDA	game+GAME::varA
		ADC	$FB
		
		BCC	@1
		
		INC	$FC
		
@1:
		STA	$FB

		RTS

;-------------------------------------------------------------------------------
screenFillBrushM:
;-------------------------------------------------------------------------------
		TXA
		AND	#$0F

		TAY
		LDA	brushesLo, Y
		STA	$A3
		LDA	brushesHi, Y
		STA	$A4
		
		JSR	screenReadBrush
		STA	game+GAME::varD
		JSR	screenReadBrush
		STA	game+GAME::varE
		
		JSR 	screenReadByte
		STA	game+GAME::varA
;		STA	game+GAME::varC
		JSR	screenReadByte
		STA	game+GAME::varB

		TAX

@loopRow:
		LDA	#$00
		STA	game + GAME::varF
		
		JSR	screenSetScreenPtr
		
@loopCol:
		JSR	screenReadBrush
		LDY	game + GAME::varF
		STA	($FB), Y
		
		INC	game + GAME::varF
		INY
		
		CPY	game + GAME::varD
		BNE	@loopCol
		
		INX

		DEC	game + GAME::varE
		BNE	@loopRow

@exit:
		RTS


;-------------------------------------------------------------------------------
screenFillPointsM:
;-------------------------------------------------------------------------------
		TXA
		AND	#$0F
		PHA
	
@loop:	
		JSR 	screenReadByte
		
		CMP	#$FF
		BEQ	@exit
		
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
		
		TAX

		JSR	screenSetScreenPtr
		
		PLA
		PHA
		
		TAY
		LDA	pointCodes, Y
		
		LDY	#$00
		STA	($FB), Y
		
		JMP	@loop
		
@exit:
		PLA
		
		RTS
		

;-------------------------------------------------------------------------------
screenFillPtClrM:
;-------------------------------------------------------------------------------
		TXA
		AND	#$0F
		PHA

		JSR 	screenReadByte
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
		
		TAX

		JSR	screenSetColourPtr

		PLA
		LDY	#$00
		STA	($FB), Y

		RTS
		
		
;-------------------------------------------------------------------------------
screenFillTextM:
;-------------------------------------------------------------------------------
		JSR 	screenReadByte
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
		
		TAX
		JSR	screenSetScreenPtr

		JSR 	screenReadByte
		STA	$A7
		JSR	screenReadByte
		STA	$A8
		
		LDY	#$00		
		LDA	($A7), Y
		
		TAY
		
		INC	$A7
		BNE	@cont
	
		INC	$A8

@cont:
		CPY	#$00
		BNE	@begin
		
		RTS
		
@begin:
		DEY
		
@loop:
		LDA	($A7), Y
		STA	($FB), Y
		DEY
		BPL	@loop

		RTS


;-------------------------------------------------------------------------------
screenFillButtonM:
;-------------------------------------------------------------------------------
		TXA
		AND	#$0F
		PHA

		LDA	screenBtnCnt
		ASL
		ASL
		ASL
		TAX
		
		PLA
		STA	button0, X		;fType
						;0 = regular disabled 
						;1 = regular enabled
						;2 = regular hidden
						;3 = footer
						;4 = single
						;C = colour visible
						;D = colour hidden
						;E = Simple (trd sel dialog)
						;F = full screen

		STA	game + GAME::varA

		CMP	#$04
		BNE	@begin
		
		LDA	screenBtnSglSeen
		BNE	@begin
		
		LDA	#$01
		STA	screenBtnSglSeen
		
		LDA	screenBtnCnt
		STA	screenBtnSglStart
		
@begin:
		JSR 	screenReadByte
		INX
		STA	button0, X		;pY
		
		JSR 	screenReadByte
		INX
		STA	button0, X		;pX1
		
		JSR 	screenReadByte
		INX
		STA	button0, X		;pX2
		
		LDA	#$00
		INX
		STA	button0, X
		INX
		STA	button0, X		;wResv
		INX

		LDA	game + GAME::varA
		CMP	#$0C
		BEQ	@doColour
		
		CMP	#$0D
		BEQ	@doColour
		
		LDA	#$00
		STA	button0, X		;fColour (none)
		
		JMP	@getKey
		
@doColour:
		JSR	screenReadByte
		STA	button0, X		;fColour

@getKey:
		INX
		
		JSR	screenReadByte
		STA	button0, X		;cKey
		INX

		LDX	screenBtnCnt
		INX

		LDA	buttonLo, X
		STA	$50
		LDA	buttonHi, X
		STA	$51

		LDY	#BUTTON::fType

		LDA	#$FF
		STA	($50), Y		;fType

		LDA	game + GAME::varA
		CMP	#$02
		BEQ	@skipText
		
		CMP	#$0D
		BEQ	@skipText

		JSR	screenFillTextM
		JMP	@cont
		
@skipText:
		JSR	screenReadByte
		JSR	screenReadByte
		JSR	screenReadByte
		JSR	screenReadByte

@cont:
		LDA	screenBtnCnt
		INC	screenBtnCnt
		
		JSR 	screenDrawButton

		RTS


;-------------------------------------------------------------------------------
screenFillColHM:
;-------------------------------------------------------------------------------
		TXA
		AND	#$0F
		PHA
		
		JSR 	screenReadByte
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
		JSR 	screenReadByte
		STA	game+GAME::varC

		LDA	game+GAME::varB
		TAX

		JSR	screenSetColourPtr

		PLA
		JSR	screenFillRowV
		
screenFillColHMExit:
		RTS


;-------------------------------------------------------------------------------
;screenFillColVM
;-------------------------------------------------------------------------------
screenFillColVM:
		TXA
		AND	#$0F
		PHA
		
		JSR 	screenReadByte
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
;		STA	game+GAME::varG
		
		LDA	#$01
;		STA	game+GAME::varC
		STA	game+GAME::varE

		JSR	screenReadByte
		STA	game+GAME::varD
;		STA	game+GAME::varF
		
screenFillColVMRow:
		LDA 	game+GAME::varB
		TAX
		INC	game+GAME::varB

		LDA	game+GAME::varE
		STA	game+GAME::varC

		JSR	screenSetColourPtr

		PLA
		PHA
		
		JSR	screenFillRowV

		DEC	game+GAME::varD
		BNE	screenFillColVMRow
		
;		JMP	screenFillColVMRow
		
screenFillColVMExit:		
		PLA

		RTS
		
;-------------------------------------------------------------------------------
;screenFillLineHM
;-------------------------------------------------------------------------------
screenFillLineHM:
		TXA
		AND	#$0F
		PHA
		
		JSR 	screenReadByte
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
		JSR 	screenReadByte
		STA	game+GAME::varC

		LDA	game+GAME::varB
		TAX

		JSR	screenSetScreenPtr

		PLA
		TAY
		LDA	lineCodes, Y
		
		JSR	screenFillRowV
		
		RTS
	
;-------------------------------------------------------------------------------
;screenFillLineVM
;-------------------------------------------------------------------------------
screenFillLineVM:
		TXA
		AND	#$0F
		PHA
		
		JSR 	screenReadByte
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
;		STA	game+GAME::varG
		
		LDA	#$01
;		STA	game+GAME::varC
		STA	game+GAME::varE

		JSR	screenReadByte
		STA	game+GAME::varD
;		STA	game+GAME::varF
		
screenFillLineVMRow:
		LDA 	game+GAME::varB
		TAX
		INC	game+GAME::varB

		LDA	game+GAME::varE
		STA	game+GAME::varC

		JSR	screenSetScreenPtr

		PLA
		PHA
		
		TAY
		LDA	lineCodes, Y
		
		JSR	screenFillRowV

		DEC	game+GAME::varD
		BNE	screenFillLineVMRow
		
;		JMP	screenFillLineVMRow
		
screenFillLineVMExit:		
		PLA

		RTS
	
;-------------------------------------------------------------------------------
;screenFillRectM
;-------------------------------------------------------------------------------
screenFillRectM:
		TXA
		AND	#$0F
		PHA
		
		JSR 	screenReadByte
		STA	game+GAME::varA
		JSR	screenReadByte
		STA	game+GAME::varB
		STA	game+GAME::varG
		JSR 	screenReadByte
;		STA	game+GAME::varC
		STA	game+GAME::varE
		JSR	screenReadByte
		STA	game+GAME::varD
		STA	game+GAME::varF
		
screenFillRMChrRow:
		LDA 	game+GAME::varB
		TAX
		INC	game+GAME::varB

		LDA	game+GAME::varE
		STA	game+GAME::varC

		JSR	screenSetScreenPtr

		PLA
		PHA
		
		BEQ	@2
		
		CMP	#$02
		BPL	@2
		
		LDA	#$20
		BNE	@3
@2:
		LDA	#$A0
@3:
		JSR	screenFillRowV
		
		DEC	game+GAME::varD
		BNE	screenFillRMChrRow

;		JMP	screenFillRMChrRow
		
screenFillRMNext:		
		LDA	game+GAME::varF
		STA	game+GAME::varD

		LDA	game+GAME::varG
		STA	game+GAME::varB

screenFillRMColRow:
		LDA	game+GAME::varB
		TAX
		INC	game+GAME::varB

		LDA	game+GAME::varE
		STA	game+GAME::varC

		JSR	screenSetColourPtr

		PLA
		PHA
		
		BEQ	@2
		
		CMP	#$03
		BNE	@0
		
		LDA	#$0F
		BNE	@3
		
@0:
		CMP	#$02
		BNE	@1
		
		LDA	#$0C
		BNE	@3
@1:
;		LDA	#$01
;		BNE	@3
		JMP	screenFillRMExit
@2:
		LDA	#$03
@3:
		JSR	screenFillRowV
		
		DEC	game+GAME::varD
		BNE	screenFillRMColRow

;		JMP	screenFillRMColRow
		
screenFillRMExit:
		PLA
		
		RTS
		
		
;-------------------------------------------------------------------------------
;screenFillRowV
;-------------------------------------------------------------------------------
screenFillRowV:
		LDY	#$00
@1:
		STA 	($FB), Y
		INY
		CPY	game+GAME::varC
;		BEQ	screenFillRowVExit
		BNE 	@1
		
screenFillRowVExit:
		RTS
		
	
;-------------------------------------------------------------------------------
;screen data
;-------------------------------------------------------------------------------
lineCodes:
			.byte	$EA, $EF, $F4, $F7
			.byte	$FF, $A0, $6C, $7E
			.byte	$20, $6A, $77, $E7
			.byte	$D0
			
pointCodes:
			.byte	$CF, $D0, $CC, $FA
			.byte 	$A0, $B1, $B2, $B3
			.byte	$B4, $88, $20, $F7
			.byte	$E7, $D7
			
screenClear0:
			.byte	$11, $00, $00, $28, $19
			.byte	$00

screenQErase0:
;			.byte	$58, $00, $00, $06
			.byte	$58, $12, $00, $07
			.byte	$11, $13, $15, $15, $04
			.byte	$00
			
			
;-------------------------------------------------------------------------------
;square face brushes
;-------------------------------------------------------------------------------
brushRailroad0:		
			.byte 	$02, $02
			.byte	$E2, $7E
			.byte	$D7, $D7
brushChanceH1:
			.byte	$03, $01 
			.byte	$BF, $BF, $BF
			
brushTaxH2:
			.byte	$03, $01 
			.byte	$94, $81, $98

brushTaxV3:
			.byte	$01, $03
			.byte	$94
			.byte	$81
			.byte	$98
			
brushChestV4:	
			.byte	$01, $03
			.byte	$5C
			.byte	$66
			.byte	$FE

brushGo5:
			.byte	$03, $02
			.byte	$A0, $87, $8F
			.byte	$9F, $C3, $C3
			
brushElectric6:		
			.byte	$03, $01
			.byte	$CE, $CD, $CE
			
brushChanceV7:
			.byte	$01, $03
			.byte	$BF
			.byte	$BF
			.byte	$BF
			
brushChestH8:	
			.byte	$03, $01
			.byte	$EC, $66, $68

brushParking9:
			.byte	$03, $03
			.byte	$D5, $C3, $C9
			.byte	$D7, $68, $D7
			.byte	$6C, $62, $7B
			
brushWaterA:
			.byte	$02, $03
			.byte	$A0, $EF
			.byte	$D5, $DB
			.byte	$A0, $DD
			
brushInGaolB:
			.byte	$03, $03
			.byte	$DD, $DD, $DD
			.byte	$DD, $DD, $DD
			.byte	$ED, $F1, $F1

brushGoGaolC:
			.byte   $04, $03
			.byte	$F0, $F2, $C0, $C9
			.byte	$FC, $7C, $7F, $C2
			.byte	$A0, $FC, $C0, $CB
			
brushesLo:
			.byte	<brushRailroad0, <brushChanceH1, <brushTaxH2
			.byte	<brushTaxV3, <brushChestV4, <brushGo5
			.byte	<brushElectric6, <brushChanceV7, <brushChestH8
			.byte	<brushParking9, <brushWaterA, <brushInGaolB
			.byte	<brushGoGaolC
brushesHi:
			.byte	>brushRailroad0, >brushChanceH1, >brushTaxH2
			.byte	>brushTaxV3, >brushChestV4, >brushGo5
			.byte	>brushElectric6, >brushChanceV7, >brushChestH8
			.byte	>brushParking9, >brushWaterA, >brushInGaolB
			.byte	>brushGoGaolC


;==============================================================================
;FOR PLAYER.S
;==============================================================================

	.struct	IRQGLOBS
		instld	.byte
;		vector	.word
		saveA	.byte
		saveB	.byte
		saveC	.byte
		saveD	.byte
		saveE	.byte
		brd0X	.byte
		brd0Y	.byte
		brd1X	.byte
		brd1Y	.byte
		brd2X	.byte
		brd2Y	.byte
		brd3Y	.byte
		brd3X	.byte
		brd4X	.byte
		brd4Y	.byte
		brd5X	.byte
		brd5Y	.byte
		brdMX	.byte
		savMX	.byte
		min0X	.byte
		min0Y	.byte
		min1X	.byte
		min1Y	.byte
		min2X	.byte
		min2Y	.byte
		min3X	.byte
		min3Y	.byte
		min4X	.byte
		min4Y	.byte
		min5X	.byte
		min5Y	.byte
		varA	.byte
		varB	.byte
		varC	.byte
		varD	.byte
		varE	.byte
		varF	.byte
		varG	.byte
		varH	.byte
		minPlr	.byte
		minIdx	.byte
		minFlg	.byte
		keyDly	.byte
	.endstruct


irqglob:	.tag	IRQGLOBS
irqBlinkSeq0:
		.byte	$00, $00, $0C, $0C, $0F, $0F, $01, $01, $0F, $0F, $0C, $0C



;-------------------------------------------------------------------------------
installPlyr:
;-------------------------------------------------------------------------------
		LDA	irqglob + IRQGLOBS::instld
		CMP	#$01
		BEQ	@exit

		LDA	#<plyrIRQ		;install our handler
		STA	cpuIRQ
		LDA	#>plyrIRQ
		STA	cpuIRQ + 1

		LDA	#<plyrNOP		;install our handler
		STA	cpuRESET
		LDA	#>plyrNOP
		STA	cpuRESET + 1

		LDA	#<plyrNOP		;install our handler
		STA	cpuNMI
		LDA	#>plyrNOP
		STA	cpuNMI + 1


		LDA	#%01111111		;We'll always want rasters
		AND	vicCtrlReg		;    less than $0100
		STA	vicCtrlReg
		
;***FIXME: 	This will have to be higher (lower value) in order to prevent
;		the mouse from tearing.  Need to change IRQ handler, too.  Don't
;		want it too high to allow for as much time in lowest IRQ phase 
;		as possible.  Some experimentation may be required.
		LDA	#$32			;Initial raster interrupt pos
		STA	vicRstrVal
		
		LDA	#$01			;Enable raster irqs
		STA	vicIRQMask
		
		LDA	#$01			;flag installed irq handler
		STA	irqglob + IRQGLOBS::instld

@exit:
		RTS
		

;-------------------------------------------------------------------------------
plyrNOP:
;-------------------------------------------------------------------------------
		RTI


;-------------------------------------------------------------------------------
plyrIRQ:
;-------------------------------------------------------------------------------
;***TODO:		Should use self-patching in IRQ routine.  Use RAM!
;***FIXME:		Perhaps way it does so much testing is reason for 
;			occassional failure?
;***FIXME:		Don't do third interrupt?  Process its code after
;			second?

		PHP				;save the initial state
		PHA
		TXA				;de This is done in the kernal
		PHA
		TYA
		PHA

		CLD
		
;***FIXME:	I've decided that the overhead is really quite huge.  I need to 
;	refactor this routine so that it is more efficient on time consumption.  
;	I'm having to share the same zero page addresses with the front end??

	.if	DEBUG_IRQ
		LDA	vicBrdrClr
		STA	irqglob + IRQGLOBS::saveE
		
		LDA	#$04
		STA	vicBrdrClr
	.endif
	
		LDA	vicIRQFlgs
		AND	#$01
		BNE	@1
		
		JMP 	@done
		
@1:
		LDA	$FB
		STA	irqglob + IRQGLOBS::saveA
		LDA	$FC
		STA	irqglob + IRQGLOBS::saveB
		LDA	$FD
		STA	irqglob + IRQGLOBS::saveC
		LDA	$FE
		STA	irqglob + IRQGLOBS::saveD
		
		LDA	vicRstrVal
		
		CMP	#$D7
		BCS	@2

		JSR	plyrCheckStepping	;Do these early.  Should be
		LDA	ui + UI::fMseEnb	;fairly consistent.
		BEQ	@tstjoystick
		
		JSR	plyrProcessMouse
;		JMP	@procsound		;Don't skip the joystick even
						;though I don't like it, it will
						;only ever happen all the time
						;at the start
		
@tstjoystick:
		LDA	ui + UI::fJskEnb
		BEQ	@procsound
		
		JSR	plyrProcessJoystick
		
@procsound:
	.if	DEBUG_IRQ
		LDA	#$00
		STA	vicBrdrClr
	.endif
	
		JSR	SNDBASE + 3		;Call sound driver
		
	.if	DEBUG_IRQ
		LDA	#$0D
		STA	vicBrdrClr
	.endif
	
		
		LDA	game + GAME::sig	;Don't process the mouse click
		BNE	@skipThis		;or keys if the FrontEnd is busy
;
	.if	DEBUG_IRQ
		LDA	#$02
		STA	vicBrdrClr
	.endif
	
		JSR	keyDequeueKeys

	.if 	DEBUG_CPU
	.else
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::fCPU
		LDA	($FB), Y
		BNE	@skipJstk
	.endif

		JSR	keyScanKey

		LDA	ui + UI::fMseEnb	
		BEQ	@skipMouse
		
		LDA	#$01
		JSR	handleMouse
		
		LDA	ButtonLClick
		BEQ	@skipMouse
		
		JSR	handleMouseClick
	
@skipMouse:
		LDA	ui + UI::fJskEnb
		BEQ	@skipJstk

		JSR	handleJoystick

@skipJstk:
		JSR	handleKeys

		JSR	handleHotBlink

@skipThis:
		LDA	#$00			;IRQ done now and not busy until
		STA	game + GAME::lock	;last phase
							
		LDA	#$D7
		STA	irqglob + IRQGLOBS::varA
		
		JMP	@finish
				
@2:
		CMP	#$FA
		BCC	@miniPrep
		
		LDA	#$01			;IRQ becomes busy for a few 
		STA	game + GAME::lock	;passes...
		
		
;dengland
;***FIXME:	It just becomes a hacked mess from here on.

		
		LDA	#$21
		STA	irqglob + IRQGLOBS::varA
	.if	DEBUG_IRQ
		LDA	#$01
	.endif
		LDY	#$00
		JMP	@begin
				
@miniPrep:
		LDA	#$22
		STA	irqglob + IRQGLOBS::varA
	.if	DEBUG_IRQ
		LDA	#$0A
	.endif
		LDY	#$01
		
@begin:
	.if	DEBUG_IRQ
		STA	vicBrdrClr		;set screen colours
	.endif

		LDX	#$00			;Init sprite ptrs
		LDA	irqglob + IRQGLOBS::varA

@loop0:
		STA	spritePtr1, X
		
		INX
		CPX	#$06
		BNE	@loop0

		CPY	#$01
		BEQ	@miniMap
 	
		JSR	plyrDisplay
		
	.if	DEBUG_IRQ
		LDA	#$00
		STA	vicBrdrClr
	.endif
	
		LDX	#$0B
@loop1:
		LDA	irqglob + IRQGLOBS::brd0X, X
		STA	vicSprPos1, X
		DEX
		BPL	@loop1
		
		LDA	irqglob + IRQGLOBS::brdMX
		AND	#$7E
		ORA	irqglob + IRQGLOBS::savMX
		STA	vicSprPosM
		
		LDA	#$32
		STA	irqglob + IRQGLOBS::varA

		JMP	@finish
		
@miniMap:
		LDX	#$0B
@loop2:
		LDA	irqglob + IRQGLOBS::min0X, X
		STA	vicSprPos1, X
		DEX
		BPL	@loop2
		
		JSR	plyrMinimapBlink
		
		LDA	vicSprPosM
		ORA	#$FE
		STA	vicSprPosM

		LDA	#$FA
		STA	irqglob + IRQGLOBS::varA

@finish:
	.if	DEBUG_IRQ
		LDA	#$06
		STA	vicBrdrClr
	.endif
	
		LDA	irqglob + IRQGLOBS::saveA
		STA	$FB
		LDA	irqglob + IRQGLOBS::saveB
		STA	$FC
		LDA	irqglob + IRQGLOBS::saveC
		STA	$FD
		LDA	irqglob + IRQGLOBS::saveD
		STA	$FE

		LDA	irqglob + IRQGLOBS::varA
		STA	vicRstrVal

		ASL	vicIRQFlgs

	.if	DEBUG_IRQ
						;Restore colour
		LDA  	irqglob + IRQGLOBS::saveE	
		STA	vicBrdrClr
	.endif

@done:
		PLA             
		TAY             
		PLA             
		TAX             
		PLA             
		
		PLP

		RTI


;-------------------------------------------------------------------------------
plyrCheckStepping:
;-------------------------------------------------------------------------------
		LDA	game + GAME::gMode	;If in trade selection mode
		CMP	#$07				
		BEQ	@tstsig
		
		LDA	game + GAME::gMode	;If in trade stepping mode
		CMP	#$08				
		BEQ	@tstsig

		LDA	game + GAME::fAmStep	;Or square stepping?
		BNE	@tstsig
		
		RTS				;No - do nothing.
		
@tstsig:
		LDA	game + GAME::fStpSig	;Yes, check not already
		BEQ	@proc			;signalled and waiting
		
		RTS				;It is, so do nothing
		
@proc:
		DEC	game + GAME::iStpCnt	;Its not so count down...
		LDX	game + GAME::iStpCnt	;Reached the end?
		BNE	@exit			;No, done.
	
		LDA	#$01			;Yes, signal and reset
		STA	game + GAME::fStpSig
		
		LDA	game + GAME::gMode	;If in trade stepping mode
		CMP	#$08				
		BEQ	@longwhile
		
		LDA	#$11
		STA	game + GAME::iStpCnt
		
		RTS
		
@longwhile:
		LDA	#$60
		STA	game + GAME::iStpCnt

@exit:
		RTS


;-------------------------------------------------------------------------------
;Mouse driver variables
;-------------------------------------------------------------------------------
OldPotX:        
	.byte    	0               	;Old hw counter values
OldPotY:        
	.byte    	0

XPos:           
	.word    	0               	;Current mouse position, X
YPos:           
	.word    	0               	;Current mouse position, Y
XMin:           
	.word    	0               	;X1 value of bounding box
YMin:           
	.word    	0               	;Y1 value of bounding box
XMax:           
	.word    	319               	;X2 value of bounding box
YMax:           
	.word    	199           		;Y2 value of bounding box
	
JoyUp:
	.byte		$00
JoyDown:
	.byte		$00
JoyLeft:
	.byte		$00
JoyRight:
	.byte		$00
JoyButton:
	.byte		$00
JoyUsed:
	.byte		$00
ButtonJClick:
	.byte		$00
	
Buttons:        
	.byte    	0               	;button status bits
ButtonsOld:
	.byte		0
ButtonLClick:
	.byte		0
ButtonRClick:
	.byte		0
MouseUsed:
	.byte		$00

OldValue:       
	.byte    	0               	;Temp for MoveCheck routine
NewValue:       
	.byte    	0               	;Temp for MoveCheck routine

tempValue:	
	.word		0



;-------------------------------------------------------------------------------
plyrProcessJoystick:
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

		LDA	ui + UI::fJskAck
		BEQ	@proc
	
		RTS
		
@proc:
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

		LDX     #$00
		
		STX	JoyUp
		STX	JoyDown
		STX	JoyLeft
		STX	JoyRight
		STX	ButtonJClick
		
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
		
		BIT	$31			;I want them to let go of stick
		BNE	@isButton		;and button (after pressing it)
						;in order to form a click
		CMP	#$00
		BEQ	@tstClick	
		
		RTS
		
@tstClick:
		LDA	JoyButton
		BNE	@doClick
		
		RTS
		
@doClick:
		STX	ButtonJClick
		STX	JoyUsed
		STX	ui + UI::fJskAck
		
		LDA	#$00
		STA	JoyButton
		RTS
		
@isUp:
		STX	JoyUp
		STX	ui + UI::fJskAck
		
		RTS
		
@isDown:
		STX	JoyDown
		STX	ui + UI::fJskAck
		
		RTS
		
@isLeft:
		STX	JoyLeft
		STX	ui + UI::fJskAck
		
		RTS
		
@isRight:
		STX	JoyRight
		STX	ui + UI::fJskAck
		
		RTS
		
@isButton:
		STX	JoyButton
		
		RTS
		

;-------------------------------------------------------------------------------
;plyrProcessMouse
;-------------------------------------------------------------------------------
plyrProcessMouse:
		LDA	#$00
		STA	mouseCheck
		
		LDY     #%00000000              ;Set ports A and B to input
		STY     CIA1_DDRB
		STY     CIA1_DDRA               ;Keyboard won't look like mouse
		LDA     CIA1_PRB                ;Read Control-Port 1
		DEC     CIA1_DDRA               ;Set port A back to output
		EOR     #%11111111              ;Bit goes up when button goes down
		STA     Buttons
		BEQ     @L0                     ;(bze)
		DEC     CIA1_DDRB               ;Mouse won't look like keyboard
		STY     CIA1_PRB                ;Set "all keys pushed"

@L0:    
		JSR	ButtonCheck
		
		LDA     SID_ADConv1             ;Get mouse X movement
		LDY     OldPotX
		JSR     MoveCheck               ;Calculate movement vector

; Skip processing if nothing has changed

		BCC     @SkipX
		STY     OldPotX

; Calculate the new X coordinate (--> a/y)

		CLC
		ADC	XPos

		TAY                             ;Remember low byte
		TXA
		ADC     XPos+1
		TAX

; Limit the X coordinate to the bounding box

		CPY     XMin
		SBC     XMin+1
		BPL     @L1
		LDY     XMin
		LDX     XMin+1
		JMP     @L2
@L1:    	
		TXA

		CPY     XMax
		SBC     XMax+1
		BMI     @L2
		LDY     XMax
		LDX     XMax+1
@L2:    
		STY     XPos
		STX     XPos+1

; Move the mouse pointer to the new X pos

		TYA
		JSR     CMOVEX
		
		LDA	#$01
		STA	mouseCheck

; Calculate the Y movement vector

@SkipX: 
		LDA     SID_ADConv2             ;Get mouse Y movement
		LDY     OldPotY
		JSR     MoveCheck               ;Calculate movement

; Skip processing if nothing has changed

		BCC     @SkipY
		STY     OldPotY

; Calculate the new Y coordinate (--> a/y)

		STA     OldValue
		LDA     YPos
		SEC
		SBC	OldValue

		TAY
		STX     OldValue
		LDA     YPos+1
		SBC     OldValue
		TAX

; Limit the Y coordinate to the bounding box

		CPY     YMin
		SBC     YMin+1
		BPL     @L3
		LDY     YMin
		LDX     YMin+1
		JMP     @L4
@L3:    
		TXA

		CPY     YMax
		SBC     YMax+1
		BMI     @L4
		LDY     YMax
		LDX     YMax+1
@L4:    	
		STY     YPos
		STX     YPos+1

; Move the mouse pointer to the new Y pos

		TYA
		JSR     CMOVEY
		
		LDA	#$01
		STA	mouseCheck

; Done

@SkipY: 
;		JSR     CDRAW

;dengland:	What is this for???
		CLC                             ;Interrupt not "handled"

		RTS
		

;-------------------------------------------------------------------------------
MoveCheck:
; Move check routine, called for both coordinates.
;
; Entry:        y = old value of pot register
;               a = current value of pot register
; Exit:         y = value to use for old value
;               x/a = delta value for position
;-------------------------------------------------------------------------------
;***FIXME:	Are you supposed to mask out certain bits (lowest?) in order to
;		correct for jitter?  A real mouse isn't synced to the C64 like 
;		it should be or tries to be...

		STY     OldValue
		STA     NewValue
		LDX     #$00

		SEC				; a = mod64 (new - old)
		SBC	OldValue

		AND     #%01111111
		CMP     #%01000000              ; if (a > 0)
		BCS     @L1                     ;
		LSR                             ;   a /= 2;
		BEQ     @L2                     ;   if (a != 0)
		LDY     NewValue                ;     y = NewValue
		SEC
		RTS                             ;   return

@L1:    
		ORA     #%11000000              ; else, "or" in high-order bits
		CMP     #$FF                    ; if (a != -1)
		BEQ     @L2
		SEC
		ROR                             ;   a /= 2
		DEX                             ;   high byte = -1 (X = $FF)
		LDY     NewValue
		SEC
		RTS

@L2:    
		TXA                             ; A = $00
		CLC
		RTS


;-------------------------------------------------------------------------------
ButtonCheck:
;-------------------------------------------------------------------------------
		LDA	Buttons			;Buttons still the same as last
		CMP	ButtonsOld		;time?
		BEQ	@done			;Yes - don't do anything here
		
		PHA
		LDA	#$01
		STA	MouseUsed
		PLA
		
		AND	#buttonLeft		;No - Is left button down?
		BNE	@testRight		;Yes - test right
		
		LDA	ButtonsOld		;No, but was it last time?
		AND	#buttonLeft
		BEQ	@testRight		;No - test right
		
		LDA	#$01			;Yes - flag have left click
		STA	ButtonLClick
		
@testRight:
		AND	#buttonRight		;Is right button down?
		BNE	@done			;Yes - don't do anything here
		
		LDA	ButtonsOld		;No, but was it last time?
		AND	#buttonRight
		BEQ	@done			;No - don't do anything here
		
		LDA	#$01			;Yes - flag have right click
		STA	ButtonRClick

@done:
		LDA	Buttons			;Store the current state
		STA	ButtonsOld
		RTS


;-------------------------------------------------------------------------------
CMOVEX:
;-------------------------------------------------------------------------------
		CLC
		LDA	XPos
		ADC	#offsX
		STA	tempValue
		LDA	XPos + 1
		ADC	#$00
		STA	tempValue + 1
	
		LDA	tempValue
		STA	VICXPOS
		LDA	tempValue + 1
		CMP	#$00
		BEQ	@unset
	
		LDA	VICXPOSMSB
		ORA	#$01
		STA	VICXPOSMSB
		RTS
	
@unset:
		LDA	VICXPOSMSB
		AND	#$FE
		STA	VICXPOSMSB
		RTS
	
;-------------------------------------------------------------------------------
CMOVEY:
;-------------------------------------------------------------------------------
		CLC
		LDA	YPos
		ADC	#offsY
		STA	tempValue
		LDA	YPos + 1
		ADC	#$00
		STA	tempValue + 1
	
		LDA	tempValue
		STA	VICYPOS
	
		RTS


;-------------------------------------------------------------------------------
;handleKeyInput
;-------------------------------------------------------------------------------
handleKeyInput:
		LDY	keyBuffer0		;copy kernal code for input key
		LDX	#$00
@loop:
		LDA	keyBuffer0 + 1, X
		STA	keyBuffer0, X
		INX
		CPX	keyZPKeyCount
		BNE	@loop
		
		DEC	keyZPKeyCount
		TYA
;		CLI				;NO!  Causes problem for IRQ
		CLC
		RTS

;-------------------------------------------------------------------------------
;handleKeys
;-------------------------------------------------------------------------------
handleKeys:
						;We have a pretty waiting
						;indicator.  Count down to update.
		DEC	irqglob + IRQGLOBS::keyDly	
		BPL	@cont
		
		LDA	#$03
		STA	irqglob + IRQGLOBS::keyDly
		
@begin:
		LDA	game + GAME::aWai	;Get address for indicator
		STA	$FB
		LDA	game + GAME::aWai + 1
		STA	$FC
		LDY 	#$00

		LDA	sidV2EnvOu		;Get a random value for its
						;colour
		STA	vicSprClr0		;Set the colour of the mouse
						;pointer, too

		LDX	game + GAME::kWai	;Displaying indicator?
		BEQ	@cont			;No - continue with keys

		STA	($FB), Y		;Yes - update colour of indicator
		
@cont:
		LDA	keyZPKeyCount		;copy kernal code for get key
		BNE	@1
		RTS
		
@1:
		JSR	handleKeyInput		;Do the key fetch
		PHA				;save pressed key
		
		LDA	game + GAME::dlgVis	;Is a dialog visible?
		BNE	@dialog			;Yes - pass keys to it
		
		PLA				;No - pass keys to menu
		JMP	(menuActivePage0 + MENUPAGE::aKeys)
		
@dialog:	
		LDA	#$00
		STA	keyZPKeyCount

		PLA				;Pass keys to dialog
		JMP	(dialogKeyHandler)
		

;-------------------------------------------------------------------------------
handleHotBlink:
;-------------------------------------------------------------------------------
		LDA	ui + UI::fBtUpd1
		CMP	#$FF
		BEQ	@test
		
		RTS
		
@test:
		LDA	ui + UI::cHotDly
		BEQ	@proc

		DEC	ui + UI::cHotDly
		RTS
		
@proc:
		LDA	#$1B
		STA	ui + UI::cHotDly
		
		LDA	ui + UI::iSelBtn
		CMP	#$FF
		BNE	@update
	
		RTS

@update:
		STA	ui + UI::fBtUpd1
		LDA	ui + UI::fHotSta
		STA	ui + UI::fBtSta1
		
		EOR	#$01
		STA	ui + UI::fHotSta
		
		RTS


doHandleJstkSinglesUp:
		LDA	$34
		CMP	screenBtnSglStart
		BPL	@chkleft
		
@frombottom:
		TAX				;***FIXME What is faster?
		DEX
		DEX
		DEX
		TXA
		STA	ui + UI::iSelBtn
		JSR	handleJoystickUpdateUI
		
		LDA	#$01
		RTS
		
@chkleft:
		LDX	screenBtnSglStart
		INX
		INX
		INX
		STX	$4F
		CMP	$4F
		BPL	@frombottom
		
		LDA	screenBtnSglStart
		STA	ui + UI::iSelBtn
		
		LDA	#$00
		STA	ui + UI::fSelSgl
		RTS
		
		
doHandleJstkSinglesDown:
		LDA	$34
		LDX	screenBtnSglStart
		INX
		INX
		INX
		STX	$4F
		CMP	$4F
		BPL	@frombottom
		
@fromtop:
		TAX				;***FIXME What is faster?
		INX
		INX
		INX
		TXA
		STA	ui + UI::iSelBtn
		JSR	handleJoystickUpdateUI
		
		LDA	#$01
		RTS
		
@frombottom:
		CLC
		LDA	screenBtnSglStart
		ADC	#$05
		STA	ui + UI::iSelBtn
		
		LDA	#$00
		STA	ui + UI::fSelSgl
		RTS


doHandleJstkSinglesLeft:
		LDA	$34
		LDX	screenBtnSglStart
		STX	$4F
		CMP	$4F
		BNE	@tst1
		
		LDA	#$02
		JMP	@update

@tst1:
		INC	$4F
		CMP	$4F
		BNE	@tst2
		
		LDA	#$00
		JMP	@update

@tst2:
		INC	$4F
		CMP	$4F
		BNE	@tst3
		
		LDA	#$01
		JMP	@update

@tst3:
		INC	$4F
		CMP	$4F
		BNE	@tst4
		
		LDA	#$05
		JMP	@update
		
@tst4:
		INC	$4F
		CMP	$4F
		BNE	@5
		
		LDA	#$03
		JMP	@update
		
@5:
		LDA	#$04
		
@update:
		CLC
		ADC	screenBtnSglStart
		STA	ui + UI::iSelBtn
		RTS



doHandleJstkSinglesRight:
		LDA	$34
		LDX	screenBtnSglStart
		STX	$4F
		CMP	$4F
		BNE	@tst1
		
		LDA	#$01
		JMP	@update

@tst1:
		INC	$4F
		CMP	$4F
		BNE	@tst2
		
		LDA	#$02
		JMP	@update

@tst2:
		INC	$4F
		CMP	$4F
		BNE	@tst3
		
		LDA	#$00
		JMP	@update

@tst3:
		INC	$4F
		CMP	$4F
		BNE	@tst4
		
		LDA	#$04
		JMP	@update
		
@tst4:
		INC	$4F
		CMP	$4F
		BNE	@5
		
		LDA	#$05
		JMP	@update
		
@5:
		LDA	#$03
		
@update:
		CLC
		ADC	screenBtnSglStart
		STA	ui + UI::iSelBtn
		RTS


;-------------------------------------------------------------------------------
handleJoystick:
;-------------------------------------------------------------------------------
		LDA	ui + UI::cJskDly
		BEQ	@proc
		
		LDA	ui + UI::fJskAck
		BEQ	@done

		DEC	ui + UI::cJskDly
		
@done:
		RTS

@proc:
		LDA	ui + UI::fJskAck
		BEQ	@done
		
		LDA	ui + UI::cJskSns
		STA	ui + UI::cJskDly

		LDA	#$00
		STA	ui + UI::fJskAck
		
		LDA	ui + UI::iSelBtn
		STA	$34
		
		LDA	screenBtnCnt
		BNE	@begin
		
		RTS
		
@begin:
		LDX	ui + UI::iSelBtn	;Gone invalid?
		CPX	#$FF			;Stays that way until reset
		BNE	@tstJoyUp
		
		RTS
		
@tstJoyUp:
		LDA	JoyUp
		BEQ	@tstJoyDown
		
		LDA	ui + UI::fSelSgl
		BEQ	@loopUp

		JSR	doHandleJstkSinglesUp
		BEQ	@loopUp
		
		RTS

@loopUp:
		DEC	ui + UI::iSelBtn
		LDA	ui + UI::iSelBtn
		BPL	@tstNewUp

		LDX	screenBtnCnt
		DEX
		STX	ui + UI::iSelBtn
		TXA
		
@tstNewUp:
		CMP	$34
		BEQ	@upExhausted

		JSR	screenTestSelBtn
		BEQ	@loopUp

		JMP	@updateUI
		
@upExhausted:
;		LDA	#$FF			;Don't set to none, always
						;assume there is a valid 
						;button?
		STA	ui + UI::iSelBtn
		JMP	@updateUI
		
@tstJoyDown:
		LDA	JoyDown
		BEQ	@tstJoyLeft

		LDA	ui + UI::fSelSgl
		BEQ	@loopDown

		JSR	doHandleJstkSinglesDown
		BEQ	@loopDown
		
		RTS

@loopDown:
		INC	ui + UI::iSelBtn
		LDA	ui + UI::iSelBtn
		CMP	screenBtnCnt
		BNE	@tstNewDown
		
		LDA	#$00
		STA	ui + UI::iSelBtn

@tstNewDown:
		CMP	$34
		BEQ	@downExhausted
	
		JSR	screenTestSelBtn
		BEQ	@loopDown

		JMP	@updateUI
		
@downExhausted:
;		LDA	#$FF			;As above?
		STA	ui + UI::iSelBtn
		JMP	@updateUI
		
@tstJoyLeft:
		LDA	JoyLeft
		BEQ	@tstJoyRight

		LDA	ui + UI::fSelSgl
		BEQ	@joyLeft

		JSR	doHandleJstkSinglesLeft
		JMP	@updateUI

@joyLeft:
		LDA	ui + UI::fWntJFB
		BEQ	@tstClick
		
		LDA	#$46
		JSR	keyInjectKey
		
		RTS
		
@tstJoyRight:
		LDA	JoyRight
		BEQ	@tstClick

		LDA	ui + UI::fSelSgl
		BEQ	@joyRight

		JSR	doHandleJstkSinglesRight
		JMP	@updateUI

@joyRight:
		LDA	ui + UI::fWntJFB
		BEQ	@tstClick

		LDA	#$42
		JSR	keyInjectKey
		
		RTS
		
@tstClick:
		LDA	ButtonJClick
		BEQ	@exit
		
		LDA	#$00
		STA	ButtonJClick
		
		LDX	ui + UI::iSelBtn
		
		LDA	buttonLo, X
		STA	$32
		LDA	buttonHi, X
		STA	$33
		
		LDY	#BUTTON::cKey
		LDA	($32), Y
		
		JSR	keyInjectKey

@exit:
		RTS

@updateUI:
handleJoystickUpdateUI:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

		LDA	$FF
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1
		
		LDA	$34
		CMP	#$FF
		BEQ	@tstnew

		STA	ui + UI::fBtUpd0
		LDA	#$00
		STA	ui + UI::fBtSta0

@tstnew:
		LDA	ui + UI::iSelBtn
		CMP	#$FF
		BEQ	@exit
		
		STA	ui + UI::fBtUpd1
		LDA	#$01
		STA	ui + UI::fBtSta1

		LDX	ui + UI::iSelBtn

		LDA	buttonLo, X
		STA	$44
		LDA	buttonHi, X
		STA	$45
		
		LDY	#BUTTON::fType
		
		LDA	($44), Y
		CMP	#$04
		BNE	@exit
		
		LDA	#$01
		STA	ui + UI::fSelSgl

@exit:
		RTS

;-------------------------------------------------------------------------------
mouseCheck:
	.byte		$00
mouseTemp0:
	.word		$0000
mouseXCol:
	.byte		$00
mouseYRow:
	.byte		$00
mouseLastY:
	.word           $0000


;-------------------------------------------------------------------------------
handleMouse:
;-------------------------------------------------------------------------------
		STA	$46

		LDA	ui  + UI::iSelBtn
		STA	$47

		LDA	mouseCheck
		BNE	@proc
		
		RTS

@proc:
		LDA	#$00
		STA	mouseCheck

;**TODO:	Back it up and update ui if changed!!!

		LDA	#$FF
		STA	ui + UI::iSelBtn

		LDA	XPos
		STA	mouseTemp0
		LDA	XPos + 1
		STA	mouseTemp0 + 1
		
		LDX	#$02
@xDiv8Loop:
		LSR
		STA	mouseTemp0 + 1
		LDA	mouseTemp0
		ROR
		STA	mouseTemp0
		LDA	mouseTemp0 + 1
		
		DEX
		BPL	@xDiv8Loop
		
		LDA	mouseTemp0
		STA	mouseXCol
		
		LDA	YPos
		STA	mouseTemp0
		LDA	YPos + 1
		STA	mouseTemp0 + 1
		
		LDX	#$02
@yDiv8Loop:
		LSR
		STA	mouseTemp0 + 1
		LDA	mouseTemp0
		ROR
		STA	mouseTemp0
		LDA	mouseTemp0 + 1
		
		DEX
		BPL	@yDiv8Loop
		
		LDA	mouseTemp0
		STA	mouseYRow

		LDA	#$00
		STA	mouseTemp0
		
@loop:
		LDA	mouseTemp0
		ASL
		ASL
		ASL
		TAX
		
		LDA	button0, X
		
		CMP	#$FF
		BNE	@dotest
		
		JMP	@chklast

@dotest:
		CMP	#$0F
		BNE	@tstEnb

		LDA	mouseTemp0
		STA	ui + UI::iSelBtn
		
		LDA	#$FF
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1
		
		JMP	@exit

@tstEnb:
		CMP	#$00			;Disabled?
		BEQ	@next
		
		CMP	#$02			;Hidden?
		BEQ	@next
		
		CMP	#$0D			;Colour hidden?
		BEQ	@next
		
		INX				;pY
		LDA	button0, X	
		CMP	mouseYRow
		BNE	@next
		
		LDA	mouseXCol		;pX1
		INX
		CMP	button0, X
		BMI	@next
		
		INX				;pX2
		CMP	button0, X
		BPL	@next
		
		LDA	mouseTemp0
		STA	ui + UI::iSelBtn
		
		LDA	#$FF
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1
		
		LDA	$46
		BEQ	@tstnew

		LDA	$47
		CMP	#$FF
		BEQ	@tstnew
		
		STA	ui + UI::fBtUpd0
		LDA	#$00
		STA	ui + UI::fBtSta0

@tstnew:
		LDA	ui + UI::iSelBtn
		CMP	#$FF
		BEQ	@exit
		
		STA	ui + UI::fBtUpd1
		LDA	#$01
		STA	ui + UI::fBtSta1

		JMP	@exit
		
@next:
		INC	mouseTemp0
		JMP	@loop

@chklast:
		LDA	$46
		BEQ	@exit
		
		LDA	$47
		CMP	#$FF
		BEQ	@exit
		
		STA	ui + UI::fBtUpd0
		LDA	#$00
		STA	ui + UI::fBtSta0
		
		LDA	#$FF
		STA	ui + UI::fBtUpd1
		
@exit:
		RTS


;-------------------------------------------------------------------------------
handleMouseClick:
;-------------------------------------------------------------------------------
		LDA	#$00			;Find out where we clicked
		STA	ButtonLClick
		
		LDA	ui + UI::iSelBtn
		CMP	#$FF
		BEQ	@exit
		
		LDX	ui + UI::iSelBtn
		
		LDA	buttonLo, X
		STA	$32
		LDA	buttonHi, X
		STA	$33
		
		LDY	#BUTTON::cKey
		LDA	($32), Y
		
		JSR	keyInjectKey
		
@exit:
		RTS
		
		
;-------------------------------------------------------------------------------
;plyrMinimapBlink
;-------------------------------------------------------------------------------
plyrMinimapBlink:
		LDA	game + GAME::pActive
		CMP	irqglob + IRQGLOBS::minPlr
		BEQ	@test
	
		TAY
		LDX	irqglob + IRQGLOBS::minPlr
		LDA	irqBlinkSeq0
		STA	vicSprClr1, X
		
		STY	irqglob + IRQGLOBS::minPlr
		
		LDA	vicSprClr1, Y
		STA	irqBlinkSeq0
		STA	irqBlinkSeq0 + 1
		
		LDA	#$00
		STA	irqglob + IRQGLOBS::minIdx
		STA	irqglob + IRQGLOBS::minFlg
		
		JMP	@exit

@test:
		LDA	#$01
		EOR	irqglob + IRQGLOBS::minFlg
		STA	irqglob + IRQGLOBS::minFlg
		BNE	@exit

@blink:
		LDX	irqglob + IRQGLOBS::minIdx
		INX
		CPX	#$0C
		BNE	@1

		LDX	#$00
		
@1:
		STX	irqglob + IRQGLOBS::minIdx
		
		LDA	irqBlinkSeq0, X
		LDX	irqglob + IRQGLOBS::minPlr
		STA	vicSprClr1, X
				
@exit:
		RTS


;-------------------------------------------------------------------------------
;plyrDisplay
;-------------------------------------------------------------------------------
plyrDisplay:
		LDA	vicSprPosM
		AND	#$81
		STA	irqglob + IRQGLOBS::savMX

		LDX	#$00
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		STX	irqglob + IRQGLOBS::varG

		LDY	#PLAYER::dirty
		LDA	($FB), Y
		BEQ	@next

@calc:
		LDA	#$00
		STA	irqglob + IRQGLOBS::varC
		STA	irqglob + IRQGLOBS::varD
		STA	irqglob + IRQGLOBS::varE
		
		LDY	#PLAYER::square		
		LDA	($FB), Y		
		STA	irqglob + IRQGLOBS::varF

		LDY	#PLAYER::status
		LDA	($FB), Y
		
		JSR	plyrCalcMinimap

		AND	#$01
		BEQ	@hide

		LDA	game + GAME::pVis
		BNE	@test0

@hide:
		JSR	plyrDispHide
		JMP	@updatePos

@test0:
		LDA	game + GAME::qVis
		CMP	#$00
		BNE	@test1

		JSR	plyrDispTest0
		JMP	@updatePos
@test1:
		CMP	#$01
		BNE	@test2
		
		JSR	plyrDispTest1
		JMP	@updatePos
		
@test2:
		CMP	#$02
		BNE	@test3
		
		JSR	plyrDispTest2
		JMP	@updatePos
		
@test3:
		CMP	#$03
		BNE	@updatePos

		JSR	plyrDispTest3

@updatePos:
		JSR 	plyrDispUpdate
		JSR	plyrUpdCache

		LDX	irqglob + IRQGLOBS::varG

@next:
		
		INX
		CPX	#$06
		BNE	@loop

@exit:

		RTS


;-------------------------------------------------------------------------------
;plyrCalcMinimap
;-------------------------------------------------------------------------------
plyrCalcMinimap:
		PHA

		LDX	irqglob + IRQGLOBS::varG	;player
		TXA
		ASL
		TAX
		
		PLA
		PHA

		AND	#$01
		BNE	@cont
		
		LDA	$FF
		STA	irqglob + IRQGLOBS::min0X, X
		STA	irqglob + IRQGLOBS::min0Y, X
		JMP	@exit

@cont:
		
		LDA	irqglob + IRQGLOBS::varF	;square
		
		CMP	#$0B
		BPL	@lhv

		ASL
		STA	irqglob + IRQGLOBS::varA
		LDA	#$4F
		SEC
		SBC	irqglob + IRQGLOBS::varA
		STA	irqglob + IRQGLOBS::min0X, X

		LDA	#$EE
		CLC
		ADC	irqglob + IRQGLOBS::varG
		STA	irqglob + IRQGLOBS::min0Y, X
		
		JMP	@exit
	
@lhv:
		CMP	#$14
		BPL	@tph

		SEC
		SBC	#$0A
		STA	irqglob + IRQGLOBS::varA

		LDA	irqglob + IRQGLOBS::varG
		ASL
		CLC	
		ADC	#$3A
		
		STA	irqglob + IRQGLOBS::min0X, X
		
		LDA	#$EE
		SEC
		SBC	irqglob + IRQGLOBS::varA
		STA	irqglob + IRQGLOBS::min0Y, X
		
		JMP	@exit
		
@tph:
		CMP	#$1F
		BPL	@rhv

		SEC
		SBC	#$14
		ASL
		STA	irqglob + IRQGLOBS::varA
		LDA	#$3B
		CLC
		ADC	irqglob + IRQGLOBS::varA
		STA	irqglob + IRQGLOBS::min0X, X
		
		LDA	irqglob + IRQGLOBS::varG
		CLC	
		ADC	#$DF
		STA	irqglob + IRQGLOBS::min0Y, X
		
		JMP	@exit
		
@rhv:
		SEC
		SBC	#$1F
		STA	irqglob + IRQGLOBS::varA
		
		LDA	irqglob + IRQGLOBS::varG
		ASL
		CLC	
		ADC	#$46
		STA	irqglob + IRQGLOBS::min0X, X
		
		CLC
		LDA	#$E5
		ADC	irqglob + IRQGLOBS::varA
		STA	irqglob + IRQGLOBS::min0Y, X
		
@exit:
		PLA
		
		RTS


;-------------------------------------------------------------------------------
;plyrUpdCache
;-------------------------------------------------------------------------------
plyrUpdCache:
		LDY	#PLAYER::dirty
		LDA	#$00
		STA	($FB), Y
		
		RTS


;-------------------------------------------------------------------------------
;plyrDispHide
;-------------------------------------------------------------------------------
plyrDispHide:
		LDA	#$00
		STA	irqglob + IRQGLOBS::varC
		STA	irqglob + IRQGLOBS::varD
		
		RTS
		

;-------------------------------------------------------------------------------
;plyrDispTest0
;-------------------------------------------------------------------------------
plyrDispTest0:
		LDA	irqglob + IRQGLOBS::varF	;square
		
		CMP	#$06			
		BPL	@test0V
		
		LDX	#$00
		STX	irqglob + IRQGLOBS::varH
		
;		LDX	#$00
		JSR	plyrDispQuadH
		JMP 	@exit
	
@test0V:
		CMP	#$23			;Quad 0, vert?
		BMI	@exit

		LDX	#$23
		STX	irqglob + IRQGLOBS::varH

		LDX	#$00
		JSR	plyrDispQuadV
;		JMP 	@updatePos

@exit:
		RTS


;-------------------------------------------------------------------------------
;plyrDispTest1
;-------------------------------------------------------------------------------
plyrDispTest1:
		LDA	irqglob + IRQGLOBS::varF	;square
		
		CMP	#$05
		BMI	@exit

		CMP	#$0B			
		BPL	@test1V

		LDX	#$05
		STX	irqglob + IRQGLOBS::varH
		LDX	#$01
		JSR	plyrDispQuadH
		JMP 	@exit
	
@test1V:
		CMP	#$10			;Quad 1, vert?
		BPL	@exit

		LDX	#$0B
		STX	irqglob + IRQGLOBS::varH
		LDX	#$01
		JSR	plyrDispQuadV
;		JMP 	@exit
		
@exit:
		RTS


;-------------------------------------------------------------------------------
;plyrDispTest2
;-------------------------------------------------------------------------------
plyrDispTest2:
		LDA	irqglob + IRQGLOBS::varF	;square
		
		CMP	#$0F			
		BMI	@exit

		CMP	#$14
		BPL	@test2H

		LDX	#$0F
		STX	irqglob + IRQGLOBS::varH
		LDX	#$02
		JSR	plyrDispQuadV
		JMP 	@exit
		
@test2H:
		CMP	#$1A			;Quad 2, horz?
		BPL	@exit

		LDX	#$14
		STX	irqglob + IRQGLOBS::varH
		LDX	#$02
		JSR	plyrDispQuadH
;		JMP 	@exit
@exit:
		RTS
	
	
;-------------------------------------------------------------------------------
;plyrDispTest3
;-------------------------------------------------------------------------------
plyrDispTest3:
		LDA	irqglob + IRQGLOBS::varF	;square

		CMP	#$19
		BMI	@exit

		CMP	#$1F
		BPL	@test3V

		LDX	#$19
		STX	irqglob + IRQGLOBS::varH
		LDX	#$03
		JSR	plyrDispQuadH
		JMP 	@exit
	
@test3V:
		CMP	#$24			;Quad 3, vert?
		BPL	@exit

		LDX	#$1F
		STX	irqglob + IRQGLOBS::varH
		LDX	#$03
		JSR	plyrDispQuadV
;		JMP 	@exit
@exit:
		RTS


;-------------------------------------------------------------------------------
;plyrDispSetBaseH
;-------------------------------------------------------------------------------
plyrDispSetBaseH:
		LDA	#$00
		STA	irqglob + IRQGLOBS::varA
		STA	irqglob + IRQGLOBS::varB

		LDX	irqglob + IRQGLOBS::varG
		CPX	#$03
		BMI	@test
		
		LDA	#$08
		STA	irqglob + IRQGLOBS::varA
		DEX
		DEX
		DEX
		
@test:
		CPX	#$00
		BEQ	@exit
		
		LDA	#$04
@step:
		ASL
		DEX
		CPX	#$00
		BNE	@step

@done:
		STA	irqglob + IRQGLOBS::varB
@exit:
		RTS


;-------------------------------------------------------------------------------
;plyrDispSetBaseV
;-------------------------------------------------------------------------------
plyrDispSetBaseV:
		LDA	#$00
		STA	irqglob + IRQGLOBS::varA
		STA	irqglob + IRQGLOBS::varB

		LDX	irqglob + IRQGLOBS::varG
		CPX	#$03
		BMI	@test
		
		LDA	#$08
		STA	irqglob + IRQGLOBS::varB
		DEX
		DEX
		DEX
		
@test:
		CPX	#$00
		BEQ	@exit
		
		LDA	#$04
@step:
		ASL
		DEX
		CPX	#$00
		BNE	@step

@done:
		STA	irqglob + IRQGLOBS::varA
@exit:
		RTS

;-------------------------------------------------------------------------------
;plyrDispQuadH
;-------------------------------------------------------------------------------
plyrDispQuadH:
		LDA	bQuadPosLo, X
		STA	$FD
		LDA	bQuadPosHi, X
		STA	$FE
		
;		LDX	irqglob + IRQGLOBS::varG

		LDY	#BQUADP::pPosHY
		LDA	($FD), Y
		
		STA	irqglob + IRQGLOBS::varE
		
		LDA	irqglob + IRQGLOBS::varF
		SEC
		SBC	irqglob + IRQGLOBS::varH
		ASL
		STA	irqglob + IRQGLOBS::varA

		LDA	#BQUADP::pPos0X
		CLC
		ADC	irqglob + IRQGLOBS::varA
		TAY
		LDA	($FD), Y
		
		STA	irqglob + IRQGLOBS::varC
		
		INY
		LDA	($FD), Y
		STA	irqglob + IRQGLOBS::varD

		JSR 	plyrDispSetBaseH

		RTS


;-------------------------------------------------------------------------------
;plyrDispQuadV
;-------------------------------------------------------------------------------
plyrDispQuadV:
		LDA	bQuadPosLo, X
		STA	$FD
		LDA	bQuadPosHi, X
		STA	$FE
		
;		LDX	irqglob + IRQGLOBS::varG

		LDY	#BQUADP::pPosVX
		LDA	($FD), Y
		STA	irqglob + IRQGLOBS::varC
		INY
		LDA	($FD), Y
		STA	irqglob + IRQGLOBS::varD
		
		LDA	irqglob + IRQGLOBS::varF
		SEC
		SBC	irqglob + IRQGLOBS::varH
		STA	irqglob + IRQGLOBS::varA
		
		LDA	#BQUADP::pPos0Y
		CLC
		ADC	irqglob + IRQGLOBS::varA
		TAY
		LDA	($FD), Y
		STA	irqglob + IRQGLOBS::varE

		JSR 	plyrDispSetBaseV

		RTS


plrMIncBits:					;Doubled up because its easier
						;(reuse calculated index)
			.byte	$02, $02, $04, $04, $08, $08
			.byte	$10, $10, $20, $20, $40, $40

plrMExcBits:					;Doubled up because its easier
						;(reuse calculated index)
			.byte	$FD, $FD, $FB, $FB, $F7, $F7
			.byte	$EF, $EF, $DF, $DF, $BF, $BF

;-------------------------------------------------------------------------------
;plyrDispUpdate:
;-------------------------------------------------------------------------------
plyrDispUpdate:
		LDA	irqglob + IRQGLOBS::varA
		CLC
		ADC	irqglob + IRQGLOBS::varC
		BCC	@1
		
		INC	irqglob + IRQGLOBS::varD

@1:
		LDX	irqglob + IRQGLOBS::varG

		PHA
		TXA
		ASL
		TAX
		PLA

		STA 	irqglob + IRQGLOBS::brd0X, X

		LDA	irqglob + IRQGLOBS::varD
		BEQ	@2

		LDA	plrMIncBits, X
		ORA	irqglob + IRQGLOBS::brdMX
		STA	irqglob + IRQGLOBS::brdMX
		JMP	@3
	
@2:
		LDA	plrMExcBits, X
		AND	irqglob + IRQGLOBS::brdMX
		STA	irqglob + IRQGLOBS::brdMX
		
@3:
;		TYA
;		TYX

		LDA	irqglob + IRQGLOBS::varB
		CLC
		ADC	irqglob + IRQGLOBS::varE
		
;		TXA
;		TAY
;		ASL
;		TAX

		STA	irqglob + IRQGLOBS::brd0Y, X

		LDX	irqglob + IRQGLOBS::varG

;		JSR	plyrUpdCache
		
plyrDispUpdShort:
		RTS


;-------------------------------------------------------------------------------
;consts/tables
;-------------------------------------------------------------------------------
;dengland	These are BQUADP structs

bQuadPos0:
			.byte	$B6
			.word	$0134
			.word	$0114
			.word	$00FC
			.word	$00E4
			.word	$00CC
			.word	$00B4
			.word	$0134
			.byte	$36
			.byte	$4E
			.byte	$66
			.byte	$7E
			.byte	$96

bQuadPos1:
			.byte	$B6
			.word	$0144
			.word	$012C
			.word	$0114
			.word	$00FC
			.word 	$00E4
			.word	$00BC
			.word	$00BC
			.byte	$96
			.byte	$7E
			.byte	$66
			.byte	$4E
			.byte	$36
			
bQuadPos2:
			.byte	$3E
			.word	$00BC
			.word	$00E4
			.word	$00FC
			.word	$0114
			.word	$012C
			.word	$0144
			.word	$00BC
			.byte	$C6
			.byte	$AE
			.byte	$96
			.byte	$7E
			.byte	$66
			
bQuadPos3:
			.byte	$3E
			.word	$00B4
			.word	$00CC
			.word	$00E4
			.word	$00FC
			.word	$011C
			.word	$0134
			.word	$0134
			.byte	$66
			.byte	$7E
			.byte	$96
			.byte	$AE
			.byte	$C6
			
bQuadPosLo:
			.byte 	<bQuadPos0, <bQuadPos1
			.byte 	<bQuadPos2, <bQuadPos3
			
bQuadPosHi:
			.byte 	>bQuadPos0, >bQuadPos1
			.byte 	>bQuadPos2, >bQuadPos3


;===============================================================================
;FOR PROMPT.S
;===============================================================================

prmpt0Txt0	=	$0783
prmpt0Clr0	=	$DB83
prmpt1Txt0	=	prmpt0Txt0 + 40
prmpt1Clr0	=	prmpt0Clr0 + 40

prmptTemp0:
		.byte	$00, $00
prmptTemp2:
		.byte 	$00
prmptTemp3:
		.byte	$00


tokPrmptRolled:		;ROLLED 
			.byte 	$51, $12, $0F, $0C, $0C, $05, $04, $20
			.byte	$20, $20, $20, $20, $20, $20, $20, $20
tokPrmptRent:		;RENT   
			.byte 	$51, $12, $05, $0E, $14, $20, $20, $20
			.byte	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptBought:		;BOUGHT
			.byte	$51, $02, $0F, $15, $07, $08, $14, $20
			.byte	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptTax:		;TAX
			.byte 	$51, $14, $01, $18, $20, $20, $20, $20
			.byte	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptGaol:		;GONE TO GAOL
			.byte 	$51, $07, $0F, $0E, $05, $20, $14, $0F
			.byte 	$20, $07, $01, $0F, $0C, $20, $20, $20
tokPrmptManage:		;HSES+00 HTLS+00
			.byte 	$51, $08, $13, $05, $13, $2B, $30, $30
			.byte 	$20, $08, $14, $0C, $13, $2B, $30, $30
tokPrmptMustSell:	;MUST SELL IMPRV
			.byte 	$51, $0D, $15, $13, $14, $20, $13, $05
			.byte 	$0C, $0C, $20, $09, $0D, $10, $12, $16
tokPrmptSalary:		;SALARY   
			.byte 	$51, $13, $01, $0C, $01, $12, $19, $20
			.byte 	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptFParking:	;FPARKING
			.byte 	$51, $06, $10, $01, $12, $0B, $09, $0E
			.byte 	$07, $24, $20, $20, $20, $20, $20, $20
tokPrmptMortgage:	;MORTGAGE
			.byte 	$51, $0D, $0F, $12, $14, $07, $01, $07
			.byte 	$05, $24, $20, $20, $20, $20, $20, $20
tokPrmptRepay:		;REPAY    
			.byte 	$51, $12, $05, $10, $01, $19, $20, $20
			.byte 	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptSold:		;SOLD     
			.byte 	$51, $13, $0F, $0C, $04, $20, $20, $20
			.byte 	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptShuffle:	;SHUFFLING...
			.byte 	$51, $13, $08, $15, $06, $06, $0C, $09
			.byte 	$0E, $07, $2E, $2E, $2E, $20, $20, $20
tokPrmptChest:		;CHEST
			.byte 	$51, $03, $08, $05, $13, $14, $20, $20
			.byte 	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptChance:		;CHANCE 
			.byte 	$51, $03, $08, $01, $0E, $03, $05, $20
			.byte 	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptForSale:	;FOR SALE
			.byte 	$51, $06, $0F, $12, $20, $13, $01, $0C
			.byte 	$05, $24, $20, $20, $20, $20, $20, $20
tokPrmptPostBail:	;BAIL
			.byte 	$51, $02, $01, $09, $0C, $20, $20, $20
			.byte	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptFee:		;FEE
			.byte 	$51, $06, $05, $05, $20, $20, $20, $20
			.byte	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptForfeit:	;FORFEIT
			.byte 	$51, $06, $0F, $12, $06, $05, $09, $14
			.byte	$20, $20, $20, $20, $20, $20, $20, $20
tokPrmptPass:		;PASS
			.byte 	$51, $10, $01, $13, $13, $20, $20, $20
			.byte	$20, $20, $20, $20, $20, $20, $20, $20
tokPrmptBid:		;BID
			.byte 	$51, $02, $09, $04, $20, $20, $20, $20
			.byte	$20, $24, $20, $20, $20, $20, $20, $20
tokPrmptInTrade:	;BEING TRADED!
			.byte 	$51, $02, $05, $09, $0E, $07, $20, $14
			.byte 	$12, $01, $04, $05, $04, $21, $20, $20


;-------------------------------------------------------------------------------
;prmptClear
;-------------------------------------------------------------------------------
prmptClear:
		LDA 	#$20
		LDX	#$1F
@loop1:
		STA	prmptTok0, X
		
		DEX
		BPL	@loop1

		LDX	#$0F
@loop2:
		LDA	#$0C
		STA	prmptClr0, X

		LDA	#$0F
		STA	prmptClr1, X
		
		DEX
		BPL 	@loop2

		LDA	#$00
		STA	prmptTemp2
		STA	prmptTemp3
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


prmptClear2:
		LDX	#$0F
		LDA	#$20
@loop0:
		STA	prmptTok1, X
		DEX
		BPL	@loop0
		
		LDA	prmptTemp2
		AND	#$F0
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


prmptDisplay:
		LDX	#$0F
@loop0:
		LDA	prmptTok0, X
		STA	prmpt0Txt0, X
		LDA	prmptClr0, X
		STA	prmpt0Clr0, X
		
		LDA	prmptTok1, X
		STA	prmpt1Txt0, X
		LDA	prmptClr1, X
		STA	prmpt1Clr0, X

		DEX
		BPL	@loop0

		RTS
	
	
prmptUpdate:
		LDA	prmptTemp2
		BNE	@begin
		
		JMP	@exit
		
@begin:
		AND	#$80
		BEQ	@test
		
						;-HSES+00 HTLS+00
		LDA	game + GAME::cntHs
		STA	Z:numConvVALUE
		BPL	@poshs
			
		LDA	#$FF
		STA	Z:numConvVALUE + 1

		LDA	#$02
		JMP	@cont0
		
@poshs:	
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		LDA	#$05
		
@cont0:
		LDX	#$02
@loop0:
		STA	prmptClr0 + $05, X
		DEX
		BPL	@loop0

		JSR	numConvPRTSGN
		
		LDA	heap0
		STA	prmptTok0 + $05
		LDA	heap0 + $04
		STA	prmptTok0 + $06
		LDA	heap0 + $05
		STA	prmptTok0 + $07
		
		LDA	game + GAME::cntHt
		STA	Z:numConvVALUE
		BPL	@posht

		LDA	#$FF
		STA	Z:numConvVALUE + 1
		
		LDA	#$02
		JMP	@cont1
		
@posht:	
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		LDA	#$05
		
@cont1:
		LDX	#$02
@loop1:
		STA	prmptClr0 + $0D, X
		DEX
		BPL	@loop1
		
		JSR	numConvPRTSGN
		
		LDA	heap0
		STA	prmptTok0 + $0D
		LDA	heap0 + $04
		STA	prmptTok0 + $0E
		LDA	heap0 + $05
		STA	prmptTok0 + $0F
		
@test:
		LDA	prmptTemp2
		AND	#$0F
		BEQ	@exit

		LDA	prmptTemp0
		STA	Z:numConvVALUE
		LDA	prmptTemp0 + 1
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop2:
		LDA	heap0, X
		STA	prmptTok1 + $0A, X
		
		LDA	prmptTemp2
		AND	#$0F
		STA	prmptClr1 + $0A, X
		
		DEX
		BPL	@loop2
		
		STA	prmptClr1 + $09

;		LDA	prmptTemp2			;This would put a + in
;		AND	#$0F				;all add cash (green) values
;		CMP	#$05				;but it looks strange 
;		BNE	@exit				;sometimes - eg for sale 
;		LDA	#$2B
;		STA	prmptTok1 + $0A

@exit:	
		LDA	#$00
		STA	prmptTemp2
		
		RTS
	
		
prmptRolled:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptRolled, X
		STA	prmptTok0, X

		LDA	#$0C
		STA	prmptClr0, X

		DEX
		BPL	@loop1
		
		PLA
		STA	prmptClr0
		
		LDA	game + GAME::dieA
		CLC
		ADC	#'0'
		STA	prmptTok0 + $09
		
		LDA	game + GAME::dieB
		CLC
		ADC	#'0'
		STA	prmptTok0 + $0B

		LDA	#$01
		STA	prmptTemp3
		
		LDA	prmptTemp2
		AND	#$0F
		STA	prmptTemp2
		
		JSR	prmptClear2

		RTS


prmptManage:
		LDX	#$0F
@loop1:
		LDA	tokPrmptManage, X
		STA	prmptTok0, X

		LDA	#$0C
		STA	prmptClr0, X

		DEX
		BPL	@loop1
		
		LDA	#$0F
		STA	prmptClr0
		
		LDA	#$80
		ORA	prmptTemp2
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
	
	
prmptClearOrRoll:
		LDA	prmptTemp3
		BNE	@roll
		
		JSR	prmptClear
		RTS
		
@roll:
		JSR	prmptRolled
		RTS
		

prmptMustSell:
		TXA
		PHA
		
		LDX	#$0F
@loop1:
		LDA	tokPrmptMustSell, X
		STA	prmptTok1, X

		LDA	#$01
		STA	prmptClr1, X

		DEX
		BPL	@loop1

		PLA
		STA	prmptClr1

		LDA	prmptTemp2		;Exclude flags for text 1 (not 
		AND	#$F0			;needed)
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		
		
prmptGoneGaol:
		TXA
		PHA
		
		LDX	#$0F
@loop1:
		LDA	tokPrmptGaol, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1

		PLA
		STA	prmptClr1

		LDA	prmptTemp2
		AND	#$F0
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


prmptDoSubCash:
		PLA
		STA	prmptClr1
		
		SEC
		LDA	#$00
		SBC	game + GAME::varD
		STA	prmptTemp0
		
		LDA	#$00
		SBC	game + GAME::varE
		STA	prmptTemp0 + 1
		
		LDA	prmptTemp2
		AND	#$F0
		ORA	#$02
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


prmptDoAddCash:
		PLA
		STA	prmptClr1
		
		LDA	game + GAME::varD
		STA	prmptTemp0
		
		LDA	game + GAME::varE
		STA	prmptTemp0 + 1
		
		LDA	prmptTemp2
		AND	#$F0
		ORA	#$05
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS

	
prmptRent:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptRent, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash
		

prmptBought:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptBought, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash
		
		
prmptPostBail:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptPostBail, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash
		
		
prmptTax:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptTax, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptFee:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptFee, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptSalary:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptSalary, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptFParking:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptFParking, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptSold:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptSold, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash
		
		
prmptMortgage:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptMortgage, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash
		
		
prmptRepay:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptRepay, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptChestSub:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChest, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptChanceSub:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChance, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptChestAdd:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChest, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptChanceAdd:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChance, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptShuffle:
		LDX	#$0F
@loop0:
		LDA	#$20
		STA	prmpt0Txt0, X
		STA	prmpt1Txt0, X

		DEX
		BPL	@loop0

		LDX	#$0F
@loop1:
		LDA	tokPrmptShuffle, X
		STA	prmpt0Txt0, X

		LDA	#$0C
		STA	prmpt0Clr0, X

		DEX
		BPL	@loop1
		
		LDA	#$01
		STA	prmpt0Clr0
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS
		
		
prmptForSale:
		LDX	#$0F
@loop1:
		LDA	tokPrmptForSale, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		LDA	#$0F
		PHA
		
		JMP	prmptDoAddCash

		RTS


prmptForfeit:
		TXA
		PHA
		
		LDX	#$0F
@loop1:
		LDA	tokPrmptForfeit, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		PLA
		STA	prmptClr1
		
		LDA	prmptTemp2
		AND	#$F0
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


prmptPass:
		TXA
		PHA
		
		LDX	#$0F
@loop1:
		LDA	tokPrmptPass, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		PLA
		STA	prmptClr1
		
		LDA	prmptTemp2
		AND	#$F0
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


prmptBid:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptBid, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptInTrade:
		LDX	#$0F
@loop1:
		LDA	tokPrmptInTrade, X
		STA	prmptTok1, X

		LDA	#$0F
		STA	prmptClr1, X

		DEX
		BPL	@loop1
		
		LDA	#$0F
		STA	prmptClr1
		
		LDA	prmptTemp2
		AND	#$F0
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS
		

;==============================================================================
;FOR STATUS.S
;==============================================================================

statsPlrCntr:	
		.byte	$00
statsScnOffs:
		.byte	$00
statsStrLen:
		.byte	$00
		
statsPerfLstH:
		.byte	$20, $02, $00, $11
		.byte	$00
		
statsPerfLstV:
		.byte	$31, $00, $00, $06
		.byte	$3F, $01, $00, $06
		.byte	$00
		
;------------------------------------------------------------------------------
;statsClear
;------------------------------------------------------------------------------
statsClear:
		LDX	#$00			;Colour each line in the 
@loop:						;player's colour
		STX	statsPlrCntr

		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
			
		LDA	#<statsPerfLstH
		STA	$FD
		LDA	#>statsPerfLstH
		STA	$FE
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		
		ORA	#$20
		STA	statsPerfLstH

		TXA
		STA	statsPerfLstH + 2

		JSR	screenPerformList

@next:
		LDX	statsPlrCntr
		INX
		CPX	#$06
		BNE	@loop
		
		LDA	#<statsPerfLstV		;Colour the active player and
		STA	$FD			;gaol status indicators
		LDA	#>statsPerfLstV
		STA	$FE
		
		JSR	screenPerformList

		RTS


;------------------------------------------------------------------------------
;statsDisplay
;------------------------------------------------------------------------------
statsDisplay:
		LDX	#$00
		
@loopPlr:
		LDA	screenRowsLo, X
		STA	$FB
		LDA	screenRowsHi, X
		STA	$FC
		
		STX	statsPlrCntr
		
		LDA	plrLo, X
		STA	$FD
		LDA	plrHi, X
		STA	$FE
		
		LDY	#PLAYER::status
		LDA	($FD), Y
		STA	game + GAME::varA

		AND	#$01
		BNE	@cont
		
		LDA	#$20
		LDY	#$11
@loopBlank:
		STA	($FB), Y
		DEY
		BPL	@loopBlank
		
		JMP	@plrNext
		
@cont:
		LDY	#PLAYER::money
		LDA	($FD), Y
		STA	$A3
		INY
		LDA	($FD), Y
		STA	$A4
		
		LDY	#$00
		
		CPX	game + GAME::pActive
		BNE	@2

		LDA	#'>'
		BNE	@3

@2:
		LDA	#' '
		
@3:
		STA	($FB), Y
		INY

		TYA				;Save .Y in .X
		TAX	
		LDA	game + GAME::varA
		AND	#$80
		BEQ	@4

		LDA	game + GAME::pGF0Crd
		CMP	statsPlrCntr
		BNE	@tst1
		
		JMP	@outfree1
		
@tst1:
		LDA	game + GAME::pGF1Crd
		CMP	statsPlrCntr
		BNE	@gaol
		
@outfree1:
		LDA	#'='			;Same screen code as ASCII???
		JMP	@5
	

@gaol:
		LDA	#'#'			;Same screen code as ASCII???
		JMP	@5
		
@4:
		LDA	game + GAME::pGF0Crd
		CMP	statsPlrCntr
		BNE	@tst2
		
		JMP	@outfree2
@tst2:
		LDA	game + GAME::pGF1Crd
		CMP	statsPlrCntr
		BNE	@nofree

@outfree2:
		LDA	#'+'			;Same screen code as ASCII???
		JMP	@5
		
@nofree:
		LDA	#' '			;Same screen code as ASCII???	

@5:
		PHA				;Back up .A
		TXA				;Get back .Y from .X
		TAY
		PLA				;Restore .A

		STA	($FB), Y
		INY

		LDA	#PLAYER::name + 1
		STA	game + GAME::varM
		STY	game + GAME::varN
		
		LDX	#$00
@loopName:
		LDY	game + GAME::varM
		LDA	($FD), Y
		
		LDY	game + GAME::varN
		AND	#$7F
		STA	($FB), Y
		
		INC	game + GAME::varN
		INC	game + GAME::varM
		
		INX
		CPX	#$08
		BNE	@loopName
		
		LDY	game + GAME::varN
		
		LDA	#' '			;Same screen code as ASCII???
		STA	($FB), Y
		INY
		LDA	#'$'			;Same screen code as ASCII???
		STA	($FB), Y
		INY
		
		STY	statsScnOffs
		
		JSR	numConvPRTSGN
		
;***FIXME???	numConvPRTSGN always prints to 6 characters.  There really 
;		isn't a need to return the length in .Y.  If it restored .Y
;		some other code would be simpler.

		STY	statsStrLen
		
		LDY	statsScnOffs
		LDX	#$00
		
@loopMoney:
		LDA	heap0, X
		STA	($FB), Y
		INY

		INX
		CPX	statsStrLen
		BNE	@loopMoney
		
		
@plrNext:
		LDX	statsPlrCntr
		INX
		CPX	#$06
		BEQ	@exit
		JMP	@loopPlr
			
@exit:
		RTS

		

;==============================================================================
;FOR UI.S
;==============================================================================

UI_ACT_FALT	=	0
UI_ACT_TRDE	=	1
UI_ACT_REPY	=	2
UI_ACT_PFEE	=	3
UI_ACT_AUCN	=	4
UI_ACT_MRTG	=	5
UI_ACT_SELL	=	6
UI_ACT_BUYD	=	7
UI_ACT_BUYI	=	8
UI_ACT_GOFR	=	9
UI_ACT_POST	=	10
UI_ACT_ROLL	=	11
UI_ACT_SKEY	=	12
UI_ACT_DELY	= 	13


uiActionCallsLo:
		.byte	<(uiActionFault - 1), <(uiActionTrade - 1)
		.byte	<(uiActionRepay - 1), <(uiActionFee - 1)
		.byte	<(uiActionAuction - 1), <(uiActionMrtg - 1)
		.byte	<(uiActionSell - 1), <(uiActionBuy - 1)
		.byte	<(uiActionImprv - 1), <(uiActionGOFree - 1)
		.byte	<(uiActionPost - 1), <(uiActionRoll - 1)
		.byte	<(uiActionSendKey - 1), <(uiActionDelay - 1)
uiActionCallsHi:
		.byte	>(uiActionFault - 1), >(uiActionTrade - 1)
		.byte	>(uiActionRepay - 1), >(uiActionFee - 1)
		.byte	>(uiActionAuction - 1), >(uiActionMrtg - 1)
		.byte	>(uiActionSell - 1), >(uiActionBuy - 1)
		.byte	>(uiActionImprv - 1), >(uiActionGOFree - 1)
		.byte	>(uiActionPost - 1), >(uiActionRoll - 1)
		.byte	>(uiActionSendKey - 1), >(uiActionDelay - 1)
		
uiActnCache	=	$FB00
;	.repeat		256, I
;			.byte	$FF, $00, $00, $00
;	.endrep
;

;-------------------------------------------------------------------------------
uiInitQueue:
;-------------------------------------------------------------------------------
		LDA	#<uiActnCache
		STA	$6D
		LDA	#>uiActnCache
		STA	$6E

		LDA	#$00
		STA	ui + UI::cActns

;		LDA	#$FF
;		STA	($6D), Y
		
;		CLC
;		LDA	$6D
;		ADC	#$04
;		STA	$6D
;		LDA	$6E
;		ADC	#$00
;		STA	$6E
		
		RTS


;-------------------------------------------------------------------------------
uiDequeueAction:
;-------------------------------------------------------------------------------
		LDY	#$00
		
;		SEC
;		LDA	ui + UI::cActns
;		SBC	#$01
;		STA	ui + UI::cActns
;		LDA	ui + UI::cActns + 1
;		SBC	#$00
;		STA	ui + UI::cActns + 1
		
		DEC	ui + UI::cActns
		
		LDA	($6D), Y
		STA	$68
		INY
		LDA	($6D), Y
		STA	$69
		INY
		LDA	($6D), Y
		STA	$6A
		INY
		LDA	($6D), Y
		STA	$6B

		CLC
		LDA	$6D
		ADC	#$04
		STA	$6D
		LDA	$6E
		ADC	#$00
		STA	$6E
		

		RTS
		

;-------------------------------------------------------------------------------
uiEnqueueAction:
;-------------------------------------------------------------------------------
		LDY	#$00
		
		LDA	$68
		STA	($6D), Y
		INY
		LDA	$69
		STA	($6D), Y
		INY
		LDA	$6A
		STA	($6D), Y
		INY
		LDA	$6B
		STA	($6D), Y
		
;		CLC
;		LDA	ui + UI::cActns
;		ADC	#$01
;		STA	ui + UI::cActns
;		LDA	ui + UI::cActns + 1
;		ADC	#$00
;		STA	ui + UI::cActns + 1

		INC	ui + UI::cActns

		CLC
		LDA	$6D
		ADC	#$04
		STA	$6D
		LDA	$6E
		ADC	#$00
		STA	$6E
		
		LDY	#$00
		LDA	#$FF
		STA	($6D), Y

		RTS

;-------------------------------------------------------------------------------
uiPerformAction:
;-------------------------------------------------------------------------------
		LDX	$68
		
		LDA	#>(@farreturn - 1)
		PHA
		LDA	#<(@farreturn - 1)
		PHA
		
		LDA	uiActionCallsHi, X
		PHA
		LDA	uiActionCallsLo, X
		PHA
		
		RTS				;Call our routine
		
@farreturn:
		RTS


;-------------------------------------------------------------------------------
uiProcessInit:
;-------------------------------------------------------------------------------
		LDA	#<uiActnCache
		STA	$6D
		LDA	#>uiActnCache
		STA	$6E
		
		LDA	#$00
		STA	ui + UI::fInjKey
		
		LDA	#$30
		STA	game + GAME::iStpCnt
		LDA	#$00			
		STA	game + GAME::fStpSig

		LDA	game + GAME::gMode
		STA	ui + UI::gMdAct
		LDA	game + GAME::pActive
		STA	ui + UI::pActBak

		LDA	#$08
		STA	game + GAME::gMode
		
		JSR	gameUpdateMenu

		LDA	#<$DA18
		STA	game + GAME::aWai
		LDA	#>$DA18
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai
	
		RTS
		

;-------------------------------------------------------------------------------
uiProcessActions:
;-------------------------------------------------------------------------------
		LDA	ui + UI::cActns
		BEQ	@terminate
		
		LDA	game + GAME::fStpSig
		BNE	@proc

		LDA	ui + UI::fActInt
		BEQ	@proc

		RTS
		
@proc:
		JSR	uiActionDeselect
		
		JSR	uiDequeueAction
		
		JSR	uiPerformAction
		
;		DEC	ui + UI::cActns
;		LDA	ui + UI::cActns
;		BNE	@exit
		JMP	@exit
		
@terminate:
		JSR	uiInitQueue
		
		LDY	#$00
		LDA	#$FF
		STA	($6D), Y

		JSR	uiProcessTerminate
		
@exit:
		LDA	#$00
		STA	game + GAME::fStpSig
		
		RTS


;-------------------------------------------------------------------------------
uiProcessMPay:
;-------------------------------------------------------------------------------
		LDA	game + GAME::gMode
		STA	game + GAME::gMdMPyI	
		
		LDA	game + GAME::pActive
		STA	game + GAME::pMstPyI

		STA	game + GAME::pMPyLst
		STA	game + GAME::pMPyCur

		LDA	#$03
		STA	game + GAME::gMode
		
		RTS
		
		
;-------------------------------------------------------------------------------
uiProcessChkAllMPay:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		JMP	@next1
@loop1:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$0A
		BEQ	@next1

		JSR	uiProcessMPay
		JMP	@exit1
		
@next1:
		INX

		CPX	#$06
		BNE	@tstloop1
		
@wrap1:		
		LDX	#$00
		
@tstloop1:
		CPX	game + GAME::pActive
		BNE	@loop1
		
@exit1:
		RTS


;-------------------------------------------------------------------------------
uiProcessTerminate:
;-------------------------------------------------------------------------------
		JSR	uiActionDeselect
		
		LDA	ui + UI::fActTyp
		BNE	@endelimin

;		Pop player and mode from trade 
		LDA	ui + UI::pActBak
		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast
		
		LDA	ui + UI::gMdAct
		STA	game + GAME::gMode

		LDA	#$00
		STA	game + GAME::fStpSig
		STA	game + GAME::kWai
		
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty

;		LDX	game + GAME::pActive	
;		LDA	plrLo, X		
;		STA	$FB
;		LDA	plrHi, X
;		STA	$FC
;		
;		LDY	#PLAYER::colour
;		LDA	($FB), Y
;		TAX
;		JSR	prmptClearOrRoll

		JSR	uiProcessChkAllMPay	

		JSR	gameUpdateMenu

		LDA	#$01
		STA	ui + UI::fInjKey
		
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS

@endelimin:
		LDA	ui + UI::pActBak
		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast
		
		LDA	ui + UI::gMdAct
		STA	game + GAME::gMode

		LDA	#$00
		STA	game + GAME::fStpSig
		STA	game + GAME::kWai
		
		JSR	rulesDoNextPlyr
		
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty
		
		LDA	game + GAME::gMode
		CMP	#$03
		BEQ	@alreadympay
		
		JSR	uiProcessChkAllMPay
		JMP	@complete
		
@alreadympay:
		LDA	game + GAME::pActive	;Check them all again
		STA	game + GAME::pMstPyI

		STA	game + GAME::pMPyLst

@complete:
		JSR	gameUpdateMenu
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


;-------------------------------------------------------------------------------
uiActionDeselect:
;-------------------------------------------------------------------------------
		LDA	game + GAME::sSelect
		CMP	#$FF
		BEQ	@exit
		
		JSR	gameDeselect
		
@exit:
		RTS
		

;-------------------------------------------------------------------------------
uiActionFocusSquare:
;-------------------------------------------------------------------------------
		STA	game + GAME::varA
		
		TXA
		PHA
		
		JSR	uiActionDeselect
		
		LDA	game + GAME::varA
		JSR	gameSelect

		LDA	ui + UI::fActInt
		BEQ	@exit
		
		LDA	game + GAME::varA
		LDX	#$00
		JSR	rulesCalcQForSquare
		
		CMP	game + GAME::qVis
		BEQ	@focusskipv
		
		STA	game + GAME::qVis

		JSR	gamePlayersDirty
		
@focusskipv:
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		PLA
		TAX
		
		RTS

;-------------------------------------------------------------------------------
uiActionFault:
;-------------------------------------------------------------------------------
		LDA	#$01
		STA	cpuHaveFault
		STA	cpuFlagFault
		
		LDA	$69
		STA	cpuFaultPlayer
		
		LDA	$6A
		STA	cpuFaultAddr
		LDA	$6B
		STA	cpuFaultAddr + 1
		

		RTS


;-------------------------------------------------------------------------------
uiActionTrade:
;-------------------------------------------------------------------------------
;		LDY	#TRADE::player
;		LDA	trade0, Y

		LDA	$69			;byte 01 = player

		STA	game + GAME::pLast
		STA	game + GAME::pActive

;			- phase 0 - transfer deed
;		LDX	game + GAME::iTrdStp 
;		LDA	trddeeds1, X
		
		LDA	$6A			;byte 02 = square
		
		JSR	uiActionFocusSquare
		
;		LDA	trddeeds1, X
;		TAX

		LDX	$6A

		JSR	rulesTradeTitleDeed
		
		RTS

uiActionRepay:
;		LDY	#TRADE::player
;		LDA	trade0, Y

		LDA	$69			;byte 01 = player

		STA	game + GAME::pLast
		STA	game + GAME::pActive

;		LDX	game + GAME::iTrdStp 
;		LDA	trddeeds1, X

		LDA	$6A
		JSR	uiActionFocusSquare

;		LDA	trddeeds1, X
		LDA	$6A
		JSR	rulesUnmortgageImmed
		
;		JSR	gamePerfTradeDeselect

		RTS
		
uiActionFee:
;		LDY	#TRADE::player
;		LDA	trade0, Y

		LDA	$69			;byte 01 = player

		STA	game + GAME::pLast
		STA	game + GAME::pActive
		
;			- phase 1 - fee/repay deed
;		LDX	game + GAME::iTrdStp 
;		LDA	trdrepay1, X
;		AND	#$01
;		BNE	@stage0ph1repay

;		LDX	game + GAME::iTrdStp 
;		LDA	trddeeds1, X

		LDA	$6A
		JSR	uiActionFocusSquare

;		LDA	trddeeds1, X
		
		LDA	$6A
		JSR	rulesMortgageFeeImmed

		RTS
		
uiActionAuction:
;***TODO:	Probably should make a routine that toggles off interactive and
;		sets this, too.
		LDA	#$00
		STA	game + GAME::kWai
		
;		LDY	game + GAME::iTrdStp
;		LDA	trddeeds0, Y

		LDA	$6A
		STA	game + GAME::sAuctn

;		INC	game + GAME::iTrdStp

;		LDY	#TRADE::player
;		LDA	trade0, Y

		LDA	$69

		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast

		JSR	rulesDoNextPlyr

		LDX	#$01
		JSR	gameStartAuction
		
		RTS


uiActionMrtg:
		LDA	$69

		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		LDA	$6A
		JSR	uiActionFocusSquare
		
;		LDA	$6A
;		ASL
;		TAX
;		JSR	rulesMortgageImmed

		LDA	#$00
		STA	menuManage0CheckTrade
		
		JSR	rulesToggleMrtg

		RTS


uiActionSell:
		LDA	$69

		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		LDA	$6A
		JSR	uiActionFocusSquare
		
		LDA	$6A
		JSR	rulesPriorImprv

		RTS


uiActionBuy:
		LDA	$69

		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		TAX
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	game + GAME::varS
		INY
		LDA	($FB), Y
		STA	game + GAME::varT

		LDA	$6A
		JSR	uiActionFocusSquare

;		Need to load again, *ugh*
		LDX	$69
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

;	IN:	.X	=	square * 2
		LDA	$6A
		ASL
		TAX
		
;		varB 	=	group
		LDA	rulesSqr0, X
		STA	game + GAME::varB
		
;		varC	= 	group index
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC
		
;		varH	=	flag sub cash (0 = do it)
		LDA	#$00
		STA	game + GAME::varH

		JSR	rulesDoPurchDeed

;***TODO:	There is a bug somewhere causing this to go awry
		LDY	#PLAYER::money
		LDA	($FB), Y
		CMP	game + GAME::varS
		BNE	@exit
		INY
		LDA	($FB), Y
		CMP	game + GAME::varT
		BNE	@exit
		
		LDA	#<uiActionBuy
		STA	$6A
		LDA	#>uiActionBuy
		STA	$6B

		JSR	uiActionFault
		
@exit:
		RTS
		

uiActionImprv:
		LDA	$69

		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		LDA	$6A
		JSR	uiActionFocusSquare

		LDA	$6A
		JSR	rulesNextImprv
		
		RTS
		

uiActionGOFree:
		LDA	$69

		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		JSR	gameCheckGaolFree

		RTS
		

uiActionPost:
		LDA	$69

		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		LDX	#$01
		JSR	gameToggleGaol

		RTS
		

uiActionRoll:
		LDA	game + GAME::fMBuy
		BNE	@fault

		LDA	$69

		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		JSR	gameRollDice

		RTS
		
@fault:
		LDA	#<uiActionRoll
		STA	$6A
		LDA	#>uiActionRoll
		STA	$6B

		JSR	uiActionFault
		
		RTS
		
		
uiActionSendKey:
		LDA	$69
		JSR	keyEnqueueKey
		RTS
		
		
uiActionDelay:
		RTS


;==============================================================================
;FOR CPU.S
;==============================================================================
cpuLastActCnt:
		.byte	$00
cpuHaveMenuUpdate:
		.byte	$00
		
cpuLastPerform:	
		.word	$0000
cpuThisPerform:
		.word	cpuPerformIdle

cpuIsIdle:
		.byte	$00
cpuHaveFault:
		.byte	$00
cpuFaultPlayer:
		.byte	$00
cpuFaultAddr:
		.word	$0000
cpuFlagFault:
		.byte	$00
		

cpuEngageBehaviour:
		LDA	cpuHaveFault
		BNE	@havefault
		
		LDA	cpuHaveMenuUpdate
		BEQ	@update
		
		LDA	#>(@farreturn - 1)
		PHA
		LDA	#<(@farreturn - 1)
		PHA
		
		JMP	(cpuThisPerform)
@farreturn:
		LDA	cpuIsIdle
		BNE	@update

		LDA	ui + UI::cActns
		STA	cpuLastActCnt
		BEQ	@tstfault
		
		LDA	#$01
		STA	ui + UI::fActInt
		LDA	#$00
		STA	ui + UI::fActTyp
		
		JSR	uiProcessInit
		
@tstfault:		
		LDA	cpuLastActCnt
		BNE	@update
		
		LDA	cpuLastPerform
		CMP	cpuThisPerform 
		BNE	@update
		
		LDA	cpuLastPerform + 1
		CMP	cpuThisPerform + 1
		BNE	@update
		
@fault:
		LDA	#$01
		STA	cpuHaveFault
		STA	cpuFlagFault
		
		LDA	#<@fault
		STA	cpuFaultAddr
		LDA	#>@fault
		STA	cpuFaultAddr + 1
		
		JMP	@exit
		
@update:
		LDA	cpuThisPerform
		STA	cpuLastPerform
		LDA	cpuThisPerform + 1
		STA	cpuLastPerform + 1
		
@exit:
		LDA	#$00
		STA	cpuIsIdle
		
		RTS

@havefault:
		LDA	cpuFlagFault
		BEQ	@exit
		
		LDA	#$00
		STA	cpuFlagFault
		
		LDA 	#<dialogDlgNull0
		LDY	#>dialogDlgNull0
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog
		
		RTS
		

cpuPerformFault:
		LDA	#$01
		STA	cpuHaveFault
		STA	cpuFlagFault
		
		LDA	game + GAME::pActive
		STA	cpuFaultPlayer
		
		LDA	#<cpuPerformFault
		STA	cpuFaultAddr
		LDA	#>cpuPerformFault
		STA	cpuFaultAddr + 1
		
		
		RTS
		
		
cpuPerformIdle:
		LDA	#$01
		STA	cpuIsIdle
		
		RTS
		
cpuPerformPlay:
		LDA	game + GAME::fMBuy
		BEQ	@continue
		
		
		LDA	#UI_ACT_FALT
		STA	$68
		LDA	game + GAME::pActive
		STA	$69
		LDA	#<cpuPerformPlay
		STA	$6A
		LDA	#>cpuPerformPlay
		STA	$6B
		
		JSR	uiEnqueueAction
		
		RTS
		
@continue:
		JSR	rulesAutoPlay
		BNE	@exit
		
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'N'
		STA	$69
		
		JSR	uiEnqueueAction

		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction

@exit:
		RTS


cpuPerformBuy:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square
		LDA	($FB), Y
		TAX

		JSR	rulesAutoBuy
		BEQ	@passed
		
		RTS
		
@passed:
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'P'
		STA	$69
		
		JSR	uiEnqueueAction
		
		RTS


cpuPerformAuction:
		JSR	rulesAutoAuction
		
		RTS


cpuPerformTrade:
;***TODO:	Try to evaluate and accept

		LDA	#UI_ACT_SKEY
		STA	$68
	.if	DEBUG_CPU
		LDA	#'C'
	.else
		LDA	#'X'
	.endif
		STA	$69
		JSR	uiEnqueueAction
	
		RTS
		

cpuPerformElimin:
		LDY	#TRADE::player
		LDA	trade1, Y
		TAX
		JSR	rulesAutoEliminate

		RTS
		
		
cpuPerformGoneGaol:
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'N'
		STA	$69
		
		JSR	uiEnqueueAction
		
		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction
		
		RTS
		
		
cpuPerformInGaol:
		JSR	rulesAutoGaol

		RTS
		
		
cpuPerformGaolMustPost:
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'P'
		STA	$69
		
		JSR	uiEnqueueAction
		
		RTS
		
		
cpuPerformMustPay:
		JSR	rulesAutoPay

		RTS


cpuPerformQuit:
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'Y'
		STA	$69
		
		JSR	uiEnqueueAction
		
		RTS
		

cpuPerformSelectColour:
		LDA	sidV2EnvOu
		LSR
		LSR
		LSR
		LSR
		LSR
		STA	game + GAME::varA
		
		LDX	#$00
@loop:
		LDA	menuWindowSetup1Btns, X
		TAY
		LDA	menuWindowSetup1, Y
		CMP	#$AC
		BNE	@next
		
		LDA	game + GAME::varA
		BNE	@cont
		
		JMP	@select
		
@cont:
		DEC	game + GAME::varA
		
@next:
		INX
		CPX	#$0A
		BNE	@loop
		
		LDX	#$00
		BEQ	@loop
		
@select:
		TXA
		CLC
		ADC	#$30
		JSR	keyEnqueueKey
		
		LDA	#$01
		STA	ui + UI::fInjKey

		RTS


cpuPerformStartRoll:
		LDA	#'R'
		JSR	keyEnqueueKey
		
		LDA	#$01
		STA	ui + UI::fInjKey
		
		RTS


;==============================================================================
;FOR MENU.S
;==============================================================================


menuTemp0:
			.byte	$00
			.byte	$00
menuTemp3:
			.byte	$00, $00, $00, $00, $00, $00
menuTemp9:
			.byte	$00, $00, $00, $00, $00, $00
menuTempF:
			.byte	$00

menuLastSelBtn:
		.byte	$FF
		
menuLastDrawFunc:
		.word	$0000
		
menuDefWindow0:		
			.byte	$12, $01, $07, $11, $11
			.byte	$46, $00, $06, $12
			.byte	$47, $01, $18, $12
			.byte	$56, $00, $07, $11
			.byte	$57, $12, $07, $11
			.byte	$2B, $00, $06, $12
			.byte	$2B, $01, $18, $12
			.byte	$3B, $00, $07, $11
			.byte	$3B, $12, $07, $11
			
			.byte	$21, $01, $07, $11
			.byte	$23, $01, $08, $11

			.byte	$00

		
menuPageBlank0:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00			;Have to say 0 so not drawn
						;twice.
		.word	cpuPerformIdle
		
menuActivePage0:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00
		.word	cpuPerformFault
		
menuActivePage1:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00
		.word	cpuPerformFault
		
menuActivePage2:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00
		.word	cpuPerformFault
	
menuPagePlay0:
		.word	menuPagePlay0Keys
		.word	menuPagePlay0Draw
		.byte	$01
		.word	cpuPerformPlay
		
menuPagePlay1:
		.word	menuPagePlay1Keys
		.word	menuPagePlay1Draw
		.byte	$01
		.word	cpuPerformBuy
		
menuPagePlay2:
		.word	menuPagePlay2Keys
		.word	menuPagePlay2Draw
		.byte	$01
		.word	cpuPerformFault
		
menuPageAuctn0:
		.word	menuPageAuctn0Keys
		.word	menuPageAuctn0Draw
		.byte	$01
		.word	cpuPerformAuction
		
menuPageAuctn1:
		.word	menuPageAuctn1Keys
		.word	menuPageAuctn1Draw
		.byte	$01
		.word	cpuPerformFault
		
menuPageManage0:
		.word	menuPageManage0Keys
		.word	menuPageManage0Draw
		.byte	$01
		.word	cpuPerformFault
		
menuPageTrade0:
		.word	menuPageTrade0Keys
		.word	menuPageTrade0Draw
		.byte	$01
		.word	cpuPerformFault
		
menuPageTrade1:
		.word	menuPageTrade1Keys
		.word	menuPageTrade1Draw
		.byte	$01
		.word	cpuPerformTrade
		
;***TODO:	Rename and retext this menu
menuPageTrade6:
		.word	menuPageTrade6Keys
		.word	menuPageTrade6Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageElimin0:
		.word	menuPageElimin0Keys
		.word	menuPageElimin0Draw
		.byte	$01
		.word	cpuPerformElimin
		
menuPagePlyrSel0:
		.word	menuPagePlyrSel0Keys
		.word	menuPagePlyrSel0Draw
		.byte	$01
		.word	cpuPerformFault
		
menuPageGaol0:
		.word	menuPageGaol0Keys
		.word	menuPageGaol0Draw
		.byte	$01
		.word	cpuPerformGoneGaol
		
menuPageGaol1:
		.word	menuPageGaol1Keys
		.word	menuPageGaol1Draw
		.byte	$01
		.word	cpuPerformInGaol
		
menuPageGaol2:
		.word	menuPageGaol2Keys
		.word	menuPageGaol2Draw
		.byte	$01
		.word	cpuPerformFault
		
menuPageGaol3:
		.word	menuPageGaol3Keys
		.word	menuPageGaol3Draw
		.byte	$01
		.word	cpuPerformGaolMustPost
		
menuPageSetup0:
		.word	menuPageSetup0Keys
		.word	menuPageSetup0Draw
		.byte	$01
		.word	cpuPerformIdle

menuPageSetup1:
		.word	menuPageSetup1Keys
		.word	menuPageSetup1Draw
		.byte	$01
		.word	cpuPerformSelectColour

menuPageSetup2:
		.word	menuPageSetup2Keys
		.word	menuPageSetup2Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageSetup3:
		.word	menuPageSetup3Keys
		.word	menuPageSetup3Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageSetup4:
		.word	menuPageSetup4Keys
		.word	menuPageSetup4Draw
		.byte	$01
		.word	cpuPerformStartRoll
		
menuPageSetup5:
		.word	menuPageSetup5Keys
		.word	menuPageSetup5Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageSetup6:
		.word	menuPageSetup6Keys
		.word	menuPageSetup6Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageSetup7:
		.word	menuPageSetup7Keys
		.word	menuPageSetup7Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageSetup8:
		.word	menuPageSetup8Keys
		.word	menuPageSetup8Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageSetup9:
		.word	menuPageSetup9Keys
		.word	menuPageSetup9Draw
		.byte	$01
		.word	cpuPerformIdle
		
menuPageMustPay0:
		.word	menuPageMustPay0Keys
		.word	menuPageMustPay0Draw
		.byte	$01
		.word	cpuPerformMustPay
		
menuPageJump0:
		.word	menuPageJump0Keys
		.word	menuPageJump0Draw
		.byte	$01
		.word	cpuPerformIdle

menuPageQuit0:
		.word	menuPageQuit0Keys
		.word	menuPageQuit0Draw
		.byte	$01
		.word	cpuPerformFault

menuPageQuit1:
		.word	menuPageQuit1Keys
		.word	menuPageQuit1Draw
		.byte	$01
		.word	cpuPerformFault

menuPageQuit2:
		.word	menuPageQuit2Keys
		.word	menuPageQuit2Draw
		.byte	$01
		.word	cpuPerformQuit


;-------------------------------------------------------------------------------
menuDefDraw:
;-------------------------------------------------------------------------------
		LDA	#<menuDefWindow0
		STA	$FD
		LDA	#>menuDefWindow0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


;-------------------------------------------------------------------------------
menuDisplay:
;-------------------------------------------------------------------------------
		LDA	#$00
		STA	cpuHaveMenuUpdate
		
		LDA	#$00
		STA	ui + UI::fWntJFB
		
		LDA	ui + UI::iSelBtn
		STA	menuLastSelBtn
		
		JSR	screenBeginButtons
		
		LDA	#$FF
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1
		
		JSR	screenResetSelBtn
		
		LDA	#$01
		CMP	menuActivePage0 + MENUPAGE::bDef
		BNE	@cont
		
		JSR	menuDefDraw
@cont:
		LDA	#$00
		STA	screenRedirectNull

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::fCPU
		LDA	($FB), Y
		BEQ	@disp
		
		LDA	game + GAME::gMode
		CMP	#$08
		BEQ	@disp
		
		CMP	#$06
		BEQ	@disp
		
		LDA	#$01
		STA	screenRedirectNull

@disp:
		LDA	#>(@farreturn - 1)
		PHA
		LDA	#<(@farreturn - 1)
		PHA

		JMP	(menuActivePage0 + MENUPAGE::aDraw)
		
@farreturn:
		LDA	#$00
		STA	screenRedirectNull
		
		LDA	ui + UI::fMseEnb
		BNE	@reset

		LDA	ui + UI::fJskEnb
		BNE	@tstreset
	
		JMP	@tsthaveupdate
	
@tstreset:
		LDA	ui + UI::iSelBtn
		CMP	#$FF
		BNE	@tsthaveupdate
		
@reset:

		LDA	#$FF
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1
		
		JSR	screenResetSelBtn
		
@tsthaveupdate:
		LDA	game + GAME::pActive
		CMP	game + GAME::pLast
		BNE	@haveupdate

		LDA	menuActivePage0 + MENUPAGE::aDraw
		CMP	menuLastDrawFunc
		BNE	@haveupdate
		
		LDA	menuActivePage0 + MENUPAGE::aDraw + 1
		CMP	menuLastDrawFunc + 1
		BNE	@haveupdate
		
		LDA	menuLastSelBtn
		JSR	screenTestSelBtn
		BEQ	@exit
		
		LDA	menuLastSelBtn
		JSR	screenDoSelectBtn
		
		RTS

@haveupdate:
		LDA	#$01
		STA	cpuHaveMenuUpdate
		
		LDA	menuActivePage0 + MENUPAGE::aDraw
		STA	menuLastDrawFunc
		LDA	menuActivePage0 + MENUPAGE::aDraw + 1
		STA	menuLastDrawFunc + 1
		
@exit:
		RTS

;-------------------------------------------------------------------------------
menuSetPage:
;-------------------------------------------------------------------------------
		STA	$FD
		STY	$FE
		
		LDY	#MENUPAGE::aKeys
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::aKeys
		INY
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::aKeys + 1

		LDA	#$00
		STA	cpuHaveMenuUpdate

		LDY	#MENUPAGE::aDraw
		LDA	($FD), Y
		CMP	menuActivePage0 + MENUPAGE::aDraw
		BNE	@havedraw

		INY
		LDA	($FD), Y
		CMP	menuActivePage0 + MENUPAGE::aDraw + 1
		BEQ	@cont

@havedraw:
		LDA	#$01
		STA	cpuHaveMenuUpdate

@cont:
		LDY	#MENUPAGE::aDraw
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::aDraw
		INY
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::aDraw + 1

		LDY	#MENUPAGE::bDef
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::bDef
		
		LDY	#MENUPAGE::aCPU
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::aCPU
		INY
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::aCPU + 1
		RTS


;-------------------------------------------------------------------------------
menuPushPage:
;-------------------------------------------------------------------------------
		STA	$FD
;		STY	$FE

		LDX	#.sizeof(MENUPAGE) - 1
@loop:
		LDA	menuActivePage1, X
		STA	menuActivePage2, X
		
		LDA	menuActivePage0, X
		STA	menuActivePage1, X
		
		DEX
		BPL	@loop

		LDA	$FD
		JSR	menuSetPage

		RTS


;-------------------------------------------------------------------------------
menuPopPage:
;-------------------------------------------------------------------------------
		LDX	#.sizeof(MENUPAGE) - 1
@loop:
		LDA	menuActivePage1, X
		STA	menuActivePage0, X

		LDA	menuActivePage2, X
		STA	menuActivePage1, X
		
		LDA	menuPageBlank0, X
		STA	menuActivePage2, X

		DEX
		BPL	@loop

		RTS


menuPageBlank0Keys:
		RTS


menuWindowSetup0:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup0
			.byte	$90, $01, $08
			.word        strDescSetup0
			.byte	$A1, $0A, $01, $12, $32, $02, $0A
			.word	     strOptn0Setup0
			.byte	$A1, $0C, $01, $12, $33, $02, $0C
			.word	     strOptn1Setup0
			.byte	$A1, $0E, $01, $12, $34, $02, $0E
			.word	     strOptn2Setup0
			.byte	$A1, $10, $01, $12, $35, $02, $10
			.word	     strOptn3Setup0
			.byte	$A1, $12, $01, $12, $36, $02, $12
			.word	     strOptn4Setup0
			
			.byte	$00
			
			
menuPageSetup0Keys:
		CMP	#'2'
		BMI	@exit
		 
		CMP	#'7'
		BPL	@exit
		
		SEC
		SBC	#'0'
		PHA
			
		LDA	#$00
		STA	menuTemp0

		LDA 	#<menuPageSetup9
		LDY	#>menuPageSetup9
		
		JSR	menuSetPage

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		PLA

		STA	game + GAME::pCount

		CMP	#$06
		BEQ	@done
		
		TAX
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	#$00
		STA	($FB), Y
		
		LDA	#$A0
		LDY	#PLAYER::name + 8
@loopname:
		STA	($FB), Y
		DEY
		CPY	#PLAYER::name
		BNE	@loopname
		
		INX
		CPX	#$06
		BNE 	@loop
		
@done:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

@exit:
		RTS

						
menuPageSetup0Draw:
		LDA	#<menuWindowSetup0
		STA	$FD
		LDA	#>menuWindowSetup0
		STA	$FE
		
		JSR	screenPerformList

		RTS

menuWindowSetup1Btns:
		.byte	(menuWindowSetup1B0 - menuWindowSetup1)
		.byte	(menuWindowSetup1B1 - menuWindowSetup1)
		.byte	(menuWindowSetup1B2 - menuWindowSetup1)
		.byte	(menuWindowSetup1B3 - menuWindowSetup1)
		.byte	(menuWindowSetup1B4 - menuWindowSetup1)
		.byte	(menuWindowSetup1B5 - menuWindowSetup1)
		.byte	(menuWindowSetup1B6 - menuWindowSetup1)
		.byte	(menuWindowSetup1B7 - menuWindowSetup1)
		.byte	(menuWindowSetup1B8 - menuWindowSetup1)
		.byte	(menuWindowSetup1B9 - menuWindowSetup1)

menuWindowSetup1:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup0
			.byte	$90, $01, $08
			.word        strDescSetup1
			
menuWindowSetup1B0:
			.byte	$AC, $0A, $01, $12, $02, $30, $02, $0A
			.word	     strOptn0Setup1
menuWindowSetup1B1:
			.byte	$AC, $0B, $01, $12, $04, $31, $02, $0B
			.word	     strOptn1Setup1
menuWindowSetup1B2:
			.byte	$AC, $0C, $01, $12, $05, $32, $02, $0C
			.word	     strOptn2Setup1
menuWindowSetup1B3:
			.byte	$AC, $0D, $01, $12, $06, $33, $02, $0D
			.word	     strOptn3Setup1
menuWindowSetup1B4:
			.byte	$AC, $0E, $01, $12, $07, $34, $02, $0E
			.word	     strOptn4Setup1
menuWindowSetup1B5:
			.byte	$AC, $0F, $01, $12, $08, $35, $02, $0F
			.word	     strOptn5Setup1
menuWindowSetup1B6:
			.byte	$AC, $10, $01, $12, $09, $36, $02, $10
			.word	     strOptn6Setup1
menuWindowSetup1B7:
			.byte	$AC, $11, $01, $12, $0A, $37, $02, $11
			.word	     strOptn7Setup1
menuWindowSetup1B8:
			.byte	$AC, $12, $01, $12, $0D, $38, $02, $12
			.word	     strOptn8Setup1
menuWindowSetup1B9:
			.byte	$AC, $13, $01, $12, $0E, $39, $02, $13
			.word	     strOptn9Setup1

			.byte	$00


menuPageSetup1EnbAll:
		LDA	#<menuWindowSetup1
		STA	$A3
		LDA	#>menuWindowSetup1
		STA	$A4
		
		LDX	#$09
@loop:	
		LDA	menuWindowSetup1Btns, X
		TAY
		LDA	#$AC
		STA	($A3), Y
		
		DEX
		BPL	@loop
		
		RTS
		

menuPageSetup1Keys:
		CMP	#'0'
		BMI	@exit
		
		CMP	#$3A
		BPL	@exit

		SEC
		SBC	#'0'
		
		PHA
		
		TAY
		LDA	menuWindowSetup1Btns, Y
		TAY
		
		LDA	#<menuWindowSetup1
		STA	$A3
		LDA	#>menuWindowSetup1
		STA	$A4
		
		LDA	($A3), Y
		CMP	#$AC
		BNE	@buzz
		
		LDA	#$AD
		STA	($A3), Y
		
		LDX	menuTemp0
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::colour
		
		PLA
		TAX
		LDA	plrColours, X
				
		STA	($FB), Y		

		LDX	menuTemp0

		STA	vicSprClr1, X
	
		STA	irqBlinkSeq0		;Naughty but it will work in this
		STA	irqBlinkSeq0 + 1	;context

		JSR	statsClear

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDX	menuTemp0

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		
		
		INX
		STX	menuTemp0
		STX	game + GAME::pActive
		
		CPX	game + GAME::pCount
		BNE	@exit

		LDX	#$00
		STX	game + GAME::pActive
		
		LDA 	#<menuPageSetup2
		LDY	#>menuPageSetup2
		
		JSR	menuSetPage
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

@exit:
		RTS

@buzz:
		PLA
		
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS


menuPageSetup1Draw:
		LDA	#<menuWindowSetup1
		STA	$FD
		LDA	#>menuWindowSetup1
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuWindowSetup2:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup0
			.byte	$90, $01, $08
			.word        strDescSetup2
			.byte	$A1, $0A, $01, $12, $30, $02, $0A
			.word	     strOptn0Setup2
			.byte	$A1, $0C, $01, $12, $31, $02, $0C
			.word	     strOptn1Setup2
			.byte	$A1, $0E, $01, $12, $32, $02, $0E
			.word	     strOptn2Setup2
			
			.byte	$00

menuCashStartLow:	
			.word	1000
menuCashStartDef:	
			.word	1500
menuCashStartHigh:	
			.word	2000
			

menuPageSetup2Keys:
		CMP	#'0'
		BMI	@exit
		
		CMP	#'3'
		BPL	@exit
		
		SEC
		SBC	#'0'
		
		ASL
		TAX
		LDA	menuCashStartLow, X
		STA	menuTemp0
		LDA	menuCashStartLow + 1, X
		STA	menuTemp0 + 1

		LDX	#$00
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		LDA	menuTemp0
		STA	($FB), Y
		INY
		LDA	menuTemp0 + 1
		STA	($FB), Y
		
		INX
		CPX	#$06
		BNE	@loop

		LDX	#$00
		STX	game + GAME::pActive
		
		LDX	#$05
		LDA	#$00
@loop0:
		STA	menuTemp3, X
		STA	menuTemp9, X
		DEX
		BPL	@loop0
		
		LDA	#$00
		STA	menuTemp0
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA 	#<menuPageSetup6
		LDY	#>menuPageSetup6
		
		JSR	menuSetPage

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

@exit:
		RTS


menuPageSetup2Draw:
		LDA	#<menuWindowSetup2
		STA	$FD
		LDA	#>menuWindowSetup2
		STA	$FE
		
		JSR	screenPerformList
		
		RTS
		
		
menuWindowSetup3:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup3
			.byte	$90, $01, $08
			.word        strDescSetup3
			.byte	$90, $02, $0A
			.word	     strText0Setup3
			.byte	$90, $02, $0B
			.word	     strText1Setup3
			
			.byte	$A1, $0D, $01, $12, $4E, $02, $0D
			.word	     strOptn1Setup3
			.byte	$A1, $0F, $01, $12, $59, $02, $0F
			.word	     strOptn0Setup3
			
			.byte	$00

		
menuPageSetup3Keys:
		LDX	#$00
		STX	menuTemp0

		CMP	#'Y'
		BNE	@tstN
		
		LDA	#$01
		STA	menuTemp0
		
		JMP	@begin
		
@tstN:
		CMP	#'N'
		BEQ	@begin
		
		RTS
		
@begin:
		LDA	game + GAME::pActive
		STA	game + GAME::pLast
		
		LDA	menuTemp0
		STA	game + GAME::fShwNxt

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$00
		STA	menuTemp0

		LDA 	#<menuPageSetup5
		LDY	#>menuPageSetup5
		
		JSR	menuSetPage

		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		

menuPageSetup3Draw:
		LDA	#<menuWindowSetup3
		STA	$FD
		LDA	#>menuWindowSetup3
		STA	$FE
		
		JSR	screenPerformList

		RTS
		

strSetup4Roll0:		.byte	$03, $A0, $A0, $A0
strSetup4Roll1:		.byte	$03, $A0, $A0, $A0
strSetup4Roll2:		.byte	$03, $A0, $A0, $A0
strSetup4Roll3:		.byte	$03, $A0, $A0, $A0
strSetup4Roll4:		.byte	$03, $A0, $A0, $A0
strSetup4Roll5:		.byte	$03, $A0, $A0, $A0

strsSetup4RollLo:
		.byte	<(strSetup4Roll0 + 1), <(strSetup4Roll1 + 1) 
		.byte 	<(strSetup4Roll2 + 1), <(strSetup4Roll3 + 1)
		.byte 	<(strSetup4Roll4 + 1), <(strSetup4Roll5 + 1)
strsSetup4RollHi:
		.byte	>(strSetup4Roll0 + 1), >(strSetup4Roll1 + 1)
		.byte	>(strSetup4Roll2 + 1), >(strSetup4Roll3 + 1)
		.byte	>(strSetup4Roll4 + 1), >(strSetup4Roll5 + 1)


menuWindowSetup4:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup0
			.byte	$90, $01, $08
			.word        strDescSetup4
			.byte	$90, $02, $0A
			.word	     (plr0 + PLAYER::name)
			.byte	$90, $0D, $0A
			.word		strSetup4Roll0
			.byte	$90, $02, $0B
			.word	     (plr1 + PLAYER::name)
			.byte	$90, $0D, $0B
			.word		strSetup4Roll1
			.byte	$90, $02, $0C
			.word	     (plr2 + PLAYER::name)
			.byte	$90, $0D, $0C
			.word		strSetup4Roll2
			.byte	$90, $02, $0D
			.word	     plr3 + PLAYER::name
			.byte	$90, $0D, $0D
			.word		strSetup4Roll3
			.byte	$90, $02, $0E
			.word	     plr4 + PLAYER::name
			.byte	$90, $0D, $0E
			.word		strSetup4Roll4
			.byte	$90, $02, $0F
			.word	     plr5 + PLAYER::name
			.byte	$90, $0D, $0F
			.word		strSetup4Roll5
			
			.byte	$A1, $11, $01, $12
menuWindowSetup4K:
			.byte	$52, $02, $11
menuWindowSetup4O:
			.word	     strOptn0Play0
			
			.byte	$00
			
menuPageSetup4Keys:
		LDX	menuTemp0
		CPX	game + GAME::pCount
		BNE	@tstR
		
		CMP	#'B'
		BNE	@exit
		
		LDA	#musTuneStart
		JSR	SNDBASE + 0	

		LDA	#$C0
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		

;		JSR	rulesShuffleChest
;		JSR	rulesShuffleChance
		
		JSR	prmptClear
		
		LDA	#$00
		STA	game + GAME::kWai

		LDA	#$01
		STA	game + GAME::pVis

		JSR	gameUpdateMenu
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		

		JSR	gamePlayersDirty
		
		LDA	menuTemp0 + 1
		STA	game + GAME::pActive
		
		LDA	#$FF
		STA	game + GAME::pLast
		
		RTS
		
@tstR:
		CMP	#'R'
		BNE	@exit
	
		JSR 	numConvDieRoll
		LDX	menuTemp0
		STA	menuTemp3, X
		
		JSR 	numConvDieRoll
		LDX	menuTemp0
		STA	menuTemp9, X

		LDA 	sidV2EnvOu
		LSR
		LSR
		LSR
		LSR
		LSR
		LSR			
		CLC
		ADC	#musTuneDice0
		JSR	SNDBASE + 0	

		INC	menuTemp0
		LDA	game + GAME::pCount
		CMP	menuTemp0
		BNE	@cont
		
		LDA	#$00
		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		JSR	menuDoSetup4Highest
		RTS

@cont:
		INC	game + GAME::pActive

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		
		
@exit:
		RTS
		
		
menuDoSetup4Highest:
		LDX	#$00
		STX	menuTemp0 + 1
		STX	menuTempF
		
@loop:
		CLC
		LDA	menuTemp3, X
		ADC	menuTemp9, X
		
		CMP	menuTempF
		BMI	@next
		BEQ	@next
		
		STX	menuTemp0 + 1
		STA	menuTempF
		
@next:
		INX
		CPX	game + GAME::pCount
		BNE	@loop

		LDA	menuTemp0 + 1
		STA	game + GAME::pFirst

		LDA 	#<dialogDlgStart0
		LDY	#>dialogDlgStart0
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog
		
		RTS
		
		
menuPageSetup4Draw:
		LDX	#$00
@loop0:
		LDA	strsSetup4RollLo, X
		STA	$A3
		LDA	strsSetup4RollHi, X
		STA	$A4
		
		LDA	menuTemp3, X
		BEQ	@blank
		
		CLC
		ADC	#$B0
		LDY	#$00
		STA	($A3), Y

		LDA	menuTemp9, X
		CLC
		ADC	#$B0
		LDY	#$02
		STA	($A3), Y

		JMP	@next0
		
@blank:
		LDA	#$A0
		
		LDY	#$00
		STA	($A3), Y
		LDY	#$02
		STA	($A3), Y
	
@next0:
		INX
		CPX	game + GAME::pCount
		BNE	@loop0

		LDA	menuTemp0
		CMP	game + GAME::pCount
		BNE	@roll
		
		LDA	#$42
		STA	menuWindowSetup4K
		
		LDA	#<strOptn0Setup4
		STA	menuWindowSetup4O
		LDA	#>strOptn0Setup4
		STA	menuWindowSetup4O + 1
		
		JMP	@cont
		
@roll:
		LDA	#$52
		STA	menuWindowSetup4K
		
		LDA	#<strOptn0Play0
		STA	menuWindowSetup4O
		LDA	#>strOptn0Play0
		STA	menuWindowSetup4O + 1

@cont:
		LDA	#<menuWindowSetup4
		STA	$FD
		LDA	#>menuWindowSetup4
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuWindowSetup5:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup3
			.byte	$90, $01, $08
			.word        strDescSetup5
			.byte	$90, $02, $0A
			.word	     strText0Setup5
			.byte	$90, $02, $0B
			.word	     strText1Setup5
			
			.byte	$A1, $0D, $01, $12, $4E, $02, $0D
			.word	     strOptn1Setup3
			.byte	$A1, $0F, $01, $12, $59, $02, $0F
			.word	     strOptn0Setup3
			
			.byte	$00

		
menuPageSetup5Keys:
		LDX	#$00
		STX	menuTemp0

		CMP	#'Y'
		BNE	@tstN
		
		LDA	#$01
		STA	menuTemp0
		
		JMP	@begin
		
@tstN:
		CMP	#'N'
		BEQ	@begin
		
		RTS
		
@begin:
		LDA	menuTemp0
		STA	game + GAME::fDoJump

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$00
		STA	menuTemp0
		
;		LDA 	#<menuPageSetup0
;		LDY	#>menuPageSetup0
;		JSR	menuSetPage

		JSR	menuPopPage

		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		

menuPageSetup5Draw:
		LDA	#<menuWindowSetup5
		STA	$FD
		LDA	#>menuWindowSetup5
		STA	$FE
		
		JSR	screenPerformList

		RTS


menuWindowSetup6:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup0
			.byte	$90, $01, $08
			.word        strDescSetup6
			.byte	$A1, $0A, $01, $12, $46, $02, $0A
			.word	     strOptn0Setup6
			.byte	$A1, $14, $01, $12, $43, $02, $14
			.word	     strOptn0MustPay0
			
			.byte	$00
			
menuWindowSetup6FP:
			.byte	$90, $04, $0B
			.word		strText0Setup6
			.byte	$90, $04, $0C
			.word		strText1Setup6
			.byte	$00


menuPageSetup6SetTog:
		CMP	#$00
		BEQ	@off
		
		LDA	#$DA
		STA	strText1Setup6 + 1
		LDA	#$A0
		STA	strText0Setup6 + 1
		
		RTS
		
@off:
		LDA	#$DA
		STA	strText0Setup6 + 1
		LDA	#$A0
		STA	strText1Setup6 + 1
		
		RTS


menuPageSetup6DispFP:
		LDA	#<menuWindowSetup6FP
		STA	$FD
		LDA	#>menuWindowSetup6FP
		STA	$FE
		
		JSR	screenPerformList
		
		RTS
		

menuPageSetup6Keys:
		CMP	#'F'
		BNE	@keysC
		
		LDA	game + GAME::fFPTax
		EOR	#$01
		STA	game + GAME::fFPTax
		
		JSR	menuPageSetup6SetTog
		JSR	menuPageSetup6DispFP
		
		JMP	@keysDing
		
@keysC:
		CMP	#'C'
		BNE	@keysExit
		
		LDA	#$00
		STA	menuTemp0
		
		LDA 	#<menuPageSetup4
		LDY	#>menuPageSetup4
		
		JSR	menuSetPage

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing
		
@keysExit:
		RTS

@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS


menuPageSetup6Draw:
		LDA	#<menuWindowSetup6
		STA	$FD
		LDA	#>menuWindowSetup6
		STA	$FE
		
		JSR	screenPerformList

		JSR	menuPageSetup6SetTog
		JSR	menuPageSetup6DispFP
		
		RTS

menuWindowSetup7:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup7
			.byte	$90, $01, $08
			.word        strDescSetup7
			
			.byte	$AF, $00, $00, $01, $20, $00, $00
			.word		strDummyDummy0
			
			.byte	$A1, $0A, $01, $12, $59, $02, $0A
			.word	     strOptn0Setup7
			.byte	$A1, $0C, $01, $12, $4E, $02, $0C
			.word	     strOptn1Setup7
			.byte	$A1, $0E, $01, $12, $4E, $02, $0E
			.word	     strOptn2Setup7
			
			.byte	$00


menuPageSetup7Keys:
		CMP	#' '
		BNE	@tstK
		
		LDA	JoyUsed
		BNE	@doJsk
		
		LDA	MouseUsed
		BNE	@doMse
		
		RTS

@tstK:
		CMP	#'K'
		BNE	@tstM

		LDA	#$FF
		STA	ui + UI::iSelBtn
		
		JMP	@nojoy	
		
@tstM:
		CMP	#'M'
		BNE	@tstJ
	
@doMse:	
		JSR	initMouse
		
		JMP	@nojoy
		
@tstJ:
		CMP	#'J'
		BNE	@exit

@doJsk:
		LDA	#$01
		STA	ui + UI::fJskEnb
		LDA	#$00
		STA	ui + UI::fMseEnb
		
		LDA 	#<menuPageSetup0
		LDY	#>menuPageSetup0
		JSR	menuSetPage
		
		LDA 	#<menuPageSetup3
		LDY	#>menuPageSetup3
		JSR	menuPushPage		
		
		LDA 	#<menuPageSetup8
		LDY	#>menuPageSetup8
		JSR	menuPushPage		
		
		JMP	@cont
		
@nojoy:
		LDA 	#<menuPageSetup0
		LDY	#>menuPageSetup0
		JSR	menuSetPage

		LDA 	#<menuPageSetup3
		LDY	#>menuPageSetup3
		JSR	menuPushPage
		
@cont:
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
@exit:
		RTS


menuPageSetup7Draw:
		LDA	#$00
		STA	JoyUsed
		STA	MouseUsed

		LDA	#$00
		STA	ui + UI::iSelBtn

		LDA	#<menuWindowSetup7
		STA	$FD
		LDA	#>menuWindowSetup7
		STA	$FE
		
		JSR	screenPerformList

		RTS


menuWindowSetup8:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup7
			.byte	$90, $01, $08
			.word        strDescSetup8
			
			.byte	$A1, $0A, $01, $12, $4C, $02, $0A
			.word	     strOptn0Setup8
			.byte	$A1, $0C, $01, $12, $4D, $02, $0C
			.word	     strOptn1Setup8
			.byte	$A1, $0E, $01, $12, $48, $02, $0E
			.word	     strOptn2Setup8
			
			.byte	$00


menuPageSetup8Keys:
		CMP	#'L'
		BNE	@keysM
		
		LDA	#JSTKSENS_LOW
		JMP	@update
		
@keysM:
		CMP	#'M'
		BNE	@keysH
		
		LDA	#JSTKSENS_MED
		JMP	@update
		
@keysH:
		CMP	#'H'
		BNE	@exit
		
		LDA	#JSTKSENS_HIGH
		
@update:
		STA	ui + UI::cJskSns
		
;		LDA 	#<menuPageSetup3
;		LDY	#>menuPageSetup3
;		JSR	menuSetPage

		JSR	menuPopPage
		
		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

@exit:
		RTS
		

menuPageSetup8Draw:
		LDA	#<menuWindowSetup8
		STA	$FD
		LDA	#>menuWindowSetup8
		STA	$FE
		
		JSR	screenPerformList

		RTS


menuWindowSetup9BN:
		.byte	(menuWindowSetup9B0 - menuWindowSetup9)
		.byte	(menuWindowSetup9B1 - menuWindowSetup9)
		.byte	(menuWindowSetup9B2 - menuWindowSetup9)
		.byte	(menuWindowSetup9B3 - menuWindowSetup9)
		.byte	(menuWindowSetup9B4 - menuWindowSetup9)
		.byte	(menuWindowSetup9B5 - menuWindowSetup9)

menuWindowSetup9:	
			.byte	$90, $01, $07
			.word	     strHeaderSetup0
			.byte	$90, $01, $08
			.word        strDescSetup9
			
menuWindowSetup9B0:
			.byte	$A1, $0A, $01, $12, $30, $02, $0A
			.word	     strOptn0Setup9
menuWindowSetup9B1:
			.byte	$A1, $0C, $01, $12, $31, $02, $0C
			.word	     strOptn1Setup9
menuWindowSetup9B2:
			.byte	$A1, $0E, $01, $12, $32, $02, $0E
			.word	     strOptn0Setup0
menuWindowSetup9B3:
			.byte	$A1, $10, $01, $12, $33, $02, $10
			.word	     strOptn1Setup0
menuWindowSetup9B4:
			.byte	$A1, $12, $01, $12, $34, $02, $12
			.word	     strOptn2Setup0
menuWindowSetup9B5:
			.byte	$A1, $14, $01, $12, $35, $02, $14
			.word	     strOptn3Setup0
			
			.byte	$00
			
menuPageSetup9Keys:
		CMP	#'0'
		BPL	@tstupper
		
		JMP	@exit

@tstupper:
		CMP	#'5'
		BMI	@begin
		
		JMP	@exit
		
@begin:
		SEC
		SBC	#'0'

		CMP	#$00
		BEQ	@done
		
		LDX	game + GAME::pCount
		STX	game + GAME::varA
		
		CMP	game + GAME::varA
		BPL 	@exit

		STA	game + GAME::varA
		SEC
		LDA	game + GAME::pCount
		SBC	game + GAME::varA
		TAX

		LDA	#$01
		STA	game + GAME::varC
		
@loop0:		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::fCPU
		LDA	#$01
		STA	($FB), Y
		
		LDA	game + GAME::varC
		CLC
		ADC	#$B0
		
		INC	game + GAME::varC
		
		LDY	#$05
		STA	cpuDefName, Y
		
		LDA	plrNameLo, X
		STA	$FB
		LDA	plrNameHi, X
		STA	$FC
		
		LDY	#$08
@loop1:
		LDA	cpuDefName, Y
		STA	($FB), Y
		DEY
		BPL	@loop1
		
@next0:
		INX
		CPX	game + GAME::pCount
		BNE	@loop0

@done:
		LDA	#$00
		STA	menuTemp0
		JSR	menuPageSetup1EnbAll

		LDA 	#<menuPageSetup1
		LDY	#>menuPageSetup1
		
		JSR	menuSetPage

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
@exit:
		RTS


menuPageSetup9Draw:
		LDX	#$02
@loop0:
		LDA	menuWindowSetup9BN, X
		TAY
		LDA	#$A2
		STA	menuWindowSetup9, Y
		INX
		CPX	#$06
		BNE	@loop0
		
		LDX	game + GAME::pCount
@loop1:
		CPX	#$02
		BEQ	@disp

		DEX

		LDA	menuWindowSetup9BN, X
		TAY
		LDA	#$A1
		STA	menuWindowSetup9, Y
		
		JMP	@loop1

@disp:
		LDA	#<menuWindowSetup9
		STA	$FD
		LDA	#>menuWindowSetup9
		STA	$FE
		
		JSR	screenPerformList

		RTS


menuWindowPlay0:	
			.byte	$90, $01, $07
			.word	     	strHeaderPlay0
			.byte	$90, $01, $08
menuWindowPlay0D:	
			.word		strDummyDummy0
			.byte	$90, $0C, $08
			.word        	strDescGaol1

menuWindowPlay0RollB:
			.byte	$A1, $0A, $01, $12, $52, $02, $0A
			.word	     	strOptn0Play0
menuWindowPlay0NextB:
			.byte	$A1, $0C, $01, $12, $4E, $02, $0C
			.word	     	strOptn1Play0
			.byte	$A1, $0E, $01, $12, $4D, $02, $0E
			.word	     	strOptn2Play0
menuWindowPlay0Trd:
			.byte	$A1, $10, $01, $12, $54, $02, $10
			.word		strOptn3Play0
			.byte	$A1, $12, $01, $12, $56, $02, $12
			.word		strOptn4Play0
			.byte	$A1, $14, $01, $12, $2E, $02, $14
			.word		strOptn2Gaol1
			
			.byte	$00
			
menuFooterGame0:
			.byte	$A3, $16, $01, $09, keyF5, $01, $16
			.word		strOptn0Ftr0
			.byte	$A3, $16, $0A, $12, keyF7, $0A, $16
			.word		strOptn1Ftr0
			.byte	$A3, $17, $01, $09, keyF3, $01, $17
			.word		strOptn2Ftr0
			.byte	$A3, $17, $0A, $12, keyF1, $0A, $17
			.word		strOptn3Ftr0
			
			.byte	$00


menuPagePlay0DefKeys:
@keys1:
		CMP	#keyF1
		BNE	@keys2
		
		LDA	#$00
		JMP	@keysTstQuad
		
@keys2:
		CMP	#keyF3
		BNE	@keys3
		
		LDA	#$01
		JMP	@keysTstQuad
		
@keys3:
		CMP	#keyF5
		BNE	@keys4
		
		LDA	#$02
		JMP	@keysTstQuad
		
@keys4:
		CMP	#keyF7
		BNE	@keysM
		
		LDA	#$03
		JMP	@keysTstQuad
		
@keysM:
		CMP	#'M'
		BNE	@keysT
		
		LDA	#$00
		STA	menuManage0CheckTrade
		
		JSR	gameToggleManage
		JMP	@keysDing
@keysT:
		CMP	#'T'
		BNE	@keysV

		LDA	game + GAME::gMode
		CMP	#$03
		BMI	@tstFunds
		
		JMP	@keysBuzz
		
@tstFunds:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money + 1
		LDA	($FB), Y
		BPL	@trade
		
		JMP	@keysBuzz

@trade:
		JSR	gameInitiateTrade
		JMP	@keysDing
		
@keysV:
		CMP	#'V'
		BNE	@keysS
		
		JSR	gameToggleDialog
		JMP	@keysDing
		
@keysS:
		CMP	#'S'
		BNE	@keysExit
		
		LDA	game + GAME::gMode
		CMP	#$03
		BPL	@keysExit
		
		LDA	#<gameInitiatePStats
		STA	menuPlyrSelCallProc
		LDA	#>gameInitiatePStats
		STA	menuPlyrSelCallProc + 1

		LDA	#$01
		STA	menuPlyrSelAllowCur
		
		LDA	#<menuPagePlyrSel0
		LDY	#>menuPagePlyrSel0
		
		JSR	menuPushPage
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing
		
@keysTstQuad:
		CMP	game + GAME::qVis
		BEQ	@keysExit
		
		STA	game + GAME::qVis

		JSR	gamePlayersDirty
		
@keysDirty:
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

@keysExit:
		RTS

@keysBuzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS


menuPagePlay0StdKeys:
		CMP	#'A'
		BNE	@keysQ
		
		JSR	rulesAutoPay
		
		LDA	ui + UI::cActns
		BNE	@autopay
		
		JMP	@keysDing
		
@autopay:
		LDA	#$01
		STA	ui + UI::fActInt
		LDA	#$00
		STA	ui + UI::fActTyp
		
		JSR	uiProcessInit
		
		JMP	@keysDing
		
@keysQ:
		CMP	#'Q'			
		BNE	@keysN			
						
		LDA	#<menuPageQuit0
		LDY	#>menuPageQuit1
		
		JSR	menuSetPage
		
		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing
@keysN:
		CMP	#'N'
		BNE	@keysR

		LDX	menuWindowPlay0NextB
		CPX	#$A1
		BEQ	@donext
		
		JMP	@keysBuzz
		
@donext:
		JSR	rulesNextTurn
		JMP	@keysDing
		
@keysR:
		CMP	#'R'
		BNE	@keysO
		
		LDX	menuWindowPlay0RollB
		CPX	#$A1
		BNE	@keysBuzz
		
		JSR	gameRollDice
		JMP	@keysExit
		
@keysO:
		CMP	#'O'
		BNE	@keysC

		LDA	#<menuPagePlay0
		LDY	#>menuPagePlay0
		JSR	menuSetPage
		
		LDA	#<menuPageSetup3
		LDY	#>menuPageSetup3
		JSR	menuPushPage
		
		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing

@keysC:
		CMP	#'C'
	.if	DEBUG_KEYS
		BNE	@keysL
	.else
		BNE	@keysOther
	.endif

		LDA	#<menuPagePlay0
		LDY	#>menuPagePlay0
		JSR	menuSetPage
		
		LDA	#<menuPageSetup8
		LDY	#>menuPageSetup8
		JSR	menuPushPage
		
		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing


	.if	DEBUG_KEYS
@keysL:
		CMP	#'L'
		BNE	@keysI
		
		JSR	rulesLandOnSquare
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		JSR	gameUpdateMenu
		RTS
		
@keysI:
		CMP	#'I'
		BNE	@keysOther
		
		JSR	rulesAutoImprove
		
		LDA	ui + UI::cActns
		BEQ	@keysDing
		
		LDA	#$01
		STA	ui + UI::fActInt
		LDA	#$00
		STA	ui + UI::fActTyp
		
		JSR	uiProcessInit
		
		JMP	@keysDing
		
	.endif
		
@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

@keysExit:		
		RTS

@keysOther:
		JSR	menuPagePlay0DefKeys
		RTS
		
@keysBuzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS


;-------------------------------------------------------------------------------
menuPagePlay0Keys:
;-------------------------------------------------------------------------------
		CMP	#'.'
		BNE	@keysStd
		
		LDA	#<menuPagePlay2
		LDY	#>menuPagePlay2
		
		JSR	menuSetPage
		
		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing
		
@keysStd:
		JSR	menuPagePlay0StdKeys
	
		RTS

@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS

menuPagePlay0Draw:
		LDA	game + GAME::dieDbl
		BEQ	@nodesc
		
		LDA	#<strDescPlay0
		STA	menuWindowPlay0D
		LDA	#>strDescPlay0
		STA	menuWindowPlay0D + 1
		
		JMP	@begin

@nodesc:
		LDA	#<strDummyDummy0
		STA	menuWindowPlay0D
		LDA	#>strDummyDummy0
		STA	menuWindowPlay0D + 1
		
@begin:
		LDA	#<menuWindowPlay0
		STA	$FD
		LDA	#>menuWindowPlay0
		STA	$FE
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	#$A0
		STA	menuWindowPlay0RollB
		STA	menuWindowPlay0NextB
		STA	menuWindowPlay0Trd
		
		LDY	#PLAYER::money + 1
		
		LDA	($FB), Y
		BPL	@cantrade
		
		JMP	@cont
		
@cantrade:
		LDA	#$A1
		STA	menuWindowPlay0Trd
		
		LDA	game + GAME::cntHs
		BMI	@cont
		
		LDA	game + GAME::cntHt
		BMI	@cont
		
		LDA	#$01
		CMP	game + GAME::dieRld
		BNE	@canroll

@cannext:
		LDA	#$A1
		STA	menuWindowPlay0NextB
		
		JMP	@cont
		
@canroll:
		LDA	#$A1
		STA	menuWindowPlay0RollB
		
@cont:
		JSR	screenPerformList

		LDA	#<menuFooterGame0
		STA	$FD
		LDA	#>menuFooterGame0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuWindowPlay1:
			.byte	$90, $01, $07
			.word	     	strHeaderPlay1

menuWindowPlay1BuyB:
			.byte	$A1, $0A, $01, $12, $42, $02, $0A
			.word	     	strOptn0Play1
			.byte	$A1, $0C, $01, $12, $50, $02, $0C
			.word	     	strOptn1Play1
			.byte	$A1, $0E, $01, $12, $4D, $02, $0E
			.word	     	strOptn2Play0
menuWindowPlay1Trd:
			.byte	$A1, $10, $01, $12, $54, $02, $10
			.word		strOptn3Play0
			.byte	$A1, $12, $01, $12, $56, $02, $12
			.word		strOptn4Play0
			.byte	$A1, $14, $01, $12, $53, $02, $14
			.word		strOptn5Play0
			
			.byte	$00
		

menuPagePlay1Keys:
@keysB:
		CMP	#'B'
		BNE	@keysP
		
		LDA	menuWindowPlay1BuyB
		CMP	#$A1
		BNE	@keysBuzz
		
		JSR	gameBuyTitleDeed
		JMP	@keysDirty

@keysP:
		CMP	#'P'
		BNE	@keysOther
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDY	#PLAYER::square		;store the square being auctioned
		LDA	($FB), Y
		STA	game + GAME::sAuctn

		LDX	#$00
		JSR	gameStartAuction

@keysDirty:
		LDA	#$00
		STA	game + GAME::fMBuy

		JSR	gameUpdateMenu

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
				
@keysExit:		
		RTS

@keysOther:
		JSR	menuPagePlay0DefKeys
		RTS

@keysBuzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
		
menuPagePlay1Draw:
		LDA	#$A1
		STA	menuWindowPlay1BuyB
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	#$A0
		STA	menuWindowPlay1Trd
		
		LDY	#PLAYER::money + 1
		BMI	@cont

		LDA	#$A1
		STA	menuWindowPlay1Trd

@cont:
		LDY	#PLAYER::square
		LDA	($FB), Y

		JSR	gameGetCardPtrForSquare

		LDY	#DEED::pPurch
		LDA	($FD), Y
		STA	menuTemp0
		INY
		LDA	($FD), Y
		STA	menuTemp0 + 1

		SEC
		LDY	#PLAYER::money
		LDA	($FB), Y
		SBC	menuTemp0
		INY	
		LDA	($FB), Y
		SBC	menuTemp0 + 1
		BPL	@skip		

		LDA	#$A0
		STA	menuWindowPlay1BuyB

@skip:
		LDA	#<menuWindowPlay1
		STA	$FD
		LDA	#>menuWindowPlay1
		STA	$FE
		
		JSR	screenPerformList

		LDA	#<menuFooterGame0
		STA	$FD
		LDA	#>menuFooterGame0
		STA	$FE
		
		JSR	screenPerformList

		RTS



menuWindowPlay2:	
			.byte	$90, $01, $07
			.word	     	strHeaderPlay0
			.byte	$90, $01, $08
menuWindowPlay2D:	
			.word		strDummyDummy0
			.byte	$90, $0C, $08
			.word        	strDescGaol2

			.byte	$A1, $0A, $01, $12, $53, $02, $0A
			.word	     	strOptn5Play0
			.byte	$A1, $0C, $01, $12, $4F, $02, $0C
			.word	     	strOptn6Play0
			.byte	$A1, $0E, $01, $12, $43, $02, $0E
			.word	     	strOptn7Play0
			.byte	$A1, $10, $01, $12, $51, $02, $10
			.word		strOptn8Play0

			.byte	$A1, $14, $01, $12, $2E, $02, $14
			.word		strOptn2Gaol1
			
			.byte	$00
			
			
;-------------------------------------------------------------------------------
menuPagePlay2Keys:
;-------------------------------------------------------------------------------
		CMP	#'.'
		BNE	@keysStd
		
		LDA	#<menuPagePlay0
		LDY	#>menuPagePlay0
		
		JSR	menuSetPage
		
		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing
		
@keysStd:
		JSR	menuPagePlay0StdKeys
	
		RTS

@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS


menuPagePlay2Draw:
		LDA	game + GAME::dieDbl
		BEQ	@nodesc
		
		LDA	#<strDescPlay0
		STA	menuWindowPlay2D
		LDA	#>strDescPlay0
		STA	menuWindowPlay2D + 1
		
		JMP	@begin

@nodesc:
		LDA	#<strDummyDummy0
		STA	menuWindowPlay2D
		LDA	#>strDummyDummy0
		STA	menuWindowPlay2D + 1
		
@begin:
		LDA	#<menuWindowPlay2
		STA	$FD
		LDA	#>menuWindowPlay2
		STA	$FE

		JSR	screenPerformList
		
		RTS
		

menuPageAuctnAmt0:
			.byte	$06, $00, $00, $00, $00, $00, $00, $00


menuWindowAuctn0:
			.byte	$90, $01, $07
			.word	     	strHeaderAuctn0
			.byte	$90, $0C, $08
			.word        	strDescGaol1
			
			.byte	$90, $02, $0A
			.word	     	strOptn1Auctn0
			.byte	$90, $0B, $0A
			.word		menuPageAuctnAmt0

			.byte	$2F, $01, $0B, $11
			.byte	$2F, $01, $0C, $11
			
			.byte	$A4, $0B, $0E, $0F, $55, $00, $00
			.word		strDummyDummy0
			.byte	$A4, $0B, $0F, $10, $49, $00, $00
			.word		strDummyDummy0
			.byte	$A4, $0B, $10, $11, $4F, $00, $00
			.word		strDummyDummy0
			.byte	$90, $02, $0B
			.word	     	strOptn0Auctn0
			
			.byte	$A4, $0C, $0E, $0F, $4A, $00, $00
			.word		strDummyDummy0
			.byte	$A4, $0C, $0F, $10, $4B, $00, $00
			.word		strDummyDummy0
			.byte	$A4, $0C, $10, $11, $4C, $00, $00
			.word		strDummyDummy0
			.byte	$90, $02, $0C
			.word	     	strOptn2Auctn0

menuWindowAuctn0Bid:
			.byte	$A1, $0E, $01, $12, $42, $02, $0E
			.word	     	strOptn3Auctn0
			.byte	$A1, $10, $01, $12, $50, $02, $10
			.word	     	strOptn4Auctn0
			.byte	$A1, $12, $01, $12, $46, $02, $12
			.word	     	strOptn5Auctn0
			
			.byte	$A1, $14, $01, $12, $2E, $02, $14
			.word		strOptn2Gaol1
			
			.byte	$00
		
		
menuPageAuctn0Inc:
		CLC
		ADC	game + GAME::mACurr
		STA	game + GAME::mACurr
		LDA	game + GAME::mACurr + 1
		ADC	#0
		STA	game + GAME::mACurr + 1
		
		BPL	@exit
	
		LDA	#$FF
		STA	game + GAME::mACurr
		LDA	#$7F
		STA	game + GAME::mACurr + 1

@exit:
		RTS

menuPageAuctn0Dec:
		STA	game + GAME::varA
		
		LDA	game + GAME::mACurr
		BNE	@cont
		
		LDA	game + GAME::mACurr + 1
		BNE	@cont
		
		RTS

@cont:
		SEC
		LDA	game + GAME::mACurr
		SBC	game + GAME::varA
		STA	game + GAME::mACurr
		LDA	game + GAME::mACurr + 1
		SBC	#0
		STA	game + GAME::mACurr + 1
		
		RTS
		
menuPageAuctn0Bid:
		LDA	game + GAME::mACurr	;Make bid amount current amount
		STA	game + GAME::mAuctn
		LDA	game + GAME::mACurr + 1
		STA	game + GAME::mAuctn + 1
		
		LDA	game + GAME::pActive	;This player bid
		STA	game + GAME::pWAuctn
		STA	game + GAME::pAFirst	;Make them the auction starter
		
		LDA	game + GAME::fAForf	;Reset the passed players
		STA	game + GAME::fAPass

		RTS
		
menuPageAuctn0Pass:
		LDX	game + GAME::pActive	;This player passed
		LDA	plrFlags, X
		ORA	game + GAME::fAPass
		STA	game + GAME::fAPass
		
		RTS

menuPageAuctn0Forf:
		LDX	game + GAME::pActive	;This player forfeited
		LDA	plrFlags, X
		ORA	game + GAME::fAForf
		STA	game + GAME::fAForf
		
		LDA	plrFlags, X		;Set to pass in this round, too
		ORA	game + GAME::fAPass
		STA	game + GAME::fAPass
		
		RTS


menuPageAuctnDefKeys:
		CMP	#'U'
		BNE	@keysJ
		
		LDA	#100
		JSR	menuPageAuctn0Inc
		JMP	@tstHaveFunds
		
@keysJ:
		CMP	#'J'
		BNE	@keysI
		
		LDA	#100
		JSR	menuPageAuctn0Dec
		
		JMP	@tstCurrBid

@keysI:
		CMP	#'I'
		BNE	@keysK
		
		LDA	#10
		JSR	menuPageAuctn0Inc
		JMP	@tstHaveFunds
		
@keysK:
		CMP	#'K'
		BNE	@keysO
		
		LDA	#10
		JSR	menuPageAuctn0Dec
		
		JMP	@tstCurrBid

@keysO:
		CMP	#'O'
		BNE	@keysL
		
		LDA	#1
		JSR	menuPageAuctn0Inc
		JMP	@tstHaveFunds

@keysL:
		CMP	#'L'
		BNE	@keysB
		
		LDA	#1
		JSR	menuPageAuctn0Dec
		
		JMP	@tstCurrBid
		
@keysB:	
		CMP	#'B'
		BNE	@keysP
		
		LDA	game + GAME::mACurr
		LDY	game + GAME::mACurr + 1
		
;		So, if money less than A, Y - clear carry else set
		JSR	gamePlayerHasFunds
		BCS	@beginbid
		
		JMP	@keysBuzz
		
@beginbid:
		LDA	game + GAME::pWAuctn	;Has there been a bid?
		CMP	#$FF
		BEQ	@dobid			;no, so bid
		
		LDA	game + GAME::mACurr	;Did they enter the last value?
		CMP	game + GAME::mAuctn
		BNE	@dobid
		
		LDA	game + GAME::mACurr + 1
		CMP	game + GAME::mAuctn + 1
		BNE	@dobid
		JMP	@keysExit		;Yes, so don't do anything
		
@dobid:
		LDA	game + GAME::mACurr
		STA	game + GAME::varD
		LDA	game + GAME::mACurr + 1
		STA	game + GAME::varE

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		LDY 	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptBid

		JSR	menuPageAuctn0Bid
		JSR	rulesNextTurn
		JMP	@keysUpdateAll
		
@keysP:
		CMP	#'P'
		BNE	@keysF

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		LDY 	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptPass
		
		JSR	menuPageAuctn0Pass
		JSR	rulesNextTurn
		JMP	@keysUpdateAll
		

@keysF:
		CMP	#'F'
		BEQ	@forfeit
		JMP	@keysOther
		
@forfeit:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		LDY 	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptForfeit
		
		JSR	menuPageAuctn0Forf
		JSR	rulesNextTurn
		JMP	@keysUpdateAll
		
@tstCurrBid:
		LDA	game + GAME::mACurr
		STA	game + GAME::varD
		LDA	game + GAME::mACurr + 1
		STA	game + GAME::varE
		
		LDA	game + GAME::mAuctn
		LDY	game + GAME::mAuctn + 1
		
;		D, E < A, Y -> CLC | SEC
		JSR	gameAmountIsLess	;If trying to bid less...
		BCS	@keysUpdate

		LDA	game + GAME::mAuctn	;reset the bid
		STA	game + GAME::mACurr
		LDA	game + GAME::mAuctn + 1
		STA	game + GAME::mACurr + 1
		
		JMP	@keysBuzz		
		
@tstHaveFunds:
		LDA	game + GAME::mACurr
		LDY	game + GAME::mACurr + 1
		
;		So, if money less than A, Y - clear carry else set
		JSR	gamePlayerHasFunds
		BCS	@keysUpdate
		
		LDY	#PLAYER::money		;This is safe since $FB was loaded
		LDA	($FB), Y		;in gamePlayerHasFunds
		STA	game + GAME::mACurr
		INY
		LDA	($FB), Y
		STA	game + GAME::mACurr + 1
		
		JMP	@keysBuzz

@keysUpdate:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
@keysRealUpd:
		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@keysExit:
		RTS
		
@keysUpdateAll:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		
@keysBuzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		JMP	@keysRealUpd

@keysOther:
		JSR	menuPagePlay0DefKeys
		RTS


menuPageAuctn0Keys:
		CMP	#'.'
		BNE	@keysDefault
		
		LDA 	#<menuPageAuctn1
		LDY	#>menuPageAuctn1
		JSR	menuSetPage

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	game + GAME::dirty
		ORA	#$08
		STA	game + GAME::dirty

		RTS

@keysDefault:
		JSR	menuPageAuctnDefKeys
		
		RTS


menuPageAuctn0Draw:
		LDA	game + GAME::mACurr
		LDY	game + GAME::mACurr + 1
		
;		So, if money less than A, Y - clear carry else set
		JSR	gamePlayerHasFunds
		BCS	@havefunds
		
		LDA	#$A0
		STA	menuWindowAuctn0Bid
		
		JMP	@beginbid
		
@havefunds:
		LDA	#$A1
		STA	menuWindowAuctn0Bid

@beginbid:
		LDA	game + GAME::mACurr
		STA	Z:numConvVALUE
		LDA	game + GAME::mACurr + 1
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop:
		LDA	heap0, X
		ORA	#$80
		STA	menuPageAuctnAmt0 + 1, X
		DEX
		BPL	@loop
		
		LDA	#<menuWindowAuctn0
		STA	$FD
		LDA	#>menuWindowAuctn0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS
		
menuWindowAuctn1:	
			.byte	$90, $01, $07
			.word	     	strHeaderAuctn0
			.byte	$90, $0C, $08
			.word        	strDescGaol2
			.byte	$A1, $0A, $01, $12, $4D, $02, $0A
			.word	     	strOptn2Play0
menuWindowAuctn1Trd:
			.byte	$A1, $0C, $01, $12, $54, $02, $0C
			.word		strOptn3Play0
			.byte	$A1, $0E, $01, $12, $56, $02, $0E
			.word		strOptn4Play0
			.byte	$A1, $10, $01, $12, $53, $02, $10
			.word		strOptn5Play0
			.byte	$A1, $14, $01, $12, $2E, $02, $14
			.word		strOptn2Gaol1
			
			.byte	$00
			
		
menuPageAuctn1Keys:
		CMP	#'.'
		BNE	@keysOther

		LDA 	#<menuPageAuctn0
		LDY	#>menuPageAuctn0
		JSR	menuSetPage

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	game + GAME::dirty
		ORA	#$01
		STA	game + GAME::dirty

		RTS
		
@keysOther:
		JSR	menuPageAuctnDefKeys
		
		RTS
		
		
menuPageAuctn1Draw:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	#$A0
		STA	menuWindowAuctn1Trd
		
		LDY	#PLAYER::money + 1
		BMI	@cont

		LDA	#$A1
		STA	menuWindowAuctn1Trd

@cont:
		LDA	#<menuWindowAuctn1
		STA	$FD
		LDA	#>menuWindowAuctn1
		STA	$FE
		
		JSR	screenPerformList

		LDA	#<menuFooterGame0
		STA	$FD
		LDA	#>menuFooterGame0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS
		

menuGaol0Dbls:
		.byte 	$00

menuWindowGaol0:	
			.byte	$90, $01, $07
			.word	     strHeaderGaol0
			.byte	$90, $01, $08
menuWindowGaol0D:
			.word		strDummyDummy0

			.byte	$A1, $0C, $01, $12, $4E, $02, $0C
			.word	     strOptn1Play0

			.byte	$00


menuPageGaol0Keys:
		CMP	#'N'
		BNE	@keysDone
		
		JSR	rulesNextTurn

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

@keysDone:

		RTS
		
		
menuPageGaol0Draw:
		LDA	menuGaol0Dbls
		BEQ	@nodesc
		
		LDA	#<strDescGaol0
		STA	menuWindowGaol0D
		LDA	#>strDescGaol0
		STA	menuWindowGaol0D + 1
		
		JMP	@cont
		

@nodesc:
		LDA	#<strDummyDummy0
		STA	menuWindowGaol0D
		LDA	#>strDummyDummy0
		STA	menuWindowGaol0D + 1
		
@cont:
		LDA	#$00
		STA	menuGaol0Dbls

		LDA	#<menuWindowGaol0
		STA	$FD
		LDA	#>menuWindowGaol0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuPageGaol1DefKeys:				
@keysP:
		CMP	#'P'
		BNE	@keysF

		LDA	#$01
		CMP	game + GAME::dieRld
		BEQ	@keysExit
		
		LDX	#$01
		JSR	gameToggleGaol
		
		JSR	gameUpdateMenu
		JMP	@keysDirty
		
@keysF:
		CMP	#'F'
		BNE	@keysR
		
		LDA	#$01
		CMP	game + GAME::dieRld
		BEQ	@keysExit

		JSR	gameCheckGaolFree
		
		JSR	gameUpdateMenu
		JMP	@keysDirty
		
@keysR:
		CMP	#'R'
		BNE	@keysN
		
		JSR	gameRollDice
		JSR	gameUpdateMenu
		JMP	@keysDirty

@keysN:
		CMP	#'N'
		BNE	@keysOther
		
		JSR	rulesNextTurn
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		JMP	@keysExit

@keysTstQuad:
		CMP	game + GAME::qVis
		BEQ	@keysExit
		
		STA	game + GAME::qVis

		JSR	gamePlayersDirty
		
@keysDirty:
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@keysExit:
		RTS
		
@keysOther:
		JSR	menuPagePlay0DefKeys
		
		RTS
		

menuPageGaol1Keys:
@keysNext:
		CMP	#'.'
		BNE	@keysOther

		LDA 	#<menuPageGaol2
		LDY	#>menuPageGaol2
		JSR	menuSetPage

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

		LDA	game + GAME::dirty
		ORA	#$08
		STA	game + GAME::dirty

		RTS
		
@keysOther:
		JSR	menuPageGaol1DefKeys
		
		RTS


menuWindowGaol1:	
			.byte	$90, $01, $07
			.word	     	strHeaderGaol1
			.byte	$90, $0C, $08
			.word        	strDescGaol1
menuWindowGaol1RollB:
			.byte	$A1, $0A, $01, $12, $52, $02, $0A
			.word	     	strOptn0Play0
menuWindowGaol1NextB:
			.byte	$A1, $0C, $01, $12, $4E, $02, $0C
			.word	     	strOptn1Play0
menuWindowGaol1PostB:
			.byte	$A1, $0E, $01, $12, $50, $02, $0E
			.word	     	strOptn0Gaol1
menuWindowGaol1FreeB:
			.byte	$A1, $10, $01, $12, $46, $02, $10
			.word		strOptn1Gaol1
			.byte	$A1, $14, $01, $12, $2E, $02, $14
			.word		strOptn2Gaol1
			
			.byte	$00

	
menuPageGaol1Draw:
		LDA	#<menuWindowGaol1
		STA	$FD
		LDA	#>menuWindowGaol1
		STA	$FE
		
		LDA	#$01
		CMP	game + GAME::dieRld
		BNE	@noroll
	
		LDA	#$A1
		STA	menuWindowGaol1NextB

		LDA	#$A0
		STA	menuWindowGaol1RollB
		STA	menuWindowGaol1PostB
		STA	menuWindowGaol1FreeB
	
		JMP	@cont

@noroll:
		LDA	#$A1
		STA	menuWindowGaol1RollB
		STA	menuWindowGaol1PostB

		LDA	#$A0
		STA	menuWindowGaol1NextB

		LDA	game + GAME::pActive
		CMP	game + GAME::pGF0Crd
		BEQ	@havegf
		
		CMP	game + GAME::pGF1Crd
		BEQ	@havegf
		
		LDA	#$A0
		STA	menuWindowGaol1FreeB
		JMP	@cont

@havegf:
		LDA	#$A1
		STA	menuWindowGaol1FreeB

@cont:
		JSR	screenPerformList

		LDA	#<menuFooterGame0
		STA	$FD
		LDA	#>menuFooterGame0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS

		
menuWindowGaol2:	
			.byte	$90, $01, $07
			.word	     	strHeaderGaol1
			.byte	$90, $0C, $08
			.word        	strDescGaol2
			.byte	$A1, $0A, $01, $12, $4D, $02, $0A
			.word	     	strOptn2Play0
menuWindowGaol2Trd:
			.byte	$A1, $0C, $01, $12, $54, $02, $0C
			.word		strOptn3Play0
			.byte	$A1, $0E, $01, $12, $56, $02, $0E
			.word		strOptn4Play0
			.byte	$A1, $10, $01, $12, $53, $02, $10
			.word		strOptn5Play0
			.byte	$A1, $14, $01, $12, $2E, $02, $14
			.word		strOptn2Gaol1
			
			.byte	$00
			
		
menuPageGaol2Keys:
		CMP	#'.'
		BNE	@keysOther

		LDA 	#<menuPageGaol1
		LDY	#>menuPageGaol1
		JSR	menuSetPage

		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	game + GAME::dirty
		ORA	#$01
		STA	game + GAME::dirty

		RTS
		
@keysOther:
		JSR	menuPageGaol1DefKeys
		
		RTS
		
		
menuPageGaol2Draw:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	#$A0
		STA	menuWindowGaol2Trd
		
		LDY	#PLAYER::money + 1
		BMI	@cont

		LDA	#$A1
		STA	menuWindowGaol2Trd

@cont:
		LDA	#<menuWindowGaol2
		STA	$FD
		LDA	#>menuWindowGaol2
		STA	$FE
		
		JSR	screenPerformList

		LDA	#<menuFooterGame0
		STA	$FD
		LDA	#>menuFooterGame0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS
		

menuWindowGaol3:	
			.byte	$90, $01, $07
			.word	     	strHeaderGaol3

			.byte	$A1, $0A, $01, $12, $50, $02, $0A
			.word	     	strOptn0Gaol1
			
			.byte	$00

menuPageGaol3Keys:
@keysP:
		CMP	#'P'
		BNE	@keysOther

		LDX	#$01
		JSR	gameToggleGaol
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$DF
		ORA	#$10
		STA	($FB), Y
		
		JSR	gameUpdateMenu
	
@keysDirty:
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@keysExit:
		RTS
		
@keysOther:
		JSR	menuPagePlay0DefKeys
		
		RTS
		
		
menuPageGaol3Draw:
		LDA	#<menuWindowGaol3
		STA	$FD
		LDA	#>menuWindowGaol3
		STA	$FE
		
		JSR	screenPerformList
		
		RTS
	

menuWindowMustPay0:	
			.byte	$90, $01, $07
			.word	     	strHeaderMustPay0
			.byte	$90, $01, $08
			.word        	strDescMustPay0
menuWindowMustPay0ContB:
			.byte	$A1, $0A, $01, $12, $43, $02, $0A
			.word	     	strOptn0MustPay0
			.byte	$A1, $0E, $01, $12, $4D, $02, $0E
			.word	     	strOptn2Play0
			.byte	$A1, $12, $01, $12, $56, $02, $12
			.word		strOptn4Play0
			.byte	$A1, $14, $01, $12, $53, $02, $14
			.word		strOptn5Play0

			.byte	$00
			
			
menuPageMustPay0Keys:
		LDX	menuWindowMustPay0ContB
		CPX	#$A1
		BNE	@keysOther

		CMP	#'C'
		BNE	@keysOther
		
		LDA	game + GAME::pMPyLst
		CMP	game + GAME::pMPyCur
		
		BNE	@update
		
		LDA	#$FF
		STA	game + GAME::pMPyCur
		
@update:
		JSR	gameUpdateMenu
		
		LDA	#$01			;???Overzealous???
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		
@keysOther:
		JSR	menuPagePlay0DefKeys
		
		RTS
		
		
menuPageMustPay0Draw:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money + 1
		LDA	($FB), Y
		BPL	@havecash

		LDA	#$A0
		STA	menuWindowMustPay0ContB
		
		JMP	@cont

@havecash:
		LDA	#$A1
		STA	menuWindowMustPay0ContB

@cont:
		LDA	#<menuWindowMustPay0
		STA	$FD
		LDA	#>menuWindowMustPay0
		STA	$FE
		
		JSR	screenPerformList
		
		LDA	#<menuFooterGame0
		STA	$FD
		LDA	#>menuFooterGame0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuManage0CheckTrade:
		.byte	$00

menuWindowManage0:
			.byte	$90, $01, $07
			.word	     strHeaderMng0

			.byte	$A1, $0A, $01, $12, $46, $02, $0A
			.word	     strOptn0Mng0
			.byte	$A1, $0C, $01, $12, $42, $02, $0C
			.word	     strOptn1Mng0
			.byte	$A1, $0E, $01, $12, $4D, $02, $0E
			.word	     strOptn2Mng0
menuWindowManage0C:
			.byte	$A1, $10, $01, $12, $43, $02, $10
			.word	     strOptn3Mng0
			.byte	$A1, $12, $01, $12, $53, $02, $12
			.word	     strOptn4Mng0
			.byte	$A1, $14, $01, $12, $49, $02, $14
			.word	     strOptn5Mng0
			.byte	$A1, $16, $01, $12, $44, $02, $16
			.word	     strOptn6Mng0

			.byte	$00


;-------------------------------------------------------------------------------
menuPageManage0Keys:
;-------------------------------------------------------------------------------
		CMP	#'D'
		BNE	@keysF
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	game + GAME::cntHs
		BMI	@warn
		
		LDA	game + GAME::cntHt
		BMI	@warn
		
		JSR	gameToggleManage

;***FIXME:	Having to do this in inexplicable.
		LDX	game + GAME::pActive	;I need to do this again or I
		LDA	plrLo, X		;get the wrong colour.  Why???
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptClearOrRoll
		
		JMP	@ding
		
@warn:
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX

		JSR	prmptMustSell

@buzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS

@keysF:
		CMP	#'F'
		BNE	@keysB
		
		JSR	gameMoveSelectFwd
		JMP	@ding
		
@keysB:
		CMP	#'B'
		BNE	@keysM
		
		JSR	gameMoveSelectBck
 		JMP	@ding


@keysM:
		CMP	#'M'
		BNE	@keysC

		JSR	rulesToggleMrtg
		
 		JMP	@exit

@keysC:
		CMP	#'C'
		BNE	@keysS
		
		LDX	menuManage0CheckTrade
		BEQ	@doconstruct
		
		JMP	@buzz
		
@doconstruct:
		LDA	game + GAME::sSelect
		JSR	rulesNextImprv
		
 		JMP	@exit
		
@keysS:
		CMP	#'S'
		BNE	@keysI
		
		LDA	game + GAME::sSelect
		JSR	rulesPriorImprv
		
 		JMP	@exit

@keysI:
		CMP	#'I'
	.if	DEBUG_KEYS
		BNE	@keysT
	.else
		BNE	@exit
	.endif
		
		JSR	gameDispSqrInfoDlg
		JMP	@ding


	.if	DEBUG_KEYS
@keysT:
		CMP	#'T'
		BNE	@keysY
		
		LDX	game + GAME::sSelect
		JSR	rulesTradeTitleDeed
		
 		JMP	@exit
		
@keysY:
		CMP	#'Y'
		BNE	@keysU
		
		JSR	gameIncMoney100
		JMP	@exit
		
@keysU:
		CMP	#'U'
		BNE	@keysPL
		
		JSR	gameDecMoney100
		JMP	@exit
		
@keysPL:
		CMP	#'+'
		BNE	@keysMN
		
		JSR	gameIncMoney1
		JMP	@exit
		
@keysMN:
		CMP	#'-'
		BNE	@keys0
		
		JSR	gameDecMoney1
		JMP	@exit
		
@keys0:
		CMP	#'0'
		BNE	@keys9
		
		JSR	gameIncMoney10
		JMP	@exit
		
@keys9:
		CMP	#'9'
		BNE	@keysJ
		
		JSR	gameDecMoney10
		JMP	@exit
		
@keysJ:
		CMP	#'J'
		BNE	@keysK
		
		JSR	gameMovePlyrFwd
		JMP	@exit

@keysK:
		CMP	#'K'
		BNE	@exit
		
		JSR	gameMovePlyrBck
		JMP	@exit
		
;@keysN:
;		CMP	#'N'
;		BNE	@exit
;		
;		LDA	#$01
;		STA	game + GAME::dieRld
;		
;		JSR	rulesNextTurn
;
;***dengland	I disabled this debugging key because it needs to clear the 
;		management menu and setting the dice to already rolled really 
;		isn't wise.
;
;		JMP	@exit
	.endif

		
@ding:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

@exit:
		RTS


menuPageManage0Draw:
		LDA	#$A1
		STA	menuWindowManage0C

		LDA	menuManage0CheckTrade
		BEQ	@disp
		
		LDA	#$A0
		STA	menuWindowManage0C

@disp:
		JSR	prmptManage
		
		LDA	#<menuWindowManage0
		STA	$FD
		LDA	#>menuWindowManage0
		STA	$FE
		
		JSR	screenPerformList
		
		LDA	#$01
		STA	ui + UI::fWntJFB
		
		RTS


menuWindowTradeCanConf:
		.byte	$00
		
menuTrade0RemWealth:
		.byte	$00
		.byte	$00
		.byte	$00
		
menuTrade0RemCash:
		.word	$0000


menuTrade0RWealthRecalc:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	menuTrade0RemWealth
		STA	menuTrade0RemCash
		INY
		LDA	($FB), Y
		STA	menuTrade0RemWealth + 1
		STA	menuTrade0RemCash + 1
		LDA	#$00
		STA	menuTrade0RemWealth + 2
		
		JSR	gameRemWlth0AddEquity
		
		LDY	#TRADE::money		;Wealth -offered money
		SEC
		LDA	menuTrade0RemWealth
		SBC	trade1, Y
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		SBC	trade1 + 1, Y
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		SBC	#$00
		STA	menuTrade0RemWealth + 2
		
		LDY	#TRADE::money		;Cash -offered money
		SEC
		LDA	menuTrade0RemCash
		SBC	trade1, Y
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		SBC	trade1 + 1, Y
		STA	menuTrade0RemCash + 1
		
		LDY	#TRADE::money		;Wealth +wanted money
		CLC
		LDA	menuTrade0RemWealth
		ADC	trade0, Y
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		ADC	trade0 + 1, Y
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		ADC	#$00
		STA	menuTrade0RemWealth + 2
		
		LDY	#TRADE::money		;Cash +wanted money
		CLC
		LDA	menuTrade0RemCash
		ADC	trade0, Y
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		ADC	trade0 + 1, Y
		STA	menuTrade0RemCash + 1
		
		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		BNE	@dowanted
		
		JMP	@tstoffer
		
@dowanted:
		TAX
		DEX
		
@loop:
		STX	game + GAME::varA
		
		LDA	trddeeds0, X
		JSR	gameGetCardPtrForSquare
		
		LDX	game + GAME::varA
		LDA	trdrepay0, X
		AND	#$80
		BNE	@wantfee
		
		JMP	@equity

@wantfee:
		JSR	gameRemWlth0SubFee

		LDA	trdrepay0, X
		AND	#$01
		BEQ	@next
		
		LDY	#DEED::mValue
		
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		SEC
		LDA	menuTrade0RemCash
		SBC	game + GAME::varD
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		SBC	game + GAME::varE
		STA	menuTrade0RemCash + 1
		
		JMP	@next
		
@equity:
		LDY	#DEED::mValue		;Gain equity if not mrtg
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		CLC
		LDA	menuTrade0RemWealth
		ADC	game + GAME::varD
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		ADC	game + GAME::varE
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		ADC	#$00
		STA	menuTrade0RemWealth + 2
		
@next:
		LDX	game + GAME::varA
		
		DEX
		BMI	@tstoffer
		
		JMP	@loop
		
@tstoffer:
		LDY	#TRADE::cntDeed
		LDA	trade1, Y
		BNE	@dooffer
		
		RTS
		
@dooffer:
		TAX
		DEX
		
@loop1:
		STX	game + GAME::varA
		
		LDA	trddeeds1, X
		JSR	gameGetCardPtrForSquare
		
		LDX	game + GAME::varA
		LDA	trdrepay1, X
		AND	#$80
		BNE	@next1

		LDY	#DEED::mValue		;Lose equity if not mrtg
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE

		JSR	gameRemWlth0SubValue
		
@next1:
		LDX	game + GAME::varA
		
		DEX
		BPL	@loop1

		RTS


menuTrade0Recalc:
		.byte	$00

menuWindowTrade0:
			.byte	$90, $01, $07
			.word	     	strHeaderTrade0

			.byte	$A1, $0A, $01, $12, $50, $02, $0A
			.word	     	strOptn0Trade0
menuWindowTradeWB:
			.byte	$A1, $0C, $01, $12, $57, $02, $0C
			.word	     	strOptn1Trade0
			.byte	$A1, $0E, $01, $12, $4F, $02, $0E
			.word	     	strOptn2Trade0
menuWindowTradeCB:
			.byte	$A1, $10, $01, $12, $43, $02, $10
			.word	     	strOptn3Trade0
			.byte	$A1, $12, $01, $12, $4D, $02, $12
			.word		strOptn2Play0
			.byte	$A1, $14, $01, $12, $58, $02, $14
			.word	     	strOptn4Trade0

			.byte	$00
			
menuPageTrade0Keys:
		CMP	#'M'
		BNE	@keysP
		
		LDA	#$01
		STA	menuTrade0Recalc
		STA	menuManage0CheckTrade
		
		JSR	gameToggleManage
		JMP	@keysDing
		
@keysP:
		CMP	#'P'
		BNE	@keysW

		LDA	#$00
		STA	menuPlyrSelCallProc
		STA	menuPlyrSelCallProc + 1

		LDA	#$00
		STA	menuPlyrSelAllowCur
		STA	menuWindowTradeCanConf
		
		LDA	#<menuPagePlyrSel0
		LDY	#>menuPagePlyrSel0
		
		JSR	menuPushPage
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JMP	@keysDing

@keysW:
		CMP	#'W'
		BNE	@keysO
		
		LDA	#$00
		STA	dialogTrdSelDoElimin
		STA	dialogTrdSelDoApprv
		
		LDA	#$01
		STA	menuWindowTradeCanConf
		STA	dialogTrdSelDoRepay
		
		LDA	#$00
		JSR	gameInitTrdSelector
		
		JMP	@keysDing
		
@keysO:	
		CMP	#'O'
		BNE	@keysX
		
		LDA	#$01
		STA	menuWindowTradeCanConf
		
		LDA	#$00
		STA	dialogTrdSelDoElimin
		STA	dialogTrdSelDoApprv
		STA	dialogTrdSelDoRepay
		
		LDA	#$01
		JSR	gameInitTrdSelector
		
		JMP	@keysDing
		
@keysX:
		CMP	#'X'
		BNE	@keysC
		
		JSR	gameUpdateMenu
		
		JMP	@keysDing
		
@keysC:
		CMP	#'C'
		BNE	@keysExit
		
		JSR	gameInitTrdIntrpt
		
@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
@keysExit:
		RTS
		
	
menuPageTrade0Draw:
		LDA	menuTrade0Recalc
		BNE	@recalc

		LDX	#TRADE::player
		LDA	menuPlyrSelSelect
		
		CMP	trade0, X			;If the player is changed
		BEQ	@cont				;we need to clear the 
							;wanted data
							
;		LDA	#$00				;Don't do this.  This will
;		STA	menuWindowTradeCanConf		;allow an odd corner case
							;but we need more flags to
							;do it properly.
		
		LDX	#.sizeof(TRADE) - 1	;Clear the wanted data
		LDA	#$00
@loop0:
		STA 	trade0, X
		
		DEX
		BPL	@loop0
		
		LDX	#$1B
@loop1:
		STA	trddeeds0, X
		STA	trdrepay0, X

		DEX
		BPL	@loop1

		LDX	#TRADE::player
		LDA	menuPlyrSelSelect
		STA	trade0, X
		
		LDA	game + GAME::pActive
		STA	trade1, X
		
@recalc:
		JSR	menuTrade0RWealthRecalc
		
		LDA	#$00
		STA	menuTrade0Recalc
		
@cont:
		LDX	#TRADE::player		;Continue drawing
		LDA	trade0, X
		
		CMP	#$FF
		BEQ	@disW
		
		LDA	#$A1
		STA	menuWindowTradeWB
		
		JMP	@tstConf
		
@disW:
		LDA	#$A0
		STA	menuWindowTradeWB

@tstConf:
		LDA	menuWindowTradeCanConf
		BEQ	@disable

		LDA	#$A1
		STA	menuWindowTradeCB
		
		JMP	@disp

@disable:
		LDA	#$A0
		STA	menuWindowTradeCB
		
@disp:
		LDA	#<menuWindowTrade0
		STA	$FD
		LDA	#>menuWindowTrade0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuTrade1RemWealth:
		.byte	$00
		.byte	$00
		.byte	$00
menuTrade1RemCash:
		.word	$0000
menuTrade1Warn0:
		.byte	$00
		

menuTrade1RWealthRecalc:
		LDA	#$00
		STA	menuTrade1Warn0

		LDY	#TRADE::player
		LDA	trade0, Y
		TAX
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money		;Wealth +player money
		LDA	($FB), Y
		STA	menuTrade1RemWealth
		STA	menuTrade1RemCash
		INY
		LDA	($FB), Y
		STA	menuTrade1RemWealth + 1
		STA	menuTrade1RemCash + 1
		LDA	#$00
		STA	menuTrade1RemWealth + 2
		
		LDY	#PLAYER::equity		;Wealth +player equity
		CLC
		LDA	($FB), Y
		ADC	menuTrade1RemWealth
		STA	menuTrade1RemWealth
		INY
		LDA	($FB), Y
		ADC	menuTrade1RemWealth + 1
		STA	menuTrade1RemWealth + 1
		LDA	#$00
		ADC	menuTrade1RemWealth + 2
		STA	menuTrade1RemWealth + 2
		
		LDY	#TRADE::money		;Wealth -wanted money
		SEC
		LDA	menuTrade1RemWealth
		SBC	trade0, Y
		STA	menuTrade1RemWealth
		LDA	menuTrade1RemWealth + 1
		SBC	trade0 + 1, Y
		STA	menuTrade1RemWealth + 1
		LDA	menuTrade1RemWealth + 2
		SBC	#$00
		STA	menuTrade1RemWealth + 2
		
		LDY	#TRADE::money		;Cash -wanted money
		SEC
		LDA	menuTrade1RemCash
		SBC	trade0, Y
		STA	menuTrade1RemCash
		LDA	menuTrade1RemCash + 1
		SBC	trade0 + 1, Y
		STA	menuTrade1RemCash + 1
		
		LDY	#TRADE::money		;Wealth +offered money
		CLC
		LDA	menuTrade1RemWealth
		ADC	trade1, Y
		STA	menuTrade1RemWealth
		LDA	menuTrade1RemWealth + 1
		ADC	trade1 + 1, Y
		STA	menuTrade1RemWealth + 1
		LDA	menuTrade1RemWealth + 2
		ADC	#$00
		STA	menuTrade1RemWealth + 2

		LDY	#TRADE::money		;Cash +offered money
		CLC
		LDA	menuTrade1RemCash
		ADC	trade1, Y
		STA	menuTrade1RemCash
		LDA	menuTrade1RemCash + 1
		ADC	trade1 + 1, Y
		STA	menuTrade1RemCash + 1

		LDY	#TRADE::cntDeed
		LDA	trade1, Y
		BNE	@dooffer
		
		JMP	@procwant
		
@dooffer:					;Process offer (fees, equity)
		TAX
		DEX
		
@loop:
		STX	game + GAME::varA
		
		LDA	trddeeds1, X
		JSR	gameGetCardPtrForSquare
		
		LDA	trdrepay1, X
		AND	#$80
		BNE	@mrtg
		
		JMP	@equity

@mrtg:
		LDA	#$01
		STA	menuTrade1Warn0

		LDY	#DEED::mFee		;At least a fee for mrtg
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR	gameRemWlth1SubValue
		
		LDA	trdrepay1, X
		AND	#$01
		BEQ	@next
		
		LDY	#DEED::mValue		;And mValue for repay
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR	gameRemWlth1SubValue
		
		JMP	@next

@equity:
		LDY	#DEED::mValue		;Gain equity if not mrtg
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		CLC
		LDA	menuTrade1RemWealth
		ADC	game + GAME::varD
		STA	menuTrade1RemWealth
		LDA	menuTrade1RemWealth + 1
		ADC	game + GAME::varE
		STA	menuTrade1RemWealth + 1
		LDA	menuTrade1RemWealth + 2
		ADC	#$00
		STA	menuTrade1RemWealth + 2
		
@next:
		LDX	game + GAME::varA
		
		DEX
		BMI	@procwant
		
		JMP	@loop
		
				
@procwant:
		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		BNE	@dowant
		
		RTS
		
@dowant:					;Process wanted (equity)
		TAX
		DEX
		
@loop1:
		STX	game + GAME::varA
		
		LDA	trddeeds1, X
		JSR	gameGetCardPtrForSquare
		
		LDA	trdrepay1, X
		AND	#$80
		BEQ	@next1

		LDA	trddeeds1, X
		JSR	gameGetCardPtrForSquare

		LDY	#DEED::mValue		;Lose equity if not mrtg
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		SEC
		LDA	menuTrade1RemWealth
		SBC	game + GAME::varD
		STA	menuTrade1RemWealth
		LDA	menuTrade1RemWealth + 1
		SBC	game + GAME::varE
		STA	menuTrade1RemWealth + 1
		LDA	menuTrade1RemWealth + 2
		SBC	#$00
		STA	menuTrade1RemWealth + 2

@next1:
		LDX	game + GAME::varA
		
		DEX
		BPL	@loop1

		RTS


menuTrade1Recalc:
		.byte	$00

menuWindowTrade1:
			.byte	$90, $01, $07
			.word	     strHeaderTrade1

			.byte	$A1, $0A, $01, $12, $50, $02, $0A
			.word	     strOptn0Trade0
			.byte	$A1, $0C, $01, $12, $57, $02, $0C
			.word	     strOptn1Trade0
			.byte	$A1, $0E, $01, $12, $4F, $02, $0E
			.word	     strOptn2Trade0
			.byte	$A1, $10, $01, $12, $43, $02, $10
			.word	     strOptn3Trade0
			.byte	$A1, $12, $01, $12, $4D, $02, $12
			.word		strOptn2Play0
			.byte	$A1, $14, $01, $12, $58, $02, $14
			.word	     strOptn4Trade0

			.byte	$00
			
menuPageTrade1Keys:
		CMP	#'M'
		BNE	@keysP
		
		LDA	#$01
		STA	menuTrade1Recalc
		STA	menuManage0CheckTrade
		
		JSR	gameToggleManage
		JMP	@keysDing
		
@keysP:
		CMP	#'P'
		BNE	@keysW

		LDY	#TRADE::player
		LDA	trade0, Y
		STA	dialogTempTrade7P
		
		LDA 	#<dialogDlgTrade7
		LDY	#>dialogDlgTrade7
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog

		JMP	@keysDing

@keysW:
		CMP	#'W'
		BNE	@keysO
		
		LDA	#$01
		STA	dialogTrdSelDoApprv
	
		LDA	#$00
		STA	dialogTrdSelDoElimin
		STA	dialogTrdSelDoRepay
		
		LDA	#$00
		JSR	gameInitTrdSelector
		
		JMP	@keysDing
		
@keysO:	
		CMP	#'O'
		BNE	@keysX
		
		LDA	#$00
		STA	dialogTrdSelDoElimin
		
		LDA	#$01
		STA	dialogTrdSelDoApprv
		STA	dialogTrdSelDoRepay
		
		LDA	#$01
		JSR	gameInitTrdSelector
		
		JMP	@keysDing
		
@keysX:
		CMP	#'X'
		BNE	@keysC

		LDA	#$00
		STA	game + GAME::fTrdTyp
		JSR	gamePerfTradePopMode
		
		JSR	gameUpdateMenu

		JMP	@keysDing
		
@keysC:
		CMP	#'C'
		BNE	@keysExit
		
		JSR	gameApproveTrade

@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
@keysExit:
		RTS
		
	
menuPageTrade1Draw:
		LDA	menuTrade1Recalc
		BEQ	@disp
		
		LDA	#$00
		STA	menuTrade1Recalc
		
		JSR	menuTrade1RWealthRecalc

@disp:
		LDA	#<menuWindowTrade1
		STA	$FD
		LDA	#>menuWindowTrade1
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuWindowTrade6:
			.byte	$90, $01, $07
			.word	     	strHeaderTrade6

			.byte	$90, $02, $0A
			.word		strText0Trade6
			.byte	$90, $02, $0B
			.word		strText1Trade6

			.byte	$AF, $0D, $01, $12, $20, $02, $0D
			.word	     	strDesc7Titles0

			.byte	$00


menuPageTrade6Keys:
		LDA	game + GAME::fTrdTyp
		BEQ	@proc
		
		LDA	game + GAME::fTrdStg
		CMP	#$02
		BEQ	@exit

@proc:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$00
		STA	ui + UI::fActInt

@exit:
		RTS
		

menuPageTrade6Draw:
		LDA	#<menuWindowTrade6
		STA	$FD
		LDA	#>menuWindowTrade6
		STA	$FE
		
		JSR	screenPerformList
		RTS


menuElimin0HaveOffer:
		.byte	$00
menuElimin0Recalc:
		.byte	$00


menuElimin0RemWlthRecalc:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	menuTrade0RemWealth
		INY
		LDA	($FB), Y
		STA	menuTrade0RemWealth + 1
		LDA	#$00
		STA	menuTrade0RemWealth + 2
		
		
		
		JSR	gameRemWlth0AddEquity

		LDY	#TRADE::cntDeed
		LDA	trade1, Y
		BNE	@dooffer
		
		JMP	@exit
		
@dooffer:					;Process offer (fees, equity)
		TAX
		DEX
		
@loop:
		STX	game + GAME::varA
		
		LDA	trddeeds1, X
		JSR	gameGetCardPtrForSquare
		
		LDA	trdrepay1, X
		AND	#$80
		BNE	@mrtg
		
		JMP	@next

@mrtg:
		LDA	#$01
		STA	menuTrade1Warn0

		JSR	gameRemWlth0SubFee
		
		LDA	trdrepay1, X
		AND	#$01
		BEQ	@next
		
		LDY	#DEED::mValue		;And mValue for repay
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR	gameRemWlth0SubValue
		
		SEC
		LDA	menuTrade0RemCash
		SBC	game + GAME::varD
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		SBC	game + GAME::varE
		STA	menuTrade0RemCash + 1
		
@next:
		LDX	game + GAME::varA
		
		DEX
		BMI	@exit
		
		JMP	@loop
		
@exit:
		RTS


menuWindowElimin0:
			.byte	$90, $01, $07
			.word	     strHeaderElimin0

			.byte	$A1, $0A, $01, $12, $50, $02, $0A
			.word	     strOptn0Trade0
			.byte	$A1, $0E, $01, $12, $4F, $02, $0E
			.word	     strOptn2Trade0
			.byte	$A1, $10, $01, $12, $43, $02, $10
			.word	     strOptn3Trade0
			.byte	$A1, $12, $01, $12, $4D, $02, $12
			.word		strOptn2Play0

			.byte	$00
		
		
menuPageElimin0SetAuctn:
		LDY	#TRADE::player
		LDA	trade1, Y
		STA	game + GAME::varA
		
		LDY	#TRADE::cntDeed
		LDA	trade1, Y
		STA	game + GAME::varC
		
		LDX	#$00
		STX	game + GAME::varB
@loop:
		LDA	sqr00, X
		CMP	game + GAME::varA
		
		BNE	@next
		
		LDA	game + GAME::varC
		BEQ	@notfound

		LDY	#$00
@loop0:
		LDA	trddeeds1, Y
		
		CMP	game + GAME::varB
		BEQ	@found
		
		INY
		CPY	game + GAME::varC
		BNE	@loop0
		
@notfound:
		LDA	#$00
		STA	sqr00 + 1, X
		LDA	#$FF
		STA	sqr00, X

		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		TAY

		LDA	game + GAME::varB
		STA	trddeeds0, Y
		
		INY
		TYA
		LDY	#TRADE::cntDeed
		STA	trade0, Y

		JMP	@next

@found:


@next:
		INC	game + GAME::varB
		INX
		INX
		CPX	#$50
		BNE	@loop
		
		RTS
			
			
menuPageElimin0Keys:
	.if	DEBUG_KEYS
		CMP	#'A'
		BNE	@keysM

		LDY	#TRADE::player
		LDA	trade1, Y
		TAX
		JSR	rulesAutoEliminate

		LDA	ui + UI::cActns
		BNE	@autoelimin
		
		JMP	@keysBuzz
		
@autoelimin:
		LDA	#$01
		STA	menuElimin0HaveOffer
		
		LDA	#$01
		STA	ui + UI::fActInt
		LDA	#$00
		STA	ui + UI::fActTyp
		
		JSR	uiProcessInit
		
		JMP	@keysDing

		RTS
	.endif
	
@keysM:
		CMP	#'M'
		BNE	@keysP
		
		LDA	#$01
		STA	menuElimin0Recalc
		
		LDA	#$00
		STA	menuManage0CheckTrade
		
		JSR	gameToggleManage
		JMP	@keysDing
		
@keysP:
		CMP	#'P'
		BNE	@keysO

		LDY	#TRADE::player
		LDA	trade0, Y
		STA	dialogTempTrade7P
		
		LDA 	#<dialogDlgTrade7
		LDY	#>dialogDlgTrade7
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog

		JMP	@keysDing

@keysO:	
		CMP	#'O'
		BNE	@keysC
		
		LDA	#$01
		STA	menuElimin0HaveOffer
		
		LDA	#$00
		STA	dialogTrdSelDoApprv
		STA	dialogTrdSelDoRepay
		
		LDA	#$01
		STA	dialogTrdSelDoElimin
		JSR	gameInitTrdSelector
		
		JMP	@keysDing
		
@keysC:
		CMP	#'C'
		BNE	@keysExit
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::fCPU
		LDA	($FB), Y
		BNE	@proc
		
		LDA	menuElimin0HaveOffer
		BNE	@tstproc

		LDA 	#<dialogDlgElimin1
		LDY	#>dialogDlgElimin1
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog

		JSR	gamePlayersDirty
		RTS

@tstproc:
		LDA	menuTrade0RemWealth + 2
		BMI	@fail0
	
		LDA	menuTrade0RemCash + 1
		BPL	@proc
		
@fail0:
		LDA 	#<dialogDlgTrade2
		LDY	#>dialogDlgTrade2
		
		JSR	gameInitTrdFail0
		JMP	@keysBuzz
		
@proc:
		JSR 	menuPageElimin0SetAuctn
		
		LDA	#$01
		STA	game + GAME::fTrdTyp
		
;***FIXME:	Do I need to change game + GAME::pActive?
		
		LDA	game + GAME::fDoJump
		BEQ	@stepping

		LDA	#$00
		STA	ui + UI::fActInt		
		
		JMP	@cont
		
@stepping:
		LDA	#$01
		STA	ui + UI::fActInt		

@cont:
		JSR	gamePerfTradeFull
		
@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
@keysExit:
		RTS
		
@keysBuzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		RTS


menuPageElimin0Draw:
		LDA	menuElimin0Recalc
		BEQ	@disp
		
		LDA	#$00
		STA	menuElimin0Recalc
		
		JSR	menuElimin0RemWlthRecalc

@disp:
		LDA	#<menuWindowElimin0
		STA	$FD
		LDA	#>menuWindowElimin0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


menuPlyrSelCallProc:
		.word	$0000
menuPlyrSelAllowCur:
		.byte	$00
menuPlyrSelSelect:
		.byte	$00


;***THIS IS VERY NAUGHTY SO THE MENU DATA CAN'T BE MORE THAN ONE PAGE 
menuWindowPlyrSelPN:
		.byte	menuWindowPlyrSelP0 - menuWindowPlyrSel0 
		.byte	menuWindowPlyrSelP1 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelP2 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelP3 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelP4 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelP5 - menuWindowPlyrSel0
		
menuWindowPlyrSelNN:
		.byte	menuWindowPlyrSelN0 - menuWindowPlyrSel0 
		.byte	menuWindowPlyrSelN1 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelN2 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelN3 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelN4 - menuWindowPlyrSel0
		.byte	menuWindowPlyrSelN5 - menuWindowPlyrSel0

	.define	PLYRSEL_P	*
menuWindowPlyrSel0:
			.byte	$90, $01, $07
			.word	     	strHeaderPSel0
;			.byte	$90, $01, $08
;			.word        	strDescSetup0
menuWindowPlyrSelP0:
			.byte	$A2, $0A, $01, $12, $31, $02, $0A
			.word	     	strOptn0PSel0
			.byte	$90, $06, $0A
menuWindowPlyrSelN0:
			.word		plr0 + PLAYER::name
menuWindowPlyrSelP1:
			.byte	$A2, $0C, $01, $12, $32, $02, $0C
			.word	     	strOptn1PSel0
			.byte	$90, $06, $0C
menuWindowPlyrSelN1:
			.word		plr1 + PLAYER::name
menuWindowPlyrSelP2:
			.byte	$A2, $0E, $01, $12, $33, $02, $0E
			.word	     	strOptn2PSel0
			.byte	$90, $06, $0E
menuWindowPlyrSelN2:
			.word		plr2 + PLAYER::name
menuWindowPlyrSelP3:
			.byte	$A2, $10, $01, $12, $34, $02, $10
			.word	     	strOptn3PSel0
			.byte	$90, $06, $10
menuWindowPlyrSelN3:
			.word		plr3 + PLAYER::name
menuWindowPlyrSelP4:
			.byte	$A2, $12, $01, $12, $35, $02, $12
			.word	     	strOptn4PSel0
			.byte	$90, $06, $12
menuWindowPlyrSelN4:
			.word		plr4 + PLAYER::name
menuWindowPlyrSelP5:
			.byte	$A2, $14, $01, $12, $36, $02, $14
			.word	     	strOptn5PSel0
			.byte	$90, $06, $14
menuWindowPlyrSelN5:
			.word		plr5 + PLAYER::name

			.byte	$00
	.assert	(* - PLYRSEL_P)  < $FE, error, "WindowPlyrSel must be on one page!"
			
			
menuPagePlyrSel0Keys:
		CMP	#'7'
		BPL	@keysExit
		
		CMP	#'1'
		BMI	@keysExit
		
		SEC
		SBC	#'1'
		
		STA	menuPlyrSelSelect
		TAX
		
		LDA	menuPlyrSelAllowCur
		BNE	@tstalive
		
		CPX	game + GAME::pActive
		BNE	@tstalive

		RTS
		
@tstalive:
		LDY	#PLAYER::status
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

;***FIXME:	Should this be testing that they aren't losing, too?
		LDA	($FB), Y
		AND	#$01
		BNE	@done
		
		RTS

@done:
		JSR	menuPopPage

		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	menuPlyrSelCallProc + 1
		BNE	@doProc
		
@keysExit:
		RTS
		
@doProc:
		JMP	(menuPlyrSelCallProc)
		

menuPagePlyrSel0Draw:
		LDA	#<menuWindowPlyrSel0
		STA	$A3
		LDA	#>menuWindowPlyrSel0
		STA	$A4
		
		LDX	#$00
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		
		BEQ	@hide
		
		LDA	menuWindowPlyrSelPN, X
		TAY
		LDA	#$A1
		STA	($A3), Y
		
		LDA	menuWindowPlyrSelNN, X
		TAY
		LDA	plrNameLo, X
		STA	($A3), Y
		INY
		LDA	plrNameHi, X
		STA	($A3), Y

		JMP	@next

@hide:
		LDA	menuWindowPlyrSelPN, X
		TAY
		LDA	#$A2
		STA	($A3), Y
		
		LDA	menuWindowPlyrSelNN, X
		TAY
		LDA	#<strDummyDummy0
		STA	($A3), Y
		INY
		LDA	#>strDummyDummy0
		STA	($A3), Y

@next:
		INX
		CPX	#$06
		BNE	@loop

		LDA	menuPlyrSelAllowCur
		BNE	@disp
		
		LDX	game + GAME::pActive
		
		LDA	menuWindowPlyrSelPN, X
		TAY
		LDA	#$A2
		STA	($A3), Y
		
		LDA	menuWindowPlyrSelNN, X
		TAY
		LDA	#<strDummyDummy0
		STA	($A3), Y
		INY
		LDA	#>strDummyDummy0
		STA	($A3), Y

@disp:
		LDA	#<menuWindowPlyrSel0
		STA	$FD
		LDA	#>menuWindowPlyrSel0
		STA	$FE
		
		JSR	screenPerformList
		
@exit:
		RTS


menuWindowJump0:
			.byte	$90, $01, $07
			.word	     	strHeaderJump0
;			.byte	$90, $01, $08
;			.word        	strDescSetup0

			.byte	$90, $02, $0A
			.word		strText0Jump0
			.byte	$90, $02, $0B
			.word		strText1Jump0

			.byte	$AF, $0D, $01, $12, $20, $02, $0D
			.word	     	strDesc7Titles0

			.byte	$00


menuPageJump0Keys:
		LDA	#<SFXNUDGE
		LDY	#>SFXNUDGE
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	game + GAME::fStpPsG
		CMP	#$00
		BEQ	@update
		
		LDY	#PLAYER::square
		LDA	#$00
		STA	($FB), Y
		STA	game + GAME::fStpPsG
		
		JSR	rulesLandOnSquare

@update:
		LDY	#PLAYER::square
		LDA	game + GAME::sStpDst
		STA	($FB), Y
		
		LDA	#$00
		STA	game + GAME::fAmStep
		STA	game + GAME::fStpSig
		
		LDA	game + GAME::gMdStep
		STA	game + GAME::gMode

		LDA	#$00
		STA	game + GAME::kWai
		
		LDA	game + GAME::sStpDst	;dest square
		LDX	#$00			;if passed go
		LDY	game + GAME::fPayDbl	;if we do something special
		JSR	rulesMoveToSquare

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JSR	gameUpdateMenu
		
		RTS
		

menuPageJump0Draw:
		LDA	#<menuWindowJump0
		STA	$FD
		LDA	#>menuWindowJump0
		STA	$FE
		
		JSR	screenPerformList
		RTS


menuWindowQuit0:	
			.byte	$90, $01, $07
			.word	     strHeaderQuit0
;			.byte	$90, $01, $08
;			.word        strDescSetup3
			.byte	$90, $02, $0A
			.word	     strText0Quit0
			.byte	$90, $02, $0B
			.word	     strText1Quit0
			
			.byte	$A1, $0D, $01, $12, $4E, $02, $0D
			.word	     strOptn1Setup3
			.byte	$A1, $0F, $01, $12, $59, $02, $0F
			.word	     strOptn0Setup3
			
			.byte	$00

menuPageQuit0Keys:
		CMP	#'N'
		BNE	@tstY
		
		JMP	@update

@tstY:
		CMP	#'Y'
		
		LDA	#<menuPageQuit1
		LDY	#>menuPageQuit1

		JSR	menuSetPage

		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		JMP	@ding

@update:
		JSR	gameUpdateMenu
		
@ding:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

		RTS
		

menuPageQuit0Draw:
		LDA	#<menuWindowQuit0
		STA	$FD
		LDA	#>menuWindowQuit0
		STA	$FE
		
		JSR	screenPerformList

		RTS


menuWindowQuit1:	
			.byte	$90, $01, $07
			.word	     strHeaderQuit0
			.byte	$90, $01, $08
			.word        strDescQuit1
			.byte	$90, $02, $0A
			.word	     strText0Quit1
			
			.byte	$A1, $0D, $01, $12, $59, $02, $0D
			.word	     strOptn0Setup3
			.byte	$A1, $0F, $01, $12, $4E, $02, $0F
			.word	     strOptn1Setup3
			
			.byte	$00

menuPageQuit1Keys:
		CMP	#'N'
		BNE	@tstY
		
		JMP	@update

@tstY:
		CMP	#'Y'
		
		LDA	game + GAME::gMode
		STA	game + GAME::gMdQuit
		
		LDA	game + GAME::pActive
		STA	game + GAME::pQuitCP

		JSR	rulesDoNextPlyr
		
		LDA	#$09
		STA	game + GAME::gMode
		
@update:
		JSR	gameUpdateMenu
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@ding:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6

		RTS
		

menuPageQuit1Draw:
		LDA	#<menuWindowQuit1
		STA	$FD
		LDA	#>menuWindowQuit1
		STA	$FE
		
		JSR	screenPerformList

		RTS


menuWindowQuit2:	
			.byte	$90, $01, $07
			.word	     strHeaderQuit2
;			.byte	$90, $01, $08
;			.word        strDescQuit1
			.byte	$90, $02, $0A
			.word	     strText0Quit0
			.byte	$90, $02, $0B
			.word	     strText1Quit0
			
			.byte	$A1, $0D, $01, $12, $4E, $02, $0D
			.word	     strOptn1Setup3
			.byte	$A1, $0F, $01, $12, $59, $02, $0F
			.word	     strOptn0Setup3
			
			.byte	$00

menuPageQuit2Keys:
		CMP	#'N'
		BNE	@tstY
		
		LDA	game + GAME::gMdQuit
		STA	game + GAME::gMode
		
		LDA	game + GAME::pQuitCP
		STA	game + GAME::pActive
		
		JMP	@update

@tstY:
		CMP	#'Y'
		
		JSR	rulesDoNextPlyr
		
		LDA	game + GAME::pQuitCP
		CMP	game + GAME::pActive
		BNE	@update
		
		JSR	gamePerformQuit
		
		JMP	@ding
		
		
@update:
		JSR	gameUpdateMenu
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@ding:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		

menuPageQuit2Draw:
		LDA	#<menuWindowQuit2
		STA	$FD
		LDA	#>menuWindowQuit2
		STA	$FE
		
		JSR	screenPerformList

		RTS


;===============================================================================
;FOR GAME.S
;===============================================================================


gameRemWlth0AddEquity:		
		LDY	#PLAYER::equity
		CLC
		LDA	($FB), Y
		ADC	menuTrade0RemWealth
		STA	menuTrade0RemWealth
		INY
		LDA	($FB), Y
		ADC	menuTrade0RemWealth + 1
		STA	menuTrade0RemWealth + 1
		LDA	#$00
		ADC	menuTrade0RemWealth + 2
		STA	menuTrade0RemWealth + 2
		
		RTS
		

gameRemWlth0SubFee:		
		LDY	#DEED::mFee		;At least a fee for mrtg
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		SEC
		LDA	menuTrade0RemWealth
		SBC	game + GAME::varD
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		SBC	game + GAME::varE
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		SBC	#$00
		STA	menuTrade0RemWealth + 2
		
		SEC
		LDA	menuTrade0RemCash
		SBC	game + GAME::varD
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		SBC	game + GAME::varE
		STA	menuTrade0RemCash + 1
		
		RTS
		
		
gameRemWlth1SubValue:
		SEC
		LDA	menuTrade1RemWealth
		SBC	game + GAME::varD
		STA	menuTrade1RemWealth
		LDA	menuTrade1RemWealth + 1
		SBC	game + GAME::varE
		STA	menuTrade1RemWealth + 1
		LDA	menuTrade1RemWealth + 2
		SBC	#$00
		STA	menuTrade1RemWealth + 2
		
		SEC
		LDA	menuTrade1RemCash
		SBC	game + GAME::varD
		STA	menuTrade1RemCash
		LDA	menuTrade1RemCash + 1
		SBC	game + GAME::varE
		STA	menuTrade1RemCash + 1
		
		RTS
		
		
gameRemWlth0SubValue:
		SEC
		LDA	menuTrade0RemWealth
		SBC	game + GAME::varD
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		SBC	game + GAME::varE
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		SBC	#$00
		STA	menuTrade0RemWealth + 2

		RTS
		

gamePerformQuit:
		LDX	game + GAME::pFirst
		STX	game + GAME::varF
		STX	game + GAME::varG
		
		LDA	#$00
		STA	game + GAME::varH
		STA	game + GAME::varI
		
		JMP	@update
		
@loop:		
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
		
		JSR	gameCalcPlayerScore
		
		LDA	game + GAME::varH
		STA	game + GAME::varD
		LDA	game + GAME::varI
		STA	game + GAME::varE
	
;		D, E < (O, P) -> CLC | SEC 
		JSR	gameAmountIsLessDirect
		BCS	@next
		
@found:
		LDA	game + GAME::varG
		STA	game + GAME::varF
		
		LDA	game + GAME::varO
		STA	game + GAME::varH
		LDA	game + GAME::varP
		STA	game + GAME::varI
	
@next:
		INC	game + GAME::varG
		LDX	game + GAME::varG
		
		CPX	#$06
		BNE	@tstloop
		
@wrap:		
		LDX	#$00
		STX	game + GAME::varG
		
@tstloop:
		CPX	game + GAME::pFirst
		BEQ	@finish

@update:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
	
		JMP	@loop

@finish:
		LDA	game + GAME::varF
		STA	game + GAME::pActive
		STA	game + GAME::pLast
		
		LDA	#$05
		STA	game + GAME::gMode
		
		JSR	gameUpdateMenu
		
		LDA	#musTuneGameOver
		JSR	SNDBASE + 0

		RTS


doGameAddScoreElement:
		CLC
		LDA	game + GAME::varO
		ADC	game + GAME::varM
		STA	game + GAME::varO
		LDA	game + GAME::varP
		ADC	game + GAME::varN
		STA	game + GAME::varP
		
		RTS


doGameScoreEquity:
		LDY	#PLAYER::equity
		LDA	($FB), Y
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		STA	game + GAME::varE
		LSR
		STA	game + GAME::varE
		LDA	game + GAME::varD
		ROR
		STA	game + GAME::varD

		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	game + GAME::varM
		INY
		LDA	($FB), Y
		STA	game + GAME::varN
		
		LDX	#$02
@xDiv8Loop:
		ASL
		ROR	game + GAME::varN
		ROR	game + GAME::varM
		
		LDA	game + GAME::varN
		
		DEX
		BPL	@xDiv8Loop
		
		CLC
		LDA	game + GAME::varM
		ADC	game + GAME::varD
		STA	game + GAME::varM
		LDA	game + GAME::varN
		ADC	game + GAME::varE
		STA	game + GAME::varN
		
		RTS

doGameScoreCntDeeds:
		LDA	#$00
		STA	game + GAME::varM
		STA	game + GAME::varN
		
		LDY	#PLAYER::oGrp01
		LDX	#$00
@loop:
		LDA	($FB), Y
		CLC
		ADC	game + GAME::varM
		STA	game + GAME::varM
		
		INY
		INX
		
		CPX	#$0A
		BNE	@loop
		
		RTS
		
		
doGameScoreCntGOFree:
		LDA	#$00
		STA	game + GAME::varM
		STA	game + GAME::varN
		
		LDA	game + GAME::varA
		CMP	game + GAME::pGF0Crd
		BNE	@tst1
		
		INC	game + GAME::varM
		
@tst1:
		CMP	game + GAME::pGF1Crd
		BNE	@exit
		
		INC	game + GAME::varM
		
@exit:
		RTS


doGameScoreCntGroups:
;***TODO:	Isn't this supposed to be groups that are wholy owned?

		LDA	#$00
		STA	game + GAME::varM
		STA	game + GAME::varN
		
		LDY	#PLAYER::oGrp01
		LDX	#$00
@loop:
		LDA	($FB), Y
		BEQ	@next
				
		TYA
		PHA
		
		TAY
		DEY
		TYA
		ASL

		CLC
		ADC	game + GAME::varM
		STA	game + GAME::varM
		
		PLA
		TAY

@next:
		INY
		INX
		
		CPX	#$0A
		BNE	@loop
		
		RTS
		
		
doGameScoreImprvBonus:
		LDA	#$00
		STA	game + GAME::varM
		STA	game + GAME::varN
		
		LDX	#$00
		STX	game + GAME::varB
		
@loop:
		LDA	sqr00, X
		INX
		CMP	game + GAME::varA
		BNE	@next

		TXA
		PHA

		LDA	game + GAME::varB
		JSR	gameGetCardPtrForSquare
		
		PLA
		TAX
		
		LDY	#GROUP::pImprv
		LDA	($FD), Y
		BEQ	@next

		LDY	#$00

		LDA	sqr00, X
		AND	#$08
		BEQ	@tsths
		
		LDY	#$04
		JMP	@calc
		
@tsths:
		LDA	sqr00, X
		AND	#$07
		BEQ	@next
		
		TAY
		DEY
		
@calc:
		TYA
		PHA

		LDY	#GROUP::aScrTab
		LDA	($FD), Y
		STA	$A3
		INY
		LDA	($FD), Y
		STA	$A4
		
		PLA
		TAY
		
		LDA	($A3), Y
		
		CLC
		ADC	game + GAME::varM
		STA	game + GAME::varM
		LDA	#$00
		ADC	game + GAME::varN
		STA	game + GAME::varN


@next:
		INC	game + GAME::varB

		INX
		CPX	#$50
		BNE	@loop


		RTS


doGameScoreStationBonus:
		LDA	#$00
		STA	game + GAME::varM
		STA	game + GAME::varN
		
		LDY	#PLAYER::oGrp09
		LDA	($FB), Y
		
		TAX
		BEQ	@exit
		
		DEX
		LDA	#$01
		
@loop:
		ASL
		DEX
		BPL	@loop

		STA	game + GAME::varM
		
@exit:
		RTS


doGameScoreUtilityBonus:
		LDA	#$00
		STA	game + GAME::varN
		
		LDY	#PLAYER::oGrp0A
		LDA	($FB), Y
		
		STA	game + GAME::varM
		
		RTS


;-------------------------------------------------------------------------------
gameCalcPlayerScore:
;-------------------------------------------------------------------------------
		STX	game + GAME::varA
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	#$00
		STA	game + GAME::varO
		STA	game + GAME::varP
		
		JSR	doGameScoreEquity
		JSR	doGameAddScoreElement
		
		JSR	doGameScoreCntDeeds
		JSR	doGameAddScoreElement
		
		JSR	doGameScoreCntGOFree
		JSR	doGameAddScoreElement
		
		JSR	doGameScoreCntGroups
		JSR	doGameAddScoreElement
		
		JSR	doGameScoreImprvBonus
		JSR	doGameAddScoreElement
		
		JSR	doGameScoreStationBonus
		JSR	doGameAddScoreElement
		
		JSR	doGameScoreUtilityBonus
		JSR	doGameAddScoreElement
		
		RTS


;-------------------------------------------------------------------------------
gameDispSqrInfoDlg:
;-------------------------------------------------------------------------------
		LDA	game + GAME::sSelect
		CMP	#$FF
		BEQ	@exit

		LDA 	#<dialogDlgSqrInfo0
		LDY	#>dialogDlgSqrInfo0
		
		JSR	dialogSetDialog

		LDA	#<$DB3B
		STA	game + GAME::aWai
		LDA	#>$DB3B
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai
		STA	game + GAME::dlgVis
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		LDA	#$00
		STA	game + GAME::pVis
		JSR	gamePlayersDirty		

@exit:
		RTS


;-------------------------------------------------------------------------------
gamePerfTrdSelBlink:
;-------------------------------------------------------------------------------
		LDA	game + GAME::fStpSig
		BNE	@tst
		
		RTS

@tst:
		LDA	game + GAME::fTrdSlL
		EOR	#$01
		STA	game + GAME::fTrdSlL
		
		BNE	@on
		
		LDX	game + GAME::cTrdSlB
		JMP	@proc
		
@on:
		LDX	#$D1
		
@proc:
		LDA	game + GAME::aTrdSlH
		STA	$A3
		LDA	game + GAME::aTrdSlH + 1
		STA	$A4
		
		LDY 	#$00
		
		TXA
		STA	($A3), Y
		
		LDA	#$00
		STA	game + GAME::fStpSig
		
		RTS


;-------------------------------------------------------------------------------
gamePerfStepping:
;-------------------------------------------------------------------------------
		LDA	#$01
		STA	game + GAME::fAmStep
		
		LDA	game + GAME::fStpSig
		BNE	@proc
		
		RTS
		
@proc:
		LDA	#<SFXNUDGE
		LDY	#>SFXNUDGE
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square
		
		LDA	($FB), Y
		LDX	#$01
		JSR	rulesCalcNextSqr
		
		STA	($FB), Y
		CMP	game + GAME::sStpDst
		BEQ	@finish

		CMP	#$00
		BNE	@update
		
		LDA	#$00
		STA	game + GAME::fStpPsG
		
		JSR	rulesLandOnSquare

@update:
		LDA	#$00
		STA	game + GAME::fStpSig
		
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty		
		
		RTS

@finish:
		LDA	#$00
		STA	game + GAME::fAmStep
		STA	game + GAME::fStpSig
		
		LDA	game + GAME::gMdStep
		STA	game + GAME::gMode

		LDA	#$00
		STA	game + GAME::kWai
		
		LDA	game + GAME::sStpDst	;dest square
		LDX	#$00			;if passed go
		LDY	game + GAME::fPayDbl	;if we do something special
		JSR	rulesMoveToSquare

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JSR	gameUpdateMenu
		
		RTS


;-------------------------------------------------------------------------------
gameShowPlayerDlg:
;-------------------------------------------------------------------------------
		JSR	doDialogDlgWaitFor0Backup

		LDA	game + GAME::dlgVis
		BNE	@cont
		
		LDA	#$00
		STA	dialogWaitFor0Keys + 1
		
@cont:
		LDA 	#<dialogDlgWaitFor0
		LDY	#>dialogDlgWaitFor0
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog

		RTS


;-------------------------------------------------------------------------------
gameGetCardPtrForSquare:
;-------------------------------------------------------------------------------
		ASL
		TAX
		
gameGetCardPtrForSquareImmed:
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC	;index
		
		LDA	rulesSqr0, X		
		STA	game + GAME::varB	;group
		TAX
		
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		STA	$FE
		PLA
		STA	$FD

		RTS
		

;-------------------------------------------------------------------------------
gameContinueAfterPost:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$EF
		STA	($FB), Y

		LDY	#PLAYER::square
		LDA	($FB), Y

		PHA
		
		CLC
		LDA	game + GAME::dieA
		ADC	game + GAME::dieB
		
		TAX
		PLA
		
		JSR	rulesCalcNextSqr
		LDY	#$00
		
		PHA

		LDA	game + GAME::fDoJump
		BNE	@doJump
		
		PLA
;***dengland	This is going to call back into gameUpdateMenu but it should be
;		fine.
		JSR	rulesInitStepping

		RTS
		
@doJump:
		LDY	#>SFXSPLAT		;In case there are no other sfx
		LDA	#<SFXSPLAT
		LDX	#$07
		JSR	SNDBASE + 6
		
		PLA
		JSR	rulesMoveToSquare
		
;***dengland	This is going to call back into gameUpdateMenu but it should be
;		fine.
		JSR	gameUpdateMenu
		
		LDA	game + GAME::dirty	;???Needed???
		ORA	#$01
		STA	game + GAME::dirty
		
		RTS


;-------------------------------------------------------------------------------
gameMustPayAfterPost:
;-------------------------------------------------------------------------------
		LDA	game + GAME::gMode
		STA	game + GAME::gMdMPyI	
		
		LDA	game + GAME::pActive
		STA	game + GAME::pMstPyI

		STA	game + GAME::pMPyLst
		STA	game + GAME::pMPyCur

		LDA	#$03
		STA	game + GAME::gMode
		
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty		

		LDA	#<menuPageMustPay0
		LDY	#>menuPageMustPay0
		
		JSR	menuSetPage

		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		
		
;-------------------------------------------------------------------------------
gameSwitchMPayToElmin:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		JSR	gamePerfLosing
		JSR	rulesDoPlayerElimin
		
		RTS
		
		
;-------------------------------------------------------------------------------
gameUpdateForMustPay:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::status		
		LDX	game + GAME::pMPyCur
		JMP	@next
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	($FB), Y		;Are they active?
		AND	#$01
		BEQ	@next

		LDA	($FB), Y		;Are they not losing?
		AND	#$02
		BNE	@switchelmin

		LDA	($FB), Y		;Are they in debt?
		AND	#$08
		BEQ	@next

		STX	game + GAME::pMPyCur	;All yes then found player
		STX	game + GAME::pActive
		JMP	@update
		
@next:
		INX

		CPX	#$06
		BNE	@tstloop
		
@wrap:		
		LDX	#$00
		
@tstloop:
		CPX	game + GAME::pMPyLst
		BNE	@loop

		JSR	gameRestoreFromMustPay
		RTS

@update:
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty		
		
		LDA	#<menuPageMustPay0
		LDY	#>menuPageMustPay0
		
		JSR	menuSetPage

		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		
@switchelmin:
		STX	game + GAME::pMPyCur
		STX	game + GAME::pActive
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		JSR	gameSwitchMPayToElmin
		
		RTS
		
		
;-------------------------------------------------------------------------------
gameRestoreFromMustPay:
;-------------------------------------------------------------------------------
		LDA	game + GAME::pMstPyI
		STA	game + GAME::pActive
		
		LDA	game + GAME::gMdMPyI	
		STA	game + GAME::gMode
		
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty

;***dengland	This is going to call back into gameUpdateMenu but it should be
;		fine.
		JSR	gameUpdateMenu
		
		RTS
		

;-------------------------------------------------------------------------------
gamePerfGameOver:
;-------------------------------------------------------------------------------
		LDA 	#<dialogDlgGameOver0
		LDY	#>dialogDlgGameOver0
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog
		
;		LDA	#musTuneGameOver
;		JSR	SNDBASE + 0
		
		RTS


;-------------------------------------------------------------------------------
gamePerfLosing:
;-------------------------------------------------------------------------------
		LDA	game + GAME::pActive
		STA	dialogTempElimin0P

		LDA 	#<dialogDlgElimin0
		LDY	#>dialogDlgElimin0
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog

		LDA	game + GAME::pCount
		CMP	#$02
		BEQ	@over

		LDA	#musTunePlyrElim
		JSR	SNDBASE + 0
		
		RTS
		
@over:
		LDA	#musTuneGameOver
		JSR	SNDBASE + 0

		RTS

;-------------------------------------------------------------------------------
gameUpdateMenu:
;-------------------------------------------------------------------------------
		LDA	game + GAME::gMode
		BNE	@tstTrading
		
		JMP	@tstlosing			;For/from normal mode

@tstTrading:
		CMP	#$08
		BNE	@tstStepping
		
		LDA	#<menuPageTrade6			;game mode 8
		LDY	#>menuPageTrade6
		
		JMP	@update

@tstStepping:
		CMP	#$06
		BNE	@tstGameOver
		
		LDA	#<menuPageJump0			;game mode 6
		LDY	#>menuPageJump0
		
		JMP	@update

@tstGameOver:
		CMP	#$05
		BNE	@tstelimin

		JSR	gamePerfGameOver		;game mode 5 
		RTS

@tstelimin:
		CMP	#$04				;Elimin. interrupt?
		BNE	@tstmustpay
		
		LDA	#<menuPageElimin0			;game mode 4
		LDY	#>menuPageElimin0

		JMP	@update
		
@tstmustpay:
		CMP	#$03
		BNE	@tsttrade

		LDA	game + GAME::pMPyCur
		CMP	#$FF
		BEQ	@lvintrpt1

		JSR	gameUpdateForMustPay
		RTS
		
@lvintrpt1:
		JSR	gameRestoreFromMustPay
		RTS

@tsttrade:
		CMP	#$02
		BNE	@tstauction

		LDA 	#<menuPageTrade1
		LDY	#>menuPageTrade1
		
		JMP	@update

@tstauction:
		CMP	#$01
		BNE	@tstquit
		
		LDA 	#<menuPageAuctn0
		LDY	#>menuPageAuctn0
		
		JMP	@update
		
@tstquit:
		CMP	#$09
		BNE	@tstlosing

		LDA 	#<menuPageQuit2
		LDY	#>menuPageQuit2
		
		JMP	@update
		
@tstlosing:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$02
		BEQ	@tstmbuy

		JSR	gamePerfLosing
		RTS

@tstmbuy:
		LDA	#$01
		CMP 	game + GAME::fMBuy
		BNE	@normal
		
		LDY	#PLAYER::square
		LDA	($FB), Y

		JSR	gameGetCardPtrForSquare

		LDY	#DEED::pPurch
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR 	prmptForSale
		
		LDA 	#<menuPagePlay1
		LDY	#>menuPagePlay1
		
		JMP	@update

@normal:
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$40		
		BEQ	@test0
		
		LDA 	#<menuPageGaol0
		LDY	#>menuPageGaol0
		
		JMP	@update
@test0:
		LDA	($FB), Y
		AND	#$10		
		BEQ	@test1
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$02
		BNE	@switchelmin0
		
		LDA	($FB), Y
		AND	#$08
		BEQ	@nomustpay

		JSR	gameMustPayAfterPost
		RTS
		
@nomustpay:
		JSR	gameContinueAfterPost
		RTS

@switchelmin0:
		JSR	gameSwitchMPayToElmin
		RTS

@test1:
		LDA	($FB), Y
		AND	#$20		
		BEQ	@test2
		
		LDA 	#<menuPageGaol3
		LDY	#>menuPageGaol3
		
		JMP	@update

@test2:
		LDA	($FB), Y
		AND	#$80		
		BEQ	@play0

		LDA 	#<menuPageGaol1
		LDY	#>menuPageGaol1
		
		JMP	@update

@play0:
		LDA 	#<menuPagePlay0
		LDY	#>menuPagePlay0
		
@update:
		JSR	menuSetPage

		LDA	#$08
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS

;------------------------------------------------------------------------------
;gameMoveSelectFwd
;------------------------------------------------------------------------------
gameMoveSelectFwd:
		LDX	game + GAME::sSelect
		INX
		TXA
		CMP	#$28
		BNE	@cont

		LDA	#$00
		
@cont:
		PHA
		JSR	gameMoveSelect

		PLA
		LDX	#$00
		JSR	rulesCalcQForSquare
		
		CMP	game + GAME::qVis
		BEQ	@exit
		
		STA	game + GAME::qVis

		JSR	gamePlayersDirty
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

@exit:

		RTS


;------------------------------------------------------------------------------
;gameMoveSelectBck
;------------------------------------------------------------------------------
gameMoveSelectBck:
		LDX	game + GAME::sSelect
		DEX
		TXA
		CMP	#$FF
		BNE	@cont

		LDA	#$27
		
@cont:
		PHA
		JSR	gameMoveSelect

		PLA
		LDX	#$01
		JSR	rulesCalcQForSquare
		
		CMP	game + GAME::qVis
		BEQ	@exit
		
		STA	game + GAME::qVis

		JSR	gamePlayersDirty
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		RTS
		

;------------------------------------------------------------------------------
;gameMovePlyrFwd
;------------------------------------------------------------------------------
gameMovePlyrFwd:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square
		LDA	($FB), Y
		CLC
		ADC	#$01
		STA	($FB), Y

		CMP	#$28
		BMI 	@exit

		LDA	#$00
		STA	($FB), Y
		
@exit:
		LDY	#PLAYER::dirty
		LDA	#$01
		STA	($FB), Y
		
		RTS
		
;------------------------------------------------------------------------------
;gameMovePlyrBck
;------------------------------------------------------------------------------
gameMovePlyrBck:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square
		LDA	($FB), Y
		SEC
		SBC	#$01
		STA	($FB), Y

		BPL	@exit
		
		LDA	#$27
		STA	($FB), Y
		
@exit:
		LDY	#PLAYER::dirty
		LDA	#$01
		STA	($FB), Y
		
		RTS

;------------------------------------------------------------------------------
;gameToggleGaol
;------------------------------------------------------------------------------
gameToggleGaol:
		TXA
		PHA

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		PLA
		TAX
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$80
		BEQ	@cont

		CPX	#$01			;coming out of gaol
		BNE	@outsound1

		LDA	#$32
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE

		LDX	game + GAME::pActive
		JSR	rulesSubCash		

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptPostBail
		
		JMP	@outsound0
@cont:
		LDY	#PLAYER::status
		LDA	($FB), Y		;going into gaol
		ORA	#$40
		STA	($FB), Y

		LDY	#PLAYER::square
		LDA	#$0A
		STA	($FB), Y
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptGoneGaol
		
		LDA	#musTuneGaol
		JSR	SNDBASE + 0

		JMP	@dotoggle

@outsound0:
		TXA
		PHA

		LDA	#<SFXRENT0
		LDY	#>SFXRENT0
		LDX	#$07
		JSR	SNDBASE + 6
		
		PLA
		TAX
		
		JMP	@dotoggle
		
@outsound1:
		TXA
		PHA

		LDA	#<SFXSLAM
		LDY	#>SFXSLAM
		LDX	#$07
		JSR	SNDBASE + 6
		
		PLA
		TAX

@dotoggle:
		LDY	#PLAYER::status
		LDA	($FB), Y
		EOR	#$80
		STA	($FB), Y
		
		LDY	#PLAYER::dirty
		LDA	#$01
		STA	($FB), Y

		LDY	#PLAYER::nGRls
		LDA	#$00
		STA	($FB), Y

		JSR	gameUpdateMenu

		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


;-------------------------------------------------------------------------------
;gameCheckGaolFree
;-------------------------------------------------------------------------------
gameCheckGaolFree:
		LDX	#$00

		LDA	game + GAME::pGF0Crd
		CMP	game + GAME::pActive
		BEQ	@canfree
		
		LDX	#$01
		
		LDA	game + GAME::pGF1Crd
		CMP	game + GAME::pActive
		BNE	@fail
		
@canfree:
		LDA	#$FF

		CPX	#$00
		BEQ	@1
		
		STA	game + GAME::pGF1Crd
		JMP	@cont
@1:
		STA	game + GAME::pGF0Crd
		
@cont:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$7F
		STA	($FB), Y
		
		LDA	#$00
		LDY	#PLAYER::nGRls
		STA	($FB), Y
		
		LDA	#<SFXSLAM
		LDY	#>SFXSLAM
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDY	#PLAYER::dirty
		LDA	#$01
		STA	($FB), Y

		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
	
		RTS

@fail:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6

		RTS


;-------------------------------------------------------------------------------
gameNextAuction:
;-------------------------------------------------------------------------------
		LDA	game + GAME::fAForf	;Have all players already forfeited?
		CMP	#$3F
		BEQ	@auctionover

		LDA	game + GAME::fAPass	;Have all players already passed?
		CMP	#$3F
		BEQ	@auctionover

		LDY	#PLAYER::status

		LDX	game + GAME::pActive
		JMP	@next

@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	($FB), Y
		AND	#$01
		
		BEQ	@next
		
		LDA	game + GAME::fAForf
		AND	plrFlags, X
		BEQ	@cont
		
@next:
		INX
		CPX	#$06
		BNE	@tstloop
		
@wrap:		
		LDX	#$00
		
@tstloop:
		CPX	game + GAME::pActive
		BNE	@loop
		
@cont:
		STX	game + GAME::pActive

		LDA	game + GAME::pWAuctn	;If no one bids, everyone has to pass
		CMP	#$FF			;or forfeit, explicitly
		BEQ	@update

		LDA	game + GAME::pAFirst	;Have we come back to the last bidder?
		CMP	game + GAME::pActive
		BEQ	@auctionover		;Yes, auction over
		
		JMP	@update
		
@auctionover:	
		LDA	game + GAME::pWAuctn	;Did no one bid?
		CMP	#$FF
		BEQ	@endauction
		
		TAX
		STX	game + GAME::pActive	;Temporarily set active player...
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#$01			;in order to buy deed but
		LDX	game + GAME::sAuctn	;don't sub cash also set a specific square
		JSR	rulesBuyTitleDeed	
		
		LDA	game + GAME::mAuctn
		STA	game + GAME::varD
		LDA	game + GAME::mAuctn + 1
		STA	game + GAME::varE
		
		LDX	game + GAME::pActive
		JSR	rulesSubCash

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptBought
		
@endauction:
		LDA	game + GAME::sAuctn
		JSR	gameDeselect

		LDA	game + GAME::gMdActn	;go back to normal mode
		STA	game + GAME::gMode
		LDA	game + GAME::pRecall	;go back to initial player
		STA	game + GAME::pActive
		
@update:
		JSR	gameUpdateMenu

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS
		

;-------------------------------------------------------------------------------
gameBuyTitleDeed:
;-------------------------------------------------------------------------------
		LDY	#$00
		JSR	rulesBuyTitleDeed
		
		RTS


;-------------------------------------------------------------------------------
gameInitiatePStats:
;-------------------------------------------------------------------------------
		LDA 	#<dialogDlgPStats0
		LDY	#>dialogDlgPStats0
		
		JSR	dialogSetDialog
		
		LDA	#<$DB3B
		STA	game + GAME::aWai
		LDA	#>$DB3B
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai
		STA	game + GAME::dlgVis
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		LDA	#$00
		STA	game + GAME::pVis
		JSR	gamePlayersDirty		

		RTS


;-------------------------------------------------------------------------------
gameInitiateTrade:
;-------------------------------------------------------------------------------
		LDX	#.sizeof(TRADE) - 1
		LDA	#$00
@loop0:
		STA 	trade0, X
		STA	trade1, X
		
		DEX
		BPL	@loop0
		
		LDX	#$1B
@loop1:
		STA	trddeeds0, X
		STA	trdrepay0, X
		
		STA	trddeeds1, X
		STA	trdrepay1, X
		
		DEX
		BPL	@loop1

		LDA	#$00
		STA	menuWindowTradeCanConf

		LDA	#$FF
		STA	menuPlyrSelSelect
		
		LDX	#TRADE::player
		STA	trade0, X

		LDA	game + GAME::pActive
		STA	trade1, X
		
		JSR	menuTrade0RWealthRecalc

		LDA 	#<menuPageTrade0
		LDY	#>menuPageTrade0
		JSR	menuSetPage
		
		LDA	#$03
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


;-------------------------------------------------------------------------------
gamePrepTradePtrs:
;-------------------------------------------------------------------------------
		CMP	#$01
		BEQ	@trd1
		
		LDA	#<trade0
		STA	$A3
		LDA	#>trade0
		STA	$A4

		LDA	#<trddeeds0
		STA	$A5
		LDA	#>trddeeds0
		STA	$A6

		LDA	#<trdrepay0
		STA	$A7
		LDA	#>trdrepay0
		STA	$A8
		
		RTS
		
@trd1:
		LDA	#<trade1
		STA	$A3
		LDA	#>trade1
		STA	$A4
		
		LDA	#<trddeeds1
		STA	$A5
		LDA	#>trddeeds1
		STA	$A6

		LDA	#<trdrepay1
		STA	$A7
		LDA	#>trdrepay1
		STA	$A8
		
		RTS
		

;-------------------------------------------------------------------------------
gameUnpackTrdData:
;-------------------------------------------------------------------------------
		PHA

		JSR	gamePrepTradePtrs

		LDY	#.sizeof(TRADE) - 1	;Copy basic trade info
@loop0:
		LDA	($A3), Y
		STA	trade2, Y
		
		DEY
		BPL	@loop0

		LDX	#$29			;Init deeds in exp. area
		LDA	#$00			;because they will be randomly
@loop1:						;populated in actual populate.
		STA	trddeeds2, X
		
		DEX
		BPL	@loop1

		LDX	#$27			;Init repay data, too
		LDA	#$00
@loop1a:
		STA	trdrepay2, X
		
		DEX
		BPL	@loop1a


		LDY	#TRADE::cntDeed		;Populate exp. deed data
		LDA	($A3), Y
		STA	game + GAME::varA
		
		BEQ	@gofree
		
		LDY	#$00
@loop2:
		LDA	($A5), Y
		TAX
		LDA	#$01
		STA	trddeeds2, X
		
		LDA	($A7), Y
		STA	trdrepay2, X
		
		INY
		CPY	game + GAME::varA
		BNE	@loop2
		
		
@gofree:
		LDY	#TRADE::gofree
		LDA	($A3), Y
		
		AND	#$01
		BEQ	@gofree2
		
		LDA	#$01
		LDX	#$28
		STA	trddeeds2, X
		
@gofree2:
		LDA	($A3), Y
		
		AND	#$02
		BEQ	@exit
		
		LDA	#$01
		LDX	#$29
		STA	trddeeds2, X
	
@exit:
		PLA
		
		LDY	#TRADE::cntDeed		;This is ugly but we'll reuse 
		STA	trade2, Y		;the count to hold the flag for 
						;which trade data
		RTS


;-------------------------------------------------------------------------------
gameInitTrdSelector:
;-------------------------------------------------------------------------------
		JSR	gameUnpackTrdData
		
		LDA 	#<dialogDlgTrdSel0
		LDY	#>dialogDlgTrdSel0
		
		JSR	dialogSetDialog

		LDA	#$00
		STA	game + GAME::kWai
		
		LDA	#$01
		EOR	game + GAME::dlgVis
		STA	game + GAME::dlgVis
		LDA	#$01
		EOR	game + GAME::dlgVis
		STA	game + GAME::pVis
		
		JSR	gamePlayersDirty
		
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		LDA	game + GAME::gMode
		STA	game + GAME::fTrdSlM

		RTS


;-------------------------------------------------------------------------------
gameInitTrdFail0:
;-------------------------------------------------------------------------------
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog
		
		RTS


;-------------------------------------------------------------------------------
gameInitTrdIntrpt:
;-------------------------------------------------------------------------------
		LDA	menuTrade0RemWealth + 2
		BMI	@fail0
		
		LDA	menuTrade0RemCash + 1
		BPL	@tstWantedRW
		
@fail0:
		LDA 	#<dialogDlgTrade2
		LDY	#>dialogDlgTrade2
		
		JSR	gameInitTrdFail0
		RTS

@tstWantedRW:
		JSR	menuTrade1RWealthRecalc
		LDA	menuTrade1RemWealth + 2
		BMI	@fail1
		
		LDA	menuTrade1RemCash + 1
		BPL	@initiate

@fail1:
		LDA 	#<dialogDlgTrade3
		LDY	#>dialogDlgTrade3
		
		JSR	gameInitTrdFail0
		RTS
		
@initiate:
gameInitTrdIntrptDirect:
		LDA	game + GAME::pActive
		STA	game + GAME::pTrdICP
		
		LDY	#TRADE::player
		LDA	trade0, Y
		STA	game + GAME::pActive
		
		LDA	game + GAME::gMode
		STA	game + GAME::gMdTrdI
		
		LDA	#$02
		STA	game + GAME::gMode
		
		JSR	gameUpdateMenu

		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		
		
		RTS
		

;-------------------------------------------------------------------------------
gameApproveTrade:
;-------------------------------------------------------------------------------
		LDA	menuTrade1RemWealth + 2
		BMI	@fail0
		
		LDA	menuTrade1RemCash + 1
		BPL	@tstWarning
		
@fail0:
		LDA 	#<dialogDlgTrade4
		LDY	#>dialogDlgTrade4
		
		JSR	gameInitTrdFail0
		RTS

@tstWarning:
		LDA	menuTrade1Warn0
		BEQ	@approve
		
		LDA	#$00
		STA	menuTrade1Warn0
		
		LDA 	#<dialogDlgTrade5
		LDY	#>dialogDlgTrade5
		
		JSR	gameInitTrdFail0
		RTS

@approve:
		LDA	#$00
		STA	game + GAME::fTrdTyp
		
		LDA	game + GAME::fDoJump
		BEQ	@stepping

		LDA	#$00
		STA	ui + UI::fActInt		
		
		JMP	@proc
		
@stepping:
		LDA	#$01
		STA	ui + UI::fActInt		
		
@proc:
		JSR	gamePerfTradeFull

		RTS


;-------------------------------------------------------------------------------
gamePerfTradeStep:
;-------------------------------------------------------------------------------
;		JSR	gamePerfTradeDeselect

;		Check if doing stage 0 - offered xfer
		LDA	game + GAME::fTrdStg
		BEQ	@stage0
		
		JMP	@tststage1
		
@stage0:
;		- for each deed
		LDY	#TRADE::cntDeed
		LDA	trade1, Y
		CMP	game + GAME::iTrdStp 
		BEQ	@stage0next
	
		LDA	game + GAME::fTrdPhs
		BNE	@stage0phase1

		LDA	#UI_ACT_TRDE
		STA	$68

		LDY	#TRADE::player
		LDA	trade0, Y
		
		STA	$69
		
;		STA	game + GAME::pLast
;		STA	game + GAME::pActive
		
;			- phase 0 - transfer deed
		LDX	game + GAME::iTrdStp 
		LDA	trddeeds1, X

		STA	$6A
		
		JSR	uiEnqueueAction

;		JSR	gamePerfTradeFocus
;		
;		LDA	trddeeds1, X
;		TAX
;		JSR	rulesTradeTitleDeed
;		
;		JSR	gamePerfTradeDeselect

;***

;				- if mrtg, go to phase 1
		LDX	game + GAME::iTrdStp 
		LDA	trdrepay1, X
		AND	#$80
		BNE	@stage0tophase1
		
;				- else, next deed
		JMP	@stage0nextdeed

@stage0tophase1:
		LDA	#$01
		STA	game + GAME::fTrdPhs
		RTS
		
@stage0phase1:
		LDY	#TRADE::player
		LDA	trade0, Y
;		STA	game + GAME::pLast
;		STA	game + GAME::pActive
		
		STA	$69
		
;			- phase 1 - fee/repay deed
		LDX	game + GAME::iTrdStp 
		LDA	trdrepay1, X
		AND	#$01
		BNE	@stage0ph1repay

		LDA	#UI_ACT_PFEE
		STA	$68

		LDX	game + GAME::iTrdStp 

		LDA	trddeeds1, X
		
		STA	$6A
		
		JSR	uiEnqueueAction
		
;		JSR	gamePerfTradeFocus
;
;		LDA	trddeeds1, X
;		JSR	rulesMortgageFeeImmed
;
;		JSR	gamePerfTradeDeselect
		
		JMP	@stage0nextdeed
		
@stage0ph1repay:

		LDA	#UI_ACT_REPY
		STA	$68

		LDX	game + GAME::iTrdStp 
		LDA	trddeeds1, X

		STA	$6A
		
		JSR	uiEnqueueAction
		
;		JSR	gamePerfTradeFocus
;
;		LDA	trddeeds1, X
;		JSR	rulesUnmortgageImmed
;		
;		JSR	gamePerfTradeDeselect


@stage0nextdeed:
;			- next deed
		INC 	game + GAME::iTrdStp 
		LDA	#$00
		STA	game + GAME::fTrdPhs
		RTS

@stage0next:
;		- if doing actual trade (not elimin) continue to stage 1
		LDA	#$00
		STA	game + GAME::iTrdStp
		STA	game + GAME::fTrdPhs
		
		LDA	game + GAME::fTrdTyp
		BNE	@stage0elimin
		
		LDA	#$01
		STA	game + GAME::fTrdStg
		
		RTS
		
@stage0elimin:
		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		BEQ	@stage0term
		
		LDA	#$02
		STA	game + GAME::fTrdStg
		
		LDA	#$00
		STA	game + GAME::iTrdStp
		STA	game + GAME::fTrdPhs
;		STA	game + GAME::kWai
		
;		JSR	gamePerfTradeDeselect
		
		RTS
		
@stage0term:
		LDA	#$FF
		STA	game + GAME::fTrdStg
		
		RTS

;		check if doing stage 1 - wanted xfer
@tststage1:
		CMP	#$01
		BEQ	@stage1
		
		JMP	@tststage2

@stage1:
;		- for each deed
		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		CMP	game + GAME::iTrdStp 
		BEQ	@stage1next
	
		LDA	game + GAME::fTrdPhs
		BNE	@stage1phase1
	
		LDA	#UI_ACT_TRDE
		STA	$68

		LDY	#TRADE::player
		LDA	trade1, Y
		
		STA	$69
		
;		STA	game + GAME::pLast
;		STA	game + GAME::pActive
		
;			- phase 0 - transfer deed
		LDX	game + GAME::iTrdStp 
		LDA	trddeeds0, X
		
		STA	$6A
		
		JSR	uiEnqueueAction
		
		
;		JSR	gamePerfTradeFocus
;
;		LDA	trddeeds0, X
;		TAX
;		JSR	rulesTradeTitleDeed
;		
;		JSR	gamePerfTradeDeselect



;				- if mrtg, go to phase 1
		LDX	game + GAME::iTrdStp 
		LDA	trdrepay0, X
		AND	#$80
		BNE	@stage1tophase1
		
;				- else, next deed
		JMP	@stage1nextdeed

@stage1tophase1:
		LDA	#$01
		STA	game + GAME::fTrdPhs
		RTS
		
@stage1phase1:
		LDY	#TRADE::player
		LDA	trade1, Y
		
		STA	$69
		
;		STA	game + GAME::pLast
;		STA	game + GAME::pActive
		
;			- phase 1 - fee/repay deed
		LDX	game + GAME::iTrdStp 
		LDA	trdrepay0, X
		AND	#$01
		BNE	@stage1ph1repay

		LDA	#UI_ACT_PFEE
		STA	$68

		LDX	game + GAME::iTrdStp 
		LDA	trddeeds0, X

		STA	$69
		
		JSR	uiEnqueueAction

;		JSR	gamePerfTradeFocus
;
;		LDA	trddeeds0, X
;		JSR	rulesMortgageFeeImmed
;		
;		JSR	gamePerfTradeDeselect

		JMP	@stage1nextdeed
		
@stage1ph1repay:
		LDA	#UI_ACT_REPY
		STA	$68

		LDX	game + GAME::iTrdStp 
		LDA	trddeeds0, X
		
		STA	$69
		
		JSR	uiEnqueueAction

;		JSR	gamePerfTradeFocus
;
;		LDA	trddeeds0, X
;		JSR	rulesUnmortgageImmed
;		
;		JSR	gamePerfTradeDeselect
		
;***
		
@stage1nextdeed:
;			- next deed
		INC 	game + GAME::iTrdStp 
		LDA	#$00
		STA	game + GAME::fTrdPhs
		RTS

@stage1next:
;		- stage $FF
		LDA	#$FF
		STA	game + GAME::fTrdStg
		
		LDA	#$00
		STA	game + GAME::iTrdStp
		STA	game + GAME::fTrdPhs

		RTS


;		check if doing stage 2 - auction 
@tststage2:

		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		CMP	game + GAME::iTrdStp
		BEQ	@stage2done	

		LDA	#UI_ACT_AUCN
		STA	$68

		LDY	game + GAME::iTrdStp
		LDA	trddeeds0, Y
;		STA	game + GAME::sAuctn
		STA	$6A

		INC	game + GAME::iTrdStp

		LDY	#TRADE::player
		LDA	trade0, Y
		
		STA	$69
		
		JSR	uiEnqueueAction
		
;		STA	game + GAME::pActive
;		LDA	#$FF
;		STA	game + GAME::pLast
;
;		JSR	rulesDoNextPlyr
;
;		LDX	#$01
;		JSR	gameStartAuction
;		

		
		RTS

@stage2done:
		LDA	#$FF
		STA	game + GAME::fTrdStg
		
		RTS



;-------------------------------------------------------------------------------
gamePerfTradeCCCCards:
;-------------------------------------------------------------------------------
		LDY	#TRADE::gofree
		LDA	trade0, Y
		AND	$01
		BEQ	@wchance

		LDY	#TRADE::player
		LDA	trade1, Y
		
		STA 	game + GAME::pGF0Crd

@wchance:
		LDY	#TRADE::gofree
		LDA	trade0, Y
		AND	$02
		BEQ	@ochest
		
		LDY	#TRADE::player
		LDA	trade1, Y
		
		STA 	game + GAME::pGF0Crd

@ochest:
		LDY	#TRADE::gofree
		LDA	trade1, Y
		AND	$01
		BEQ	@ochance

		LDY	#TRADE::player
		LDA	trade0, Y
		
		STA 	game + GAME::pGF1Crd

@ochance:
		LDY	#TRADE::gofree
		LDA	trade1, Y
		AND	$02
		BEQ	@exit
		
		LDY	#TRADE::player
		LDA	trade0, Y
		
		STA 	game + GAME::pGF1Crd

@exit:
		RTS


;-------------------------------------------------------------------------------
gamePerfTradeMoney:
;-------------------------------------------------------------------------------
		LDY	#TRADE::money
		LDA	trade0, Y
		STA	game + GAME::varD
		INY
		LDA	trade0, Y
		STA	game + GAME::varE

		LDY	#TRADE::player
		LDA	trade0, Y
		STA	game + GAME::pLast
		STA	game + GAME::pActive
		
		TAX
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	trade1, Y
		TAX
		
		JSR	rulesSubCash
		
		LDY	#TRADE::money
		LDA	trade1, Y
		STA	game + GAME::varD
		INY
		LDA	trade1, Y
		STA	game + GAME::varE

		LDY	#TRADE::player
		LDA	trade1, Y
		STA	game + GAME::pLast
		STA	game + GAME::pActive
		
		TAX
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	trade0, Y
		TAX
		
		JSR	rulesSubCash

		RTS


gamePerfTradePopMode:
		LDA	game + GAME::fTrdTyp
		BNE	@endelimin

;		Pop player and mode from trade 
		LDA	game + GAME::pTrdICP
		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast
		
		LDA	game + GAME::gMdTrdI
		STA	game + GAME::gMode

		RTS

@endelimin:
		LDA	game + GAME::pElimin
		
		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast
		
		LDA	game + GAME::gMdElim
		STA	game + GAME::gMode

		RTS


;-------------------------------------------------------------------------------
gamePerfTradeFull:
;-------------------------------------------------------------------------------
		LDA	#$00
		STA	game + GAME::fTrdStg
		STA	game + GAME::iTrdStp 
		STA	game + GAME::fTrdPhs

		LDA	game + GAME::fTrdTyp
		BNE	@loop

		JSR	gamePerfTradeMoney
		JSR	gamePerfTradeCCCCards
		
@loop:
		JSR	gamePerfTradeStep

		LDA	game + GAME::fTrdStg
@tstnext:
		CMP	#$FF
		BNE	@loop
	
		JSR	gamePerfTradePopMode
	
		LDA	ui + UI::cActns
		BEQ	@cleanup
	
		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction
	
		LDA	game + GAME::fTrdTyp
		STA	ui + UI::fActTyp
		
		JSR	uiProcessInit

		RTS
		
@cleanup:
		JSR	gameUpdateMenu

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		
		
;-------------------------------------------------------------------------------
gameToggleManage:
;-------------------------------------------------------------------------------
		LDA	game + GAME::sSelect
		STA	game + GAME::varA
		
		CMP	#$FF
		BEQ	@test

		JSR	gameDeselect

@test:
		LDA	game + GAME::fMngmnt
		BEQ	@cont
		
		DEC	game + GAME::fMngmnt

		JSR	menuPopPage

		LDA	game + GAME::sMngBak
		STA	game + GAME::sSelect
		
		CMP	#$FF
		BEQ	@plyract
		
		JSR	gameSelect
		
		LDX	#$00
		JSR	rulesCalcQForSquare
		
		CMP	game + GAME::qVis
		BEQ	@mngdone
		
		STA	game + GAME::qVis
		JSR	gamePlayersDirty
		
		JMP	@mngdone
	
@plyract:
		JSR	rulesFocusOnActive	;**todo check if board changed
		
		
@mngdone:
		LDA	#$01			
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		JMP	@exit

@cont:
		INC	game + GAME::fMngmnt

		LDA	game + GAME::varA
		STA	game + GAME::sMngBak

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square
		LDA	($FB), Y
		
		JSR	gameSelect

		LDA 	#<menuPageManage0
		LDY	#>menuPageManage0
		JSR	menuPushPage
		
		JSR	prmptClear2

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		LDA	#$24
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;-------------------------------------------------------------------------------
gameMoveSelect:
;-------------------------------------------------------------------------------
		PHA
		LDA	game + GAME::sSelect
		CMP	#$FF
		BNE	@cont
		PLA
		RTS
@cont:
		JSR	gameDeselect
		PLA
		JSR	gameSelect
		
		LDA	#$04
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;-------------------------------------------------------------------------------
gameSelect:
;-------------------------------------------------------------------------------
		PHA
	
		ASL
		TAX
		
		LDA	sqr00 + 1, X
		ORA	#$20
		STA	sqr00 + 1, X
		
		LDA	game + GAME::sSelect
		CMP	#$FF
		BEQ	@select
	
		JSR	gameDeselect

@select:
		PLA
		STA	game + GAME::sSelect
		
		RTS


;-------------------------------------------------------------------------------
gameDeselect:
;-------------------------------------------------------------------------------
		ASL
		TAX
		
		LDA	sqr00 + 1, X
		AND	#$DF
		STA	sqr00 + 1, X
		
		LDA	#$FF
		STA	game + GAME::sSelect
		
		RTS


;-------------------------------------------------------------------------------
gameAmountIsLess:		
;		D, E < .A, .Y (O, P) -> CLC | SEC 
;-------------------------------------------------------------------------------
		STA	game + GAME::varO
		STY	game + GAME::varP
		
gameAmountIsLessDirect:
                SEC
		LDA	game + GAME::varD
		SBC	game + GAME::varO
		LDA	game + GAME::varE
		SBC	game + GAME::varP
		BVS	@LBL1
		BPL	@GE
		
@LBL2:
		JMP	@LESS
@LBL1:
		BMI	@LBL2
@GE:
		SEC
		RTS
		
@LESS:
		CLC
		RTS
		

;-------------------------------------------------------------------------------
gamePlayerHasFunds:
;-------------------------------------------------------------------------------
		PHA
		TYA
		PHA
		
		LDY	game + GAME::pActive
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC
		
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		STA	game + GAME::varE
		
		PLA
		TAY
		PLA
		
;		D, E < .A, .Y -> CLC | SEC 
;		So, if money less than A, Y - clear carry else set
		JSR	gameAmountIsLess
		
		RTS
		

;-------------------------------------------------------------------------------
gamePlayerHasWealth:
;		ASSUMES INPUT VALUE IS POSITIVE 16BIT
;		ASSUMES -VE WEALTH IS FAIL (CLC)
;		ASSUMES 16BOVRFLW IS SUCCESS (SEC)
;-------------------------------------------------------------------------------
		STA	game + GAME::varM
		STY	game + GAME::varN
		
		LDY	game + GAME::pActive
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC
		
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		STA	game + GAME::varE
		LDA	#$00
		STA	game + GAME::varF

		LDY	#PLAYER::equity
		CLC
		LDA	($FB), Y
		ADC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		ADC	game + GAME::varE
		STA	game + GAME::varE
		LDA	#$00
		ADC	game + GAME::varF
		STA	game + GAME::varF
		
		BMI	@fail

;***FIXME:	Is there a better way to test for 16 bit overflow?

		BNE	@success
		LDA	game + GAME::varE	;
		AND	#$80			;Is the 16th bit used?
		BNE	@success

		JMP	@test
@fail:
		CLC
		RTS
		
@success:
		SEC
		RTS

@test:
		LDA	game + GAME::varM
		LDY	game + GAME::varN
		
;		D, E < .A, .Y -> CLC | SEC
;		So, if wealth less than A, Y - set carry else clear
		JSR	gameAmountIsLess

		RTS
		

	.if	DEBUG_KEYS
;-------------------------------------------------------------------------------
gameDecMoney1:
;------------------------------------------------------------------------------- 
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		
		SEC
		LDA	($FB), Y
		SBC	#1
		STA	($FB), Y
		INY
		LDA	($FB), Y
		SBC	#0
		STA	($FB), Y
		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;-------------------------------------------------------------------------------
gameIncMoney1:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		
		CLC
		LDA	($FB), Y
		ADC	#1
		STA	($FB), Y
		INY
		LDA	($FB), Y
		ADC	#0
		STA	($FB), Y
		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS
		
;-------------------------------------------------------------------------------
gameDecMoney10:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		
		SEC
		LDA	($FB), Y
		SBC	#10
		STA	($FB), Y
		INY
		LDA	($FB), Y
		SBC	#0
		STA	($FB), Y
		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS

;-------------------------------------------------------------------------------
gameIncMoney10:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		
		CLC
		LDA	($FB), Y
		ADC	#10
		STA	($FB), Y
		INY
		LDA	($FB), Y
		ADC	#0
		STA	($FB), Y
		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS

;-------------------------------------------------------------------------------
gameDecMoney100:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	#<100
		STA	game + GAME::varD
		LDA	#>100
		STA	game + GAME::varE
		
		LDX	game + GAME::pActive
		JSR	rulesSubCash
		
;		JSR	gameUpdateMenu
		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		

;-------------------------------------------------------------------------------
gameIncMoney100:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	#100
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		JSR	rulesAddCash

		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS
	.endif
		
		
;-------------------------------------------------------------------------------
gameToggleDialog:
;-------------------------------------------------------------------------------
		LDA 	#<dialogDlgOvervw0
		LDY	#>dialogDlgOvervw0
		
		JSR	dialogSetDialog

		LDA	#<$DB3B
		STA	game + GAME::aWai
		LDA	#>$DB3B
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai
		EOR	game + GAME::dlgVis
		STA	game + GAME::dlgVis
		LDA	#$01
		EOR	game + GAME::dlgVis
		STA	game + GAME::pVis
		
		JSR	gamePlayersDirty
		
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS
		
		
;-------------------------------------------------------------------------------
gameRollDice:
;-------------------------------------------------------------------------------
		LDA	game + GAME::dieRld
		CMP	#$01
		BNE	@test0
		
		JMP	@exit

@test0:
		LDX	game + GAME::pActive
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::money + 1
		LDA	($FB), Y
		BPL	@test1
		
		JMP	@exit
		
@test1:
		LDA	game + GAME::cntHs
		BPL	@test2
		
		JMP	@exit
		
@test2:
		LDA	game + GAME::cntHt
		BPL	@begin
		
		JMP	@exit

@begin:
		JSR 	numConvDieRoll
		STA	game + GAME::dieA
		
		JSR 	numConvDieRoll
		STA	game + GAME::dieB
		
		LDA	#$01
		STA	game + GAME::dieRld

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptRolled

		LDA 	sidV2EnvOu
		LSR
		LSR
		LSR
		LSR
		LSR
		LSR			
		PHA
	

		LDA	#$00
		STA	game + GAME::dieDbl
		
		LDA	game + GAME::dieA
		CMP	game + GAME::dieB
		BNE	@nodbl
		
		LDA	#$01
		STA	game + GAME::dieDbl

		LDA	#$00
		STA	game + GAME::dieRld
		
		LDX	game + GAME::nDbls
		INX
		STX	game + GAME::nDbls
		
		PLA
		LDA	#$05
		PHA
		
@nodbl:		
		PLA
		CLC
		ADC	#musTuneDice0
		JSR	SNDBASE + 0	

		LDY	#PLAYER::status		;they don't move if in gaol
		LDA	($FB), Y
		AND	#$80
		BEQ	@cont
		
		LDA	#$01			;unless they got a double
		CMP	game + GAME::dieDbl
		BNE	@test

		LDX	#$00
		JSR	gameToggleGaol

		LDA	#$01			;prevent further movement 
		STA	game + GAME::dieRld
		LDA	#$00		
		STA	game + GAME::dieDbl
		
		JMP	@cont
		
@test:
		LDY	#PLAYER::nGRls
		LDA	($FB), Y
		TAX
		INX
		TXA
		STA	($FB), Y
		CMP	#$03
		BNE	@exit

		LDY	#PLAYER::status		;must post bail
		LDA	($FB), Y
		ORA	#$20
		STA	($FB), Y

		JMP	@exit
		
@cont:
		LDA	game + GAME::nDbls
		CMP	#$03
		BNE	@move
		
		LDX	#$01			;3 doubles, go to gaol
		STX	menuGaol0Dbls
		JSR	gameToggleGaol
		
		LDA	#$01			;prevent further movement 
		STA	game + GAME::dieRld
		LDA	#$00		
		STA	game + GAME::dieDbl
		
		JSR	rulesFocusOnActive		
		
		JMP	@exit
		
		
@move:
		LDY	#PLAYER::square
		LDA	($FB), Y

		PHA
		
		LDA	game + GAME::dieA
		CLC
		ADC	game + GAME::dieB
		
		TAX
		PLA
		JSR	rulesCalcNextSqr

		LDY	#$00			;Not something special on land
		PHA

		LDA	game + GAME::fDoJump
		BNE	@doJump
		
		PLA
		JSR	rulesInitStepping
		RTS
		
@doJump:
		PLA
		JSR	rulesMoveToSquare
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		JSR	gameUpdateMenu
		
		RTS

		
;-------------------------------------------------------------------------------
gamePlayersDirty:
;-------------------------------------------------------------------------------
		LDX	#$00
		LDY	#PLAYER::dirty
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	#$01
		STA	($FB), Y
		
		INX
		CPX	#$06
		BNE	@loop
		
		RTS


;-------------------------------------------------------------------------------
gameStartAuction:
;-------------------------------------------------------------------------------
		TXA
		PHA

		LDA	game + GAME::sAuctn
		JSR	gameSelect

		LDA	#$0A			;starting auction amount $10
		STA	game + GAME::mAuctn	
		STA	game + GAME::mACurr
		LDA	#$00			
		STA	game + GAME::mAuctn + 1
		STA	game + GAME::mACurr + 1
		
		LDX	#$00			;compute flags for inactive players
		LDA	#$3F			;first, all inactive
		STA	game + GAME::varA
		
		LDY	#PLAYER::status		;Set active where player is active
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	($FB), Y		;are they active?
		AND 	#$01
		BEQ	@next			;no, go to next
		
		LDA	plrFlags, X		;yes, toggle the flag (unset)
		EOR	game + GAME::varA
		STA	game + GAME::varA
		
@next:
		INX				;test next
		CPX	#$06
		BNE	@loop
		
		LDA	game + GAME::varA	;Fetch back calculated flags
				
		STA	game + GAME::fAPass	;All active players in auction
		STA	game + GAME::fAForf

		LDA	game + GAME::gMode	;Back up current mode
		STA	game + GAME::gMdActn
		LDA	#$01			;Go to auction mode
		STA	game + GAME::gMode
		
		LDA	#$FF			;No winner
		STA	game + GAME::pWAuctn
		
		LDA	game + GAME::pActive	;Back up current player
		STA	game + GAME::pRecall
		
		PLA				;Have we already got the player
		BNE	@nonext			;who goes first?
		
		JSR 	rulesNextTurn		;No, so go to next
		
		LDA	game + GAME::pActive
		STA	game + GAME::pAFirst
		
		RTS
		
@nonext:
		LDA	game + GAME::sAuctn	;Yes - make the auctioned 
		LDX	#$00			;square visible, too
		JSR	rulesCalcQForSquare
		
		CMP	game + GAME::qVis
		BEQ	@exit
		
		STA	game + GAME::qVis

		JSR	gamePlayersDirty
		
@exit:
		JSR	gameUpdateMenu

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS
		
		
;-------------------------------------------------------------------------------
gameCheckChestShuffle:
;-------------------------------------------------------------------------------
		LDX	rulesChestIdx		;Get index of next card
		
;		LDA	#$FF			;Is the GOFree card out of the 
;		CMP	game + GAME::pGF0Crd	;deck?
;		BEQ	@fintst			;No - test if at end

		LDA	game + GAME::fGF0Out
		BEQ	@fintst
		
		CPX	#$0F			;Check if next to last last card 
		BNE	@fintst			;Not so test if at end
		
		LDA	rulesChestCrds0, X	;Yes, need to check if its
		CMP	#$0F			;GO Free
		BNE	@fintst			;Its not so just check at end
		
		JMP	@isdirty		;It is GO Free so need shuffle
						;(the card is out of the deck)
		
@fintst:
		CPX	#$10			;Are we at the end?
		BNE	@exit			;No, done
		
@isdirty:
		LDA	game + GAME::dirty	;Need shuffle
		ORA	#$80
		STA	game + GAME::dirty
		
@exit:
		RTS


;-------------------------------------------------------------------------------
gameCheckChanceShuffle:
;-------------------------------------------------------------------------------
		LDX	rulesChanceIdx
		
;		LDA	#$FF
;		CMP	game + GAME::pGF1Crd
;		BEQ	@fintst
		
		LDA	game + GAME::fGF1Out
		BEQ	@fintst
		
		CPX	#$0F
		BNE	@fintst
		
		LDA	rulesChanceCrds0, X
		CMP	#$06
		BNE	@fintst
		
		JMP	@isdirty
		
@fintst:
		CPX	#$10
		BNE	@exit
		
@isdirty:
		LDA	game + GAME::dirty
		ORA	#$40
		STA	game + GAME::dirty
		
@exit:
		RTS

		
;==============================================================================
;FOR DIALOG.S
;==============================================================================
	
dialogDefWindow0:		
			.byte	$13, $08, $05, $18, $0C
			.byte	$46, $07, $04, $19
			.byte	$47, $08, $11, $18
			.byte	$56, $07, $05, $0D
			.byte	$57, $20, $05, $0D
			.byte	$6A, $20, $04, $07, $11, $FF

			.byte	$2B, $07, $04, $19
			.byte	$2B, $08, $11, $18

			.byte	$3B, $07, $05, $0D
			.byte	$3B, $20, $05, $0D

			.byte	$21, $08, $06, $18
			.byte	$23, $08, $07, $18

			.byte 	$AF, $0F, $08, $20, $20, $0D, $0F
			.word		strDesc7Titles0
			
			.byte	$00

dialogKeyHandler:
			.word	dialogDefKeys
dialogDrawHandler:
			.word	dialogDefDraw
dialogDrawDefDraw:
			.byte	$00
			
			
dialogDlgTitles0:
		.word	dialogDlgTitles0Keys
		.word	dialogDlgTitles0Draw
		.byte	$00
		
dialogDlgCCCCard0:
		.word	dialogDlgCCCCard0Keys
		.word	dialogDlgCCCCard0Draw
		.byte	$01

dialogDlgOvervw0:
		.word	dialogDefKeys
		.word	dialogDlgOvervw0Draw
		.byte	$00
		
dialogDlgTrdSel0:
		.word	dialogDlgTrdSel0Keys
		.word	dialogDlgTrdSel0Draw
		.byte	$00
		
dialogDlgElimin0:
		.word	dialogDlgElimin0Keys
		.word	dialogDlgElimin0Draw
		.byte	$01
	
dialogDlgElimin1:
		.word	dialogDefKeys
		.word	dialogDlgElimin1Draw
		.byte	$01
		
dialogDlgGameOver0:
		.word	dialogDlgGameOver0Keys
		.word	dialogDlgGameOver0Draw
		.byte	$01
		
dialogDlgWaitFor0:
		.word	dialogDlgWaitFor0Keys
		.word	dialogDlgWaitFor0Draw
		.byte	$01

dialogDlgSqrInfo0:
		.word	dialogDefKeys
		.word	dialogDlgSqrInfo0Draw
		.byte	$00
		
dialogDlgPStats0:
		.word	dialogDefKeys
		.word	dialogDlgPStats0Draw
		.byte	$00

dialogDlgStart0:
		.word	dialogDlgStart0Keys
		.word	dialogDlgStart0Draw
		.byte	$01

dialogDlgTrade2:
		.word	dialogDefKeys
		.word	dialogDlgTrade2Draw
		.byte	$01

dialogDlgTrade3:
		.word	dialogDefKeys
		.word	dialogDlgTrade3Draw
		.byte	$01
		
dialogDlgTrade4:
		.word	dialogDefKeys
		.word	dialogDlgTrade4Draw
		.byte	$01

dialogDlgTrade5:
		.word	dialogDefKeys
		.word	dialogDlgTrade5Draw
		.byte	$01

dialogDlgTrade7:
		.word	dialogDefKeys
		.word	dialogDlgTrade7Draw
		.byte	$01
		
dialogDlgNull0:
		.word	dialogDefKeys
		.word	dialogDlgNull0Draw
		.byte	$01

			
;-------------------------------------------------------------------------------
dialogSetDialog:
;-------------------------------------------------------------------------------
		STA	$FB
		STY	$FC
		
		LDY	#DIALOG::fKeys
		LDA	($FB), Y
		STA	dialogKeyHandler
		INY
		LDA	($FB), Y
		STA	dialogKeyHandler + 1

		LDY	#DIALOG::fDraw
		LDA	($FB), Y
		STA	dialogDrawHandler
		INY
		LDA	($FB), Y
		STA	dialogDrawHandler + 1

		LDY	#DIALOG::bDef
		LDA	($FB), Y
		STA	dialogDrawDefDraw

		RTS


;-------------------------------------------------------------------------------
dialogDispDefDialog:
;-------------------------------------------------------------------------------
		LDA	#<$DA73
		STA	game + GAME::aWai
		LDA	#>$DA73
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai
		STA	game + GAME::dlgVis
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		LDA	#$00
		STA	game + GAME::pVis
		JSR	gamePlayersDirty
		
		RTS


;-------------------------------------------------------------------------------
dialogDefDraw:
;-------------------------------------------------------------------------------
		JSR	screenBeginButtons	;???Better here???

		LDA	#<dialogDefWindow0
		STA	$FD
		LDA	#>dialogDefWindow0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS

;-------------------------------------------------------------------------------
dialogDisplay:
;-------------------------------------------------------------------------------
		LDA	#$00			;Do this in the updates and 
		STA	menuLastDrawFunc	;or restore last menu's selection
		STA	menuLastDrawFunc + 1
		
		LDA	#$01
		CMP	dialogDrawDefDraw
		BNE	@cont

		JSR	dialogDefDraw
@cont:
		
		JMP	(dialogDrawHandler)

;-------------------------------------------------------------------------------
dialogDefKeys:
;-------------------------------------------------------------------------------
		LDA	#<SFXDONG
		LDY	#>SFXDONG
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$00
		STA	game + GAME::kWai
		
		LDA	#$01
		EOR	game + GAME::dlgVis
		STA	game + GAME::dlgVis
		LDA	#$01
		EOR	game + GAME::pVis
		STA	game + GAME::pVis
		
		JSR	gamePlayersDirty
		
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


dialogWindowTitles0:
			.byte	$13, $0B, $01, $12, $17
			
			.byte	$46, $0A, $00, $13
			.byte	$47, $0B, $18, $12
			.byte	$56, $0A, $01, $17
			.byte	$57, $1D, $01, $18
			
			.byte	$2B, $0A, $00, $13
			.byte	$2B, $0B, $18, $12
			.byte	$3B, $0A, $01, $17
			.byte	$3B, $1D, $01, $18
			
			.byte	$6A, $1D, $00, $0A, $18, $FF

			.byte	$90, $0C, $02
			.word        	strHeaderTitles0
			.byte	$90, $12, $05
			.word		strDesc0Titles0
			.byte	$90, $0D, $07
			.word		strDesc1Titles0
			.byte	$90, $12, $09
			.word		strDesc2Titles0
			.byte	$90, $0C, $0B
			.word		strDesc3Titles0
			.byte	$90, $13, $0C
			.word		strDesc4Titles0
			.byte	$90, $0C, $0F
			.word		strDesc8Titles0
			.byte	$90, $0D, $12
			.word		strDesc5Titles0
			.byte	$90, $11, $13
			.word		strDesc6Titles0
			
			.byte	$AF, $16, $0B, $1D, $20, $0D, $16
			.word		strDesc7Titles0
			
			.byte	$21, $0B, $02, $12
			.byte	$23, $0B, $03, $12
			
;			.byte	$21, $0B, $16, $12
			
			.byte	$00

		
;-------------------------------------------------------------------------------
dialogDlgTitles0Keys:
;-------------------------------------------------------------------------------
		LDA	ui + UI::fHveInp
		BNE	@notfirst

		LDA	#$01
		STA	ui + UI::fHveInp
		
		LDA 	#<menuPageSetup7
		LDY	#>menuPageSetup7
		
		JMP	@cont

@notfirst:
		LDA 	#<menuPageSetup0
		LDY	#>menuPageSetup0
		
@cont:
		JSR	menuSetPage

		LDA	#$00
		STA	game + GAME::kWai
		
		LDA	#<$DBA9
		STA	game + GAME::aWai
		LDA	#>$DBA9
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai

		LDA	#$00
		STA	game + GAME::dlgVis
		
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		LDA	#musTuneSilence
		JSR	SNDBASE + 0		

		RTS

dialogDlgTitles0Draw:
		JSR	screenBeginButtons

		LDA	#$00
		STA	ui + UI::iSelBtn
		
		LDA	#<dialogWindowTitles0
		STA	$FD
		LDA	#>dialogWindowTitles0
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS
		
	
dialogCCCCardTemp0:					;Card values
			.byte	$00, $00
dialogCCCCardTemp2:					;Routine to use for keys
			.byte	$00, $00
dialogCCCCardTemp4:					;Cash value 1
			.byte	$04, $A0, $A0, $A0, $A0
dialogCCCCardTemp9:					;Chance or Chest
			.byte 	$00
dialogCCCCardTempA:					;Cash value 0
			.byte	$04, $A0, $A0, $A0, $A0
dialogCCCCardTempF:					;Pointer to str data
			.word	$0000

dialogWindowCCCCard0:		
			.byte	$90, $09, $06
dialogWindowCCCCardT:
			.word		strHeaderCCCCard0		
			.byte	$90, $09, $09
dialogWindowCCCCardS0:
			.word		strDummyDummy0
			.byte	$90, $09, $0A
dialogWindowCCCCardS1:
			.word		strDummyDummy0
			.byte	$90, $09, $0B
dialogWindowCCCCardS2:
			.word		strDummyDummy0

			.byte	$90, $13, $0C
dialogWindowCCCCardC1:
			.word		strDummyDummy0

			.byte	$90, $1B, $0C
			.word		dialogCCCCardTemp4
			
			.byte	$90, $13, $0D
dialogWindowCCCCardC0:
			.word		strDummyDummy0

			.byte	$90, $1B, $0D
			.word		dialogCCCCardTempA

			.byte	$00
		
	
;-------------------------------------------------------------------------------
dialogDlgCCCCard0Keys:
;-------------------------------------------------------------------------------
		LDA	#<SFXDONG
		LDY	#>SFXDONG
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$01
		EOR	game + GAME::dlgVis
		STA	game + GAME::dlgVis
		LDA	#$01
		EOR	game + GAME::pVis
		STA	game + GAME::pVis
		JSR	gamePlayersDirty
		
		LDA	#$00
		STA	game + GAME::kWai
		
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		LDA	#$01
		CMP	dialogCCCCardTemp9
		BEQ	@chnce
	
		JSR	gameCheckChestShuffle
		JMP	@cont
	
@chnce:	
		JSR	gameCheckChanceShuffle

@cont:
		JMP	(dialogCCCCardTemp2)


;-------------------------------------------------------------------------------
dialogDlgCCCCard0Draw:
;-------------------------------------------------------------------------------
		LDA	dialogCCCCardTemp9
		BNE	@chnce
		
		LDA	#<strHeaderCCCCard0
		STA	dialogWindowCCCCardT
		LDA	#>strHeaderCCCCard0
		STA	dialogWindowCCCCardT + 1
		
		JMP	@cont
		
@chnce:
		LDA	#<strHeaderCCCCard1
		STA	dialogWindowCCCCardT
		LDA	#>strHeaderCCCCard1
		STA	dialogWindowCCCCardT + 1

@cont:
		LDA	dialogCCCCardTempF
		STA	$FD
		LDA	dialogCCCCardTempF + 1
		STA	$FE
		
		LDY	#$00
		LDA	($FD), Y
		STA	dialogWindowCCCCardS0
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardS0 + 1
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardS1
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardS1 + 1
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardS2
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardS2 + 1
		INY
		
		LDA	($FD), Y
		BNE	@conv1
		
		LDA	#$A0
		STA	dialogCCCCardTemp4 + 1
		STA	dialogCCCCardTemp4 + 2
		STA	dialogCCCCardTemp4 + 3
		STA	dialogCCCCardTemp4 + 4
		
		JMP	@cont1
	
@conv1:
		TYA
		PHA
		
		LDA	dialogCCCCardTemp0
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		PLA
		TAY
		
		LDX	#$00
@loop1:
		LDA	heap0 + 3, X
		ORA	#$80
		STA	dialogCCCCardTemp4 + 2, X
		INX
		CPX	#$03
		BNE	@loop1
		
		LDA	#$A4
		STA	dialogCCCCardTemp4 + 1
		
@cont1:
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardC1
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardC1 + 1
		INY 
		
		LDA	($FD), Y
		BNE	@conv0
		
		LDA	#$A0
		STA	dialogCCCCardTempA + 1
		STA	dialogCCCCardTempA + 2
		STA	dialogCCCCardTempA + 3
		STA	dialogCCCCardTempA + 4
		
		JMP	@cont0
	
@conv0:
		TYA
		PHA
		
		LDA	dialogCCCCardTemp0 + 1
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		PLA
		TAY
		
		LDX	#$00
@loop0:
		LDA	heap0 + 3, X
		ORA	#$80
		STA	dialogCCCCardTempA + 2, X
		INX
		CPX	#$03
		BNE	@loop0
		
		LDA	#$A4
		STA	dialogCCCCardTempA + 1
		
@cont0:
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardC0
		INY
		LDA	($FD), Y
		STA	dialogWindowCCCCardC0 + 1
;		INY 
		
		LDA	#<dialogWindowCCCCard0
		STA	$FD
		LDA	#>dialogWindowCCCCard0
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS


dialogWaitFor0Keys:
			.word	$0000
dialogWaitFor0Draw:
			.word	$0000
dialogWaitFor0DrawDef:
			.byte	$00
dialogWaitFor0KeyWaiA:	
			.word	$0000
dialogWaitFor0KeyWai:
			.byte	$00


dialogWindowWaitFor0:
			.byte	$90, $09, $06
			.word		strHeaderWaitFor0
			.byte	$90, $09, $09
			.word		strText0WaitFor0
			.byte	$90, $09, $0A
			.word		strText1WaitFor0

			.byte	$00


;-------------------------------------------------------------------------------
doDialogDlgWaitFor0Backup:
;-------------------------------------------------------------------------------
		LDA	dialogKeyHandler
		STA	dialogWaitFor0Keys
		LDA	dialogKeyHandler + 1
		STA	dialogWaitFor0Keys + 1

		LDA	dialogDrawHandler
		STA	dialogWaitFor0Draw
		LDA	dialogDrawHandler + 1
		STA	dialogWaitFor0Draw + 1
		
		LDA	dialogDrawDefDraw
		STA	dialogWaitFor0DrawDef

		LDA	game + GAME::aWai
		STA	dialogWaitFor0KeyWaiA
		LDA	game + GAME::aWai + 1
		STA	dialogWaitFor0KeyWaiA + 1

		LDA	game + GAME::kWai
		STA	dialogWaitFor0KeyWai
		
		RTS


;-------------------------------------------------------------------------------
doDialogDlgWaitFor0Restore:
;-------------------------------------------------------------------------------
		LDA	dialogWaitFor0Keys
		STA	dialogKeyHandler
		LDA	dialogWaitFor0Keys + 1
		STA	dialogKeyHandler + 1

		LDA	dialogWaitFor0Draw
		STA	dialogDrawHandler
		LDA	dialogWaitFor0Draw + 1
		STA	dialogDrawHandler + 1
		
		LDA	dialogWaitFor0DrawDef
		STA	dialogDrawDefDraw

		LDA	dialogWaitFor0KeyWaiA
		STA	game + GAME::aWai
		LDA	dialogWaitFor0KeyWaiA + 1
		STA	game + GAME::aWai + 1

		LDA	dialogWaitFor0KeyWai
		STA	game + GAME::kWai
		
		RTS


dialogDlgWaitFor0Keys:
		LDA	#<SFXDONG
		LDY	#>SFXDONG
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	dialogWaitFor0Keys + 1
		BEQ	@cleardlg
		
		JSR	doDialogDlgWaitFor0Restore
		JMP	@dirty
		
@cleardlg:
		LDA	#$01
		EOR	game + GAME::dlgVis
		STA	game + GAME::dlgVis
		LDA	#$01
		EOR	game + GAME::pVis
		STA	game + GAME::pVis
		JSR	gamePlayersDirty
		
		LDA	#$00
		STA	game + GAME::kWai
	
@dirty:	
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


dialogDlgWaitFor0Draw:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::name + $08
		
		LDX	#$07
@loop:
		LDA	($FB), Y
		ORA	#$80
		STA	strText0WaitFor0 + 1, X
		DEY
		DEX
		BPL	@loop

		LDA	#<dialogWindowWaitFor0
		STA	$FD
		LDA	#>dialogWindowWaitFor0
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS


dialogWindowStart0:
			.byte	$90, $09, $06
			.word		strHeaderStart0
			
			.byte	$90, $09, $09
			.word		strText0Start0

			.byte	$00


dialogDlgStart0Keys:
		JSR	dialogDefKeys

		LDA	#<$DBA9
		STA	game + GAME::aWai
		LDA	#>$DBA9
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai
		
		RTS
		

dialogDlgStart0Draw:
		LDX	game + GAME::pFirst
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::name + $08
		
		LDX	#$07
@loop:
		LDA	($FB), Y
		ORA	#$80
		STA	strText0Start0 + 1, X
		DEY
		DEX
		BPL	@loop

		LDA	#<dialogWindowStart0
		STA	$FD
		LDA	#>dialogWindowStart0
		STA	$FE
		
		JSR	screenPerformList

		JSR	screenResetSelBtn
		RTS


dialogWindowTrade2:
			.byte	$90, $09, $06
			.word		strHeaderTrade2
			.byte	$90, $09, $07
			.word		strDescTrade2
			
			.byte	$90, $09, $09
			.word		strText0Trade2
			.byte	$90, $09, $0A
			.word		strText1Trade2

			.byte	$00


dialogDlgTrade2Draw:
		LDA	#<dialogWindowTrade2
		STA	$FD
		LDA	#>dialogWindowTrade2
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


dialogWindowTrade3:
			.byte	$90, $09, $06
			.word		strHeaderTrade2
			.byte	$90, $09, $07
			.word		strDescTrade2
			
			.byte	$90, $09, $09
			.word		strText0Trade3
			.byte	$90, $09, $0A
			.word		strText1Trade3

			.byte	$00


dialogDlgTrade3Draw:
		LDA	#<dialogWindowTrade3
		STA	$FD
		LDA	#>dialogWindowTrade3
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


dialogWindowTrade4:
			.byte	$90, $09, $06
			.word		strHeaderTrade2
			.byte	$90, $09, $07
			.word		strDescTrade4
			
			.byte	$90, $09, $09
			.word		strText0Trade2
			.byte	$90, $09, $0A
			.word		strText1Trade2

			.byte	$00


dialogDlgTrade4Draw:
		LDA	#<dialogWindowTrade4
		STA	$FD
		LDA	#>dialogWindowTrade4
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


dialogWindowTrade5:
			.byte	$90, $09, $06
			.word		strHeaderTrade5
			.byte	$90, $09, $07
			.word		strDescTrade5
			
			.byte	$90, $09, $09
			.word		strText0Trade5
			.byte	$90, $09, $0A
			.word		strText1Trade5
			.byte	$90, $09, $0B
			.word		strText2Trade5

			.byte	$00


dialogDlgTrade5Draw:
		LDA	#<dialogWindowTrade5
		STA	$FD
		LDA	#>dialogWindowTrade5
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


dialogTempTrade7P:
		.byte	$00

dialogWindowTrade7:
			.byte	$90, $09, $06
			.word		strHeaderTrade7
			
			.byte	$90, $09, $09
			.word		strText0Trade7
			.byte	$90, $09, $0A
dialogWindowTrade7N:
			.word		strDummyDummy0
			
			.byte	$00


dialogDlgTrade7Draw:
		LDX	game + GAME::pActive
		LDA	plrNameLo, X
		STA	dialogWindowTrade7N
		LDA	plrNameHi, X
		STA	dialogWindowTrade7N + 1

		LDA	#<dialogWindowTrade7
		STA	$FD
		LDA	#>dialogWindowTrade7
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS
		
	
dialogTempElimin0P:
		.byte	$00

dialogWindowElimin0:		
			.byte	$90, $09, $06
			.word		strHeaderElimin0
			.byte	$90, $09, $09
			.word		strText0Elimin0
			
			.byte	$00
			
dialogDlgElimin0Keys:
		LDA	#<SFXDONG
		LDY	#>SFXDONG
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$01
		EOR	game + GAME::dlgVis
		STA	game + GAME::dlgVis
		LDA	#$01
		EOR	game + GAME::pVis
		STA	game + GAME::pVis
		JSR	gamePlayersDirty
		
		LDA	#$00
		STA	game + GAME::kWai
		
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		JSR	rulesNextTurn

		RTS
		
dialogDlgElimin0Draw:
;***TODO:	Make this message more informative - did they lose
;		to another player (which) or to the bank.

		LDX	dialogTempElimin0P
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::name + $08
		
		LDX	#$07
@loop:
		LDA	($FB), Y
		ORA	#$80
		STA	strText0Elimin0 + 1, X
		DEY
		DEX
		BPL	@loop

		LDA	#<dialogWindowElimin0
		STA	$FD
		LDA	#>dialogWindowElimin0
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS


dialogWindowElimin1:
			.byte	$90, $09, $06
			.word		strHeaderElimin1
			.byte	$90, $09, $07
			.word		strDescElimin1
			
			.byte	$90, $09, $09
			.word		strText0Elimin1
			.byte	$90, $09, $0A
			.word		strText1Elimin1

			.byte	$00


dialogDlgElimin1Draw:
		LDA	#<dialogWindowElimin1
		STA	$FD
		LDA	#>dialogWindowElimin1
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


dialogWindowGameOver0:		
			.byte	$90, $09, $06
			.word		strHeaderGameOver0
			.byte	$90, $09, $09
			.word		strText0GameOver0
			
			.byte	$00
			
dialogDlgGameOver0Keys:
		JSR	initBoard

		JSR	initSprites		
		
		JSR	initPlayers		

		JSR	initNew

		JSR	initScreen

		JSR	initMenu
			
		JSR	initDialog

		LDA	#musTuneIntro
		JSR	SNDBASE + 0
		
		RTS
		
dialogDlgGameOver0Draw:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::name + $08
		
		LDX	#$07
@loop:
		LDA	($FB), Y
		ORA	#$80
		STA	strText0GameOver0 + 1, X
		DEY
		DEX
		BPL	@loop

		LDA	#<dialogWindowGameOver0
		STA	$FD
		LDA	#>dialogWindowGameOver0
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS


dialogOvervwFiltOwn:
		.byte	$00
dialogOvervwPlr0:
		.byte	$00
dialogOvervwPlr1:
		.byte	$00


dialogWindowOvervw0:
			.byte	$48, $0B, $04, $11	;chr empty space
			.byte	$58, $1B, $05, $10	
			.byte	$6A, $0B, $14, $FF

;>>1

;			.byte	$46, $0A, $03, $12	;chr frame (std)
;			.byte	$56, $0A, $04, $11
;			.byte	$47, $0B, $15, $12
;			.byte	$57, $1C, $04, $11
;			.byte	$6A, $1C, $03
;			.byte		$0A, $15, $FF
			
			.byte	$44, $0A, $03, $12	;chr frame (heavy)
			.byte	$54, $0A, $04, $12
			.byte	$44, $0B, $15, $12
			.byte	$54, $1C, $03, $12
			
			.byte 	$64, $1B, $14, $FF	;chr busy indicator
			
;>>2

			.byte	$2B, $0A, $03, $12	;clr frame
			.byte	$3B, $1C, $03, $12
			.byte	$2B, $0B, $15, $12
			.byte	$3B, $0A, $04, $12
			
			.byte	$AF, $14, $1B, $1C, $20, $00, $00
			.word		strDummyDummy0
			
			.byte 	$00
	

dialogWindowOvervw1:
;//1
			.byte	$10, $0C, $05, $0E, $0E	;chr+clr board blank
			.byte 	$64, $0C, $13, $FF	
			
			.byte	$45, $0C, $05, $0F	;chr own surround
			.byte	$55, $1A, $06, $0E
			.byte	$43, $0D, $13, $0D
			.byte	$5B, $0C, $06, $0D
			.byte	$59, $0B, $05, $0F
			.byte	$4A, $0C, $14, $0F

			.byte	$6B, $0D, $06  		;chr board 
			.byte		$18, $06, $FF
			.byte	$61, $19, $06
			.byte		$17, $08, $FF
			.byte	$6C, $19, $07
			.byte		$19, $12, $FF
			
			.byte	$4C, $0E, $06, $0A
			.byte	$4B, $0E, $07, $0A
			.byte	$43, $0F, $08, $08
			
			.byte	$53, $0D, $08, $0A
			.byte	$53, $18, $08, $0A
			.byte	$5C, $0E, $08, $0A
			.byte	$5C, $19, $08, $0A
			.byte	$5B, $17, $09, $08
			
			.byte	$4C, $0E, $11, $0A
			.byte	$4B, $0E, $12, $0A

;//2
			.byte	$2F, $0D, $06, $02	;clr corners
			.byte	$2F, $0D, $07, $02
			.byte	$2F, $18, $06, $02
			.byte	$2F, $18, $07, $02
			.byte	$2F, $0D, $11, $02
			.byte	$2F, $0D, $12, $02
			.byte	$2F, $18, $11, $02
			.byte	$2F, $18, $12, $02
			
			.byte	$2F, $18, $0F, $02	;clr tax
			.byte	$3F, $14, $11, $02

			.byte	$31, $13, $11, $02	;clr stations
			.byte	$21, $0D, $0C, $02
			.byte	$31, $13, $06, $02
			.byte	$21, $18, $0C, $02
			
			.byte	$8F, $0D, $0F		;clr utilities
			.byte	$8F, $16, $06
			.byte	$81, $0E, $0F
			.byte	$81, $16, $07

			.byte	$89, $17, $11		;clr brown
			.byte	$89, $15, $11

			.byte	$8E, $12, $11		;clr light blue
			.byte	$2E, $0F, $11, $02

			.byte	$84, $0E, $10		;clr purple
			.byte	$34, $0E, $0D, $02
			
			.byte	$88, $0E, $0B		;clr orange
			.byte	$38, $0E, $08, $02

			.byte	$82, $0F, $07		;clr red
			.byte	$22, $11, $07, $02
			
			.byte	$87, $17, $07		;clr yellow
			.byte	$27, $14, $07, $02
			
			.byte	$85, $18, $0B		;clr green
			.byte	$35, $18, $08, $02
			
			.byte	$86, $18, $0E		;clr blue
			.byte	$86, $18, $10

			.byte	$2B, $0C, $05, $0F	;clr own surround
			.byte	$3B, $1A, $06, $0E
			.byte	$2B, $0C, $13, $0E
			.byte	$3B, $0C, $06, $0D
			.byte	$3B, $0B, $05, $0F
			.byte	$2B, $0C, $14, $0F

			.byte 	$00
		
		
doDialogOvervwColOwnFilt:
;		Set carry if want player

		LDA	dialogOvervwFiltOwn	;Filtering at all?
		BEQ	@wanted
		
		LDA	dialogOvervwPlr0	;Have got player in 0?
		CMP	#$FF
		BEQ	@tst1			;No, test 1
		
		CPY	dialogOvervwPlr0	;Yes, matches?
		BEQ	@wanted			;Yes, wanted.
@tst1:
		LDA	dialogOvervwPlr1	;Have got player in 0?
		CMP	#$FF
		BEQ	@not			;No, and haven't wanted?  Not!
		
		CPY	dialogOvervwPlr1	;Yes, matches?
		BEQ	@wanted			;Yes, wanted.

@not:
		CLC
		JMP	@done

@wanted:
		SEC

@done:
		RTS
		
		
dialogOvervwColOwnT:
		LDA	#$0F
		STA	game + GAME::varA
;		LDA	#$05
;		STA	game + GAME::varB
		
		LDX	#$2A
		
@loop:
		LDA	sqr00, X
		CMP	#$FF
		BEQ	@next

		TAY
		
		JSR	doDialogOvervwColOwnFilt
		BCC	@next

		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		
		ORA	#$80
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$05
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		INC	game + GAME::varA
		
		INX
		INX
		CPX	#$3C
		BNE	@loop

		RTS


dialogOvervwColOwnR:
		LDA	#$08
		STA	game + GAME::varA
;		LDA	#$1A
;		STA	game + GAME::varB
		
		LDX	#$3E
		
@loop:
		LDA	sqr00, X
		CMP	#$FF
		BEQ	@next

		TAY

		JSR	doDialogOvervwColOwnFilt
		BCC	@next
		
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		
		ORA	#$80
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	#$1A
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY

		STY	game + GAME::varH
		
@next:
		INC	game + GAME::varA
		
		INX
		INX
		CPX	#$50
		BNE	@loop

		RTS

dialogOvervwColOwnL:
		LDA	#$10
		STA	game + GAME::varA
;		LDA	#$0B
;		STA	game + GAME::varB
		
		LDX	#$16
		
@loop:
		LDA	sqr00, X
		CMP	#$FF
		BEQ	@next

		TAY

		JSR	doDialogOvervwColOwnFilt
		BCC	@next
		
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		
		ORA	#$20
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	#$0B
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY

		LDA	#$02
		STA	($A3), Y
		INY

		STY	game + GAME::varH
		
@next:
		DEC	game + GAME::varA
		
		INX
		INX
		CPX	#$28
		BNE	@loop

		RTS

dialogOvervwColOwnB:
		LDA	#$17
		STA	game + GAME::varA
;		LDA	#$13
;		STA	game + GAME::varB
		
		LDX	#$02
		
@loop:
		LDA	sqr00, X
		CMP	#$FF
		BEQ	@next

		TAY

		JSR	doDialogOvervwColOwnFilt
		BCC	@next
		
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		
		ORA	#$30
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$13
		STA	($A3), Y
		INY
		
		LDA	#$02
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		DEC	game + GAME::varA
		
		INX
		INX
		CPX	#$14
		BNE	@loop

		RTS

dialogOvervwColOwn:
		JSR	dialogOvervwColOwnT
		JSR	dialogOvervwColOwnR
		JSR	dialogOvervwColOwnL
		JSR	dialogOvervwColOwnB
		
		RTS
		
dialogOvervwColMrtgT:
		LDA	#$0F
		STA	game + GAME::varA
;		LDA	#$06
;		STA	game + GAME::varB
		
		LDX	#$2A
		
@loop:
		LDA	sqr00 + 1, X
		AND	#$80
		BEQ	@next

		LDA	#$8B
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$06
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		INC	game + GAME::varA
		
		INX
		INX
		CPX	#$3C
		BNE	@loop

		RTS

dialogOvervwColMrtgR:
		LDA	#$08
		STA	game + GAME::varA
;		LDA	#$19
;		STA	game + GAME::varB
		
		LDX	#$3E
		
@loop:
		LDA	sqr00 + 1, X
		AND	#$80
		BEQ	@next

		LDA	#$8B
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	#$19
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY

		STY	game + GAME::varH
		
@next:
		INC	game + GAME::varA
		
		INX
		INX
		CPX	#$50
		BNE	@loop

		RTS
		
dialogOvervwColMrtgL:
		LDA	#$10
		STA	game + GAME::varA
;		LDA	#$0D
;		STA	game + GAME::varB
		
		LDX	#$16
		
@loop:
		LDA	sqr00 + 1, X
		AND	#$80
		BEQ	@next

		LDA	#$8B
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	#$0D
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY

		STY	game + GAME::varH
		
@next:
		DEC	game + GAME::varA
		
		INX
		INX
		CPX	#$28
		BNE	@loop

		RTS
		
dialogOvervwColMrtgB:
		LDA	#$17
		STA	game + GAME::varA
;		LDA	#$12
;		STA	game + GAME::varB
		
		LDX	#$02
		
@loop:
		LDA	sqr00 + 1, X
		AND	#$80
		BEQ	@next

		LDA	#$8B
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$12
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		DEC	game + GAME::varA
		
		INX
		INX
		CPX	#$14
		BNE	@loop

		RTS
			
dialogOvervwColMrtg:
		JSR	dialogOvervwColMrtgT
		JSR	dialogOvervwColMrtgR
		JSR	dialogOvervwColMrtgL
		JSR	dialogOvervwColMrtgB

		RTS
		
dialogOvervwColImprvT:
		LDA	#$0F
		STA	game + GAME::varA
;		LDA	#$06
;		STA	game + GAME::varB
		
		LDX	#$2A
		
@loop:
		LDA	sqr00 + 1, X
		AND	#$0F
		BEQ	@next

		AND	#$08
		BEQ	@hses

		LDA	#$0A
		PHA
		LDA	#$69
		JMP	@out

@hses:
		LDA	#$0D
		PHA	
		
		LDA	sqr00 + 1, X
		AND	#$07
		CLC
		ADC	#$04
		ORA	#$60
		
@out:
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$06
		STA	($A3), Y
		INY

		LDA	#$FF
		STA	($A3), Y
		INY
		
		PLA
		ORA	#$80
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$06
		STA	($A3), Y
		INY

		STY	game + GAME::varH

@next:
		INC	game + GAME::varA
		
		INX
		INX
		CPX	#$3C
		BNE	@loop

		RTS
		
dialogOvervwColImprvR:
		LDA	#$08
		STA	game + GAME::varA
;		LDA	#$19
;		STA	game + GAME::varB
		
		LDX	#$3E
		
@loop:
		LDA	sqr00 + 1, X
		
		AND	#$0F
		BEQ	@next

		AND	#$08
		BEQ	@hses

		LDA	#$0A
		PHA
		LDA	#$69
		JMP	@out

@hses:
		LDA	#$0D
		PHA	
		
		LDA	sqr00 + 1, X
		AND	#$07
		CLC
		ADC	#$04
		ORA	#$60
		
@out:
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	#$19
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY

		LDA	#$FF
		STA	($A3), Y
		INY
		
		PLA
		ORA	#$80
		STA	($A3), Y
		INY
		
		LDA	#$19
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY


		STY	game + GAME::varH
		
@next:
		INC	game + GAME::varA
		
		INX
		INX
		CPX	#$50
		BNE	@loop

		RTS
		
dialogOvervwColImprvL:
		LDA	#$10
		STA	game + GAME::varA
;		LDA	#$0D
;		STA	game + GAME::varB
		
		LDX	#$16
		
@loop:
		LDA	sqr00 + 1, X
		AND	#$0F
		BEQ	@next

		AND	#$08
		BEQ	@hses

		LDA	#$0A
		PHA
		LDA	#$69
		JMP	@out

@hses:
		LDA	#$0D
		PHA	
		
		LDA	sqr00 + 1, X
		AND	#$07
		CLC
		ADC	#$04
		ORA	#$60
		
@out:
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	#$0D
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY

		LDA	#$FF
		STA	($A3), Y
		INY
		
		PLA
		ORA	#$80
		STA	($A3), Y
		INY
		
		LDA	#$0D
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY

		STY	game + GAME::varH
		
@next:
		DEC	game + GAME::varA
		
		INX
		INX
		CPX	#$28
		BNE	@loop

		RTS

dialogOvervwColImprvB:
		LDA	#$17
		STA	game + GAME::varA
;		LDA	#$12
;		STA	game + GAME::varB
		
		LDX	#$02
		
@loop:
		LDA	sqr00 + 1, X
		AND	#$0F
		BEQ	@next

		AND	#$08
		BEQ	@hses

		LDA	#$0A
		PHA
		LDA	#$69
		JMP	@out

@hses:
		LDA	#$0D
		PHA	
		
		LDA	sqr00 + 1, X
		AND	#$07
		CLC
		ADC	#$04
		ORA	#$60
		
@out:
		LDY	game + GAME::varH
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$12
		STA	($A3), Y
		INY
		
		LDA	#$FF
		STA	($A3), Y
		INY
		
		PLA
		ORA	#$80
		STA	($A3), Y
		INY
		
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		
		LDA	#$12
		STA	($A3), Y
		INY

		STY	game + GAME::varH
		
@next:
		DEC	game + GAME::varA
		
		INX
		INX
		CPX	#$14
		BNE	@loop

		RTS
		
dialogOvervwColImprv:
		JSR	dialogOvervwColImprvT
		JSR	dialogOvervwColImprvR
		JSR	dialogOvervwColImprvL
		JSR	dialogOvervwColImprvB
		
		RTS
		
dialogOvervwColPlrT:
;		LDA	#$0E
;		STA	game + GAME::varA	;x pos
;		LDA	#$07			;y pos
		
		LDX 	#$00
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
				
		LDY	#PLAYER::square
		LDA	($FB), Y
		
		CMP	#$14
		BPL	@test0
		
		JMP	@next
		
@test0:
		CMP	#$1E
		BPL	@next
		
		SEC
		SBC	#$14
		STA	game + GAME::varA
		
		CLC
		ADC	#$0E
		PHA
		
		LDY	game + GAME::varH
		LDA	#$6D
		STA	($A3), Y
		INY
		
		PLA
		STA	($A3), Y
		INY

		LDA	#$07
		STA	($A3), Y
		INY
		
		LDA	#$FF
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		INX
		CPX	#$06
		BNE	@loop
		
		RTS
		
dialogOvervwColPlrR:
;		LDA	#$18			;x pos
;		LDA	#$07			;y pos
;		STA	game + GAME::varA	
		
		LDX 	#$00
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
				
		LDY	#PLAYER::square
		LDA	($FB), Y
		
		CMP	#$1E
		BPL	@begin
		
		JMP	@next
		
@begin:
		SEC
		SBC	#$1E
		STA	game + GAME::varA
		
		CLC
		ADC	#$07
		PHA
		
		LDY	game + GAME::varH
		LDA	#$6D
		STA	($A3), Y
		INY
		
		LDA	#$18
		STA	($A3), Y
		INY
		
		PLA
		STA	($A3), Y
		INY
		
		LDA	#$FF
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		INX
		CPX	#$06
		BNE	@loop
		
		RTS
		
dialogOvervwColPlrL:
;		LDA	#$0E			;x pos
;		LDA	#$11			;y pos
;		STA	game + GAME::varA	
		
		LDX 	#$00
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
				
		LDY	#PLAYER::square
		LDA	($FB), Y
		
		CMP	#$0A
		BPL	@test0
		
		JMP	@next
		
@test0:
		CMP	#$14
		BPL	@next
		
		SEC
		SBC	#$0A
		STA	game + GAME::varA
		
		LDA	#$11
		SEC
		SBC	game + GAME::varA
		PHA
		
		LDY	game + GAME::varH
		LDA	#$6D
		STA	($A3), Y
		INY
		
		LDA	#$0E
		STA	($A3), Y
		INY
		
		PLA
		STA	($A3), Y
		INY

		LDA	#$FF
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		INX
		CPX	#$06
		BNE	@loop
		
		RTS
		
		
dialogOvervwColPlrB:
;		LDA	#$18
;		STA	game + GAME::varA	;x pos
;		LDA	#$11			;y pos
		
		LDX 	#$00
		
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
				
		LDY	#PLAYER::square
		LDA	($FB), Y
		
		CMP	#$0A
		BPL	@next
		
		STA	game + GAME::varA
		LDA	#$18
		
		SEC
		SBC	game + GAME::varA
		PHA
		
		LDY	game + GAME::varH
		LDA	#$6D
		STA	($A3), Y
		INY
		
		PLA
		STA	($A3), Y
		INY

		LDA	#$11
		STA	($A3), Y
		INY
		
		LDA	#$FF
		STA	($A3), Y
		INY
		
		STY	game + GAME::varH
		
@next:
		INX
		CPX	#$06
		BNE	@loop
		
		RTS
		
dialogOvervwColPlrs:
		JSR	dialogOvervwColPlrT
		JSR	dialogOvervwColPlrR
		JSR	dialogOvervwColPlrL
		JSR	dialogOvervwColPlrB
		
		RTS
			
			
dialogOvervwCollateState:
		TXA
		PHA
		
		LDA	#$00
		STA	dialogOvervwFiltOwn

		JSR	dialogOvervwColOwn
		
		JSR	dialogOvervwColImprv
		JSR	dialogOvervwColMrtg
		
		PLA
		BEQ	@done
		
		JSR	dialogOvervwColPlrs

@done:
		LDA	#$00
		LDY	game + GAME::varH
		STA	($A3), Y
		INC	game + GAME::varH
		
		RTS


dialogDlgOvervw0Draw:
		JSR	screenBeginButtons

		LDA	#<dialogWindowOvervw0
		STA	$FD
		LDA	#>dialogWindowOvervw0
		STA	$FE
		
		JSR	screenPerformList

		LDA	#<dialogWindowOvervw1
		STA	$FD
		LDA	#>dialogWindowOvervw1
		STA	$FE
		
		JSR	screenPerformList
		
		LDA	#<heap0
		STA	$A3
		LDA	#>heap0
		STA	$A4
		
		LDY	#$00
		STY	game + GAME::varH
		
		LDX	#$01
		JSR	dialogOvervwCollateState

		LDA	#<heap0
		STA	$FD
		LDA	#>heap0
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS
		

dialogWindowTrdSel0:
			.byte	$11, $05, $04, $1E, $11	;chr empty space

;			.byte	$46, $0A, $03, $12	;chr frame (std)
;			.byte	$56, $0A, $04, $11
;			.byte	$47, $0B, $15, $12
;			.byte	$57, $1C, $04, $11
;			.byte	$6A, $1C, $03
;			.byte		$0A, $15, $FF
			
			.byte	$44, $04, $03, $20	;chr frame (heavy)
			.byte	$54, $04, $04, $12
			.byte	$44, $04, $15, $20
			.byte	$54, $23, $03, $12
			
			.byte	$2B, $03, $03, $20	;clr frame
			.byte	$3B, $04, $04, $12
			.byte	$2B, $04, $15, $20
			.byte	$3B, $23, $03, $12

	
			.byte	$90, $05, $0A		;Rem wealth lbls
			.word		strText4TrdSel0	
			.byte	$2C, $05, $0A, $06	;RWealth lbl + $
			.byte	$2F, $05, $0B, $06	

			.byte	$90, $05, $0D		;Rem money lbls
			.word		strText7TrdSel0
			.byte	$2C, $05, $0D, $06
			.byte	$2F, $05, $0E, $06

			.byte	$90, $1D, $05		;GO Free
			.word		strText0TrdSel0
			.byte	$90, $1D, $06
			.word		strText0TrdSel0

							;Ctrls
			.byte	$AE, $0C, $1C, $23, $46, $1C, $0C
			.word		strOptn0TrdSel0
			.byte	$AE, $0D, $1C, $20, $42, $1C, $0D
			.word		strOptn1TrdSel0

			
;***TODO:		Make colours configurable in order to indicate
;			which are available
			.byte	$81, $1C, $05		;GO Free
			.byte	$81, $1C, $06
			.byte	$2F, $1D, $05, $06	
			.byte	$2F, $1D, $06, $06
			
			
			.byte 	$00


dialogWindowTrdSel1:
			.byte	$AE, $10, $1C, $22, $52, $1C, $10
			.word		strOptn5TrdSel0
			
			.byte	$00


dialogWindowTrdSel2:
							;Select button
			.byte	$AE, $0F, $1C, $22, $53, $1C, $0F
			.word		strOptn2TrdSel0

			.byte	$00


dialogWindowTrdSel3:
							;Cash btns
			.byte	$A4, $07, $08, $09, $55, $08, $07
			.word		strDummyDummy0
			.byte	$A4, $07, $09, $0A, $49, $09, $07
			.word		strDummyDummy0
			.byte	$A4, $07, $0A, $0B, $4F, $0A, $07
			.word		strDummyDummy0
			.byte	$A4, $08, $08, $09, $4A, $08, $08
			.word		strDummyDummy0
			.byte	$A4, $08, $09, $0A, $4B, $09, $08
			.word		strDummyDummy0
			.byte	$A4, $08, $0A, $0B, $4C, $0A, $08
			.word		strDummyDummy0

			.byte	$90, $05, $07		;Cash btn lbls
			.word		strText1TrdSel0
			.byte	$90, $05, $08
			.word		strText2TrdSel0
;			.byte	$8F, $05, $07		;Cash btn clrs
;			.byte	$8F, $05, $08
			
			.byte	$90, $05, $05		;Cash lbls
			.word		strText3TrdSel0
			.byte	$2C, $05, $05, $06	;Cash lbl + $ 
			.byte	$2F, $05, $06, $06	
			
			.byte	$00

dialogWindowTrdSel4:
			.byte	$AE, $12, $1C, $22, $41, $1C, $12
			.word		strOptn3TrdSel0
			.byte	$AE, $13, $1C, $23, $44, $1C, $13
			.word		strOptn4TrdSel0

			.byte	$00


dialogAddrTrdSelCash	=	$04F5
dialogAddrTrdSelRWealth	=	$05BD
dialogAddrTrdSelRCash	=	$0635


dialogAddrTrdSelSqrLo:
			.byte	<$06E9, <$06E7, <$06E6, <$06E5, <$06E4, <$06E3 
			.byte	<$06E2, <$06E1, <$06E0, <$06DF, <$06DD, <$068D 
			.byte	<$0665, <$063D, <$0615, <$05ED, <$05C5, <$059D 
			.byte	<$0575, <$054D, <$04FD, <$04FF, <$0500, <$0501 
			.byte	<$0502, <$0503, <$0504, <$0505, <$0506, <$0507 
			.byte	<$0509, <$0559, <$0581, <$05A9, <$05D1, <$05F9 
			.byte	<$0621, <$0649, <$0671, <$0699, <$04E4, <$050C 
			
dialogAddrTrdSelSqrHi:
			.byte	>$06E9, >$06E7, >$06E6, >$06E5, >$06E4, >$06E3 
			.byte	>$06E2, >$06E1, >$06E0, >$06DF, >$06DD, >$068D 
			.byte	>$0665, >$063D, >$0615, >$05ED, >$05C5, >$059D 
			.byte	>$0575, >$054D, >$04FD, >$04FF, >$0500, >$0501 
			.byte	>$0502, >$0503, >$0504, >$0505, >$0506, >$0507 
			.byte	>$0509, >$0559, >$0581, >$05A9, >$05D1, >$05F9 
			.byte	>$0621, >$0649, >$0671, >$0699, >$04E4, >$050C 

dialogAddrTrdSelRepLo:
			.byte	<$06C1, <$06BF, <$06BE, <$06BD, <$06BC, <$06BB 
			.byte	<$06BA, <$06B9, <$06B8, <$06B7, <$06B5, <$068E 
			.byte	<$0666, <$063E, <$0616, <$05EE, <$05C6, <$059E 
			.byte	<$0576, <$054E, <$0525, <$0527, <$0528, <$0529 
			.byte	<$052A, <$052B, <$052C, <$052D, <$052E, <$052F 
			.byte	<$0531, <$0558, <$0580, <$05A8, <$05D0, <$05F8 
			.byte	<$0620, <$0648, <$0670, <$0698
			
dialogAddrTrdSelRepHi:
			.byte	>$06C1, >$06BF, >$06BE, >$06BD, >$06BC, >$06BB 
			.byte	>$06BA, >$06B9, >$06B8, >$06B7, >$06B5, >$068E 
			.byte	>$0666, >$063E, >$0616, >$05EE, >$05C6, >$059E 
			.byte	>$0576, >$054E, >$0525, >$0527, >$0528, >$0529 
			.byte	>$052A, >$052B, >$052C, >$052D, >$052E, >$052F 
			.byte	>$0531, >$0558, >$0580, >$05A8, >$05D0, >$05F8 
			.byte	>$0620, >$0648, >$0670, >$0698


dialogBakupTrdSelSqr:		
			.byte	$E7, $E7, $E7, $E7, $E7, $E7, $E7, $E7
			.byte	$E7, $E7, $A0, $F7, $F7, $F7, $F7, $F7
			.byte	$F7, $F7, $F7, $F7, $F7, $D0, $D0, $D0
			.byte	$D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
			.byte	$D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
			.byte	$20, $20
			
dialogBakupTrdSelRep:
			.byte	$D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
			.byte	$D0, $D0, $F7, $D0, $D0, $D0, $D0, $D0
			.byte	$D0, $D0, $D0, $D0, $A0, $E7, $E7, $E7
			.byte	$E7, $E7, $E7, $E7, $E7, $E7, $E7, $F7
			.byte	$F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7

dialogTrdSelDoElimin:
		.byte	$00
dialogTrdSelDoApprv:
		.byte	$00
dialogTrdSelDoRepay:
		.byte	$00
dialogTrdSelMaxCash:
		.word	$0000
dialogTrdSelBakRWlthI:
		.byte	$00
		.byte	$00
		.byte	$00
dialogTrdSelBakRWlthA:
		.byte	$00
		.byte	$00
		.byte	$00
dialogTrdSelBakRCashI:
		.word	$0000
dialogTrdSelBakRCashA:
		.word	$0000
	

doDialogTrdSelGetAddr:
		LDX	game + GAME::sTrdSel
		LDA	dialogAddrTrdSelSqrLo, X
		STA	game + GAME::aTrdSlH
		LDA	dialogAddrTrdSelSqrHi, X
		STA	game + GAME::aTrdSlH + 1
		
		RTS
		

doDialogTrdSelBckChar:
		LDA	game + GAME::aTrdSlH
		STA	$A3
		LDA	game + GAME::aTrdSlH + 1
		STA	$A4
		
		LDY	#$00
		LDA	($A3), Y
		
		STA	game + GAME::cTrdSlB

		RTS
		

doDialogTrdSelRstChar:
		LDA	game + GAME::aTrdSlH
		STA	$A3
		LDA	game + GAME::aTrdSlH + 1
		STA	$A4
		
		LDY	#$00
		LDA	game + GAME::cTrdSlB
		
		STA	($A3), Y

		RTS


doDialogTrdSelMvFwd:
		JSR	doDialogTrdSelRstChar

		INC	game + GAME::sTrdSel
		LDA	game + GAME::sTrdSel
		CMP	#$2A
		BNE	@proc
		
		LDA	#$00
		STA	game + GAME::sTrdSel
		
@proc:
		JSR	doDialogTrdSelGetAddr
		JSR	doDialogTrdSelBckChar
		
		RTS


doDialogTrdSelMvBck:
		JSR	doDialogTrdSelRstChar

		DEC	game + GAME::sTrdSel
		LDA	game + GAME::sTrdSel
		CMP	#$FF
		BNE	@proc
		
		LDA	#$29
		STA	game + GAME::sTrdSel
		
@proc:
		JSR	doDialogTrdSelGetAddr
		JSR	doDialogTrdSelBckChar
		
		RTS

;-------------------------------------------------------------------------------
doDialogTrdSelGetCashHi:
;-------------------------------------------------------------------------------
		LDA	dialogTrdSelDoApprv
		BEQ	@initial
		
		LDA	menuTrade1RemCash + 1
		RTS

@initial:
		LDA	menuTrade0RemCash + 1
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelSubRWlthI:
;-------------------------------------------------------------------------------
		SEC
		LDA	menuTrade0RemWealth
		SBC	game + GAME::varD
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		SBC	game + GAME::varE 
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		SBC	#$00
		STA	menuTrade0RemWealth + 2
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelSubRCashI:
;-------------------------------------------------------------------------------
		SEC
		LDA	menuTrade0RemCash
		SBC	game + GAME::varD
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		SBC	game + GAME::varE 
		STA	menuTrade0RemCash + 1
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelSubRWlthA:
;-------------------------------------------------------------------------------
		SEC
		LDA	menuTrade1RemWealth
		SBC	game + GAME::varD
		STA	menuTrade1RemWealth
		LDA	menuTrade1RemWealth + 1
		SBC	game + GAME::varE 
		STA	menuTrade1RemWealth + 1
		LDA	menuTrade1RemWealth + 2
		SBC	#$00
		STA	menuTrade1RemWealth + 2
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelSubRCashA:
;-------------------------------------------------------------------------------
		SEC
		LDA	menuTrade1RemCash
		SBC	game + GAME::varD
		STA	menuTrade1RemCash
		LDA	menuTrade1RemCash + 1
		SBC	game + GAME::varE 
		STA	menuTrade1RemCash + 1
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelChrgFee:
;-------------------------------------------------------------------------------
;		Directly charge the fee on the remaining wealth for square in .X

		TXA
		JSR	gameGetCardPtrForSquare
		
		LDY	#DEED::mFee
		
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE

		LDA	dialogTrdSelDoApprv
		BEQ	@initial

		JSR	doDialogTrdSelSubRWlthA
		JSR	doDialogTrdSelSubRCashA
		RTS
		
@initial:
		JSR	doDialogTrdSelSubRWlthI
		JSR	doDialogTrdSelSubRCashI
		RTS
		
		
;-------------------------------------------------------------------------------
doDialogTrdSelAddRWlthI:
;-------------------------------------------------------------------------------
		CLC
		LDA	($FD), Y
		ADC	menuTrade0RemWealth
		STA	menuTrade0RemWealth
		INY	
		LDA	($FD), Y
		ADC	menuTrade0RemWealth + 1
		STA	menuTrade0RemWealth + 1
		LDA	#$00
		ADC	menuTrade0RemWealth + 2
		STA	menuTrade0RemWealth + 2
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelAddRCashI:
;-------------------------------------------------------------------------------
		CLC
		LDA	($FD), Y
		ADC	menuTrade0RemCash
		STA	menuTrade0RemCash
		INY	
		LDA	($FD), Y
		ADC	menuTrade0RemCash + 1
		STA	menuTrade0RemCash + 1
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelAddRWlthA:
;-------------------------------------------------------------------------------
		CLC
		LDA	($FD), Y
		ADC	menuTrade1RemWealth
		STA	menuTrade1RemWealth
		INY	
		LDA	($FD), Y
		ADC	menuTrade1RemWealth + 1
		STA	menuTrade1RemWealth + 1
		LDA	#$00
		ADC	menuTrade1RemWealth + 2
		STA	menuTrade1RemWealth + 2
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelAddRCashA:
;-------------------------------------------------------------------------------
		CLC
		LDA	($FD), Y
		ADC	menuTrade1RemCash
		STA	menuTrade1RemCash
		INY	
		LDA	($FD), Y
		ADC	menuTrade1RemCash + 1
		STA	menuTrade1RemCash + 1
		
		RTS


;-------------------------------------------------------------------------------
doDialogTrdSelTstRfndSel:
;-------------------------------------------------------------------------------
;		For trade index in .X...
;		See if square is mortgaged, if so..  if repay set refund repay
;		else refund just fee
		
		TXA
		PHA
		JSR	gameGetCardPtrForSquare
		PLA
		TAX
		
		LDA	dialogTrdSelDoRepay	;Is wanting?  Check fees
		BNE	@wanted	

		LDA	dialogTrdSelDoElimin	;Is elimination, Check fees
		BNE	@wanted

		LDA	trdrepay2, X
		AND	#$80
		BEQ	@rfndequity
		
		RTS
		
@rfndequity:
		TXA
		PHA
		JSR	doDialogTrdSelRfndWlthMVal	;Return lost equity
		PLA
		TAX

		RTS

@wanted:
		LDA	trdrepay2, X
		AND	#$80
		BNE	@rfndfee
		
		TXA				;Return gained equity
		PHA
		JSR	doDialogTrdSelChrgWlthMVal
		PLA
		TAX
	
		RTS
		
@rfndfee:
		LDY	#DEED::mFee		;Return charged fee
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial
		
		JSR	doDialogTrdSelAddRWlthA

		LDA	trdrepay2, X
		AND	#$01
		BEQ	@exit
		
		LDY	#DEED::mValue
		JSR	doDialogTrdSelAddRCashA
		
		RTS
		
@initial:
		JSR	doDialogTrdSelAddRWlthI
		
		LDA	trdrepay2, X
		AND	#$01
		BEQ	@exit
		
		LDY	#DEED::mValue
		JSR	doDialogTrdSelAddRCashI
		
		
@exit:
		RTS
		
		
;-------------------------------------------------------------------------------
doDialogTrdSelChrgWlthMVal:
;-------------------------------------------------------------------------------
;		Directly charge the mvalue on the remaining wealth for square in .X

		TXA
		JSR	gameGetCardPtrForSquare
		
		LDY	#DEED::mValue
		
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial

		JSR	doDialogTrdSelSubRWlthA
		RTS
		
@initial:
		JSR	doDialogTrdSelSubRWlthI
		
		RTS
		
		
;-------------------------------------------------------------------------------
doDialogTrdSelChrgCashMVal:
;-------------------------------------------------------------------------------
;		Directly charge the mvalue on the remaining cash for square in .X

		TXA
		JSR	gameGetCardPtrForSquare
		
		LDY	#DEED::mValue
		
		LDA	($FD), Y
		STA	game + GAME::varD
		INY	
		LDA	($FD), Y
		STA	game + GAME::varE
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial

		JSR	doDialogTrdSelSubRCashA
		RTS
		
@initial:
		JSR	doDialogTrdSelSubRCashI
		
		RTS
		
		
;-------------------------------------------------------------------------------
doDialogTrdSelRfndWlthMVal:
;-------------------------------------------------------------------------------
;		Directly refund the mvalue on the remaining wealth for square in .X

		TXA

		JSR	gameGetCardPtrForSquare

doDialogTrdSelRfndWlthMValAlt:
		LDY	#DEED::mValue
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial

		JSR	doDialogTrdSelAddRWlthA
		RTS
		
@initial:
		JSR	doDialogTrdSelAddRWlthI
		RTS
		

;-------------------------------------------------------------------------------
doDialogTrdSelRfndCashMVal:
;-------------------------------------------------------------------------------
;		Directly refund the mvalue on the remaining cash for square in .X

		TXA

		JSR	gameGetCardPtrForSquare

doDialogTrdSelRfndCashMValAlt:
		LDY	#DEED::mValue
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial

		JSR	doDialogTrdSelAddRCashA
		RTS
		
@initial:
		JSR	doDialogTrdSelAddRCashI
		RTS
		

;-------------------------------------------------------------------------------
doDialogTrdSelTogRepay:
;-------------------------------------------------------------------------------
		LDX	game + GAME::sTrdSel
		CPX	#$28			;Is it an actual square?
		BMI	@tstselect
		
		JMP	@exit			;No (and no sound)

@tstselect:
		LDA	#$02			;Default to buzz
		STA	game + GAME::varP
		
		LDA	trddeeds2, X		;Is selected?
		BNE	@begin0			;Yes, test mortgaged
		
		JMP	@doSound		;No, quit

@begin0:						
		LDA	trdrepay2, X		;Is mortgaged?
		AND	#$80
		BNE	@begin1			;Yes, begin	
		
		JMP	@doSound		;No, quit
		
@begin1:
		LDA	#$00			;Default to just fee
		STA	game + GAME::varP
		
		LDA	trdrepay2, X		;Actual square...
		AND	#$01
		BEQ	@togon			;Selecting?

		LDA	trddeeds2, X		
		TAX				
		JSR	doDialogTrdSelRfndCashMVal	

		LDX	game + GAME::sTrdSel
		LDA	trdrepay2, X		;No
		AND	#$FE
		STA	trdrepay2, X

		LDA	dialogBakupTrdSelRep, X
		JMP	@proc
		
@togon:
		LDA	trddeeds2, X		
		TAX
		JSR	doDialogTrdSelChrgCashMVal
		
		LDX	game + GAME::sTrdSel
		LDA	trdrepay2, X		;Yes
		ORA	#$01	
		STA	trdrepay2, X
		
		JSR	doDialogTrdSelGetCashHi
		BPL	@okay0
		
		LDA	#$03
		STA	game + GAME::varP
		JMP	@cont0
		
@okay0:
		LDA	#$01
		STA	game + GAME::varP
		
@cont0:
		LDA	#$DA
	
@proc:
		PHA
		
		LDA	dialogAddrTrdSelRepLo, X	
		STA	$A3
		LDA	dialogAddrTrdSelRepHi, X
		STA	$A4
		
		LDY	#$00
		PLA
		STA	($A3), Y

@doSound:
		LDA	game + GAME::varP
		BNE	@tstMrtg
		
		LDY	#>SFXCASH
		LDA	#<SFXCASH
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@tstMrtg:
		CMP	#$01
		BNE	@tstBuzz
		
		LDA	#<SFXRENT2
		LDY	#>SFXRENT2
		LDX	#$07
		JSR	SNDBASE + 6

		RTS
		
@tstBuzz:
		CMP	#$02
		BNE	@doBell
		
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@doBell:
		LDA	#<SFXBELL
		LDY	#>SFXBELL
		LDX	#$07
		JSR	SNDBASE + 6
		
@exit:
		RTS
		

;-------------------------------------------------------------------------------
doDialogTrdSelToggle:
;-------------------------------------------------------------------------------
		LDA	#$02			;Default to buzz
		STA	game + GAME::varP

		LDX	game + GAME::sTrdSel
		
		LDA	trddeeds2, X
		BEQ	@togon			;Selecting?
		
		LDA	#$00			;No, set unselected
		STA	trddeeds2, X

		CPX	#$28			;Is it an actual square?
		BPL	@cont0			;No
		
;		.X is already loaded		
		JSR	doDialogTrdSelTstRfndSel

		LDA	dialogAddrTrdSelRepLo, X	;Yes, clear any previous 
		STA	$A3				;repay
		LDA	dialogAddrTrdSelRepHi, X
		STA	$A4

		LDY	#$00
		LDA	dialogBakupTrdSelRep, X
		STA	($A3), Y
		
		LDA	trdrepay2, X		;Set no repay
		AND	#$FE
		STA	trdrepay2, X

@cont0:
		LDA	#$00			;Can ding
		STA	game + GAME::varP
		
		LDA	dialogBakupTrdSelSqr, X
		JMP	@proc
		
@togon:
		CPX	#$28			;Is it an actual square?
		BMI	@square
		
		JMP	@tstgofree		;No, test gofree
		
@square:
		LDA	dialogTrdSelDoRepay	;Offering?
		BEQ	@tstPlr			;Yes, don't worry about wealth

		LDA	menuTrade0RemWealth + 2	;Is there remaining wealth?
		BPL	@tstCash
		JMP	@doSound		;No, bail (buzz)
		
@tstCash:		
		LDA	menuTrade0RemCash + 1	;Is there remaining cash?
		BPL	@tstPlr
		JMP	@doSound		;No, bail (buzz)
		
@tstPlr:
		TXA				;Yes, test player
		ASL
		TAX
		LDA	sqr00, X
		STA	game + GAME::varN
		
		LDY	#TRADE::player	
		LDA	trade2, Y
		CMP	game + GAME::varN	;Is right player?
		BEQ	@tstimprv
		
		JMP	@doSound		;No, bail (buzz)
		
@tstimprv:
		LDA	game + GAME::sTrdSel
		ASL
		TAX
		LDA	sqr00 + 1, X
		AND	#$80
		STA	game + GAME::varO

		LDA	rulesSqr0, X		;Get square group ptr
		TAX
		LDY	#$FF
		JSR 	rulesDoCollateImprv	;Get improvement stats

		LDA	game + GAME::varB	;Has improvements?
		BEQ	@proc0
		
		JMP	@doSound		;Yes, bail (buzz)
		
@proc0:
		LDA	#$00			;Can ding
		STA	game + GAME::varP
		
		LDA	game + GAME::varO	;Get the mortgage info 
		LDX	game + GAME::sTrdSel	;Store in trade repay info
		STA	trdrepay2, X
	
		LDA	dialogTrdSelDoElimin
		BNE	@repay

		LDA	dialogTrdSelDoRepay	;Is offering?  Check for sub
		BEQ	@dooffer		;equity
		
@repay:
		LDA	game + GAME::varO	;Need to LDA again for flags
		AND	#$80			;Is mrtg? 
		BNE	@dowantfee

		LDA	#$04			;Get money
		STA	game + GAME::varP
		
						;.X is already loaded
		JSR	doDialogTrdSelRfndWlthMVal
		LDX	game + GAME::sTrdSel
		
		JMP	@dotstwealth

@dowantfee:
		LDA	#$01			;Set sound to rent
		STA	game + GAME::varP
		
						;.X is already loaded
		JSR	doDialogTrdSelChrgFee
		LDX	game + GAME::sTrdSel

		JMP	@dotstwealth

@dooffer:	
		LDA	game + GAME::varO	;Is mortgaged, no loss in offer
		AND	#$80			
		BNE	@dotogon

		LDA	#$01			;Set sound to rent
		STA	game + GAME::varP
		
						;.X is already loaded
		JSR	doDialogTrdSelChrgWlthMVal  ;Need to sub equity
		LDX	game + GAME::sTrdSel

;		JMP	@dotstwealth

@dotstwealth:
		LDA	menuTrade0RemWealth + 2
		BPL	@dotogon
		
		LDA	menuTrade0RemCash + 1
		BPL	@dotogon
		
		LDA	#$03			;Gone negative set sound to bell
		STA	game + GAME::varP
		
		JMP	@dotogon
		
@tstgofree:
		LDY	#TRADE::player	
		LDA	trade2, Y
		
		CMP	game + GAME::pGF0Crd
		BEQ	@dogofree
		
		CMP	game + GAME::pGF1Crd
		BEQ	@dogofree
		
		JMP	@doSound
		
@dogofree:
		LDA	#$00			;Can ding
		STA	game + GAME::varP

@dotogon:
		LDX	game + GAME::sTrdSel	;Set selected
		LDA	#$01			
		STA	trddeeds2, X
		
		LDA	#$AA
		
@proc:
		PHA
		LDA	game + GAME::aTrdSlH
		STA	$A3
		LDA	game + GAME::aTrdSlH + 1
		STA	$A4
		
		LDY	#$00
		PLA
		
		STA	($A3), Y
		STA	game + GAME::cTrdSlB


@doSound:
		LDA	game + GAME::varP
		BNE	@tstRent
		
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@tstRent:
		CMP	#$01
		BNE	@tstBuzz
		
		LDA	#<SFXRENT0
		LDY	#>SFXRENT0
		LDX	#$07
		JSR	SNDBASE + 6

		RTS

@tstBuzz:
		CMP	#$02
		BNE	@tstBell
		
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS

@tstBell:
		CMP	#$03
		BNE	@doCash
		
		LDA	#<SFXBELL
		LDY	#>SFXBELL
		LDX	#$07
		JSR	SNDBASE + 6
		
@doCash:
		LDY	#>SFXCASH
		LDA	#<SFXCASH
		LDX	#$07
		JSR	SNDBASE + 6

		RTS


doDialogTrdSelClose:
		LDA	game + GAME::fTrdSlM
		STA	game + GAME::gMode

		LDA	#$00
		STA	game + GAME::dlgVis
		LDA	#$01
		STA	game + GAME::pVis
		
		JSR	gamePlayersDirty
		
		LDA	#$10
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


doDialogTrdSelSetRCashI:
		LDA	#<dialogAddrTrdSelRCash
		STA	$FD
		LDA	#>dialogAddrTrdSelRCash
		STA	$FE

		LDA	menuTrade0RemCash + 1	
		BMI	@dispInvl		
		
		LDA	menuTrade0RemCash
		STA	Z:numConvVALUE
		LDA	menuTrade0RemCash + 1
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDA	#$24
		LDY	#$00
		STA	($FD), Y
		
		INC	$FD			;Naughty but will work...
						;Just
		LDY	#$04
@loop:
		LDA	heap0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop

		RTS

@dispInvl:
		
		LDY	#$05
@loop0:
		LDA	strText5TrdSel0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop0
		
		RTS


doDialogTrdSelSetRWlthI:
		LDA	#<dialogAddrTrdSelRWealth
		STA	$FD
		LDA	#>dialogAddrTrdSelRWealth
		STA	$FE
		
		LDA	menuTrade0RemWealth + 2	
		BMI	@dispInvl		
		
;***FIXME: 	Is there a better way of testing overflow?  I should check.
		BNE	@dispOvfl		;See if the value has overflown
						;by cheating...  
		LDA	menuTrade0RemWealth + 1	;
		AND	#$80			;Is the 16th bit used?
		BNE	@dispOvfl
		
		LDA	menuTrade0RemWealth
		STA	Z:numConvVALUE
		LDA	menuTrade0RemWealth + 1
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDA	#$24
		LDY	#$00
		STA	($FD), Y
		
		INC	$FD			;Naughty but will work...
						;Just
		LDY	#$04
@loop:
		LDA	heap0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop

		RTS
		
@dispInvl:
		
		LDY	#$05
@loop0:
		LDA	strText5TrdSel0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop0
		
		RTS
		
@dispOvfl:
		LDY	#$05
@loop1:
		LDA	strText6TrdSel0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop1
		
		RTS


doDialogTrdSelSetRCashA:
		LDA	#<dialogAddrTrdSelRCash
		STA	$FD
		LDA	#>dialogAddrTrdSelRCash
		STA	$FE

		LDA	menuTrade1RemCash + 1	
		BMI	@dispInvl		
		
		LDA	menuTrade1RemCash
		STA	Z:numConvVALUE
		LDA	menuTrade1RemCash + 1
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDA	#$24
		LDY	#$00
		STA	($FD), Y
		
		INC	$FD			;Naughty but will work...
						;Just
		LDY	#$04
@loop:
		LDA	heap0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop

		RTS

@dispInvl:
		
		LDY	#$05
@loop0:
		LDA	strText5TrdSel0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop0
		
		RTS


doDialogTrdSelSetRWlthA:

;***FIXME	Can I somehow not be duplicating all of this?

		LDA	#<dialogAddrTrdSelRWealth
		STA	$FD
		LDA	#>dialogAddrTrdSelRWealth
		STA	$FE
		
		LDA	menuTrade1RemWealth + 2	
		BMI	@dispInvl		
		
;***FIXME: 	Is there a better way of testing overflow?  I should check.
		BNE	@dispOvfl		;See if the value has overflown
						;by cheating...  
		LDA	menuTrade1RemWealth + 1	;
		AND	#$80			;Is the 16th bit used?
		BNE	@dispOvfl
		
		LDA	menuTrade1RemWealth
		STA	Z:numConvVALUE
		LDA	menuTrade1RemWealth + 1
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDA	#$24
		LDY	#$00
		STA	($FD), Y
		
		INC	$FD			;Naughty but will work...
						;Just
		LDY	#$04
@loop:
		LDA	heap0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop

		RTS
		
@dispInvl:
		
		LDY	#$05
@loop0:
		LDA	strText5TrdSel0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop0
		
		RTS
		
@dispOvfl:
		LDY	#$05
@loop1:
		LDA	strText6TrdSel0 + 1, Y
		STA	($FD), Y
		
		DEY
		BPL	@loop1
		
		RTS

		
doDialogTrdSelSetCash:
		LDX	#TRADE::money
		LDA	trade2, X
		STA	Z:numConvVALUE
		INX
		LDA	trade2, X
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDA	#<dialogAddrTrdSelCash
		STA	$A3
		LDA	#>dialogAddrTrdSelCash
		STA	$A4
		
		LDA	#$24
		LDY	#$00
		STA	($A3), Y
		
		INC	$A3			;Naughty but will work...
						;Just
		LDY	#$04
@loop:
		LDA	heap0 + 1, Y
		STA	($A3), Y
		
		DEY
		BPL	@loop

		RTS
		
		
doDialogTrdSelSetState:
		LDY	#$00
		LDX	#$29
@loop:
		LDA	trddeeds2, X
		BEQ	@next
		
		LDA	dialogAddrTrdSelSqrLo, X
		STA	$A3
		LDA	dialogAddrTrdSelSqrHi, X
		STA	$A4
		
		LDA	#$AA
		STA	($A3), Y
		
@next:
		DEX
		BPL	@loop


		LDY	#$00
		LDX	#$27
@loop1:
		LDA	trdrepay2, X
		AND	#$01
		BEQ	@next1
		
		LDA	dialogAddrTrdSelRepLo, X
		STA	$A3
		LDA	dialogAddrTrdSelRepHi, X
		STA	$A4
		
		LDA	#$DA
		STA	($A3), Y
		
@next1:
		DEX
		BPL	@loop1


		LDA	dialogTrdSelDoElimin
		BNE	@skipcash

		JSR	doDialogTrdSelSetCash
		
@skipcash:
		LDA	dialogTrdSelDoApprv
		BEQ	@initial
		
		JSR	doDialogTrdSelSetRWlthA
		JSR	doDialogTrdSelSetRCashA
		RTS
		
@initial:
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		RTS


doDialogTrdSelPackData:
		LDY	#TRADE::cntDeed		;We fetch which data from here
		LDA	trade2, Y
		JSR	gamePrepTradePtrs
		
		LDY	#TRADE::money		;Store cash
		LDA	trade2, Y
		STA	($A3), Y
		INY
		LDA	trade2, Y
		STA	($A3), Y

		LDA	#$00			;Init deed count
		STA	game + GAME::varA
		
		LDY	#TRADE::gofree		;Init it here for convienience
		STA	($A3), Y
		
		LDX	#$00			;For each square
@loop0:
		LDA	trddeeds2, X		;Is selected for trade?
		BEQ	@next0			;No - next
		
		TXA				;Yes - add to trade
		LDY	game + GAME::varA
		STA	($A5), Y
		
		LDA	trdrepay2, X
		STA	($A7), Y
		
		INC	game + GAME::varA	;Bump count

@next0:
		INX
		CPX	#$28
		BNE	@loop0
		
		LDY	#TRADE::cntDeed		;Get back deed count
		LDA	game + GAME::varA
		STA	($A3), Y
		
		LDY	#TRADE::gofree		;Set GOFree flags
		
		LDA	trddeeds2, X
		BEQ	@gofree2
		
		LDA	#$01
		STA	($A3), Y
		
@gofree2:
		INX
		
		LDA	trddeeds2, X
		BEQ	@exit
		
		LDA	#$02
		ORA	($A3), Y
		STA	($A3), Y

@exit:
		RTS
		
		
doDialogTrdSelAddCash:
		PHA
		
		LDX	dialogTrdSelDoRepay
		BNE	@begin
		
		LDX	menuTrade0RemWealth + 2
		BPL	@begin
		
		JMP	@max
		
@begin:

		LDX	#TRADE::money
		CLC
		ADC	trade2, X
		STA	game + GAME::varM
		LDA	#$00
		INX
		ADC	trade2, X
		STA	game + GAME::varN
		
		LDA	dialogTrdSelMaxCash
		STA	game + GAME::varD
		LDA	dialogTrdSelMaxCash + 1
		STA	game + GAME::varE
		
		LDA	game + GAME::varM
		LDY	game + GAME::varN
		
;		D, E (max) < .A, .Y (new) -> CLC | SEC
		JSR	gameAmountIsLess
		BCS	@cont0
		
		JMP	@max

@cont0:
		LDX	#TRADE::money
		LDA	game + GAME::varM
		STA	trade2, X
		INX
		LDA	game + GAME::varN
		STA	trade2, X

		LDA	dialogTrdSelDoRepay
		BEQ	@subRWealth
		
		LDA	#$00
		STA	game + GAME::varO
		
		PLA
		STA	game + GAME::varP
		
		CLC
		ADC	menuTrade0RemWealth
		STA	menuTrade0RemWealth
		LDA	#$00
		ADC	menuTrade0RemWealth + 1
		STA	menuTrade0RemWealth + 1
		LDA	#$00
		ADC	menuTrade0RemWealth + 2
		STA	menuTrade0RemWealth + 2
		
		BPL	@addCash
		
		LDA	#$01
		STA	game + GAME::varO
		
@addCash:
		CLC
		LDA	game + GAME::varP
		ADC	menuTrade0RemCash
		STA	menuTrade0RemCash
		LDA	#$00
		ADC	menuTrade0RemCash + 1
		STA	menuTrade0RemCash + 1

		BMI	@sfxBell
		
		LDA	game + GAME::varO
		BEQ	@sfxDing
		
		JMP	@sfxBell
		
@subRWealth:
		LDA	#$00
		STA	game + GAME::varO

		PLA
		STA	game + GAME::varD
		
		SEC
		LDA	menuTrade0RemWealth
		SBC	game + GAME::varD
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		SBC	#$00
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		SBC	#$00
		STA	menuTrade0RemWealth + 2
		
		BPL	@subCash
		
		LDA	#$01
		STA	game + GAME::varO
		
@subCash:
		SEC
		LDA	menuTrade0RemCash
		SBC	game + GAME::varD
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		SBC	#$00
		STA	menuTrade0RemCash + 1

		BMI	@sfxBell
		
		LDA	game + GAME::varO
		BEQ	@sfxDing
		
		JMP	@sfxBell
		
@sfxDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS

@sfxBell:
		LDA	#<SFXBELL
		LDY	#>SFXBELL
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@max:
		PLA

		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6

		RTS


doDialogTrdSelSubCash:
		LDX	#TRADE::money
		STA	game + GAME::varA
		
		SEC
		LDA	trade2, X
		SBC	game + GAME::varA
		STA	game + GAME::varD
		INX
		LDA	trade2, X
		SBC	#$00
		STA	game + GAME::varE
		
		BPL	@cont0
		
		JMP	@min
		
@cont0:
		LDX	#TRADE::money
		LDA	game + GAME::varD
		STA	trade2, X
		INX
		LDA	game + GAME::varE
		STA	trade2, X

		LDA	dialogTrdSelDoRepay
		BEQ	@addRWealth
		
		LDA	#$00
		STA	game + GAME::varP
		
		SEC
		LDA	menuTrade0RemWealth
		SBC	game + GAME::varA
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		SBC	#$00
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		SBC	#$00
		STA	menuTrade0RemWealth + 2
		
		BPL	@subCash
		
		LDA	#$01
		STA	game + GAME::varP
		
@subCash:
		SEC
		LDA	menuTrade0RemCash
		SBC	game + GAME::varA
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		SBC	#$00
		STA	menuTrade0RemCash + 1
		
		BMI	@sfxBell
		
		LDA	game + GAME::varP
		BEQ	@sfxDing
		
		JMP	@sfxBell
		
@addRWealth:
		LDA	#$00
		STA	game + GAME::varP
		
		CLC
		LDA	menuTrade0RemWealth
		ADC	game + GAME::varA
		STA	menuTrade0RemWealth
		LDA	menuTrade0RemWealth + 1
		ADC	#$00
		STA	menuTrade0RemWealth + 1
		LDA	menuTrade0RemWealth + 2
		ADC	#$00
		STA	menuTrade0RemWealth + 2

		BPL	@addCash
		
		LDA	#$01
		STA	game + GAME::varP
		
@addCash:
		CLC
		LDA	menuTrade0RemCash
		ADC	game + GAME::varA
		STA	menuTrade0RemCash
		LDA	menuTrade0RemCash + 1
		ADC	#$00
		STA	menuTrade0RemCash + 1

		BMI	@sfxBell
		
		LDA	game + GAME::varP
		BEQ	@sfxDing
		
		JMP	@sfxBell

@sfxDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@min:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS

@sfxBell:
		LDA	#<SFXBELL
		LDY	#>SFXBELL
		LDX	#$07
		JSR	SNDBASE + 6

		RTS


dialogDlgTrdSel0Keys:
		CMP	#'F'
		BNE	@keysB
		
		JSR	doDialogTrdSelMvFwd
		
		JMP	@keysDing

@keysB:
		CMP	#'B'
		BNE	@keysS
		
		JSR	doDialogTrdSelMvBck
		JMP	@keysDing
		
@keysS:
		LDX	dialogTrdSelDoApprv
		BNE	@keysR

		CMP	#'S'
		BNE	@keysR
		
		JSR	doDialogTrdSelToggle
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		JMP	@keysExit
		
@keysR:
		LDX	dialogTrdSelDoElimin
		BNE	@tstR

		LDX	dialogTrdSelDoRepay
		BEQ	@keysD
		
@tstR:
		CMP	#'R'
		BNE	@keysD

		LDA	dialogTrdSelDoApprv
		BNE	@initR

		LDA	menuTrade1RemWealth + 2
		BPL	@tstRepA
		JMP	@keysBuzz
		
@tstRepA:
		LDA	menuTrade1RemCash + 1
		BPL	@doRepay
		JMP	@keysBuzz

@initR:
		LDA	menuTrade0RemWealth + 2
		BPL	@tstRepI
		JMP	@keysBuzz
		
@tstRepI:
		LDA	menuTrade0RemCash + 1
		BPL	@doRepay
		JMP	@keysBuzz
		
@doRepay:
		JSR	doDialogTrdSelTogRepay
		JMP	@tstrwealth

@keysD:
		CMP	#'D'
		BNE	@keysA

		LDA	dialogTrdSelDoApprv
		BEQ	@initD
		
		LDA	dialogTrdSelBakRWlthA	;Restore r wealth
		STA	menuTrade1RemWealth	
		LDA	dialogTrdSelBakRWlthA + 1	
		STA	menuTrade1RemWealth + 1
		LDA	dialogTrdSelBakRWlthA + 2	
		STA	menuTrade1RemWealth + 2
		
		LDA	dialogTrdSelBakRCashA	;Restore r cash
		STA	menuTrade1RemCash
		LDA	dialogTrdSelBakRCashA + 1	
		STA	menuTrade1RemCash + 1
		
		JMP	@contD

@initD:
		LDA	dialogTrdSelBakRWlthI	;Restore r wealth
		STA	menuTrade0RemWealth	
		LDA	dialogTrdSelBakRWlthI + 1	
		STA	menuTrade0RemWealth + 1
		LDA	dialogTrdSelBakRWlthI + 2	
		STA	menuTrade0RemWealth + 2

		LDA	dialogTrdSelBakRCashI	;Restore r cash
		STA	menuTrade0RemCash
		LDA	dialogTrdSelBakRCashI + 1	
		STA	menuTrade0RemCash + 1
		
@contD:
		JSR	doDialogTrdSelClose
		JMP	@keysDong

@keysA:
		CMP	#'A'
		BNE	@keysU
		
		JSR	doDialogTrdSelPackData
		JSR	doDialogTrdSelClose
		JMP	@keysDong
		
@keysU:
		LDX	dialogTrdSelDoApprv
		BNE	@keysExit

		CMP	#'U'
		BNE	@keysI

		LDA	#100
		JSR	doDialogTrdSelAddCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		RTS

@keysI:
		CMP	#'I'
		BNE	@keysO

		LDA	#10
		JSR	doDialogTrdSelAddCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		RTS

@keysO:
		CMP	#'O'
		BNE	@keysJ
		
		LDA	#1
		JSR	doDialogTrdSelAddCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		RTS
		
@keysJ:
		CMP	#'J'
		BNE	@keysK

		LDA	#100
		JSR	doDialogTrdSelSubCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		RTS
		
@keysK:
		CMP	#'K'
		BNE	@keysL
		
		LDA	#10
		JSR	doDialogTrdSelSubCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		RTS
		
@keysL:
		CMP	#'L'
		BNE	@keysExit

		LDA	#1
		JSR	doDialogTrdSelSubCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		
@keysExit:
		RTS

@tstrwealth:
		LDA	dialogTrdSelDoApprv
		BEQ	@initial
		
		JSR	doDialogTrdSelSetRWlthA
		JSR	doDialogTrdSelSetRCashA
		LDA	menuTrade1RemWealth + 2
		BPL	@tstCashA
		
		JMP	@keysBell
		
@tstCashA:
		LDA	menuTrade1RemCash + 1
		BPL	@keysExit
		
		JMP	@keysBell
		
@initial:
		JSR	doDialogTrdSelSetRWlthI
		JSR	doDialogTrdSelSetRCashI
		LDA	menuTrade0RemWealth + 2
		BPL	@keysExit
		
		JMP	@keysBell
		
@tstCashI:
		LDA	menuTrade0RemCash + 1
		BPL	@keysExit
		
		JMP	@keysBell
		
@keysBell:
		LDA	#<SFXBELL
		LDY	#>SFXBELL
		LDX	#$07
		JSR	SNDBASE + 6
		RTS

@keysDing:
		LDA	#<SFXDING
		LDY	#>SFXDING
		LDX	#$07
		JSR	SNDBASE + 6
		RTS

@keysDong:
		LDA	#<SFXDONG
		LDY	#>SFXDONG
		LDX	#$07
		JSR	SNDBASE + 6
		RTS

@keysBuzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		RTS


dialogDlgTrdSel0Draw:
		JSR	screenBeginButtons
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial

		LDA	menuTrade1RemWealth	;Back up the remaining wealth
		STA	dialogTrdSelBakRWlthA	;in case its dismissed
		LDA	menuTrade1RemWealth + 1
		STA	dialogTrdSelBakRWlthA + 1	
		LDA	menuTrade1RemWealth + 2
		STA	dialogTrdSelBakRWlthA + 2

		LDA	menuTrade1RemCash	;Back up the remaining cash
		STA	dialogTrdSelBakRCashA	;in case its dismissed
		LDA	menuTrade1RemCash + 1
		STA	dialogTrdSelBakRCashA + 1	


		JMP	@begin

@initial:
		LDA	menuTrade0RemWealth	;Back up the remaining wealth
		STA	dialogTrdSelBakRWlthI	;in case its dismissed
		LDA	menuTrade0RemWealth + 1
		STA	dialogTrdSelBakRWlthI + 1	
		LDA	menuTrade0RemWealth + 2
		STA	dialogTrdSelBakRWlthI + 2

		LDA	menuTrade0RemCash	;Back up the remaining cash
		STA	dialogTrdSelBakRCashI	;in case its dismissed
		LDA	menuTrade0RemCash + 1
		STA	dialogTrdSelBakRCashI + 1	

@begin:
		LDY	#TRADE::player		
		LDA	trade2, Y
		
		TAX				;Get the maximum cash
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	dialogTrdSelMaxCash
		INY
		LDA	($FB), Y
		STA	dialogTrdSelMaxCash + 1
		
		BPL	@disp

		LDA	#$00
		STA	dialogTrdSelMaxCash
		STA	dialogTrdSelMaxCash + 1
		
@disp:
		LDA	#<dialogWindowTrdSel0
		STA	$FD
		LDA	#>dialogWindowTrdSel0
		STA	$FE

		JSR	screenPerformList
		
		LDA	#<dialogWindowOvervw1
		STA	$FD
		LDA	#>dialogWindowOvervw1
		STA	$FE
		
		JSR	screenPerformList


		LDA	dialogTrdSelDoApprv
		BNE	@repay
	
@select:	
		LDA	#<dialogWindowTrdSel2
		STA	$FD
		LDA	#>dialogWindowTrdSel2
		STA	$FE
		
		JSR	screenPerformList

@repay:
		LDA	dialogTrdSelDoElimin
		BNE	@dorepay

		LDA	dialogTrdSelDoRepay
		BEQ	@accept
		
@dorepay:
		LDA	#<dialogWindowTrdSel1
		STA	$FD
		LDA	#>dialogWindowTrdSel1
		STA	$FE
		
		JSR	screenPerformList

@accept:
		LDA	#<dialogWindowTrdSel4
		STA	$FD
		LDA	#>dialogWindowTrdSel4
		STA	$FE
		
		JSR	screenPerformList

		LDA	#<heap0
		STA	$A3
		LDA	#>heap0
		STA	$A4
		
		LDY	#$00
		STY	game + GAME::varH
		
		JSR	dialogTrdSel0CollateState

		LDA	#<heap0
		STA	$FD
		LDA	#>heap0
		STA	$FE
		
		JSR	screenPerformList
		
		LDA	dialogTrdSelDoElimin
		BNE	@skipcash

		LDA	#<dialogWindowTrdSel3
		STA	$FD
		LDA	#>dialogWindowTrdSel3
		STA	$FE
		
		JSR	screenPerformList
		
@skipcash:
		LDA	#$01
		STA	ui + UI::fWntJFB
		
		JSR	doDialogTrdSelSetState

		JSR	screenResetSelBtn
		
		LDA	#$00
		STA	game + GAME::fTrdSlL
		STA	game + GAME::sTrdSel

		JSR	doDialogTrdSelGetAddr
		JSR	doDialogTrdSelBckChar
		
		LDA	#$11
		STA	game + GAME::iStpCnt
		LDA	#$07
		STA	game + GAME::gMode
		
		RTS
		
		
dialogTrdSel0CollateState:
		LDA	#$01
		STA	dialogOvervwFiltOwn
		
		LDY	#TRADE::player
		LDA	trade0, Y
		STA	dialogOvervwPlr0
		
		LDA	trade1, Y
		STA	dialogOvervwPlr1
		
		JSR	dialogOvervwColOwn
		
		JSR	dialogOvervwColImprv
		JSR	dialogOvervwColMrtg
		
		LDA	#$00
		LDY	game + GAME::varH
		STA	($A3), Y
		INC	game + GAME::varH
		
		RTS
		

dialogWindowSqrInfo0:		
			.byte	$13, $0A, $02, $14, $14
			.byte	$46, $09, $01, $15
			.byte	$47, $0A, $16, $15
			.byte	$56, $09, $02, $14
			.byte	$57, $1E, $02, $15
			.byte	$6A, $1E, $01, $09, $16, $FF
			
			.byte	$2B, $09, $01, $15
			.byte	$2B, $0A, $16, $15
			.byte	$3B, $09, $02, $14
			.byte	$3B, $1E, $02, $15
			
			.byte	$90, $0B, $03
dialogWindowSqrInfoT0:
			.word		strDummyDummy0
			.byte	$90, $0B, $04
dialogWindowSqrInfoT1:
			.word		strDummyDummy0
			
			.byte 	$AF, $14, $0A, $1E, $20, $0D, $14
			.word		strDesc7Titles0

dialogWindowSqrInfoC0:
			.byte	$21, $0A, $02, $14
dialogWindowSqrInfoC1:
			.byte	$21, $0A, $03, $14
dialogWindowSqrInfoC2:
			.byte	$21, $0A, $04, $14
			
			.byte	$00
		
dialogStrSqrInfo0:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo1:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo2:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo3:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo4:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo5:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo6:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo7:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo8:
			.byte	$04, $A0, $A0, $A0, $A0
dialogStrSqrInfo9:
			.byte	$04, $A0, $A0, $A0, $A0
		
dialogWindowSqrInfo1:
			.byte 	$90, $0B, $06
			.word		strText0Street0
			.byte 	$90, $19, $06
			.word		dialogStrSqrInfo0
			.byte 	$90, $0B, $08
			.word		strText1Street0
			.byte 	$90, $19, $08
			.word		dialogStrSqrInfo1
			.byte 	$90, $0B, $09
			.word		strText2Street0
			.byte 	$90, $19, $09
			.word		dialogStrSqrInfo2
			.byte 	$90, $0B, $0A
			.word		strText3Street0
			.byte 	$90, $19, $0A
			.word		dialogStrSqrInfo3
			.byte 	$90, $0B, $0B
			.word		strText4Street0
			.byte 	$90, $19, $0B
			.word		dialogStrSqrInfo4
			.byte 	$90, $0B, $0C
			.word		strText5Street0
			.byte 	$90, $19, $0C
			.word		dialogStrSqrInfo5
			.byte 	$90, $0B, $0E
			.word		strText6Street0
			.byte 	$90, $19, $0E
			.word		dialogStrSqrInfo6
			.byte 	$90, $0B, $0F
			.word		strText7Street0
			.byte 	$90, $19, $0F
			.word		dialogStrSqrInfo7
			.byte 	$90, $0B, $10
			.word		strText8Street0
			.byte 	$90, $19, $10
			.word		dialogStrSqrInfo8
			.byte 	$90, $0B, $12
			.word		strText9Street0
			.byte 	$90, $19, $12
			.word		dialogStrSqrInfo9

			.byte 	$00

dialogWindowSqrInfo2:
			.byte 	$90, $0B, $06
			.word		strText0Street0
			.byte 	$90, $19, $06
			.word		dialogStrSqrInfo0
			.byte 	$90, $0B, $08
			.word		strText0Stn0
			.byte 	$90, $19, $08
			.word		dialogStrSqrInfo1
			.byte 	$90, $0B, $09
			.word		strText1Stn0
			.byte 	$90, $19, $09
			.word		dialogStrSqrInfo2
			.byte 	$90, $0B, $0A
			.word		strText2Stn0
			.byte 	$90, $19, $0A
			.word		dialogStrSqrInfo3
			.byte 	$90, $0B, $0E
			.word		strText6Street0
			.byte 	$90, $19, $0E
			.word		dialogStrSqrInfo6
			.byte 	$90, $0B, $0F
			.word		strText7Street0
			.byte 	$90, $19, $0F
			.word		dialogStrSqrInfo7
			.byte 	$90, $0B, $10
			.word		strText8Street0
			.byte 	$90, $19, $10
			.word		dialogStrSqrInfo8

			.byte 	$00
			

dialogWindowSqrInfo3:
			.byte 	$90, $0B, $06
			.word		strText0Util0
			.byte 	$90, $0B, $07
			.word		strText1Util0
			.byte 	$90, $0B, $09
			.word		strText2Util0
			.byte 	$90, $0B, $0A
			.word		strText3Util0
			.byte 	$90, $0B, $0E
			.word		strText6Street0
			.byte 	$90, $19, $0E
			.word		dialogStrSqrInfo6
			.byte 	$90, $0B, $0F
			.word		strText7Street0
			.byte 	$90, $19, $0F
			.word		dialogStrSqrInfo7
			.byte 	$90, $0B, $10
			.word		strText8Street0
			.byte 	$90, $19, $10
			.word		dialogStrSqrInfo8
			
			.byte 	$00
			

dialogWindowSqrInfo4:
			.byte 	$90, $0B, $06
dialogWindowSqrInfo40:
			.word		strDummyDummy0
			.byte 	$90, $0B, $07
dialogWindowSqrInfo41:
			.word		strDummyDummy0
			.byte 	$90, $0B, $08
dialogWindowSqrInfo42:
			.word		strDummyDummy0
			.byte 	$90, $0B, $09
dialogWindowSqrInfo43:
			.word		strDummyDummy0
			.byte 	$90, $0B, $0A
dialogWindowSqrInfo44:
			.word		strDummyDummy0

			.byte 	$00
			

doDialogSqrInfoGenTxt:
		LDY	#$00
		LDA	($A3), Y
		STA	dialogWindowSqrInfo40
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo40 + 1
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo41
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo41 + 1
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo42
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo42 + 1
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo43
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo43 + 1
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo44
		INY
		LDA	($A3), Y
		STA	dialogWindowSqrInfo44 + 1
		
		LDA	#<dialogWindowSqrInfo4
		STA	$3F
		LDA	#>dialogWindowSqrInfo4
		STA	$40
		
		RTS


doDialogSqrInfoCrnr:
		LDX	game + GAME::varC
		LDA	rulesSqrStrsLo, X
		STA	$A3
		LDA	rulesSqrStrsHi, X
		STA	$A4
		
		JSR	doDialogSqrInfoGenTxt

		RTS


doDialogSqrInfoChest:
		LDA	rulesSqrStrsLo + 4
		STA	$A3
		LDA	rulesSqrStrsHi + 4
		STA	$A4
		
		JSR	doDialogSqrInfoGenTxt

		RTS


doDialogSqrInfoChance:
		LDA	rulesSqrStrsLo + 5
		STA	$A3
		LDA	rulesSqrStrsHi + 5
		STA	$A4
		
		JSR	doDialogSqrInfoGenTxt

		RTS


doDialogSqrInfoTax:
		LDX	game + GAME::varC
		LDA	rulesSqrStrsLo + 6, X
		STA	$A3
		LDA	rulesSqrStrsHi + 6, X
		STA	$A4
		
		JSR	doDialogSqrInfoGenTxt

		RTS


doDialogSqrInfoGetVal:
		LDA	($FD), Y		;next value
		STA	Z:numConvVALUE
		INY
		LDA	($FD), Y
		STA	Z:numConvVALUE + 1
		INY

		TYA
		PHA

		JSR	numConvPRTSGN

		PLA
		TAY

		RTS
		

doDialogSqrInfoGetRepay:
		DEY
		DEY
		LDA	($FD), Y		;mValue
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		INY
		
		CLC
		LDA	($FD), Y		;mFee
		ADC	game + GAME::varD
		STA	Z:numConvVALUE
		INY
		LDA	($FD), Y
		ADC	game + GAME::varE
		STA	Z:numConvVALUE + 1
		INY
		
		TYA
		PHA

		JSR	numConvPRTSGN

		PLA
		TAY

		RTS
		

doDialogSqrInfoUtil:
		LDY	#UTILITY::pPurch
		
		JSR	doDialogSqrInfoGetVal	;market purchase
		
		LDX	#$03
@loop6:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo6 + 1, X
		DEX
		BPL	@loop6
		
		JSR	doDialogSqrInfoGetVal	;mortgage value
		
		LDX	#$03
@loop7:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo7 + 1, X
		DEX
		BPL	@loop7

		JSR	doDialogSqrInfoGetRepay	;mortgage repay
		
		LDX	#$03
@loop8:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo8 + 1, X
		DEX
		BPL	@loop8

		LDA	#<dialogWindowSqrInfo3
		STA	$3F
		LDA	#>dialogWindowSqrInfo3
		STA	$40
		
		RTS
		
		
		
doDialogSqrInfoStn:
		LDY	#STREET::mRent		;rent
		LDA	($FD), Y
		STA	game + GAME::varD
		
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1

		JSR	numConvPRTSGN
		
		LDX	#$03
@loop0:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo0 + 1, X
		DEX
		BPL	@loop0
		
		LDA	game + GAME::varD	;2 stations
		ASL
		STA	game + GAME::varD
		
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1

		JSR	numConvPRTSGN
		
		LDX	#$03
@loop1:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo1 + 1, X
		DEX
		BPL	@loop1
		
		LDA	game + GAME::varD	;3 stations
		ASL
		STA	game + GAME::varD
		
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1

		JSR	numConvPRTSGN
		
		LDX	#$03
@loop2:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo2 + 1, X
		DEX
		BPL	@loop2
		
		LDA	game + GAME::varD	;4 stations
		ASL
		STA	game + GAME::varD
		
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1

		JSR	numConvPRTSGN
		
		LDX	#$03
@loop3:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo3 + 1, X
		DEX
		BPL	@loop3

		LDY	#STATION::pPurch
		
		JSR	doDialogSqrInfoGetVal	;market purchase
		
		LDX	#$03
@loop6:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo6 + 1, X
		DEX
		BPL	@loop6
		
		JSR	doDialogSqrInfoGetVal	;mortgage value
		
		LDX	#$03
@loop7:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo7 + 1, X
		DEX
		BPL	@loop7

		JSR	doDialogSqrInfoGetRepay	;mortgage repay
		
		LDX	#$03
@loop8:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo8 + 1, X
		DEX
		BPL	@loop8

		LDA	#<dialogWindowSqrInfo2
		STA	$3F
		LDA	#>dialogWindowSqrInfo2
		STA	$40
		
		RTS
		
		
doDialogSqrInfoStreet:
		LDY	#STREET::mRent
		
		JSR	doDialogSqrInfoGetVal	;rent

		LDX	#$03
@loop0:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo0 + 1, X
		DEX
		BPL	@loop0

		JSR	doDialogSqrInfoGetVal	;1 house
		
		LDX	#$03
@loop1:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo1 + 1, X
		DEX
		BPL	@loop1

		JSR	doDialogSqrInfoGetVal	;2 houses
		
		LDX	#$03
@loop2:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo2 + 1, X
		DEX
		BPL	@loop2

		JSR	doDialogSqrInfoGetVal	;3 houses
		
		LDX	#$03
@loop3:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo3 + 1, X
		DEX
		BPL	@loop3

		JSR	doDialogSqrInfoGetVal	;4 houses
		
		LDX	#$03
@loop4:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo4 + 1, X
		DEX
		BPL	@loop4

		JSR	doDialogSqrInfoGetVal	;1 hotel
		
		LDX	#$03
@loop5:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo5 + 1, X
		DEX
		BPL	@loop5
		
		LDY	#STREET::pPurch
		
		JSR	doDialogSqrInfoGetVal	;market purchase
		
		LDX	#$03
@loop6:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo6 + 1, X
		DEX
		BPL	@loop6
		
		JSR	doDialogSqrInfoGetVal	;mortgage value
		
		LDX	#$03
@loop7:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo7 + 1, X
		DEX
		BPL	@loop7

		JSR	doDialogSqrInfoGetRepay	;mortgage repay
		
		LDX	#$03
@loop8:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo8 + 1, X
		DEX
		BPL	@loop8

		LDA	game + GAME::varA	;improvements
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		JSR	numConvPRTSGN

		LDX	#$03
@loop9:
		LDA	heap0 + 2, X
		ORA	#$80
		STA	dialogStrSqrInfo9 + 1, X
		DEX
		BPL	@loop9
		
		LDA	#<dialogWindowSqrInfo1
		STA	$3F
		LDA	#>dialogWindowSqrInfo1
		STA	$40
		
		RTS
		

dialogDlgSqrInfo0Draw:
		JSR	screenBeginButtons
		
		LDA	game + GAME::sSelect
		ASL
		TAX

		LDA	rulesSqr0 + 1, X	;index
		STA	game + GAME::varC
		
		LDA	rulesSqr0, X		;group
		STA	game + GAME::varB
		
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDY	#GROUP::colour
		LDA	($FD), Y
		ORA	#$20
		STA	dialogWindowSqrInfoC0
		STA	dialogWindowSqrInfoC1
		STA	dialogWindowSqrInfoC2
		
		LDY	#GROUP::pImprv
		LDA	($FD), Y
		STA	game + GAME::varA

		LDA	game + GAME::varC
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		STA	$FE
		PLA
		STA	$FD
		
		LDY	#CARD::sTitle0
		LDA	($FD), Y
		STA	dialogWindowSqrInfoT0
		INY
		LDA	($FD), Y
		STA	dialogWindowSqrInfoT0 + 1
		INY
		LDA	($FD), Y
		STA	dialogWindowSqrInfoT1
		INY
		LDA	($FD), Y
		STA	dialogWindowSqrInfoT1 + 1

		LDA	game + GAME::varB
		BNE	@tststreet
		
		JSR	doDialogSqrInfoCrnr
		JMP	@disp
		
@tststreet:
		CMP	#$09
		BPL	@tststn
		
		JSR	doDialogSqrInfoStreet
		JMP	@disp
		
@tststn:
		CMP	#$09
		BNE	@tstutil
		
		JSR	doDialogSqrInfoStn
		JMP	@disp
		
@tstutil:
		CMP	#$0A
		BNE	@tstchest
		
		JSR	doDialogSqrInfoUtil
		JMP	@disp
		
@tstchest:	
		CMP	#$0B
		BNE	@tstchance
		
		JSR	doDialogSqrInfoChest
		JMP	@disp
		
@tstchance:	
		CMP	#$0C
		BNE	@tax
		
		JSR	doDialogSqrInfoChance
		JMP	@disp
		
@tax:
		JSR	doDialogSqrInfoTax
		
@disp:
		LDA	#<dialogWindowSqrInfo0
		STA	$FD
		LDA	#>dialogWindowSqrInfo0
		STA	$FE
		
		JSR	screenPerformList
		
		LDA	$3F
		STA	$FD
		LDA	$40
		STA	$FE
		
		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS


dialogTempPStats0:
			.byte	$00

dialogStrPStats0:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats1:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats2:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats3:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats4:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats5:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats6:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats7:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats8:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
dialogStrPStats9:
			.byte	$06, $A0, $A0, $A0, $A0, $A0, $A0
		
dialogWindowPStats0:
			.byte 	$90, $0B, $06
			.word		strText0PStats0
			.byte 	$90, $17, $06
			.word		dialogStrPStats0
			.byte 	$90, $0B, $07
			.word		strText1PStats0
			.byte 	$90, $17, $07
			.word		dialogStrPStats1
			.byte 	$90, $0B, $09
			.word		strText2PStats0
			.byte 	$90, $17, $09
			.word		dialogStrPStats2
			.byte 	$90, $0B, $0A
			.word		strText3PStats0
			.byte 	$90, $17, $0A
			.word		dialogStrPStats3
			.byte 	$90, $0B, $0B
			.word		strText4PStats0
			.byte 	$90, $17, $0B
			.word		dialogStrPStats4
			.byte 	$90, $0B, $0C
			.word		strText5PStats0
			.byte 	$90, $17, $0C
			.word		dialogStrPStats5
			.byte 	$90, $0B, $0E
			.word		strText6PStats0
			.byte 	$90, $17, $0E
			.word		dialogStrPStats6
			.byte 	$90, $0B, $0F
			.word		strText7PStats0
			.byte 	$90, $17, $0F
			.word		dialogStrPStats7
			.byte 	$90, $0B, $10
			.word		strText8PStats0
			.byte 	$90, $17, $10
			.word		dialogStrPStats8
			.byte 	$90, $0B, $12
			.word		strText9PStats0
			.byte 	$90, $17, $12
			.word		dialogStrPStats9

			.byte 	$00


dialogDlgPStats0Draw:
		JSR	screenBeginButtons
		
		LDA	#$2F
		STA	dialogWindowSqrInfoC0
		LDA	#$21
		STA	dialogWindowSqrInfoC1
		LDA	#$23
		STA	dialogWindowSqrInfoC2
		
		
		LDX	menuPlyrSelSelect
		
		LDA	plrNameLo, X
		STA	dialogWindowSqrInfoT0
		LDA	plrNameHi, X
		STA	dialogWindowSqrInfoT0 + 1
		
		LDA	#<strDummyDummy0
		STA	dialogWindowSqrInfoT1
		LDA	#>strDummyDummy0
		STA	dialogWindowSqrInfoT1 + 1

		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	Z:numConvVALUE
		INY
		LDA	($FB), Y
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop0:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats0 + 1, X
		
		DEX
		BPL	@loop0

		LDY	#PLAYER::equity
		LDA	($FB), Y
		STA	Z:numConvVALUE
		INY
		LDA	($FB), Y
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop1:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats1 + 1, X
		
		DEX
		BPL	@loop1

		LDX	menuPlyrSelSelect

		LDA	#$00
		STA	Z:numConvVALUE
		STA	Z:numConvVALUE + 1
		
		CPX	game + GAME::pGF0Crd
		BNE	@gf1
		
		INC	Z:numConvVALUE
		
@gf1:
		CPX	game + GAME::pGF1Crd
		BNE	@dogf
		
		INC	Z:numConvVALUE
		
@dogf:
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop2:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats2 + 1, X
		
		DEX
		BPL	@loop2
		
		LDA	#$00
		STA	game + GAME::varA
		STA	game + GAME::varB
		STA	game + GAME::varC
		
		LDX	#$00
@loop3a:
		LDA	sqr00, X
		INX
		CMP	menuPlyrSelSelect
		BNE	@next3a
		
		INC	game + GAME::varC
		
		LDA	sqr00, X
		AND	#$07
		
		CLC
		ADC	game + GAME::varA
		STA	game + GAME::varA
		
		LDA	sqr00, X
		AND	#$08
		BEQ	@next3a
		
		INC	game + GAME::varB
		
@next3a:
		INX
		CPX	#$50
		BNE	@loop3a

		LDA	game + GAME::varA
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop3:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats3 + 1, X
		
		DEX
		BPL	@loop3

		LDA	game + GAME::varB
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop4:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats4 + 1, X
		
		DEX
		BPL	@loop4

		LDA	game + GAME::varC
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop5:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats5 + 1, X
		
		DEX
		BPL	@loop5

		LDY	#PLAYER::oGrp09
		LDA	($FB), Y
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop6:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats6 + 1, X
		
		DEX
		BPL	@loop6
		
		LDY	#PLAYER::oGrp0A
		LDA	($FB), Y
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop7:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats7 + 1, X
		
		DEX
		BPL	@loop7

		
		LDA	#PLAYER::oGrp01 
		STA	game + GAME::varA
		LDA	#$00
		STA	game + GAME::varB
		
		LDX	#$01
@loop8a:
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDY	#GROUP::count
		LDA	($FD), Y
		STA	game + GAME::varG	;deed count in group
		
		LDY	game + GAME::varA
		LDA	($FB), Y
		CMP	game + GAME::varG
		BNE	@next8a
		
		INC	game + GAME::varB
		
@next8a:
		INC	game + GAME::varA
		INX	
		CPX	#$0B
		BNE	@loop8a
		
		LDA	game + GAME::varB
		STA	Z:numConvVALUE
		LDA	#$00
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop8:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats8 + 1, X
		
		DEX
		BPL	@loop8

		LDX	menuPlyrSelSelect
		JSR	gameCalcPlayerScore
		
		LDA	game + GAME::varO
		STA	Z:numConvVALUE
		LDA	game + GAME::varP
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop9:
		LDA	heap0, X
		ORA	#$80
		STA	dialogStrPStats9 + 1, X
		
		DEX
		BPL	@loop9
		

@disp:
		LDA	#<dialogWindowSqrInfo0
		STA	$FD
		LDA	#>dialogWindowSqrInfo0
		STA	$FE

		JSR	screenPerformList
		
		LDA	#<dialogWindowPStats0
		STA	$FD
		LDA	#>dialogWindowPStats0
		STA	$FE

		JSR	screenPerformList
		
		JSR	screenResetSelBtn
		RTS


dialogWindowNullP:
			.byte	$02, $90, $A0
			
dialogWindowNullA:
			.byte	$07, $81, $00, $00, $00, $00, $00, $00

dialogWindowNull0:
			.byte	$90, $09, $06
			.word		strHeaderNull0
			
			.byte	$90, $09, $09
			.word		strText0Null0

			.byte	$90, $09, $0D
			.word		dialogWindowNullP
			
			.byte	$09, $0C, $0D
			.word		dialogWindowNullA

			.byte	$00


dialogDlgNull0Draw:
		LDA	cpuFaultPlayer
		CLC
		ADC	#$B0
		STA	dialogWindowNullP + 2

		LDA	cpuFaultAddr
		STA	Z:numConvVALUE
		LDA	cpuFaultAddr + 1
		STA	Z:numConvVALUE + 1
		
		JSR	numConvPRTSGN
		
		LDX	#$05
@loop9:
		LDA	heap0, X
		ORA	#$80
		STA	dialogWindowNullA + 2, X
		
		DEX
		BPL	@loop9


		LDA	#<dialogWindowNull0
		STA	$FD
		LDA	#>dialogWindowNull0
		STA	$FE
		
		JSR	screenPerformList

		JSR	screenResetSelBtn
		RTS

;===============================================================================
;FOR BOARD.S
;===============================================================================

;-------------------------------------------------------------------------------
boardDisplayQuad:
;-------------------------------------------------------------------------------
		STX	game + GAME::varL
		CPX	#$01
		BNE	@doFull
	
		JMP	@doSelState
		
@doFull:
		LDX	game + GAME::qVis
		LDA	boardQuadsLo, X
		STA	$FD
		LDA	boardQuadsHi, X
		STA	$FE
		
		JSR	screenPerformList

@doSelState:
		LDX	game + GAME::qVis
		LDA	#<heap0
		STA	$A3
		LDA	#>heap0
		STA	$A4
		
		LDA	#$00
		STA	game + GAME::varH

		JSR	boardCollateState

		LDA	#<heap0
		STA	$FD
		LDA	#>heap0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS
	
	
;-------------------------------------------------------------------------------
boardCollateState:
;-------------------------------------------------------------------------------
		CPX	#$00
		BNE	@test1

		JSR	boardCollateQ0
		JMP	@done
@test1:
		CPX	#$01
		BNE	@test2
		
		JSR	boardCollateQ1
		JMP	@done
		
@test2:
		CPX	#$02
		BNE	@test3
		
		JSR	boardCollateQ2
		JMP	@done
		
@test3:
		CPX	#$03
		BNE	@done

		JSR	boardCollateQ3
;		JMP	@done
		
		
@done:
		LDA	#$00
		LDY	game + GAME::varH
		STA	($A3), Y
		INC	game + GAME::varH
		
		RTS


;-------------------------------------------------------------------------------
boardCollateQ0:
;-------------------------------------------------------------------------------
		LDA	#<boardQ0SqrOffs
		STA	$FB
		LDA	#>boardQ0SqrOffs
		STA	$FC

		LDA	#<boardQ0HSqr00
		STA	$FD
		LDA	#>boardQ0HSqr00
		STA	$FE
		
		LDA	#$00
		STA	game + GAME::varJ
		STA	game + GAME::varK
		
		LDX	#$00
		
@loopH:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateHSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$06
		BNE	@loopH
		
		LDA	#<boardQ0VSqr23
		STA	$FD
		LDA	#>boardQ0VSqr23
		STA	$FE

		LDA	#$00
;		STA	game + GAME::varJ
		STA	game + GAME::varK
		
		LDX	#$23

@loopV:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateVSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$28
		BNE	@loopV
		
		RTS
		
;------------------------------------------------------------------------------
;boardCollateQ1
;------------------------------------------------------------------------------
boardCollateQ1:
		LDA	#<boardQ1SqrOffs
		STA	$FB
		LDA	#>boardQ1SqrOffs
		STA	$FC
		
		LDA	#<boardQ1HSqr05
		STA	$FD
		LDA	#>boardQ1HSqr05
		STA	$FE

		LDA	#$00	
		STA	game + GAME::varJ
		STA	game + GAME::varK
		
		LDX	#$05
		
@loopH:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateHSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$0B
		BNE	@loopH
		
		LDA	#<boardQ1VSqr0B
		STA	$FD
		LDA	#>boardQ1VSqr0B
		STA	$FE

		LDA	#$00
		STA	game + GAME::varK

		LDA	#$01
		STA	game + GAME::varJ
		
		LDX	#$0B

@loopV:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateVSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$10
		BNE	@loopV
		
		RTS
		
		
;------------------------------------------------------------------------------
;boardCollateQ2
;------------------------------------------------------------------------------
boardCollateQ2:
		LDA	#<boardQ2SqrOffs
		STA	$FB
		LDA	#>boardQ2SqrOffs
		STA	$FC
		
		LDA	#<boardQ2HSqr14
		STA	$FD
		LDA	#>boardQ2HSqr14
		STA	$FE

		LDA	#$00
		STA	game + GAME::varK

		LDA	#$01	
		STA	game + GAME::varJ

		LDX	#$14
		
@loopH:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateHSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$1A
		BNE	@loopH
		
		LDA	#<boardQ2VSqr0F
		STA	$FD
		LDA	#>boardQ2VSqr0F
		STA	$FE

		LDA	#$00
		STA	game + GAME::varK

		LDA	#$01
		STA	game + GAME::varJ
		
		LDX	#$0F

@loopV:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateVSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$14
		BNE	@loopV
		
		RTS
		
		
;------------------------------------------------------------------------------
;boardCollateQ3
;------------------------------------------------------------------------------
boardCollateQ3:
		LDA	#<boardQ3SqrOffs
		STA	$FB
		LDA	#>boardQ3SqrOffs
		STA	$FC
		
		LDA	#<boardQ3HSqr19
		STA	$FD
		LDA	#>boardQ3HSqr19
		STA	$FE

		LDA	#$00
		STA	game + GAME::varK

		LDA	#$01	
		STA	game + GAME::varJ

		LDX	#$19
		
@loopH:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateHSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$1F
		BNE	@loopH
		
		LDA	#<boardQ3VSqr1F
		STA	$FD
		LDA	#>boardQ3VSqr1F
		STA	$FE

		LDA	#$00
		STA	game + GAME::varK

;		LDA	#$00
		STA	game + GAME::varJ
		
		LDX	#$1F

@loopV:
		STX	game + GAME::varG
		TXA
		ASL
		STA	game + GAME::varI
		
		JSR	boardCollateVSqr
		
		INC	game + GAME::varK
		INC	game + GAME::varK
		
		LDX	game + GAME::varG
		INX
		CPX	#$24
		BNE	@loopV
		
		RTS
		

;------------------------------------------------------------------------------
;boardCollateHSqr
;------------------------------------------------------------------------------
boardCollateHSqr:		
		LDY	#$00			;set up mrtg points (get Y)
		LDA	($FB), Y
		STA	game + GAME::varB
		
		LDY	game + GAME::varK	;get X
		LDA	($FD), Y
		STA	game + GAME::varA	;This gets up mrtg pt
		
		LDA	#$04			;default height
		STA	game + GAME::varC
		
		INY				;Check height
		LDA	($FD), Y
		CMP	#$FF
		BNE	@1
		
		INC	game + GAME::varC
		
@1:
		LDX	game + GAME::varL
		CPX	#$01
		BNE	@doAll

		JSR	boardGenMrtgSelH
		JMP	@exit
		
@doAll:
		LDX	#$00
		JSR	boardGenMrtgSelH
		JSR	boardGenAllH
		JSR	boardGenOwnH
		JSR	boardGenImprvH

@exit:
		RTS
		
		
;------------------------------------------------------------------------------
;boardCollateVSqr
;------------------------------------------------------------------------------
boardCollateVSqr:
		LDY	#$01			;set up mrtg points (get X)
		LDA	($FB), Y
		STA	game + GAME::varA
		
		LDY	game + GAME::varK	;get Y
		LDA	($FD), Y
		STA	game + GAME::varB	;This gets up mrtg pt
		
		LDA	#$04			;default height
		STA	game + GAME::varC
		
		INY				;Check height
		LDA	($FD), Y
		CMP	#$FF
		BNE	@1
		
		INC	game + GAME::varC
		
@1:
		LDX	game + GAME::varL
		CPX	#$01
		BNE	@doAll

		JSR	boardGenMrtgSelV
		JMP	@exit
		
@doAll:
		LDX	#$00
		JSR	boardGenMrtgSelV
		JSR	boardGenAllV
		JSR	boardGenOwnV
		JSR	boardGenImprvV
		
@exit:
		RTS
		
		
;------------------------------------------------------------------------------
;boardGenAllH
;------------------------------------------------------------------------------
boardGenAllH:
		LDX	game + GAME::varI	;get imprv
		INX
		LDA	sqr00, X
		
		AND	#$40
		BEQ	@done
		
		LDA	#$45			;compute command for own
		LDY	game + GAME::varH	;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
		LDA	game + GAME::varA	;get X
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
		LDA	game + GAME::varJ	;check orientation
		BEQ	@1
		
		LDX	game + GAME::varB	;Get Y Pos for own
		DEX
		TXA
		JMP	@cont
		
@1:
		LDA	game + GAME::varB	;Get Y Pos for own
		CLC
		ADC	#$05			;
		
@cont:
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
						
		LDA	#$03			;width
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
@done:
		RTS
		
;------------------------------------------------------------------------------
;boardGenAllV
;------------------------------------------------------------------------------
boardGenAllV:
		LDX	game + GAME::varI	;get imprv
		INX
		LDA	sqr00, X
		
		AND	#$40
		BEQ	@done
		
		LDA	#$55			;compute command for own
		LDY	game + GAME::varH	;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
		LDA	game + GAME::varJ	;check orientation
		BEQ	@1
		
		LDX	game + GAME::varA	;Get X Pos for own
		DEX
		TXA
		JMP	@cont
		
@1:
		LDA	game + GAME::varA	;Get X Pos for own
		CLC
		ADC	#$05			;
		
@cont:
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
						
		LDA	game + GAME::varB	;get Y
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
		LDA	#$03			;height
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
@done:
		RTS
		
;------------------------------------------------------------------------------
;boardGenOwnH
;------------------------------------------------------------------------------
boardGenOwnH:
		LDX	game + GAME::varI	;get owner player
		LDA	sqr00, X
		
		CMP	#$FF
		BEQ	@done
		
		STA	game + GAME::varD
		
		TAX				;get owner colour
		LDA	plrLo, X
		STA	$A7
		LDA	plrHi, X
		STA	$A8
		
		LDY	#PLAYER::colour
		LDA	($A7), Y
		
		ORA	#$20			;compute command for own
		LDY	game + GAME::varH	;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
		LDA	game + GAME::varA	;get X
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
		LDA	game + GAME::varJ	;check orientation
		BEQ	@1
		
		LDX	game + GAME::varB	;Get Y Pos for own
		DEX
		TXA
		JMP	@cont
		
@1:
		LDA	game + GAME::varB	;Get Y Pos for own
		CLC
		ADC	#$05			;
		
@cont:
		
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
						
		LDA	#$03			;width
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
@done:
		RTS

;------------------------------------------------------------------------------
;boardGenOwnV
;------------------------------------------------------------------------------
boardGenOwnV:
		LDX	game + GAME::varI	;get owner player
		LDA	sqr00, X
		
		CMP	#$FF
		BEQ	@done
		
		STA	game + GAME::varD
		
		TAX				;get owner colour
		LDA	plrLo, X
		STA	$A7
		LDA	plrHi, X
		STA	$A8
		
		LDY	#PLAYER::colour
		LDA	($A7), Y
		
		ORA	#$30			;compute command for own
		LDY	game + GAME::varH	;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
		LDA	game + GAME::varJ	;check orientation
		BEQ	@1
		
		LDX	game + GAME::varA	;Get X Pos for own
		DEX
		TXA
		JMP	@cont
		
@1:
		LDA	game + GAME::varA	;Get X Pos for own
		CLC
		ADC	#$05			;
		
@cont:
		
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
						
		LDA	game + GAME::varB	;get Y
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH

		LDA	#$03			;height
		INY				;store on heap
		STA	($A3), Y
		INC	game + GAME::varH
		
@done:
		RTS
		
		
;------------------------------------------------------------------------------
;boardGenMrtgSelH
;------------------------------------------------------------------------------
boardGenMrtgSelH:
		LDX	game + GAME::varI	;get imprv

		LDA	sqr00 + 1, X
		AND	#$A0
		BNE	@doClr

		LDY	game + GAME::varL
		BNE	@begin
		
		JMP	@done
		
@begin:
		LDA	#$33
		JMP	@cont0

@doClr:
		LDA	sqr00 + 1, X
		AND	#$20
		BEQ	@mrtg
		
		LDA	sqr00 + 1, X
		AND	#$80
		BNE	@mrtgsel
		
		LDA	#$31
		JMP 	@cont0
@mrtgsel:
		LDA	#$3F
		JMP 	@cont0
		
@mrtg:
		LDA	#$3B
		
@cont0:
		STA	game + GAME::varF

		LDA	game + GAME::varG
		BEQ	@chkcnr
		
		CMP	#$0A
		BEQ	@chkcnr
		
		CMP	#$14
		BEQ	@chkcnr
		
		CMP	#$1E
		BEQ	@chkcnr
		
		LDA	#$03
		JMP	@cont1

@chkcnr:
		LDA	#$05

@cont1:
		STA	$A7
		
		LDA	game + GAME::varB	;compute y
		STA	game + GAME::varE
		
		LDA	game + GAME::varC
		CMP	#$05
		BEQ	@1
		
		LDA	game + GAME::varJ	;check orientation
		BNE	@1
		
		INC	game + GAME::varE	
		
@1:
		LDA	game + GAME::varA	;copy x
		STA	game + GAME::varD	
		
		LDY	game + GAME::varH
		LDX	#$00
@loop:
		LDA	game + GAME::varF	;store cmd on heap
		STA	($A3), Y
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varD	;store x on heap and next
		INC	game + GAME::varD
		STA	($A3), Y
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varE	;store y on heap
		STA	($A3), Y
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varC	;store h on heap
		STA	($A3), Y
		INC	game + GAME::varH
		INY

		INX
	
		CPX	$A7
		BNE	@loop

@done:
		RTS


;------------------------------------------------------------------------------
;boardGenMrtgSelV
;------------------------------------------------------------------------------
boardGenMrtgSelV:
		LDX	game + GAME::varI	;get imprv

		LDA	sqr00 + 1, X
		AND	#$A0
		BNE	@doClr

		LDY	game + GAME::varL
		BNE	@begin
		
		JMP	@done
		
@begin:
		
		LDA	#$23
		JMP	@cont0

@doClr:
		LDA	sqr00 + 1, X
		AND	#$20
		BEQ	@mrtg
		
		LDA	sqr00 + 1, X
		AND	#$80
		BNE	@mrtgsel
		
		LDA	#$21
		JMP 	@cont0
@mrtgsel:
		LDA	#$2F
		JMP 	@cont0
		
@mrtg:
		LDA	#$2B
		
@cont0:
		STA	game + GAME::varF

		LDA	game + GAME::varG
		BEQ	@chkcnr
		
		CMP	#$0A
		BEQ	@chkcnr
		
		CMP	#$14
		BEQ	@chkcnr
		
		CMP	#$1E
		BEQ	@chkcnr
		
		LDA	#$03
		JMP	@cont1

@chkcnr:
		LDA	#$05

@cont1:
		STA	$A7
		
		LDA	game + GAME::varA	;compute x
		STA	game + GAME::varD
		
		LDA	game + GAME::varC
		CMP	#$05
		BEQ	@1
		
		LDA	game + GAME::varJ	;check orientation
		BNE	@1
		
		INC	game + GAME::varD	
		
@1:
		LDA	game + GAME::varB	;copy y
		STA	game + GAME::varE	
		
		LDY	game + GAME::varH
		LDX	#$00
@loop:
		LDA	game + GAME::varF	;store cmd on heap
		STA	($A3), Y
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varD	;store x on heap and next
		STA	($A3), Y
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varE	;store y on heap
		INC	game + GAME::varE
		STA	($A3), Y
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varC	;store W on heap
		STA	($A3), Y
		INC	game + GAME::varH
		INY

		INX
	
		CPX	$A7
		BNE	@loop

@done:
		RTS
		
		
;------------------------------------------------------------------------------
;boardGenImprvH
;------------------------------------------------------------------------------
boardGenImprvH:
		LDX	game + GAME::varI	;get imprv
		LDA	sqr00  + 1, X

		AND	#$0F
		BNE	@test
		RTS
	
@test:
		STA	game + GAME::varF
		
		LDY	game + GAME::varK	;get imprv X
		INY
		LDA	($FD), Y
		
		CMP	#$FF
		BNE	@begin
		RTS
		
@begin:
		STA	game + GAME::varD
		
		LDA	game + GAME::varB
		STA	game + GAME::varE
		
		LDA	game + GAME::varJ	;check orientation
		BEQ	@cont0

;		DEC	game + GAME::varE
;		JMP	@cont0

@1:
		CLC
		LDA	#$04
		ADC	game + GAME::varE
		STA	game + GAME::varE

@cont0:
		JMP	boardGenImprvPerf
		

;------------------------------------------------------------------------------
;boardGenImprvV
;------------------------------------------------------------------------------
boardGenImprvV:
		LDX	game + GAME::varI	;get imprv
		LDA	sqr00 + 1, X

		AND	#$0F
		BNE	@test
		RTS
	
@test:
		STA	game + GAME::varF
		
		LDY	game + GAME::varK	;get imprv Y
		INY
		LDA	($FD), Y
		
		CMP	#$FF
		BNE	@begin
		RTS
		
@begin:
		STA	game + GAME::varE
		
		LDA	game + GAME::varA
		STA	game + GAME::varD
		
		LDA	game + GAME::varJ	;check orientation
		BEQ	@cont0

;		DEC	game + GAME::varE
;		JMP	@cont0

@1:
		CLC
		LDA	#$04
		ADC	game + GAME::varD
		STA	game + GAME::varD

@cont0:
		JMP	boardGenImprvPerf
		
		
		
;------------------------------------------------------------------------------
;boardGenImprvPerf
;------------------------------------------------------------------------------
boardGenImprvPerf:
		LDY	game + GAME::varH

		LDA	game + GAME::varF
		CMP	#$08
		BPL	@hotelclr
		
		LDA	#$2D
		JMP	@draw
@hotelclr:
		LDA	#$2A

@draw:
		STA	($A3), Y		;store cmd on heap
		INC	game + GAME::varH
		INY

		LDA	game + GAME::varD	;get x
		STA	($A3), Y		;store x on heap
		INC	game + GAME::varH
		INY
		LDA	game + GAME::varE	;get y
		STA	($A3), Y		;store y on heap
		INC	game + GAME::varH
		INY
		
		LDA	#$01
		STA	($A3), Y		;store w on heap
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varF
		CMP	#$08
		BPL	@hotelchr
		
		AND	#$07
		CLC
		ADC	#$04
		
		JMP	@cont1
		
@hotelchr:
		LDA	#$09
	
@cont1:
		ORA	#$60
		STA	($A3), Y		;store cmd on heap
		INC	game + GAME::varH
		INY
		
		LDA	game + GAME::varD	;get x
		STA	($A3), Y		;store x on heap
		INC	game + GAME::varH
		INY
		LDA	game + GAME::varE	;get y
		STA	($A3), Y		;store y on heap
		INC	game + GAME::varH
		INY
		
		LDA	#$FF
		STA	($A3), Y		;store term on heap
		INC	game + GAME::varH
		
@done:
		RTS


;------------------------------------------------------------------------------
;game board description
;------------------------------------------------------------------------------
boardQuad0:
			.byte	$10, $13, $00, $14, $14		;clear
			.byte	$41, $13, $13, $14		;outside h line
			.byte	$41, $13, $0E, $14		;inside h line
			.byte 	$41, $22, $02, $05		;square h lines
			.byte	$41, $22, $05, $05
			.byte	$41, $22, $08, $05
			.byte	$41, $22, $0B, $05
			.byte	$50, $26, $00, $14		;outside v line
			.byte   $50, $21, $00, $14		;inside v line
			.byte	$50, $15, $0F, $05		;square v lines
			.byte	$50, $18, $0F, $05
			.byte	$50, $1B, $0F, $05
			.byte	$50, $1E, $0F, $05
			.byte	$43, $19, $10, $03		;square brown h line
			.byte   $43, $1F, $10, $03		;	"
			.byte	$52, $23, $06, $03		;square blue v line
			.byte	$52, $23, $0C, $03		;	"
			.byte	$63, $26, $02, $26, $05		;corners outside
			.byte	     $26, $08, $26, $0B
			.byte	     $26, $0E, $26, $13
			.byte	     $21, $13, $1E, $13
			.byte	     $1B, $13, $18, $13
			.byte	     $15, $13, $21, $0E, $FF
			.byte	$61, $1B, $10, $21, $10, $FF    ;corners brown
			.byte   $62, $23, $0E, $23, $08, $FF	;corners blue
			.byte	$29, $19, $0F, $03		;colour brown
			.byte   $29, $1F, $0F, $03		;	"
			.byte	$36, $22, $06, $03		;colour blue
			.byte	$36, $22, $0C, $03		;	"
 			.byte	$70, $13, $10
			.byte	$70, $23, $00
			.byte	$71, $23, $04
			.byte	$72, $23, $0A
			.byte	$73, $17, $10
			.byte 	$74, $1D, $10
			.byte	$75, $23, $11
			.byte   $2B, $13, $14, $15		;colour surround
 			.byte   $3B, $27, $00, $15		;	"
 			.byte   $44, $13, $14, $15		;surround h line
 			.byte   $54, $27, $00, $15		;surround v line
			.byte	$00
boardQuad1:
			.byte	$10, $14, $00, $14, $14		;clear
			.byte	$41, $14, $13, $14		;outside h line
			.byte	$41, $14, $0E, $14		;inside h line
 			.byte 	$41, $14, $02, $05		;square h lines
 			.byte	$41, $14, $05, $05
 			.byte	$41, $14, $08, $05
 			.byte	$41, $14, $0B, $05
			.byte	$52, $14, $00, $14		;outside v line
			.byte   $52, $19, $00, $14		;inside v line
			.byte	$52, $1C, $0F, $05		;square v lines
			.byte	$52, $1F, $0F, $05
			.byte	$52, $22, $0F, $05
			.byte	$52, $25, $0F, $05
			.byte	$43, $19, $10, $06		;square blue h lines
			.byte   $43, $22, $10, $03		;	"
			.byte	$50, $17, $03, $06		;square purple v lines
			.byte	$50, $17, $0C, $03		;	"
			.byte	$62, $14, $02, $14, $05		;corners outside
			.byte	     $14, $08, $14, $0B
			.byte	     $14, $0E, $14, $13
			.byte	     $19, $13, $1C, $13
			.byte	     $1F, $13, $22, $13
			.byte	     $25, $13, $19, $0E, $FF
			.byte	$60, $19, $10, $1C, $10         ;corners blue
			.byte	     $22, $10, $FF
			.byte   $63, $17, $05, $17, $08		;corners purple			
			.byte	     $17, $0E, $FF
			.byte	$2E, $19, $0F, $06		;colour blue
			.byte   $2E, $22, $0F, $03		;	"
			.byte	$34, $18, $03, $06		;colour purple
			.byte	$34, $18, $0C, $03		;	"
 			.byte	$70, $16, $00
			.byte	$70, $26, $10
			.byte	$76, $15, $0A
			.byte	$77, $20, $10
			.byte	$7B, $16, $0F
			.byte   $2B, $13, $14, $15		;colour surround
 			.byte   $3B, $13, $00, $15		;	"
 			.byte   $44, $13, $14, $15		;surround h line
 			.byte   $54, $13, $00, $15		;surround v line
			.byte	$00

boardQuad2:
			.byte	$10, $14, $01, $14, $14

			.byte	$43, $14, $01, $14		;outside h line
			.byte	$43, $14, $06, $14		;inside h line
 			.byte 	$43, $14, $09, $05		;square h lines
 			.byte	$43, $14, $0C, $05
 			.byte	$43, $14, $0F, $05
 			.byte	$43, $14, $12, $05
			.byte	$52, $14, $01, $14		;outside v line
			.byte   $52, $19, $01, $14		;inside v line
			.byte	$52, $1C, $01, $05		;square v lines
			.byte	$52, $1F, $01, $05
			.byte	$52, $22, $01, $05
			.byte	$52, $25, $01, $05

			.byte	$41, $19, $04, $03		;square red h lines
			.byte   $41, $1F, $04, $06		;	"
			.byte	$50, $17, $06, $06		;square orange v lines
			.byte	$50, $17, $0F, $03		;	"

			.byte	$60, $14, $01, $14, $06		;corners outside
			.byte	     $14, $09, $14, $0C
			.byte	     $14, $0F, $14, $12
			.byte	     $19, $01, $1C, $01
			.byte	     $1F, $01, $22, $01
			.byte	     $25, $01, $19, $06, $FF
			.byte	$62, $19, $04, $1F, $04         ;corners red
			.byte	     $22, $04, $FF
			.byte   $61, $17, $06, $17, $09		;corners orange
			.byte	     $17, $0F, $FF

			.byte	$22, $19, $05, $03		;colour red
			.byte   $22, $1F, $05, $06		;	"
			.byte	$38, $18, $06, $06		;colour orange
			.byte	$38, $18, $0F, $03		;	"

			.byte	$70, $16, $13
			.byte	$70, $26, $03
			.byte	$77, $1D, $02
			.byte	$78, $15, $0D
			.byte	$79, $15, $02

 			.byte   $2B, $13, $00, $15		;colour surround
 			.byte   $3B, $13, $00, $15		;	"
			.byte   $44, $13, $00, $15		;surround h line
 			.byte   $54, $13, $00, $15		;surround v line
			.byte	$00

boardQuad3:
			.byte	$10, $13, $01, $14, $14

			.byte	$43, $13, $01, $14		;outside h line
			.byte	$43, $13, $06, $14		;inside h line
 			.byte 	$43, $22, $09, $05		;square h lines
 			.byte	$43, $22, $0C, $05
 			.byte	$43, $22, $0F, $05
 			.byte	$43, $22, $12, $05
			.byte	$50, $26, $01, $14		;outside v line
			.byte   $50, $21, $01, $14		;inside v line
			.byte	$50, $15, $01, $05		;square v lines
			.byte	$50, $18, $01, $05
			.byte	$50, $1B, $01, $05
			.byte	$50, $1E, $01, $05

			.byte	$41, $16, $04, $06		;square yellow h 
			.byte   $41, $1F, $04, $03		;	"
			.byte	$52, $23, $06, $06		;square green v 
			.byte	$52, $23, $0F, $03		;	"

			.byte	$61, $26, $01, $26, $06		;corners outside
			.byte	     $26, $09, $26, $0C
			.byte	     $26, $0F, $26, $12
			.byte	     $15, $01, $18, $01
			.byte	     $1B, $01, $1E, $01
			.byte	     $21, $01, $21, $06, $FF
			
			.byte	$63, $18, $04, $1B, $04         ;corners yellow
			.byte	     $21, $04, $FF
			.byte   $60, $23, $06, $23, $09		;corners green
			.byte	     $23, $0F, $FF

			.byte	$27, $16, $05, $06		;colour yellow
			.byte   $27, $1F, $05, $03		;	"
			.byte	$35, $22, $06, $06		;colour green
			.byte	$35, $22, $0F, $03		;	"

			.byte	$70, $13, $03
			.byte 	$70, $23, $13
			.byte	$78, $23, $0D
			.byte	$7A, $1C, $02
			.byte	$7C, $22, $02

			.byte   $2B, $13, $00, $15		;colour surround
 			.byte   $3B, $27, $00, $15		;	"
 			.byte   $44, $13, $00, $15		;surround h line
 			.byte   $54, $27, $00, $15		;surround v line
			.byte	$00
		
boardQuadsLo:
			.byte 	<boardQuad0, <boardQuad1
			.byte 	<boardQuad2, <boardQuad3
			
boardQuadsHi:
			.byte 	>boardQuad0, >boardQuad1
			.byte 	>boardQuad2, >boardQuad3
			
;		SQRQUAD
;		pSqrHY 	.byte
;		pSqrVX	.byte

boardQ0SqrOffs:
			.byte	$0F, $22
boardQ1SqrOffs:
			.byte	$0F, $14
boardQ2SqrOffs:
			.byte	$01, $14
boardQ3SqrOffs:
			.byte	$01, $22

;		SQUARE
;		pSqrA	.byte
;		pImprvA	.byte

boardQ0HSqr00:
			.byte	$22 
			.byte	$FF
boardQ0HSqr01:
			.byte	$1F 
			.byte	$1F
boardQ0HSqr02:
			.byte	$1C 
			.byte	$FF
boardQ0HSqr03:
			.byte	$19 
			.byte	$19
boardQ0HSqr04:
			.byte	$16 
			.byte	$FF
boardQ0HSqr05:
			.byte	$13 
			.byte	$FF
		
boardQ0VSqr23:
			.byte	$00 
			.byte	$FF
boardQ0VSqr24:
			.byte	$03 
			.byte	$FF
boardQ0VSqr25:
			.byte	$06 
			.byte	$06
boardQ0VSqr26:
			.byte	$09 
			.byte	$FF
boardQ0VSqr27:
			.byte	$0C 
			.byte	$0C

boardQ1HSqr05:
			.byte	$25 
			.byte	$FF
boardQ1HSqr06:
			.byte	$22 
			.byte	$24
boardQ1HSqr07:
			.byte	$1F 
			.byte	$FF
boardQ1HSqr08:
			.byte	$1C 
			.byte	$1E
boardQ1HSqr09:
			.byte	$19 
			.byte	$1B
boardQ1HSqr0A:
			.byte	$14 
			.byte	$FF

boardQ1VSqr0B:
			.byte	$0C 
			.byte	$0C
boardQ1VSqr0C:
			.byte	$09 
			.byte	$FF
boardQ1VSqr0D:
			.byte	$06 
			.byte	$06
boardQ1VSqr0E:
			.byte	$03 
			.byte	$03
boardQ1VSqr0F:
			.byte	$00 
			.byte	$FF

boardQ2HSqr14:
			.byte	$14 
			.byte	$FF
boardQ2HSqr15:
			.byte	$19 
			.byte	$1B
boardQ2HSqr16:
			.byte	$1C 
			.byte	$FF
boardQ2HSqr17:
			.byte	$1F
			.byte	$21
boardQ2HSqr18:
			.byte	$22
			.byte	$24
boardQ2HSqr19:
			.byte	$25 
			.byte	$FF

boardQ2VSqr0F:
			.byte	$12
			.byte	$FF
boardQ2VSqr10:
			.byte	$0F
			.byte	$11
boardQ2VSqr11:
			.byte	$0C 
			.byte	$FF
boardQ2VSqr12:
			.byte	$09 
			.byte	$0B
boardQ2VSqr13:
			.byte	$06
			.byte	$08
			
boardQ3HSqr19:
			.byte	$13
			.byte	$FF
boardQ3HSqr1A:
			.byte	$16
			.byte	$16
boardQ3HSqr1B:
			.byte	$19
			.byte	$19
boardQ3HSqr1C:
			.byte	$1C
			.byte	$FF
boardQ3HSqr1D:
			.byte	$1F
			.byte	$1F
boardQ3HSqr1E:
			.byte	$22
			.byte	$FF

boardQ3VSqr1F:
			.byte	$06
			.byte	$08
boardQ3VSqr20:
			.byte	$09
			.byte	$0B
boardQ3VSqr21:
			.byte	$0C
			.byte	$FF
boardQ3VSqr22:
			.byte	$0F
			.byte	$11
boardQ3VSqr23:
			.byte	$12
			.byte	$FF


;==============================================================================
;FOR RULES.S
;==============================================================================

rulesPriMrtg:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00
rulesPriAll:
		.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00
rulesSqrImprv:
	.repeat	40, I
		.byte	$00
	.endrep

rulesChestCrds0:
			.byte	$00, $00, $00, $00, $00, $00, $00, $00 
			.byte	$00, $00, $00, $00, $00, $00, $00, $00
rulesChanceCrds0:
			.byte	$00, $00, $00, $00, $00, $00, $00, $00
			.byte	$00, $00, $00, $00, $00, $00, $00, $00
rulesChestIdx:
			.byte	$00
rulesChanceIdx:	
			.byte	$00



	.include	"rules.inc"
	
	
rulesCCCrdProcsLo:
			.byte	<rulesCCCrdProcDummy	;none
			.byte	<rulesCCCrdProcInc	;get cash
			.byte	<rulesCCCrdProcAdv	;adv to
			.byte	<rulesCCCrdProcRep	;street/gen repairs
			.byte	<rulesCCCrdProcCol	;collect from all players
			.byte	<rulesCCCrdProcGGL	;go gaol
			.byte	<rulesCCCrdProcPay	;pay cash
			.byte	<rulesCCCrdProcGGF	;get out free
			.byte	<rulesCCCrdProcAST	;adv to station pay dbl
			.byte	<rulesCCCrdProcGBk	;go back spaces
			.byte	<rulesCCCrdProcBrb	;pay all players
			.byte	<rulesCCCrdProcAUT	;adv to util pay 10x

rulesCCCrdProcsHi:
			.byte	>rulesCCCrdProcDummy	;none
			.byte	>rulesCCCrdProcInc	;get cash
			.byte	>rulesCCCrdProcAdv	;adv to
			.byte	>rulesCCCrdProcRep	;street/gen repairs
			.byte	>rulesCCCrdProcCol	;collect from all players
			.byte	>rulesCCCrdProcGGL	;go gaol
			.byte	>rulesCCCrdProcPay	;pay cash
			.byte	>rulesCCCrdProcGGF	;get out free
			.byte	>rulesCCCrdProcAST	;adv to station pay dbl
			.byte	>rulesCCCrdProcGBk	;go back spaces
			.byte	>rulesCCCrdProcBrb	;pay all players
			.byte	>rulesCCCrdProcAUT	;adv to util pay 10x



;-------------------------------------------------------------------------------
;rulesGenRnd0F
;-------------------------------------------------------------------------------
rulesGenRnd0F:
;***FIXME:  I can't quite recall how I came up with the algorythm used 
;	here.  It attempts to divide the random value (0-255) down to the range 
;	(0-15).  There was an issue, however.  Values above 15 were being
;	generated.  Initially I expected only 16 however 17 seems to occur.  I
;	think this may be bad.

		LDA 	sidV2EnvOu
		AND	#$7F
		STA	Z:numConvM1
		NOP
		NOP
		NOP
		LDA 	sidV2EnvOu
		STA	Z:numConvM1 + 1

		JSR	numConvFLOAT
		
		LDX	#$00
@loop:
		LDA	Z:numConvX1, X
		STA	Z:numConvX2, X
		
		INX
		CPX	#$04
		BNE	@loop
		
		LDA	#$07
		STA	Z:numConvM1
		LDA	#$87
		STA	Z:numConvM1 + 1

		JSR	numConvFLOAT
		
		JSR	numConvFDIV
		
		JSR	numConvFIX
		
		LDX	Z:numConvM1 + 1
;		INX
		
		CPX	#$10	
		BMI	@done
		
		LDX	#$0F
		
@done:

		TXA
		
		RTS		


;-------------------------------------------------------------------------------
rulesShuffleChest:
;-------------------------------------------------------------------------------
		JSR	prmptShuffle		;Display shuffle prompt (immed.)
		
		LDA	game + GAME::pGF0Crd	;Reinclude the GO Free card?
		CMP	#$FF
		BNE	@cont
		
		LDA	#$00
		STA	game + GAME::fGF0Out
		

@cont:
;***FIXME: 	Do we need this really?
		LDA	#$FF			;Init (why???)
		LDX	#$0F			;
@loopinit:					;
		STA	rulesChestCrds0, X	;
		DEX				;
		BPL	@loopinit		;
		
		
		LDX	#$00			;Get random card, for all cards...
@looprnd:
		STX	rulesChestIdx
@rndgen:
		JSR	rulesGenRnd0F
		
		LDX	rulesChestIdx
		STA	rulesChestCrds0, X

		LDY	#$00			;Need to check its not already 
						;allocated
		CPX	#$00
		BEQ	@rndnext
		
@loopchk:
		LDA	rulesChestCrds0, Y
		CMP	rulesChestCrds0, X
		BEQ	@rndgen			;Was used already, so get a new one
		
		INY
		CPY	rulesChestIdx
		BNE	@loopchk
		
@rndnext:
		INX
		CPX	#$10
		BNE	@looprnd

		LDX	#$00			;Initialise deck index
		STX	rulesChestIdx

		JSR	prmptDisplay

		RTS


;-------------------------------------------------------------------------------
rulesShuffleChance:
;-------------------------------------------------------------------------------
		JSR	prmptShuffle
		
		LDA	game + GAME::pGF1Crd	;Reinclude the GO Free card?
		CMP	#$FF
		BNE	@cont
		
		LDA	#$00
		STA	game + GAME::fGF1Out

@cont:
;***FIXME: 	Do we need this really?
		LDA	#$FF			;Init (why???)
		LDX	#$0F			;
@loopinit:					;
		STA	rulesChanceCrds0, X	;
		DEX				;
		BPL	@loopinit		;
		
		
		LDX	#$00
@looprnd:
		STX	rulesChanceIdx
@rndgen:
		JSR	rulesGenRnd0F

		LDX	rulesChanceIdx
		STA	rulesChanceCrds0, X

		LDY	#$00

		CPX	#$00
		BEQ	@rndnext
				
@loopchk:
		LDA	rulesChanceCrds0, Y
		CMP	rulesChanceCrds0, X
		BEQ	@rndgen
		
		INY
		CPY	rulesChanceIdx
		BNE	@loopchk
		
@rndnext:
		INX
		CPX	#$10
		BNE	@looprnd

		LDX	#$00
		STX	rulesChanceIdx

		JSR	prmptDisplay
		
		RTS


rulesCalcQForSquare:
		CPX	#$01
		BEQ	@alt

		CMP	#$05
		BPL	@test0
		
		LDA	#$00
		JMP	@exit
		
@test0:
		CMP	#$0F
		BPL	@test1
		
		LDA	#$01
		JMP	@exit
		
@test1:
		CMP	#$19
		BPL	@test2
		
		LDA	#$02
		JMP	@exit
		
@test2:
		CMP	#$23
		BPL	@last
		
		LDA	#$03
		JMP	@exit
		
@last:
		LDA	#$00
		JMP	@exit

@alt:
		CMP	#$06
		BPL	@a0
		
		LDA	#$00
		JMP	@exit
		
@a0:
		CMP	#$24
		BMI	@a1
		
		LDA	#$00
		JMP	@exit
		
@a1:
		CMP	#$1A
		BMI	@a2
		
		LDA	#$03
		JMP	@exit
		
@a2:
		CMP	#$10
		BMI	@al
		
		LDA	#$02
		JMP	@exit
		
@al:
		LDA	#$01


		
@exit:
		RTS
		
		
rulesFocusOnActive:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square
		LDA	($FB), Y
		
		LDX	#$00
		JSR	rulesCalcQForSquare
		
		CMP	game + GAME::qVis
		BEQ	@exit
		
		STA	game + GAME::qVis

		JSR	gamePlayersDirty
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		
		
		SEC
		RTS
@exit:
		CLC
		RTS


rulesCalcNextSqr:
;		STA	game + GAME::varJ	;current square
		STX	game + GAME::varK	;movement
		
		CLC
		ADC	game + GAME::varK
		CMP	#$28
		BPL	@passgo

		LDX	#$00
		JMP	@exit
		
@passgo:
		SEC
		SBC	#$28
		LDX	#$01
		
@exit:
		RTS
		

;-------------------------------------------------------------------------------
rulesFixNextSqr:
;-------------------------------------------------------------------------------
;		STA	game + GAME::varJ	;current square
		STX	game + GAME::varK	;dest square
		
		CMP	game + GAME::varK
		BEQ	@equgt
		
		BPL	@passgo
		
@equgt:
		LDX	#$00
		JMP	@exit
@passgo:
		LDX	#$01

@exit:
		LDA	game + GAME::varK
		RTS
		

;-------------------------------------------------------------------------------
rulesInitStepping:
;-------------------------------------------------------------------------------
		STA	game + GAME::sStpDst
		STY	game + GAME::fPayDbl
		
		CMP	#$00
		BEQ	@nopassgo
		
		STX	game + GAME::fStpPsG
		JMP	@cont
		
@nopassgo:
		LDA	#$00
		STA	game + GAME::fStpPsG
		
@cont:
		LDA	#$11
		STA	game + GAME::iStpCnt
		LDA	#$00
		STA	game + GAME::fAmStep
		STA	game + GAME::fStpSig
		
		LDA	game + GAME::gMode
		STA	game + GAME::gMdStep

		LDA	#$06
		STA	game + GAME::gMode
		
		JSR	gameUpdateMenu
		
		LDA	#<$DA18
		STA	game + GAME::aWai
		LDA	#>$DA18
		STA	game + GAME::aWai + 1

		LDA	#$01
		STA	game + GAME::kWai
		
		RTS


;-------------------------------------------------------------------------------
rulesMoveToSquare:
;-------------------------------------------------------------------------------
		STA	game + GAME::varJ	;dest square
		STX	game + GAME::varK	;if passed go
		STY	game + GAME::varG	;if we do something special

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square

		LDA	game + GAME::varK
		CMP	#$01
		BNE	@cont
	
		LDA	game + GAME::varJ	;sanity check
		CMP	#$00
		BEQ	@cont
		
		LDA	#$00			;"Pass" Go
		STA	($FB), Y
		JSR	rulesLandOnSquare

@cont:
		LDA	game + GAME::varJ
		LDY	#PLAYER::square
		STA	($FB), Y
		JSR	rulesLandOnSquare
		
		LDY	#PLAYER::dirty
		LDA	#$01
		STA	($FB), Y
				
		JSR	rulesFocusOnActive
		RTS


;-------------------------------------------------------------------------------
rulesLandOnSquare:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::square		;***fixme change this so its 
		LDA	($FB), Y		;passed  in and stored instead?
		STA	game + GAME::varA	;square
		
		ASL
		TAX
		
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC	;index
		
		LDA	rulesSqr0, X		
		STA	game + GAME::varB	;group
		
		CMP	#$00
		BNE	@test1
		
		JSR	rulesLandCrnr
		JMP	@exit
		
@test1:
		CMP	#$09
		BPL	@test2
		
		JSR	rulesLandStreet
		JMP	@exit
		
@test2:
;		CMP	#$09
		BNE	@test3
		
		JSR	rulesLandStatn
		JMP	@exit
		
@test3:
		CMP	#$0A
		BNE	@test4
		
		JSR	rulesLandUtil
		JMP	@exit
		
@test4:
		CMP	#$0B
		BNE	@test5
		
		JSR	rulesLandChest
		JMP	@exit
		
@test5:
		CMP	#$0C
		BNE	@test6
		
		JSR	rulesLandChance
		JMP	@exit
		
@test6:
		CMP	#$0D
		BNE	@none
		
		JSR	rulesLandTax
		JMP	@exit
		
@none:
		LDA	#$00
		STA	game + GAME::fMBuy
		CLC
		RTS

@exit:
		BCC 	@realexit
		
		LDA	#$01
		STA	game + GAME::fMBuy

@realexit:
		RTS


;-------------------------------------------------------------------------------
rulesAddCash:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::money + 1	;Remember high byte of curr cash
		LDA	($FB), Y
		TAX
		
		DEY				;Calculate new cash value
		CLC
		LDA	($FB), Y
		ADC	game + GAME::varD	;From value passed in D, E
		STA	($FB), Y
		INY
		LDA	($FB), Y
		ADC	game + GAME::varE
		STA	($FB), Y
		
		TXA				;Was the value positive initially?
		BPL	@tstcap	
	
		JMP	@procdebts		;No - process debts from pool
		
@tstcap:
		LDA	($FB), Y		;Yes - is the value still positive?
		BPL	@procdebts
		
		LDA	#$7F			;No - Cap the value at max
		STA	($FB), Y
		DEY
		LDA	#$FF
		STA	($FB), Y
		
@procdebts:
		LDA	game + GAME::varD	;Put total cash added in pool M, N
		STA	game + GAME::varM
		LDA	game + GAME::varE
		STA	game + GAME::varN
		
		LDX	game + GAME::pActive
		JMP	@next
		
@loop:
		LDA	plrLo, X
		STA	$AD
		LDA	plrHi, X
		STA	$AE
		
		CLC				;Get base ptr for accs 
		LDA	$FB			;Do this outside loop?
		ADC	#<PLAYER::mDAcc0
		STA	$AB
		LDA	$FC
		ADC	#>PLAYER::mDAcc0
		STA	$AC		

		TXA				;Get the value in the checked acc 
		ASL				;to O, P
		TAY
		LDA	($AB), Y		
		STA	game + GAME::varO
		INY
		LDA	($AB), Y
		STA	game + GAME::varP

		LDA	game + GAME::varO	;Not zero value?
		BNE	@proc
		
		LDA	game + GAME::varP	;Not zero value?
		BNE	@proc
		
		JMP	@next			;Is zero, check next player's acc
		
@proc:
		CLC				;Else find out how much is left
		LDA	game + GAME::varM	;after paying player debt
		ADC	game + GAME::varO
		STA	game + GAME::varM
		LDA	game + GAME::varN
		ADC	game + GAME::varP
		STA	game + GAME::varN
		
		BPL 	@checknz		;Money left over?

		SEC				;No, calculate cash could pay
		LDA	game + GAME::varO
		SBC	game + GAME::varM
		STA	game + GAME::varO
		LDA	game + GAME::varP
		SBC	game + GAME::varN
		STA	game + GAME::varP

		DEY				;Store new owed value in acc
		LDA	game + GAME::varM
		STA	($AB), Y
		INY
		LDA	game + GAME::varN
		STA	($AB), Y

		LDY	#PLAYER::money
		
		SEC				;Calculate the actual cash now
		LDA	($AD), Y		;available to the player being
		SBC	game + GAME::varO	;paid
		STA	($AD), Y
		INY
		LDA	($AD), Y
		SBC	game + GAME::varP
		STA	($AD), Y
		
		JMP	@cont			;Done checking player accs
		
@checknz:
		DEY				;Debt fully paid, set acc value
		LDA	#$00			;to zero
		STA	($AB), Y
		INY
		LDA	#$00
		STA	($AB), Y
		
		LDY	#PLAYER::money		

		SEC				;Calculate the actual cash now
		LDA	($AD), Y		;available to the playing being
		SBC	game + GAME::varO	;paid
		STA	($AD), Y
		INY
		LDA	($AD), Y
		SBC	game + GAME::varP
		STA	($AD), Y

		LDA	game + GAME::varN	;Is there money left in the pool?
		BNE	@next			;Yes - check next player's acc
		
		LDA	game + GAME::varM
		BEQ	@cont			;No - done checking player accs

@next:
		INX

		CPX	#$06
		BNE	@tstloop
		
@wrap:		
		LDX	#$00
		
@tstloop:
		CPX	game + GAME::pActive
		BEQ	@cont
		
		JMP	@loop
		
@cont:
		LDX	game + GAME::pActive

		CLC				;Get base ptr for accs
		LDA	$FB
		ADC	#<PLAYER::mDAcc0
		STA	$AB
		LDA	$FC
		ADC	#>PLAYER::mDAcc0
		STA	$AC		

		TXA				;Get the value in the bank acc 
		ASL				;to O, P
		TAY
		LDA	($AB), Y		
		STA	game + GAME::varO
		INY
		LDA	($AB), Y
		STA	game + GAME::varP

		LDA	game + GAME::varO	;Not zero value?
		BNE	@procb0
		
		LDA	game + GAME::varP	;Not zero value?
		BNE	@procb0
		
		JMP	@tax0			;Is zero, check tax acc
		
@procb0:
		CLC				;Else find out how much is left
		LDA	game + GAME::varM	;after paying bank debt
		ADC	game + GAME::varO
		STA	game + GAME::varM
		LDA	game + GAME::varN
		ADC	game + GAME::varP
		STA	game + GAME::varN
		
		BPL 	@checknzb0		;Money left over?

		SEC				;No, calculate cash could pay
		LDA	game + GAME::varO
		SBC	game + GAME::varM
		STA	game + GAME::varO
		LDA	game + GAME::varP
		SBC	game + GAME::varN
		STA	game + GAME::varP

		DEY				;Store new owed value in acc
		LDA	game + GAME::varM
		STA	($AB), Y
		INY
		LDA	game + GAME::varN
		STA	($AB), Y

		JMP	@done0			;Done checking bank acc
		
@checknzb0:
		DEY				;Debt fully paid, set acc value
		LDA	#$00			;to zero
		STA	($AB), Y
		INY
		LDA	#$00
		STA	($AB), Y
		
		LDA	game + GAME::varN	;Is there money left in the pool?
		BNE	@tax0			;Yes - check tax acc
		
		LDA	game + GAME::varM
		BNE	@tax0
		
		JMP	@done0			;No - done checking bank accs

@tax0:
		LDX	#$06
		TXA				;Get the value in the tax acc 
		ASL				;to O, P
		TAY
		LDA	($AB), Y		
		STA	game + GAME::varO
		INY
		LDA	($AB), Y
		STA	game + GAME::varP

		LDA	game + GAME::varO	;Not zero value?
		BNE	@proct0
		
		LDA	game + GAME::varP	;Not zero value?
		BNE	@proct0
		
		JMP	@done0			;Is zero, finished
		
@proct0:
		CLC				;Else find out how much is left
		LDA	game + GAME::varM	;after paying tax debt
		ADC	game + GAME::varO
		STA	game + GAME::varM
		LDA	game + GAME::varN
		ADC	game + GAME::varP
		STA	game + GAME::varN
		
		BPL 	@checknzt0		;Money left over?

		SEC				;No, calculate cash could pay
		LDA	game + GAME::varO
		SBC	game + GAME::varM
		STA	game + GAME::varO
		LDA	game + GAME::varP
		SBC	game + GAME::varN
		STA	game + GAME::varP

		DEY				;Store new owed value in acc
		LDA	game + GAME::varM
		STA	($AB), Y
		INY
		LDA	game + GAME::varN
		STA	($AB), Y

		LDA	game + GAME::fFPTax
		BEQ	@done0
		
		SEC
		LDA	game + GAME::mFPTax
		SBC	game + GAME::varO
		STA	game + GAME::mFPTax
		LDA	game + GAME::mFPTax + 1
		SBC	game + GAME::varP
		STA	game + GAME::mFPTax + 1

		JMP	@done0			;Done checking tax acc
		
@checknzt0:
		DEY				;Debt fully paid, set acc value
		LDA	#$00			;to zero
		STA	($AB), Y
		INY
		LDA	#$00
		STA	($AB), Y

		LDA	game + GAME::fFPTax
		BEQ	@done0
		
		SEC
		LDA	game + GAME::mFPTax
		SBC	game + GAME::varO
		STA	game + GAME::mFPTax
		LDA	game + GAME::mFPTax + 1
		SBC	game + GAME::varP
		STA	game + GAME::mFPTax + 1

@done0:
		LDY	#PLAYER::money + 1	;See if the player is still 
		LDA	($FB), Y		;in debt
		BMI	@done1
	
		LDY	#PLAYER::status		;No - unset debt flag
		LDA	($FB), Y
		AND	#$F7	
		STA	($FB), Y
		
@done1:		
		LDA	#$02			;Update stats
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;-------------------------------------------------------------------------------
rulesAddEquity:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::equity
		
		CLC
		LDA	($FB), Y
		ADC	game + GAME::varD
		STA	($FB), Y
		INY
		LDA	($FB), Y
		ADC	game + GAME::varE
		STA	($FB), Y
		
		RTS


;-------------------------------------------------------------------------------
rulesCreditAcc:
;-------------------------------------------------------------------------------
		LDA	game + GAME::varL
		CMP	game + GAME::pActive
		BNE	@tstother
		
		RTS
		
@tstother:
		CMP	#$06
		BNE	@begin
		
		LDA	game + GAME::fFPTax
		BEQ	@skipFP
		
		CLC
		LDA	game + GAME::mFPTax
		ADC	game + GAME::varM
		STA	game + GAME::mFPTax
		LDA	game + GAME::mFPTax + 1
		ADC	game + GAME::varN
		STA	game + GAME::mFPTax + 1
		
@skipFP:
		RTS
		
@begin:
		TAX
		
		LDA	plrLo, X
		STA	$AB
		LDA	plrHi, X
		STA	$AC

		LDY	#PLAYER::money
		
		CLC
		LDA	($AB), Y
		ADC	game + GAME::varM
		STA	($AB), Y
		INY
		LDA	($AB), Y
		ADC	game + GAME::varN
		STA	($AB), Y
		
		RTS


;-------------------------------------------------------------------------------
rulesDoSubCash:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::money
		
		SEC
		LDA	($FB), Y
		SBC	game + GAME::varM
		STA	($FB), Y
		INY
		LDA	($FB), Y
		SBC	game + GAME::varN
		STA	($FB), Y

		RTS


;-------------------------------------------------------------------------------
rulesDoOweAcc:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::status
		LDA	($FB), Y
		ORA	#$08
		STA	($FB), Y
		
		LDA	#<SFXBELL
		LDY	#>SFXBELL
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	game + GAME::varL
		ASL
		TAY
		
		CLC
		LDA	$FB
		ADC	#<PLAYER::mDAcc0
		STA	$AB
		LDA	$FC
		ADC	#>PLAYER::mDAcc0
		STA	$AC
		
		CLC
		LDA	($AB), Y
		ADC	game + GAME::varO
		STA	($AB), Y
		INY
		LDA	($AB), Y
		ADC	game + GAME::varP
		STA	($AB), Y

		RTS


;-------------------------------------------------------------------------------
rulesDoCheckPayDebt:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::money

		LDA	($FB), Y
		STA	game + GAME::varO
		INY
		LDA	($FB), Y
		STA	game + GAME::varP
		
		LDY	#PLAYER::equity

		CLC
		LDA	($FB), Y
		ADC	game + GAME::varO
		INY
		LDA	($FB), Y
		ADC	game + GAME::varP

		BPL	@exit
	
		LDY	#PLAYER::status
		LDA	($FB), Y
		ORA	#$02
		STA	($FB), Y

@exit:
		RTS


;-------------------------------------------------------------------------------
rulesSubCash:
;-------------------------------------------------------------------------------
		STX	game + GAME::varL	;Which account to credit
		
		LDY	#PLAYER::money

		SEC
		LDA	($FB), Y
		SBC	game + GAME::varD
		STA	game + GAME::varM
		INY
		LDA	($FB), Y
		SBC	game + GAME::varE
		STA	game + GAME::varN
		
		BMI	@indebt

		LDA	game + GAME::varD
		STA	game + GAME::varM
		LDA	game + GAME::varE
		STA	game + GAME::varN
		
		JSR	rulesCreditAcc
		
		JSR	rulesDoSubCash
		
		JMP	@exit
		
@indebt:
		LDA	game + GAME::varM
		STA	game + GAME::varO
		LDA	game + GAME::varN
		STA	game + GAME::varP
		
		JSR	rulesDoOweAcc
		
		CLC
		LDA	game + GAME::varD
		ADC	game + GAME::varM
		STA	game + GAME::varM
		LDA	game + GAME::varE
		ADC	game + GAME::varN
		STA	game + GAME::varN
		
		JSR	rulesCreditAcc
		
		LDA	game + GAME::varD
		STA	game + GAME::varM
		LDA	game + GAME::varE
		STA	game + GAME::varN

		JSR	rulesDoSubCash
		
		JSR	rulesDoCheckPayDebt

@exit:
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;-------------------------------------------------------------------------------
rulesSubEquity:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::equity
		
		SEC
		LDA	($FB), Y
		SBC	game + GAME::varD
		STA	($FB), Y
		INY
		LDA	($FB), Y
		SBC	game + GAME::varE
		STA	($FB), Y

		RTS


;-------------------------------------------------------------------------------
rulesPayRent:
;-------------------------------------------------------------------------------
		PHA
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptRent
		
		PLA
		TAX
		JSR	rulesSubCash

		LDA	game + GAME::varE
		CMP	#$05
		BPL	@clamphi
		
		CMP	#$00
		BNE	@sfx
		
		LDA	#$01
		JMP	@sfx
		
@clamphi:
		LDA	#$04
		
@sfx:
		TAX
		DEX
		LDA	sfxRentLo, X
		LDY	sfxRentHi, X
		LDX	#$07
		JSR	SNDBASE + 6
				
		RTS
		

;-------------------------------------------------------------------------------
rulesGoGaol:
;-------------------------------------------------------------------------------
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptGoneGaol
		
		LDY	#PLAYER::square
		LDA	#$0A
		STA	($FB), Y
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		ORA	#$C0			;in and gone to
		STA	($FB), Y
		
		LDA	#musTuneGaol
		JSR	SNDBASE + 0
		
		LDY	#PLAYER::dirty
		LDA	#$01
		STA	($FB), Y

		LDA	#$01			;prevent further movement 
		STA	game + GAME::dieRld
		LDA	#$00		
		STA	game + GAME::dieDbl
		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


;-------------------------------------------------------------------------------
rulesLandCrnr:
;-------------------------------------------------------------------------------
		LDA	game + GAME::varA
		CMP	#$00
		BNE	@test0
		
		LDA	#200
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		JSR	rulesAddCash

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptSalary

		LDA	#<SFXGONG
		LDY	#>SFXGONG
		LDX	#$00
		JSR	SNDBASE + 6

		JMP	@exit
		
@test0:
		CMP	#$14
		BNE	@test1
		
		LDA	game + GAME::fFPTax
		BEQ	@exit
		
		LDA	game + GAME::mFPTax
		STA	game + GAME::varD
		LDA	game + GAME::mFPTax + 1
		STA	game + GAME::varE

		JSR	rulesAddCash
		
		LDA	#$00
		STA	game + GAME::mFPTax
		STA	game + GAME::mFPTax + 1
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptFParking

		LDA	#<SFXGONG
		LDY	#>SFXGONG
		LDX	#$00
		JSR	SNDBASE + 6

		JMP	@exit
		
@test1:
		CMP	#$1E
		BNE	@exit
		
		JSR	rulesGoGaol
;		JMP	@exit
		
@exit:
		CLC
		LDA	#$00
		
		RTS


;-------------------------------------------------------------------------------
rulesDoDeedRent:
;-------------------------------------------------------------------------------
		LDA	game + GAME::varI
		AND	#$80			;mrtg
		BNE	@exit
		
		LDA	game + GAME::varI
		AND	#$08
		BNE	@hotel
		
		LDA	game + GAME::varI
		AND	#$07
		
		CMP	#$00
		BEQ	@unimprv
		
		ASL
		CLC
		ADC	#STREET::m1Hse - 2
		TAY
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JMP	@rent
		
@unimprv:
		LDY	#STREET::mRent

		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

		LDA	game + GAME::varI
		AND	#$40
		BEQ	@rent
		
		ASL	game + GAME::varD		;Only ever 1 byte so cheat

		JMP	@rent

@hotel:
		LDY	#STREET::mHotl

		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

@rent:
		LDA	game + GAME::varH
		JSR	rulesPayRent
		
@exit:
		
		RTS


;-------------------------------------------------------------------------------
rulesLandStreet:
;-------------------------------------------------------------------------------
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDA	game + GAME::varA	;square
		ASL
		TAX
		LDA	sqr00, X
		STA	game + GAME::varH	;owner
		
		CMP	#$FF
		BEQ	@avail
		
		CMP	game + GAME::pActive
		BEQ	@exit
		
		LDA	sqr00 + 1, X
		STA	game + GAME::varI	;improvements
		
		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		
		STA	$FE
		PLA
		STA	$FD
		
		JSR	rulesDoDeedRent

@exit:
		CLC
		LDA	#$00
		RTS
		
@avail:
		SEC
		LDA	#$00
		RTS
		
		
		
rulesLandStatn:		
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDA	game + GAME::varA	;square
		ASL
		TAX
		LDA	sqr00, X
		STA	game + GAME::varH	;owner
		
		CMP	#$FF
		BEQ	@avail
		
		CMP	game + GAME::pActive
		BEQ	@exit

		LDA	sqr00 + 1, X
		AND	#$80			;mrtg
		BNE	@exit

		LDX	game + GAME::varH
		LDA	plrLo, X
		STA	$A7
		LDA	plrHi, X
		STA	$A8

		LDY	#PLAYER::oGrp09		
		LDA	($A7), Y
		STA	game + GAME::varF	;stations owned

		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		
		STA	$FE
		PLA
		STA	$FD

		LDY	#STATION::rRent
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		LDX	game + GAME::varF
@loop:
		DEX
		BEQ	@cont
		ASL	game + GAME::varD	;Only ever 1 byte so cheat
		JMP 	@loop
		
@cont:
		LDA	#$01
		CMP	game + GAME::varG
		BNE	@pay
		
		CLC
		ROL	game + GAME::varD
		ROL	game + GAME::varE

@pay:
		LDA	game + GAME::varH
		JSR	rulesPayRent

@exit:
		CLC
		LDA	#$00
		RTS
		
@avail:
		SEC
		LDA	#$00
		RTS


rulesLandUtil:
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDA	game + GAME::varA	;square
		ASL
		TAX
		LDA	sqr00, X
		STA	game + GAME::varH	;owner
		
		CMP	#$FF
		BEQ	@avail
		
		CMP	game + GAME::pActive
		BEQ	@exit

		LDA	sqr00 + 1, X
		AND	#$80			;mrtg
		BNE	@exit
		
		LDX	game + GAME::varH
		LDA	plrLo, X
		STA	$A7
		LDA	plrHi, X
		STA	$A8
		
		LDY	#PLAYER::oGrp0A		
		LDA	($A7), Y
		STA	game + GAME::varF	;utilites owned
		TAX
		
		LDA	#$00
		STA	game + GAME::varE
		
		LDA	game + GAME::dieA
		CLC
		ADC	game + GAME::dieB
		
		LDY	game + GAME::varG
		CPY	#$01
		BEQ	@10
		
		CPX	#$02
		BNE	@1
	
@10:	
		JSR	numConvMULT10
		JMP	@2
		
@1:
		ASL
		ASL
		
@2:
		STA	game + GAME::varD
		
		LDA	game + GAME::varH
		
		JSR	rulesPayRent
		
@exit:
		CLC
		LDA	#$00
		RTS
		
@avail:
		SEC
		LDA	#$00
		RTS


rulesCCCrdProcDummy:				;none
		RTS


rulesCCCrdProcInc:				;get cash
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	dialogCCCCardTemp0 + 1
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		JSR	rulesAddCash
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		LDA	dialogCCCCardTemp9
		CMP	#$00
		BNE	@chance
		
		JSR	prmptChestAdd
		JMP	@cont
		
@chance:
		JSR	prmptChanceAdd
		
@cont:
		LDY	#>SFXCASH
		LDA	#<SFXCASH
		LDX	#$07
		JSR	SNDBASE + 6

		RTS


rulesCCCrdProcAdv:				;adv to
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptClearOrRoll
		
		LDY	#PLAYER::square
		LDA	($FB), Y

		LDX	dialogCCCCardTemp0 + 1
		
		JSR	rulesFixNextSqr
		LDY	#$00
		PHA

		LDA	game + GAME::fDoJump
		BNE	@doJump
		
		PLA
		JSR	rulesInitStepping
		RTS
		
@doJump:
		LDY	#>SFXSPLAT		;In case there are no other sfx
		LDA	#<SFXSPLAT
		LDX	#$07
		JSR	SNDBASE + 6
		
		PLA
		JSR	rulesMoveToSquare
		
		JSR	gameUpdateMenu
		
		RTS
		

rulesCCCrdProcRep:				;street/gen repairs
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC



						;    3: Hotel flag
						;  0-2: Houses count
		LDX	#$00
		STX	game + GAME::varA
		STX	game + GAME::varB
		
@loop:
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BNE	@next

		LDA	sqr00 + 1, X
		AND	#$08
		BEQ	@hses
		
		INC	game + GAME::varB
		
@hses:
		LDA	sqr00 + 1, X
		AND	#$07
		
		CLC
		ADC	game + GAME::varA
		STA	game + GAME::varA
		
@next:
		INX
		INX
		CPX	#$50
		BNE	@loop
		
		LDA	#$00			;Houses
		STA	Z:numConvM1
		LDA	dialogCCCCardTemp0
		STA	Z:numConvM1 + 1

		JSR	numConvFLOAT
		JSR	numConvCopyX1X2
		
		LDA	#$00
		STA	Z:numConvM1
		LDA	game + GAME::varA
		STA	Z:numConvM1 + 1
		
		JSR	numConvFLOAT

		JSR	numConvFMUL

		JSR	numConvFIX
		
		LDA	Z:numConvM1
		STA	game + GAME::varE
		LDA	Z:numConvM1 + 1
		STA	game + GAME::varD
		
		LDA	#$00			;Hotels
		STA	Z:numConvM1
		LDA	dialogCCCCardTemp0 + 1
		STA	Z:numConvM1 + 1

		JSR	numConvFLOAT
		JSR	numConvCopyX1X2
		
		LDA	#$00
		STA	Z:numConvM1
		LDA	game + GAME::varB
		STA	Z:numConvM1 + 1
		
		JSR	numConvFLOAT

		JSR	numConvFMUL

		JSR	numConvFIX
		
;		LDA	Z:numConvM1
;		STA	game + GAME::varE
;		LDA	Z:numConvM1 + 1
;		STA	game + GAME::varD

		CLC
		LDA	Z:numConvM1
		ADC	game + GAME::varE
		STA	game + GAME::varE
		LDA	Z:numConvM1 + 1
		ADC	game + GAME::varD
		STA	game + GAME::varD

		BNE	@proc
		LDA	game + GAME::varE
		BNE	@proc
		
		JMP	@exit

@proc:
		LDX	game + GAME::pActive
		JSR	rulesSubCash
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		LDA	dialogCCCCardTemp9
		CMP	#$00
		BNE	@chance
		
		JSR	prmptChestSub
		JMP	@cont
		
@chance:
		JSR	prmptChanceSub
		
@cont:

		LDY	#>SFXRENT1
		LDA	#<SFXRENT1
		LDX	#$07
		JSR	SNDBASE + 6

		JSR	gameUpdateMenu
		
@exit:
		RTS


rulesCCCrdProcColMPay:
		LDA	game + GAME::gMode
		STA	game + GAME::gMdMPyI	
		
		LDA	game + GAME::pActive
		STA	game + GAME::pMstPyI

		STA	game + GAME::pMPyLst
		STA	game + GAME::pMPyCur

		LDA	#$03
		STA	game + GAME::gMode
		
		JSR	gameUpdateMenu

		RTS


rulesCCCrdProcCol:				;collect from all players
		LDA	dialogCCCCardTemp0 + 1
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE

		LDA	#$00
		STA	game + GAME::varO
		STA	game + GAME::varP

		LDX	game + GAME::pActive
		STX	game + GAME::varA
		
		JMP	@next
		
@loop:
		STX	game + GAME::pActive

		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		CPX	game + GAME::varA
		BEQ	@next
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
		
		TXA
		PHA
		
		LDX	game + GAME::varA
		JSR	rulesSubCash

		CLC
		LDA	game + GAME::varD
		ADC	game + GAME::varO
		STA	game + GAME::varO
		LDA	game + GAME::varE
		ADC	game + GAME::varP
		STA	game + GAME::varP

		PLA
		TAX
;		INC	game + GAME::varA
		
@next:
		INX

		CPX	#$06
		BNE	@tstloop
		
@wrap:		
		LDX	#$00
		
@tstloop:
		CPX	game + GAME::varA
		BNE	@loop
		
		LDX	game + GAME::varA
		STX	game + GAME::pActive
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	game + GAME::varO
		STA	game + GAME::varD
		LDA	game + GAME::varP
		STA	game + GAME::varE
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		LDA	dialogCCCCardTemp9
		CMP	#$00
		BNE	@chance
		
		JSR	prmptChestAdd
		JMP	@cont
		
@chance:
		JSR	prmptChanceAdd
		
@cont:
		LDY	#>SFXCASH
		LDA	#<SFXCASH
		LDX	#$07
		JSR	SNDBASE + 6

@finish:
		LDX	game + GAME::pActive
		JMP	@next1
@loop1:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$0A
		BEQ	@next1

		JSR	rulesCCCrdProcColMPay
		JMP	@exit1
		
@next1:
		INX

		CPX	#$06
		BNE	@tstloop1
		
@wrap1:		
		LDX	#$00
		
@tstloop1:
		CPX	game + GAME::pActive
		BNE	@loop1
		
@exit1:
		RTS

rulesCCCrdProcGGL:				;go gaol
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptGoneGaol
		
		JSR	rulesGoGaol
		JSR	rulesFocusOnActive
		JSR	gameUpdateMenu
		
		RTS
		

rulesCCCrdProcPay:				;pay cash
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	dialogCCCCardTemp0 + 1
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		LDX	game + GAME::pActive
		JSR	rulesSubCash

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		LDA	dialogCCCCardTemp9
		CMP	#$00
		BNE	@chance
		
		JSR	prmptChestSub
		JMP	@cont
		
@chance:
		JSR	prmptChanceSub
		
@cont:
		LDY	#>SFXRENT0
		LDA	#<SFXRENT0
		LDX	#$07
		JSR	SNDBASE + 6
		
		JSR	gameUpdateMenu
		
		RTS
		
		
rulesCCCrdProcGGF:				;get out free
		LDX	game + GAME::pActive
		
		LDA	dialogCCCCardTemp0 + 1
		CMP	#$00
		BNE	@1
		
		STX	game + GAME::pGF0Crd

		LDA	#$01
		STA	game + GAME::fGF0Out
		
		JMP	@done
		
@1:
		STX	game + GAME::pGF1Crd
		
		LDA	#$01
		STA	game + GAME::fGF1Out
		
@done:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptClearOrRoll
		
		LDA	#<SFXSLAM
		LDY	#>SFXSLAM
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


rulesCCCrdProcAST:				;adv to station pay dbl
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptClearOrRoll
		
		LDY	#>SFXSPLAT
		LDA	#<SFXSPLAT
		LDX	#$07
		JSR	SNDBASE + 6

		LDY	#PLAYER::square
		LDA	($FB), Y

		CMP	#$05
		BPL	@test3
		
@0:
		LDX	#$05
		JMP	@move
		
@test3:
		CMP	#$23
		BPL	@0

		CMP	#$0F
		BPL	@test2
		
		LDX	#$0F
		JMP	@move
		
@test2:
		CMP	#$19
		BPL	@3
		
		LDX	#$19
		JMP	@move
		
@3:
		LDX	#$23
		
@move:
		JSR	rulesFixNextSqr
		LDY	#$01
		PHA

		LDA	game + GAME::fDoJump
		BNE	@doJump
		
		PLA
		JSR	rulesInitStepping
		RTS
		
@doJump:
		PLA
		JSR	rulesMoveToSquare
		
		JSR	gameUpdateMenu

		RTS

rulesCCCrdProcGBk:				;go back spaces
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptClearOrRoll
		
		LDY	#>SFXSPLAT
		LDA	#<SFXSPLAT
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDY	#PLAYER::square
		LDA	($FB), Y

		PHA

		SEC
		SBC	dialogCCCCardTemp0 + 1
		
		TAX
		PLA
		
		JSR	rulesFixNextSqr
		LDX	#$00
		LDY	#$00
		JSR	rulesMoveToSquare
		
		JSR	gameUpdateMenu
		
		RTS


;-------------------------------------------------------------------------------
rulesCCCrdProcBrb:				;pay all players
;-------------------------------------------------------------------------------
		LDA	dialogCCCCardTemp0 + 1
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		LDA	#$00
		STA	game + GAME::varO
		STA	game + GAME::varP
		
		LDX	game + GAME::pActive
;		STX	game + GAME::varA

		JMP	@next
		
@loop:
;		CPX	game + GAME::pActive
;		BEQ	@next

		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
		
		TXA
		PHA

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		PLA
		PHA
		TAX

		JSR	rulesSubCash
		
		CLC
		LDA	game + GAME::varD
		ADC	game + GAME::varO
		STA	game + GAME::varO
		LDA	game + GAME::varE
		ADC	game + GAME::varP
		STA	game + GAME::varP
		
		PLA
		TAX
		
;		INC	game + GAME::varA
		
@next:
		INX

		CPX	#$06
		BNE	@tstloop
		
@wrap:		
		LDX	#$00
		
@tstloop:
		CPX	game + GAME::pActive
		BNE	@loop
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	game + GAME::varO
		STA	game + GAME::varD
		LDA	game + GAME::varP
		STA	game + GAME::varE

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		LDA	dialogCCCCardTemp9
		CMP	#$00
		BNE	@chance
		
		JSR	prmptChestSub
		JMP	@cont
		
@chance:
		JSR	prmptChanceSub
		
@cont:
		LDY	#>SFXRENT0
		LDA	#<SFXRENT0
		LDX	#$07
		JSR	SNDBASE + 6

		JSR	gameUpdateMenu

@exit:		
		RTS


;-------------------------------------------------------------------------------
rulesCCCrdProcAUT:				;adv to util pay 10x
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptClearOrRoll
		
		LDY	#>SFXSPLAT
		LDA	#<SFXSPLAT
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDY	#PLAYER::square
		LDA	($FB), Y

		CMP	#$0C
		BPL	@test
		
@water:
		LDX	#$0C
		JMP	@move
		
@test:
		CMP	#$1C
		BPL	@water

		LDX	#$1C
		
@move:
		JSR	rulesFixNextSqr
		LDY	#$01
		PHA

		LDA	game + GAME::fDoJump
		BNE	@doJump
		
		PLA
		JSR	rulesInitStepping
		RTS
		
@doJump:
		PLA
		JSR	rulesMoveToSquare

		JSR	gameUpdateMenu
	
		RTS


;-------------------------------------------------------------------------------
rulesLandChest:
;-------------------------------------------------------------------------------
		LDX	rulesChestIdx
		LDA	rulesChestCrds0, X
		
		INC	rulesChestIdx

;***DEBUG
;		LDA	#$06

		PHA
		CMP	#$0F
		BNE	@perf
		
;		LDA	#$FF
;		CMP	game + GAME::pGF0Crd

		LDA	game + GAME::fGF0Out
		BEQ	@perf
		
		PLA
		JMP	rulesLandChest
		
		
@perf:
		PLA
		
		TAX
		PHA
		
		LDA	rulesChestStrsLo, X
		STA	dialogCCCCardTempF
		LDA	rulesChestStrsHi, X
		STA	dialogCCCCardTempF + 1
		
		PLA
		
		ASL
		TAX
		LDA	rulesChest0 + 1, X
		STA	dialogCCCCardTemp0 + 1
		LDA	rulesChest0, X
		STA	dialogCCCCardTemp0

		TAX
		LDA	rulesCCCrdProcsLo, X
		STA	dialogCCCCardTemp2
		LDA	rulesCCCrdProcsHi, X
		STA	dialogCCCCardTemp2 + 1

		CPX	#$03
		BNE	@cont

		LDA	#40
		STA	dialogCCCCardTemp0
		LDA	#115
		STA	dialogCCCCardTemp0 + 1

@cont:
		LDA	#$00
		STA	dialogCCCCardTemp9

		LDA 	#<dialogDlgCCCCard0
		LDY	#>dialogDlgCCCCard0
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog

		JSR	gamePlayersDirty
@exit:
		CLC
		LDA	#$00
		RTS
		
		
;-------------------------------------------------------------------------------
rulesLandChance:
;-------------------------------------------------------------------------------
		LDX	rulesChanceIdx
		LDA	rulesChanceCrds0, X
		
		INC	rulesChanceIdx
		
;***DEBUG
;		LDA	#$04
		
		PHA
		CMP	#$06
		BNE	@perf
		
;		LDA	#$FF
;		CMP	game + GAME::pGF1Crd

		LDA	game + GAME::fGF1Out
		BEQ	@perf
		
		PLA
		JMP	rulesLandChance
	
@perf:
		PLA
		TAX
		PHA
		
		LDA	rulesChanceStrsLo, X
		STA	dialogCCCCardTempF
		LDA	rulesChanceStrsHi, X
		STA	dialogCCCCardTempF + 1
		
		PLA

		ASL
		TAX
		LDA	rulesChance0 + 1, X
		STA	dialogCCCCardTemp0 + 1
		LDA	rulesChance0, X
		STA	dialogCCCCardTemp0

		TAX
		LDA	rulesCCCrdProcsLo, X
		STA	dialogCCCCardTemp2
		LDA	rulesCCCrdProcsHi, X
		STA	dialogCCCCardTemp2 + 1

		CPX	#$03
		BNE	@cont

		LDA	#25
		STA	dialogCCCCardTemp0
		LDA	#100
		STA	dialogCCCCardTemp0 + 1

@cont:
		LDA	#$01
		STA	dialogCCCCardTemp9
		
		LDA 	#<dialogDlgCCCCard0
		LDY	#>dialogDlgCCCCard0
		
		JSR	dialogSetDialog
		JSR	dialogDispDefDialog
		
@exit:
		CLC
		LDA	#$00
		RTS
		
		
;-------------------------------------------------------------------------------
rulesLandTax:
;-------------------------------------------------------------------------------
		LDA	game + GAME::varA
		CMP	#$04
		BNE	@test1
		
		LDA	#200
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		JMP	@dotax
		
@test1:
		CMP	#$26
		BNE	@exit
		
		LDA	#100
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
@dotax:
		LDX	#$06
		JSR	rulesSubCash

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptTax

		LDA	#<SFXLOWZAP
		LDY	#>SFXLOWZAP
		LDX	#$07
		JSR	SNDBASE + 6
		
@exit:
		CLC
		LDA	#$00

		RTS


;-------------------------------------------------------------------------------
rulesDoSetAllOwned:
;-------------------------------------------------------------------------------
		LDX	#$00

@loop:
		LDA	rulesSqr0, X
		CMP	game + GAME::varB
		BNE	@next
		
		LDA	sqr00 + 1, X
		ORA	#$40
		STA	sqr00 + 1, X
		
@next:
		INX
		INX
		CPX	#$50
		BNE	@loop
		
		RTS
	
	
;-------------------------------------------------------------------------------
rulesDoUnsetAllOwned:
;-------------------------------------------------------------------------------
		LDX	#$00

@loop:
		LDA	rulesSqr0, X
		CMP	game + GAME::varB
		BNE	@next
		
		LDA	sqr00 + 1, X
		AND	#$BF
		STA	sqr00 + 1, X
		
@next:
		INX
		INX
		CPX	#$50
		BNE	@loop
		
		RTS
		

;-------------------------------------------------------------------------------
rulesDoPurchDeed:
;	IN:	.X	=	square * 2
;		varB 	=	group
;		varC	=	group index for deed
;		varH	=	flag sub cash (0 = do it)
;	REQS	Z:FB,FC	=	player ptr
;
;-------------------------------------------------------------------------------
		TXA
		PHA
		
		LDX	game + GAME::varB
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDY	#GROUP::count
		LDA	($FD), Y
		STA	game + GAME::varG	;deed count in group

		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		STA	$FE
		PLA
		STA	$FD
		
		LDY	#DEED::pPurch
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

		LDA	game + GAME::varH	;Do we sub cash?
		BNE	@begin

		SEC
		LDY	#PLAYER::money
		LDA	($FB), Y
		SBC	game + GAME::varD
		INY	
		LDA	($FB), Y
		SBC	game + GAME::varE
		BMI	@skip			;Can afford?

		LDX	game + GAME::pActive
		JSR	rulesSubCash

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptBought
	
@begin:
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR	rulesAddEquity

		PLA
		TAX
		LDA	game + GAME::pActive
		STA	sqr00, X
		
		LDX	game + GAME::varB
		
		LDA	#musTuneBuy
		PHA

		DEX
		TXA
		CLC
		ADC	#PLAYER::oGrp01
		TAY
		LDA	($FB), Y
		TAX
		INX
		TXA
		STA	($FB), Y
			
		CMP	game + GAME::varG
		BNE	@done
		
		JSR	rulesDoSetAllOwned
		PLA
		LDA	#musTuneBuyAll
		PHA

@done:
		PLA
		JSR	SNDBASE + 0
		
		LDA	#$00
		STA	game + GAME::fMBuy
		RTS

@skip:
		PLA
		
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS


;-------------------------------------------------------------------------------
rulesDoCollateImprv:
;-------------------------------------------------------------------------------
		LDA	#$05
		STA	game + GAME::varA
		LDA	#$00
		STA	game + GAME::varB
		STA	game + GAME::varC
		STA	game + GAME::varQ

		STY	game + GAME::varF	
		STX	game + GAME::varR
		
		LDX	#$4E
@loop0:	
		LDA	rulesSqr0, X
		CMP	game + GAME::varR
		BNE	@next0

		LDY	#$80
		STY	$A3
		LDA	sqr00 + 1, X
		BIT	$A3
		BEQ	@tstprep
			
		INC	game + GAME::varQ
		
@tstprep:
		LDY	#$08
		STY	$A3
		BIT	$A3
		BEQ	@tsths
			
		LDA	#$05
		JMP	@tstmin
		
@tsths:
		AND	#$07		
		
@tstmin:
		CMP	game + GAME::varA
		BPL	@tstmax
		
		STA	game + GAME::varA
		
@tstmax:
		CMP	game + GAME::varB
		BMI	@next0
		
		STA	game + GAME::varB

@next0:
		DEX
		DEX
		BPL	@loop0

		LDA	game + GAME::varF
		CMP	#$FF
		BEQ	@exit
		
		ASL
		TAX
		LDA	sqr00 + 1, X
		
		LDY	#$08
		STY	$A3
		BIT	$A3
		BEQ	@currhs
			
		LDA	#$05
		JMP	@curr
		
@currhs:
		AND	#$07
		
@curr:
		STA	game + GAME::varC
		
@exit:
		RTS


;-------------------------------------------------------------------------------
rulesNextImprv:
;-------------------------------------------------------------------------------
		TAY
		PHA
		ASL
		TAX

		LDA	sqr00 + 1, X
		AND	#$40
		BNE	@tstgroup
	
@buzzbreak:	
		PLA
		
@buzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@tstgroup:
		LDA	rulesSqr0, X		
		TAX
		
		BNE	@tstupper
		
		JMP	@buzzbreak
		
@tstupper:
		CPX	#$09
		BMI	@collate

		JMP	@buzzbreak
		
@collate:
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		JSR 	rulesDoCollateImprv
		
		LDA	game + GAME::varD
		BEQ	@tstdist
		
		JMP	@buzzbreak
		
@tstdist:
		LDA	game + GAME::varA
		CMP	game + GAME::varB
		BEQ	@begin
		
		CMP	game + GAME::varC
		BEQ	@begin
		
		JMP	@buzzbreak
		
@begin:
		PLA
		ASL
		TAX

		LDA	sqr00 + 1, X		;Check for already at hotels
		AND	#$0F
		CMP	#$08
		BNE	@checkhouse
		
		JMP	@buzz
		
@checkhouse:
		CMP	#$04
		BEQ	@checkhotel
	
		LDY	game + GAME::cntHs
		BPL	@availhouse
		
		JMP	@buzz
		
@availhouse:
		BNE	@sethouse
		
		JMP	@buzz
		
@sethouse:
		TAY
		INY

		LDA	#musTuneHouse
		PHA

		TYA

		JMP	@tstOwn
		
@checkhotel:
		LDY	game + GAME::cntHt
		BPL	@availhotel
		
		JMP	@buzz
		
@availhotel:
		BNE	@sethotel
		
		JMP	@buzz

@sethotel:
		LDA	#musTuneHotel
		PHA

		LDA	#$08

@tstOwn:
		STA	game + GAME::varA

		LDA	sqr00, X		;Check current player owns deed
		CMP	game + GAME::pActive
		BEQ	@tstCash
		
		JMP	@buzzbreak

@tstCash:
		LDY	#GROUP::pImprv		;Get cost
		LDA	($FD), Y
		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		LDY	game + GAME::pActive	;Get player
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC

		LDY	#PLAYER::money
		LDA	($FB), Y
		SEC
		SBC	game + GAME::varD
		INY
		LDA	($FB), Y
		SBC	game + GAME::varE
		
		BPL	@update
		
		JMP	@buzzbreak
		
@update:
		LDA	sqr00 + 1, X		;Set house/hotel
		AND	#$F0
		ORA	game + GAME::varA
		STA	sqr00 + 1, X
		
		AND	#$0F
		CMP	#$08
		BEQ	@updht
		
		SEC				;Update house count
		LDA	game + GAME::cntHs
		SBC	#$01
		STA	game + GAME::cntHs
		
		JMP	@cont
		
@updht:
		SEC				;Update hotel count
		LDA	game + GAME::cntHt
		SBC	#$01
		STA	game + GAME::cntHt
		
		CLC				;Return houses
		LDA	game + GAME::cntHs
		ADC	#$04
		STA	game + GAME::cntHs

@cont:
		LDX	game + GAME::pActive
		JSR	rulesSubCash		;Charge player

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptBought
		
		LSR	game + GAME::varD
		
		JSR	rulesAddEquity

		PLA	
		JSR	SNDBASE + 0

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


;-------------------------------------------------------------------------------
rulesPriorImprv:
;-------------------------------------------------------------------------------
		TAY
		PHA
		ASL
		TAX

		LDA	rulesSqr0, X		
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE
		
		JSR 	rulesDoCollateImprv
		
		LDA	game + GAME::varD
		BEQ	@tstdist
		
@buzzbreak:
		PLA
		
@buzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@tstdist:
		LDA	game + GAME::varB
		CMP	game + GAME::varA
		BEQ	@tstimprv
		
		CMP	game + GAME::varC
		BEQ	@tstimprv
		
		JMP	@buzzbreak

@tstimprv:
		PLA
		ASL
		TAX
		
		LDA	sqr00 + 1, X
		AND	#$0F
		CMP	#$00
		BNE	@begin
		
		JMP	@buzz

@begin:
		CMP	#$08
		BEQ	@sethouse
		
		TAY
		DEY

		CLC
		LDA	game + GAME::cntHs
		ADC	#$01
		STA	game + GAME::cntHs

		TYA
		
		JMP	@update
		
@sethouse:
		CLC
		LDA	game + GAME::cntHt
		ADC	#$01
		STA	game + GAME::cntHt

		SEC
		LDA	game + GAME::cntHs
		SBC	#$04
		STA	game + GAME::cntHs

		LDA	#$04

@update:
		STA	game + GAME::varA

		LDA	sqr00 + 1, X
		AND	#$F0
		ORA	game + GAME::varA
		STA	sqr00 + 1, X

		LDY	#GROUP::pImprv
		LDA	($FD), Y

		LSR

		STA	game + GAME::varD
		LDA	#$00
		STA	game + GAME::varE
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptSold
		
		JSR	rulesAddCash
		
		JSR	rulesSubEquity

		LDA	#<SFXSLIDE
		LDY	#>SFXSLIDE
		LDX	#$07
		JSR	SNDBASE + 6

		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;-------------------------------------------------------------------------------
rulesUnmortgageImmed:
;-------------------------------------------------------------------------------
		ASL
		TAX
		STX	game + GAME::varG
		
		LDA	rulesSqr0, X		
		
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDX	game + GAME::varG
		
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@begin
		
		RTS
		
@begin:
		LDA	sqr00 + 1, X
		EOR	#$80
		STA	game + GAME::varA	;imprv
		
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC	;index
		
		LDA	rulesSqr0, X		
		STA	game + GAME::varB	;group

		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		STA	$FE
		PLA
		STA	$FD
		
		LDA	game + GAME::varA
		AND	#$80
		BNE	@mrtg

		LDY	#DEED::mFee
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

		LDY	#DEED::mValue
		CLC
		LDA	($FD), Y
		ADC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		ADC	game + GAME::varE
		STA	game + GAME::varE

		LDX	game + GAME::pActive
		JSR	rulesSubCash		

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptRepay
		
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR	rulesAddEquity

		LDA	#<SFXRENT2
		LDY	#>SFXRENT2
		LDX	#$07
		JSR	SNDBASE + 6

		JMP	@toggle
		
@mrtg:
		RTS
		
@toggle:
		LDX	game + GAME::varG
		LDA	game + GAME::varA
		STA	sqr00 + 1, X
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		RTS


;-------------------------------------------------------------------------------
rulesMortgageFeeImmed:
;-------------------------------------------------------------------------------
		ASL
		TAX
		STX	game + GAME::varG
		
		LDA	rulesSqr0, X		
		
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDX	game + GAME::varG
		
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@begin
		
		RTS
		
@begin:
		LDA	sqr00 + 1, X
		EOR	#$80
		STA	game + GAME::varA	;imprv
		
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC	;index
		
		LDA	rulesSqr0, X		
		STA	game + GAME::varB	;group
		TAX
		
		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		STA	$FE
		PLA
		STA	$FD
		
		LDY	#DEED::mFee
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

		LDX	game + GAME::pActive
		JSR	rulesSubCash		

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptFee
		
		LDA	#<SFXRENT1
		LDY	#>SFXRENT1
		LDX	#$07
		JSR	SNDBASE + 6
	
		RTS
		
		
rulesMortgageImmed:
		LDA	sqr00 + 1, X
		EOR	#$80
		STA	game + GAME::varA	;imprv

;***TODO:	Test for improvements here, too.

		STA	sqr00 + 1, X

		JSR	gameGetCardPtrForSquareImmed

		LDA	game + GAME::varA
		AND	#$80
		BNE	@mrtg

		RTS

@mrtg:
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		JSR	rulesAddCash
		
		JSR	rulesSubEquity

		LDA	#<SFXSLIDELOW
		LDY	#>SFXSLIDELOW
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptMortgage
		
@toggle:
		LDX	game + GAME::varG
		LDA	game + GAME::varA
		STA	sqr00 + 1, X
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		RTS


;-------------------------------------------------------------------------------
rulesMrtgCheckTrade:
;-------------------------------------------------------------------------------
		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		BEQ	@offer
		
		TAX
		DEX
@loop0:
		LDA	trddeeds0, X
		CMP	game + GAME::sSelect
		BEQ	@found
		
		DEX
		BPL	@loop0
		
@offer:
		LDA	trade1, Y
		BEQ	@notfound
		
		TAX
		DEX
@loop1:
		LDA	trddeeds1, X
		CMP	game + GAME::sSelect
		BEQ	@found
		
		DEX
		BPL	@loop1

@notfound:
		LDA	#$00
		RTS
		
@found:
		LDA	#$01
		RTS


;-------------------------------------------------------------------------------
rulesToggleMrtg:
;-------------------------------------------------------------------------------
		LDA	menuManage0CheckTrade
		BEQ	@start
		
		JSR	rulesMrtgCheckTrade
		BEQ	@start
		
		JSR	prmptInTrade
		JMP	@buzz
		
@start:
		LDA	game + GAME::sSelect
		
		TAY
		ASL
		TAX

		LDA	rulesSqr0, X		
		TAX
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE
		
		JSR 	rulesDoCollateImprv
		
		LDA	game + GAME::varA
		BEQ	@cont0
		
@buzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
		LDX	#$07
		JSR	SNDBASE + 6
		
		RTS
		
@cont0:
		LDA	game + GAME::varB
		BEQ	@cont1
		
		JMP	@buzz
		
@cont1:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
;		LDY	#PLAYER::square
;		LDA	($FB), Y

		LDA	game + GAME::sSelect
		CMP	#$FF
		BNE	@test
		
		JMP	@buzz
	
@test:
		ASL
		TAX
		
		STX	game + GAME::varG
		
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@begin
		
		JMP	@buzz
		
@begin:
;***TODO:	Link into action code instead.

		LDA	sqr00 + 1, X
		EOR	#$80
		STA	game + GAME::varA	;imprv
		
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC	;index
		
		LDA	rulesSqr0, X		
		STA	game + GAME::varB	;group

		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		STA	$FE
		PLA
		STA	$FD
		
		LDA	game + GAME::varA
		AND	#$80
		BNE	@mrtg

		LDY	#DEED::mFee
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

		LDY	#DEED::mValue
		CLC
		LDA	($FD), Y
		ADC	game + GAME::varD
		STA	game + GAME::varD
		STA	game + GAME::varH
		INY
		LDA	($FD), Y
		ADC	game + GAME::varE
		STA	game + GAME::varE
		STA	game + GAME::varI

		LDA	game + GAME::varD
		LDY	game + GAME::varE
		
;		So, if money less than A, Y - clear carry else set
		JSR	gamePlayerHasFunds
		BCS	@havefunds
		
		JMP	@buzz

@havefunds:
		LDA	game + GAME::varH
		STA	game + GAME::varD
		LDA	game + GAME::varI
		STA	game + GAME::varE

		LDX	game + GAME::pActive
		JSR	rulesSubCash		

		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptRepay
		
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR	rulesAddEquity

		LDA	#<SFXRENT2
		LDY	#>SFXRENT2
		LDX	#$07
		JSR	SNDBASE + 6

		JMP	@toggle
		
@mrtg:
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE

		JSR	rulesAddCash
		
		JSR	rulesSubEquity

		LDA	#<SFXSLIDELOW
		LDY	#>SFXSLIDELOW
		LDX	#$07
		JSR	SNDBASE + 6
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptMortgage
		
@toggle:
		LDX	game + GAME::varG
		LDA	game + GAME::varA
		STA	sqr00 + 1, X
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		RTS
		

;-------------------------------------------------------------------------------
rulesDoXferDeed:
;-------------------------------------------------------------------------------
		LDA	sqr00, X
		PHA

		LDA	game + GAME::pActive
		STA	sqr00, X
		
		LDX	game + GAME::varB
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE

		LDY	#GROUP::count
		LDA	($FD), Y
		STA	game + GAME::varG	;deed count in group
		
;		LDX	game + GAME::varB
		DEX
		TXA
		CLC
		ADC	#PLAYER::oGrp01
		TAY
		LDA	($FB), Y
		TAX
		INX
		TXA
		STA	($FB), Y

		CMP	game + GAME::varG
		BNE	@unset
	
		JSR	rulesDoSetAllOwned

		LDA	#musTuneBuyAll
		JSR	SNDBASE + 0
		
		JMP	@cont
		
@unset:	
		JSR	rulesDoUnsetAllOwned
		
		LDA	#musTuneBuy
		JSR	SNDBASE + 0
		
@cont:
		LDA	game + GAME::varC	;group index
		ASL
		CLC
		ADC	#GROUP::mDeed1
		TAY
		
		LDA	($FD), Y		;now pts to card
		PHA
		INY
		LDA	($FD), Y
		
		STA	$FE
		PLA
		STA	$FD

		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JSR	rulesAddEquity
		
		PLA
		TAX

		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDX	game + GAME::varB
		DEX
		TXA
		CLC
		ADC	#PLAYER::oGrp01
		TAY
		LDA	($FB), Y
		TAX
		DEX
		TXA
		STA	($FB), Y
		
		JSR	rulesSubEquity
		
@exit:

		RTS
		


;-------------------------------------------------------------------------------
rulesTradeTitleDeed:
;-------------------------------------------------------------------------------
		STX	game + GAME::varA	;square
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	game + GAME::varA

		ASL
		TAX

		STA	game + GAME::varF	;square indexing

		LDA	sqr00, X
		CMP	#$FF
		BNE 	@test
		
		RTS
		
@test:
		CMP	game + GAME::pActive
		BNE	@begin
		
		RTS
		
@begin:
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC	;index
		
		LDA	rulesSqr0, X		
		STA	game + GAME::varB	;group
		
		CMP	#$01
		BMI	@exit
		
		CMP	#$0B
		BPL	@exit
		
		LDX	game + GAME::varF
		JSR	rulesDoXferDeed
		
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
@exit:
		RTS

		
;-------------------------------------------------------------------------------
rulesBuyTitleDeed:
;-------------------------------------------------------------------------------
		STY 	game + GAME::varH	;store whether or not to sub cash
		TXA
		PHA

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDA	#$01			;Do we also get the square or 
		CMP	game + GAME::varH	;use the one passed in?
		BNE	@getsqr
		
		PLA				;Use one passed in
		JMP	@havesqr
				
@getsqr:
		PLA				;Use the one the player is on
		LDY	#PLAYER::square
		LDA	($FB), Y
		
@havesqr:		
		STA	game + GAME::varA	;square
		ASL
		TAX

		STA	game + GAME::varF	;square indexing
		
		LDA	sqr00, X
		CMP	#$FF
		BEQ 	@begin
		
		RTS
		
@begin:
		LDA	rulesSqr0 + 1, X
		STA	game + GAME::varC	;index
		
		LDA	rulesSqr0, X		
		STA	game + GAME::varB	;group
		
		CMP	#$01
		BMI	@exit
		
		CMP	#$0B
		BPL	@exit
		
		LDX	game + GAME::varF
		LDA	sqr00, X
		
		JSR	rulesDoPurchDeed
		
@exit:
		RTS


;-------------------------------------------------------------------------------
rulesDoPlayerElimin:		
;-------------------------------------------------------------------------------
		LDA	($FB), Y		;Set player not alive
		AND	#$FC
		STA	($FB), Y
		
		DEC	game + GAME::pCount	;Decrement player count
		LDA	game + GAME::pCount
		CMP	#$01
		BNE	@begin
		
		JSR	rulesDoGameOver		;Only 1 player left, game over
		RTS

@begin:
		LDY	#PLAYER::equity		;Payout whatever we can
		LDA	($FB), Y
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		STA	game + GAME::varE
		
		LDA	game + GAME::pActive	;Find who we lost to
		TAX
		ASL
		CLC
		ADC	#PLAYER::mDAcc1
		TAY
		JMP	@next0
		
@loop0:
		LDA	($FB), Y
		BNE	@lostplyr
		
		INY
		LDA	($FB), Y
		BNE	@lostplyr

		INY
		
@next0:
		INX
		CPX	#$06
		BNE	@tstloop0

@wrap0:
		LDY	#PLAYER::mDAcc0
		LDX	#$00
		
@tstloop0:
		CPX	game + GAME::pActive
		BNE	@loop0

@lostbank:					
		JSR	rulesDoPlyrLostBank	;Player lost to bank
		RTS

@lostplyr:
		TXA
		PHA

		LDA	game + GAME::varE
		BMI	@skipcash		;This can't happen but
						;safeguard against it
		
		LDA	game + GAME::pActive
		STA	game + GAME::varU
		PLA
		STA	game + GAME::pActive

		TAY
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC

		JSR	rulesAddCash

		LDX	game + GAME::pActive
		LDA	game + GAME::varU
		STA	game + GAME::pActive
		
		TAY
		LDA	plrLo, Y
		STA	$FB
		LDA	plrHi, Y
		STA	$FC

@skipcash:
		JSR	rulesDoPlyrLostPlyr	;Player lost to other player
		RTS


;-------------------------------------------------------------------------------
rulesDoGameOver:
;-------------------------------------------------------------------------------
		LDA	#$05
		STA	game + GAME::gMode
		
		JSR	rulesDoNextPlyr
		
		JSR	gameUpdateMenu
		
		JSR	rulesFocusOnActive
		BCC	@juststats

;		LDA	#$01
;		STA	game + GAME::dirty
		RTS

@juststats:		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		

		RTS


rulesInitTradeData:
		LDX	#.sizeof(TRADE) - 1	
		LDA	#$00
@loop0:
		STA 	trade0, X
		STA 	trade1, X
		
		DEX
		BPL	@loop0
		
		LDX	#$1B
@loop1:
		STA	trddeeds0, X
		STA	trdrepay0, X
		STA	trddeeds1, X
		STA	trdrepay1, X

		DEX
		BPL	@loop1

		RTS
		

;-------------------------------------------------------------------------------
rulesInitEliminToPlyr:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		STX	game + GAME::pElimin
		LDX	game + GAME::gMode
		STX	game + GAME::gMdElim
		
		STA	game + GAME::pActive
		
		JSR	menuElimin0RemWlthRecalc
		
		LDA	#$00
		STA	menuElimin0HaveOffer
		
		JSR	rulesInitTradeData

		LDX	#$00
@loop:
		LDA	sqr00, X
		CMP	game + GAME::pElimin
		
		BNE	@next
		
		LDA	#$80
		STA	sqr00 + 1, X
		
@next:
		INX
		INX
		CPX	#$50
		BNE	@loop

		LDX	#TRADE::player
		LDA	game + GAME::pElimin
		STA	trade1, X
		LDA	game + GAME::pActive
		STA	trade0, X

		LDA	#$04
		STA	game + GAME::gMode
		RTS
		

;-------------------------------------------------------------------------------
rulesInitEliminToBank:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		STX	game + GAME::pElimin
		STX	game + GAME::varA

		JSR	menuElimin0RemWlthRecalc

		LDX	#TRADE::player
		LDA	#$FF
		STA	trade1, X
		LDA	game + GAME::pActive
		STA	trade0, X

;		LDA	game + GAME::pElimin
;		STA	game + GAME::pActive

		LDA	#$00
		STA	menuElimin0HaveOffer

		JSR	rulesInitTradeData

		LDX	#$00
		STX	game + GAME::varB
@loop:
		LDA	sqr00, X
		CMP	game + GAME::varA
		
		BNE	@next
		
		LDA	#$00
		STA	sqr00 + 1, X
		
		LDA	#$FF
		STA	sqr00, X
		
		LDY	#TRADE::cntDeed
		LDA	trade0, Y
		TAY
		LDA	game + GAME::varB
		STA	trddeeds0, Y
		INY
		TYA
		LDY	#TRADE::cntDeed
		STA	trade0, Y
		
@next:
		INC	game + GAME::varB
		INX
		INX
		CPX	#$50
		BNE	@loop

		JSR	rulesDoNextPlyr
		
		LDA	#$01
		STA	game + GAME::fTrdTyp
		
;***FIXME:	Do I need to change game + GAME::pActive?

		LDA	#$01
		STA	ui + UI::fActInt		
		
		JSR	gamePerfTradeFull
		RTS
		

;-------------------------------------------------------------------------------
rulesDoPlyrLostPlyr:
;-------------------------------------------------------------------------------
		TXA

		LDX	#$80
		STX	game + GAME::varB

		LDX	game + GAME::pGF0Crd
		CPX	game + GAME::pActive
		BNE	@gf1
		
		STA	game + GAME::pGF0Crd
@gf1:
		LDX	game + GAME::pGF1Crd
		CPX	game + GAME::pActive
		BNE	@sqrs
		
		STA	game + GAME::pGF1Crd

@sqrs:
		JSR	rulesInitEliminToPlyr

@cont:
		JSR	gameUpdateMenu
		
		BCC	@juststats

;		LDA	#$01
;		STA	game + GAME::dirty
		RTS

@juststats:		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		

		RTS
		

;-------------------------------------------------------------------------------
rulesDoPlyrLostBank:
;-------------------------------------------------------------------------------
		LDA	#$00
		STA	game + GAME::varB

		LDA	#$FF			;Return GO Free cards to deck
		
		LDX	game + GAME::pGF0Crd
		CPX	game + GAME::pActive
		BNE	@gf1
		
		STA	game + GAME::pGF0Crd
@gf1:
		LDX	game + GAME::pGF1Crd
		CPX	game + GAME::pActive
		BNE	@sqrs
		
		STA	game + GAME::pGF1Crd
		
@sqrs:
		JSR	rulesInitEliminToBank

@cont:
		JSR	gameUpdateMenu
		
		BCC	@juststats

;		LDA	#$01
;		STA	game + GAME::dirty
		RTS

@juststats:		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty		

		RTS
	
	
;-------------------------------------------------------------------------------
rulesDoNextPlyr:
;-------------------------------------------------------------------------------
		JSR	prmptClear

		LDY	#PLAYER::status		;switch off gone to gaol
		LDA	($FB), Y
		AND	#$BF
		STA	($FB), Y
		
		LDA	#$00
		STA	game + GAME::nDbls
		STA	game + GAME::dieRld
		STA	game + GAME::dieA
		STA	game + GAME::dieB

		LDX	game + GAME::pActive
		JMP	@next

@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		LDA	($FB), Y
		AND	#$01
		
		BNE	@exit
		
@next:
		INX
		CPX	#$06
		BNE	@tstloop
		
@wrap:		
		LDX	#$00
		
@tstloop:
		CPX	game + GAME::pActive
		BNE	@loop

@exit:
		STX	game + GAME::pActive
		
		RTS


;-------------------------------------------------------------------------------
rulesNextTurn:
;-------------------------------------------------------------------------------
		LDA	game + GAME::gMode
		CMP	#$00
		BEQ	@normal
	
		CMP	#$05
		BNE	@auctn
		
		RTS
		
@auctn:
		CMP	#$01
		BNE	@intrpt
		
		JSR	gameNextAuction
		RTS
		
@intrpt:
		RTS

@normal:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		
		LDA	($FB), Y
		AND	#$02
		BEQ	@tstdice
		
		JSR	rulesDoPlayerElimin
		RTS
		
@tstdice:		
		LDA	game + GAME::dieRld
		CMP	#$01
		BEQ	@begin
		
		RTS
		
@begin:
		LDY	#PLAYER::money + 1
		LDA	($FB), Y
		BPL	@cont0
		
		RTS
		
@cont0:
		LDA	game + GAME::cntHs
		BPL	@cont1
		
		RTS
		
@cont1:

		LDA	game + GAME::cntHt
		BPL	@cont2
		
		RTS
		
@cont2:
		JSR	rulesDoNextPlyr
		
		JSR	gameUpdateMenu
		
		JSR	rulesFocusOnActive
		BCC	@juststats

;		LDA	#$01
;		STA	game + GAME::dirty
		RTS

@juststats:		
		LDA	#$02
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS
		
		
rulesDoTestAllOwned:
;***FIXME:	I'm doing this group lookup a lot now.  I should optimise it
;		by indexing the squares for the groups.

		LDX	#$00
@loop:		
		LDA	rulesSqr0, X
		CMP	game + GAME::varA
		BNE	@next
		
		LDA	sqr00, X
		CMP	game + GAME::varK
		BNE	@next
		
		LDA	sqr00 + 1, X
		AND	#$40
		BEQ	@next
		
		LDA	#$01
		RTS
		
@next:
		INX
		INX
		CPX 	#$50
		BNE	@loop
		
		LDA	#$00
		RTS
	
	
rulesDoSetPriority:
		LDX	#$00
@loop0:
		STX	game + GAME::varG		;varC = group index
		
		LDA	rulesGrpPriority, X	
		STA	game + GAME::varA		;varA = group
		
		JSR	rulesDoTestAllOwned
		BNE	@setall
		
		LDA	#$01
		LDX	game + GAME::varG
		STA	rulesPriMrtg, X
		LDA	#$00
		STA	rulesPriAll, X
		
		JMP	@next0
		
@setall:
		LDA	#$00
		LDX	game + GAME::varG
		STA	rulesPriMrtg, X
		LDA	#$01
		STA	rulesPriAll, X
		
@next0:
		INX
		CPX	#$0A
		BNE	@loop0

		RTS
	

rulesDoCommitMrtg:
;		varJ	= group
;		varK	= player

		LDA	#$00
		STA	game + GAME::varL
		
@loop0:
		LDX	game + GAME::varL
		BPL	@fetchsqr
		
		JMP	@complete
		
@fetchsqr:
		LDA	game + GAME::varJ
		CMP	#$09
		BNE	@tstutil
		
		JSR	rulesStnSqrForIndex
		JMP	@begin0
		
@tstutil:
		CMP	#$0A
		BNE	@street
		
		CPX	#$02
		BPL	@skipidx

		JSR	rulesUtilSqrForIndex
		JMP	@begin0

@street:
		CPX	#$03
		BNE	@docalc
		
@skipidx:
		INC	game + GAME::varL
		JMP	@loop0
		
@docalc:
		LDA	#$1C
		LDX	game + GAME::varL
		

@loop1:
		INX
		CPX	#$03
		BEQ	@cont0
		
		SEC
		SBC	#$0E
		JMP	@loop1
		
@cont0:
		CLC
		ADC	game + GAME::varJ
		
		TAX
		LDA	rulesGrpSqrs0, X
		
		CMP	#$FF
		BNE	@begin0
		
		DEC	game + GAME::varL
		JMP	@loop0

@begin0:
		STA	game + GAME::varI
		
		ASL
		TAX
		STX	game + GAME::varH
		
		LDA	sqr00, X
		CMP	game + GAME::varK
		BNE	@next
		
		LDX	game + GAME::varI
		LDA	rulesSqrImprv, X
		AND	#$80
		BNE	@next

		LDX	game + GAME::varJ
		LDY	#$FF

		JSR	rulesDoCollateImprv
		
		LDA	game + GAME::varA
		BNE	@next
		
		LDX	game + GAME::varI
		LDA	rulesSqrImprv, X
		ORA	#$80
		STA	rulesSqrImprv, X
		
		LDA	#UI_ACT_MRTG
		STA	$68
		LDA	game + GAME::varK
		STA	$69
		LDA	game + GAME::varI
		STA	$6A
		
		JSR	uiEnqueueAction
		
		LDA	game + GAME::varI
		JSR	gameGetCardPtrForSquare
		
		LDY	#DEED::mValue
		
		CLC
		LDA	($FD), Y
		ADC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		ADC	game + GAME::varE
		STA	game + GAME::varE
		
		JSR	gameAmountIsLessDirect
		BCS	@complete
		
@next:
		INC	game + GAME::varA
		LDA	game + GAME::varA
		CMP	#$04
		BEQ	@incomplete
		
		JMP	@loop0

@incomplete:
		LDA	#$00
		RTS
		
@complete:
		LDA	#$01
		
		RTS


rulesDoProcRecoverMrtg:
		LDX	#$00
@loop0:
		STX	game + GAME::varG		;varG = group index
		
		LDA	rulesGrpPriority, X	
		STA	game + GAME::varJ		;varJ = group

		LDA	rulesPriMrtg, X
		BEQ	@next0
		
		JSR	rulesDoCommitMrtg
		BNE	@complete
				
@next0:
		LDX	game + GAME::varG

		INX
		CPX	#$0A
		BNE	@loop0
		
		LDA	#$00
		RTS
		
@complete:
		LDA	#$01
		RTS
	

rulesDoCommitSellAtLevel:
;		For each square in group, sell improvements at level 
;		until sold enough or positive houses?

;		Must return not handled if negative houses at end

;		Update level when cleared

;		Update house count if level is 5 or below
;		Update hotel count if level is 5

;		game + GAME::varJ = group
;		game + GAME::varB = level
;		game + GAME::varH = house count
;		game + game::varI = hotel count
;		game + GAME::varK = player
;		rulesSqrImprv for improvement information

;		until (sold enough and pos houses) or none found
;			find next matching square (has count)
;				
;			check varI for 5 else varH
;				sell improvement
;				check complete
;				complete, exit
;				else next
;			none found at level?
;				decrement level
;				not complete
;
;		game + GAME::varA = group square idx
;		game + GAME::varF = square 
;		game + GAME::varL = new imprv

		LDX	game + GAME::varJ
		
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE
		
		LDA	#$00
		STA	game + GAME::varA
		
@loop0:
		LDA	#$00
		LDX	game + GAME::varA
@loop1:
		DEX
		BMI	@cont0
		CLC
		ADC	#$0E
		JMP	@loop1
		
@cont0:
		CLC
		ADC	game + GAME::varJ
		
		TAX
		LDA	rulesGrpSqrs0, X
		STA	game + GAME::varF
		
		CMP	#$FF
		BNE	@begin0
		
		JMP	@incompletedn

@begin0:
		ASL
		TAX
		LDA	sqr00, X
		CMP	game + GAME::varK
		BEQ	@begin1
		
		JMP	@incompletedn
		
@begin1:
		LDX	game + GAME::varF
		LDA	rulesSqrImprv, X
		AND	#$08
		BEQ	@houses0
		
		LDA	#$05
		JMP	@cont1
		
@houses0:
		LDA	rulesSqrImprv, X
		AND	#$07
		
@cont1:

		CMP	game + GAME::varB
		BNE	@donext

		LDA	#UI_ACT_SELL
		STA	$68
		LDA	game + GAME::varK
		STA	$69
		LDA	game + GAME::varF
		STA	$6A
		
		JSR	uiEnqueueAction
		
		LDA	game + GAME::varB
		CMP	#$05
		BNE	@houses1
		
		INC	game + GAME::varI
		LDA	game + GAME::varH
		SEC
		SBC	#$04
		STA	game + GAME::varH
	
		LDX	game + GAME::varF
		LDA	rulesSqrImprv, X
		
		AND	#$F0
		ORA	#$04
		STA	rulesSqrImprv, X
	
		JMP	@cont2
	
@houses1:	
		CLC
		LDA	game + GAME::varH
		ADC	#$01
		STA	game + GAME::varH
		
		LDX	game + GAME::varB
		DEX
		STX	game + GAME::varL
		
		LDX	game + GAME::varF
		LDA	rulesSqrImprv, X
		
		AND	#$F0
		ORA	game + GAME::varL
		STA	rulesSqrImprv, X
		
@cont2:
		LDY	#GROUP::pImprv
		LDA	($FD), Y
		LSR
		CLC
		ADC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	#$00
		ADC	game + GAME::varE
		STA	game + GAME::varE
		
@tstnext:
		LDA	game + GAME::varH
		BMI	@donext
		
		JSR	gameAmountIsLessDirect
		BCC	@donext
		
@complete:
		LDA	#$01
		RTS
		
@donext:
		INC	game + GAME::varA
		LDA	game + GAME::varA
		CMP	#$03
		BEQ	@incompletedn
		
		JMP	@loop0
		
@incompletedn:
		DEC	game + GAME::varB
@incomplete:
		LDA	#$00
		
		RTS
		

rulesDoCommitSellHotels:
		JSR	rulesDoCommitSellAtLevel
		RTS
	
	
rulesDoCommitSellHouses:
;		Must continue to break down houses while negative houses
;		game + GAME::varB = level
;		game + GAME::varH = house count

@loop:
		JSR	rulesDoCommitSellAtLevel
		BNE	@complete
		
		LDA	game + GAME::varB
		BEQ	@incomplete

		LDA	game + GAME::varH
		BMI	@loop

		JSR	gameAmountIsLessDirect
		BCC	@loop

@complete:
		LDA	#$01
		RTS

@incomplete:
		LDA	#$00
		RTS
		
	
rulesDoCopyImprv:
		LDX	#$00
		LDY	#$00
@loop:
		LDA	sqr00 + 1, X
		STA	rulesSqrImprv, Y		

		INX
		INX
		INY
		
		CPX	#$50
		BNE	@loop
		
		RTS
		
	
rulesDoProcRecoverAll:
;		For each group in the priority lists do
;			Is it in this list? 

;				Is group 09/0A?  goto handle mortgage

;				rulesDoCollateImprv

;				has improvements?

;					no - handle mortgage

;					yes - handle hotels?

;						handle houses
		LDA	game + GAME::cntHs
		STA	game + GAME::varH
		LDA	game + GAME::cntHt
		STA	game + GAME::varI
		
		
		LDX	#$00
@loop0:
		STX	game + GAME::varG		;varG = group index
		
		LDA	rulesGrpPriority, X	
		STA	game + GAME::varJ		;varJ = group

		LDA	rulesPriAll, X
		BEQ	@next0
		
		LDA	game + GAME::varJ
		CMP	#$09
		BEQ	@handleMrtg
		
		LDA	game + GAME::varJ
		CMP	#$0A
		BEQ	@handleMrtg

		LDX	game + GAME::varJ
		LDY	#$FF

		JSR	rulesDoCollateImprv
		
		LDA	game + GAME::varB
		BEQ	@handleMrtg
		
		CMP	#$05
		BNE	@handleHouses
		
		JSR	rulesDoCommitSellHotels
		BNE	@complete
		
@handleHouses:
		JSR	rulesDoCommitSellHouses
		BNE	@complete

@handleMrtg:
		JSR	rulesDoCommitMrtg
		BNE	@complete
				
@next0:
		LDX	game + GAME::varG

		INX
		CPX	#$0A
		BNE	@loop0
		
		LDA	#$00
		RTS
		
@complete:		
		RTS
	
	
rulesAutoRecover:
		STA	game + GAME::varO		;varO,P = amount
		STY	game + GAME::varP
		STX	game + GAME::varK		;varF = player
		
		JSR	rulesDoCopyImprv
		
		LDA	#$00
		STA	game + GAME::varD		;varD,E = recovered amt
		STA	game + GAME::varE
		
		JSR	rulesDoSetPriority

		JSR	rulesDoProcRecoverMrtg
		BNE	@tstcomplete
		
		JSR	rulesDoProcRecoverAll

@tstcomplete:
		LDA	ui + UI::cActns
		BEQ	@incomplete

		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction

		LDA	#$01
		RTS

@incomplete:
		LDA	#$00
		RTS


rulesAutoPay:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::money + 1
		LDA	($FB), Y
		BPL	@incomplete
		
		DEY
		LDA	($FB), Y
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		STA	game + GAME::varE
		
		SEC
		LDA	#$00
		SBC	game + GAME::varD
		STA	game + GAME::varD
		LDA	#$00
		SBC	game + GAME::varE
		
		TAY
		LDA	game + GAME::varD
		
		JSR	rulesAutoRecover
		
		LDA	ui + UI::cActns
		BEQ	@incomplete
		
@complete:
		LDA	#$01
		RTS
		
@incomplete:	
		LDA	#$00
		RTS
		
		
rulesDoGetOwnCount:
;	IN:	varU	=	square
;	OUT:	varA	=	own count
;	USES:	varB	=	player group own index

		LDA	#$00
		STA	game + GAME::varA
		
		LDA	game + GAME::varU
		ASL
		TAX
		LDA	rulesSqr0, X
		TAX

		DEX
		TXA
		
		CMP	#$FF
		BEQ	@exit
		
		CLC
		ADC	#PLAYER::oGrp01
		STA	game + GAME::varB
		
		LDX	#$00
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
		
		LDY	game + GAME::varB
		LDA	($FB), Y
		BEQ	@next
		
		INC	game + GAME::varA
		
@next:
		INX
		CPX	#$06
		BNE	@loop
		
@exit:
		LDA	game + GAME::varA

		RTS
		
		
rulesDoGetLastOwn:
;	IN:	varU	=	square
;	OUT:	varA	=	last player owns
;	USES:	varB	=	player group own index

		LDA	#$FF
		STA	game + GAME::varA
		
		LDA	game + GAME::varU
		ASL
		TAX
		LDA	rulesSqr0, X
		TAX
		
		DEX
		TXA
		
		CMP	#$FF
		BEQ	@exit
		
		CLC
		ADC	#PLAYER::oGrp01
		STA	game + GAME::varB
		
		LDX	#$00
@loop:
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::status
		LDA	($FB), Y
		AND	#$01
		BEQ	@next
		
		LDY	game + GAME::varB
		LDA	($FB), Y
		BEQ	@next
		
		STX	game + GAME::varA
		
@next:
		INX
		CPX	#$06
		BNE	@loop
		
@exit:
		LDA	game + GAME::varA
		
		RTS
		
		
		
rulesAutoBuy:
;	IN:	.X	=	square
;
;	USED:	varU	=	square
;		varV-X  =	wealth
;		varD-E	=	temp calc
;		varO-P 	=	temp calc
;		varM-N	=	cost
;		varS-T	=	player money

;	Get cost for square
		STX	game + GAME::varU
		TXA
		JSR	gameGetCardPtrForSquare
	
		LDY	#DEED::pPurch
		LDA	($FD), Y
		STA	game + GAME::varM
		INY
		LDA	($FD), Y
		STA	game + GAME::varN
	
;	Get cash for player
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
	
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	game + GAME::varS
		INY
		LDA	($FB), Y
		STA	game + GAME::varT
		
;	Can afford to snap up?  299 < cash - cost
		LDA	#<299
		STA	game + GAME::varD
		LDA	#>299
		STA	game + GAME::varE
		
		SEC
		LDA	game + GAME::varS
		SBC	game + GAME::varM
		STA	game + GAME::varO
		LDA	game + GAME::varT
		SBC	game + GAME::varN
		STA	game + GAME::varP

;		D, E < (O, P) -> SEC | CLC
		JSR	gameAmountIsLessDirect
		BCS	@tstwant
		
		JMP	@purchase

@tstwant:
		
;	***TODO:  Check gambling on auction here?

;	Have wealth at all?
		LDY	#PLAYER::equity
		CLC
		LDA	($FB), Y
		ADC	game + GAME::varS
		STA	game + GAME::varV
		INY
		LDA	($FB), Y
		ADC	game + GAME::varT
		STA	game + GAME::varW
		LDA	#$00
		ADC	#$00
		STA	game + GAME::varX
		
		SEC
		LDA	game + GAME::varV
		SBC	game + GAME::varM
		STA	game + GAME::varV
		LDA	game + GAME::varW
		SBC	game + GAME::varN
		STA	game + GAME::varW
		LDA	game + GAME::varX
		SBC	#$00
		STA	game + GAME::varX
		
		BPL	@canwant
		
		JMP	@pass

@canwant:
		LDA	game + GAME::varS
		STA	game + GAME::varO
		LDA	game + GAME::varT
		STA	game + GAME::varP

;	Do I really want?  
;		have cash >= 50% of cost and either no one owns group or
;		only 2 or fewer do

		LDA	game + GAME::varM
		STA	game + GAME::varD
		LDA	game + GAME::varN
		STA	game + GAME::varE
		
		ASL
		ROR	game + GAME::varE
		ROR	game + GAME::varD
		
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCS	@tstplease
	
		JSR	rulesDoGetOwnCount
		BEQ	@purchase
		CMP	#$03
		BMI	@purchase

@tstplease:
;	Do I really really want?
;		have cash >= 25% of cost and is station or I own 1 or more and 
;		no one else does or only 1 does

		LDA	game + GAME::varE
		ASL
		ROR	game + GAME::varE
		ROR	game + GAME::varD

;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCS	@pass

		LDA	game + GAME::varU
		ASL
		TAX
		LDA	rulesSqr0, X
		CMP	#$09
		BEQ	@purchase

		JSR	rulesDoGetOwnCount
		CMP	#$00
		BNE	@pass
		
		CMP	#$02
		BPL	@pass
		
;		JSR	rulesDoGetLastOwn
;		CMP	game + GAME::pActive
;		BNE	@pass

@purchase:
;	On purchase wanted
;		Check cash (cost - cash > 0) is sufficient

		SEC
		LDA	game + GAME::varM
		SBC	game + GAME::varS
		STA	game + GAME::varD
		LDA	game + GAME::varN
		SBC	game + GAME::varT
		STA	game + GAME::varE
		
		BMI	@cont
		BNE	@recover
	
		LDA	game + GAME::varD
		BEQ	@cont
		
@recover:
@debug_trap0:
;			Recover calculated amt
		LDA	game + GAME::varD		;.A,.Y = amount
		LDY	game + GAME::varE
		LDX	game + GAME::pActive		;.X = player
			
		JSR	rulesAutoRecover
			
@cont:
;		Buy deed
		LDA	#UI_ACT_BUYD
		STA	$68
		LDA	game + GAME::pActive
		STA	$69
		LDA	game + GAME::varU
		STA	$6A
		
		JSR	uiEnqueueAction

;		Init Process
		LDA	ui + UI::cActns
		BEQ	@pass
		
@complete:
;		Return 1
		LDA	#$01
		RTS

@pass:
;	On pass
;	
;		TODO:  Go to auction?
;
;		Return 0
		LDA	#$00
		RTS
		

rulesUpdateValueIfLess:
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCS	@exit
		
		LDA	game + GAME::varO
		STA	game + GAME::varD
		LDA	game + GAME::varP
		STA	game + GAME::varE
		
@exit:
		RTS


rulesSuggestBaseReserve:
;		game + GAME::varD,E = value
;
;		game + GAME::varJ = group
;		game + GAME::varU = square
;		game + GAME::varH = improvements
;		game + GAME::varO,P = temp value
;		game + GAME::varM,N = temp value
;
		LDA	#$00
		STA	game + GAME::varD
		STA	game + GAME::varE

;	Test all brown - orange street groups owned by other player
		LDX	#$01
@loop0:
		STX	game + GAME::varJ
		
		LDA	rulesGrpSqrs2, X
		CMP	#$FF
		BNE	@havesqr0
		
		LDA	rulesGrpSqrs1, X
		CMP	#$FF
		BEQ	@next0
		
@havesqr0:
		STA	game + GAME::varU
		ASL
		TAX
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@next0
		
		CMP	#$FF
		BEQ	@next0
		
		TAY
		LDA	plrLo, Y
		STA	$A3
		LDA	plrHi, Y
		STA	$A4
		LDY	#PLAYER::status
		LDA	($A3), Y
		AND	#$01
		BEQ	@next0
		
		LDA	sqr00 + 1, X
		AND	#$08
		BNE	@hotel0
		
		LDA	sqr00 + 1, X
		AND	#$07
	
		JMP	@cont0
		
@hotel0:
		LDA	#$05
		
@cont0:
		STA	game + GAME::varH
		
;		If no houses set value to rent if lower
;		Else set value to rent for improvement has if lower

		JSR	gameGetCardPtrForSquareImmed
		
		CLC
		LDA	game + GAME::varH
		ASL
		ADC	#STREET::mRent

		TAY
		LDA	($FD), Y
		STA	game + GAME::varO
		INY
		LDA	($FD), Y
		STA	game + GAME::varP
		
		JSR	rulesUpdateValueIfLess

@next0:
		LDX	game + GAME::varJ
		
		INX
		CPX	#$05
		BNE	@loop0


;	Copy value to temp value
		LDA	game + GAME::varD
		STA	game + GAME::varM
		LDA	game + GAME::varE
		STA	game + GAME::varN
		
		LDA	#$00
		STA	game + GAME::varD
		STA	game + GAME::varE
		

;***TODO:	Make a routine that does this since its "unrolled" 2 times for
;		no good reason.
		

;	Test all red - yellow street groups owned by other player
		LDX	#$05
@loop1:
		STX	game + GAME::varJ
		
		LDA	rulesGrpSqrs2, X
		CMP	#$FF
		BEQ	@next1
		
		STA	game + GAME::varU
		ASL
		TAX

		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@next1
		
		CMP	#$FF
		BEQ	@next1
		
		TAY
		LDA	plrLo, Y
		STA	$A3
		LDA	plrHi, Y
		STA	$A4
		LDY	#PLAYER::status
		LDA	($A3), Y
		AND	#$01
		BEQ	@next1

		LDA	sqr00 + 1, X
		AND	#$08
		BNE	@hotel1
		
		LDA	sqr00 + 1, X
		AND	#$07
	
		JMP	@cont1
		
@hotel1:
		LDA	#$05
		
@cont1:
		STA	game + GAME::varH
		
;		If no houses set value to rent if lower
;		Else set value to rent for improvement has if lower

		JSR	gameGetCardPtrForSquareImmed
		
		CLC
		LDA	game + GAME::varH
		ASL
		ADC	#STREET::mRent

		TAY
		LDA	($FD), Y
		STA	game + GAME::varO
		INY
		LDA	($FD), Y
		STA	game + GAME::varP
		
		JSR	rulesUpdateValueIfLess

@next1:
		LDX	game + GAME::varJ
		
		INX
		CPX	#$07
		BNE	@loop1
		
		
;	Add temp value to value
		CLC
		LDA	game + GAME::varD
		ADC	game + GAME::varM
		STA	game + GAME::varD
		LDA	game + GAME::varE
		ADC	game + GAME::varN
		STA	game + GAME::varE
		

;	Test all green - blue street groups owned by other player
		LDX	#$07
@loop2:
		STX	game + GAME::varJ
		
		LDA	rulesGrpSqrs2, X
		CMP	#$FF
		BNE	@havesqr2
		
		LDA	rulesGrpSqrs1, X
		CMP	#$FF
		BEQ	@next2
		
@havesqr2:
		STA	game + GAME::varU
		ASL
		TAX

		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@next2
		
		CMP	#$FF
		BEQ	@next2
		
		TAY
		LDA	plrLo, Y
		STA	$A3
		LDA	plrHi, Y
		STA	$A4
		LDY	#PLAYER::status
		LDA	($A3), Y
		AND	#$01
		BEQ	@next2
		
		LDA	sqr00 + 1, X
		AND	#$08
		BNE	@hotel2
		
		LDA	sqr00 + 1, X
		AND	#$07
	
		JMP	@cont2
		
@hotel2:
		LDA	#$05
		
@cont2:
		STA	game + GAME::varH
		
;		If no houses add rent * 2 to value
;		Else add rent for improvement has / 4 to value

		JSR	gameGetCardPtrForSquareImmed
		
		CLC
		LDA	game + GAME::varH
		ASL
		ADC	#STREET::mRent

		TAY
		LDA	($FD), Y
		STA	game + GAME::varO
		INY
		LDA	($FD), Y
		STA	game + GAME::varP

		LDA	game + GAME::varH
		BEQ	@update2

		LDA	game + GAME::varP
		ASL
		ROR	game + GAME::varP
		ROR	game + GAME::varO

		LDA	game + GAME::varP
		ASL
		ROR	game + GAME::varP
		ROR	game + GAME::varO
		
@update2:
		CLC
		LDA	game + GAME::varD
		ADC	game + GAME::varO
		STA	game + GAME::varD
		LDA	game + GAME::varE
		ADC	game + GAME::varP
		STA	game + GAME::varE

@next2:
		LDX	game + GAME::varJ
		
		INX
		CPX	#$09
		BEQ	@finish

		JMP	@loop2

@finish:
;	If all stations owned by other player 
		LDX	#$0A
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@utilities
		
		TAY
		LDA	plrLo, Y
		STA	$A3
		LDA	plrHi, Y
		STA	$A4
		LDY	#PLAYER::status
		LDA	($A3), Y
		AND	#$01
		BEQ	@utilities
		
		LDA	sqr00 + 1, X
		AND	#$40
		BEQ	@utilities
		
;		Add 250
		CLC
		LDA	game + GAME::varD
		ADC	#250
		STA	game + GAME::varD
		LDA	game + GAME::varE
		ADC	#$00
		STA	game + GAME::varE

@utilities:
;	If all utilities owned by other player 
		LDX	#$18
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BEQ	@purchases
		
		TAY
		LDA	plrLo, Y
		STA	$A3
		LDA	plrHi, Y
		STA	$A4
		LDY	#PLAYER::status
		LDA	($A3), Y
		AND	#$01
		BEQ	@exit
		
		LDA	sqr00 + 1, X
		AND	#$40
		BEQ	@exit
		
;		Add 75
		CLC
		LDA	game + GAME::varD
		ADC	#75
		STA	game + GAME::varD
		LDA	game + GAME::varE
		ADC	#$00
		STA	game + GAME::varE

@purchases:
;	Find number deeds owned
		JSR	rulesCountOwnedDeeds

;	All 28
		LDA	game + GAME::varA
		CMP	#$1C
		BNE	@tst16
		
;		Increase value by 150
		LDA	#<150
		STA	game + GAME::varM
		LDA	#>150
		STA	game + GAME::varN
		
		JMP	@bump
		
@tst16:
;	Or more than 20
		CMP	#$14
		BMI	@tst11

;		Increase value by 200
		LDA	#<200
		STA	game + GAME::varM
		LDA	#>200
		STA	game + GAME::varN

		JMP	@bump

@tst11:
;	Or more than 12
		CMP	#$0C
		BMI	@default
		
;		Increase value by 300
		LDA	#<300
		STA	game + GAME::varM
		LDA	#>300
		STA	game + GAME::varN

		JMP	@bump

@default:
;	Or
;		Increase value by 400
		LDA	#<400
		STA	game + GAME::varM
		LDA	#>400
		STA	game + GAME::varN

@bump:
		CLC
		LDA	game + GAME::varD
		ADC	game + GAME::varM
		STA	game + GAME::varD
		LDA	game + GAME::varE
		ADC	game + GAME::varN
		STA	game + GAME::varE

@exit:
		RTS


rulesCountOwnedDeeds:
;	Tally owned deeds
		LDA	#$00
		STA	game + GAME::varA

		LDX	#$00
@loop:
		LDA	sqr00, X
		CMP	#$FF
		BEQ	@next
		
		TAY
		LDA	plrLo, Y
		STA	$A3
		LDA	plrHi, Y
		STA	$A4
		LDY	#PLAYER::status
		LDA	($A3), Y
		AND	#$01
		BEQ	@next
		
		INC	game + GAME::varA

@next:
		INX
		INX
		
		CPX	#$50
		BNE	@loop

		RTS
	

rulesDoConstructAtLevel:
;		For each square in group, backwards, buy improvements at level 
;		until out of money or zero houses/hotels?

;		Update level when all done at level

;		game + GAME::varJ = group
;		game + GAME::varB = level
;		game + GAME::varH = house count
;		game + game::varI = hotel count
;		game + GAME::varK = player
;		rulesSqrImprv for improvement information
;
;		game + GAME::varA = group square idx
;		game + GAME::varF = square 
		
		LDX	game + GAME::varJ
		
		LDA	rulesGrpLo, X
		STA	$FD
		LDA	rulesGrpHi, X
		STA	$FE
		
		LDA	#$02
		STA	game + GAME::varA
		
@loop0:
		LDA	#$1C
		LDX	game + GAME::varA
		BPL	@loop1
		
		JMP	@incomplete
		
		
@loop1:
		INX
		CPX	#$03
		BEQ	@cont0
		
		SEC
		SBC	#$0E
		JMP	@loop1
		
@cont0:
		CLC
		ADC	game + GAME::varJ
		
		TAX
		LDA	rulesGrpSqrs0, X
		STA	game + GAME::varF
		
		CMP	#$FF
		BNE	@begin0
		
		DEC	game + GAME::varA
		JMP	@loop0

@begin0:
		ASL
		TAX
		LDA	sqr00, X
		CMP	game + GAME::varK
		BEQ	@begin1
		
		JMP	@complete
		
@begin1:
		LDX	game + GAME::varF
		LDA	rulesSqrImprv, X
		AND	#$08
		BEQ	@houses0
		
		LDA	#$05
		JMP	@cont1
		
@houses0:
		LDA	rulesSqrImprv, X
		AND	#$07
		
@cont1:
		CMP	game + GAME::varB
		BNE	@donext

		LDA	game + GAME::varB
		CMP	#$04
		BEQ	@hotels1
		
		LDA	game + GAME::varH
		BEQ	@complete

		DEC	game + GAME::varH
		
		LDA	rulesSqrImprv, X
		AND	#$F0
		ORA	game + GAME::varB
		STA	rulesSqrImprv, X
		INC	rulesSqrImprv, X
		
		JMP	@improve
		
@hotels1:
		LDA	game + GAME::varI
		BEQ	@complete
		
		DEC	game + GAME::varI
		
		CLC
		LDA	game + GAME::varH
		ADC	#$04
		STA	game + GAME::varH
		
		LDA	rulesSqrImprv, X
		AND	#$F0
		ORA	#$08
		STA	rulesSqrImprv, X

@improve:
		LDY	#GROUP::pImprv
		LDA	($FD), Y
		STA	game + GAME::varO
		LDA	#$00
		STA	game + GAME::varP
		
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCC	@complete
		
		LDA	#UI_ACT_BUYI
		STA	$68
		LDA	game + GAME::varK
		STA	$69
		LDA	game + GAME::varF
		STA	$6A
		
		JSR	uiEnqueueAction
		
		SEC
		LDA	game + GAME::varD
		SBC	game + GAME::varO
		STA	game + GAME::varD
		LDA	game + GAME::varE
		SBC	#$00
		STA	game + GAME::varE
		
@tstnext:
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCS	@donext
		
@complete:
		LDA	#$01
		RTS
		
@donext:
		DEC	game + GAME::varA
		LDA	game + GAME::varA
		CMP	#$FF
		BEQ	@incomplete
		
		JMP	@loop0
		
@incomplete:
		LDA	#$00
		
		RTS		
	
	
rulesAutoConstruct:
;		For each group in the priority lists backwards do
;
;				Is group 09/0A?  goto next
;			
;			for each level until run out of money
;				
;				construct at level
;				

		LDA	game + GAME::cntHs
		STA	game + GAME::varH
		LDA	game + GAME::cntHt
		STA	game + GAME::varI
		
		LDX	#$09
@loop0:
		STX	game + GAME::varG		;varG = group index
		
		LDA	rulesGrpPriority, X	
		STA	game + GAME::varJ		;varJ = group

		CMP	#$09
		BEQ	@next0
		
		CMP	#$0A
		BEQ	@next0

		TAX
		LDA	rulesGrpSqrs0, X
		ASL
		TAX
		
		LDA	sqr00, X
		CMP	game + GAME::pActive
		BNE	@next0
		
		LDA	sqr00 + 1, X
		AND	#$40
		BEQ	@next0
		
		LDA	sqr00 + 1, X
		AND	#$08
		BNE	@next0

		LDX	game + GAME::varJ
		LDY	#$FF

		JSR	rulesDoCollateImprv

		LDA	game + GAME::varQ
		BNE	@next0
		
		LDA	game + GAME::varA
		STA	game + GAME::varB

@loop1:
		JSR	rulesDoConstructAtLevel
		BNE	@complete
		
		INC	game + GAME::varB
		LDA	game + GAME::varB
		CMP	#$05
		BNE	@loop1
		
@next0:
		LDX	game + GAME::varG

		DEX
		BPL	@loop0
		
@complete:		
		RTS
		
		
rulesAutoRepayGroup:
		LDA	#$03
		STA	game + GAME::varA
		
@loop0:
		LDX	game + GAME::varA
		BPL	@fetchsqr
		
		JMP	@complete
		
@fetchsqr:
		LDA	game + GAME::varJ
		CMP	#$09
		BNE	@tstutil
		
		JSR	rulesStnSqrForIndex
		JMP	@begin0
		
@tstutil:
		CMP	#$0A
		BNE	@street
		
		CPX	#$02
		BPL	@skipidx

		JSR	rulesUtilSqrForIndex
		JMP	@begin0

@street:
		CPX	#$03
		BNE	@docalc
		
@skipidx:
		DEC	game + GAME::varA
		JMP	@loop0
		
@docalc:
		LDA	#$1C
		LDX	game + GAME::varA
		

@loop1:
		INX
		CPX	#$03
		BEQ	@cont0
		
		SEC
		SBC	#$0E
		JMP	@loop1
		
@cont0:
		CLC
		ADC	game + GAME::varJ
		
		TAX
		LDA	rulesGrpSqrs0, X
		
		CMP	#$FF
		BNE	@begin0
		
		DEC	game + GAME::varA
		JMP	@loop0

@begin0:
		STA	game + GAME::varF
		
		ASL
		STA	game + GAME::varL
		TAX
		LDA	sqr00, X
		CMP	game + GAME::varK
		BEQ	@begin1
		
		JMP	@donext
		
@begin1:
		LDX	game + GAME::varF
		LDA	rulesSqrImprv, X
		AND	#$80
		BEQ	@donext

		LDX	game + GAME::varL
		JSR	gameGetCardPtrForSquareImmed
		
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		LDY	#DEED::mFee
		CLC
		LDA	($FD), Y
		ADC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		ADC	game + GAME::varE
		STA	game + GAME::varE

		JSR	gameAmountIsLessDirect
		BCC	@repay
		
@incomplete:
		LDA	#$00
		RTS
		
@repay:
		SEC
		LDA	game + GAME::varO
		SBC	game + GAME::varD
		STA	game + GAME::varO
		LDA	game + GAME::varP
		SBC	game + GAME::varE
		STA	game + GAME::varP
		
		LDA	#UI_ACT_REPY
		STA	$68
		LDA	game + GAME::varK
		STA	$69
		LDA	game + GAME::varF
		STA	$6A
		
		JSR	uiEnqueueAction

@donext:
		DEC	game + GAME::varA
		LDA	game + GAME::varA
		CMP	#$FF
		BEQ	@incomplete
		
		JMP	@loop0
@complete:		
		LDA	#$01
		RTS
		
		
rulesAutoRepay:
		LDA	game + GAME::varD
		STA	game + GAME::varO
		LDA	game + GAME::varE
		STA	game + GAME::varP

		LDX	#$09
@loop0:
		STX	game + GAME::varG		;varG = group index
		
		LDA	rulesGrpPriority, X	
		STA	game + GAME::varJ	

		JSR	rulesAutoRepayGroup

@next0:
		LDX	game + GAME::varG

		DEX
		BPL	@loop0
		
		LDA	ui + UI::cActns
		BEQ	@incomplete
		
@complete:		
		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction
	
		LDA	#$01
		RTS

@incomplete:
		LDA	#$00
		RTS


rulesAutoImprove:
;	USES:	varD,E	=	amount surplus and available

		LDX	game + GAME::pActive
		STX	game + GAME::varK		;varK = player

		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		JSR	rulesDoCopyImprv

;	Find base rent value needed
		JSR	rulesSuggestBaseReserve
		
;	Subtract value from money store as value
		LDY	#PLAYER::money
		SEC
		LDA	($FB), Y
		SBC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		SBC	game + GAME::varE
		STA	game + GAME::varE
		
;	Have positive value, AutoConstruct
		BMI	@incomplete

		JSR	rulesAutoConstruct

;	Still have positive value, AutoRepay
		LDA	game + GAME::varE
		BMI	@tstcomp
		BNE	@repay
		
		LDA	game + GAME::varD
		BEQ	@tstcomp
		
@repay:
		JSR	rulesAutoRepay
		BNE	@finish

@tstcomp:
;	Any actions added?
		LDA	ui + UI::cActns
		BEQ	@incomplete

@complete:
		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction

@finish:
;		Return 1
		LDA	#$01
		RTS

@incomplete:
;	Else
;		Return 0
		LDA	#$00
		RTS


rulesDoTapValue:
;		.Y = min # taps (0 - 8 value increment)
;		.X = max # taps

		STY	game + GAME::varA
		LDY	#$00
		
		DEX
		BMI	@exit
		
@loop:
		LDA	sidV2EnvOu
		LSR
		LSR
		LSR
		LSR
		LSR
		CLC
		ADC	game + GAME::varD
		STA	game + GAME::varD
		LDA	#$00
		ADC	game + GAME::varE
		STA	game + GAME::varE
		
@next:
		DEX

		INY
		CPY	game + GAME::varA
		BMI	@loop

		CPX	#$FF
		BEQ	@exit
		
		LDA	sidV2EnvOu
		BPL	@loop
		
@exit:
		RTS


rulesDoNudgeValue:
;		.Y = min # nudges (0 - 16 value increment)
;		.X = max # nudges

		STY	game + GAME::varA
		LDY	#$00
		
		DEX
		BMI	@exit
		
@loop:
		LDA	sidV2EnvOu
		LSR
		LSR
		LSR
		LSR
		CLC
		ADC	game + GAME::varD
		STA	game + GAME::varD
		LDA	#$00
		ADC	game + GAME::varE
		STA	game + GAME::varE
		
@next:
		DEX

		INY
		CPY	game + GAME::varA
		BMI	@loop

		CPX	#$FF
		BEQ	@exit
		
		LDA	sidV2EnvOu
		BPL	@loop
		
@exit:
		RTS


rulesAutoGaol:
		LDA	#$00
		
;	if have go free, go free
		LDA	game + GAME::pGF0Crd
		CMP	game + GAME::pActive
		BNE	@tstgof1
		
		JMP	@gofree
		
@tstgof1:
		LDA	game + GAME::pGF1Crd
		CMP	game + GAME::pActive
		BNE	@tstpost

@gofree:
		LDA	#UI_ACT_GOFR
		STA	$68
		LDA	game + GAME::pActive
		STA	$69
		JSR	uiEnqueueAction
		JMP	@complete

@tstpost:
;***TODO:	Could do this properly now, get a base reserve by rental
;		expectations.

		LDA	game + GAME::dieRld
		BNE	@next
		
;	if have $770+(2->5nudge), post
		LDA	#<770
		STA	game + GAME::varD
		LDA	#>770
		STA	game + GAME::varE

		LDX	#$05
		LDY	#$02
		JSR	rulesDoNudgeValue
		
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
	
		LDY	#PLAYER::money
		LDA	($FB), Y
		STA	game + GAME::varO
		INY
		LDA	($FB), Y
		STA	game + GAME::varP
		
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCS	@tstroll

		LDA	#UI_ACT_POST
		STA	$68
		LDA	game + GAME::pActive
		STA	$69
		JSR	uiEnqueueAction
		JMP	@complete
		
@tstroll:
		LDA	game + GAME::dieRld
		BNE	@tstimprove

		LDY	#PLAYER::fCPUHvI
		LDA	#$00
		STA	($FB), Y

		LDA	#UI_ACT_ROLL
		STA	$68
		LDA	game + GAME::pActive
		STA	$69
		JSR	uiEnqueueAction
		
		JMP	@complete
		
@tstimprove:
		LDY	#PLAYER::fCPUHvI
		LDA	($FB), Y
		BNE	@next
		
		LDA	#$01
		STA	($FB), Y

		JSR	rulesAutoImprove
		BNE	@complete

@next:
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'N'
		STA	$69
		JSR	uiEnqueueAction

		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction

@complete:
;		Return 1
		LDA	#$01
		RTS


rulesGetGroupOwnInfo:
;(IN)		varB	=	group
;(IN)		varK	=	player
;		varH	=	count owned by player
;		varI	=	count owned by other player
;		varJ	= 	temp value
;		varF	=	only one other player
;		varG	=	temp value

		LDA	#$00
		STA	game + GAME::varH
		STA	game + GAME::varI
		
		LDA	#$FF
		STA	game + GAME::varG
		
		LDA	#$01
		STA	game + GAME::varF

		LDA	#$03
		STA	game + GAME::varJ
		
@loop0:
		LDX	game + GAME::varJ
		BPL	@fetchsqr
		
		JMP	@complete
		
@fetchsqr:
		LDA	game + GAME::varB
		CMP	#$09
		BNE	@tstutil
		
		JSR	rulesStnSqrForIndex
		JMP	@begin0
		
@tstutil:
		CMP	#$0A
		BNE	@street
		
		CPX	#$02
		BPL	@skipidx

		JSR	rulesUtilSqrForIndex
		JMP	@begin0

@street:
		CPX	#$03
		BNE	@docalc
		
@skipidx:
		DEC	game + GAME::varJ
		JMP	@loop0
		
@docalc:
		LDA	#$1C
		LDX	game + GAME::varJ

@loop1:
		INX
		CPX	#$03
		BEQ	@cont0
		
		SEC
		SBC	#$0E
		JMP	@loop1
		
@cont0:
		CLC
		ADC	game + GAME::varB
		
		TAX
		LDA	rulesGrpSqrs0, X
		
		CMP	#$FF
		BNE	@begin0
		
		DEC	game + GAME::varJ
		JMP	@loop0

@begin0:
;	Get square ownership
		ASL
		TAX
		LDA	sqr00, X
		CMP	#$FF
		BEQ	@donext
		
;	Is it owned by this player?
		CMP	game + GAME::varK
		BNE	@other

;	Yes, increment this own count
		INC	game + GAME::varH
		JMP	@checkother
		
@other:
;	No, increment other own count
		INC	game + GAME::varI
		
@checkother:
;	Is it owned by the same as the last?
		CMP	game + GAME::varG
		BEQ	@donext
		
;	Possibly not...
		PHA
		LDA	game + GAME::varG
		CMP	#$FF
		BEQ	@checkdone

;	No, unset owned by one player flag
		LDA	#$00
		STA	game + GAME::varF

@checkdone:
		PLA
		STA	game + GAME::varG

@donext:
		DEC	game + GAME::varJ
		LDA	game + GAME::varJ
		CMP	#$FF
		BEQ	@complete
		
		JMP	@loop0
		
@complete:
		LDA	#$01
		RTS


rulesSuggestDeedValue:
;(IN)		.A	= 	square
;		varA	=	square
;		varB	=	group
;		varC	=	group index
;		varD,E  = 	value
;		varM,N	=	temp value
;		varS,T	=	temp value
;(IN)		varK 	=	player
;		varL	= 	square * 2

		STA	game + GAME::varA
		
		ASL
		STA	game + GAME::varL
		
		TAX
		JSR	gameGetCardPtrForSquareImmed
		
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varS
		STA	game + GAME::varM
		INY
		LDA	($FD), Y
		STA	game + GAME::varT
		STA	game + GAME::varN
		
		ASL
		ROR	game + GAME::varN
		ROR	game + GAME::varM

		LDA	game + GAME::varM
		STA	game + GAME::varD
		LDA	game + GAME::varN
		STA	game + GAME::varE

		ASL
		ROR	game + GAME::varE
		ROR	game + GAME::varD

;	Now have deed market value in S,T; half value in M,N and quarter value 
;	in D,E.  Want 3/4 market value as starting point.

		SEC
		LDA	game + GAME::varS
		SBC	game + GAME::varD
		STA	game + GAME::varD
		LDA	game + GAME::varT
		SBC	game + GAME::varE
		STA	game + GAME::varE
		
;	Now have 3/4 market value in D,E.
		
;	Need to test ownership info
		JSR	rulesGetGroupOwnInfo

;	If the group is 1 or 8 and own 1 then pretend like its 2
		LDA	game + GAME::varC
		CMP	#$01
		BEQ	@tstpromote0
		
		CMP	#$08
		BNE	@cont0
		
@tstpromote0:		
		LDA	game + GAME::varH
		BEQ	@tstpromote1
		
		INC	game + GAME::varH
		
@tstpromote1:
		LDA	game + GAME::varI
		BEQ	@cont0
		
		INC	game + GAME::varI
		
@cont0:
		LDA	game + GAME::varF
		BEQ	@tstmultiown
		
		LDA	game + GAME::varH
		BNE	@tstsingle0
		
;	Owned by only 1 player and its not this one

		LDA	game + GAME::varI
		CMP	#$02
		BEQ	@wantedvery
		
		JMP	@wantedsome
		
@tstsingle0:
;	Owned by only 1 player but its me
		
		LDA	game + GAME::varH
		CMP	#$02
		BEQ	@wantedvery
		
		JMP	@wantedsome

@tstmultiown:
		LDA	game + GAME::varH
		CMP	#$02
		BPL	@wantedsome

;***TODO:	Tap value based on group (more for higher ones)

@wanted:
		LDX	#$02
		LDY	#$01
		JSR	rulesDoTapValue		
		
		JMP	@done
		
@wantedsome:
		LDA	game + GAME::varS
		STA	game + GAME::varD
		LDA	game + GAME::varT
		STA	game + GAME::varE
		
		LDX	#$02
		LDY	#$01
		JSR	rulesDoTapValue		

		JMP	@done
		
@wantedvery:
		CLC
		LDA	game + GAME::varD
		ADC	game + GAME::varM
		STA	game + GAME::varD
		LDA	game + GAME::varE
		ADC	game + GAME::varN
		STA	game + GAME::varE
		
		LDX	#$02
		LDY	#$01
		JSR	rulesDoTapValue		

@done:
		RTS

rulesAutoAuction:
;	Current bid amount in game + GAME::mACurr
;	Auctioned square in game + GAME::sAuctn	

		LDX	game + GAME::pActive
		STX	game + GAME::varK		;varK = player

		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		JSR	rulesDoCopyImprv

;	Find base rent value needed
		JSR	rulesSuggestBaseReserve
		
;	Subtract value from money store as value
		LDY	#PLAYER::money
		SEC
		LDA	($FB), Y
		SBC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		SBC	game + GAME::varE
		STA	game + GAME::varE
		
;	Have negative aboslute maximum value, forfeit
		BPL	@begin
		JMP	@forfeit

@begin:
;	Copy our absolute maximum to compare
		LDA	game + GAME::varD
		STA	game + GAME::varO
		LDA	game + GAME::varE
		STA	game + GAME::varP
		
;	Get a suggested value
		LDA	game + GAME::sAuctn
		JSR	rulesSuggestDeedValue
		
;	Test our suggested value, if suggested is < maximum then keep
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCC	@cont0
		
;	Copy our absolute maximum to suggested value
		LDA	game + GAME::varO
		STA	game + GAME::varD
		LDA	game + GAME::varP
		STA	game + GAME::varE
		
@cont0:
		LDA	game + GAME::mACurr
		STA	game + GAME::varO
		LDA	game + GAME::mACurr + 1
		STA	game + GAME::varP
		
;	Test our suggested value, if current is >= then forfeit
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCS	@forfeit
		
;	Swap our values around (for comparisons)
		LDA	game + GAME::varD
		STA	game + GAME::varO
		LDA	game + GAME::varE
		STA	game + GAME::varP
		LDA	game + GAME::mACurr
		STA	game + GAME::varD
		LDA	game + GAME::mACurr + 1
		STA	game + GAME::varE
		
;	Do we nudge or tap towards our value?
		LDA	sidV2EnvOu
		CMP	#$C0
		BCS	@nudge0
		
		LDX	#$02
		LDY	#$01
		JSR	rulesDoTapValue
		
		JMP	@cont1

@nudge0:
		LDX	#$02
		LDY	#$01
		JSR	rulesDoNudgeValue
		
@cont1:
;	Test our bid value, if larger than our max then reset to max
;		D, E < (O, P) -> CLC | SEC
		JSR	gameAmountIsLessDirect
		BCC	@cont2
		
		LDA	game + GAME::varO
		STA	game + GAME::varD
		LDA	game + GAME::varP
		STA	game + GAME::varE
		
@cont2:
;	Make our bid
		LDA	game + GAME::varD
		STA	game + GAME::mACurr
		LDA	game + GAME::varE
		STA	game + GAME::mACurr + 1
		
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'B'
		STA	$69
		
		JSR	uiEnqueueAction
		
		JMP	@complete


@forfeit:
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'F'
		STA	$69
		
		JSR	uiEnqueueAction

@complete:
		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction
		
		LDA	#$01
		RTS


rulesAutoTradeInitiate:
		LDA	#$00
		RTS


rulesAutoTradeApprove:
		LDA	#$00
		RTS


rulesAutoPlay:
		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		JSR	rulesAutoPay
		BNE	@complete

		LDA	game + GAME::dieRld
		BNE	@tstimprove

		LDY	#PLAYER::fCPUHvI
		LDA	#$00
		STA	($FB), Y

		LDA	game + GAME::dieDbl
		BEQ	@doroll
		
		LDA	#UI_ACT_DELY
		STA	$68
		LDA	#$00
		STA	$69
		STA	$6A
		STA	$6B
		
		JSR	uiEnqueueAction

@doroll:
		LDA	#UI_ACT_ROLL
		STA	$68
		LDA	game + GAME::pActive
		STA	$69
		JSR	uiEnqueueAction
		
		JMP	@complete

@tstimprove:
		LDY	#PLAYER::fCPUHvI
		LDA	($FB), Y
		BNE	@incomplete
		
		LDA	#$01
		STA	($FB), Y

		JSR	rulesAutoImprove
		BNE	@complete

@incomplete:
		LDA	#$00
		RTS

@complete:
		LDA	#$01
		RTS


rulesStnSqrForIndex:
		CPX	#$00
		BNE	@1
		LDA	#$23
		RTS
@1:
		CPX	#$01
		BNE	@2
		LDA	#$19
		RTS
@2:
		CPX	#$02
		BNE	@3
		LDA	#$0F
		RTS
@3:
		LDA	#$05
		RTS
		

rulesUtilSqrForIndex:
		CPX	#$00
		BNE	@1
		LDA	#$0C
		RTS
@1:
		LDA	#$1C
		RTS
		

rulesAutoEliminGroup:
		LDA	#$03
		STA	game + GAME::varA
		
@loop0:
		LDX	game + GAME::varA
		BPL	@fetchsqr
		
		JMP	@complete
		
@fetchsqr:
		LDA	game + GAME::varJ
		CMP	#$09
		BNE	@tstutil
		
		JSR	rulesStnSqrForIndex
		JMP	@begin0
		
@tstutil:
		CMP	#$0A
		BNE	@street
		
		CPX	#$02
		BPL	@skipidx

		JSR	rulesUtilSqrForIndex
		JMP	@begin0

@street:
		CPX	#$03
		BNE	@docalc
		
@skipidx:
		DEC	game + GAME::varA
		JMP	@loop0
		
@docalc:
		LDA	#$1C
		LDX	game + GAME::varA
		

@loop1:
		INX
		CPX	#$03
		BEQ	@cont0
		
		SEC
		SBC	#$0E
		JMP	@loop1
		
@cont0:
		CLC
		ADC	game + GAME::varJ
		
		TAX
		LDA	rulesGrpSqrs0, X
		
		CMP	#$FF
		BNE	@begin0
		
		DEC	game + GAME::varA
		JMP	@loop0

@begin0:
		STA	game + GAME::varF
		
		ASL
		TAX
		LDA	sqr00, X
		CMP	game + GAME::varK
		BEQ	@begin1
		
		JMP	@donext
		
@begin1:
		JSR	gameGetCardPtrForSquareImmed
		
		LDY	#DEED::mValue
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		LDY	#DEED::mFee
		CLC
		LDA	($FD), Y
		ADC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		ADC	game + GAME::varE
		STA	game + GAME::varE

		JSR	gameAmountIsLessDirect
		BCC	@select
		
		JMP	@donext
		
@select:
		SEC
		LDA	game + GAME::varO
		SBC	game + GAME::varD
		STA	game + GAME::varO
		LDA	game + GAME::varP
		SBC	game + GAME::varE
		STA	game + GAME::varP
		
		LDY	#TRADE::cntDeed
		LDA	trade1, Y
		TAY
		LDA	game + GAME::varF
		STA	trddeeds1, Y
		LDA	#$81
		STA	trdrepay1, Y
		INY
		TYA
		LDY	#TRADE::cntDeed
		STA	trade1, Y
		
@donext:
		DEC	game + GAME::varA
		LDA	game + GAME::varA
		CMP	#$FF
		BEQ	@complete
		
		JMP	@loop0
		
@complete:
		LDA	#$01
		RTS
		

rulesAutoEliminSelect:
		LDA	game + GAME::varD
		STA	game + GAME::varO
		LDA	game + GAME::varE
		STA	game + GAME::varP
		
		LDX	#$09
@loop0:
		STX	game + GAME::varG		;varG = group index
		
		LDA	rulesGrpPriority, X	
		STA	game + GAME::varJ	

		JSR	rulesAutoEliminGroup

@next0:
		LDX	game + GAME::varG

		DEX
		BPL	@loop0
		
@complete:		
		RTS
		

rulesAutoEliminate:
		STX	game + GAME::varK		;varK = player

		LDX	game + GAME::pActive
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC

		JSR	rulesDoCopyImprv

;	Find base rent value needed
		JSR	rulesSuggestBaseReserve
		
		LDY	#$02
		LDX	#$05
		JSR	rulesDoNudgeValue

;	Subtract value from money store as value
		LDY	#PLAYER::money
		SEC
		LDA	($FB), Y
		SBC	game + GAME::varD
		STA	game + GAME::varD
		INY
		LDA	($FB), Y
		SBC	game + GAME::varE
		STA	game + GAME::varE
		
;	Have positive value, AutoEliminSelect
		BMI	@complete

		JSR	rulesAutoEliminSelect
		
@complete:	
		LDA	#UI_ACT_SKEY
		STA	$68
		LDA	#'C'
		STA	$69
		
		JSR	uiEnqueueAction
		
		LDA	#$01
		RTS


;==============================================================================
;FOR NUMCONV.S
;==============================================================================

numConvLEAD0	=	$A5
numConvDIGIT   	=	$A6
numConvVALUE	=	$A3

numConvHeapPtr	=	$A7

numConvSIGN	=	$03
numConvX2	=	$04			;EXPONENT 2
numConvM2	=	$05			;MANTISSA 2
numConvX1	=	$08			;EXPONENT 1
numConvM1	=	$09			;MANTISSA 1
numConvE	=	$0C			;SCRATCH
numConvZ	=	$10
numConvT	=	$14
numConvSEXP	=	$18
numConvINT	=	$1C


screenPanic0:
			.byte	$11, $00, $00, $28, $19
			.byte	$90, $00, $00
			.word		strText0NumConv0
			.byte	$00


numConvPanic:
		LDA	#<screenPanic0
		STA	$FD
		LDA	#>screenPanic0
		STA	$FE
		
		JSR	screenPerformList
numConvHalt:
		JMP	numConvHalt
		RTS


numConvTemp0:	.byte	$00


;http://www.6502.org/source/integers/fastx10.htm

numConvMULT10:  
		ASL         			;multiply by 2
		STA 	numConvTemp0    	;temp store in TEMP
		ASL         			;again multiply by 2 (*4)
		ASL         			;again multiply by 2 (*8)
		CLC
		ADC 	numConvTemp0    	;as result, A = x*8 + x*2
		RTS


numConvDieRoll:
		LDA 	sidV2EnvOu
		AND	#$7F
		STA	Z:numConvM1
		NOP
		NOP
		NOP
		LDA 	sidV2EnvOu
		STA	Z:numConvM1 + 1

		JSR	numConvFLOAT
		
		JSR	numConvCopyX1X2
		
		LDA	#$15
		STA	Z:numConvM1
		LDA	#$55
		STA	Z:numConvM1 + 1

		JSR	numConvFLOAT
		
		JSR	numConvFDIV
		
		JSR	numConvFIX
		
		LDX	Z:numConvM1 + 1
		INX
		
		CPX	#$07	
		BNE	@done
		
		LDX	#$06
		
@done:

		TXA

		RTS


numConvCopyX1X2:
		LDX	#$00
@loop:
		LDA	Z:numConvX1, X
		STA	Z:numConvX2, X
		
		INX
		CPX	#$04
		BNE	@loop
		
		RTS
		

;http://www.easy68k.com/paulrsm/6502/HYDE6502.TXT
;
;Apparently this is Wozinac source, converted for CA65 and my purposes here. 
;It is exactly what I was going to do myself...


numConvPRTSGN:
;I want to return Y and needn't bother saving A
;
;               PHA             		;SAVE ACC
;		PHA             		;SAVE REGISTERS
;		TXA
;               PHA
;		TYA
;		PHA
		
		LDA	#<heap0			;INIT BUFFER PTR
		STA	numConvHeapPtr
		LDA	#>heap0
		STA	numConvHeapPtr + 1
		LDY	#$00
		
		BIT 	numConvVALUE + $1    	;TEST SIGN BIT
                BPL 	@1      		;IF POSITIVE, GO TO PRTINT
                LDA 	#'-'        		;OUTPUT A
;               JSR 	numConvCOUT
		STA	(numConvHeapPtr), Y
		INY
                SEC             		;TAKE TWO'S COMPLIMENT OF
                LDA 	#$0         		;VALUE.
                SBC 	numConvVALUE
                STA 	numConvVALUE
                LDA 	#$0
                SBC 	numConvVALUE + $1
                STA 	numConvVALUE + $1
;               PLA
		JMP	@PRTINT
		
@1:
		LDA	#' '
		STA	(numConvHeapPtr), Y
		INY

@PRTINT:  
                LDX 	#$4         		;OUTPUT UP TO 5 DIGITS

;de	I'm pretty sure we have a problem below and this will help fix it
;		STX 	numConvLEAD0       	;INIT LEAD0 TO NON-NEG
		LDA	%10000000
		STA	numConvLEAD0
		
;
@PRTI1:
		LDA 	#'0'        		;INIT DIGIT COUNTER
                STA 	numConvDIGIT
;
@PRTI2:
		SEC            	 		;BEGIN SUBTRACTION PROCESS
                LDA 	numConvVALUE
                SBC 	numConvT10L, X      	;SUBTRACT LOW ORDER BYTE
                PHA             		;AND SAVE.
                LDA 	numConvVALUE + $1    	;GET H.O BYTE
                SBC 	numConvT10H, X      	;AND SUBTRACT H.O TBL OF 10
                BCC 	@PRTI3       		;IF LESS THAN, BRANCH
;
                STA 	numConvVALUE + $1    	;IF NOT LESS THAN, SAVE IN
                PLA             		;VALUE.
                STA 	numConvVALUE
                INC 	numConvDIGIT       	;INCREMENT DIGIT COUNTER
                JMP 	@PRTI2
;
;
@PRTI3:
		PLA             		;FIX THE STACK
                LDA 	numConvDIGIT       	;GET CHARACTER TO OUTPUT
                
		CPX 	#$0         		;LAST DIGIT TO OUTPUT?
                BEQ 	@PRTI5       		;IF SO, OUTPUT REGARDLESS

		CMP 	#'0'        		;A ZERO?

;de	#$31+ is not negative so this wouldn't work??
;               BEQ 	@PRTI4       		;IF SO, SEE IF A LEADING ZERO
;		STA 	numConvLEAD0       	;FORCE LEAD0 TO NEG.
;de 	We'll do this instead
		BNE	@PRTI5
@PRTI4:   	
		BIT 	numConvLEAD0       	;SEE IF ZERO VALUES OUTPUT
;de	I need to this as well
;               BPL 	@PRTI6       		;YET.
;		BPL 	@space			;de I want spaces.
		BMI	@space

@PRTI5:
;		JSR 	numConvCOUT
;de	And this too (only l6bit here)
		CLC
		ROR	numConvLEAD0

		STA	(numConvHeapPtr), Y
		INY
		
		JMP	@PRTI6			;de This messes the routine but
						;I need spaces

@space:
		LDA	#' '
		STA	(numConvHeapPtr), Y
		INY
		
@PRTI6:
		DEX             		;THROUGH YET?
                BPL 	@PRTI1

;		PLA
;		TAY
;		PLA
;               TAX
;               PLA
                RTS

numConvT10L:
			.byte 	<1
			.byte 	<10
			.byte	<100
			.byte	<1000
			.byte	<10000

numConvT10H:		.byte	>1
			.byte	>10
			.byte	>100
			.byte	>1000
			.byte	>10000



;http://www.6502.org/source/floats/wozfp1.txt
;de 	More Wozniak code


;
;
;     BASIC FLOATING POINT ROUTINES
;
ADD:
		CLC         			;CLEAR CARRY
		LDX 	#$02    		;INDEX FOR 3-BYTE ADD
ADD1:
		LDA 	numConvM1, X
		ADC 	numConvM2, X    	;ADD A BYTE OF MANT2 TO MANT1
		STA 	numConvM1, X
		DEX         			;ADVANCE INDEX TO NEXT MORE SIGNIF.BYTE
		BPL 	ADD1    		;LOOP UNTIL DONE.
		RTS         			;RETURN
MD1:	
		ASL 	numConvSIGN    		;CLEAR LSB OF SIGN
		JSR 	ABSWAP  		;ABS VAL OF MANT1, THEN SWAP MANT2
ABSWAP:
		BIT 	numConvM1      		;MANT1 NEG?
		BPL 	ABSWP1  		;NO,SWAP WITH MANT2 AND RETURN
		JSR 	FCOMPL  		;YES, COMPLIMENT IT.
		INC 	numConvSIGN    		;INCR SIGN, COMPLEMENTING LSB
ABSWP1: 
		SEC         			;SET CARRY FOR RETURN TO MUL/DIV
;
;     SWAP EXP/MANT1 WITH EXP/MANT2
;
SWAP:
		LDX 	#$04    		;INDEX FOR 4-BYTE SWAP.
SWAP1:
		STY 	numConvE - 1, X

		LDA 	numConvX1 - 1, X  	;SWAP A BYTE OF EXP/MANT1 WITH
		LDY 	numConvX2 - 1, X  	;EXP/MANT2 AND LEAVEA COPY OF

		STY 	numConvX1 - 1, X  	;MANT1 IN E(3BYTES). E+3 USED.

		STA 	numConvX2 - 1, X
		DEX         			;ADVANCE INDEX TO NEXT BYTE
		BNE 	SWAP1   		;LOOP UNTIL DONE.
		RTS
;
;
;
;     CONVERT 16 BIT INTEGER IN M1(HIGH) AND M1+1(LOW) TO F.P.
;     RESULT IN EXP/MANT1.  EXP/MANT2 UNEFFECTED
;
;
numConvFLOAT:
		LDA 	#$8E
		STA 	numConvX1      		;SET EXPN TO 14 DEC
		LDA 	#0      		;CLEAR LOW ORDER BYTE
		STA 	numConvM1 + 2
		BEQ 	NORM    		;NORMALIZE RESULT
NORM1:
		DEC 	numConvX1      		;DECREMENT EXP1
		ASL 	numConvM1 + 2
		ROL  	numConvM1 + 1    	;SHIFT MANT1 (3 BYTES) LEFT
		ROL 	numConvM1
NORM:
		LDA 	numConvM1      		;HIGH ORDER MANT1 BYTE
		ASL         			;UPPER TWO BITS UNEQUAL?
		EOR 	numConvM1
		BMI 	RTS1    		;YES,RETURN WITH MANT1 NORMALIZED
		LDA 	numConvX1      		;EXP1 ZERO?
		BNE 	NORM1   		;NO, CONTINUE NORMALIZING
RTS1:
		RTS         			;RETURN


;
;
;     EXP/MANT2-EXP/MANT1 RESULT IN EXP/MANT1
;
numConvFSUB:
		JSR 	FCOMPL  		;CMPL MANT1 CLEARS CARRY UNLESS ZERO
SWPALG: 
		JSR 	ALGNSW  		;RIGHT SHIFT MANT1 OR SWAP WITH MANT2 ON CARRY
;
;     ADD EXP/MANT1 AND EXP/MANT2 RESULT IN EXP/MANT1
;
numConvFADD:
		LDA 	numConvX2
		CMP 	numConvX1      		;COMPARE EXP1 WITH EXP2
		BNE 	SWPALG  		;IF UNEQUAL, SWAP ADDENDS OR ALIGN MANTISSAS

		JSR 	ADD    			;ADD ALIGNED MANTISSAS
ADDEND:
		BVC 	NORM    		;NO OVERFLOW, NORMALIZE RESULTS
		BVS 	RTLOG   		;OV: SHIFT MANT1 RIGHT. NOTE CARRY IS CORRECT SIGN
ALGNSW:
		BCC 	SWAP    		;SWAP IF CARRY CLEAR, ELSE SHIFT RIGHT ARITH.
RTAR:  	
		LDA 	numConvM1      		;SIGN OF MANT1 INTO CARRY FOR
		ASL         			;RIGHT ARITH SHIFT
RTLOG:  
		INC 	numConvX1      		;INCR EXP1 TO COMPENSATE FOR RT SHIFT
		
;de	This is out of range, apparently...
;		BEQ 	OVFL    		;EXP1 OUT OF RANGE.
		BNE	RTCONT
		JMP	OVFL
RTCONT:

RTLOG1: 	
		LDX 	#$FA    		;INDEX FOR 6 BYTE RIGHT SHIFT
ROR1:   
		LDA 	#$80
		BCS 	ROR2
		ASL
ROR2:   
		LSR 	numConvE + 3, X		;SIMULATE ROR E + 3,X
		ORA 	numConvE + 3, X
		STA 	numConvE + 3, X

		INX         			;NEXT BYTE OF SHIFT
		BNE 	ROR1    		;LOOP UNTIL DONE
		
		RTS         			;RETURN
;
;
;     EXP/MANT1 X EXP/MANT2 RESULT IN EXP/MANT1
;
numConvFMUL:
		JSR 	MD1     		;ABS. VAL OF MANT1, MANT2
		ADC 	numConvX1      		;ADD EXP1 TO EXP2 FOR PRODUCT EXPONENT
		JSR 	MD2     		;CHECK PRODUCT EXP AND PREPARE FOR MUL
		CLC         			;CLEAR CARRY
MUL1:
		JSR 	RTLOG1  		;MANT1 AND E RIGHT.(PRODUCT AND MPLIER)
		BCC 	MUL2    		;IF CARRY CLEAR, SKIP PARTIAL PRODUCT
		
		JSR 	ADD     		;ADD MULTIPLICAN TO PRODUCT
		
MUL2:
		DEY         			;NEXT MUL ITERATION
		BPL 	MUL1    		;LOOP UNTIL DONE
MDEND:
		LSR 	numConvSIGN    		;TEST SIGN (EVEN/ODD)
NORMX:
		BCC 	NORM    		;IF EXEN, NORMALIZE PRODUCT, ELSE COMPLEMENT
FCOMPL:
		SEC         			;SET CARRY FOR SUBTRACT
		LDX 	#$03    		;INDEX FOR 3 BYTE SUBTRACTION
COMPL1: 
		LDA 	#$00    		;CLEAR A
		SBC 	numConvX1, X   		;SUBTRACT BYTE OF EXP1
		STA 	numConvX1, X    	;RESTORE IT
		DEX         			;NEXT MORE SIGNIFICANT BYTE
		BNE 	COMPL1  		;LOOP UNTIL DONE
		BEQ 	ADDEND  		;NORMALIZE (OR SHIFT RIGHT IF OVERFLOW)
;
;
;     EXP/MANT2 / EXP/MANT1 RESULT IN EXP/MANT1
;
numConvFDIV:
		JSR 	MD1     		;TAKE ABS VAL OF MANT1, MANT2
		SBC 	numConvX1      		;SUBTRACT EXP1 FROM EXP2
		JSR 	MD2     		;SAVE AS QUOTIENT EXP
DIV1:
		SEC         			;SET CARRY FOR SUBTRACT
		LDX 	#$02    		;INDEX FOR 3-BYTE INSTRUCTION
DIV2:
		LDA 	numConvM2, X
		SBC 	numConvE, X    		;SUBTRACT A BYTE OF E FROM MANT2
		PHA         			;SAVE ON STACK
		DEX         			;NEXT MORE SIGNIF BYTE
		BPL 	DIV2    		;LOOP UNTIL DONE


		LDX 	#$FD    		;INDEX FOR 3-BYTE CONDITIONAL MOVE
DIV3:
		PLA         			;PULL A BYTE OF DIFFERENCE OFF STACK
		BCC 	DIV4    		;IF MANT2<E THEN DONT RESTORE MANT2
		STA 	numConvM2 + 3, X		
		
DIV4:
		INX         			;NEXT LESS SIGNIF BYTE
		BNE 	DIV3    		;LOOP UNTIL DONE

		ROL 	numConvM1 + 2
		ROL  	numConvM1 + 1    	;ROLL QUOTIENT LEFT, CARRY INTO LSB
		ROL 	numConvM1
		ASL 	numConvM2 + 2
		ROL 	numConvM2 + 1  		;SHIFT DIVIDEND LEFT
		ROL 	numConvM2
		BCS 	OVFL    		;OVERFLOW IS DUE TO UNNORMALIZED DIVISOR
		DEY         			;NEXT DIVIDE ITERATION
		BNE 	DIV1    		;LOOP UNTIL DONE 23 ITERATIONS
		BEQ 	MDEND   		;NORMALIZE QUOTIENT AND CORRECT SIGN
MD2:
		STX 	numConvM1 + 2
		STX 	numConvM1 + 1    	;CLR MANT1 (3 BYTES) FOR MUL/DIV
		STX 	numConvM1
		BCS 	OVCHK   		;IF EXP CALC SET CARRY, CHECK FOR OVFL
		BMI 	MD3     		;IF NEG NO UNDERFLOW
		PLA         			;POP ONE
		PLA         			;RETURN LEVEL
		BCC 	NORMX   		;CLEAR X1 AND RETURN
MD3:
		EOR 	#$80    		;COMPLIMENT SIGN BIT OF EXP
		STA 	numConvX1      		;STORE IT
		LDY 	#$17    		;COUNT FOR 24 MUL OR 23 DIV ITERATIONS
		RTS         			;RETURN
OVCHK:
		BPL 	MD3     		;IF POS EXP THEN NO OVERFLOW
OVFL:
		JMP	numConvPanic
;
;
;     CONVERT EXP/MANT1 TO INTEGER IN M1 (HIGH) AND M1+1(LOW)
;      EXP/MANT2 UNEFFECTED
;
		JSR 	RTAR	   		;SHIFT MANT1 RT AND INCREMENT EXPNT
numConvFIX:
		LDA 	numConvX1      		;CHECK EXPONENT
		CMP 	#$8E    		;IS EXPONENT 14?
		BNE 	numConvFIX - 3   	;NO, SHIFT
		
RTRN:   
		RTS         			;RETURN


;===============================================================================
;FOR INIT.S
;===============================================================================

plrDefName:
			.byte 	$08, $90, $8C, $81, $99, $85, $92, $E4, $B0
cpuDefName:
			.byte 	$08, $83, $90, $95, $E4, $B0, $A0, $A0, $A0

;-------------------------------------------------------------------------------
initBoard:
;-------------------------------------------------------------------------------
		LDX	#$00
		
@loop:
		LDA	#$FF
		STA	sqr00, X
		INX
		
		LDA	#$00
		STA	sqr00, X
		INX
		
		CPX 	#$50
		BNE	@loop
		
		RTS


;-------------------------------------------------------------------------------
initSprites:
;-------------------------------------------------------------------------------
		LDA	#$23
		LDX	#$07
		STA	spritePtr0, X

		LDA	#%10000000		;Init sprite positions
		STA	vicSprPosM
	
		LDX	#$0E
		LDA	#$3A
		STA	vicSprPos0, X
		INX
		LDA	#$DF
		STA	vicSprPos0, X
	
		LDA	#<vicSprClr1		;sprite colours
		STA	$FB
		LDA	#>vicSprClr1
		STA	$FC
		
		LDA	#<plrColours
		STA	$FD
		LDA	#>plrColours
		STA	$FE
		
		LDY	#$00

@loop4:
		LDA	($FD), Y
		STA	($FB), Y
		
		INY
		CPY	#$06
		BNE	@loop4
		
		LDA	#$03
		STA	($FB), Y

		LDA	#$01			;MCM only mouse
		STA	vicSprCMod

		LDA	#$00
		STA	vicSprMCl0
		LDA	#$01
		STA	vicSprMCl1
		LDA	#$03
		STA	vicSprClr0
	
		LDA	#$20
		STA	spritePtr0
		
		LDA	#$00
		STA	vicSprExpX		
		STA	vicSprExpY

		LDA	#$FE			;Enable player sprites
		STA	vicSprEnab
		
		RTS
		
	
;-------------------------------------------------------------------------------
initMouse:
;-------------------------------------------------------------------------------
		LDA	#$FF			;Enable all sprites
		STA	vicSprEnab
		
		LDA	#$01
		STA	ui + UI::fMseEnb
		LDA	#$00
		STA	ui + UI::fJskEnb
		
		RTS

;-------------------------------------------------------------------------------
initPlayers:
;-------------------------------------------------------------------------------
		LDA	#'1'			;ASCII same as screen code
		ORA	#$80
		STA	plrDefName + 8

		LDX	#$00
		
@loop:
		STX	$A3
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::dirty
		LDA	#$01
		STA	($FB), Y

		LDY	#PLAYER::status
		STA	($FB), Y

		LDY	#PLAYER::square
		LDA	#$00
		STA	($FB), Y
		
		LDY	#PLAYER::equity
		STA	($FB), Y
		INY
		STA	($FB), Y
		
		LDY	#PLAYER::nGRls
		STA	($FB), Y
		
		LDY	#PLAYER::fCPU
		STA	($FB), Y
		
		LDY	#PLAYER::colour
		LDA	plrColours, X
		STA	($FB), Y
		
		LDY	#PLAYER::money
		LDA	#$DC
		STA	($FB), Y
		INY
		LDA	#$05
		STA	($FB), Y
		
		LDX	#$00
		LDY	#PLAYER::name
		
@loopName:
		LDA	plrDefName, X
		STA	($FB), Y
		INY
		INX
		CPX	#$09
		BNE	@loopName
		
		INC	plrDefName + 8
		
		LDY	#PLAYER::oGrp01
		LDX	#$09
		LDA	#$00
@loopGrpOwn:
		STA	($FB), Y
		INY
		DEX
		BPL	@loopGrpOwn
	
		LDY	#PLAYER::mDAcc0
		LDX	#$0D
		LDA	#$00
@loopDebit:
		STA	($FB), Y
		INY
		DEX
		BPL	@loopDebit
		
		LDX	$A3
		INX
		
		CPX	#$06
		BNE	@loop
	
		RTS
		
		
;-------------------------------------------------------------------------------
initNew:
;-------------------------------------------------------------------------------
		LDA	#$20
		STA	game + GAME::cntHs
		LDA	#$0C
		STA	game + GAME::cntHt

		LDA	#$06
		STA	game + GAME::pCount

		JSR	uiInitQueue		

		LDA	#$00			;init game
		STA	game + GAME::qVis		
		STA	game + GAME::pActive
		STA	game + GAME::fShwNxt
		STA	game + GAME::dieDbl
		STA	game + GAME::dieRld
		STA	game + GAME::nDbls
		STA	game + GAME::fMBuy
		STA	game + GAME::fMngmnt
		STA	game + GAME::gMode
		STA	game + GAME::fGF0Out
		STA	game + GAME::fGF1Out
		STA	game + GAME::fFPTax
		STA	game + GAME::mFPTax
		STA	game + GAME::mFPTax + 1
		
		LDA	#$FF
		STA	game + GAME::sSelect
		STA	game + GAME::pGF0Crd
		STA	game + GAME::pGF1Crd
		STA	game + GAME::pLast

		LDA	#<screenClear0
		STA	$FD
		LDA	#>screenClear0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS


;-------------------------------------------------------------------------------
initScreen:
;-------------------------------------------------------------------------------
		LDA	#$FF
		STA	button0
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1 
		
		JSR	statsClear
		JSR	prmptClear
		
		RTS


;-------------------------------------------------------------------------------
initMenu:
;-------------------------------------------------------------------------------
		LDA 	#<menuPageBlank0
		LDY	#>menuPageBlank0
		
		JSR	menuSetPage
		
		LDA	#$00
		STA	game + GAME::pVis

		JSR	gamePlayersDirty
		
		LDA	#<$DBA9
		STA	game + GAME::aWai
		LDA	#>$DBA9
		STA	game + GAME::aWai + 1
		
		LDA	#$01
		STA	game + GAME::kWai

		RTS


;-------------------------------------------------------------------------------
initDialog:
;-------------------------------------------------------------------------------
		LDA 	#<dialogDlgTitles0
		LDY	#>dialogDlgTitles0
		
		JSR	dialogSetDialog
		
		LDA	#<$DB8B
		STA	game + GAME::aWai
		LDA	#>$DB8B
		STA	game + GAME::aWai + 1
		
		LDA	#$01
		STA	game + GAME::kWai
		STA	game + GAME::dlgVis
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		RTS


;===============================================================================
;HEAP
;===============================================================================
heap0:
	.assert         heap0 < $CE00, error, "Program too large!"
	

;===============================================================================
;DISCARD.S
;===============================================================================

screenLoad0:
			.byte	$11, $00, $00, $28, $19
			.byte	$90, $00, $01
			.word	strText0Load0
			.byte	$00
screenLoad1:
			.byte	$90, $00, $02
			.word	strText0Load1
			.byte	$00
			
strText0Load0:		;LOADING RESOURCES...
			.byte $14, $0C, $0F, $01, $04, $09, $0E, $07
			.byte $20, $12, $05, $13, $0F, $15, $12, $03
			.byte $05, $13, $2E, $2E, $2E
strText0Load1:		;LOADING RULES...
			.byte $10, $0C, $0F, $01, $04, $09, $0E, $07
			.byte $20, $12, $15, $0C, $05, $13, $2E, $2E
			.byte $2E
			
FILENAME:
		.byte	"STRINGS"
FILENAME_2:
		.byte	"RULES"
FILENAME_3:


;-------------------------------------------------------------------------------
initVICII:
;-------------------------------------------------------------------------------
		LDA	CIA1_DDRA
		ORA	#$03
		STA	CIA1_DDRA
		
		LDA	CIA1_PRA
		AND	#$FC
		ORA	#$03
		STA	CIA1_PRA
		
		LDA	vicMemCtrl
		AND	#$0F
		ORA	#$10
		STA	vicMemCtrl
		
		RTS
	

;-------------------------------------------------------------------------------
initDataLoad:
;-------------------------------------------------------------------------------
		LDA	#$8E			;go to uppercase characters
		JSR	krnlOutChr
		LDA	#$08			;disable change character case
		JSR	krnlOutChr
		
		LDA	#<screenLoad0
		STA	$FD
		LDA	#>screenLoad0
		STA	$FE
		
		JSR	screenPerformList

		LDA	#$01
		LDX	#$08
		LDY	#$01
		
		JSR	krnlSetLFS
		
		LDA	#FILENAME_2 - FILENAME
		LDX	#<FILENAME
		LDY	#>FILENAME

		JSR	krnlSetNam
		
		LDA	#$00
		LDX	#<$E000
		LDY	#>$E000
		
		JSR	krnlLoad
		
		JSR	knrlClAll

		LDA	#<screenLoad1
		STA	$FD
		LDA	#>screenLoad1
		STA	$FE
		
		JSR	screenPerformList

		LDA	#$01
		LDX	#$08
		LDY	#$01
		
		JSR	krnlSetLFS
		
		LDA	#FILENAME_3 - FILENAME_2
		LDX	#<FILENAME_2
		LDY	#>FILENAME_2

		JSR	krnlSetNam
		
		LDA	#$00
		LDX	#<$F400
		LDY	#>$F400
		
		JSR	krnlLoad
		
		JSR	knrlClAll

		RTS


;-------------------------------------------------------------------------------
;initCore
;-------------------------------------------------------------------------------
initCore:
		JSR	initMem
		JSR	initKeys
		JSR	initFirstTime
		JSR	initBoard
		JSR	initSprites		
		JSR	initPlayers		
		JSR	initScreen
		JSR	initMenu
		JSR	initDialog

		LDA	#musTuneIntro
		JSR	SNDBASE + 0		
		
		JSR	initPlyr

;		Reset the stack pointer
		LDX	#$FF
		TXS

		JMP	main
		
;-------------------------------------------------------------------------------
;initMem
;-------------------------------------------------------------------------------
initMem:
;	Bank out BASIC + Kernal (keep IO).  First, make sure that the IO port
;	is set to output on those lines.
		LDA	$00
		ORA	#$07
		STA	$00
		
;	Now, exclude BASIC + KERNAL from the memory map (include only IO)
;		LDA	$01
;		AND	#$FC
;		ORA	#$01
		LDA	#$1D
		STA	$01		
		
		LDX	#$FF
		LDA	#$00
@loop:
		STA	$0300, X
		STA	$0200, X
		
		DEX
		BPL	@loop
		
		LDA	#<msePointer		;Set-up player token loc		
		STA	$FB
		LDA	#>msePointer
		STA	$FC
		
		LDA	#<spriteMem20		;Set-up sprite data loc
		STA	$FD
		LDA	#>spriteMem20
		STA	$FE
		
		LDY	#$00
@loop5:						;Copy mouse pointer data
		LDA	($FB), Y
		STA	($FD), Y
		
		INY
		CPY	#$3F
		BNE	@loop5

		RTS


;-------------------------------------------------------------------------------
initKeys:
;-------------------------------------------------------------------------------
;		LDA	#<keyEvaluateSpecial
;		STA	keyModifierVect
;		LDA	#>keyEvaluateSpecial
;		STA	keyModifierVect + 1
		
		LDA	#$00
		STA	keyRepeatFlag
		
;		LDA	#$80
;		STA	keyModifierLock
		
		LDA	#$0A
		STA	keyBufferSize
		RTS


;-------------------------------------------------------------------------------
initFirstTime:
;-------------------------------------------------------------------------------
		LDA  	#$0B			;set screen colours
		STA	vicBrdrClr
		LDA	#$00
		STA	vicBkgdClr
		
		LDA	#$00			;init game
		STA	game + GAME::sig
		STA	game + GAME::term
		STA	game + GAME::qVis		
		STA	game + GAME::dlgVis
		STA	ui + UI::fHveInp
		
		LDA	#JSTKSENS_LOW
		STA	ui + UI::cJskSns
		
		LDA	#$01
		STA	game + GAME::lock
		STA	game + GAME::pVis

		JSR	initNumConv

		JSR	initUI

		JSR	initNew

		RTS


;-------------------------------------------------------------------------------
initNumConv:
;-------------------------------------------------------------------------------
		LDA 	#$FF 			; maximum frequency value
		STA 	sidVoc2FLo		; voice 3 frequency low byte
		STA 	sidVoc2FHi		; voice 3 frequency high byte
		LDA 	#$80 			; noise waveform, gate bit off
		STA 	sidVoc2Ctl		; voice 3 control register		

		LDX	#$00
		TXA
@loop:
		STA	Z:numConvSIGN, X
		INX
		CPX	#$1A
		BNE	@loop

		LDA	#$EA
		STA	Z:numConvSIGN
		STA	Z:numConvX2
		STA	Z:numConvX1

		RTS


;-------------------------------------------------------------------------------
initUI:
;-------------------------------------------------------------------------------
		JSR	uiInitQueue
		LDA	#$FF
		LDY	#$00
		STA	($6D), Y
		RTS


;-------------------------------------------------------------------------------
initPlyr:
;-------------------------------------------------------------------------------
		LDX	game + GAME::pActive
		LDA	vicSprClr1, X
		STA	irqBlinkSeq0
		STA	irqBlinkSeq0 + 1
		
		STX	irqglob + IRQGLOBS::minPlr
		LDA	#$00
		STA	irqglob + IRQGLOBS::minIdx
		STA	irqglob + IRQGLOBS::minFlg
		
		LDA	ui + UI::cJskSns
		STA	ui + UI::cJskDly
		
		LDA	#$01
		STA	ui + UI::fMseEnb
		STA	ui + UI::fJskEnb
		
		JSR	CMOVEX
		JSR	CMOVEY
		
		JSR	installPlyr
		
		RTS


;-------------------------------------------------------------------------------
msePointer:
;-------------------------------------------------------------------------------
			.byte 	%01010101, %01010000, %00000000
			.byte 	%01111111, %11010000, %00000000
			.byte 	%01101010, %10010000, %00000000
			.byte 	%01101010, %01000000, %00000000
			.byte 	%01101010, %01000000, %00000000
			.byte 	%01101010, %11010000, %00000000
			.byte 	%01101010, %10110100, %00000000
			.byte 	%01101010, %10101101, %00000000
			.byte 	%01100110, %10101001, %00000000
			.byte 	%01010101, %10100100, %00000000
			.byte 	%01010001, %01100100, %00000000
			.byte 	%01010000, %01010100, %00000000
			.byte 	%01000000, %00010000, %00000000
			.byte 	%00000000, %00010000, %00000000
			.byte 	%00000000, %00000000, %00000000
			.byte 	%00000000, %00000000, %00000000
			.byte 	%00000000, %00000000, %00000000
			.byte 	%00000000, %00000000, %00000000
			.byte 	%00000000, %00000000, %00000000
			.byte 	%00000000, %00000000, %00000000
			.byte 	%00000000, %00000000, %00000000
			.byte	$00

	.assert         * < $D000, error, "Program too large!"
