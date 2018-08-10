unit MR64Board;

interface

uses
	C64Video;

type
	PMR64Board = ^TMR64Board;
	TMR64Board = array[0..319, 0..319] of TC64RGBA;

	TMR64BoardPlayerDet = record
		colour: Byte;
		active: Boolean;
		square: Byte;
		status: Byte;
	end;

	TMR64BoardDirty = (mbdNone, mbdAll, mbdSelect);

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
		fg: Boolean;
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
		(306, 6, 0, 312);

	ARR_VAL_BOARD_IMP: array[TMR64BoardPos] of Integer =
		(266, 46, 40, 272);

	ARR_REC_BOARD_DET: array[0..39] of TMR64BoardSqDet = (
//0:
			(x:	272; y:	266; w:	38; h:	38; fg:	True; ps:	mbpBottom),
//1:
			(x:	248; y:	276; w:	22; h:	28; fg:	False; ps:	mbpBottom),
//2:
			(x:	224; y:	266; w:	22; h:	38; fg:	True; ps:	mbpBottom),
//3:
			(x:	200; y:	276; w:	22; h:	28; fg:	False; ps:	mbpBottom),
//4:
			(x:	176; y:	266; w:	22; h:	38; fg:	True; ps:	mbpBottom),
//5:
			(x:	152; y:	266; w:	22; h:	38; fg:	True; ps:	mbpBottom),
//6:
			(x:	128; y:	276; w:	22; h:	28; fg:	False; ps:	mbpBottom),
//7:
			(x:	104; y:	266; w:	22; h:	38; fg:	True; ps:	mbpBottom),
//8:
			(x:	80; y:	276; w:	22; h:	28; fg:	False; ps:	mbpBottom),
//9:
			(x:	56; y:	276; w:	22; h:	28; fg:	False; ps:	mbpBottom),
//10:
			(x:	16; y:	266; w:	38; h:	38; fg:	True; ps:	mbpLeft),
//11:
			(x:	16; y:	242; w:	28; h:	22; fg:	False; ps:	mbpLeft),
//12:
			(x:	16; y:	218; w:	38; h:	22; fg:	True; ps:	mbpLeft),
//13:
			(x:	16; y:	194; w:	28; h:	22; fg:	False; ps:	mbpLeft),
//14:
			(x:	16; y:	170; w:	28; h:	22; fg:	False; ps:	mbpLeft),
//15:
			(x:	16; y:	146; w:	38; h:	22; fg:	True; ps:	mbpLeft),
//16:
			(x:	16; y:	122; w:	28; h:	22; fg:	False; ps:	mbpLeft),
//17:
			(x:	16; y:	98; w:	38; h:	22; fg:	True; ps:	mbpLeft),
//18:
			(x:	16; y:	74; w:	28; h:	22; fg:	False; ps:	mbpLeft),
//19:
			(x:	16; y:	50; w:	28; h:	22; fg:	False; ps:	mbpLeft),
//20:
			(x:	16; y:	10; w:	38; h:	38; fg:	True; ps:	mbpTop),
//21:
			(x:	56; y:	10; w:	22; h:	28; fg:	False; ps:	mbpTop),
//22:
			(x:	80; y:	10; w:	22; h:	38; fg:	True; ps:	mbpTop),
//23:
			(x:	104; y:	10; w:	22; h:	28; fg:	False; ps:	mbpTop),
//24:
			(x:	128; y:	10; w:	22; h:	28; fg:	False; ps:	mbpTop),
//25:
			(x:	152; y:	10; w:	22; h:	38; fg:	True; ps:	mbpTop),
//26:
			(x:	176; y:	10; w:	22; h:	28; fg:	False; ps:	mbpTop),
//27:
			(x:	200; y:	10; w:	22; h:	28; fg:	False; ps:	mbpTop),
//28:
			(x:	224; y:	10; w:	22; h:	38; fg:	True; ps:	mbpTop),
//29:
			(x:	248; y:	10; w:	22; h:	28; fg:	False; ps:	mbpTop),
//30:
			(x:	272; y:	10; w:	38; h:	38; fg:	True; ps:	mbpRight),
//31:
			(x:	282; y:	50; w:	28; h:	22; fg:	False; ps:	mbpRight),
//32:
			(x:	282; y:	74; w:	28; h:	22; fg:	False; ps:	mbpRight),
//33:
			(x:	272; y:	98; w:	38; h:	22; fg:	True; ps:	mbpRight),
//34:
			(x:	282; y:	122; w:	28; h:	22; fg:	False; ps:	mbpRight),
//35:
			(x:	272; y:	146; w:	38; h:	22; fg:	True; ps:	mbpRight),
//36:
			(x:	272; y:	170; w:	38; h:	22; fg:	True; ps:	mbpRight),
//37:
			(x:	282; y:	194; w:	28; h:	22; fg:	False; ps:	mbpRight),
//38:
			(x:	272; y:	218; w:	38; h:	22; fg:	True; ps:	mbpRight),
//39:
			(x:	282; y:	242; w:	28; h:	22; fg:	False; ps:	mbpRight));

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


implementation

uses
	Classes;

procedure InitialiseBoard;
	var
	m: TMemoryStream;
	i,
	x,
	y: Integer;
	p: Byte;
	xp,
	yp: Integer;

	begin
	m:= TMemoryStream.Create;
	try
		m.LoadFromFile('board.data');
		m.Position:= 0;

		for y:= 0 to 319 do
			for x:= 0 to 319 do
				begin
				m.ReadData(p, 1);
				Move(GlobalC64Palette[p], GlobalMR64Board[319 - y, x], 4);
				end;

		finally
		m.Free;
		end;

	Move(GlobalMR64Board[0], PrevMR64Board[0], 320 * 320 * 4);

	for i:= 0 to 39 do
		if  ARR_REC_BOARD_DET[i].fg then
			begin
			SetLength(GlobalMR64BrdSelGlyphs[i], ARR_REC_BOARD_DET[i].h);
			SetLength(GlobalMR64BrdMrtGlyphs[i], ARR_REC_BOARD_DET[i].h);
			SetLength(GlobalMR64BrdSlMGlyphs[i], ARR_REC_BOARD_DET[i].h);

			for y:= 0 to ARR_REC_BOARD_DET[i].h - 1 do
				begin
				SetLength(GlobalMR64BrdSelGlyphs[i, (ARR_REC_BOARD_DET[i].h - 1) - y],
						ARR_REC_BOARD_DET[i].w);
				SetLength(GlobalMR64BrdMrtGlyphs[i, (ARR_REC_BOARD_DET[i].h - 1) - y],
						ARR_REC_BOARD_DET[i].w);
				SetLength(GlobalMR64BrdSlMGlyphs[i, (ARR_REC_BOARD_DET[i].h - 1) - y],
						ARR_REC_BOARD_DET[i].w);

				yp:= 319 - (ARR_REC_BOARD_DET[i].y + y);

				for x:= 0 to ARR_REC_BOARD_DET[i].w - 1 do
					begin
					xp:= ARR_REC_BOARD_DET[i].x + x;

					if  (GlobalMR64Board[yp, xp, 0] = GlobalC64Palette[0, 0])
					and (GlobalMR64Board[yp, xp, 1] = GlobalC64Palette[0, 1])
					and (GlobalMR64Board[yp, xp, 2] = GlobalC64Palette[0, 2]) then
						begin
						Move(GlobalC64Palette[0], GlobalMR64BrdSelGlyphs[i,
								(ARR_REC_BOARD_DET[i].h - 1) - y, x], 4);
						Move(GlobalC64Palette[0], GlobalMR64BrdMrtGlyphs[i,
								(ARR_REC_BOARD_DET[i].h - 1) - y, x], 4);
						Move(GlobalC64Palette[0], GlobalMR64BrdSlMGlyphs[i,
								(ARR_REC_BOARD_DET[i].h - 1) - y, x], 4);
						end
					else
						begin
						Move(GlobalC64Palette[1], GlobalMR64BrdSelGlyphs[i,
								(ARR_REC_BOARD_DET[i].h - 1) - y, x], 4);
						Move(GlobalC64Palette[11], GlobalMR64BrdMrtGlyphs[i,
								(ARR_REC_BOARD_DET[i].h - 1) - y, x], 4);
						Move(GlobalC64Palette[15], GlobalMR64BrdSlMGlyphs[i,
								(ARR_REC_BOARD_DET[i].h - 1) - y, x], 4);
						end;
					end;
				end;
			end
		else
			begin
			SetLength(GlobalMR64BrdSelGlyphs[i], 0);
			SetLength(GlobalMR64BrdMrtGlyphs[i], 0);
			SetLength(GlobalMR64BrdSlMGlyphs[i], 0);
			end;
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

end.
