
	.code
	.org	$C000 - 2
	
	.word	$C000
	
langCount:
	.byte	$02
	
lang0:
	.byte 	'A'
	.byte	$00
	;  A - ENGLISH (USA)
	.byte 	$20, $20, $01, $20, $2D, $20, $05, $0E
	.byte 	$07, $0C, $09, $13, $08, $20, $28, $15
	.byte 	$13, $01, $29, $20
	
lang1:
	.byte	'B'
	.byte	'E'
	;  B - ENGLISH (UK)
	.byte 	$20, $20, $02, $20, $2D, $20, $05, $0E
	.byte 	$07, $0C, $09, $13, $08, $20, $28, $15
	.byte 	$0B, $29, $20, $20