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
;===============================================================================


;===============================================================================
;C64CLIENT.S
;===============================================================================

;-------------------------------------------------------------------------------
;defs
;-------------------------------------------------------------------------------
	.define	DEBUG_IRQ	0
	.define DEBUG_KEYS	0

spriteMemD	=	$0340
spriteMemE	=	$0380
spriteMemF	=	$03C0
spriteMem20	= 	$0800

spritePtr0	=	$07F8
spritePtr1	=	$07F9

vicSprPos0	=	$D000
vicSprPos1	=	$D002

vicSprPosM	=	$D010

vicSprMCl0	= 	$D025
vicSprMCl1	= 	$D026
vicSprClr0	= 	$D027
vicSprClr1	= 	$D028

vicSprCMod	= 	$D01C

vicSprExpX	= 	$D01D

vicSprExpY	=	$D017

vicSprEnab	= 	$D015

vicBrdrClr	=	$D020
vicBkgdClr	= 	$D021

vicCtrlReg	=	$D011

vicRstrVal	=	$D012

vicIRQMask	=	$D01A

vicIRQFlgs	=	$D019

cia1IRQCtl	=	$DC0D

VIC     	= 	$D000         		; VIC REGISTERS
VICXPOS    	= 	VIC + $00      		; LOW ORDER X POSITION
VICYPOS    	= 	VIC + $01      		; Y POSITION
VICXPOSMSB 	=	VIC + $10      		; BIT 0 IS HIGH ORDER X POS

SID     	= 	$D400         		; SID REGISTERS
sidVoc2FLo	=	$D40E
sidVoc2FHi	=	$D40F
sidVoc2Ctl	=	$D412
sidV2EnvOu	=	$D41B
SID_ADConv1    	= 	SID + $19
SID_ADConv2    	= 	SID + $1A

CIA1_DDRA	=	$DC02
CIA1_DDRB	=	$DC03
CIA1_PRB	=	$DC01
CIA1_PRA        = 	$DC00        ; Port A

offsX		=	24
offsY		=	50
buttonLeft	=	$10
buttonRight	=	$01


krnlUsrIRQ	=	$0314

krnlOutChr	= 	$E716
krnlScnKey	=	$EA87

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


keyF1		= 	$85
keyF3		=	$86
keyF5		=	$87
keyF7		=	$88
keyF2		=	$89
keyF4		=	$8A
keyF6		=	$8B
keyF8		=	$8C

JSTKSENS_LOW	=	27
JSTKSENS_MED	=	18
JSTKSENS_HIGH	=	9


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
		fTrdInt .byte			;interactive
		
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
						;8:  Trade stepping (f/e)
						;9:  Quit request
		
		tPrmT0	.tag	TOKEN
		tPrmT1	.tag	TOKEN
		tPrmC0	.tag	TOKEN
		tPrmC1	.tag	TOKEN

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
		mDAcc1	.word			;Same acc# as player no. is
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
		mValue	.word			;could be byte
		mFee	.word			;could be byte
		rRent	.word			;could be byte
		r1Hse	.word
		r2Hse	.word
		r3Hse	.word
		r4Hse	.word
		rHotl	.word
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
	
	
	.struct	MENUPAGE
		fKeys	.word
		fDraw	.word
		bDef	.byte
	.endstruct


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
	.assert         * = $080D, error, "BASIC Loader incorrect!"
bootstrap:
		JMP	init
	
;dengland
;	We need this space in order to use it for the mouse pointer (from $0800)
	.byte		$00, $00, $00, $00, $00, $00, $00, $00
	.byte		$00, $00, $00, $00, $00, $00, $00, $00
	.byte		$00, $00, $00, $00, $00, $00, $00, $00
	.byte		$00, $00, $00, $00, $00, $00, $00, $00
	.byte		$00, $00, $00, $00, $00, $00, $00, $00
	.byte		$00, $00, $00, $00, $00, $00, $00, $00
	.assert         * = $0840, error, "Program bootstrap incorrect!"

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
;Global variables
;-------------------------------------------------------------------------------
ui:		.tag 	UI
game:		.tag	GAME
plr0:		.tag	PLAYER
plr1:		.tag	PLAYER
plr2:		.tag	PLAYER
plr3:		.tag	PLAYER
plr4:		.tag	PLAYER
plr5:		.tag 	PLAYER
sqr00:		.tag	SQUARE	
sqr01:		.tag	SQUARE	
sqr02:		.tag	SQUARE	
sqr03:		.tag	SQUARE	
sqr04:		.tag	SQUARE	
sqr05:		.tag	SQUARE	
sqr06:		.tag	SQUARE	
sqr07:		.tag	SQUARE	
sqr08:		.tag	SQUARE	
sqr09:		.tag	SQUARE	
sqr0A:		.tag	SQUARE	
sqr0B:		.tag	SQUARE	
sqr0C:		.tag	SQUARE	
sqr0D:		.tag	SQUARE	
sqr0E:		.tag	SQUARE	
sqr0F:		.tag	SQUARE	
sqr10:		.tag	SQUARE	
sqr11:		.tag	SQUARE	
sqr12:		.tag	SQUARE	
sqr13:		.tag	SQUARE	
sqr14:		.tag	SQUARE	
sqr15:		.tag	SQUARE	
sqr16:		.tag	SQUARE	
sqr17:		.tag	SQUARE	
sqr18:		.tag	SQUARE	
sqr19:		.tag	SQUARE	
sqr1A:		.tag	SQUARE	
sqr1B:		.tag	SQUARE	
sqr1C:		.tag	SQUARE	
sqr1D:		.tag	SQUARE	
sqr1E:		.tag	SQUARE	
sqr1F:		.tag	SQUARE	
sqr20:		.tag	SQUARE	
sqr21:		.tag	SQUARE	
sqr22:		.tag	SQUARE	
sqr23:		.tag	SQUARE	
sqr24:		.tag	SQUARE	
sqr25:		.tag	SQUARE	
sqr26:		.tag	SQUARE	
sqr27:		.tag	SQUARE	

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
;init
;-------------------------------------------------------------------------------
init:
;		PHP				;save the initial state
;		PHA	
;		TYA				;Don't bother, we're no longer 
;		PHA				;going back.
;		TXA
;		PHA

		CLD

		LDA	#$8E			;go to uppercase characters
		JSR	krnlOutChr
		
		LDA	#$08			;disable change character case
		JSR	krnlOutChr

		LDA  	#$0B			;set screen colours
		STA	vicBrdrClr
		LDA	#$00
		STA	vicBkgdClr

		JSR	initMem

		JSR	initBoard

		JSR	initSprites		
		
		JSR	initPlayers		

		JSR	initFirstTime

		JSR	initScreen

		JSR	initMenu
			
		JSR	initDialog

		LDA	#musTuneIntro
		JSR	SNDBASE + 0		
		
		JSR	plyrInit
 		JSR	plyrInstall


		JMP	uloop			;jump to updates

;-------------------------------------------------------------------------------
;main
;-------------------------------------------------------------------------------
main:
;		LDA	game + GAME::term
;		BNE	exit
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
		
exit:
		JSR	plyrUninstall
		
		JSR	finMem
		
		LDA	#$09			;enable change character case
		JSR	krnlOutChr

;		PLA				;restore initial state
;		TAX
;		PLA				;We're not going back
;		TAY
;		PLA
;		PLP

hang:
		JMP	hang

		RTS				;return to BASIC
		

;-------------------------------------------------------------------------------
;initMem
;-------------------------------------------------------------------------------
initMem:
;	Bank out BASIC (keep Kernal and IO).  First, make sure that the IO port
;	is set to output on those lines.
		LDA	$00
		ORA	#$07
		STA	$00
		
;	Now, exclude BASIC from the memory map (and include Kernal and IO)
		LDA	$01
		AND	#$FE
		ORA	#$06
		STA	$01		
		
;		LDX	#$00			;We don't need to back-up the
;@loop:						;zero page since we're no
;		LDA	$00, X			;longer returning to BASIC
;		STA	$C000, X
;		INX
;		BNE	@loop
		
		RTS


;-------------------------------------------------------------------------------
;finMem
;-------------------------------------------------------------------------------
finMem:
;		LDX	#$00			;We haven't backed-up the zero
;@loop:						;page
;		LDA	$C000, X
;		STA	$00, X
;		INX
;		BNE	@loop
		
		RTS


;-------------------------------------------------------------------------------
;handleUpdates
;-------------------------------------------------------------------------------
handleUpdates:
		LDA	game + GAME::pActive
		CMP	game + GAME::pLast
		BEQ	@tststep
		
		LDA	game + GAME::fShwNxt
		BEQ	@tststep
		
		JSR	gameShowPlayerDlg
	
@tststep:
		LDA	game + GAME::gMode
		CMP	#$06
		BNE	@tsttrdsel
		
		JSR	gamePerfStepping
		
@tsttrdsel:
		CMP	#$07
		BNE	@tsttrdstep
		
		JSR	gamePerfTrdSelBlink
		
@tsttrdstep:
		LDA	game + GAME::gMode
		CMP	#$08
		BNE	@tstdirty
		
		JSR	gamePerfTradeStepping

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
		BEQ	@noDialog
		
@updDialog:
		JSR	dialogDisplay

@noDialog:

		LDA	#$00
		STA	game+GAME::dirty

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
;gameRebuildScreen
;-------------------------------------------------------------------------------
gameRebuildScreen:
		JSR	screenBeginButtons	;???Is this really required???

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
screenResetSelBtn:
;-------------------------------------------------------------------------------
		LDA	ui + UI::fMseEnb
		BEQ	@joystick

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
		STA	ui + UI::iSelBtn
		
		STA	ui + UI::fBtUpd0
		LDA	#$01
		STA	ui + UI::fBtSta0
		
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
		vector	.word
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
;plyrInit
;-------------------------------------------------------------------------------
plyrInit:
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
		
		RTS


;-------------------------------------------------------------------------------
;plyrInstall
;-------------------------------------------------------------------------------
plyrInstall:
		LDA	irqglob + IRQGLOBS::instld
		CMP	#$01
		BEQ	@exit

		SEI
		
		LDA	krnlUsrIRQ		;Save current IRQ handler
		STA	irqglob + IRQGLOBS::vector
		LDA	krnlUsrIRQ + 1
		STA	irqglob + IRQGLOBS::vector + 1
		
		LDA	#<plyrIRQ		;install our handler
		STA	$0314
		LDA	#>plyrIRQ
		STA	$0315

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

		LDA	#$7F			;disable standard CIA irqs
		STA	cia1IRQCtl

		CLI

@exit:
		RTS
		

;-------------------------------------------------------------------------------
;plyrUninstall
;-------------------------------------------------------------------------------
plyrUninstall:
		LDA	irqglob + IRQGLOBS::instld
		CMP	#$00
		BEQ	@exit

		SEI
		
						;restore original handler
		LDA	irqglob + IRQGLOBS::vector
		STA	krnlUsrIRQ
		LDA	irqglob + IRQGLOBS::vector + 1
		STA	krnlUsrIRQ + 1
		
		LDA	#$00			;disable raster IRQs
		STA	vicIRQMask
		
		LDA	#$FF			;enable standard CIA IRQs
		STA	cia1IRQCtl
		
		LDA	#$00
		STA	irqglob + IRQGLOBS::instld
		
		CLI
		
@exit:
		RTS



;-------------------------------------------------------------------------------
;plyrIRQ
;-------------------------------------------------------------------------------
;***TODO:		Should use self-patching in IRQ routine.  Use RAM!
;***FIXME:		Perhaps way it does so much testing is reason for 
;			occassional failure?
;***FIXME:		Don't do third interrupt?  Process its code after
;			second?

plyrIRQ:
;		PHP				;save the initial state
;		PHA
;		TXA				;de This is done in the kernal
;		PHA
;		TYA
;		PHA

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
		
;		JMP	(irqglob + IRQGLOBS::vector)
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
	
;dengland
;		I seem to need to call this regularly or else there is a jam for 
;		some reason???
		JSR	krnlScnKey

		LDA	game + GAME::sig	;Don't process the mouse click
		BNE	@skipKeys		;or keys if the FrontEnd is busy
		
	.if	DEBUG_IRQ
		LDA	#$02
		STA	vicBrdrClr
	.endif

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

@skipKeys:
		JSR	handleHotBlink

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

		
		LDA	#$0D
		STA	irqglob + IRQGLOBS::varA
	.if	DEBUG_IRQ
		LDA	#$01
	.endif
		LDY	#$00
		JMP	@begin
				
@miniPrep:
		LDA	#$0E
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

		RTI


;-------------------------------------------------------------------------------
;plyrCheckStepping
;-------------------------------------------------------------------------------
plyrCheckStepping:
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
		LDY	$0277			;copy kernal code for input key
		LDX	#$00
@loop:
		LDA	$0278, X
		STA	$0277, X
		INX
		CPX	$C6
		BNE	@loop
		
		DEC	$C6
		TYA
;		CLI				;NO!  Causes problem for IRQ
		CLC
		RTS

;-------------------------------------------------------------------------------
;handleKeys
;-------------------------------------------------------------------------------
handleKeys:
;dengland	We have done these already elsewhere or are copying them
;		JSR	$EA87			;scan keyboard **NOT REQ'D**
;		JSR 	$FFE4			;call get character from input
		
		
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
		LDA	$C6			;copy kernal code for get key
		BNE	@1
		RTS
		
@1:
		JSR	handleKeyInput		;Do the key fetch
		PHA				;save pressed key
		
		LDA	game + GAME::dlgVis	;Is a dialog visible?
		BNE	@dialog			;Yes - pass keys to it
		
		PLA				;No - pass keys to menu
		JMP	(menuActivePage0 + MENUPAGE::fKeys)
		
@dialog:	
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
		JSR	doInjectKey
		
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
		JSR	doInjectKey
		
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
		
		JSR	doInjectKey

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
		
		JSR	doInjectKey
		
@exit:
		RTS
		
		
;-------------------------------------------------------------------------------
;doInjectKey:
;-------------------------------------------------------------------------------
doInjectKey:	
		LDX	$C6			;Put a key into the buffer
		STA	$0277, X
		INC	$C6
		
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


;-------------------------------------------------------------------------------
;prmptClear
;-------------------------------------------------------------------------------
prmptClear:
		LDA 	#$20
		LDX	#$1F
@loop1:
		STA	game + GAME::tPrmT0, X
		
		DEX
		BPL	@loop1

		LDX	#$0F
@loop2:
		LDA	#$0C
		STA	game + GAME::tPrmC0, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X
		
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
		STA	game + GAME::tPrmT1, X
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
		LDA	game + GAME::tPrmT0, X
		STA	prmpt0Txt0, X
		LDA	game + GAME::tPrmC0, X
		STA	prmpt0Clr0, X
		
		LDA	game + GAME::tPrmT1, X
		STA	prmpt1Txt0, X
		LDA	game + GAME::tPrmC1, X
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
		STA	game + GAME::tPrmC0 + $05, X
		DEX
		BPL	@loop0

		JSR	numConvPRTSGN
		
		LDA	heap0
		STA	game + GAME::tPrmT0 + $05
		LDA	heap0 + $04
		STA	game + GAME::tPrmT0 + $06
		LDA	heap0 + $05
		STA	game + GAME::tPrmT0 + $07
		
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
		STA	game + GAME::tPrmC0 + $0D, X
		DEX
		BPL	@loop1
		
		JSR	numConvPRTSGN
		
		LDA	heap0
		STA	game + GAME::tPrmT0 + $0D
		LDA	heap0 + $04
		STA	game + GAME::tPrmT0 + $0E
		LDA	heap0 + $05
		STA	game + GAME::tPrmT0 + $0F
		
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
		STA	game + GAME::tPrmT1 + $0A, X
		
		LDA	prmptTemp2
		AND	#$0F
		STA	game + GAME::tPrmC1 + $0A, X
		
		DEX
		BPL	@loop2
		
		STA	game + GAME::tPrmC1 + $09

;		LDA	prmptTemp2			;This would put a + in
;		AND	#$0F				;all add cash (green) values
;		CMP	#$05				;but it looks strange 
;		BNE	@exit				;sometimes - eg for sale 
;		LDA	#$2B
;		STA	game + GAME::tPrmT1 + $0A

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
		STA	game + GAME::tPrmT0, X

		LDA	#$0C
		STA	game + GAME::tPrmC0, X

		DEX
		BPL	@loop1
		
		PLA
		STA	game + GAME::tPrmC0
		
		LDA	game + GAME::dieA
		CLC
		ADC	#'0'
		STA	game + GAME::tPrmT0 + $09
		
		LDA	game + GAME::dieB
		CLC
		ADC	#'0'
		STA	game + GAME::tPrmT0 + $0B

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
		STA	game + GAME::tPrmT0, X

		LDA	#$0C
		STA	game + GAME::tPrmC0, X

		DEX
		BPL	@loop1
		
		LDA	#$0F
		STA	game + GAME::tPrmC0
		
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
		STA	game + GAME::tPrmT1, X

		LDA	#$01
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1

		PLA
		STA	game + GAME::tPrmC1

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
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1

		PLA
		STA	game + GAME::tPrmC1

		LDA	prmptTemp2
		AND	#$F0
		STA	prmptTemp2
		
		LDA	#$20
		ORA	game + GAME::dirty
		STA	game + GAME::dirty
		
		RTS


prmptDoSubCash:
		PLA
		STA	game + GAME::tPrmC1
		
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
		STA	game + GAME::tPrmC1
		
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
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash
		

prmptBought:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptBought, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash
		
		
prmptPostBail:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptPostBail, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash
		
		
prmptTax:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptTax, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptFee:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptFee, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptSalary:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptSalary, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptFParking:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptFParking, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptSold:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptSold, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash
		
		
prmptMortgage:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptMortgage, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash
		
		
prmptRepay:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptRepay, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptChestSub:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChest, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptChanceSub:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChance, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoSubCash


prmptChestAdd:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChest, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		JMP	prmptDoAddCash


prmptChanceAdd:
		TXA
		PHA

		LDX	#$0F
@loop1:
		LDA	tokPrmptChance, X
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

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
		STA	game + GAME::tPrmT1, X

		LDA	#$0F
		STA	game + GAME::tPrmC1, X

		DEX
		BPL	@loop1
		
		LDA	#$0F
		PHA
		
		JMP	prmptDoAddCash

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

menuActivePage0:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00
menuActivePage1:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00
menuActivePage2:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00
		
		
menuLastDrawFunc:
		.word	$0000


menuPageBlank0:
		.word	menuPageBlank0Keys
		.word	menuDefDraw
		.byte	$00			;Have to say 0 so not drawn
						;twice.

menuPagePlay0:
		.word	menuPagePlay0Keys
		.word	menuPagePlay0Draw
		.byte	$01
		
menuPagePlay1:
		.word	menuPagePlay1Keys
		.word	menuPagePlay1Draw
		.byte	$01
		
menuPagePlay2:
		.word	menuPagePlay2Keys
		.word	menuPagePlay2Draw
		.byte	$01
		
menuPageAuctn0:
		.word	menuPageAuctn0Keys
		.word	menuPageAuctn0Draw
		.byte	$01
		
menuPageAuctn1:
		.word	menuPageAuctn1Keys
		.word	menuPageAuctn1Draw
		.byte	$01
		
menuPageManage0:
		.word	menuPageManage0Keys
		.word	menuPageManage0Draw
		.byte	$01
		
menuPageTrade0:
		.word	menuPageTrade0Keys
		.word	menuPageTrade0Draw
		.byte	$01
		
menuPageTrade1:
		.word	menuPageTrade1Keys
		.word	menuPageTrade1Draw
		.byte	$01
		
menuPageTrade6:
		.word	menuPageTrade6Keys
		.word	menuPageTrade6Draw
		.byte	$01
		
menuPageElimin0:
		.word	menuPageElimin0Keys
		.word	menuPageElimin0Draw
		.byte	$01
		
menuPagePlyrSel0:
		.word	menuPagePlyrSel0Keys
		.word	menuPagePlyrSel0Draw
		.byte	$01
		
menuPageGaol0:
		.word	menuPageGaol0Keys
		.word	menuPageGaol0Draw
		.byte	$01
		
menuPageGaol1:
		.word	menuPageGaol1Keys
		.word	menuPageGaol1Draw
		.byte	$01
menuPageGaol2:
		.word	menuPageGaol2Keys
		.word	menuPageGaol2Draw
		.byte	$01
menuPageGaol3:
		.word	menuPageGaol3Keys
		.word	menuPageGaol3Draw
		.byte	$01
		
menuPageSetup0:
		.word	menuPageSetup0Keys
		.word	menuPageSetup0Draw
		.byte	$01

menuPageSetup1:
		.word	menuPageSetup1Keys
		.word	menuPageSetup1Draw
		.byte	$01

menuPageSetup2:
		.word	menuPageSetup2Keys
		.word	menuPageSetup2Draw
		.byte	$01
		
menuPageSetup3:
		.word	menuPageSetup3Keys
		.word	menuPageSetup3Draw
		.byte	$01
		
menuPageSetup4:
		.word	menuPageSetup4Keys
		.word	menuPageSetup4Draw
		.byte	$01
		
menuPageSetup5:
		.word	menuPageSetup5Keys
		.word	menuPageSetup5Draw
		.byte	$01
		
menuPageSetup6:
		.word	menuPageSetup6Keys
		.word	menuPageSetup6Draw
		.byte	$01
		
menuPageSetup7:
		.word	menuPageSetup7Keys
		.word	menuPageSetup7Draw
		.byte	$01
		
menuPageSetup8:
		.word	menuPageSetup8Keys
		.word	menuPageSetup8Draw
		.byte	$01
		
		
menuPageMustPay0:
		.word	menuPageMustPay0Keys
		.word	menuPageMustPay0Draw
		.byte	$01
		
menuPageJump0:
		.word	menuPageJump0Keys
		.word	menuPageJump0Draw
		.byte	$01

menuPageQuit0:
		.word	menuPageQuit0Keys
		.word	menuPageQuit0Draw
		.byte	$01

menuPageQuit1:
		.word	menuPageQuit1Keys
		.word	menuPageQuit1Draw
		.byte	$01

menuPageQuit2:
		.word	menuPageQuit2Keys
		.word	menuPageQuit2Draw
		.byte	$01


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
		LDA	#$01
		CMP	menuActivePage0 + MENUPAGE::bDef
		BNE	@cont
		
		JSR	menuDefDraw
@cont:
		LDA	#>(@farreturn - 1)
		PHA
		LDA	#<(@farreturn - 1)
		PHA

		LDA	#$00
		STA	ui + UI::fWntJFB
		
		JMP	(menuActivePage0 + MENUPAGE::fDraw)
		
@farreturn:
		LDA	ui + UI::fMseEnb
		BNE	@reset

		LDA	ui + UI::fJskEnb
		BNE	@tstreset
	
		RTS
	
@tstreset:
		LDA	ui + UI::iSelBtn
		CMP	#$FF
		BEQ	@havedraw
		
		JSR	screenTestSelBtn
;		CMP	#$00
		BEQ	@havedraw
		
		LDA	game + GAME::pActive
		CMP	game + GAME::pLast
		BNE	@havedraw

		LDA	menuActivePage0 + MENUPAGE::fDraw
		CMP	menuLastDrawFunc
		BNE	@havedraw
		
		LDA	menuActivePage0 + MENUPAGE::fDraw + 1
		CMP	menuLastDrawFunc + 1
		BEQ	@exit

@havedraw:
		LDA	menuActivePage0 + MENUPAGE::fDraw
		STA	menuLastDrawFunc
		LDA	menuActivePage0 + MENUPAGE::fDraw + 1
		STA	menuLastDrawFunc + 1
		
@reset:

		LDA	#$FF
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1
		
		JSR	screenResetSelBtn
		
@exit:
		RTS

;-------------------------------------------------------------------------------
menuSetPage:
;-------------------------------------------------------------------------------
		STA	$FD
		STY	$FE
		
		LDY	#MENUPAGE::fKeys
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::fKeys
		INY
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::fKeys + 1

		LDY	#MENUPAGE::fDraw
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::fDraw
		INY
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::fDraw + 1

		LDY	#MENUPAGE::bDef
		LDA	($FD), Y
		STA	menuActivePage0 + MENUPAGE::bDef
		
		RTS


;-------------------------------------------------------------------------------
menuPushPage:
;-------------------------------------------------------------------------------
		STA	$FD
;		STY	$FE

		LDX	#$04
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
		LDX	#$04
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
		JSR	menuPageSetup1EnbAll

		LDA 	#<menuPageSetup1
		LDY	#>menuPageSetup1
		
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
			
			
menuPageSetup0Draw:
		JSR	screenBeginButtons
		
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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons
		
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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		
		JMP	@doMse

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

		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

		LDA	#<menuWindowSetup8
		STA	$FD
		LDA	#>menuWindowSetup8
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
		BNE	@keysBuzz
		
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
		BNE	@keysOther
		
		JSR	rulesLandOnSquare
		LDA	#$01
		ORA	game + GAME::dirty
		STA	game + GAME::dirty

		JSR	gameUpdateMenu
		RTS
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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		
;		So, if money less than A, Y - set carry else clear
		JSR	gamePlayerHasFunds
		BCC	@beginbid
		
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
		BEQ	@keysExit		;Yes, so don't do anything
		
@dobid:
		JSR	menuPageAuctn0Bid
		JSR	rulesNextTurn
		JMP	@keysUpdateAll
		
@keysP:
		CMP	#'P'
		BNE	@keysF

		JSR	menuPageAuctn0Pass
		JSR	rulesNextTurn
		JMP	@keysUpdateAll
		

@keysF:
		CMP	#'F'
		BNE	@keysOther
		
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
		
;		D, E < A, Y -> SEC | CLC
		JSR	gameAmountIsLess	;If trying to bid less...
		BCC	@keysUpdate

		LDA	game + GAME::mAuctn	;reset the bid
		STA	game + GAME::mACurr
		LDA	game + GAME::mAuctn + 1
		STA	game + GAME::mACurr + 1
		
		JMP	@keysBuzz		
		
@tstHaveFunds:
		LDA	game + GAME::mACurr
		LDY	game + GAME::mACurr + 1
		
;		So, if money less than A, Y - set carry else clear
		JSR	gamePlayerHasFunds
		BCC	@keysUpdate
		
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
		ORA	#$01
		STA	game + GAME::dirty

		RTS

@keysDefault:
		JSR	menuPageAuctnDefKeys


menuPageAuctn0Draw:
		LDA	game + GAME::mACurr
		LDY	game + GAME::mACurr + 1
		
;		So, if money less than A, Y - set carry else clear
		JSR	gamePlayerHasFunds
		BCC	@havefunds
		
		LDA	#$A0
		STA	menuWindowAuctn0Bid
		
		JMP	@beginbid
		
@havefunds:
		LDA	#$A1
		STA	menuWindowAuctn0Bid

@beginbid:
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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

		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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


;-------------------------------------------------------------------------------
;menuPageManage0Keys
;-------------------------------------------------------------------------------
menuPageManage0Keys:
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


menuWindowManage0:
			.byte	$90, $01, $07
			.word	     strHeaderMng0

			.byte	$A1, $0A, $01, $12, $46, $02, $0A
			.word	     strOptn0Mng0
			.byte	$A1, $0C, $01, $12, $42, $02, $0C
			.word	     strOptn1Mng0
			.byte	$A1, $0E, $01, $12, $4D, $02, $0E
			.word	     strOptn2Mng0
			.byte	$A1, $10, $01, $12, $43, $02, $10
			.word	     strOptn3Mng0
			.byte	$A1, $12, $01, $12, $53, $02, $12
			.word	     strOptn4Mng0
			.byte	$A1, $14, $01, $12, $49, $02, $14
			.word	     strOptn5Mng0
			.byte	$A1, $16, $01, $12, $44, $02, $16
			.word	     strOptn6Mng0

			.byte	$00


menuPageManage0Draw:
		JSR	prmptManage
		
		JSR	screenBeginButtons

		LDA	#<menuWindowManage0
		STA	$FD
		LDA	#>menuWindowManage0
		STA	$FE
		
		JSR	screenPerformList
		
		LDA	#$01
		STA	ui + UI::fWntJFB
		
		RTS
		RTS


menuWindowTradeCanConf:
		.byte	$00
		
menuTrade0RemWealth:
		.byte	$00
		.byte	$00
		.byte	$00


menuTrade0RWealthRecalc:
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
		
		LDY	#TRADE::money
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
		
		LDY	#TRADE::cntDeed
		LDA	trade1, Y
		BNE	@dosub
		
		RTS
		
@dosub:
		TAX
		DEX
		
@loop:
		LDA	trdrepay1, X
		AND	#$80
		BNE	@next

		STX	game + GAME::varA

		LDA	trddeeds1, X
		JSR	gameGetCardPtrForSquare
		
		LDY	#DEED::mValue
		
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
		
		LDX	game + GAME::varA
		
@next:
		DEX
		BPL	@loop
		
		RTS


menuWindowTrade0:
			.byte	$90, $01, $07
			.word	     strHeaderTrade0

			.byte	$A1, $0A, $01, $12, $50, $02, $0A
			.word	     strOptn0Trade0
menuWindowTradeWB:
			.byte	$A1, $0C, $01, $12, $57, $02, $0C
			.word	     strOptn1Trade0
			.byte	$A1, $0E, $01, $12, $4F, $02, $0E
			.word	     strOptn2Trade0
menuWindowTradeCB:
			.byte	$A1, $10, $01, $12, $43, $02, $10
			.word	     strOptn3Trade0
			.byte	$A1, $12, $01, $12, $58, $02, $12
			.word	     strOptn4Trade0

			.byte	$00
			
menuPageTrade0Keys:
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
		JSR	screenBeginButtons

		LDX	#TRADE::player
		LDA	menuPlyrSelSelect
		
		CMP	trade0, X			;If the player is changed
		BEQ	@cont				;we need to clear the 
							;wanted data
							
;		LDA	#$00				;Don't do this.  This will
;		STA	menuWindowTradeCanConf		;allow an odd corner case
							;but we need more flags to
							;do it properly.
		
		LDX	#.SIZEOF(TRADE) - 1	;Clear the wanted data
		LDA	#$00
@loop0:
		STA 	trade0, X
		
		DEX
		BPL	@loop0
		
		LDX	#$27
@loop1:
		STA	trddeeds0, X
		STA	trdrepay0, X

		DEX
		BPL	@loop1

		LDX	#TRADE::player
		LDA	menuPlyrSelSelect
		STA	trade0, X
		
		JSR	menuTrade0RWealthRecalc
		
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
		INY
		LDA	($FB), Y
		STA	menuTrade1RemWealth + 1
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
		BEQ	@equity

		LDA	#$01
		STA	menuTrade1Warn0

		LDY	#DEED::mFee		;At least a fee for mrtg
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
		BPL	@loop
		
		
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
			.byte	$A1, $12, $01, $12, $58, $02, $12
			.word	     strOptn4Trade0

			.byte	$00
			
menuPageTrade1Keys:
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
		JSR	gamePerfTradeFullTerm

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
		JSR	screenBeginButtons

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
		STA	game + GAME::fTrdInt
		
		JSR	gamePerfTradeFullCont

@exit:
		RTS
		

menuPageTrade6Draw:
		JSR	screenBeginButtons

		LDA	#<menuWindowTrade6
		STA	$FD
		LDA	#>menuWindowTrade6
		STA	$FE
		
		JSR	screenPerformList
		RTS


menuElimin0HaveOffer:
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


menuWindowElimin0:
			.byte	$90, $01, $07
			.word	     strHeaderElimin0

			.byte	$A1, $0A, $01, $12, $50, $02, $0A
			.word	     strOptn0Trade0
			.byte	$A1, $0E, $01, $12, $4F, $02, $0E
			.word	     strOptn2Trade0
			.byte	$A1, $10, $01, $12, $43, $02, $10
			.word	     strOptn3Trade0

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
		BPL	@proc
		
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

		JSR	gamePerfTradeFull
		JMP	@keysDing
		
@stepping:
		JSR	gamePerfTradeIntrpt
		
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
		JSR	screenBeginButtons

		LDA	#<menuWindowElimin0
		STA	$FD
		LDA	#>menuWindowElimin0
		STA	$FE
		
		JSR	screenPerformList
		
		RTS



menuPlyrSelAllowCur:
		.byte	$00
menuPlyrSelSelect:
		.byte	$00
menuPlyrSelCallProc:
		.word	$0000


	.define	PLYRSEL_P	.HIBYTE(*)
menuWindowPlyrSelPN:
;***THIS IS VERY NAUGHTY SO THE MENU DATA CAN'T CROSS PAGE BOUNDARY
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
	.assert	PLYRSEL_P = .HIBYTE(*), error, "WindowPlyrSel must be on one page!"
			
			
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
		JSR	screenBeginButtons

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
		
		BEQ	@disable
		
		LDA	menuWindowPlyrSelPN, X
		TAY
		LDA	#$A1
		STA	($A3), Y

		JMP	@next

@disable:
		LDA	menuWindowPlyrSelPN, X
		TAY
		LDA	#$A2
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
		
		LDA	menuPlyrSelAllowCur
		BNE	@exit
		
		LDX	game + GAME::pActive
		
		LDA	plrLo, X
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::name
		LDA	($FB), Y
		STA	game + GAME::varA
		INY
		LDA	($FB), Y
		STA	game + GAME::varB
		
		LDA	menuWindowPlyrSelNN, X
		TAY
		LDA	game + GAME::varA
		STA	($A3), Y
		INY
		LDA	game + GAME::varB
		STA	($A3), Y
		
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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

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
		JSR	screenBeginButtons

		LDA	#<menuWindowQuit2
		STA	$FD
		LDA	#>menuWindowQuit2
		STA	$FE
		
		JSR	screenPerformList

		RTS


;===============================================================================
;FOR GAME.S
;===============================================================================



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
	
;		D, E < (O, P) -> SEC | CLC
		JSR	gameAmountIsLessDirect
		BCC	@next
		
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
gamePerfTradeStepping:
;-------------------------------------------------------------------------------
		LDA	game + GAME::fStpSig
		BNE	@proc
		
		RTS
		
@proc:
		JSR	gamePerfTradeStep
		
		LDA	#$00
		STA	game + GAME::fStpSig
		
		LDA	game + GAME::fTrdStg
		CMP	#$FF
		BNE	@exit
		
;		Pop player and mode from trade/elimin
		JSR	gamePerfTradeFullTerm

@exit:
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
		BNE	@exit
		
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
		
@exit:
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
		LDX	#.SIZEOF(TRADE) - 1
		LDA	#$00
@loop0:
		STA 	trade0, X
		STA	trade1, X
		
		DEX
		BPL	@loop0
		
		LDX	#$27
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

		LDY	#.SIZEOF(TRADE) - 1	;Copy basic trade info
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
		BPL	@tstWantedRW
		
		LDA 	#<dialogDlgTrade2
		LDY	#>dialogDlgTrade2
		
		JSR	gameInitTrdFail0
		RTS

@tstWantedRW:
		JSR	menuTrade1RWealthRecalc
		LDA	menuTrade1RemWealth + 2
		BPL	@initiate
		
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
		BPL	@tstWarning
		
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
		LDA	game + GAME::fDoJump
		BEQ	@stepping

		LDA	#$00
		STA	game + GAME::fTrdTyp
		
		JSR	gamePerfTradeFull
		RTS
		
@stepping:
		LDA	#$00
		STA	game + GAME::fTrdTyp
		
		JSR	gamePerfTradeIntrpt

		RTS


;-------------------------------------------------------------------------------
gamePerfTradeStep:
;-------------------------------------------------------------------------------
		JSR	gamePerfTradeDeselect

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
		
		LDY	#TRADE::player
		LDA	trade0, Y
		STA	game + GAME::pLast
		STA	game + GAME::pActive
		
;			- phase 0 - transfer deed
		LDX	game + GAME::iTrdStp 
		LDA	trddeeds1, X
		JSR	gamePerfTradeFocus
		
		LDA	trddeeds1, X
		TAX
		JSR	rulesTradeTitleDeed
		
;		JSR	gamePerfTradeDeselect

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
		STA	game + GAME::pLast
		STA	game + GAME::pActive
		
;			- phase 1 - fee/repay deed
		LDX	game + GAME::iTrdStp 
		LDA	trdrepay1, X
		AND	#$01
		BNE	@stage0ph1repay

		LDX	game + GAME::iTrdStp 

		LDA	trddeeds1, X
		JSR	gamePerfTradeFocus

		LDA	trddeeds1, X
		JSR	rulesMortgageFeeImmed

;		JSR	gamePerfTradeDeselect
		
		JMP	@stage0nextdeed
		
@stage0ph1repay:
		LDX	game + GAME::iTrdStp 
		LDA	trddeeds1, X
		JSR	gamePerfTradeFocus

		LDA	trddeeds1, X
		JSR	rulesUnmortgageImmed
		
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
		STA	game + GAME::kWai
		
		JSR	gamePerfTradeDeselect
		
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
		
		LDY	#TRADE::player
		LDA	trade1, Y
		STA	game + GAME::pLast
		STA	game + GAME::pActive
		
;			- phase 0 - transfer deed
		LDX	game + GAME::iTrdStp 
		LDA	trddeeds0, X
		JSR	gamePerfTradeFocus

		LDA	trddeeds0, X
		TAX
		JSR	rulesTradeTitleDeed
		
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
		STA	game + GAME::pLast
		STA	game + GAME::pActive
		
;			- phase 1 - fee/repay deed
		LDX	game + GAME::iTrdStp 
		LDA	trdrepay0, X
		AND	#$01
		BNE	@stage1ph1repay

		LDX	game + GAME::iTrdStp 
		LDA	trddeeds0, X
		JSR	gamePerfTradeFocus

		LDA	trddeeds0, X
		JSR	rulesMortgageFeeImmed
		
;		JSR	gamePerfTradeDeselect

		JMP	@stage1nextdeed
		
@stage1ph1repay:
		LDX	game + GAME::iTrdStp 
		LDA	trddeeds0, X
		JSR	gamePerfTradeFocus

		LDA	trddeeds0, X
		JSR	rulesUnmortgageImmed
		
;		JSR	gamePerfTradeDeselect
		
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

		LDY	game + GAME::iTrdStp
		LDA	trddeeds0, Y
		STA	game + GAME::sAuctn

		INC	game + GAME::iTrdStp

		LDY	#TRADE::player
		LDA	trade0, Y
		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast

		JSR	rulesDoNextPlyr

		LDX	#$01
		JSR	gameStartAuction
		
		RTS

@stage2done:
		LDA	#$FF
		STA	game + GAME::fTrdStg
		
		RTS


;-------------------------------------------------------------------------------
gamePerfTradeFocus:
;-------------------------------------------------------------------------------
		STA	game + GAME::varA
		
		TXA
		PHA
		
		LDA	game + GAME::fTrdInt
		BEQ	@exit
		
		JSR	gamePerfTradeDeselect
		
		LDA	game + GAME::varA
		JSR	gameSelect

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
gamePerfTradeDeselect:
;-------------------------------------------------------------------------------
;		LDA	game + GAME::fTrdInt
;		BEQ	@exit
		
		LDA	game + GAME::sSelect
		CMP	#$FF
		BEQ	@exit
		
		JSR	gameDeselect
		
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


;-------------------------------------------------------------------------------
gamePerfTradeIntrpt:
;-------------------------------------------------------------------------------
		LDA	#$00
		STA	game + GAME::fTrdStg
		STA	game + GAME::iTrdStp 
		STA	game + GAME::fTrdPhs
;		STA	game + GAME::fTrdTyp
		
		LDA	#$01
		STA	game + GAME::fTrdInt		
		
		JSR	gamePerfTradeMoney
	
		JSR	gamePerfTradeStep

		LDA	game + GAME::fTrdStg
		CMP	#$FF
		BNE	@cont
	
		JSR	gamePerfTradeFullTerm
		RTS
		
@cont:
		LDA	#$60
		STA	game + GAME::iStpCnt
		LDA	#$00			
		STA	game + GAME::fStpSig
		
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
gamePerfTradeMPay:
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
gamePerfTradeChkAllMPay:
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

		JSR	gamePerfTradeMPay
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
gamePerfTradeFull:
;-------------------------------------------------------------------------------
		LDA	#$00
		STA	game + GAME::fTrdStg
		STA	game + GAME::iTrdStp 
		STA	game + GAME::fTrdPhs
;		STA	game + GAME::fTrdTyp
		STA	game + GAME::fTrdInt

		JSR	gamePerfTradeMoney
		
gamePerfTradeFullCont:

@loop:
		JSR	gamePerfTradeStep

		LDA	game + GAME::fTrdStg
		
		CMP	#$02
		BNE	@tstnext
	
		LDA	#$01
		STA	game + GAME::fTrdInt
		
;***FIXME:	What else do I need to do to go back to interactive?
;***TODO:	Go back to interactive stepping for auctions??
		
		RTS

@tstnext:
		CMP	#$FF
		BNE	@loop
	
gamePerfTradeFullTerm:	
		JSR	gamePerfTradeDeselect
		
		LDA	game + GAME::fTrdTyp
		BNE	@endelimin

;		Pop player and mode from trade 
		LDA	game + GAME::pTrdICP
		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast
		
		LDA	game + GAME::gMdTrdI
		STA	game + GAME::gMode

		LDA	#$00
		STA	game + GAME::fStpSig
		STA	game + GAME::kWai
		
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty

		LDX	game + GAME::pActive	
		LDA	plrLo, X		
		STA	$FB
		LDA	plrHi, X
		STA	$FC
		
		LDY	#PLAYER::colour
		LDA	($FB), Y
		TAX
		JSR	prmptClearOrRoll

		JSR	gamePerfTradeChkAllMPay	

		JSR	gameUpdateMenu

		RTS

@endelimin:
		LDA	game + GAME::pElimin
		
		STA	game + GAME::pActive
		LDA	#$FF
		STA	game + GAME::pLast
		
		LDA	game + GAME::gMdElim
		STA	game + GAME::gMode

		LDA	#$00
		STA	game + GAME::fStpSig
		STA	game + GAME::kWai
		
		JSR	rulesFocusOnActive
		JSR	gamePlayersDirty
		
		LDA	game + GAME::gMode
		CMP	#$03
		BEQ	@alreadympay
		
		JSR	gamePerfTradeChkAllMPay	
		
		LDA	game + GAME::gMode
		CMP	#$03
		BEQ	@complete
		
		JSR	rulesDoNextPlyr
		JMP	@complete
		
		
@alreadympay:
		LDA	game + GAME::pActive	;Check them all again
		STA	game + GAME::pMstPyI

		STA	game + GAME::pMPyLst

@complete:
		JSR	gameUpdateMenu
		
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
;		D, E < .A, .Y (O, P) -> SEC | CLC
;***???		IS THIS ROUTINE RETURING CARRY IN A STRANGE WAY?
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
		CLC
		RTS
		
@LESS:
		SEC
		RTS
		

;-------------------------------------------------------------------------------
gamePlayerHasFunds:
;***???		IS THIS ROUTINE RETURING CARRY IN A STRANGE WAY?
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
		
;		D, E < .A, .Y -> SEC | CLC
;		So, if money less than A, Y - set carry else clear
		JSR	gameAmountIsLess
		
		RTS
		

;-------------------------------------------------------------------------------
gamePlayerHasWealth:
;		ASSUMES INPUT VALUE IS POSITIVE 16BIT
;		ASSUMES -VE WEALTH IS FAIL (SEC)
;		ASSUMES 16BOVRFLW IS SUCCESS (CLC)
;
;***???		IS THIS ROUTINE RETURING CARRY IN A STRANGE WAY?
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
		SEC
		RTS
		
@success:
		CLC
		RTS

@test:
		LDA	game + GAME::varM
		LDY	game + GAME::varN
		
;		D, E < .A, .Y -> SEC | CLC
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
	.struct	DIALOG
		fKeys	.word
		fDraw	.word
		bDef	.byte
	.endstruct
	
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
dialogDrawDefDraw:
			.byte	$00
dialogDrawHandler:
			.word	dialogDefDraw
			
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

			.byte	$90, $05, $05		;Cash lbls
			.word		strText3TrdSel0
			
			.byte	$90, $05, $0A		;Rem wealth lbls
			.word		strText4TrdSel0	


;***TODO:		Move these into another display data
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

			.byte	$90, $1D, $05		;GO Free
			.word		strText0TrdSel0
			.byte	$90, $1D, $06
			.word		strText0TrdSel0

							;Ctrls
			.byte	$AE, $0C, $1C, $23, $46, $1C, $0C
			.word		strOptn0TrdSel0
			.byte	$AE, $0D, $1C, $20, $42, $1C, $0D
			.word		strOptn1TrdSel0
			.byte	$AE, $12, $1C, $22, $41, $1C, $12
			.word		strOptn3TrdSel0
			.byte	$AE, $13, $1C, $23, $44, $1C, $13
			.word		strOptn4TrdSel0


;***TODO:		Move these into other display data
			.byte	$2C, $05, $05, $06	;Cash lbl + $ 
			.byte	$2F, $05, $06, $06	
			
			.byte	$2C, $05, $0A, $06	;RWealth lbl + $
			.byte	$2F, $05, $0B, $06	
			
;***TODO:		Make colours configurable in order to indicate
;			which are available
			.byte	$81, $1C, $05		;GO Free
			.byte	$81, $1C, $06
			.byte	$2F, $1D, $05, $06	
			.byte	$2F, $1D, $06, $06
			
			
			.byte 	$00


dialogWindowTrdSel1:
			.byte	$AE, $10, $1C, $22, $53, $1C, $10
			.word		strOptn5TrdSel0
			
			.byte	$00


dialogWindowTrdSel2:
							;Select button
			.byte	$AE, $0F, $1C, $22, $53, $1C, $0F
			.word		strOptn2TrdSel0

;***TODO:		Move these into other display data
			.byte	$90, $05, $07		;Cash btn lbls
			.word		strText1TrdSel0
			.byte	$90, $05, $08
			.word		strText2TrdSel0
			.byte	$8F, $05, $07		;Cash btn clrs
			.byte	$8F, $05, $08
			
			.byte	$00
			

dialogAddrTrdSelCash=	$04F5
dialogAddrTrdSelRWealth=$05BD


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
		RTS
		
@initial:
		JSR	doDialogTrdSelSubRWlthI
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
doDialogTrdSelTstRfndFee:
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
		JSR	doDialogTrdSelRfndMVal	;Return lost equity
		PLA
		TAX

		RTS

@wanted:
		LDA	trdrepay2, X
		AND	#$80
		BNE	@rfndfee
		
		TXA				;Return gained equity
		PHA
		JSR	doDialogTrdSelChrgMVal
		PLA
		TAX
	
		RTS
		
@rfndfee:
		LDY	#DEED::mFee		;Return charged fee
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial
		
		JSR	doDialogTrdSelAddRWlthA
		RTS
		
@initial:
		JSR	doDialogTrdSelAddRWlthI
		RTS
		
		
;-------------------------------------------------------------------------------
doDialogTrdSelChrgMVal:
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
doDialogTrdSelRfndMVal:
;-------------------------------------------------------------------------------
;		Directly refund the mvalue on the remaining wealth for square in .X

		TXA

		JSR	gameGetCardPtrForSquare

doDialogTrdSelRfndMValAlt:
		LDY	#DEED::mValue
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial

		JSR	doDialogTrdSelAddRWlthA
		RTS
		
@initial:
		JSR	doDialogTrdSelAddRWlthI
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

;		LDA	trddeeds2, X		;***Don't do this because when
;		TAX				;repaying, effectively get mvalue
;		JSR	doDialogTrdSelRfndMVal	;back again in equity

		LDX	game + GAME::sTrdSel
		LDA	trdrepay2, X		;No
		AND	#$FE
		STA	trdrepay2, X

		LDA	dialogBakupTrdSelRep, X
		JMP	@proc
		
@togon:
;		LDA	trddeeds2, X		;***Don't do this as above
;		TAX
;		JSR	doDialogTrdSelChrgMVal
		
		LDX	game + GAME::sTrdSel
		LDA	trdrepay2, X		;Yes
		ORA	#$01	
		STA	trdrepay2, X
		
		LDA	#$01
		STA	game + GAME::varP
		
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
		BNE	@doBuzz
		
		LDA	#<SFXRENT2
		LDY	#>SFXRENT2
		LDX	#$07
		JSR	SNDBASE + 6

		RTS
		
@doBuzz:
		LDA	#<SFXBUZZ
		LDY	#>SFXBUZZ
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
		JSR	doDialogTrdSelTstRfndFee

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
		JSR	doDialogTrdSelRfndMVal
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
		JSR	doDialogTrdSelChrgMVal  ;Need to sub equity
		LDX	game + GAME::sTrdSel

;		JMP	@dotstwealth

@dotstwealth:
		LDA	menuTrade0RemWealth + 2
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


		JSR	doDialogTrdSelSetCash
		
		LDA	dialogTrdSelDoApprv
		BEQ	@initial
		
		JSR	doDialogTrdSelSetRWlthA
		RTS
		
@initial:
		JSR	doDialogTrdSelSetRWlthI
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
		
;		D, E (max) < .A, .Y (new) -> SEC | CLC
		JSR	gameAmountIsLess
		BCS	@max

		LDX	#TRADE::money
		LDA	game + GAME::varM
		STA	trade2, X
		INX
		LDA	game + GAME::varN
		STA	trade2, X

		LDA	dialogTrdSelDoRepay
		BEQ	@subRWealth
		
		CLC
		PLA
		ADC	menuTrade0RemWealth
		STA	menuTrade0RemWealth
		LDA	#$00
		ADC	menuTrade0RemWealth + 1
		STA	menuTrade0RemWealth + 1
		LDA	#$00
		ADC	menuTrade0RemWealth + 2
		STA	menuTrade0RemWealth + 2
		
		BMI	@sfxBell
		
		JMP	@sfxDing
		
@subRWealth:
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
		
		BMI	@sfxBell
		
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
		
		BMI	@min
		
		LDX	#TRADE::money
		LDA	game + GAME::varD
		STA	trade2, X
		INX
		LDA	game + GAME::varE
		STA	trade2, X

		LDA	dialogTrdSelDoRepay
		BEQ	@addRWealth
		
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
		
		JMP	@sfxDingBell
		
@addRWealth:
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
		
@sfxDingBell:
		LDA	menuTrade0RemWealth + 2
		BMI	@sfxBell
		
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
		BPL	@doRepay
		JMP	@keysBuzz

@initR:
		LDA	menuTrade0RemWealth + 2
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
		
		JMP	@contD

@initD:
		LDA	dialogTrdSelBakRWlthI	;Restore r wealth
		STA	menuTrade0RemWealth	
		LDA	dialogTrdSelBakRWlthI + 1	
		STA	menuTrade0RemWealth + 1
		LDA	dialogTrdSelBakRWlthI + 2	
		STA	menuTrade0RemWealth + 2

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
		RTS

@keysI:
		CMP	#'I'
		BNE	@keysO

		LDA	#10
		JSR	doDialogTrdSelAddCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		RTS

@keysO:
		CMP	#'O'
		BNE	@keysJ
		
		LDA	#1
		JSR	doDialogTrdSelAddCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		RTS
		
@keysJ:
		CMP	#'J'
		BNE	@keysK

		LDA	#100
		JSR	doDialogTrdSelSubCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		RTS
		
@keysK:
		CMP	#'K'
		BNE	@keysL
		
		LDA	#10
		JSR	doDialogTrdSelSubCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		RTS
		
@keysL:
		CMP	#'L'
		BNE	@keysExit

		LDA	#1
		JSR	doDialogTrdSelSubCash
		JSR	doDialogTrdSelSetCash
		JSR	doDialogTrdSelSetRWlthI
		
@keysExit:
		RTS

@tstrwealth:
		LDA	dialogTrdSelDoApprv
		BEQ	@initial
		
		JSR	doDialogTrdSelSetRWlthA
		LDA	menuTrade1RemWealth + 2
		BPL	@keysExit
		
		JMP	@keysBell
		
@initial:
		JSR	doDialogTrdSelSetRWlthI
		LDA	menuTrade0RemWealth + 2
		BPL	@keysExit
		
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
		
		JMP	@begin

@initial:
		LDA	menuTrade0RemWealth	;Back up the remaining wealth
		STA	dialogTrdSelBakRWlthI	;in case its dismissed
		LDA	menuTrade0RemWealth + 1
		STA	dialogTrdSelBakRWlthI + 1	
		LDA	menuTrade0RemWealth + 2
		STA	dialogTrdSelBakRWlthI + 2

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

		LDA	dialogTrdSelDoRepay
		BEQ	@skipRepay
		
		LDA	#<dialogWindowTrdSel1
		STA	$FD
		LDA	#>dialogWindowTrdSel1
		STA	$FE
		
		JSR	screenPerformList

@skipRepay:
		LDA	dialogTrdSelDoElimin
		BNE	@doRepay

		LDA	dialogTrdSelDoApprv
		BNE	@approv
		
@doRepay:
		LDA	#<dialogWindowTrdSel2
		STA	$FD
		LDA	#>dialogWindowTrdSel2
		STA	$FE
		
		JSR	screenPerformList

@approv:
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
		LDY	#STREET::rRent		;rent
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
		LDY	#STREET::rRent
		
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

rulesScore0:	
			.byte	1, 2, 5, 7, 15
rulesScore1:
			.byte	5, 15, 30, 40, 70
rulesScore2:
			.byte	10, 20, 50, 70, 100
rulesScore3:
			.byte	20, 35, 80, 110, 180


rulesGrp0:
			.byte	$03
			.byte	$04
			.byte	$00
			.word	$0000
			.word	rulesCrdCrnr0
			.word	rulesCrdCrnr1
			.word	rulesCrdCrnr2
			.word	rulesCrdCrnr3
rulesGrp1:
			.byte	$09
			.byte	$02
			.byte	50
			.word	rulesScore0
			.word	rulesCrdBrown0
			.word	rulesCrdBrown1
			.word	$0000
			.word	$0000
rulesGrp2:
			.byte	$0E
			.byte	$03
			.byte	50
			.word	rulesScore0
			.word	rulesCrdLBlue0
			.word	rulesCrdLBlue1
			.word	rulesCrdLBlue2
			.word	$0000
rulesGrp3:
			.byte	$04
			.byte	$03
			.byte	100
			.word	rulesScore1
			.word	rulesCrdPrple0
			.word	rulesCrdPrple1
			.word	rulesCrdPrple2
			.word	$0000
rulesGrp4:
			.byte	$08
			.byte	$03
			.byte	100
			.word	rulesScore1
			.word	rulesCrdOrnge0
			.word	rulesCrdOrnge1
			.word	rulesCrdOrnge2
			.word	$0000
rulesGrp5:
			.byte	$02
			.byte	$03
			.byte	150
			.word	rulesScore2
			.word	rulesCrdRed0
			.word	rulesCrdRed1
			.word	rulesCrdRed2
			.word	$0000
rulesGrp6:			
			.byte	$07
			.byte	$03
			.byte	150
			.word	rulesScore2
			.word	rulesCrdYellw0
			.word	rulesCrdYellw1
			.word	rulesCrdYellw2
			.word	$0000
rulesGrp7:
			.byte	$05
			.byte	$03
			.byte	200
			.word	rulesScore3
			.word	rulesCrdGreen0
			.word	rulesCrdGreen1
			.word	rulesCrdGreen2
			.word	$0000
rulesGrp8:
			.byte	$06
			.byte	$02
			.byte	200
			.word	rulesScore3
			.word	rulesCrdBlue0
			.word	rulesCrdBlue1
			.word	$0000
			.word	$0000
rulesGrp9:			
			.byte	$01
			.byte	$04
			.byte	$00
			.word 	$0000
			.word	rulesCrdStn0
			.word	rulesCrdStn1
			.word	rulesCrdStn2
			.word	rulesCrdStn3
rulesGrpA:			
			.byte	$01
			.byte	$02
			.byte	$00
			.word	$0000
			.word	rulesCrdUtil0
			.word	rulesCrdUtil1
			.word	$0000
			.word	$0000
rulesGrpB:
			.byte	$03
			.byte	$01
			.byte	$00
			.word	$0000
			.word	rulesCrdChest0
			.word	$0000
			.word	$0000
			.word	$0000
rulesGrpC:
			.byte	$03
			.byte	$01
			.byte	$00
			.word	$0000
			.word	rulesCrdChnce0
			.word	$0000
			.word	$0000
			.word	$0000
rulesGrpD:			
			.byte	$03
			.byte	$02
			.byte	$00
			.word	$0000
			.word	rulesCrdTax0
			.word	rulesCrdTax1
			.word	$0000
			.word	$0000
	
rulesGrpLo:		.byte	<rulesGrp0, <rulesGrp1, <rulesGrp2, <rulesGrp3
			.byte	<rulesGrp4, <rulesGrp5, <rulesGrp6, <rulesGrp7
			.byte	<rulesGrp8, <rulesGrp9, <rulesGrpA, <rulesGrpB
			.byte	<rulesGrpC, <rulesGrpD

rulesGrpHi:		.byte	>rulesGrp0, >rulesGrp1, >rulesGrp2, >rulesGrp3
			.byte	>rulesGrp4, >rulesGrp5, >rulesGrp6, >rulesGrp7
			.byte	>rulesGrp8, >rulesGrp9, >rulesGrpA, >rulesGrpB
			.byte	>rulesGrpC, >rulesGrpD


rulesCrdCrnr0:
			.word	strTitle0Crnr0
			.word	strDummyDummy0
rulesCrdCrnr1:
			.word	strTitle0Crnr1
			.word	strDummyDummy0
rulesCrdCrnr2:
			.word	strTitle0Crnr2
			.word	strDummyDummy0
rulesCrdCrnr3:
			.word	strTitle0Crnr3
			.word	strDummyDummy0
rulesCrdBrown0:
			.word	strTitle0Brown0
			.word	strDummyDummy0
			.word	60
			.word	30
			.word	3
			.word	2
			.word	10
			.word	30
			.word	90
			.word	160
			.word	250
rulesCrdBrown1:
			.word	strTitle0Brown1
			.word	strDummyDummy0
			.word	60
			.word	30
			.word	3
			.word	4
			.word	20
			.word	60
			.word	180
			.word	320
			.word	450
rulesCrdLBlue0:
			.word	strTitle0LBlue0
			.word	strTitle1LBlue0
			.word	100
			.word	50
			.word	5
			.word	6
			.word	30
			.word	90
			.word	270
			.word	400
			.word	550
rulesCrdLBlue1:
			.word	strTitle0LBlue1
			.word	strDummyDummy0
			.word	100
			.word	50
			.word	5
			.word	6
			.word	30
			.word	90
			.word	270
			.word	400
			.word	550
rulesCrdLBlue2:
			.word	strTitle0LBlue2
			.word	strDummyDummy0
			.word	120
			.word	60
			.word	6
			.word	8
			.word	40
			.word	100
			.word	300
			.word	450
			.word	600
rulesCrdPrple0:
			.word	strTitle0Prple0
			.word	strDummyDummy0
			.word	140
			.word	70
			.word	7
			.word	10
			.word	50
			.word	150
			.word	450
			.word	625
			.word	750
rulesCrdPrple1:
			.word	strTitle0Prple1
			.word	strDummyDummy0
			.word	140
			.word	70
			.word	7
			.word	10
			.word	50
			.word	150
			.word	450
			.word	625
			.word	750
rulesCrdPrple2:
			.word	strTitle0Prple2
			.word	strTitle1Prple2
			.word	160
			.word	80
			.word	8
			.word	12
			.word	60
			.word	180
			.word	500
			.word	700
			.word	900
rulesCrdOrnge0:
			.word	strTitle0Ornge0
			.word	strDummyDummy0
			.word	180
			.word	90
			.word	9
			.word	14
			.word	70
			.word	200
			.word	550
			.word	750
			.word	950
rulesCrdOrnge1:
			.word	strTitle0Ornge1
			.word	strDummyDummy0
			.word	180
			.word	90
			.word	9
			.word	14
			.word	70
			.word	200
			.word	550
			.word	750
			.word	950
rulesCrdOrnge2:
			.word	strTitle0Ornge2
			.word	strDummyDummy0
			.word	200
			.word	100
			.word	10
			.word	16
			.word	80
			.word	220
			.word	600
			.word	800
			.word	1000
rulesCrdRed0:
			.word	strTitle0Red0
			.word	strDummyDummy0
			.word	220
			.word	110
			.word	11
			.word	18
			.word	90
			.word	250
			.word	700
			.word	875
			.word	1050
rulesCrdRed1:
			.word	strTitle0Red1
			.word	strDummyDummy0
			.word	220
			.word	110
			.word	11
			.word	18
			.word	90
			.word	250
			.word	700
			.word	875
			.word	1050
rulesCrdRed2:
			.word	strTitle0Red2
			.word	strDummyDummy0
			.word	240
			.word	120
			.word	12
			.word	20
			.word	100
			.word	300
			.word	750
			.word	925
			.word	1100
rulesCrdYellw0:
			.word	strTitle0Yellw0
			.word	strDummyDummy0
			.word	260
			.word	130
			.word	13
			.word	22
			.word	110
			.word	330
			.word	800
			.word	975
			.word	1150
rulesCrdYellw1:
			.word	strTitle0Yellw1
			.word	strDummyDummy0
			.word	260
			.word	130
			.word	13
			.word	22
			.word	110
			.word	330
			.word	800
			.word	975
			.word	1150
rulesCrdYellw2:
			.word	strTitle0Yellw2
			.word	strDummyDummy0
			.word	280
			.word	140
			.word	14
			.word	24
			.word	120
			.word	360
			.word	850
			.word	1025
			.word	1200
rulesCrdGreen0:
			.word	strTitle0Green0
			.word	strDummyDummy0
			.word	300
			.word	150
			.word	15
			.word	26
			.word	130
			.word	390
			.word	900
			.word	1100
			.word	1275
rulesCrdGreen1:
			.word	strTitle0Green1
			.word	strDummyDummy0
			.word	300
			.word	150
			.word	15
			.word	26
			.word	130
			.word	390
			.word	900
			.word	1100
			.word	1275
rulesCrdGreen2:
			.word	strTitle0Green2
			.word	strDummyDummy0
			.word	320
			.word	160
			.word	16
			.word	28
			.word	150
			.word	450
			.word	1000
			.word	1200
			.word	1400
rulesCrdBlue0:
			.word	strTitle0Blue0
			.word	strDummyDummy0
			.word	350
			.word	175
			.word	18
			.word	35
			.word	175
			.word	500
			.word	1100
			.word	1300
			.word	1500
rulesCrdBlue1:
			.word	strTitle0Blue1
			.word	strDummyDummy0
			.word	400
			.word	200
			.word	20
			.word	50
			.word	200
			.word	600
			.word	1400
			.word	1700
			.word	2000
rulesCrdStn0:
			.word	strTitle0Stn0
			.word	strTitle1Stn0
			.word	200
			.word	100
			.word	10
			.word	25
rulesCrdStn1:
			.word	strTitle0Stn1
			.word	strDummyDummy0
			.word	200
			.word	100
			.word	10
			.word	25
rulesCrdStn2:
			.word	strTitle0Stn2
			.word	strTitle1Stn2
			.word	200
			.word	100
			.word	10
			.word	25
rulesCrdStn3:
			.word	strTitle0Stn3
			.word	strTitle1Stn3
			.word	200
			.word	100
			.word	10
			.word	25
rulesCrdUtil0:
			.word	strTitle0Util0
			.word	strDummyDummy0
			.word	150
			.word	75
			.word	8
rulesCrdUtil1:
			.word	strTitle0Util1
			.word	strDummyDummy0
			.word	150
			.word	75
			.word	8
rulesCrdChest0:
			.word	strHeaderCCCCard0
			.word	strDummyDummy0
rulesCrdChnce0:
			.word	strHeaderCCCCard1
			.word	strDummyDummy0
rulesCrdTax0:
			.word	strTitle0Tax0
			.word	strDummyDummy0
rulesCrdTax1:
			.word	strTitle0Tax1
			.word	strDummyDummy0



rulesSqr0:
			.byte	$00		;GO
			.byte	$00
			
			.byte	$01		;Brown 1
			.byte	$00
			
			.byte	$0B		;Chest	
			.byte	$00
			
			.byte	$01		;Brown 2
			.byte	$01

			.byte	$0D		;INC TAX 
			.byte	$00
			
			.byte	$09		;Station 1
			.byte	$00

			.byte	$02		;LBlue 1
			.byte	$00
			
			.byte	$0C		;Chance 
			.byte	$00

			.byte	$02		;LBlue 2
			.byte	$01

			.byte	$02		;LBlue 3
			.byte	$02
			
			.byte	$00		;Gaol
			.byte	$01
			
			.byte	$03		;Purple 1
			.byte	$00
			
			.byte	$0A		;Electric Co. 
			.byte	$00
			
			.byte	$03		;Purple 2
			.byte	$01
			
			.byte	$03		;Purple 3
			.byte	$02
			
			.byte	$09		;Station 2 
			.byte	$01
			
			.byte	$04		;Orange 1
			.byte	$00
			
			.byte	$0B		;Chest 
			.byte	$00
			
			.byte	$04		;Orange 2
			.byte	$01

			.byte	$04		;Orange 3
			.byte	$02
			
			.byte	$00		;Free Parking
			.byte	$02
			
			.byte	$05		;Red 1
			.byte	$00
			
			.byte	$0C		;Chance
			.byte	$00
			
			.byte	$05		;Red 2
			.byte	$01

			.byte	$05		;Red 3
			.byte	$02

			.byte	$09		;Station 3 
			.byte	$02
			
			.byte	$06		;Yellow 1
			.byte	$00
			
			.byte	$06		;Yellow 2
			.byte 	$01
			
			.byte	$0A		;Waterworks 
			.byte	$01

			.byte	$06		;Yellow 3
			.byte	$02
			
			.byte	$00		;GO GAOL
			.byte	$03
			
			.byte	$07		;Green 1
			.byte	$00
			
			.byte	$07		;Green 2
			.byte	$01
			
			.byte	$0B		;Chest 
			.byte	$00
			
			.byte	$07		;Green 3
			.byte	$02
			
			.byte	$09		;Station 4 
			.byte	$03
			
			.byte	$0C		;Chance 
			.byte	$00
			
			.byte	$08		;Blue 1
			.byte	$00	
			
			.byte	$0D		;Income TAX 
			.byte	$01
			
			.byte	$08		;Blue 2
			.byte	$01

rulesSqrStrsLo:
			.byte 	<rulesSqrStrsCrnr0, <rulesSqrStrsCrnr1
			.byte	<rulesSqrStrsCrnr2, <rulesSqrStrsCrnr3
			.byte   <rulesSqrStrsChest0, <rulesSqrStrsChance0
			.byte   <rulesSqrStrsTax0, <rulesSqrStrsTax1
rulesSqrStrsHi:
			.byte 	>rulesSqrStrsCrnr0, >rulesSqrStrsCrnr1
			.byte	>rulesSqrStrsCrnr2, >rulesSqrStrsCrnr3
			.byte   >rulesSqrStrsChest0, >rulesSqrStrsChance0
			.byte   >rulesSqrStrsTax0, >rulesSqrStrsTax1


rulesSqrStrsCrnr0:
			.word 	strText0Crnr0
			.word 	strText1Crnr0
			.word 	strText2Crnr0
			.word 	strText3Crnr0
			.word 	strText4Crnr0
rulesSqrStrsCrnr1:
			.word 	strText0Crnr1
			.word 	strText1Crnr1
			.word 	strText2Crnr1
			.word 	strText3Crnr1
			.word 	strText4Crnr1
rulesSqrStrsCrnr2:
			.word 	strText0Crnr2
			.word 	strText1Crnr2
			.word 	strText2Crnr2
			.word 	strText3Crnr2
			.word 	strText4Crnr2
rulesSqrStrsCrnr3:
			.word 	strText0Crnr3
			.word 	strText1Crnr3
			.word 	strText2Crnr3
			.word 	strText3Crnr3
			.word 	strText4Crnr3
rulesSqrStrsChest0:
			.word 	strText0Chest0
			.word 	strText1Chest0
			.word 	strText2Chest0
			.word 	strText3Chest0
			.word 	strText4Chest0
rulesSqrStrsChance0:
			.word 	strText0Chance0
			.word 	strText1Chance0
			.word 	strText2Chance0
			.word 	strText3Chance0
			.word 	strText4Chance0
rulesSqrStrsTax0:
			.word 	strText0Tax0
			.word 	strText1Tax0
			.word 	strText2Tax0
			.word 	strText3Tax0
			.word 	strText4Tax0
rulesSqrStrsTax1:
			.word 	strText0Tax1
			.word 	strText1Tax1
			.word 	strText2Tax1
			.word 	strText3Tax1
			.word 	strText4Tax1


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

rulesChestStrsLo:
			.byte	<rulesChestStrs0
			.byte	<rulesChestStrs1
			.byte	<rulesChestStrs2
			.byte	<rulesChestStrs3
			.byte	<rulesChestStrs4
			.byte	<rulesChestStrs5
			.byte	<rulesChestStrs6
			.byte	<rulesChestStrs7
			.byte	<rulesChestStrs8
			.byte	<rulesChestStrs9
			.byte	<rulesChestStrsA
			.byte	<rulesChestStrsB
			.byte	<rulesChestStrsC
			.byte	<rulesChestStrsD
			.byte	<rulesChestStrsE
			.byte	<rulesChestStrsF
rulesChestStrsHi:
			.byte	>rulesChestStrs0
			.byte	>rulesChestStrs1
			.byte	>rulesChestStrs2
			.byte	>rulesChestStrs3
			.byte	>rulesChestStrs4
			.byte	>rulesChestStrs5
			.byte	>rulesChestStrs6
			.byte	>rulesChestStrs7
			.byte	>rulesChestStrs8
			.byte	>rulesChestStrs9
			.byte	>rulesChestStrsA
			.byte	>rulesChestStrsB
			.byte	>rulesChestStrsC
			.byte	>rulesChestStrsD
			.byte	>rulesChestStrsE
			.byte	>rulesChestStrsF

rulesChestStrs0:
			.word	strDesc0Chest0
			.word	strDesc1Chest0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrs1:
			.word	strDesc0Chest1
			.word	strDesc1Chest1
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChestStrs2:
			.word	strDesc0Chest2
			.word	strDesc1Chest2
			.word 	strDummyDummy0
			.byte	$01
			.word	strText2CCCCard0
			.byte	$01
			.word	strText3CCCCard0
rulesChestStrs3:
			.word	strDesc0Chest3
			.word	strDesc1Chest3
			.word 	strDesc2Chest3
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrs4:
			.word	strDesc0Chest4
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrs5:
			.word	strDesc0Chest5
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrs6:
			.word	strDesc0Chest6
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText4CCCCard0
rulesChestStrs7:
			.word	strDesc0Chest7
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrs8:
			.word	strDesc0Chest8
			.word	strDesc1Chest8
			.word 	strDesc2Chest8
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChestStrs9:
			.word	strDesc0Chest9
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText1CCCCard0
rulesChestStrsA:
			.word	strDesc0ChestA
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrsB:
			.word	strDesc0ChestB
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText1CCCCard0
rulesChestStrsC:
			.word	strDesc0ChestC
			.word	strDesc1ChestC
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrsD:
			.word	strDesc0ChestD
			.word	strDesc1ChestD
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChestStrsE:
			.word	strDesc0ChestE
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText1CCCCard0
rulesChestStrsF:
			.word	strDesc0ChestF
			.word	strDesc1ChestF
			.word 	strDesc2ChestF
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0


rulesChest0:					;Bank error, $200
			.byte	$01
			.byte	200
rulesChest1:					;Advance Go
			.byte	$02	
			.byte	$00
rulesChest2:					;Street repairs (chest)
			.byte	$03
			.byte	$00
rulesChest3:					;Beauty contest, $10
			.byte	$01
			.byte	10
rulesChest4:					;sale stock, $50
			.byte	$01
			.byte	50
rulesChest5:					;inherit $100		
			.byte	$01
			.byte	100
rulesChest6:					;collect $10 from each player
			.byte	$04
			.byte	10
rulesChest7:					;consultancy $25
			.byte	$01
			.byte	25
rulesChest8:					;go gaol
			.byte	$05		
			.byte	$00
rulesChest9:					;pay $100 hospital
			.byte	$06		
			.byte	100
rulesChestA:					;income tax refund $20
			.byte	$01
			.byte	20
rulesChestB:					;pay school fees $50
			.byte	$06
			.byte	50
rulesChestC:					;life insurance $100
			.byte	$01
			.byte	100
rulesChestD:					;holiday fund $100
			.byte	$01
			.byte	100
rulesChestE:					;doctor's fee $50
			.byte	$06
			.byte	50
rulesChestF:					;get out of gaol free
			.byte	$07
			.byte	00


rulesChanceStrsLo:
			.byte	<rulesChanceStrs0
			.byte	<rulesChanceStrs1
			.byte	<rulesChanceStrs2
			.byte	<rulesChanceStrs3
			.byte	<rulesChanceStrs4
			.byte	<rulesChanceStrs5
			.byte	<rulesChanceStrs6
			.byte	<rulesChanceStrs7
			.byte	<rulesChanceStrs8
			.byte	<rulesChanceStrs9
			.byte	<rulesChanceStrsA
			.byte	<rulesChanceStrsB
			.byte	<rulesChanceStrsC
			.byte	<rulesChanceStrsD
			.byte	<rulesChanceStrsE
			.byte	<rulesChanceStrsF
rulesChanceStrsHi:
			.byte	>rulesChanceStrs0
			.byte	>rulesChanceStrs1
			.byte	>rulesChanceStrs2
			.byte	>rulesChanceStrs3
			.byte	>rulesChanceStrs4
			.byte	>rulesChanceStrs5
			.byte	>rulesChanceStrs6
			.byte	>rulesChanceStrs7
			.byte	>rulesChanceStrs8
			.byte	>rulesChanceStrs9
			.byte	>rulesChanceStrsA
			.byte	>rulesChanceStrsB
			.byte	>rulesChanceStrsC
			.byte	>rulesChanceStrsD
			.byte	>rulesChanceStrsE
			.byte	>rulesChanceStrsF

rulesChanceStrs0:
			.word	strDesc0Chance0
			.word	strDesc1Chance0
			.word 	strDesc2Chance0
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrs1:
			.word	strDesc0Chance1
			.word	strDesc1Chance1
			.word 	strDesc2Chance1
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrs2:
			.word	strDesc0Chance2
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText1CCCCard0
rulesChanceStrs3:
			.word	strDesc0Chance3
			.word	strDesc1Chance3
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrs4:
			.word	strDesc0Chance4
			.word	strDesc1Chance4
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText5CCCCard0
rulesChanceStrs5:
			.word	strDesc0Chance5
			.word	strDummyDummy0
			.word 	strDesc1Chance5
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrs6:
			.word	strDesc0Chance6
			.word	strDesc1Chance6
			.word 	strDesc2Chance6
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrs7:
			.word	strDesc0Chance7
			.word	strDesc1Chance7
			.word 	strDummyDummy0
			.byte	$01
			.word	strText2CCCCard0
			.byte	$01
			.word	strText3CCCCard0
rulesChanceStrs8:
			.word	strDesc0Chance8
			.word	strDummyDummy0
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChanceStrs9:
			.word	strDesc0Chance9
			.word	strDesc1Chance9
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrsA:
			.word	strDesc0ChanceA
			.word	strDesc1ChanceA
			.word 	strDesc2ChanceA
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrsB:
			.word	strDesc0ChanceB
			.word	strDesc1ChanceB
			.word 	strDesc2ChanceB
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrsC:
			.word	strDesc0ChanceC
			.word	strDummyDummy0
			.word 	strDesc1ChanceC
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrsD:
			.word	strDesc0ChanceD
			.word	strDesc1ChanceD
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$01
			.word	strText0CCCCard0
rulesChanceStrsE:
			.word	strDesc0ChanceE
			.word	strDesc1ChanceE
			.word 	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0
rulesChanceStrsF:
			.word	strDesc0ChanceF
			.word	strDummyDummy0
			.word 	strDesc1ChanceF
			.byte	$00
			.word	strDummyDummy0
			.byte	$00
			.word	strDummyDummy0


rulesChance0:					;advance to station, pay double
			.byte	$08
			.byte	$00
rulesChance1:					;advance to station, pay double
			.byte	$08
			.byte	$00
rulesChance2:					;speeding fine $15
			.byte	$06
			.byte	15
rulesChance3:					;go back 3 spaces
			.byte	$09
			.byte	3
rulesChance4:					;chairman pay each player $50
			.byte	$0A
			.byte	50
rulesChance5:					;advance pall mall
			.byte	$02		
			.byte	$0B
rulesChance6:					;get out of gaol free
			.byte	$07
			.byte	$01
rulesChance7:					;general repairs (chance)
			.byte	$03
			.byte	$01
rulesChance8:					;bank pays $50
			.byte	$01
			.byte	50
rulesChance9:					;Advance Go
			.byte	$02	
			.byte	$00
rulesChanceA:					;go gaol
			.byte	$05		
			.byte	$00
rulesChanceB:					;advance utility, pay 10 times
			.byte	$0B		
			.byte	$00
rulesChanceC:					;Advance Trafalgar
			.byte	$02	
			.byte	$18
rulesChanceD:					;building loan $150
			.byte	$01
			.byte	150
rulesChanceE:					;Advance Kings cross
			.byte	$02	
			.byte	$05
rulesChanceF:					;Advance Mayfair
			.byte	$02	
			.byte	$27

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

;-------------------------------------------------------------------------------
;rulesGenRnd0F
;-------------------------------------------------------------------------------
rulesGenRnd0F:
;***FIXME:  I can't quite recall how I came up with the algorythm used 
;	here.  It attempts to divide the random value (0-255) down to the range 
;	(0-15).  There seems to be an issue, however.  Values above 15 are being
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
		ADC	#STREET::r1Hse - 2
		TAY
		LDA	($FD), Y
		STA	game + GAME::varD
		INY
		LDA	($FD), Y
		STA	game + GAME::varE
		
		JMP	@rent
		
@unimprv:
		LDY	#STREET::rRent

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
		LDY	#STREET::rHotl

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
		CMP	#$01
		BEQ	@begin

		SEC
		LDY	#PLAYER::money
		LDA	($FB), Y
		SBC	game + GAME::varD
		INY	
		LDA	($FB), Y
		SBC	game + GAME::varE
		BMI	@skip

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
		RTS

@skip:
		PLA
		RTS


;-------------------------------------------------------------------------------
rulesDoCollateImprv:
;-------------------------------------------------------------------------------
		LDA	#$05
		STA	game + GAME::varA
		LDA	#$00
		STA	game + GAME::varB
		STA	game + GAME::varC
		STA	game + GAME::varD

		STY	game + GAME::varF
		STX	game + GAME::varE
		
		LDX	#$4E
@loop0:	
		LDA	rulesSqr0, X
		CMP	game + GAME::varE
		BNE	@next0

		LDY	#$80
		STY	$A3
		LDA	sqr00 + 1, X
		BIT	$A3
		BEQ	@tstprep
			
		INC	game + GAME::varD
		
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
		

;-------------------------------------------------------------------------------
rulesToggleMrtg:
;-------------------------------------------------------------------------------
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
		
;		So, if money less than A, Y - set carry else clear
		JSR	gamePlayerHasFunds
		BCC	@havefunds
		
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
		
		JSR	rulesAddCash

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
		LDX	#.SIZEOF(TRADE) - 1	
		LDA	#$00
@loop0:
		STA 	trade0, X
		STA 	trade1, X
		
		DEX
		BPL	@loop0
		
		LDX	#$27
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

		LDA	game + GAME::pElimin
		STA	game + GAME::pActive

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

		JSR	gamePerfTradeIntrpt
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

numConvInit:
		LDA 	#$FF 			; maximum frequency value
		STA 	sidVoc2FLo		; voice 3 frequency low byte
		STA 	sidVoc2FHi		; voice 3 frequency high byte
		LDA 	#$80 			; noise waveform, gate bit off
		STA 	sidVoc2Ctl		; voice 3 control register		

		LDX	#$00
		LDA	#$00
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



;==============================================================================
;FOR STRINGS.S
;==============================================================================

strHeaderTitles0:	;M O N O P O L Y
			.byte $0F, $8D, $A0, $8F, $A0, $8E, $A0, $8F
			.byte $A0, $90, $A0, $8F, $A0, $8C, $A0, $99
			
;***These should be strTextNTitles0, doh...

strDesc0Titles0:	;BY
			.byte $02, $82, $99			
strDesc1Titles0:	;DANIEL ENGLAND
			.byte $0E, $84, $81, $8E, $89, $85, $8C, $A0
			.byte $85, $8E, $87, $8C, $81, $8E, $84
strDesc2Titles0:	;FOR
			.byte $03, $86, $8F, $92
strDesc3Titles0:	;ECCLESTIAL
			.byte $0A, $85, $83, $83, $8C, $85, $93, $94
			.byte $89, $81, $8C
strDesc4Titles0:	;SOLUTIONS
			.byte $09, $93, $8F, $8C, $95, $94, $89, $8F
			.byte $8E, $93	
strDesc8Titles0:	;VERSION 0.01.99A
			.byte $10, $96, $85, $92, $93, $89, $8F, $8E
			.byte $A0, $B0, $AE, $B0, $B1, $AE, $B9, $B9
			.byte $81			
strDesc5Titles0:	;(C) 1935, 2016
			.byte $0E, $A8, $83, $A9, $A0, $B1, $B9, $B3
			.byte $B5, $AC, $A0, $B2, $B0, $B1, $B6			
strDesc6Titles0:	;HASBRO
			.byte $06, $88, $81, $93, $82, $92, $8F
strDesc7Titles0:	;PRESS ANY KEY
			.byte $0D, $90, $92, $85, $93, $93, $A0, $81
			.byte $8E, $99, $A0, $8B, $85, $99


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

strDummyDummy0:
			.byte	$00


strText0NumConv0:	;INTERNAL ERROR (OVERFLOW)
			.byte $19, $09, $0E, $14, $05, $12, $0E, $01
			.byte $0C, $20, $05, $12, $12, $0F, $12, $20
			.byte $28, $0F, $16, $05, $12, $06, $0C, $0F
			.byte $17, $29


strHeaderSetup0:	;PREGAME CONFIG
			.byte 	$0E, $90, $92, $85, $87, $81, $8D, $85
			.byte	$A0, $83, $8F, $8E, $86, $89, $87
strDescSetup0:		;SET PLAYER COUNT
			.byte 	$10, $93, $85, $94, $A0, $90, $8C, $81
			.byte 	$99, $85, $92, $A0, $83, $8F, $95, $8E
			.byte 	$94
strOptn0Setup0:		;2 - 2 PLAYERS
			.byte 	$0D, $B2, $A0, $AD, $A0, $B2, $A0, $90
			.byte 	$8C, $81, $99, $85, $92, $93
strOptn1Setup0:		;3 - 3 PLAYERS
			.byte 	$0D, $B3, $A0, $AD, $A0, $B3, $A0, $90
			.byte 	$8C, $81, $99, $85, $92, $93
strOptn2Setup0:		;4 - 4 PLAYERS
			.byte 	$0D, $B4, $A0, $AD, $A0, $B4, $A0, $90
			.byte 	$8C, $81, $99, $85, $92, $93
strOptn3Setup0:		;5 - 5 PLAYERS
			.byte 	$0D, $B5, $A0, $AD, $A0, $B5, $A0, $90
			.byte 	$8C, $81, $99, $85, $92, $93
strOptn4Setup0:		;6 - 6 PLAYERS
			.byte 	$0D, $B6, $A0, $AD, $A0, $B6, $A0, $90
			.byte 	$8C, $81, $99, $85, $92, $93


strDescSetup1:		;SET PLAYER COLOUR
			.byte $11, $93, $85, $94, $A0, $90, $8C, $81
			.byte $99, $85, $92, $A0, $83, $8F, $8C, $8F
			.byte $95, $92
strOptn0Setup1:		;0 - RED
			.byte 	$07, $B0, $A0, $AD, $A0, $92, $85, $84
strOptn1Setup1:		;1 - PURPLE
			.byte 	$0A, $B1, $A0, $AD, $A0, $90, $95, $92
			.byte 	$90, $8C, $85
strOptn2Setup1:		;2 - GREEN
			.byte 	$09, $B2, $A0, $AD, $A0, $87, $92, $85
			.byte 	$85, $8E
strOptn3Setup1:		;3 - BLUE
			.byte 	$08, $B3, $A0, $AD, $A0, $82, $8C, $95
			.byte 	$85
strOptn4Setup1:		;4 - YELLOW
			.byte 	$0A, $B4, $A0, $AD, $A0, $99, $85, $8C
			.byte 	$8C, $8F, $97
strOptn5Setup1:		;5 - ORANGE
			.byte 	$0A, $B5, $A0, $AD, $A0, $8F, $92, $81
			.byte 	$8E, $87, $85
strOptn6Setup1:		;6 - BROWN
			.byte 	$09, $B6, $A0, $AD, $A0, $82, $92, $8F
			.byte 	$97, $8E
strOptn7Setup1:		;7 - PINK
			.byte 	$08, $B7, $A0, $AD, $A0, $90, $89, $8E
			.byte 	$8B
strOptn8Setup1:		;8 - LIGHT GREEN
			.byte 	$0F, $B8, $A0, $AD, $A0, $8C, $89, $87
			.byte 	$88, $94, $A0, $87, $92, $85, $85, $8E
strOptn9Setup1:		;9 - LIGHT BLUE
			.byte 	$0E, $B9, $A0, $AD, $A0, $8C, $89, $87
			.byte 	$88, $94, $A0, $82, $8C, $95, $85


strDescSetup2:		;SET START FUNDS
			.byte $0F, $93, $85, $94, $A0, $93, $94, $81
			.byte $92, $94, $A0, $86, $95, $8E, $84, $93
			
strOptn0Setup2:		;0 - 1000 LOW
			.byte 	$0C, $B0, $A0, $AD, $A0, $B1, $B0, $B0
			.byte 	$B0, $A0, $8C, $8F, $97
strOptn1Setup2:		;1 - 1500 NORMAL
			.byte 	$0F, $B1, $A0, $AD, $A0, $B1, $B5, $B0
			.byte 	$B0, $A0, $8E, $8F, $92, $8D, $81, $8C
strOptn2Setup2:		;2 - 2000 HIGH
			.byte 	$0D, $B2, $A0, $AD, $A0, $B2, $B0, $B0
			.byte 	$B0, $A0, $88, $89, $87, $88


strHeaderSetup3:	;PLAY OPTIONS
			.byte $0C, $90, $8C, $81, $99, $A0, $8F, $90
			.byte $94, $89, $8F, $8E, $93

strDescSetup3:		;WAIT FOR PLAYER
			.byte $0F, $97, $81, $89, $94, $A0, $86, $8F
			.byte $92, $A0, $90, $8C, $81, $99, $85, $92
			
strText0Setup3:		;PROMPT FOR EACH
			.byte $0F, $90, $92, $8F, $8D, $90, $94, $A0
			.byte $86, $8F, $92, $A0, $85, $81, $83, $88
strText1Setup3:		;PLAYER?
			.byte $07, $90, $8C, $81, $99, $85, $92, $BF
			
strOptn0Setup3:		;Y - YES
			.byte $07, $99, $A0, $AD, $A0, $99, $85, $93
strOptn1Setup3:		;N - NO
			.byte $06, $8E, $A0, $AD, $A0, $8E, $8F
			
	
strDescSetup4:		;ROLL FOR FIRST
			.byte $0E, $92, $8F, $8C, $8C, $A0, $86, $8F
			.byte $92, $A0, $86, $89, $92, $93, $94
			
strOptn0Setup4:		;B - BEGIN GAME
			.byte $0E, $82, $A0, $AD, $A0, $82, $85, $87
			.byte $89, $8E, $A0, $87, $81, $8D, $85

		
strDescSetup5:		;JUMP TO NEXT
			.byte $0C, $8A, $95, $8D, $90, $A0, $94, $8F
			.byte $A0, $8E, $85, $98, $94
			
strText0Setup5:		;ALWAYS JUMP TO 
			.byte $0F, $81, $8C, $97, $81, $99, $93, $A0
			.byte $8A, $95, $8D, $90, $A0, $94, $8F, $A0
strText1Setup5:		;THE NEXT SQUARE?
			.byte $10, $94, $88, $85, $A0, $8E, $85, $98
			.byte $94, $A0, $93, $91, $95, $81, $92, $85
			.byte $BF
		
		
strDescSetup6:		;HOUSE RULES
			.byte $0B, $88, $8F, $95, $93, $85, $A0, $92
			.byte $95, $8C, $85, $93
		
strOptn0Setup6:		;F - FPRKING TAX
			.byte $0F, $86, $A0, $AD, $A0, $86, $90, $92
			.byte $8B, $89, $8E, $87, $A0, $94, $81, $98
strOptn1Setup6:		;G - LAND DBLS GO
			.byte $10, $87, $A0, $AD, $A0, $8C, $81, $8E
			.byte $84, $A0, $84, $82, $8C, $93, $A0, $87
			.byte $8F
strOptn2Setup6:		;M - LMTD MONEY
			.byte $0E, $8D, $A0, $AD, $A0, $8C, $8D, $94
			.byte $84, $A0, $8D, $8F, $8E, $85, $99
		
strText0Setup6:		;  NO
			.byte $04, $A0, $A0, $8E, $8F
strText1Setup6:		;  YES
			.byte $05, $A0, $A0, $99, $85, $93
			

strHeaderSetup7:	;INPUT CONFIG
			.byte $0C, $89, $8E, $90, $95, $94, $A0, $83
			.byte $8F, $8E, $86, $89, $87
strDescSetup7:		;SELECT DEVICES
			.byte $0E, $93, $85, $8C, $85, $83, $94, $A0
			.byte $84, $85, $96, $89, $83, $85, $93

strOptn0Setup7:		;K - KEYS ONLY
			.byte $0D, $8B, $A0, $AD, $A0, $8B, $85, $99
			.byte $93, $A0, $8F, $8E, $8C, $99
strOptn1Setup7:		;J - AND JOYSTICK
			.byte $10, $8A, $A0, $AD, $A0, $81, $8E, $84
			.byte $A0, $8A, $8F, $99, $93, $94, $89, $83
			.byte $8B
strOptn2Setup7:		;M - OR MOUSE
			.byte $0C, $8D, $A0, $AD, $A0, $8F, $92, $A0
			.byte $8D, $8F, $95, $93, $85
	
strDescSetup8:		;INPUT SENSE
			.byte $0B, $89, $8E, $90, $95, $94, $A0, $93
			.byte $85, $8E, $93, $85
			
strOptn0Setup8:		;L - LOW
			.byte $07, $8C, $A0, $AD, $A0, $8C, $8F, $97
strOptn1Setup8:		;M - MEDIUM
			.byte $0A, $8D, $A0, $AD, $A0, $8D, $85, $84
			.byte $89, $95, $8D
strOptn2Setup8:		;H - HIGH
			.byte $08, $88, $A0, $AD, $A0, $88, $89, $87
			.byte $88


strHeaderStart0:	;GAME STARTING
			.byte $0D, $87, $81, $8D, $85, $A0, $93, $94
			.byte $81, $92, $94, $89, $8E, $87
			
strText0Start0:		;PLAYER_1 GOES FIRST
			.byte $13, $90, $8C, $81, $99, $85, $92, $E4
			.byte $B1, $A0, $87, $8F, $85, $93, $A0, $86
			.byte $89, $92, $93, $94
			

strHeaderWaitFor0:	;PLAYER CHANGED
			.byte $0E, $90, $8C, $81, $99, $85, $92, $A0
			.byte $83, $88, $81, $8E, $87, $85, $84

strText0WaitFor0:	;PLAYER_1, IT IS NOW
			.byte $13, $90, $8C, $81, $99, $85, $92, $E4
			.byte $B1, $AC, $A0, $89, $94, $A0, $89, $93
			.byte $A0, $8E, $8F, $97
strText1WaitFor0:	;YOUR TURN!
			.byte $0A, $99, $8F, $95, $92, $A0, $94, $95
			.byte $92, $8E, $A1
			

strHeaderPlay0:		;PLAYER'S TURN
			.byte $0D, $90, $8C, $81, $99, $85, $92, $A7
			.byte $93, $A0, $94, $95, $92, $8E
			
strDescPlay0:		;DOUBLES
			.byte $07, $84, $8F, $95, $82, $8C, $85, $93

strOptn0Play0:		;R - ROLL
			.byte $08, $92, $A0, $AD, $A0, $92, $8F, $8C
			.byte $8C
strOptn1Play0:		;N - NEXT TURN
			.byte $0D, $8E, $A0, $AD, $A0, $8E, $85, $98
			.byte $94, $A0, $94, $95, $92, $8E
strOptn2Play0:		;M - MANAGE
			.byte $0A, $8D, $A0, $AD, $A0, $8D, $81, $8E
			.byte $81, $87, $85
strOptn3Play0:		;T - TRADE
			.byte $09, $94, $A0, $AD, $A0, $94, $92, $81
			.byte $84, $85
strOptn4Play0:		;V - OVERVIEW
			.byte $0C, $96, $A0, $AD, $A0, $8F, $96, $85
			.byte $92, $96, $89, $85, $97
strOptn5Play0:		;S - STATISTICS
			.byte $0E, $93, $A0, $AD, $A0, $93, $94, $81
			.byte $94, $89, $93, $94, $89, $83, $93			
strOptn6Play0:		;O - GAME OPTIONS
			.byte $10, $8F, $A0, $AD, $A0, $87, $81, $8D
			.byte $85, $A0, $8F, $90, $94, $89, $8F, $8E
			.byte $93
strOptn7Play0:		;C - INPUT CONFIG
			.byte $10, $83, $A0, $AD, $A0, $89, $8E, $90
			.byte $95, $94, $A0, $83, $8F, $8E, $86, $89
			.byte $87
strOptn8Play0:		;Q - QUIT
			.byte $08, $91, $A0, $AD, $A0, $91, $95, $89
			.byte $94
			
strOptn0Ftr0:		;F5-QUAD3
			.byte $08, $86, $B5, $AD, $91, $95, $81, $84
			.byte $B3
strOptn1Ftr0:		;F7-QUAD4
			.byte $08, $86, $B7, $AD, $91, $95, $81, $84
			.byte $B4
strOptn2Ftr0:		;F3-QUAD2
			.byte $08, $86, $B3, $AD, $91, $95, $81, $84
			.byte $B2
strOptn3Ftr0:		;F1-QUAD1
			.byte $08, $86, $B1, $AD, $91, $95, $81, $84
			.byte $B1		


strHeaderPlay1:		;UNOWNED DEED
			.byte $0C, $95, $8E, $8F, $97, $8E, $85, $84
			.byte $A0, $84, $85, $85, $84

strOptn0Play1:		;B - BUY
			.byte $07, $82, $A0, $AD, $A0, $82, $95, $99
strOptn1Play1:		;P - PASS
			.byte $08, $90, $A0, $AD, $A0, $90, $81, $93
			.byte $93
			
			
strHeaderAuctn0:	;DEED AUCTION
			.byte $0C, $84, $85, $85, $84, $A0, $81, $95
			.byte $83, $94, $89, $8F, $8E

strOptn0Auctn0:		;+           UIO
			.byte $0F, $AB, $A0, $A0, $A0, $A0, $A0, $A0
			.byte $A0, $A0, $A0, $A0, $A0, $95, $89, $8F

strOptn1Auctn0:		;AMT    $
			.byte $08, $81, $8D, $94, $A0, $A0, $A0, $A0
			.byte $A4

strOptn2Auctn0:		;-           JKL
			.byte $0F, $AD, $A0, $A0, $A0, $A0, $A0, $A0
			.byte $A0, $A0, $A0, $A0, $A0, $8A, $8B, $8C
	
strOptn3Auctn0:		;B - BID
			.byte $07, $82, $A0, $AD, $A0, $82, $89, $84
strOptn4Auctn0:		;P - PASS
			.byte $08, $90, $A0, $AD, $A0, $90, $81, $93
			.byte $93			
strOptn5Auctn0:		;F - FORFEIT
			.byte $0B, $86, $A0, $AD, $A0, $86, $8F, $92
			.byte $86, $85, $89, $94

			
strHeaderGaol0:		;GONE TO GAOL
			.byte $0C, $87, $8F, $8E, $85, $A0, $94, $8F
			.byte $A0, $87, $81, $8F, $8C

strDescGaol0:		;THREE DOUBLES
			.byte $0D, $94, $88, $92, $85, $85, $A0, $84
			.byte $8F, $95, $82, $8C, $85, $93
						
strHeaderGaol1:		;IN GAOL
			.byte $07, $89, $8E, $A0, $87, $81, $8F, $8C
strDescGaol1:		;PG 1/2
			.byte $06, $90, $87, $A0, $B1, $AF, $B2

strOptn0Gaol1:		;P - POST BAIL
			.byte $0D, $90, $A0, $AD, $A0, $90, $8F, $93
			.byte $94, $A0, $82, $81, $89, $8C
strOptn1Gaol1:		;F - GET OUT FREE
			.byte $10, $86, $A0, $AD, $A0, $87, $85, $94
			.byte $A0, $8F, $95, $94, $A0, $86, $92, $85
			.byte $85
strOptn2Gaol1:		;. - NEXT PAGE
			.byte $0D, $AE, $A0, $AD, $A0, $8E, $85, $98
			.byte $94, $A0, $90, $81, $87, $85	


strDescGaol2:		;PG 2/2
			.byte $06, $90, $87, $A0, $B2, $AF, $B2
			

strHeaderGaol3:		;MUST POST BAIL
			.byte $0E, $8D, $95, $93, $94, $A0, $90, $8F
			.byte $93, $94, $A0, $82, $81, $89, $8C


strHeaderMustPay0:	;PLAYER MUST PAY
			.byte $0F, $90, $8C, $81, $99, $85, $92, $A0
			.byte $8D, $95, $93, $94, $A0, $90, $81, $99
strDescMustPay0:	;IN DEBT
			.byte $07, $89, $8E, $A0, $84, $85, $82, $94
			
strOptn0MustPay0:	;C - CONTINUE
			.byte $0C, $83, $A0, $AD, $A0, $83, $8F, $8E
			.byte $94, $89, $8E, $95, $85


strHeaderMng0:		;MANAGE OPTIONS
			.byte $0E, $8D, $81, $8E, $81, $87, $85, $A0
			.byte $8F, $90, $94, $89, $8F, $8E, $93
			
strOptn0Mng0:		;F - MOVE FWRD
			.byte $0D, $86, $A0, $AD, $A0, $8D, $8F
			.byte $96, $85, $A0, $86, $97, $92, $84
strOptn1Mng0:		;B - MOVE BACK
			.byte $0D, $82, $A0, $AD, $A0, $8D, $8F
			.byte $96, $85, $A0, $82, $81, $83, $8B
strOptn2Mng0:		;M - UN/MORTGAGE
			.byte $0F, $8D, $A0, $AD, $A0, $95, $8E
			.byte $AF, $8D, $8F, $92, $94, $87, $81, $87
			.byte $85
strOptn3Mng0:		;C - CONSTRUCT
			.byte $0D, $83, $A0, $AD, $A0, $83, $8F
			.byte $8E, $93, $94, $92, $95, $83, $94
strOptn4Mng0:		;S - SELL
			.byte $08, $93, $A0, $AD, $A0, $93, $85
			.byte $8C, $8C
strOptn5Mng0:		;I - INFO
			.byte $08, $89, $A0, $AD, $A0, $89, $8E, $86
			.byte $8F
strOptn6Mng0:		;D - DONE
			.byte $08, $84, $A0, $AD, $A0, $84, $8F
			.byte $8E, $85
			

strHeaderTrade0:	;TRADE INITIATION
			.byte $10, $94, $92, $81, $84, $85, $A0, $89
			.byte $8E, $89, $94, $89, $81, $94, $89, $8F
			.byte $8E

strOptn0Trade0:		;P - PLAYER
			.byte $0A, $90, $A0, $AD, $A0, $90, $8C, $81
			.byte $99, $85, $92
strOptn1Trade0:		;W - WANTED
			.byte $0A, $97, $A0, $AD, $A0, $97, $81, $8E
			.byte $94, $85, $84
strOptn2Trade0:		;O - OFFERING
			.byte $0C, $8F, $A0, $AD, $A0, $8F, $86, $86
			.byte $85, $92, $89, $8E, $87
strOptn3Trade0:		;C - CONFIRM
			.byte $0B, $83, $A0, $AD, $A0, $83, $8F, $8E
			.byte $86, $89, $92, $8D
strOptn4Trade0:		;X - CANCEL
			.byte $0A, $98, $A0, $AD, $A0, $83, $81, $8E
			.byte $83, $85, $8C


strHeaderTrade1:	;TRADE APPROVAL
			.byte $0E, $94, $92, $81, $84, $85, $A0, $81
			.byte $90, $90, $92, $8F, $96, $81, $8C


strHeaderTrade2:	;INVALID TRADE!
			.byte $0E, $89, $8E, $96, $81, $8C, $89, $84
			.byte $A0, $94, $92, $81, $84, $85, $A1
			
strDescTrade2:		;CANNOT INITIATE
			.byte $0F, $83, $81, $8E, $8E, $8F, $94, $A0
			.byte $89, $8E, $89, $94, $89, $81, $94, $85
			
strText0Trade2:		;YOUR REMAINING WEALTH
			.byte $15, $99, $8F, $95, $92, $A0, $92, $85
			.byte $8D, $81, $89, $8E, $89, $8E, $87, $A0
			.byte $97, $85, $81, $8C, $94, $88
strText1Trade2:		;IS INVALID.
			.byte $0B, $89, $93, $A0, $89, $8E, $96, $81
			.byte $8C, $89, $84, $AE
			

strText0Trade3:		;THEIR REMAINING WEALTH
			.byte $16, $94, $88, $85, $89, $92, $A0, $92
			.byte $85, $8D, $81, $89, $8E, $89, $8E, $87
			.byte $A0, $97, $85, $81, $8C, $94, $88
strText1Trade3 	=	strText1Trade2


strDescTrade4:		;CANNOT APPROVE
			.byte $0E, $83, $81, $8E, $8E, $8F, $94, $A0
			.byte $81, $90, $90, $92, $8F, $96, $85
			

strHeaderTrade5:	;WARNING!
			.byte $08, $97, $81, $92, $8E, $89, $8E, $87
			.byte $A1

strDescTrade5:		;WILL NOT SHOW AGAIN
			.byte $13, $97, $89, $8C, $8C, $A0, $8E, $8F
			.byte $94, $A0, $93, $88, $8F, $97, $A0, $81
			.byte $87, $81, $89, $8E
		
strText0Trade5:		;THERE ARE MORTGAGED
			.byte $13, $94, $88, $85, $92, $85, $A0, $81
			.byte $92, $85, $A0, $8D, $8F, $92, $94, $87
			.byte $81, $87, $85, $84
strText1Trade5:		;DEEDS THAT YOU WILL
			.byte $13, $84, $85, $85, $84, $93, $A0, $94
			.byte $88, $81, $94, $A0, $99, $8F, $95, $A0
			.byte $97, $89, $8C, $8C
strText2Trade5:		;PAY FEES FOR.
			.byte $0D, $90, $81, $99, $A0, $86, $85, $85
			.byte $93, $A0, $86, $8F, $92, $AE
			
			
strHeaderTrade6:	;TRADE PROCESSING
			.byte $10, $94, $92, $81, $84, $85, $A0, $90
			.byte $92, $8F, $83, $85, $93, $93, $89, $8E
			.byte $87

strText0Trade6:		;YOU MAY COMPLETE
			.byte $10, $99, $8F, $95, $A0, $8D, $81, $99
			.byte $A0, $83, $8F, $8D, $90, $8C, $85, $94
			.byte $85
strText1Trade6:		;IMMEDIATELY.
			.byte $0C, $89, $8D, $8D, $85, $84, $89, $81
			.byte $94, $85, $8C, $99, $AE


strHeaderTrade7:	;TRADE PLAYER
			.byte $0C, $94, $92, $81, $84, $85, $A0, $90
			.byte $8C, $81, $99, $85, $92
			
strText0Trade7:		;TRADE INITIATED BY:
			.byte $13, $94, $92, $81, $84, $85, $A0, $89
			.byte $8E, $89, $94, $89, $81, $94, $85, $84
			.byte $A0, $82, $99, $BA


strHeaderPSel0:		;SELECT PLAYER
			.byte $0D, $93, $85, $8C, $85, $83, $94, $A0
			.byte $90, $8C, $81, $99, $85, $92


strOptn0PSel0:		;1 -
			.byte $03, $B1, $A0, $AD
strOptn1PSel0:		;2 -
			.byte $03, $B2, $A0, $AD
strOptn2PSel0:		;3 -
			.byte $03, $B3, $A0, $AD
strOptn3PSel0:		;4 -
			.byte $03, $B4, $A0, $AD
strOptn4PSel0:		;5 -
			.byte $03, $B5, $A0, $AD
strOptn5PSel0:		;6 -
			.byte $03, $B6, $A0, $AD

			
strOptn0TrdSel0:	;FORWARD
			.byte $07, $86, $0F, $12, $17, $01, $12, $04
strOptn1TrdSel0:	;BACK
			.byte $04, $82, $01, $03, $0B
strOptn2TrdSel0:	;SELECT
			.byte $06, $93, $05, $0C, $05, $03, $14
strOptn3TrdSel0:	;ACCEPT
			.byte $06, $81, $03, $03, $05, $10, $14
strOptn4TrdSel0:	;DISMISS
			.byte $07, $84, $09, $13, $0D, $09, $13, $13
strOptn5TrdSel0:	;REPAY
			.byte $05, $92, $05, $10, $01, $19

strText0TrdSel0:	;GOFREE
			.byte $06, $07, $0F, $06, $12, $05, $05
strText1TrdSel0:	;+  UIO
			.byte $06, $2B, $20, $20, $95, $89, $8F
strText2TrdSel0:	;-  JKL
			.byte $06, $2D, $20, $20, $8A, $8B, $8C
strText3TrdSel0:	;CASH
			.byte $04, $03, $01, $13, $08
strText4TrdSel0:	;R.WLTH
			.byte $06, $12, $2E, $17, $0C, $14, $08
strText5TrdSel0:	;INVLD!
			.byte $06, $09, $0E, $16, $0C, $04, $21
strText6TrdSel0:	;OVRFLW
			.byte $06, $0F, $16, $12, $06, $0C, $17
			

strHeaderJump0:		;PLAYER MOVING
			.byte $0D, $90, $8C, $81, $99, $85, $92, $A0
			.byte $8D, $8F, $96, $89, $8E, $87

strText0Jump0:		;YOU MAY JUMP TO
			.byte $0F, $99, $8F, $95, $A0, $8D, $81, $99
			.byte $A0, $8A, $95, $8D, $90, $A0, $94, $8F
strText1Jump0:		;THE DESTINATION
			.byte $0F, $94, $88, $85, $A0, $84, $85, $93
			.byte $94, $89, $8E, $81, $94, $89, $8F, $8E


strText0PStats0:	;MONEY......$
			.byte $0C, $8D, $8F, $8E, $85, $99, $AE, $AE
			.byte $AE, $AE, $AE, $AE, $A4
strText1PStats0:	;EQUITY.....$
			.byte $0C, $85, $91, $95, $89, $94, $99, $AE
			.byte $AE, $AE, $AE, $AE, $A4
strText2PStats0:	;GOFREE.....#
			.byte $0C, $87, $8F, $86, $92, $85, $85, $AE
			.byte $AE, $AE, $AE, $AE, $A3
strText3PStats0:	;HOUSES.....#
			.byte $0C, $88, $8F, $95, $93, $85, $93, $AE
			.byte $AE, $AE, $AE, $AE, $A3
strText4PStats0:	;HOTELS.....#
			.byte $0C, $88, $8F, $94, $85, $8C, $93, $AE
			.byte $AE, $AE, $AE, $AE, $A3
strText5PStats0:	;DEEDS......#
			.byte $0C, $84, $85, $85, $84, $93, $AE, $AE
			.byte $AE, $AE, $AE, $AE, $A3
strText6PStats0:	;STATIONS...#
			.byte $0C, $93, $94, $81, $94, $89, $8F, $8E
			.byte $93, $AE, $AE, $AE, $A3
strText7PStats0:	;UTILITIES..#
			.byte $0C, $95, $94, $89, $8C, $89, $94, $89
			.byte $85, $93, $AE, $AE, $A3
strText8PStats0:	;FULL GRPS..#
			.byte $0C, $86, $95, $8C, $8C, $A0, $87, $92
			.byte $90, $93, $AE, $AE, $A3
strText9PStats0:	;SCORE......*
			.byte $0C, $93, $83, $8F, $92, $85, $AE, $AE
			.byte $AE, $AE, $AE, $AE, $AA


strHeaderElimin0:	;PLAYER ELIMINATED
			.byte $11, $90, $8C, $81, $99, $85, $92, $A0
			.byte $85, $8C, $89, $8D, $89, $8E, $81, $94
			.byte $85, $84
			
strText0Elimin0:	;PLAYER_1 ELIMINATED!
			.byte $14, $90, $8C, $81, $99, $85, $92, $E4
			.byte $B1, $A0, $85, $8C, $89, $8D, $89, $8E
			.byte $81, $94, $85, $84, $A1
			
strHeaderElimin1:	;ERROR!
			.byte $06, $85, $92, $92, $8F, $92, $A1

strDescElimin1:		;CANNOT CONFIRM
			.byte $0E, $83, $81, $8E, $8E, $8F, $94, $A0
			.byte $83, $8F, $8E, $86, $89, $92, $8D
			
strText0Elimin1:	;YOU MUST REVIEW THE
			.byte $13, $99, $8F, $95, $A0, $8D, $95, $93
			.byte $94, $A0, $92, $85, $96, $89, $85, $97
			.byte $A0, $94, $88, $85
strText1Elimin1:	;ELIMINATION OFFER.
			.byte $12, $85, $8C, $89, $8D, $89, $8E, $81
			.byte $94, $89, $8F, $8E, $A0, $8F, $86, $86
			.byte $85, $92, $AE
			

strHeaderGameOver0:	;GAME OVER
			.byte $09, $87, $81, $8D, $85, $A0, $8F, $96
			.byte $85, $92

strText0GameOver0:	;PLAYER_1 WINS!
			.byte $0E, $90, $8C, $81, $99, $85, $92, $E4
			.byte $B1, $A0, $97, $89, $8E, $93, $A1


strHeaderQuit0:		;QUIT INITIATION
			.byte $0F, $91, $95, $89, $94, $A0, $89, $8E
			.byte $89, $94, $89, $81, $94, $89, $8F, $8E

strText0Quit0:		;DO YOU WISH TO
			.byte $0E, $84, $8F, $A0, $99, $8F, $95, $A0
			.byte $97, $89, $93, $88, $A0, $94, $8F

strText1Quit0:		;QUIT THE GAME?
			.byte $0E, $91, $95, $89, $94, $A0, $94, $88
			.byte $85, $A0, $87, $81, $8D, $85, $BF
			

strDescQuit1:		;CONFIRM REQUEST
			.byte $0F, $83, $8F, $8E, $86, $89, $92, $8D
			.byte $A0, $92, $85, $91, $95, $85, $93, $94
			
strText0Quit1:		;ARE YOU SURE?
			.byte $0D, $81, $92, $85, $A0, $99, $8F, $95
			.byte $A0, $93, $95, $92, $85, $BF
			

strHeaderQuit2:		;QUIT REQUESTED
			.byte $0E, $91, $95, $89, $94, $A0, $92, $85
			.byte $91, $95, $85, $93, $94, $85, $84


strHeaderCCCCard0:	;COMMUNITY CHEST
			.byte $0F, $83, $8F, $8D, $8D, $95, $8E, $89
			.byte $94, $99, $A0, $83, $88, $85, $93, $94
			
			
strText0CCCCard0:	;COLLECT
			.byte $07, $83, $8F, $8C, $8C, $85, $83, $94
strText1CCCCard0:	;PAY
			.byte $07, $A0, $A0, $A0, $A0, $90, $81, $99
strText2CCCCard0:	;HOUSES
			.byte $07, $A0, $88, $8F, $95, $93, $85, $93
strText3CCCCard0:	;HOTELS
			.byte $07, $A0, $88, $8F, $94, $85, $8C, $93
strText4CCCCard0:	;FROM ALL
			.byte $08, $86, $92, $8F, $8D, $A0, $81, $8C
			.byte $8C
strText5CCCCard0:	;PAY ALL
			.byte $07, $90, $81, $99, $A0, $81, $8C, $8C
			
			
strHeaderCCCCard1:	;CHANCE
			.byte $06, $83, $88, $81, $8E, $83, $85


;***dengland		These should actually be strTextNChestN... doh

strDesc0Chest0:		;BANK ERROR
			.byte $0A, $82, $81, $8E, $8B, $A0, $85, $92
			.byte $92, $8F, $92
strDesc1Chest0:		;IN YOUR FAVOUR.
			.byte $0F, $89, $8E, $A0, $99, $8F, $95, $92
			.byte $A0, $86, $81, $96, $8F, $95, $92, $AE
strDesc0Chest1:		;ADVANCE TO GO
			.byte $0D, $81, $84, $96, $81, $8E, $83, $85
			.byte $A0, $94, $8F, $A0, $87, $8F
strDesc1Chest1:		;(COLLECT $200)
			.byte $0E, $A8, $83, $8F, $8C, $8C, $85, $83
			.byte $94, $A0, $A4, $B2, $B0, $B0, $A9
strDesc0Chest2:		;YOU ARE ASSESSED
			.byte $10, $99, $8F, $95, $A0, $81, $92, $85
			.byte $A0, $81, $93, $93, $85, $93, $93, $85
			.byte $84
strDesc1Chest2:		;FOR STREET REPAIRS:
			.byte $13, $86, $8F, $92, $A0, $93, $94, $92
			.byte $85, $85, $94, $A0, $92, $85, $90, $81
			.byte $89, $92, $93, $BA
strDesc0Chest3:		;YOU HAVE WON SECOND
			.byte $13, $99, $8F, $95, $A0, $88, $81, $96
			.byte $85, $A0, $97, $8F, $8E, $A0, $93, $85
			.byte $83, $8F, $8E, $84
strDesc1Chest3:		;PRIZE IN A BEAUTY
			.byte $11, $90, $92, $89, $9A, $85, $A0, $89
			.byte $8E, $A0, $81, $A0, $82, $85, $81, $95
			.byte $94, $99
strDesc2Chest3:		;CONTEST.
			.byte $08, $83, $8F, $8E, $94, $85, $93, $94
			.byte $AE
strDesc0Chest4:		;SALE OF STOCK.
			.byte $0E, $93, $81, $8C, $85, $A0, $8F, $86
			.byte $A0, $93, $94, $8F, $83, $8B, $AE
strDesc0Chest5:		;INHERITANCE.
			.byte $0C, $89, $8E, $88, $85, $92, $89, $94
			.byte $81, $8E, $83, $85, $AE
strDesc0Chest6:		;ITS YOUR BIRTHDAY.
			.byte $12, $89, $94, $93, $A0, $99, $8F, $95
			.byte $92, $A0, $82, $89, $92, $94, $88, $84
			.byte $81, $99, $AE
strDesc0Chest7:		;CONSULTANCY FEE.
			.byte $10, $83, $8F, $8E, $93, $95, $8C, $94
			.byte $81, $8E, $83, $99, $A0, $86, $85, $85
			.byte $AE
strDesc0Chest8:		;GO DIRECTLY TO GAOL.
			.byte $14, $87, $8F, $A0, $84, $89, $92, $85
			.byte $83, $94, $8C, $99, $A0, $94, $8F, $A0
			.byte $87, $81, $8F, $8C, $AE
strDesc1Chest8:		;DO NOT PASS GO.
			.byte $0F, $84, $8F, $A0, $8E, $8F, $94, $A0
			.byte $90, $81, $93, $93, $A0, $87, $8F, $AE
strDesc2Chest8:		;DO NOT COLLECT $200.
			.byte $14, $84, $8F, $A0, $8E, $8F, $94, $A0
			.byte $83, $8F, $8C, $8C, $85, $83, $94, $A0
			.byte $A4, $B2, $B0, $B0, $AE
strDesc0Chest9:		;HOSPITAL FEES.
			.byte $0E, $88, $8F, $93, $90, $89, $94, $81
			.byte $8C, $A0, $86, $85, $85, $93, $AE
strDesc0ChestA:		;INCOME TAX REFUND.
			.byte $12, $89, $8E, $83, $8F, $8D, $85, $A0
			.byte $94, $81, $98, $A0, $92, $85, $86, $95
			.byte $8E, $84, $AE
strDesc0ChestB:		;SCHOOL FEES.
			.byte $0C, $93, $83, $88, $8F, $8F, $8C, $A0
			.byte $86, $85, $85, $93, $AE
strDesc0ChestC:		;LIFE INSURANCE MATURES.
			.byte $17, $8C, $89, $86, $85, $A0, $89, $8E
			.byte $93, $95, $92, $81, $8E, $83, $85, $A0
			.byte $8D, $81, $94, $95, $92, $85, $93, $AE
strDesc1ChestC	=	strDummyDummy0
strDesc0ChestD:		;HOLIDAY FUND MATURES.
			.byte $15, $88, $8F, $8C, $89, $84, $81, $99
			.byte $A0, $86, $95, $8E, $84, $A0, $8D, $81
			.byte $94, $95, $92, $85, $93, $AE
strDesc1ChestD	=	strDummyDummy0
strDesc0ChestE:		;DOCTORS'S FEES.
			.byte $0F, $84, $8F, $83, $94, $8F, $92, $93
			.byte $A7, $93, $A0, $86, $85, $85, $93, $AE
strDesc0ChestF:		;GET OUT OF GAOL FREE.
			.byte $15, $87, $85, $94, $A0, $8F, $95, $94
			.byte $A0, $8F, $86, $A0, $87, $81, $8F, $8C
			.byte $A0, $86, $92, $85, $85, $AE
strDesc1ChestF:		;MAY BE KEPT UNTIL
			.byte $11, $8D, $81, $99, $A0, $82, $85, $A0
			.byte $8B, $85, $90, $94, $A0, $95, $8E, $94
			.byte $89, $8C
strDesc2ChestF:		;NEEDED OR TRADED.
			.byte $11, $8E, $85, $85, $84, $85, $84, $A0
			.byte $8F, $92, $A0, $94, $92, $81, $84, $85
			.byte $84, $AE


;***dengland		These should actually be strTextNChanceN... doh

strDesc0Chance0:	;ADVANCE TO THE
			.byte $0E, $81, $84, $96, $81, $8E, $83, $85
			.byte $A0, $94, $8F, $A0, $94, $88, $85
strDesc1Chance0:	;NEAREST STATION.
			.byte $10, $8E, $85, $81, $92, $85, $93, $94
			.byte $A0, $93, $94, $81, $94, $89, $8F, $8E
			.byte $AE			
strDesc2Chance0:	;IF OWNED, PAY DOUBLE.
			.byte $15, $89, $86, $A0, $8F, $97, $8E, $85
			.byte $84, $AC, $A0, $90, $81, $99, $A0, $84
			.byte $8F, $95, $82, $8C, $85, $AE
strDesc0Chance1 =	strDesc0Chance0
strDesc1Chance1 =	strDesc1Chance0
strDesc2Chance1 =	strDesc2Chance0
strDesc0Chance2:	;SPEEDING FINE.
			.byte $0E, $93, $90, $85, $85, $84, $89, $8E
			.byte $87, $A0, $86, $89, $8E, $85, $AE
strDesc0Chance3:	;GO BACK THREE SPACES.
			.byte $15, $87, $8F, $A0, $82, $81, $83, $8B
			.byte $A0, $94, $88, $92, $85, $85, $A0, $93
			.byte $90, $81, $83, $85, $93, $AE
strDesc1Chance3	=	strDummyDummy0
strDesc0Chance4:	;YOU HAVE BEEN ELECTED
			.byte $15, $99, $8F, $95, $A0, $88, $81, $96
			.byte $85, $A0, $82, $85, $85, $8E, $A0, $85
			.byte $8C, $85, $83, $94, $85, $84
strDesc1Chance4:	;CHAIRMAN OF THE BOARD.
			.byte $16, $83, $88, $81, $89, $92, $8D, $81
			.byte $8E, $A0, $8F, $86, $A0, $94, $88, $85
			.byte $A0, $82, $8F, $81, $92, $84, $AE
strDesc0Chance5:	;ADVANCE TO:
			.byte $0B, $81, $84, $96, $81, $8E, $83, $85
			.byte $A0, $94, $8F, $BA
strDesc1Chance5:	;  PALL MALL.
			.byte $0C, $A0, $A0, $90, $81, $8C, $8C, $A0
			.byte $8D, $81, $8C, $8C, $AE
;strDesc2Chance5:	;YOU MAY COLLECT SALARY.
;			.byte $17, $99, $8F, $95, $A0, $8D, $81, $99
;			.byte $A0, $83, $8F, $8C, $8C, $85, $83, $94
;			.byte $A0, $93, $81, $8C, $81, $92, $99, $AE
strDesc0Chance6	=	strDesc0ChestF
strDesc1Chance6	=	strDesc1ChestF
strDesc2Chance6	=	strDesc2ChestF
strDesc0Chance7:	;MAKE GENERAL REPAIRS
			.byte $14, $8D, $81, $8B, $85, $A0, $87, $85
			.byte $8E, $85, $92, $81, $8C, $A0, $92, $85
			.byte $90, $81, $89, $92, $93
strDesc1Chance7:	;ON ALL YOUR PROPERTY:
			.byte $15, $8F, $8E, $A0, $81, $8C, $8C, $A0
			.byte $99, $8F, $95, $92, $A0, $90, $92, $8F
			.byte $90, $85, $92, $94, $99, $BA
strDesc0Chance8:	;BANK DIVIDEND.
			.byte $0E, $82, $81, $8E, $8B, $A0, $84, $89
			.byte $96, $89, $84, $85, $8E, $84, $AE
strDesc0Chance9	=	strDesc0Chest1
strDesc1Chance9 =	strDesc1Chest1
strDesc0ChanceA	=	strDesc0Chest8
strDesc1ChanceA	=	strDesc1Chest8
strDesc2ChanceA	=	strDesc2Chest8
strDesc0ChanceB	=	strDesc0Chance0
strDesc1ChanceB:	;NEAREST UTILITY.
			.byte $10, $8E, $85, $81, $92, $85, $93, $94
			.byte $A0, $95, $94, $89, $8C, $89, $94, $99
			.byte $AE
strDesc2ChanceB:	;IF OWNED, PAY 10* DICE.
			.byte $17, $89, $86, $A0, $8F, $97, $8E, $85
			.byte $84, $AC, $A0, $90, $81, $99, $A0, $B1
			.byte $B0, $AA, $A0, $84, $89, $83, $85, $AE
strDesc0ChanceC =	strDesc0Chance5
strDesc1ChanceC:	;  TRAFALGAR SQUARE.
			.byte $13, $A0, $A0, $94, $92, $81, $86, $81
			.byte $8C, $87, $81, $92, $A0, $93, $91, $95
			.byte $81, $92, $85, $AE
;strDesc2ChanceC = 	strDesc2Chance5
strDesc0ChanceD:	;YOUR BUILDING LOAN
			.byte $12, $99, $8F, $95, $92, $A0, $82, $95
			.byte $89, $8C, $84, $89, $8E, $87, $A0, $8C
			.byte $8F, $81, $8E
strDesc1ChanceD:	;MATURES.
			.byte $08, $8D, $81, $94, $95, $92, $85, $93
			.byte $AE
strDesc0ChanceE:	;TAKE A TRIP TO
			.byte $0E, $94, $81, $8B, $85, $A0, $81, $A0
			.byte $94, $92, $89, $90, $A0, $94, $8F
strDesc1ChanceE:	;KINGS CROSS STATION.
			.byte $14, $8B, $89, $8E, $87, $93, $A0, $83
			.byte $92, $8F, $93, $93, $A0, $93, $94, $81
			.byte $94, $89, $8F, $8E, $AE
;strDesc2ChanceE = 	strDesc2Chance5
strDesc0ChanceF =	strDesc0Chance5
strDesc1ChanceF:	;  MAYFAIR.
			.byte $0A, $A0, $A0, $8D, $81, $99, $86, $81
			.byte $89, $92, $AE


strTitle0Brown0:	;OLD KENT ROAD
			.byte $0D, $8F, $8C, $84, $A0, $8B, $85, $8E
			.byte $94, $A0, $92, $8F, $81, $84
strTitle0Brown1:	;WHITECHAPEL ROAD
			.byte $10, $97, $88, $89, $94, $85, $83, $88
			.byte $81, $90, $85, $8C, $A0, $92, $8F, $81
			.byte $84
strTitle0LBlue0:	;THE ANGEL,
			.byte $0A, $94, $88, $85, $A0, $81, $8E, $87
			.byte $85, $8C, $AC
strTitle1LBlue0:	;ISLINGTON
			.byte $09, $89, $93, $8C, $89, $8E, $87, $94
			.byte $8F, $8E
strTitle0LBlue1:	;EUSTON ROAD
			.byte $0B, $85, $95, $93, $94, $8F, $8E, $A0
			.byte $92, $8F, $81, $84
strTitle0LBlue2:	;PENTOVILLE ROAD
			.byte $0F, $90, $85, $8E, $94, $8F, $96, $89
			.byte $8C, $8C, $85, $A0, $92, $8F, $81, $84
strTitle0Prple0:	;PALL MALL
			.byte $09, $90, $81, $8C, $8C, $A0, $8D, $81
			.byte $8C, $8C
strTitle0Prple1:	;WHITEHALL
			.byte $09, $97, $88, $89, $94, $85, $88, $81
			.byte $8C, $8C
strTitle0Prple2:	;NORTHUMBERLAND
			.byte $0E, $8E, $8F, $92, $94, $88, $95, $8D
			.byte $82, $85, $92, $8C, $81, $8E, $84
strTitle1Prple2:	;AVENUE
			.byte $06, $81, $96, $85, $8E, $95, $85
strTitle0Ornge0:	;BOW STREET
			.byte $0A, $82, $8F, $97, $A0, $93, $94, $92
			.byte $85, $85, $94
strTitle0Ornge1:	;MARLBOROUGH STREET
			.byte $12, $8D, $81, $92, $8C, $82, $8F, $92
			.byte $8F, $95, $87, $88, $A0, $93, $94, $92
			.byte $85, $85, $94
strTitle0Ornge2:	;VINE STREET
			.byte $0B, $96, $89, $8E, $85, $A0, $93, $94
			.byte $92, $85, $85, $94
strTitle0Red0:		;STRAND
			.byte $06, $93, $94, $92, $81, $8E, $84
strTitle0Red1:		;FLEET STREET
			.byte $0C, $86, $8C, $85, $85, $94, $A0, $93
			.byte $94, $92, $85, $85, $94
strTitle0Red2:		;TRAFALGAR SQUARE
			.byte $10, $94, $92, $81, $86, $81, $8C, $87
			.byte $81, $92, $A0, $93, $91, $95, $81, $92
			.byte $85
strTitle0Yellw0:	;LEICESTER SQUARE
			.byte $10, $8C, $85, $89, $83, $85, $93, $94
			.byte $85, $92, $A0, $93, $91, $95, $81, $92
			.byte $85
strTitle0Yellw1:	;COVENTRY STREET
			.byte $0F, $83, $8F, $96, $85, $8E, $94, $92
			.byte $99, $A0, $93, $94, $92, $85, $85, $94
strTitle0Yellw2:	;PICCADILLY
			.byte $0A, $90, $89, $83, $83, $81, $84, $89
			.byte $8C, $8C, $99
strTitle0Green0:	;REGENT STREET
			.byte $0D, $92, $85, $87, $85, $8E, $94, $A0
			.byte $93, $94, $92, $85, $85, $94
strTitle0Green1:	;OXFORD STREET
			.byte $0D, $8F, $98, $86, $8F, $92, $84, $A0
			.byte $93, $94, $92, $85, $85, $94
strTitle0Green2:	;BOND STREET
			.byte $0B, $82, $8F, $8E, $84, $A0, $93, $94
			.byte $92, $85, $85, $94
strTitle0Blue0:		;PARK LANE
			.byte $09, $90, $81, $92, $8B, $A0, $8C, $81
			.byte $8E, $85
strTitle0Blue1:		;MAYFAIR
			.byte $07, $8D, $81, $99, $86, $81, $89, $92
strTitle0Stn0:		;KINGS CROSS
			.byte $0B, $8B, $89, $8E, $87, $93, $A0, $83
			.byte $92, $8F, $93, $93
strTitle1Stn0:		;STATION
			.byte $07, $93, $94, $81, $94, $89, $8F, $8E
strTitle0Stn1:		;MARYLEBONE STATION
			.byte $12, $8D, $81, $92, $99, $8C, $85, $82
			.byte $8F, $8E, $85, $A0, $93, $94, $81, $94
			.byte $89, $8F, $8E
strTitle0Stn2:		;FENCHURCH STREET
			.byte $10, $86, $85, $8E, $83, $88, $95, $92
			.byte $83, $88, $A0, $93, $94, $92, $85, $85
			.byte $94
strTitle1Stn2	= 	strTitle1Stn0
strTitle0Stn3:		;LIVERPOOL STREET
			.byte $10, $8C, $89, $96, $85, $92, $90, $8F
			.byte $8F, $8C, $A0, $93, $94, $92, $85, $85
			.byte $94
strTitle1Stn3 	=	strTitle1Stn0
strTitle0Util0:		;ELECTRIC COMPANY
			.byte $10, $85, $8C, $85, $83, $94, $92, $89
			.byte $83, $A0, $83, $8F, $8D, $90, $81, $8E
			.byte $99
strTitle0Util1:		;WATER WORKS
			.byte $0B, $97, $81, $94, $85, $92, $A0, $97
			.byte $8F, $92, $8B, $93
strTitle0Crnr0:		;GO
			.byte $02, $87, $8F
strTitle0Crnr1:		;GAOL/JUST VISITING
			.byte $12, $87, $81, $8F, $8C, $AF, $8A, $95
			.byte $93, $94, $A0, $96, $89, $93, $89, $94
			.byte $89, $8E, $87
strTitle0Crnr2:		;FREE PARKING
			.byte $0C, $86, $92, $85, $85, $A0, $90, $81
			.byte $92, $8B, $89, $8E, $87
strTitle0Crnr3:		;GO TO GAOL
			.byte $0A, $87, $8F, $A0, $94, $8F, $A0, $87
			.byte $81, $8F, $8C
strTitle0Tax0:		;INCOME TAX
			.byte $0A, $89, $8E, $83, $8F, $8D, $85, $A0
			.byte $94, $81, $98
strTitle0Tax1:		;LUXURY TAX
			.byte $0A, $8C, $95, $98, $95, $92, $99, $A0
			.byte $94, $81, $98
			
			
strText0Street0:	;RENT.........$
			.byte $0E, $92, $85, $8E, $94, $AE, $AE, $AE
			.byte $AE, $AE, $AE, $AE, $AE, $AE, $A4
strText1Street0:	;1 HOUSE......$
			.byte $0E, $B1, $A0, $88, $8F, $95, $93, $85
			.byte $AE, $AE, $AE, $AE, $AE, $AE, $A4
strText2Street0:	;2 HOUSES.....$
			.byte $0E, $B2, $A0, $88, $8F, $95, $93, $85
			.byte $93, $AE, $AE, $AE, $AE, $AE, $A4
strText3Street0:	;3 HOUSES.....$
			.byte $0E, $B3, $A0, $88, $8F, $95, $93, $85
			.byte $93, $AE, $AE, $AE, $AE, $AE, $A4
strText4Street0:	;4 HOUSES.....$
			.byte $0E, $B4, $A0, $88, $8F, $95, $93, $85
			.byte $93, $AE, $AE, $AE, $AE, $AE, $A4
strText5Street0:	;1 HOTEL......$
			.byte $0E, $B1, $A0, $88, $8F, $94, $85, $8C
			.byte $AE, $AE, $AE, $AE, $AE, $AE, $A4
strText6Street0:	;MARKET.......$
			.byte $0E, $8D, $81, $92, $8B, $85, $94, $AE
			.byte $AE, $AE, $AE, $AE, $AE, $AE, $A4
strText7Street0:	;MORTGAGE.....$
			.byte $0E, $8D, $8F, $92, $94, $87, $81, $87
			.byte $85, $AE, $AE, $AE, $AE, $AE, $A4
strText8Street0:	;REPAY........$
			.byte $0E, $92, $85, $90, $81, $99, $AE, $AE
			.byte $AE, $AE, $AE, $AE, $AE, $AE, $A4
strText9Street0:	;IMPRV. ......$
			.byte $0E, $89, $8D, $90, $92, $96, $AE, $A0
			.byte $AE, $AE, $AE, $AE, $AE, $AE, $A4
			
			
strText0Stn0:		;2 STATIONS...$
			.byte $0E, $B2, $A0, $93, $94, $81, $94, $89
			.byte $8F, $8E, $93, $AE, $AE, $AE, $A4
strText1Stn0:		;3 STATIONS...$
			.byte $0E, $B3, $A0, $93, $94, $81, $94, $89
			.byte $8F, $8E, $93, $AE, $AE, $AE, $A4
strText2Stn0:		;4 STATIONS...$
			.byte $0E, $B4, $A0, $93, $94, $81, $94, $89
			.byte $8F, $8E, $93, $AE, $AE, $AE, $A4
			
			
strText0Util0:		;ONE UTILITY OWNED:
			.byte $12, $8F, $8E, $85, $A0, $95, $94, $89
			.byte $8C, $89, $94, $99, $A0, $8F, $97, $8E
			.byte $85, $84, $BA
strText1Util0:		;RENT IS  4 * DICE
			.byte $11, $92, $85, $8E, $94, $A0, $89, $93
			.byte $A0, $A0, $B4, $A0, $AA, $A0, $84, $89
			.byte $83, $85
strText2Util0:		;TWO OWNED:
			.byte $0A, $94, $97, $8F, $A0, $8F, $97, $8E
			.byte $85, $84, $BA
strText3Util0:		;RENT IS 10 * DICE
			.byte $11, $92, $85, $8E, $94, $A0, $89, $93
			.byte $A0, $B1, $B0, $A0, $AA, $A0, $84, $89
			.byte $83, $85
			
			
strText0Crnr0:		;THE START POINT.
			.byte $10, $94, $88, $85, $A0, $93, $94, $81
			.byte $92, $94, $A0, $90, $8F, $89, $8E, $94
			.byte $AE
strText1Crnr0	=	strDummyDummy0
strText2Crnr0:		;ALSO, GAIN $200
			.byte $0F, $81, $8C, $93, $8F, $AC, $A0, $87
			.byte $81, $89, $8E, $A0, $A4, $B2, $B0, $B0
strText3Crnr0:		;SALARY WHEN LANDED
			.byte $12, $93, $81, $8C, $81, $92, $99, $A0
			.byte $97, $88, $85, $8E, $A0, $8C, $81, $8E
			.byte $84, $85, $84
strText4Crnr0:		;ON OR PASSING.
			.byte $0E, $8F, $8E, $A0, $8F, $92, $A0, $90
			.byte $81, $93, $93, $89, $8E, $87, $AE


strText0Crnr1:		;THE GAOL HOUSE.
			.byte $0F, $94, $88, $85, $A0, $87, $81, $8F
			.byte $8C, $A0, $88, $8F, $95, $93, $85, $AE
strText1Crnr1	=	strDummyDummy0
strText2Crnr1:		;YOU ARE EITHER
			.byte $0E, $99, $8F, $95, $A0, $81, $92, $85
			.byte $A0, $85, $89, $94, $88, $85, $92
strText3Crnr1:		;HELD HERE OR JUST
			.byte $11, $88, $85, $8C, $84, $A0, $88, $85
			.byte $92, $85, $A0, $8F, $92, $A0, $8A, $95
			.byte $93, $94
strText4Crnr1:		;VISITING.
			.byte $09, $96, $89, $93, $89, $94, $89, $8E
			.byte $87, $AE


strText0Crnr2:		;A SPACE FOR YOU TO
			.byte $12, $81, $A0, $93, $90, $81, $83, $85
			.byte $A0, $86, $8F, $92, $A0, $99, $8F, $95
			.byte $A0, $94, $8F
strText1Crnr2:		;WHILE AWAY YOUR
			.byte $0F, $97, $88, $89, $8C, $85, $A0, $81
			.byte $97, $81, $99, $A0, $99, $8F, $95, $92
strText2Crnr2:		;WORRIES.
			.byte $08, $97, $8F, $92, $92, $89, $85, $93
			.byte $AE
strText3Crnr2	=	strDummyDummy0
strText4Crnr2:		;ITS FREE!
			.byte $09, $89, $94, $93, $A0, $86, $92, $85
			.byte $85, $A1


strText0Crnr3:		;YOU WILL BE SENT
			.byte $10, $99, $8F, $95, $A0, $97, $89, $8C
			.byte $8C, $A0, $82, $85, $A0, $93, $85, $8E
			.byte $94
strText1Crnr3:		;DIRECTLY TO GAOL.
			.byte $11, $84, $89, $92, $85, $83, $94, $8C
			.byte $99, $A0, $94, $8F, $A0, $87, $81, $8F
			.byte $8C, $AE
strText2Crnr3:		;NO FURTHER ACTION
			.byte $11, $8E, $8F, $A0, $86, $95, $92, $94
			.byte $88, $85, $92, $A0, $81, $83, $94, $89
			.byte $8F, $8E
strText3Crnr3:		;POSSIBLE UNTIL
			.byte $0E, $90, $8F, $93, $93, $89, $82, $8C
			.byte $85, $A0, $95, $8E, $94, $89, $8C
strText4Crnr3:		;YOUR NEXT TURN.
			.byte $0F, $99, $8F, $95, $92, $A0, $8E, $85
			.byte $98, $94, $A0, $94, $95, $92, $8E, $AE


;***dengland		These should actually be strTextNChest10... doh

strText0Chest0:		;A TREASURE TROVE
			.byte $10, $81, $A0, $94, $92, $85, $81, $93
			.byte $95, $92, $85, $A0, $94, $92, $8F, $96
			.byte $85
strText1Chest0:		;BUT BEWARE!
			.byte $0B, $82, $95, $94, $A0, $82, $85, $97
			.byte $81, $92, $85, $A1
strText2Chest0	=	strDummyDummy0
strText3Chest0:		;A DECK OF 16 CARDS
			.byte $12, $81, $A0, $84, $85, $83, $8B, $A0
			.byte $8F, $86, $A0, $B1, $B6, $A0, $83, $81
			.byte $92, $84, $93
strText4Chest0:		;RANDOMLY SHUFFLED.
			.byte $12, $92, $81, $8E, $84, $8F, $8D, $8C
			.byte $99, $A0, $93, $88, $95, $86, $86, $8C
			.byte $85, $84, $AE


;***dengland		These should actually be strTextNChance10... doh

strText0Chance0:	;A MYSTERY BOX OF
			.byte $10, $81, $A0, $8D, $99, $93, $94, $85
			.byte $92, $99, $A0, $82, $8F, $98, $A0, $8F
			.byte $86
strText1Chance0:	;DIFFERENT EVENTS.
			.byte $11, $84, $89, $86, $86, $85, $92, $85
			.byte $8E, $94, $A0, $85, $96, $85, $8E, $94
			.byte $93, $AE
strText2Chance0	=	strDummyDummy0
strText3Chance0	=	strText3Chest0
strText4Chance0	=	strText4Chest0


strText0Tax0:		;YOU MUST PAY THE
			.byte $10, $99, $8F, $95, $A0, $8D, $95, $93
			.byte $94, $A0, $90, $81, $99, $A0, $94, $88
			.byte $85
strText1Tax0:		;BANK THE AMOUNT OF
			.byte $12, $82, $81, $8E, $8B, $A0, $94, $88
			.byte $85, $A0, $81, $8D, $8F, $95, $8E, $94
			.byte $A0, $8F, $86
strText2Tax0:		;$200.
			.byte $05, $A4, $B2, $B0, $B0, $AE
strText3Tax0	=	strDummyDummy0
strText4Tax0	=	strDummyDummy0


strText0Tax1	=	strText0Tax0
strText1Tax1	=	strText1Tax0
strText2Tax1:		;$100.
			.byte $05, $A4, $B1, $B0, $B0, $AE
strText3Tax1	=	strDummyDummy0
strText4Tax1	=	strDummyDummy0


;===============================================================================
;FOR INIT.S
;===============================================================================

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
		LDA	#<plrToken		;Set-up player token loc		
		STA	$FB
		LDA	#>plrToken
		STA	$FC
		
		LDA	#<spriteMemD		;Set-up sprite data loc
		STA	$FD
		LDA	#>spriteMemD
		STA	$FE
		
		LDY	#$00
@loop0:						;Copy player token data
		LDA	($FB), Y
		STA	($FD), Y
		
		INY
		CPY	#$18
		BNE	@loop0
		
@loop1:						;Clear sprite data
		STA	($FD), Y
		INY
		CPY	#$80
		BNE	@loop1

		LDA	#$C0			;Minimap token
		STA	spriteMemE		
		
		LDA	#<spriteMemF		;Minimap bg
		STA	$FD
		LDA	#>spriteMemF
		STA	$FE
		
		LDA	#<brdMiniMap		;Set-up minimap bkgnd		
		STA	$FB
		LDA	#>brdMiniMap
		STA	$FC
		
		LDY	#$00
		
@loop2:						;Copy data
		LDA	($FB), Y
		STA	($FD), Y
		
		INY
		CPY	#$3F
		BNE	@loop2

		LDA	#$00
		STA	($FD), Y
		
		LDA	#$0F
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
initFirstTime:
;-------------------------------------------------------------------------------
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

		JSR	numConvInit

		JSR	initNew

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
		
		JSR	statsClear
		JSR	prmptClear
		
		RTS


;-------------------------------------------------------------------------------
initScreen:
;-------------------------------------------------------------------------------
		LDA	#$FF
		STA	button0
		STA	ui + UI::fBtUpd0
		STA	ui + UI::fBtUpd1 
		
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


;-------------------------------------------------------------------------------
;init tables
;-------------------------------------------------------------------------------
msePointer:
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

plrToken:
			.byte	%00111100, $00, $00
			.byte 	%01111110, $00, $00
			.byte	%11111111, $00, $00
			.byte	%11111111, $00, $00
			.byte	%11111111, $00, $00
			.byte	%11111111, $00, $00
			.byte 	%01111110, $00, $00
			.byte	%00111100, $00, $00
			
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
			
plrDefName:
			.byte 	$08, $90, $8C, $81, $99, $85, $92, $E4, $B0

uiActnCache:
	.repeat		264, I
			.byte	$00
	.endrep

heap0:
			.byte	$00
			
	.assert         * < $CD00, error, "Program too large!"
