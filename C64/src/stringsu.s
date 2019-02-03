;==============================================================================
;STRINGS.S
;==============================================================================

	.code
	.org	$E000

strDummyDummy0:
			.byte	$00

strHeaderTitles0:	;M O N O P O L Y
			.byte $0F, $8D, $A0, $8F, $A0, $8E, $A0, $8F
			.byte $A0, $90, $A0, $8F, $A0, $8C, $A0, $99
			
strText0Titles0:	;BY
			.byte $02, $82, $99			
strText1Titles0:	;DANIEL ENGLAND
			.byte $0E, $84, $81, $8E, $89, $85, $8C, $A0
			.byte $85, $8E, $87, $8C, $81, $8E, $84
strText2Titles0:	;FOR
			.byte $03, $86, $8F, $92
strText3Titles0:	;ECCLESTIAL
			.byte $0A, $85, $83, $83, $8C, $85, $93, $94
			.byte $89, $81, $8C
strText4Titles0:	;SOLUTIONS
			.byte $09, $93, $8F, $8C, $95, $94, $89, $8F
			.byte $8E, $93	
strText8Titles0:	;VERSION 0.02.74B
			.byte $10, $96, $85, $92, $93, $89, $8F, $8E
			.byte $A0, $B0, $AE, $B0, $B2, $AE, $B7, $B4
			.byte $82			
strText5Titles0:	;(C) 1935, 2016
			.byte $0E, $A8, $83, $A9, $A0, $B1, $B9, $B3
			.byte $B5, $AC, $A0, $B2, $B0, $B1, $B6			
strText6Titles0:	;HASBRO
			.byte $06, $88, $81, $93, $82, $92, $8F
strText7Titles0:	;PRESS ANY KEY
			.byte $0D, $90, $92, $85, $93, $93, $A0, $81
			.byte $8E, $99, $A0, $8B, $85, $99


strText0NumConv0:	;INTERNAL ERROR (OVERFLOW)
			.byte $19, $09, $0E, $14, $05, $12, $0E, $01
			.byte $0C, $20, $05, $12, $12, $0F, $12, $20
			.byte $28, $0F, $16, $05, $12, $06, $0C, $0F
			.byte $17, $29


strHeaderNull0:		;INFORMATION
			.byte $0B, $89, $8E, $86, $8F, $92, $8D, $81
			.byte $94, $89, $8F, $8E

strText0Null0:		;COMPUTER SAYS "NO".
			.byte $13, $83, $8F, $8D, $90, $95, $94, $85
			.byte $92, $A0, $93, $81, $99, $93, $A0, $A2
			.byte $8E, $8F, $A2, $AE


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


strDescSetup1:		;SET PLAYER COLOR
			.byte $10, $93, $85, $94, $A0, $90, $8C, $81
			.byte $99, $85, $92, $A0, $83, $8F, $8C, $8F
			.byte $92
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
			
strOptn0Setup2:		;1 - 1000 LOW
			.byte 	$0C, $B1, $A0, $AD, $A0, $B1, $B0, $B0
			.byte 	$B0, $A0, $8C, $8F, $97
strOptn1Setup2:		;0 - 1500 NORMAL
			.byte 	$0F, $B0, $A0, $AD, $A0, $B1, $B5, $B0
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
		
strText0Setup6:		;NO
			.byte $02, $8E, $8F
strText1Setup6:		;YES
			.byte $03, $99, $85, $93
			

strHeaderSetup7:	;INPUT CONFIG
			.byte $0C, $89, $8E, $90, $95, $94, $A0, $83
			.byte $8F, $8E, $86, $89, $87
strDescSetup7:		;SELECT DEVICES
			.byte $0E, $93, $85, $8C, $85, $83, $94, $A0
			.byte $84, $85, $96, $89, $83, $85, $93

strOptn0Setup7:		;K - KEYS ONLY
			.byte $0D, $8B, $A0, $AD, $A0, $8B, $85, $99
			.byte $93, $A0, $8F, $8E, $8C, $99
strOptn1Setup7:		;J - JOYSTICK
			.byte $0C, $8A, $A0, $AD, $A0, $8A, $8F, $99
			.byte $93, $94, $89, $83, $8B
strOptn2Setup7:		;M - MOUSE
			.byte $09, $8D, $A0, $AD, $A0, $8D, $8F, $95
			.byte $93, $85
	
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

strDescSetup9:		;SET CPU PLAYERS
			.byte $0F, $93, $85, $94, $A0, $83, $90, $95
			.byte $A0, $90, $8C, $81, $99, $85, $92, $93
			
strOptn0Setup9:		;0 - NO CPU
			.byte $0A, $B0, $A0, $AD, $A0, $8E, $8F, $A0
			.byte $83, $90, $95

strOptn1Setup9:		;1 - 1 PLAYER
			.byte $0C, $B1, $A0, $AD, $A0, $B1, $A0, $90
			.byte $8C, $81, $99, $85, $92


strHeaderStart0:	;GAME STARTING
			.byte $0D, $87, $81, $8D, $85, $A0, $93, $94
			.byte $81, $92, $94, $89, $8E, $87
			
strText0Start0:		;GOES FIRST
			.byte $0A, $87, $8F, $85, $93, $A0, $86, $89
			.byte $92, $93, $94
			

strHeaderWaitFor0:	;PLAYER CHANGED
			.byte $0E, $90, $8C, $81, $99, $85, $92, $A0
			.byte $83, $88, $81, $8E, $87, $85, $84

strText0WaitFor0:	;, IT IS NOW
			.byte $0B, $AC, $A0, $89, $94, $A0, $89, $93
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
strOptn9Play0:		;A - AUTOPAY
			.byte $0B, $81, $A0, $AD, $A0, $81, $95, $94
			.byte $8F, $90, $81, $99
			
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
strText3TrdSel0:	;MONEY
			.byte $05, $0D, $0F, $0E, $05, $19
strText4TrdSel0:	;R.WLTH
			.byte $06, $12, $2E, $17, $0C, $14, $08
strText5TrdSel0:	;INVLD!
			.byte $06, $09, $0E, $16, $0C, $04, $21
strText6TrdSel0:	;OVRFLW
			.byte $06, $0F, $16, $12, $06, $0C, $17
strText7TrdSel0:	;R.MNY
			.byte $05, $12, $2E, $0D, $0E, $19

strHeaderJump0:		;PLAYER MOVING
			.byte $0D, $90, $8C, $81, $99, $85, $92, $A0
			.byte $8D, $8F, $96, $89, $8E, $87

strText0Jump0:		;YOU MAY JUMP TO
			.byte $0F, $99, $8F, $95, $A0, $8D, $81, $99
			.byte $A0, $8A, $95, $8D, $90, $A0, $94, $8F
strText1Jump0:		;THE DESTINATION
			.byte $0F, $94, $88, $85, $A0, $84, $85, $93
			.byte $94, $89, $8E, $81, $94, $89, $8F, $8E


strHeaderJump1:		;GAME UPDATING
			.byte $0D, $87, $81, $8D, $85, $A0, $95, $90
			.byte $84, $81, $94, $89, $8E, $87

strText0Jump1:		;YOU MAY FINISH
			.byte $0E, $99, $8F, $95, $A0, $8D, $81, $99
			.byte $A0, $86, $89, $8E, $89, $93, $88
strText1Jump1:		;IMMEDIATELY.
			.byte $0C, $89, $8D, $8D, $85, $84, $89, $81
			.byte $94, $85, $8C, $99, $AE
			
			
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
			
strDescElimin0:		;DEFEATED BY
			.byte $0B, $84, $85, $86, $85, $81, $94, $85
			.byte $84, $A0, $82, $99
			
strText0Elimin0:	;ELIMINATED!
			.byte $0B, $85, $8C, $89, $8D, $89, $8E, $81
			.byte $94, $85, $84, $A1
			
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

strText0GameOver0:	;WINS!
			.byte $05, $97, $89, $8E, $93, $A1


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


strText0Chest0:		;BANK ERROR
			.byte $0A, $82, $81, $8E, $8B, $A0, $85, $92
			.byte $92, $8F, $92
strText1Chest0:		;IN YOUR FAVOUR.
			.byte $0F, $89, $8E, $A0, $99, $8F, $95, $92
			.byte $A0, $86, $81, $96, $8F, $95, $92, $AE
strText0Chest1:		;ADVANCE TO GO
			.byte $0D, $81, $84, $96, $81, $8E, $83, $85
			.byte $A0, $94, $8F, $A0, $87, $8F
strText1Chest1:		;(COLLECT $200)
			.byte $0E, $A8, $83, $8F, $8C, $8C, $85, $83
			.byte $94, $A0, $A4, $B2, $B0, $B0, $A9
strText0Chest2:		;YOU ARE ASSESSED
			.byte $10, $99, $8F, $95, $A0, $81, $92, $85
			.byte $A0, $81, $93, $93, $85, $93, $93, $85
			.byte $84
strText1Chest2:		;FOR STREET REPAIRS:
			.byte $13, $86, $8F, $92, $A0, $93, $94, $92
			.byte $85, $85, $94, $A0, $92, $85, $90, $81
			.byte $89, $92, $93, $BA
strText0Chest3:		;YOU HAVE WON SECOND
			.byte $13, $99, $8F, $95, $A0, $88, $81, $96
			.byte $85, $A0, $97, $8F, $8E, $A0, $93, $85
			.byte $83, $8F, $8E, $84
strText1Chest3:		;PRIZE IN A BEAUTY
			.byte $11, $90, $92, $89, $9A, $85, $A0, $89
			.byte $8E, $A0, $81, $A0, $82, $85, $81, $95
			.byte $94, $99
strText2Chest3:		;CONTEST.
			.byte $08, $83, $8F, $8E, $94, $85, $93, $94
			.byte $AE
strText0Chest4:		;SALE OF STOCK.
			.byte $0E, $93, $81, $8C, $85, $A0, $8F, $86
			.byte $A0, $93, $94, $8F, $83, $8B, $AE
strText0Chest5:		;INHERITANCE.
			.byte $0C, $89, $8E, $88, $85, $92, $89, $94
			.byte $81, $8E, $83, $85, $AE
strText0Chest6:		;ITS YOUR BIRTHDAY.
			.byte $12, $89, $94, $93, $A0, $99, $8F, $95
			.byte $92, $A0, $82, $89, $92, $94, $88, $84
			.byte $81, $99, $AE
strText0Chest7:		;CONSULTANCY FEE.
			.byte $10, $83, $8F, $8E, $93, $95, $8C, $94
			.byte $81, $8E, $83, $99, $A0, $86, $85, $85
			.byte $AE
strText0Chest8:		;GO DIRECTLY TO JAIL.
			.byte $14, $87, $8F, $A0, $84, $89, $92, $85
			.byte $83, $94, $8C, $99, $A0, $94, $8F, $A0
			.byte $8A, $81, $89, $8C, $AE
strText1Chest8:		;DO NOT PASS GO.
			.byte $0F, $84, $8F, $A0, $8E, $8F, $94, $A0
			.byte $90, $81, $93, $93, $A0, $87, $8F, $AE
strText2Chest8:		;DO NOT COLLECT $200.
			.byte $14, $84, $8F, $A0, $8E, $8F, $94, $A0
			.byte $83, $8F, $8C, $8C, $85, $83, $94, $A0
			.byte $A4, $B2, $B0, $B0, $AE
strText0Chest9:		;HOSPITAL FEES.
			.byte $0E, $88, $8F, $93, $90, $89, $94, $81
			.byte $8C, $A0, $86, $85, $85, $93, $AE
strText0ChestA:		;INCOME TAX REFUND.
			.byte $12, $89, $8E, $83, $8F, $8D, $85, $A0
			.byte $94, $81, $98, $A0, $92, $85, $86, $95
			.byte $8E, $84, $AE
strText0ChestB:		;SCHOOL FEES.
			.byte $0C, $93, $83, $88, $8F, $8F, $8C, $A0
			.byte $86, $85, $85, $93, $AE
strText0ChestC:		;LIFE INSURANCE MATURES.
			.byte $17, $8C, $89, $86, $85, $A0, $89, $8E
			.byte $93, $95, $92, $81, $8E, $83, $85, $A0
			.byte $8D, $81, $94, $95, $92, $85, $93, $AE
;strText1ChestC	=	strDummyDummy0
strText0ChestD:		;HOLIDAY FUND MATURES.
			.byte $15, $88, $8F, $8C, $89, $84, $81, $99
			.byte $A0, $86, $95, $8E, $84, $A0, $8D, $81
			.byte $94, $95, $92, $85, $93, $AE
;strText1ChestD	=	strDummyDummy0
strText0ChestE:		;DOCTORS'S FEES.
			.byte $0F, $84, $8F, $83, $94, $8F, $92, $93
			.byte $A7, $93, $A0, $86, $85, $85, $93, $AE
strText0ChestF:		;GET OUT OF JAIL FREE.
			.byte $15, $87, $85, $94, $A0, $8F, $95, $94
			.byte $A0, $8F, $86, $A0, $8A, $81, $89, $8C
			.byte $A0, $86, $92, $85, $85, $AE
strText1ChestF:		;MAY BE KEPT UNTIL
			.byte $11, $8D, $81, $99, $A0, $82, $85, $A0
			.byte $8B, $85, $90, $94, $A0, $95, $8E, $94
			.byte $89, $8C
strText2ChestF:		;NEEDED OR TRADED.
			.byte $11, $8E, $85, $85, $84, $85, $84, $A0
			.byte $8F, $92, $A0, $94, $92, $81, $84, $85
			.byte $84, $AE


strText0Chance0:	;ADVANCE TO THE
			.byte $0E, $81, $84, $96, $81, $8E, $83, $85
			.byte $A0, $94, $8F, $A0, $94, $88, $85
strText1Chance0:	;NEAREST STATION.
			.byte $10, $8E, $85, $81, $92, $85, $93, $94
			.byte $A0, $93, $94, $81, $94, $89, $8F, $8E
			.byte $AE			
strText2Chance0:	;IF OWNED, PAY DOUBLE.
			.byte $15, $89, $86, $A0, $8F, $97, $8E, $85
			.byte $84, $AC, $A0, $90, $81, $99, $A0, $84
			.byte $8F, $95, $82, $8C, $85, $AE
strText0Chance1 =	strText0Chance0
strText1Chance1 =	strText1Chance0
strText2Chance1 =	strText2Chance0
strText0Chance2:	;SPEEDING FINE.
			.byte $0E, $93, $90, $85, $85, $84, $89, $8E
			.byte $87, $A0, $86, $89, $8E, $85, $AE
strText0Chance3:	;GO BACK THREE SPACES.
			.byte $15, $87, $8F, $A0, $82, $81, $83, $8B
			.byte $A0, $94, $88, $92, $85, $85, $A0, $93
			.byte $90, $81, $83, $85, $93, $AE
strText0Chance4:	;YOU HAVE BEEN ELECTED
			.byte $15, $99, $8F, $95, $A0, $88, $81, $96
			.byte $85, $A0, $82, $85, $85, $8E, $A0, $85
			.byte $8C, $85, $83, $94, $85, $84
strText1Chance4:	;CHAIRMAN OF THE BOARD.
			.byte $16, $83, $88, $81, $89, $92, $8D, $81
			.byte $8E, $A0, $8F, $86, $A0, $94, $88, $85
			.byte $A0, $82, $8F, $81, $92, $84, $AE
strText0Chance5:	;ADVANCE TO:
			.byte $0B, $81, $84, $96, $81, $8E, $83, $85
			.byte $A0, $94, $8F, $BA
strText1Chance5:	;  ST CHARLES PLACE.
			.byte $13, $A0, $A0, $93, $94, $A0, $83, $88
			.byte $81, $92, $8C, $85, $93, $A0, $90, $8C
			.byte $81, $83, $85, $AE
;strText2Chance5:	;YOU MAY COLLECT SALARY.
;			.byte $17, $99, $8F, $95, $A0, $8D, $81, $99
;			.byte $A0, $83, $8F, $8C, $8C, $85, $83, $94
;			.byte $A0, $93, $81, $8C, $81, $92, $99, $AE
strText0Chance6	=	strText0ChestF
strText1Chance6	=	strText1ChestF
strText2Chance6	=	strText2ChestF
strText0Chance7:	;MAKE GENERAL REPAIRS
			.byte $14, $8D, $81, $8B, $85, $A0, $87, $85
			.byte $8E, $85, $92, $81, $8C, $A0, $92, $85
			.byte $90, $81, $89, $92, $93
strText1Chance7:	;ON ALL YOUR PROPERTY:
			.byte $15, $8F, $8E, $A0, $81, $8C, $8C, $A0
			.byte $99, $8F, $95, $92, $A0, $90, $92, $8F
			.byte $90, $85, $92, $94, $99, $BA
strText0Chance8:	;BANK DIVIDEND.
			.byte $0E, $82, $81, $8E, $8B, $A0, $84, $89
			.byte $96, $89, $84, $85, $8E, $84, $AE
strText0Chance9	=	strText0Chest1
strText1Chance9 =	strText1Chest1
strText0ChanceA	=	strText0Chest8
strText1ChanceA	=	strText1Chest8
strText2ChanceA	=	strText2Chest8
strText0ChanceB	=	strText0Chance0
strText1ChanceB:	;NEAREST UTILITY.
			.byte $10, $8E, $85, $81, $92, $85, $93, $94
			.byte $A0, $95, $94, $89, $8C, $89, $94, $99
			.byte $AE
strText2ChanceB:	;IF OWNED, PAY 10* DICE.
			.byte $17, $89, $86, $A0, $8F, $97, $8E, $85
			.byte $84, $AC, $A0, $90, $81, $99, $A0, $B1
			.byte $B0, $AA, $A0, $84, $89, $83, $85, $AE
strText0ChanceC =	strText0Chance5
strText1ChanceC:	;  ILLINOIS AVENUE.
			.byte $12, $A0, $A0, $89, $8C, $8C, $89, $8E
			.byte $8F, $89, $93, $A0, $81, $96, $85, $8E
			.byte $95, $85, $AE
strText0ChanceD:	;YOUR BUILDING LOAN
			.byte $12, $99, $8F, $95, $92, $A0, $82, $95
			.byte $89, $8C, $84, $89, $8E, $87, $A0, $8C
			.byte $8F, $81, $8E
strText1ChanceD:	;MATURES.
			.byte $08, $8D, $81, $94, $95, $92, $85, $93
			.byte $AE
strText0ChanceE:	;TAKE A TRIP TO
			.byte $0E, $94, $81, $8B, $85, $A0, $81, $A0
			.byte $94, $92, $89, $90, $A0, $94, $8F
strText1ChanceE:	;  READING RAILROAD.
			.byte $13, $A0, $A0, $92, $85, $81, $84, $89
			.byte $8E, $87, $A0, $92, $81, $89, $8C, $92
			.byte $8F, $81, $84, $AE
strText0ChanceF =	strText0Chance5
strText1ChanceF:	;  BOADWALK.
			.byte $0B, $A0, $A0, $82, $8F, $81, $84, $97
			.byte $81, $8C, $8B, $AE



strTitle0Brown0:	;MEDITERRANEAN AV
			.byte $10, $8D, $85, $84, $89, $94, $85, $92
			.byte $92, $81, $8E, $85, $81, $8E, $A0, $81
			.byte $96
strTitle0Brown1:	;BALTIC AV
			.byte $09, $82, $81, $8C, $94, $89, $83, $A0
			.byte $81, $96
strTitle0LBlue0:	;ORIENTAL AV
			.byte $0B, $8F, $92, $89, $85, $8E, $94, $81
			.byte $8C, $A0, $81, $96
strTitle1LBlue0:	;
			.byte $00
strTitle0LBlue1:	;VERMONT AV
			.byte $0A, $96, $85, $92, $8D, $8F, $8E, $94
			.byte $A0, $81, $96
strTitle0LBlue2:	;CONNECTICUT AV
			.byte $0E, $83, $8F, $8E, $8E, $85, $83, $94
			.byte $89, $83, $95, $94, $A0, $81, $96
strTitle0Prple0:	;ST CHARLES PL
			.byte $0D, $93, $94, $A0, $83, $88, $81, $92
			.byte $8C, $85, $93, $A0, $90, $8C
strTitle0Prple1:	;STATES AV
			.byte $09, $93, $94, $81, $94, $85, $93, $A0
			.byte $81, $96
strTitle0Prple2:	;VIRGINIA AV
			.byte $0B, $96, $89, $92, $87, $89, $8E, $89
			.byte $81, $A0, $81, $96
strTitle1Prple2:	;
			.byte $00
strTitle0Ornge0:	;ST JAMES PL
			.byte $0B, $93, $94, $A0, $8A, $81, $8D, $85
			.byte $93, $A0, $90, $8C
strTitle0Ornge1:	;TENNESSEE AV
			.byte $0C, $94, $85, $8E, $8E, $85, $93, $93
			.byte $85, $85, $A0, $81, $96
strTitle0Ornge2:	;NEW YORK AV
			.byte $0B, $8E, $85, $97, $A0, $99, $8F, $92
			.byte $8B, $A0, $81, $96
strTitle0Red0:		;KENTUCKY AV
			.byte $0B, $8B, $85, $8E, $94, $95, $83, $8B
			.byte $99, $A0, $81, $96
strTitle0Red1:		;INDIANA AV
			.byte $0A, $89, $8E, $84, $89, $81, $8E, $81
			.byte $A0, $81, $96
strTitle0Red2:		;ILLINOIS AV
			.byte $0B, $89, $8C, $8C, $89, $8E, $8F, $89
			.byte $93, $A0, $81, $96
strTitle0Yellw0:	;ATLANTIC AV
			.byte $0B, $81, $94, $8C, $81, $8E, $94, $89
			.byte $83, $A0, $81, $96
strTitle0Yellw1:	;VENTNOR AV
			.byte $0A, $96, $85, $8E, $94, $8E, $8F, $92
			.byte $A0, $81, $96
strTitle0Yellw2:	;MARVIN GARDENS
			.byte $0E, $8D, $81, $92, $96, $89, $8E, $A0
			.byte $87, $81, $92, $84, $85, $8E, $93
strTitle0Green0:	;PACIFIC AV
			.byte $0A, $90, $81, $83, $89, $86, $89, $83
			.byte $A0, $81, $96
strTitle0Green1:	;NORTH CAROLINA AV
			.byte $11, $8E, $8F, $92, $94, $88, $A0, $83
			.byte $81, $92, $8F, $8C, $89, $8E, $81, $A0
			.byte $81, $96
strTitle0Green2:	;PENNSYLVANIA AV
			.byte $0F, $90, $85, $8E, $8E, $93, $99, $8C
			.byte $96, $81, $8E, $89, $81, $A0, $81, $96
strTitle0Blue0:		;PARK PL
			.byte $07, $90, $81, $92, $8B, $A0, $90, $8C
strTitle0Blue1:		;BOADWALK
			.byte $08, $82, $8F, $81, $84, $97, $81, $8C
			.byte $8B
strTitle0Stn0:		;READING RAIL
			.byte $0C, $92, $85, $81, $84, $89, $8E, $87
			.byte $A0, $92, $81, $89, $8C
strTitle1Stn0:		;
			.byte $00
strTitle0Stn1:		;PENNSYLVANIA RAIL
			.byte $11, $90, $85, $8E, $8E, $93, $99, $8C
			.byte $96, $81, $8E, $89, $81, $A0, $92, $81
			.byte $89, $8C
strTitle0Stn2:		;B & O RAIL
			.byte $0A, $82, $A0, $A6, $A0, $8F, $A0, $92
			.byte $81, $89, $8C
strTitle1Stn2	= 	strTitle1Stn0
strTitle0Stn3:		;SHORT LINE RAIL
			.byte $0F, $93, $88, $8F, $92, $94, $A0, $8C
			.byte $89, $8E, $85, $A0, $92, $81, $89, $8C
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
strTitle0Crnr1:		;JAIL/JUST VISITING
			.byte $12, $8A, $81, $89, $8C, $AF, $8A, $95
			.byte $93, $94, $A0, $96, $89, $93, $89, $94
			.byte $89, $8E, $87
strTitle0Crnr2:		;FREE PARKING
			.byte $0C, $86, $92, $85, $85, $A0, $90, $81
			.byte $92, $8B, $89, $8E, $87
strTitle0Crnr3:		;GO TO JAIL
			.byte $0A, $87, $8F, $A0, $94, $8F, $A0, $8A
			.byte $81, $89, $8C
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


strText0Crnr1:		;THE JAIL HOUSE.
			.byte $0F, $94, $88, $85, $A0, $8A, $81, $89
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
strText1Crnr3:		;DIRECTLY TO JAIL.
			.byte $11, $84, $89, $92, $85, $83, $94, $8C
			.byte $99, $A0, $94, $8F, $A0, $8A, $81, $89
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


strText0Chest10:	;A TREASURE TROVE
			.byte $10, $81, $A0, $94, $92, $85, $81, $93
			.byte $95, $92, $85, $A0, $94, $92, $8F, $96
			.byte $85
strText1Chest10:	;BUT BEWARE!
			.byte $0B, $82, $95, $94, $A0, $82, $85, $97
			.byte $81, $92, $85, $A1
strText2Chest10	=	strDummyDummy0
strText3Chest10:	;A DECK OF 16 CARDS
			.byte $12, $81, $A0, $84, $85, $83, $8B, $A0
			.byte $8F, $86, $A0, $B1, $B6, $A0, $83, $81
			.byte $92, $84, $93
strText4Chest10:	;RANDOMLY SHUFFLED.
			.byte $12, $92, $81, $8E, $84, $8F, $8D, $8C
			.byte $99, $A0, $93, $88, $95, $86, $86, $8C
			.byte $85, $84, $AE


strText0Chance10:	;A MYSTERY BOX OF
			.byte $10, $81, $A0, $8D, $99, $93, $94, $85
			.byte $92, $99, $A0, $82, $8F, $98, $A0, $8F
			.byte $86
strText1Chance10:	;DIFFERENT EVENTS.
			.byte $11, $84, $89, $86, $86, $85, $92, $85
			.byte $8E, $94, $A0, $85, $96, $85, $8E, $94
			.byte $93, $AE
strText2Chance10 = 	strDummyDummy0
strText3Chance10 = 	strText3Chest10
strText4Chance10 = 	strText4Chest10


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


tokPrmptRolled:		;.ROLLED 
			.byte 	$07, $51, $12, $0F, $0C, $0C, $05, $04
tokPrmptRent:		;.RENT    $
			.byte 	$0A, $51, $12, $05, $0E, $14, $20, $20
			.byte	$20, $20, $24
tokPrmptBought:		;.BOUGHT  $
			.byte	$0A, $51, $02, $0F, $15, $07, $08, $14
			.byte	$20, $20, $24
tokPrmptTax:		;.TAX     $
			.byte 	$0A, $51, $14, $01, $18, $20, $20, $20
			.byte	$20, $20, $24
tokPrmptGaol:		;.GONE TO JAIL
			.byte 	$0D, $51, $87, $8F, $8E, $85, $A0, $94
			.byte 	$8F, $A0, $8A, $81, $89, $8C
tokPrmptManage:		;.HSES+00 HTLS+00
			.byte 	$10, $51, $08, $13, $05, $13, $2B, $30
			.byte 	$30, $20, $08, $14, $0C, $13, $2B, $30
			.byte	$30
tokPrmptMustSell:	;.MUST SELL IMPRV
			.byte 	$10, $51, $0D, $15, $13, $14, $20, $13
			.byte 	$05, $0C, $0C, $20, $09, $0D, $10, $12
			.byte	$16
tokPrmptSalary:		;.SALARY  $
			.byte 	$0A, $51, $13, $01, $0C, $01, $12, $19
			.byte	$20, $20, $24
tokPrmptFParking:	;.FPARKING$
			.byte 	$0A, $51, $06, $10, $01, $12, $0B, $09
			.byte	$0E, $07, $24
tokPrmptMortgage:	;.MORTGAGE$
			.byte 	$0A, $51, $0D, $0F, $12, $14, $07, $01
			.byte	$07, $05, $24
tokPrmptRepay:		;.REPAY   $
			.byte 	$0A, $51, $12, $05, $10, $01, $19, $20
			.byte	$20, $20, $24
tokPrmptSold:		;.SOLD    $
			.byte 	$0A, $51, $13, $0F, $0C, $04, $20, $20
			.byte	$20, $20, $24
tokPrmptShuffle:	;.SHUFFLING...
			.byte 	$10, $51, $13, $08, $15, $06, $06, $0C 
			.byte	$09, $0E, $07, $2E, $2E, $2E, $20, $20
			.byte	$20
tokPrmptChest:		;.CHEST   $
			.byte 	$0A, $51, $03, $08, $05, $13, $14, $20
			.byte	$20, $20, $24
tokPrmptChance:		;.CHANCE  $
			.byte 	$0A, $51, $03, $08, $01, $0E, $03, $05
			.byte	$20, $20, $24
tokPrmptForSale:	;.FOR SALE$
			.byte 	$0A, $51, $06, $0F, $12, $20, $13, $01
			.byte	$0C, $05, $24
tokPrmptPostBail:	;.BAIL    $
			.byte 	$0A, $51, $02, $01, $09, $0C, $20, $20
			.byte	$20, $20, $24
tokPrmptFee:		;.FEE     $
			.byte 	$0A, $51, $06, $05, $05, $20, $20, $20
			.byte	$20, $20, $24
tokPrmptForfeit:	;.FORFEIT
			.byte 	$08, $51, $06, $0F, $12, $06, $05, $09
			.byte	$14
tokPrmptPass:		;.PASS
			.byte 	$05, $51, $10, $01, $13, $13
tokPrmptBid:		;.BID     $
			.byte 	$0A, $51, $02, $09, $04, $20, $20, $20
			.byte	$20, $20, $24
tokPrmptInTrade:	;.BEING TRADED!
			.byte 	$0E, $51, $02, $05, $09, $0E, $07, $20
			.byte	$14, $12, $01, $04, $05, $04, $21
tokPrmptTrading:	;.TRADING...
			.byte 	$0B, $51, $14, $12, $01, $04, $09, $0E
			.byte	$07, $2E, $2E, $2E
tokPrmptTrdApprv:	;.APPROVED!
			.byte 	$0A, $51, $01, $10, $10, $12, $0F, $16
			.byte	$05, $04, $21
tokPrmptTrdDecln:	;.DECLINED!
			.byte 	$0A, $51, $04, $05, $03, $0C, $09, $0E
			.byte	$05, $04, $21
tokPrmptThinking:	;.THINKING...
			.byte 	$10, $51, $14, $08, $09, $0E, $0B, $09
			.byte	$0E, $07, $2E, $2E, $2E, $20, $20, $20
			.byte	$20
tokPrmptConstruct:	;.CONSTRCT$
			.byte 	$0A, $51, $03, $0F, $0E, $13, $14, $12
			.byte 	$03, $14, $24
tokPrmptAuction:	;.AUCTION
			.byte 	$08, $51, $01, $15, $03, $14, $09, $0F
			.byte	$0E
tokPrmptAcquired:	;.ACQUIRED
			.byte 	$09, $51, $01, $03, $11, $15, $09, $12
			.byte 	$05, $04
			
STRINGS_END	=	*
	.assert	* < $F400, error, "Strings data too large for current allocation!"