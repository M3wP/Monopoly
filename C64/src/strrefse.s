;===============================================================================
;STRREFS.S
;===============================================================================

	.include	"stringse.inc"

	.code
	.org	$0900 - 2
	
	.word	$0900
	
	.include	"strrefs.def"
	
	.assert	* < $0C00, error, "String translation references too large!"
