;===============================================================================
;SCREEN.S
;===============================================================================

	.include	"strings.inc"

	.code
	.org	STRINGS_END - 2
	
	.word	STRINGS_END


SCREEN_BEGIN	=	*

;-------------------------------------------------------------------------------
;screen constant data
;-------------------------------------------------------------------------------

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
			.byte	$58, $12, $00, $07
			.byte	$11, $13, $15, $15, $04
			.byte	$00
			
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


;	These are BQUADP structs
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

SCREEN_END	=	*