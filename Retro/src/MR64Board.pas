unit MR64Board;

interface

uses
	C64Video;

type
	PMR64Board = ^TMR64Board;
	TMR64Board = array[0..639, 0..639] of TC64RGBA;

	TMR64BoardPlayerDet = record
		colour: Byte;
		active: Boolean;
		square: Byte;
		status: Byte;
	end;

	TMR64BoardDirty = (mbdNone, mbdAll, mbdSelect);
	TMR64SquareType = (mstStreet, mstStation, mstUtility, mstAction);

	TMR64BoardRegs = record
		address: Word;
		dirty: TMR64BoardDirty;
		players: array[0..5] of TMR64BoardPlayerDet;
	end;

	TMR64BoardSqr = packed record
		own,
		imprv: Byte;
	end;

	TMR64BoardSqrs = array[0..39] of TMR64BoardSqr;

	TMR64BoardPos = (mbpBottom, mbpLeft, mbpTop, mbpRight);
	TMR64BoardSqDet = packed record
		x,
		y,
		w,
		h: Integer;
		st: TMR64SquareType;
		ps: TMR64BoardPos;
	end;

	TMR64BoardGlyph = array of array of TC64RGBA;

	TMR64BoardIIO = class
	public
		procedure Write(const AAddress: Word; const AValue: Byte);
		function  Read(const AAddress: Word): Byte;
	end;


const
//Bottom Own Y:	306
//Bottom Imprv Y: 266
//
//Left Own X: 6
//Left Imprv X: 46
//
//Top Own Y: 0
//Top Imprv Y: 40
//
//Right Own X: 312
//Right Imprv X: 272

	ARR_VAL_BOARD_OWN: array[TMR64BoardPos] of Integer =
		(612, 12, 0, 624);

	ARR_VAL_BOARD_IMP: array[TMR64BoardPos] of Integer =
		(532, 92, 80, 544);

	ARR_REC_BOARD_DET: array[0..39] of TMR64BoardSqDet = (
//0:
			(x:	544; y:	532; w:	76; h:	76; st:	mstAction; ps:	mbpBottom),
//1:
			(x:	496; y:	552; w:	44; h:	56; st: mstStreet; ps:	mbpBottom),
//2:
			(x:	448; y:	532; w:	44; h:	76; st: mstAction; ps:	mbpBottom),
//3:
			(x:	400; y:	552; w:	44; h:	56; st: mstStreet; ps:	mbpBottom),
//4:
			(x:	352; y:	532; w:	44; h:	76; st: mstAction; ps:	mbpBottom),
//5:
			(x:	304; y:	532; w:	44; h:	76; st: mstStation; ps:	mbpBottom),
//6:
			(x:	256; y:	552; w:	44; h:	56; st: mstStreet; ps:	mbpBottom),
//7:
			(x:	208; y:	532; w:	44; h:	76; st: mstAction; ps:	mbpBottom),
//8:
			(x:	160; y:	552; w:	44; h:	56; st: mstStreet; ps:	mbpBottom),
//9:
			(x:	112; y:	552; w:	44; h:	56; st: mstStreet; ps:	mbpBottom),
//10:
			(x:	32; y:	532; w:	76; h:	76; st: mstAction; ps:	mbpLeft),


//11:
			(x:	32; y:	484; w:	56; h:	44; st: mstStreet; ps:	mbpLeft),
//12:
			(x:	32; y:	436; w:	76; h:	44; st: mstUtility; ps:	mbpLeft),
//13:
			(x:	32; y:	388; w:	56; h:	44; st: mstStreet; ps:	mbpLeft),
//14:
			(x:	32; y:	340; w:	56; h:	44; st: mstStreet; ps:	mbpLeft),
//15:
			(x:	32; y:	292; w:	76; h:	44; st: mstStation; ps:	mbpLeft),
//16:
			(x:	32; y:	244; w:	56; h:	44; st: mstStreet; ps:	mbpLeft),
//17:
			(x:	32; y:	196; w:	76; h:	44; st: mstAction; ps:	mbpLeft),
//18:
			(x:	32; y:	148; w:	56; h:	44; st: mstStreet; ps:	mbpLeft),
//19:
			(x:	32; y:	100; w:	56; h:	44; st: mstStreet; ps:	mbpLeft),
//20:
			(x:	32; y:	20; w:	76; h:	76; st: mstAction; ps:	mbpTop),



//21:
			(x:	112; y:	20; w:	44; h:	56; st: mstStreet; ps:	mbpTop),
//22:
			(x:	160; y:	20; w:	44; h:	76; st: mstAction; ps:	mbpTop),
//23:
			(x:	208; y:	20; w:	44; h:	56; st: mstStreet; ps:	mbpTop),
//24:
			(x:	256; y:	20; w:	44; h:	56; st: mstStreet; ps:	mbpTop),
//25:
			(x:	304; y:	20; w:	44; h:	76; st: mstStation; ps:	mbpTop),
//26:
			(x:	352; y:	20; w:	44; h:	56; st: mstStreet; ps:	mbpTop),
//27:
			(x:	400; y:	20; w:	44; h:	56; st: mstStreet; ps:	mbpTop),
//28:
			(x:	448; y:	20; w:	44; h:	76; st: mstUtility; ps:	mbpTop),
//29:
			(x:	496; y:	20; w:	44; h:	56; st: mstStreet; ps:	mbpTop),


//30:
			(x:	544; y:	20; w:	76; h:	76; st: mstAction; ps:	mbpRight),
//31:
			(x:	564; y:	100; w:	56; h:	44; st: mstStreet; ps:	mbpRight),
//32:
			(x:	564; y:	148; w:	56; h:	44; st: mstStreet; ps:	mbpRight),
//33:
			(x:	544; y:	196; w:	76; h:	44; st: mstAction; ps:	mbpRight),
//34:
			(x:	564; y:	244; w:	56; h:	44; st: mstStreet; ps:	mbpRight),
//35:
			(x:	544; y:	292; w:	76; h:	44; st: mstStation; ps:	mbpRight),
//36:
			(x:	544; y:	340; w:	76; h:	44; st: mstAction; ps:	mbpRight),
//37:
			(x:	564; y:	388; w:	56; h:	44; st: mstStreet; ps:	mbpRight),
//38:
			(x:	544; y:	436; w:	76; h:	44; st: mstAction; ps:	mbpRight),
//39:
			(x:	564; y:	484; w:	56; h:	44; st: mstStreet; ps:	mbpRight));

	ARR_VAL_TOKEN_CHR: array[0..7] of Byte = (
			$18, $7E, $7E, $FF, $FF, $7E, $7E, $18);

	ARR_VAL_TOKEN_BNK: array[0..11] of Byte = (
			$FF, $FF, $0C, $0C, $0F, $0F, $01, $01, $0F, $0F, $0C, $0C);


procedure InitialiseBoard;


var
	GlobalMR64Board: TMR64Board;
	PrevMR64Board: TMR64Board;
	GlobalMR64BoardRegs: TMR64BoardRegs;
	GlobalMR64BrdSelGlyphs: array[0..39] of TMR64BoardGlyph;
	GlobalMR64BrdMrtGlyphs: array[0..39] of TMR64BoardGlyph;
	GlobalMR64BrdSlMGlyphs: array[0..39] of TMR64BoardGlyph;

	GlobalMR64TokenGlyphs: array[0..15] of TMR64BoardGlyph;
	GlobalMR64OwnGlyphs: array[0..15] of TMR64BoardGlyph;
	GlobalMR64ImprvGlyphs: array[0..4] of TMR64BoardGlyph;


implementation

uses
	SysUtils, Classes, PNGImage;


procedure DoLoadGlyph(const AFileName: string; var AGlyph: TMR64BoardGlyph);
	var
	i: TPNGImage;
	y,
	x: Integer;
	sl: PByteArray;
	p: TC64RGBA;
	al: PByteArray;

	begin
	i:= TPNGImage.Create;
	try
		i.LoadFromFile(AFileName);

		SetLength(AGlyph, i.Height);

		for y:= 0 to i.Height - 1 do
			begin
			SetLength(AGlyph[(i.Height - 1) - y], i.Width);

			sl:= PByteArray(i.Scanline[y]);
			al:= i.AlphaScanline[y];

			for x:= 0 to i.Width - 1 do
				begin
				p[0]:= sl[x * 3 + 2];
				p[1]:= sl[x * 3 + 1];
				p[2]:= sl[x * 3];
				if  Assigned(al) then
					p[3]:= al[x]
				else
					p[3]:= $FF;

				Move(p[0], AGlyph[(i.Height - 1) - y, x], 4);
				end;
			end;

		finally
		i.Free;
		end;
	end;


procedure InitialiseBoard;
	var
	m: TPNGImage;
	i,
	x,
	y: Integer;
	sl: PByteArray;
	p: TC64RGBA;

	begin
	m:= TPNGImage.Create;
	try
		m.LoadFromFile('res\board.png');

		for y:= 0 to 639 do
			begin
			sl:= PByteArray(m.Scanline[y]);

			for x:= 0 to 639 do
				begin
				p[0]:= sl[x * 3 + 2];
				p[1]:= sl[x * 3 + 1];
				p[2]:= sl[x * 3];
				p[3]:= $FF;

				Move(p[0], GlobalMR64Board[639 - y, x], 4);
				end;
			end;

		finally
		m.Free;
		end;

	Move(GlobalMR64Board[0], PrevMR64Board[0], 640 * 640 * 4);

	for i:= 0 to 39 do
		if  ARR_REC_BOARD_DET[i].st <> mstStreet then
			begin
			DoLoadGlyph(Format('res\Square%2.2xS.png', [i]),
					GlobalMR64BrdSelGlyphs[i]);

			if  ARR_REC_BOARD_DET[i].st <> mstAction then
				begin
				DoLoadGlyph(Format('res\Square%2.2xM.png', [i]),
						GlobalMR64BrdMrtGlyphs[i]);
				DoLoadGlyph(Format('res\Square%2.2xSM.png', [i]),
						GlobalMR64BrdSlMGlyphs[i]);
				end
			else
				begin
				SetLength(GlobalMR64BrdMrtGlyphs[i], 0);
				SetLength(GlobalMR64BrdSlMGlyphs[i], 0);
				end;
			end
		else
			begin
			SetLength(GlobalMR64BrdSelGlyphs[i], 0);
			SetLength(GlobalMR64BrdMrtGlyphs[i], 0);
			SetLength(GlobalMR64BrdSlMGlyphs[i], 0);
			end;
	end;

procedure InitialiseTokens;
	var
	i: Integer;

	begin
	for i:= 0 to 15 do
		DoLoadGlyph(Format('res\Token%2.2x.png', [i]), GlobalMR64TokenGlyphs[i]);
	end;

procedure InitialiseOwn;
	var
	i: Integer;

	begin
	for i:= 0 to 15 do
		DoLoadGlyph(Format('res\Own%2.2x.png', [i]), GlobalMR64OwnGlyphs[i]);
	end;

procedure InitialiseImprv;
	var
	i: Integer;

	begin
	for i:= 0 to 4 do
		DoLoadGlyph(Format('res\Improve%2.2x.png', [i]), GlobalMR64ImprvGlyphs[i]);
	end;


{ TMR64BoardIIO }

function TMR64BoardIIO.Read(const AAddress: Word): Byte;
	begin
	Result:= 0;
	end;

procedure TMR64BoardIIO.Write(const AAddress: Word; const AValue: Byte);
	var
	i: Integer;
	r: Word;

	begin
	r:= AAddress and $00FF;
	case r of
		$00:
			GlobalMR64BoardRegs.address:= (GlobalMR64BoardRegs.address and $FF00) or
					AValue;
		$01:
			GlobalMR64BoardRegs.address:= (GlobalMR64BoardRegs.address and $00FF) or
					(AValue shl 8);
		$02:
			if  AValue = 0 then
				GlobalMR64BoardRegs.dirty:= mbdNone
			else if AValue = 1 then
				GlobalMR64BoardRegs.dirty:= mbdAll
			else if AValue = 2 then
				GlobalMR64BoardRegs.dirty:= mbdSelect;
		$03..$08:
			GlobalMR64BoardRegs.players[r - $03].colour:= AValue and $0F;
		$09..$0E:
			GlobalMR64BoardRegs.players[r - $09].square:= AValue;
		$0F:
			begin
			for i:= 0 to 5 do
				GlobalMR64BoardRegs.players[i].active:= False;

			GlobalMR64BoardRegs.players[AValue].active:= True;
			end;
		$10..$15:
			GlobalMR64BoardRegs.players[r - $10].status:= AValue;
		end;
	end;


initialization
	InitialiseBoard;
	InitialiseTokens;
	InitialiseOwn;
	InitialiseImprv;

end.
