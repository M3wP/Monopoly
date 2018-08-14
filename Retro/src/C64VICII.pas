unit C64VICII;

interface

uses
	Classes, SyncObjs, C64Classes, MR64Board;

type
	TC64SpriteMode = (csmHiRes, csmMulti, csmHiMulti);

	TC64SpriteRegs = packed record
		posX,
		posY: Word;
		enabled: Boolean;
		colour: Byte;
		mode: TC64SpriteMode;
	end;

	TC64VICIIRegs = packed record
		rasterY: Word;
		rasterIRQY: Word;
		rasterIRQ: Boolean;
		rasterIRQSrc: Boolean;
		borderClr: Byte;
		backgdClr: Byte;
		sprtM0Clr: Byte;
		sprtM1Clr: Byte;
		sprites: array[0..7] of TC64SpriteRegs;
	end;

	TC64VICIIIO = class
	public
		procedure Write(const AAddress: Word; const AValue: Byte);
		function  Read(const AAddress: Word): Byte;
	end;

	TC64VICIIThread = class(TThread)
	protected
		FBuffer: TC64VideoBuffer;

	public
		RunSignal,
		DoneSignal: TSimpleEvent;

		constructor Create(ABuffer: TC64VideoBuffer);
		destructor Destroy; override;
	end;

	TC64VICIIFrame = class(TC64VICIIThread)
	protected
		FBrdRegs: TMR64BoardRegs;
		FPrevBrd: TMR64BoardSqrs;
		FThisBrd: TMR64BoardSqrs;
		FBlnkIdx: Integer;
		FBlnkFlg: Boolean;

		procedure Execute; override;

	public
		constructor Create(ABuffer: TC64VideoBuffer);
	end;

	TC64VICIIRaster = class(TC64VICIIThread)
	private
		FRegs: TC64VICIIRegs;

	protected
		procedure Execute; override;
	end;

	TC64VICIIBadLine = class(TC64VICIIThread)
	private
		FRegs: TC64VICIIRegs;
		FScreen: array[0..39] of Byte;
		FColour: array[0..39] of Byte;

		procedure DoDrawHiResText(AX, AY: Integer; AIndex: Integer);

	protected
		procedure Execute; override;

	public
		FRaster: Word;

	end;

var
	C64GlobalVICIIRegs: TC64VICIIRegs;

implementation

uses
	C64Types, C64Memory, C64Video;

{ TC64VICIIIO }

function TC64VICIIIO.Read(const AAddress: Word): Byte;
	var
	r: Byte;
	i: Integer;


	begin
	Result:= 0;
	r:= AAddress and $00FF;
	case r of
		$00..$0F:
			if  (r and $01) <> 0 then
				Result:= (C64GlobalVICIIRegs.sprites[r div 2].posY and $00FF)
			else
				Result:= (C64GlobalVICIIRegs.sprites[r div 2].posX and $00FF);
		$10:
			begin
			Result:= 0;
			for i:= 0 to 7 do
				if  C64GlobalVICIIRegs.sprites[i].posX > $FF then
					Result:= Result or (1 shl i)
//				Result:= Result or
//						(((C64GlobalVICIIRegs.sprites[i].posX and $100) shr 8) shl i);
			end;
		$11:
			begin
			Result:= (C64GlobalVICIIRegs.rasterY and $0100) shr 1;
			end;
		$12:
			Result:= C64GlobalVICIIRegs.rasterY and $00FF;
		$15:
			begin
			Result:= 0;
			for i:= 0 to 7 do
				if  C64GlobalVICIIRegs.sprites[i].enabled then
					Result:= Result or (1 shl i);
			end;
		$19:
			Result:= Ord(C64GlobalVICIIRegs.rasterIRQSrc);
		$1A:
			begin
			Result:= Ord(C64GlobalVICIIRegs.rasterIRQ);
			end;
		$20:
			Result:= C64GlobalVICIIRegs.borderClr;
		$21:
			Result:= C64GlobalVICIIRegs.backgdClr;
		$25:
			Result:= C64GlobalVICIIRegs.sprtM0Clr;
		$26:
			Result:= C64GlobalVICIIRegs.sprtM1Clr;
		$27..$2E:
			Result:= C64GlobalVICIIRegs.sprites[r - $27].colour;
		$2F:
			begin
			Result:= 0;
			for i:= 0 to 7 do
				if  C64GlobalVICIIRegs.sprites[i].mode = csmHiMulti then
					Result:= Result or (1 shl i);
			end;
		$30:
			begin
			Result:= 0;
			for i:= 0 to 7 do
				Result:= Result or
						(((C64GlobalVICIIRegs.sprites[i].posY and $100) shr 8) shl i);
			end;
		end;
	end;

procedure TC64VICIIIO.Write(const AAddress: Word; const AValue: Byte);
	var
	r: Byte;
	v: Byte;
	i: Integer;

	begin
	r:= AAddress and $00FF;
	case r of
		$00..$0F:
			begin
			if  (r and $01) <> 0 then
				C64GlobalVICIIRegs.sprites[r div 2].posY:=
						(C64GlobalVICIIRegs.sprites[r div 2].posY and $0100) or AValue
			else
				C64GlobalVICIIRegs.sprites[r div 2].posX:=
						(C64GlobalVICIIRegs.sprites[r div 2].posX and $0100) or AValue;
			end;
		$10:
			begin
			v:= AValue;
			for i:= 0 to 7 do
				begin
				if  (v and $01) <> 0 then
					C64GlobalVICIIRegs.sprites[i].posX:=
							(C64GlobalVICIIRegs.sprites[i].posX and $00FF) or $0100
				else
					C64GlobalVICIIRegs.sprites[i].posX:=
							(C64GlobalVICIIRegs.sprites[i].posX and $00FF);

				v:= v shr 1;
				end;
			end;
		$11:
			begin
			v:= C64GlobalVICIIRegs.rasterIRQY and $00FF;
			v:= v or ((AValue and $80) shl 1);
			C64GlobalVICIIRegs.rasterIRQY:= v;
			end;
		$12:
			begin
			v:= C64GlobalVICIIRegs.rasterIRQY and $0100;
			v:= v or AValue;
			C64GlobalVICIIRegs.rasterIRQY:= v;
			end;
		$15:
			begin
			v:= AValue;
			for i:= 0 to 7 do
				begin
				C64GlobalVICIIRegs.sprites[i].enabled:= (v and $01) <> 0;
				v:= v shr 1;
				end;
			end;
		$1A:
			begin
			C64GlobalVICIIRegs.rasterIRQ:= (AValue and $01) <> 0;
			end;
		$20:
			C64GlobalVICIIRegs.borderClr:= AValue and $0F;
		$21:
			C64GlobalVICIIRegs.backgdClr:= AValue and $0F;
		$25:
			C64GlobalVICIIRegs.sprtM0Clr:= AValue and $0F;
		$26:
			C64GlobalVICIIRegs.sprtM1Clr:= AValue and $0F;
		$27..$2E:
			C64GlobalVICIIRegs.sprites[r - $27].colour:= AValue and $0F;
		$2F:
			begin
			v:= AValue;
			for i:= 0 to 7 do
				begin
				if  (v and $01) <> 0 then
					C64GlobalVICIIRegs.sprites[i].mode:= csmHiMulti
				else
					C64GlobalVICIIRegs.sprites[i].mode:= csmHiRes;

				v:= v shr 1;
				end;
			end;
		$30:
			begin
			v:= AValue;
			for i:= 0 to 7 do
				begin
				if  (v and $01) <> 0 then
					C64GlobalVICIIRegs.sprites[i].posY:=
							(C64GlobalVICIIRegs.sprites[i].posY and $00FF) or $0100
				else
					C64GlobalVICIIRegs.sprites[i].posY:=
							(C64GlobalVICIIRegs.sprites[i].posY and $00FF);

				v:= v shr 1;
				end;
			end;
		end;
	end;

{ TC64VICIIThread }

constructor TC64VICIIThread.Create(ABuffer: TC64VideoBuffer);
	begin
	FBuffer:= ABuffer;

	RunSignal:= TSimpleEvent.Create;
	RunSignal.ResetEvent;
	DoneSignal:= TSimpleEvent.Create;
	DoneSignal.SetEvent;

	inherited Create(False);

	FreeOnTerminate:= True;
	end;

destructor TC64VICIIThread.Destroy;
	begin

	inherited;
	end;

{ TC64VICIIFrame }

constructor TC64VICIIFrame.Create(ABuffer: TC64VideoBuffer);
	var
	i: Integer;
	s: TMR64BoardSqr;

	begin
	s.own:= $FF;
	s.imprv:= $00;

	for i:= 0 to 39 do
		FPrevBrd[i]:= s;

	inherited Create(ABuffer);
	end;

procedure TC64VICIIFrame.Execute;
	var
	p: TC64PalToInt;

	procedure DoFillSquareSolid(const ASquare: Integer; const AColourInt: Integer);
		var
		y,
		yp,
		xp,
		sz: Integer;

		begin
		for y:= 0 to ARR_REC_BOARD_DET[ASquare].h - 1 do
			begin
			yp:= 639 - (ARR_REC_BOARD_DET[ASquare].y + y);
			xp:= ARR_REC_BOARD_DET[ASquare].x;
			sz:= ARR_REC_BOARD_DET[ASquare].w;

			DoFillInt(PInteger(@FBuffer.FBR^[yp, xp]), sz, AColourInt);
			end;
		end;

	procedure DoCopyOrigGlyph(const ASquare: Integer);
		var
		y,
		yp,
		xp,
		sz: Integer;

		begin
		for y:= 0 to ARR_REC_BOARD_DET[ASquare].h - 1 do
			begin
			yp:= 639 - (ARR_REC_BOARD_DET[ASquare].y + y);
			xp:= ARR_REC_BOARD_DET[ASquare].x;
			sz:= ARR_REC_BOARD_DET[ASquare].w * 4;

			Move(GlobalMR64Board[yp, xp, 0], FBuffer.FBR^[yp, xp, 0], sz);
			end;
		end;

	procedure DoCopySelGlyph(const ASquare: Integer);
		var
		y,
		yp,
		xp,
		sz: Integer;

		begin
		for y:= 0 to ARR_REC_BOARD_DET[ASquare].h - 1 do
			begin
			yp:= 639 - (ARR_REC_BOARD_DET[ASquare].y + y);
			xp:= ARR_REC_BOARD_DET[ASquare].x;
			sz:= ARR_REC_BOARD_DET[ASquare].w * 4;

			Move(GlobalMR64BrdSelGlyphs[ASquare, (ARR_REC_BOARD_DET[ASquare].h - 1) - y,
					0, 0], FBuffer.FBR^[yp, xp, 0], sz);
			end;
		end;

	procedure DoCopyMrtGlyph(const ASquare: Integer);
		var
		y,
		yp,
		xp,
		sz: Integer;

		begin
		for y:= 0 to ARR_REC_BOARD_DET[ASquare].h - 1 do
			begin
			yp:= 639 - (ARR_REC_BOARD_DET[ASquare].y + y);
			xp:= ARR_REC_BOARD_DET[ASquare].x;
			sz:= ARR_REC_BOARD_DET[ASquare].w * 4;

			Move(GlobalMR64BrdMrtGlyphs[ASquare, (ARR_REC_BOARD_DET[ASquare].h - 1) - y,
					0, 0], FBuffer.FBR^[yp, xp, 0], sz);
			end;
		end;

	procedure DoCopySlMGlyph(const ASquare: Integer);
		var
		y,
		yp,
		xp,
		sz: Integer;

		begin
		for y:= 0 to ARR_REC_BOARD_DET[ASquare].h - 1 do
			begin
			yp:= 639 - (ARR_REC_BOARD_DET[ASquare].y + y);
			xp:= ARR_REC_BOARD_DET[ASquare].x;
			sz:= ARR_REC_BOARD_DET[ASquare].w * 4;

			Move(GlobalMR64BrdSlMGlyphs[ASquare, (ARR_REC_BOARD_DET[ASquare].h - 1) - y,
					0, 0], FBuffer.FBR^[yp, xp, 0], sz);
			end;
		end;

//	procedure DoDrawVICIIChar(const AX, AY: Integer; const AChar, AFGClr, ABGClr: Byte);
//		var
//		x,
//		y: Integer;
//		b: Byte;
////		m: Byte;
//		p: TC64RGBA;
//
//		begin
//		for y:= 0 to 15 do
//			begin
//			for x:= 0 to 15 do
//				begin
//				p:= GlobalC64Palette[ABGClr];
//				Move(p[0], FBuffer.FBR^[639 - (AY + y), AX + x, 0], 4);
//
//				b:= GlobalC64CharGen[AChar * 256 + y * 16 + x];
//				p:= GlobalC64Palette[AFGClr];
//				p[3]:= b;
//
//				Move(p[0], FBuffer.FBP^[639 - (AY + y), AX + x, 0], 4);
//				end;
//			end;
//		end;

	procedure DoDrawOwnGlyph(const AX, AY: Integer; const AFGClr: Byte;
			const AAll: Boolean);
		var
		x,
		y: Integer;
		p: TC64RGBA;

		begin
		for y:= 0 to 15 do
			for x:= 0 to 15 do
				begin
				if  AAll then
					p:= GlobalC64Palette[AFGClr]
				else
					p:= GlobalMR64OwnGlyphs[AFGClr, 15 - y, x];

				Move(p[0], FBuffer.FBR^[639 - (AY + y), AX + x, 0], 4);
				end;
		end;

	procedure DoDrawImprvGlyph(const AX, AY: Integer; const AImprv: Byte);
		var
		x,
		y: Integer;
		p: TC64RGBA;

		begin
		for y:= 0 to 15 do
			for x:= 0 to 15 do
				begin
				p:= GlobalMR64ImprvGlyphs[AImprv, 15 - y, x];
				Move(p[0], FBuffer.FBR^[639 - (AY + y), AX + x, 0], 4);
				end;
		end;

	procedure UpdateOwn;
		var
		i: Integer;
		all: Boolean;
		cl: Byte;
		x,
		y: Integer;

		begin
		for i:= 0 to 39 do
			begin
			all:= (FThisBrd[i].imprv and $40) <> 0;

			if  FThisBrd[i].own = $FF then
				cl:= $0B
			else
				cl:= FBrdRegs.players[FThisBrd[i].own].colour;

			case ARR_REC_BOARD_DET[i].ps of
				mbpBottom, mbpTop:
					begin
					if  ARR_REC_BOARD_DET[i].ps = mbpBottom then
						x:= ARR_REC_BOARD_DET[i].x
					else
						x:= ARR_REC_BOARD_DET[i].x - 4;

					y:= ARR_VAL_BOARD_OWN[ARR_REC_BOARD_DET[i].ps];

					DoDrawOwnGlyph(x, y, cl, all);
					DoDrawOwnGlyph(x + 16, y, cl, all);
					DoDrawOwnGlyph(x + 32, y, cl, all);
					end;
				mbpLeft, mbpRight:
					begin
					if  ARR_REC_BOARD_DET[i].ps = mbpRight then
						y:= ARR_REC_BOARD_DET[i].y
					else
						y:= ARR_REC_BOARD_DET[i].y - 4;

					x:= ARR_VAL_BOARD_OWN[ARR_REC_BOARD_DET[i].ps];

					DoDrawOwnGlyph(x, y, cl, all);
					DoDrawOwnGlyph(x, y + 16, cl, all);
					DoDrawOwnGlyph(x, y + 32, cl, all);
					end;
				end;
			end;
		end;

	procedure UpdateImprove;
		var
		i: Integer;
		ch: Byte;
//		cl: Byte;
		x,
		y: Integer;

		begin
		for i:= 0 to 39 do
			begin
			if  (FThisBrd[i].imprv and $0F) <> 0 then
				begin
				if  (FThisBrd[i].imprv and $08) <> 0 then
					ch:= 4
				else
					ch:= FThisBrd[i].imprv and $07 - 1;

				case ARR_REC_BOARD_DET[i].ps of
					mbpBottom, mbpTop:
						begin
						x:= ARR_REC_BOARD_DET[i].x;
						y:= ARR_VAL_BOARD_IMP[ARR_REC_BOARD_DET[i].ps];

						DoDrawImprvGlyph(x, y, ch);
						end;
					mbpLeft, mbpRight:
						begin
						y:= ARR_REC_BOARD_DET[i].y;
						x:= ARR_VAL_BOARD_IMP[ARR_REC_BOARD_DET[i].ps];

						DoDrawImprvGlyph(x, y, ch);
						end;
					end;
				end;
			end;
		end;

	procedure UpdateMortgage;
		var
		i: Integer;
		p: TC64PalToInt;

		begin
		p.arr:= GlobalC64Palette[$0B];

		for i:= 0 to 39 do
			if  (FThisBrd[i].imprv and $80) <> 0 then
				if  ARR_REC_BOARD_DET[i].st <> mstStreet then
					DoCopyMrtGlyph(i)
				else
					DoFillSquareSolid(i, p.int);
		end;

	procedure ResetSelection;
		var
		i: Integer;
		p: TC64PalToInt;

		begin
		for i:= 0 to 39 do
			if  (FPrevBrd[i].imprv and $20) <> 0 then
				if  ARR_REC_BOARD_DET[i].st <> mstStreet then
					if (FPrevBrd[i].imprv and $80) <> 0 then
						DoCopyMrtGlyph(i)
					else
						DoCopyOrigGlyph(i)
				else
					begin
					if (FPrevBrd[i].imprv and $80) <> 0 then
						p.arr:= GlobalC64Palette[$0B]
					else
						p.arr:= GlobalC64Palette[$03];

					DoFillSquareSolid(i, p.int);
					end;
		end;

	procedure UpdateSelection;
		var
		i: Integer;
		p: TC64PalToInt;

		begin
		for i:= 0 to 39 do
			if  (FThisBrd[i].imprv and $20) <> 0 then
				if  ARR_REC_BOARD_DET[i].st <> mstStreet then
					begin
					if (FThisBrd[i].imprv and $80) <> 0 then
						DoCopySlMGlyph(i)
					else
						DoCopySelGlyph(i)
					end
				else
					begin
					if (FThisBrd[i].imprv and $80) <> 0 then
						p.arr:= GlobalC64Palette[$0F]
					else
						p.arr:= GlobalC64Palette[$01];

					DoFillSquareSolid(i, p.int);
					end;
		end;

	procedure DoGetPlayerPos(const APlayer: Integer; var AX, AY: Integer);
		var
		s: Integer;
		p: Integer;

		begin
		s:= FBrdRegs.players[APlayer].square;
		p:= APlayer mod 3;

		case ARR_REC_BOARD_DET[s].ps of
			mbpBottom:
				begin
				AX:= ARR_REC_BOARD_DET[s].x + 4;
				AY:= ARR_REC_BOARD_DET[s].y + 2 + p * 18;
				if  APlayer > 2 then
					Inc(AX, 20);
				if  ARR_REC_BOARD_DET[s].st <> mstStreet then
					Inc(AY, 20);
				end;
			mbpLeft:
				begin
				AX:= ARR_REC_BOARD_DET[s].x + 2 + p * 18;
				AY:= ARR_REC_BOARD_DET[s].y + 4;
				if  APlayer > 2 then
					Inc(AY, 20);
				end;
			mbpTop:
				begin
				AX:= ARR_REC_BOARD_DET[s].x + 4;
				AY:= ARR_REC_BOARD_DET[s].y + 2 + p * 18;
				if  APlayer > 2 then
					Inc(AX, 20);
				end;
			mbpRight:
				begin
				AX:= ARR_REC_BOARD_DET[s].x + 2 + p * 18;
				AY:= ARR_REC_BOARD_DET[s].y + 4;
				if  APlayer > 2 then
					Inc(AY, 20);
				if  ARR_REC_BOARD_DET[s].st <> mstStreet then
					Inc(AX, 20);
				end;
			end;
		end;

	procedure DoDrawPlayerToken(const APlayer, AX, AY: Integer);
		var
		x,
		y: Integer;
		cl: Byte;

		begin
		cl:= FBrdRegs.players[APlayer].colour;
		if  FBrdRegs.players[APlayer].active then
			if  ARR_VAL_TOKEN_BNK[FBlnkIdx] <> $FF then
				cl:= ARR_VAL_TOKEN_BNK[FBlnkIdx];

		for y:= 0 to High(GlobalMR64TokenGlyphs[cl]) do
			for x:= 0 to High(GlobalMR64TokenGlyphs[cl, y]) do
				Move(GlobalMR64TokenGlyphs[cl, y, x],
						FBuffer.FBP^[639 - (AY + y), AX + x, 0], 4);
		end;

	procedure UpdatePlayers;
		var
		i: Integer;
		xp,
		yp: Integer;

		begin
		for i:= 5 downto 0 do
			if  (FBrdRegs.players[i].status and $01) <> 0 then
				begin
				DoGetPlayerPos(i, xp, yp);
				DoDrawPlayerToken(i, xp, yp);
				end;
		end;

	begin
	while not Terminated do
		if  RunSignal.WaitFor(1) = wrSignaled then
			begin
			DoneSignal.ResetEvent;

			FBrdRegs:= GlobalMR64BoardRegs;
			GlobalMR64BoardRegs.dirty:= mbdNone;

			p.arr:= ARR_CLR_C64ALPHA;
			DoFillInt(PInteger(FBuffer.FBP), 640 * 640, p.int);

			if  FBrdRegs.dirty <> mbdNone then
				Move(GlobalC64Memory.FRAM[FBrdRegs.address], FThisBrd[0], 80);

			if  FBrdRegs.dirty = mbdAll then
				begin
				Move(GlobalMR64Board[0], FBuffer.FBR^, 640 * 640 * 4);
				UpdateOwn;
				UpdateImprove;
				UpdateMortgage;
				end
			else
				Move(PrevMR64Board[0], FBuffer.FBR^, 640 * 640 * 4);

			if  FBrdRegs.dirty = mbdSelect then
				ResetSelection;

			if  FBrdRegs.dirty <> mbdNone then
				begin
				UpdateSelection;

				Move(FBuffer.FBR^, PrevMR64Board[0], 640 * 640 * 4);
				Move(FThisBrd[0], FPrevBrd[0], 80);
				end;

			FBlnkFlg:= not FBlnkFlg;
			if  not FBlnkFlg then
				begin
				Inc(FBlnkIdx);
				if  FBlnkIdx = 12 then
					FBlnkIdx:= 0;
				end;

			UpdatePlayers;

			RunSignal.ResetEvent;
			DoneSignal.SetEvent;
			end;
	end;

{ TC64VICIIRaster }

procedure TC64VICIIRaster.Execute;
	var
	y: Integer;
	x: Integer;
	p: TC64PalToInt;

	function SpriteOnRaster(const ASprite, ARaster: Integer): Boolean;
		begin
		Result:= False;

//		if  (ARaster >= 51)
//		and (ARaster <= 250) then
			if  (ARaster >= FRegs.sprites[ASprite].posY)
			and (ARaster <= (FRegs.sprites[ASprite].posY + 20)) then
				Result:= FRegs.sprites[ASprite].enabled;
		end;

	procedure DrawSpriteRasterHiRes(const ASprite, ARaster: Integer);
		var
		addr: Word;
		offs: Integer;
		b,
		m,
		ch: Byte;
		i,
		j: Integer;

		begin
		offs:= ARaster - FRegs.sprites[ASprite].posY;
		addr:= GlobalC64Memory.FRAM[$07F8 + ASprite] * 64 + offs * 3;

		for i:= 0 to 2 do
			begin
			ch:= GlobalC64Memory.FRAM[addr];
			m:= $80;
			for j:= 0 to 7 do
				begin
				b:= ch and m;
				m:= m shr 1;

				if  b <> 0 then
					Move(GlobalC64Palette[FRegs.sprites[ASprite].colour],
							FBuffer.FSP^[311 - ARaster,
							FRegs.sprites[ASprite].posX + i * 8 + j, 0], 4);
				end;

			Inc(addr);
			end;
		end;

	procedure DrawSpriteRasterHiMulti(const ASprite, ARaster: Integer);
		var
		addr: Word;
		offs: Integer;
		b,
		m,
		ch: Byte;
		i,
		j: Integer;

		begin
		offs:= ARaster - FRegs.sprites[ASprite].posY;
		addr:= GlobalC64Memory.FRAM[$07F8 + ASprite] * 64 + offs * 6;

		for i:= 0 to 5 do
			begin
			ch:= GlobalC64Memory.FRAM[addr];
			m:= $C0;
			for j:= 0 to 3 do
				begin
				b:= ch and m;
				b:= b shr ((3 - j) * 2);
				m:= m shr 2;

				if  b = 1 then
					Move(GlobalC64Palette[FRegs.sprtM0Clr],
							FBuffer.FSP^[311 - ARaster,
							FRegs.sprites[ASprite].posX + i * 4 + j, 0], 4)
				else if b = 2 then
					Move(GlobalC64Palette[FRegs.sprites[ASprite].colour],
							FBuffer.FSP^[311 - ARaster,
							FRegs.sprites[ASprite].posX + i * 4 + j, 0], 4)
				else if b = 3 then
					Move(GlobalC64Palette[FRegs.sprtM1Clr],
							FBuffer.FSP^[311 - ARaster,
							FRegs.sprites[ASprite].posX + i * 4 + j, 0], 4);
				end;

			Inc(addr);
			end;
		end;

	begin
	while not Terminated do
		begin
		if  RunSignal.WaitFor(1) = wrSignaled then
			begin
			DoneSignal.ResetEvent;

			FRegs:= C64GlobalVICIIRegs;
			y:= FRegs.rasterY;

			p.arr:= GlobalC64Palette[FRegs.borderClr];
			DoFillInt(PInteger(@FBuffer.FBG^[(VAL_SIZ_SCREEN_PALY2X - 1) - (y * 2) - 1, 0]),
					VAL_SIZ_SCREEN_PALX2X * 2, p.int);

			p.arr:= ARR_CLR_C64ALPHA;
			DoFillInt(PInteger(@FBuffer.FSP^[311 - y, 0]), 385, p.int);

			for x:= 7 downto 0 do
				if  SpriteOnRaster(x, y) then
					if  FRegs.sprites[x].mode = csmHiRes then
						DrawSpriteRasterHiRes(x, y)
					else if  FRegs.sprites[x].mode = csmHiMulti then
						DrawSpriteRasterHiMulti(x, y);

			RunSignal.ResetEvent;
			DoneSignal.SetEvent;
			end;
		end;
	end;

{ TC64VICIIBadLine }

procedure TC64VICIIBadLine.DoDrawHiResText(AX, AY, AIndex: Integer);
	var
	chrgen: Integer;
	ch: Byte;
	cl: Byte;
//	b: Byte;
//	m: Byte;
	i,
	j: Integer;
	p: TC64PalToInt;

	begin
	for i:= 0 to 39 do
		begin
		cl:= FColour[i];
		chrgen:= FScreen[i] * 256 + AIndex * 16;

		for j:= 0 to 15 do
			begin
			ch:= GlobalC64CharGen[chrgen + j];

			if  cl > $0F then
				begin
				Move(ARR_CLR_C64ALPHA[0],
						FBuffer.FFG^[(VAL_SIZ_SCREEN_PALY2X - 1) - AY,
						AX + i * 16 + j, 0], 4);
				Move(ARR_CLR_C64ALPHA[0],
						FBuffer.FFP^[(VAL_SIZ_SCREEN_PALY2X - 1) - AY,
						AX + i * 16 + j, 0], 4);
				end
			else
				begin
				Move(GlobalC64Palette[FRegs.backgdClr],
						FBuffer.FFG^[(VAL_SIZ_SCREEN_PALY2X - 1) - AY,
						AX + i * 16 + j, 0], 4);

				p.arr:= GlobalC64Palette[cl];
				p.arr[3]:= ch;
				Move(p.arr[0], FBuffer.FFP^[(VAL_SIZ_SCREEN_PALY2X - 1) - AY,
						AX + i * 16 + j, 0], 4);
				end;
			end;
		end;

	end;

procedure TC64VICIIBadLine.Execute;
	var
	i,
	x,
	y: Integer;
	addr: Word;

	begin
	while not Terminated do
		if  RunSignal.WaitFor(1) = wrSignaled then
			begin
			DoneSignal.ResetEvent;

			FRegs:= C64GlobalVICIIRegs;

			addr:= $0400 + FBuffer.FBADLine * 40;
			for i:= 0 to 39 do
				FScreen[i]:= GlobalC64Memory.FRAM[addr + i];

			addr:= $D800 + FBuffer.FBADLine * 40;
			for i:= 0 to 39 do
				FColour[i]:= GlobalC64Memory.FRAM[addr + i];

			for i:= 0 to 15 do
				begin
				y:= {51 + FBuffer.FBADLine * 8}FRaster * 2 + i;
				x:= 24 * 2;

				DoDrawHiResText(x, y, i);

//				for x:= 24 to 343 do
//					Move(GlobalC64Palette[FRegs.backgdClr{FBuffer.FBADLine mod 16}],
//							FBuffer.FFG^[311 - y, x, 0], 4);
				end;

			RunSignal.ResetEvent;
			DoneSignal.SetEvent;
			end;
	end;

end.
