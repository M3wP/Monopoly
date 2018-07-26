;===============================================================================
;RULES.S
;===============================================================================

	.include	"strings.inc"
	.include 	"screen.inc"

	.code
	.org	SCREEN_END - 2
	
	.word	SCREEN_END


RULES_BEGIN	=	*

rulesGrpPriority:
		.byte	$0A, $01, $02, $03, $04, $05, $06, $07, $09, $08


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


rulesGrpSqrs0:
			.byte	$FF, $01, $06, $0B, $10, $15, $1A, $1F
			.byte	$25, $FF, $FF, $FF, $FF, $FF
rulesGrpSqrs1:
			.byte	$FF, $03, $08, $0D, $12, $17, $1B, $20
			.byte	$27, $FF, $FF, $FF, $FF, $FF
			
rulesGrpSqrs2:
			.byte	$FF, $FF, $09, $0E, $13, $18, $1D, $22
			.byte	$FF, $FF, $FF, $FF, $FF, $FF


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

			.byte	$0D		;Income TAX 
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
			
			.byte	$0D		;Luxury TAX 
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
			

rulesGrpPointsFull:
		.byte	$00, $02, $02, $03, $03, $04, $04, $06
		.byte	$06, $04, $02, $00, $00, $00
		
rulesGrpPointsPart:
		.byte	$00, $01, $01, $02, $02, $03, $03, $05
		.byte	$05, $03, $01, $00, $00, $00
		
	

	.assert	* < $FB00, error, "Rules data too large for current allocation!"