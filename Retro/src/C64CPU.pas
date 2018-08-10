// Fake6502 CPU emulator core v1.1
// (c)2011 Mike Chambers (miker00lz@gmail.com)
// Pascal conversion, (c) Daniel England, 2018.

unit C64CPU;
//6502 defines
{$define UNDOCUMENTED} //when this is defined, undocumented opcodes are handled.
					 //otherwise, they're simply treated as NOPs.

{.define NES_CPU}      //when this is defined, the binary-coded decimal (BCD)
					 //status flag is not honored by ADC and SBC. the 2A03
					 //CPU in the Nintendo Entertainment System does not
					 //support BCD operation.

interface
const
	FLAG_CARRY		=	$01;
	FLAG_ZERO		=	$02;
	FLAG_INTERRUPT 	=	$04;
	FLAG_DECIMAL   	=	$08;
	FLAG_BREAK		=	$10;
	FLAG_CONSTANT	=	$20;
	FLAG_OVERFLOW  	=	$40;
	FLAG_SIGN      	=	$80;

	BASE_STACK     	=	$0100;

procedure saveaccum(const n: Word); inline;

//flag modifier macros
procedure setcarry; inline;
procedure clearcarry; inline;
procedure setzero; inline;
procedure clearzero; inline;
procedure setinterrupt; inline;
procedure clearinterrupt; inline;
procedure setdecimal; inline;
procedure cleardecimal; inline;
procedure setoverflow; inline;
procedure clearoverflow; inline;
procedure setsign; inline;
procedure clearsign; inline;

//flag calculation macros
procedure zerocalc(const n: Word); inline;
procedure signcalc(const n: Word); inline;
procedure carrycalc(const n: Word); inline;
procedure overflowcalc(const n, m, o: Word); inline;

type
	read6502func = function(address: Word): Byte;
	write6502proc = procedure(address: Word; value: Byte);

var
//6502 CPU registers
	pc: Word;
	sp, a, x, y, status: Byte;
	
//helper variables
	instructions: Cardinal = 0; //keep track of total instructions executed
	lastticks6502: Cardinal = 0;
	clockticks6502: Cardinal = 0;
	clockgoal6502: Cardinal = 0;
	oldpc, 
	ea, 
	reladdr, 
	value, 
	_result: Word;
	opcode, 
	oldstatus: Byte;

//externally supplied functions
	read6502: read6502func;
	write6502: write6502proc;

//a few general functions used by various other functions
procedure push16(const pushval: Word);
procedure push8(const pushval: Byte);
function  pull16: Word;
function  pull8: Byte;
procedure reset6502;

type
	addrtableprocs = array[0..255] of procedure;
	optableprocs = array[0..255] of procedure;

var
	penaltyop, penaltyaddr: Byte;

//addressing mode functions, calculates effective addresses
procedure imp;
procedure acc;
procedure imm;
procedure zp;
procedure zpx;
procedure zpy;
procedure rel;
procedure abso;
procedure absx;
procedure absy;
procedure ind;
procedure indx;
procedure indy;

function getvalue: Word;
function getvalue16: Word;
procedure putvalue(const saveval: Word);

//instruction handler functions
procedure adc;
procedure _and;
procedure asl;
procedure bcc;
procedure bcs;
procedure beq;
procedure bit;
procedure bmi;
procedure bne;
procedure bpl;
procedure brk;
procedure bvc;
procedure bvs;
procedure clc;
procedure cld;
procedure cli;
procedure clv;
procedure cmp;
procedure cpx;
procedure cpy;
procedure _dec;
procedure dex;
procedure dey;
procedure eor;
procedure _inc;
procedure inx;
procedure iny;
procedure jmp;
procedure jsr;
procedure lda;
procedure ldx;
procedure ldy;
procedure lsr;
procedure nop;
procedure ora;
procedure pha;
procedure php;
procedure pla;
procedure plp;
procedure rol;
procedure ror;
procedure rti;
procedure rts;
procedure sbc;
procedure sec;
procedure sed;
procedure sei;
procedure sta;
procedure stx;
procedure sty;
procedure tax;
procedure tay;
procedure tsx;
procedure txa;
procedure txs;
procedure tya;

//undocumented instructions
procedure lax;
procedure sax;
procedure dcp;
procedure isb;
procedure slo;
procedure rla;
procedure sre;
procedure rra;


procedure nmi6502;
procedure irq6502;

type
	callback =	procedure;

var
	callexternal: Byte = 0;
	loopexternal: callback;

procedure exec6502(tickcount: Cardinal);
procedure step6502;

procedure hookexternal(funcptr: callback);


implementation

const
	addrtable: addrtableprocs = (
(*        |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  A  |  B  |  C  |  D  |  E  |  F  |     *)
(* 0 *)     imp, indx,  imp, indx,   zp,   zp,   zp,   zp,  imp,  imm,  acc,  imm, abso, abso, abso, abso, (* 0 *)
(* 1 *)     rel, indy,  imp, indy,  zpx,  zpx,  zpx,  zpx,  imp, absy,  imp, absy, absx, absx, absx, absx, (* 1 *)
(* 2 *)    abso, indx,  imp, indx,   zp,   zp,   zp,   zp,  imp,  imm,  acc,  imm, abso, abso, abso, abso, (* 2 *)
(* 3 *)     rel, indy,  imp, indy,  zpx,  zpx,  zpx,  zpx,  imp, absy,  imp, absy, absx, absx, absx, absx, (* 3 *)
(* 4 *)     imp, indx,  imp, indx,   zp,   zp,   zp,   zp,  imp,  imm,  acc,  imm, abso, abso, abso, abso, (* 4 *)
(* 5 *)     rel, indy,  imp, indy,  zpx,  zpx,  zpx,  zpx,  imp, absy,  imp, absy, absx, absx, absx, absx, (* 5 *)
(* 6 *)     imp, indx,  imp, indx,   zp,   zp,   zp,   zp,  imp,  imm,  acc,  imm,  ind, abso, abso, abso, (* 6 *)
(* 7 *)     rel, indy,  imp, indy,  zpx,  zpx,  zpx,  zpx,  imp, absy,  imp, absy, absx, absx, absx, absx, (* 7 *)
(* 8 *)     imm, indx,  imm, indx,   zp,   zp,   zp,   zp,  imp,  imm,  imp,  imm, abso, abso, abso, abso, (* 8 *)
(* 9 *)     rel, indy,  imp, indy,  zpx,  zpx,  zpy,  zpy,  imp, absy,  imp, absy, absx, absx, absy, absy, (* 9 *)
(* A *)     imm, indx,  imm, indx,   zp,   zp,   zp,   zp,  imp,  imm,  imp,  imm, abso, abso, abso, abso, (* A *)
(* B *)     rel, indy,  imp, indy,  zpx,  zpx,  zpy,  zpy,  imp, absy,  imp, absy, absx, absx, absy, absy, (* B *)
(* C *)     imm, indx,  imm, indx,   zp,   zp,   zp,   zp,  imp,  imm,  imp,  imm, abso, abso, abso, abso, (* C *)
(* D *)     rel, indy,  imp, indy,  zpx,  zpx,  zpx,  zpx,  imp, absy,  imp, absy, absx, absx, absx, absx, (* D *)
(* E *)     imm, indx,  imm, indx,   zp,   zp,   zp,   zp,  imp,  imm,  imp,  imm, abso, abso, abso, abso, (* E *)
(* F *)     rel, indy,  imp, indy,  zpx,  zpx,  zpx,  zpx,  imp, absy,  imp, absy, absx, absx, absx, absx  (* F *)
);

	optable: optableprocs = (
(*        |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  A  |  B  |  C  |  D  |  E  |  F  |      *)
(* 0 *)      brk,  ora,  nop,  slo,  nop,  ora,  asl,  slo,  php,  ora,  asl,  nop,  nop,  ora,  asl,  slo, (* 0 *)
(* 1 *)      bpl,  ora,  nop,  slo,  nop,  ora,  asl,  slo,  clc,  ora,  nop,  slo,  nop,  ora,  asl,  slo, (* 1 *)
(* 2 *)      jsr, _and,  nop,  rla,  bit, _and,  rol,  rla,  plp, _and,  rol,  nop,  bit, _and,  rol,  rla, (* 2 *)
(* 3 *)      bmi, _and,  nop,  rla,  nop, _and,  rol,  rla,  sec, _and,  nop,  rla,  nop, _and,  rol,  rla, (* 3 *)
(* 4 *)      rti,  eor,  nop,  sre,  nop,  eor,  lsr,  sre,  pha,  eor,  lsr,  nop,  jmp,  eor,  lsr,  sre, (* 4 *)
(* 5 *)      bvc,  eor,  nop,  sre,  nop,  eor,  lsr,  sre,  cli,  eor,  nop,  sre,  nop,  eor,  lsr,  sre, (* 5 *)
(* 6 *)      rts,  adc,  nop,  rra,  nop,  adc,  ror,  rra,  pla,  adc,  ror,  nop,  jmp,  adc,  ror,  rra, (* 6 *)
(* 7 *)      bvs,  adc,  nop,  rra,  nop,  adc,  ror,  rra,  sei,  adc,  nop,  rra,  nop,  adc,  ror,  rra, (* 7 *)
(* 8 *)      nop,  sta,  nop,  sax,  sty,  sta,  stx,  sax,  dey,  nop,  txa,  nop,  sty,  sta,  stx,  sax, (* 8 *)
(* 9 *)      bcc,  sta,  nop,  nop,  sty,  sta,  stx,  sax,  tya,  sta,  txs,  nop,  nop,  sta,  nop,  nop, (* 9 *)
(* A *)      ldy,  lda,  ldx,  lax,  ldy,  lda,  ldx,  lax,  tay,  lda,  tax,  nop,  ldy,  lda,  ldx,  lax, (* A *)
(* B *)      bcs,  lda,  nop,  lax,  ldy,  lda,  ldx,  lax,  clv,  lda,  tsx,  lax,  ldy,  lda,  ldx,  lax, (* B *)
(* C *)      cpy,  cmp,  nop,  dcp,  cpy,  cmp, _dec,  dcp,  iny,  cmp,  dex,  nop,  cpy,  cmp, _dec,  dcp, (* C *)
(* D *)      bne,  cmp,  nop,  dcp,  nop,  cmp, _dec,  dcp,  cld,  cmp,  nop,  dcp,  nop,  cmp, _dec,  dcp, (* D *)
(* E *)      cpx,  sbc,  nop,  isb,  cpx,  sbc, _inc,  isb,  inx,  sbc,  nop,  sbc,  cpx,  sbc, _inc,  isb, (* E *)
(* F *)      beq,  sbc,  nop,  isb,  nop,  sbc, _inc,  isb,  sed,  sbc,  nop,  isb,  nop,  sbc, _inc,  isb  (* F *)
);

	ticktable: array[0..255] of Cardinal = (
(*        |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  A  |  B  |  C  |  D  |  E  |  F  |     *)
(* 0 *)      7,    6,    2,    8,    3,    3,    5,    5,    3,    2,    2,    2,    4,    4,    6,    6,  (* 0 *)
(* 1 *)      2,    5,    2,    8,    4,    4,    6,    6,    2,    4,    2,    7,    4,    4,    7,    7,  (* 1 *)
(* 2 *)      6,    6,    2,    8,    3,    3,    5,    5,    4,    2,    2,    2,    4,    4,    6,    6,  (* 2 *)
(* 3 *)      2,    5,    2,    8,    4,    4,    6,    6,    2,    4,    2,    7,    4,    4,    7,    7,  (* 3 *)
(* 4 *)      6,    6,    2,    8,    3,    3,    5,    5,    3,    2,    2,    2,    3,    4,    6,    6,  (* 4 *)
(* 5 *)      2,    5,    2,    8,    4,    4,    6,    6,    2,    4,    2,    7,    4,    4,    7,    7,  (* 5 *)
(* 6 *)      6,    6,    2,    8,    3,    3,    5,    5,    4,    2,    2,    2,    5,    4,    6,    6,  (* 6 *)
(* 7 *)      2,    5,    2,    8,    4,    4,    6,    6,    2,    4,    2,    7,    4,    4,    7,    7,  (* 7 *)
(* 8 *)      2,    6,    2,    6,    3,    3,    3,    3,    2,    2,    2,    2,    4,    4,    4,    4,  (* 8 *)
(* 9 *)      2,    6,    2,    6,    4,    4,    4,    4,    2,    5,    2,    5,    5,    5,    5,    5,  (* 9 *)
(* A *)      2,    6,    2,    6,    3,    3,    3,    3,    2,    2,    2,    2,    4,    4,    4,    4,  (* A *)
(* B *)      2,    5,    2,    5,    4,    4,    4,    4,    2,    4,    2,    4,    4,    4,    4,    4,  (* B *)
(* C *)      2,    6,    2,    8,    3,    3,    5,    5,    2,    2,    2,    2,    4,    4,    6,    6,  (* C *)
(* D *)      2,    5,    2,    8,    4,    4,    6,    6,    2,    4,    2,    7,    4,    4,    7,    7,  (* D *)
(* E *)      2,    6,    2,    8,    3,    3,    5,    5,    2,    2,    2,    2,    4,    4,    6,    6,  (* E *)
(* F *)      2,    5,    2,    8,    4,    4,    6,    6,    2,    4,    2,    7,    4,    4,    7,    7   (* F *)
);

procedure saveaccum(const n: Word);
	begin
	a:= n and $00FF;
	end;

procedure setcarry;
	begin
	status:= status or FLAG_CARRY;
	end;
	
procedure clearcarry;
	begin
	status:= status and not FLAG_CARRY;
	end;
	
procedure setzero;
	begin
	status:= status or FLAG_ZERO;
	end;
	
procedure clearzero;
	begin
	status:= status and not FLAG_ZERO;
	end;
	
procedure setinterrupt;
	begin
	status:= status or FLAG_INTERRUPT;
	end;
	
procedure clearinterrupt;
	begin
	status:= status and not FLAG_INTERRUPT;
	end;
	
procedure setdecimal;
	begin
	status:= status or FLAG_DECIMAL;
	end;
	
procedure cleardecimal;
	begin
	status:= status and not FLAG_DECIMAL;
	end;
	
procedure setoverflow;
	begin
	status:= status or FLAG_OVERFLOW;
	end;
	
procedure clearoverflow;
	begin
	status:= status and not FLAG_OVERFLOW;
	end;
	
procedure setsign;
	begin
	status:= status or FLAG_SIGN;
	end;
	
procedure clearsign;
	begin
	status:= status and not FLAG_SIGN;
	end;

procedure zerocalc(const n: Word);
	begin
	if  (n and $00FF) <> 0 then 
		clearzero
	else
		setzero;
	end;

procedure signcalc(const n: Word);
	begin
	if  (n and $0080) <> 0 then 
		setsign
	else
		clearsign;
	end;

procedure carrycalc(const n: Word);
	begin
	if  (n and $FF00) <> 0 then
		setcarry
	else
		clearcarry;
	end;

procedure overflowcalc(const n, m, o: Word);
	begin
//	n = result, m = accumulator, o = memory */ \
	if  (n xor m) and ((n xor o) and $0080) <> 0 then
		setoverflow
	else
		clearoverflow;
	end;

procedure push16(const pushval: Word);
	begin
	write6502(BASE_STACK + sp, (pushval shr 8) and $FF);
	write6502(BASE_STACK + ((sp - 1) and $FF), pushval and $FF);
	System.Dec(sp, 2);
	end;

procedure push8(const pushval: Byte);
	begin
	write6502(BASE_STACK + sp, pushval);
	System.Dec(sp);
	end;

function pull16: Word;
	begin
	Result:= read6502(BASE_STACK + ((sp + 1) and $FF)) or 
			(read6502(BASE_STACK + ((sp + 2) and $FF)) shl 8);
	System.Inc(sp, 2);
	end;

function pull8: Byte;
	begin
	System.Inc(sp);
	Result:= read6502(BASE_STACK + sp);
	end;

procedure reset6502;
	begin
	pc:= read6502($FFFC) or (read6502($FFFD) shl 8);
	a:= 0;
	x:= 0;
	y:= 0;
	sp:= $FD;
//***FIXME: dengland Should this be status:= FLAG_CONSTANT?
	status:= status or FLAG_CONSTANT;
	end;

procedure imp;
	begin
//implied
	end;

procedure acc;
	begin
//accumulator
	end;

procedure imm;
	begin
//immediate
	ea:= pc;
	System.Inc(pc)
	end;

procedure zp;
	begin
//zero-page
	ea:= read6502(pc);
	System.Inc(pc);
	end;

procedure zpx;
	begin
//zero-page,X
	ea:= (read6502(pc) + x) and $FF; //zero-page wraparound
	System.Inc(pc);
	end;

procedure zpy;
	begin
//zero-page,Y
	ea:= (read6502(pc) + y) and $FF; //zero-page wraparound
	System.Inc(pc);
	end;

procedure rel;
	begin
//relative for branch ops (8-bit immediate value, sign-extended)
	reladdr:= read6502(pc);
	System.Inc(pc);
	if  (reladdr and $80) <> 0 then
		reladdr:=  reladdr or $FF00;
	end;

procedure abso;
	begin
//absolute
	ea:= read6502(pc) or (read6502(pc+1) shl 8);
	System.Inc(pc, 2);
	end;

procedure absx;
	var
	startpage: Word;

	begin
//absolute,X
	ea:= read6502(pc) or (read6502(pc+1) shl 8);
	startpage:= ea and $FF00;
	ea:= ea + x;

	if  startpage <> (ea and $FF00) then
//		one cycle penlty for page-crossing on some opcodes
		penaltyaddr:= 1;

	System.Inc(pc, 2);
	end;

procedure absy;
	var
	startpage: Word;

	begin
//absolute,Y
	ea:= read6502(pc) or (read6502(pc+1) shl 8);
	startpage:= ea and $FF00;
	ea:= ea + y;

	if  startpage <> (ea and $FF00) then
//		one cycle penlty for page-crossing on some opcodes
		penaltyaddr:= 1;

	System.Inc(pc, 2);
	end;

procedure ind;
	var
	eahelp,
	eahelp2: Word;

	begin
//indirect
	eahelp:= read6502(pc) or (read6502(pc+1) shl 8);
//	replicate 6502 page-boundary wraparound bug
	eahelp2:= (eahelp and $FF00) or ((eahelp + 1) and $00FF);
	ea:= read6502(eahelp) or (read6502(eahelp2) shl 8);
	System.Inc(pc, 2);
	end;

procedure indx;
	var
	eahelp: Word;

	begin
// (indirect,X)
//	zero-page wraparound for table pointer
	eahelp:= (read6502(pc) + x) and $FF;
	System.Inc(pc);
	ea:= read6502(eahelp and $00FF) or (read6502((eahelp+1) and $00FF) shl 8);
	end;

procedure indy;
	var
	eahelp,
	eahelp2,
	startpage: Word;

	begin
// (indirect),Y
	eahelp:= read6502(pc);
	System.Inc(pc);
//	zero-page wraparound
	eahelp2:= (eahelp and $FF00) or ((eahelp + 1) and $00FF);
	ea:= read6502(eahelp) or (read6502(eahelp2) shl 8);
	startpage:= ea and $FF00;
	ea:=  ea + y;

	if  startpage <> (ea and $FF00) then
//		one cycle penlty for page-crossing on some opcodes
		penaltyaddr:= 1;
	end;

function getvalue: Word;
	begin
	if  @addrtable[opcode] = @acc then
		Result:= a
	else
		Result:= read6502(ea);
	end;

function getvalue16: Word;
	begin
	Result:= read6502(ea) or (read6502(ea+1) shl 8);
	end;

procedure putvalue(const saveval: Word);
	begin
	if  @addrtable[opcode] = @acc then
		a:= (saveval and $00FF)
	else
		write6502(ea, (saveval and $00FF));
	end;

procedure adc;
	begin
	penaltyop:= 1;
	value:= getvalue;
	_result:= a + value + (status and FLAG_CARRY);

	carrycalc(_result);
	zerocalc(_result);
	overflowcalc(_result, a, value);
	signcalc(_result);

{$IFNDEF NES_CPU}
	if  (status and FLAG_DECIMAL) <> 0 then
		begin
		clearcarry();

		if  (a and $0F) > $09 then
			a:= a + $06;

		if  (a and $F0) > $90 then
			begin
			a:= a + $60;
			setcarry();
			end;

		System.Inc(clockticks6502);
		end;
{$ENDIF}

	saveaccum(_result);
	end;

procedure _and;
	begin
	penaltyop:= 1;
	value:= getvalue;
	_result:= a and value;

	zerocalc(_result);
	signcalc(_result);

	saveaccum(_result);
	end;

procedure asl;
	begin
	value:= getvalue;
	_result:= value shl 1;

	carrycalc(_result);
	zerocalc(_result);
	signcalc(_result);
   
	putvalue(_result);
	end;

procedure bcc;
	begin
	if  (status and FLAG_CARRY) = 0 then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end;
	end;

procedure bcs;
	begin
	if  (status and FLAG_CARRY) = FLAG_CARRY then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end;
	end;

procedure beq;
	begin
	if  (status and FLAG_ZERO) = FLAG_ZERO then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end
	end;

procedure bit;
	begin
	value:= getvalue();
	_result:= a and value;

	zerocalc(_result);
	status:= (status and $3F) or (value and $C0);
//	if  (value and $80) <> 0 then
//		setsign
//	else
//		clearsign;
//
//	if  (value and $40) <> 0 then
//		setoverflow
//	else
//		clearoverflow;
	end;

procedure bmi;
	begin
	if  (status and FLAG_SIGN) = FLAG_SIGN then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end;
	end;

procedure bne;
	begin
	if  (status and FLAG_ZERO) = 0 then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end;
	end;

procedure bpl;
	begin
	if  (status and FLAG_SIGN) = 0 then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end;
	end;

procedure brk;
	begin
	System.Inc(pc);
	push16(pc); //push next instruction address onto stack
	push8(status or FLAG_BREAK); //push CPU status to stack
	setinterrupt(); //set interrupt flag
	pc:= read6502($FFFE) or (read6502($FFFF) shl 8);
	end;

procedure bvc;
	begin
	if  (status and FLAG_OVERFLOW) = 0 then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end;
	end;

procedure bvs;
	begin
	if  (status and FLAG_OVERFLOW) = FLAG_OVERFLOW then
		begin
		oldpc:= pc;
		pc:= pc + reladdr;
		if  (oldpc and $FF00) <> (pc and $FF00) then
//			check if jump crossed a page boundary
			System.Inc(clockticks6502, 2)
		else
			System.Inc(clockticks6502);
		end;
	end;

procedure clc;
	begin
	clearcarry;
	end;

procedure cld;
	begin
	cleardecimal;
	end;

procedure cli;
	begin
    clearinterrupt;
	end;

procedure clv;
	begin
    clearoverflow;
	end;

procedure cmp;
	begin
    penaltyop:= 1;
    value:= getvalue;
    _result:= a - value;
   
    if  a >= (value and $00FF) then
		setcarry
	else 
		clearcarry;
	
    if  a = (value and $00FF) then
		setzero
	else 
		clearzero;
	
    signcalc(_result);
	end;
	
procedure cpx;
	begin
    value:= getvalue;
    _result:= x - value;
   
    if  x >= (value and $00FF) then
		setcarry
	else 
		clearcarry;
	
    if  x = (value and $00FF) then 
		setzero
	else 
		clearzero;
	
    signcalc(_result);
	end;

procedure cpy;
	begin
    value:= getvalue;
    _result:= y - value;
   
    if  y >= (value and $00FF) then
		setcarry
	else 
		clearcarry;
	
    if  y = (value and $00FF) then 
		setzero
	else 
		clearzero;
	
    signcalc(_result);
	end;

procedure _dec;
	begin
	value:= getvalue;
	_result:= value - 1;

	zerocalc(_result);
	signcalc(_result);

	putvalue(_result);
	end;

procedure dex;
	begin
	System.Dec(x);

	zerocalc(x);
	signcalc(x);
	end;

procedure dey;
	begin
	System.Dec(y);

	zerocalc(y);
	signcalc(y);
	end;

procedure eor;
	begin
	penaltyop:= 1;
	value:= getvalue;
	_result:= a xor value;

	zerocalc(_result);
	signcalc(_result);

	saveaccum(_result);
	end;

procedure _inc;
	begin
	value:= getvalue;
	_result:= value + 1;

	zerocalc(_result);
	signcalc(_result);

	putvalue(_result);
	end;

procedure inx;
	begin
	System.Inc(x);

	zerocalc(x);
	signcalc(x);
	end;

procedure iny;
	begin
	System.Inc(y);

	zerocalc(y);
	signcalc(y);
	end;

procedure jmp;
	begin
	pc:= ea;
	end;

procedure jsr;
	begin
	push16(pc - 1);
    pc:= ea;
	end;

procedure lda;
	begin
    penaltyop:= 1;
    value:= getvalue;
    a:= value and $00FF;
   
    zerocalc(a);
    signcalc(a);
	end;

procedure ldx;
	begin
    penaltyop:= 1;
    value:= getvalue;
    x:= value and $00FF;
   
    zerocalc(x);
    signcalc(x);
	end;
	
procedure ldy;
	begin
    penaltyop:= 1;
    value:= getvalue;
    y:= value and $00FF;
   
    zerocalc(y);
    signcalc(y);
	end;

procedure lsr;
	begin
    value:= getvalue;
    _result:= value shr 1;
   
    if  (value and 1) <> 0 then 
		setcarry
	else 
		clearcarry;
	
    zerocalc(_result);
    signcalc(_result);
   
    putvalue(_result);
	end;

procedure nop;
    begin
	case opcode of
        $1C, $3C, $5C, $7C, $DC, $FC:
            penaltyop:= 1;
		end;
	end;
	
procedure ora;
	begin
    penaltyop:= 1;
    value:= getvalue;
    _result:= a or value;
   
    zerocalc(_result);
    signcalc(_result);
   
    saveaccum(_result);
	end;

procedure pha;
    begin
	push8(a);
	end;

procedure php;
	begin
//***dengland Huh?  Always break???
    push8(status or FLAG_BREAK);
	end;

procedure pla;
	begin
    a:= pull8;
   
    zerocalc(a);
    signcalc(a);
	end;

procedure plp;
	begin
    status:= pull8 or FLAG_CONSTANT;
	end;

procedure rol;
	begin
    value:= getvalue;
    _result:= (value shl 1) or (status and FLAG_CARRY);
   
    carrycalc(_result);
    zerocalc(_result);
    signcalc(_result);
   
    putvalue(_result);
	end;

procedure ror;
	begin
    value:= getvalue;
    _result:= (value shr 1) or ((status and FLAG_CARRY) shl 7);
   
    if  (value and 1) <> 0 then 
		setcarry
	else 
		clearcarry;
	
    zerocalc(_result);
    signcalc(_result);
   
    putvalue(_result);
	end;

procedure rti;
	begin
    status:= pull8;
    value:= pull16;
    pc:= value;
	end;

procedure rts;
	begin
    value:= pull16;
    pc:= value + 1;
	end;

procedure sbc;
	begin
    penaltyop:= 1;
    value:= getvalue xor $00FF;
    _result:= a + value + (status and FLAG_CARRY);
   
    carrycalc(_result);
    zerocalc(_result);
    overflowcalc(_result, a, value);
    signcalc(_result);

{$IFNDEF NES_CPU}
    if  (status and FLAG_DECIMAL) <> 0 then
        begin
		clearcarry;
        
        a:= a - $66;
        if  (a and $0F) > $09 then
            a:=  a + $06;
        
        if  (a and $F0) > $90 then
			begin
            a:= a + $60;
            setcarry;
			end;
                
		System.Inc(clockticks6502);
		end;
{$ENDIF}

	saveaccum(_result);
	end;

procedure sec;
	begin
	setcarry;
	end;

procedure sed;
	begin
	setdecimal;
	end;

procedure sei;
	begin
    setinterrupt;
	end;

procedure sta;
	begin
    putvalue(a);
	end;

procedure stx;
	begin
    putvalue(x);
	end;

procedure sty;
	begin
    putvalue(y);
	end;

procedure tax;
	begin
    x:= a;
   
    zerocalc(x);
    signcalc(x);
	end;

procedure tay;
	begin
    y:= a;
   
    zerocalc(y);
    signcalc(y);
	end;

procedure tsx;
	begin
    x:= sp;
   
    zerocalc(x);
    signcalc(x);
	end;

procedure txa;
	begin
    a:= x;
   
    zerocalc(a);
    signcalc(a);
	end;

procedure txs;
	begin
    sp:= x;
	end;

procedure tya;
	begin
    a:= y;
   
    zerocalc(a);
    signcalc(a);
	end;

procedure lax;
	begin
	lda;
    ldx;
    end;

procedure sax;
	begin
	sta;
	stx;
	putvalue(a and x);
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Dec(clockticks6502);
	end;

procedure dcp;
	begin
	_dec;
	cmp;
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Dec(clockticks6502);
	end;

procedure isb;
	begin
	_inc;
	sbc;
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Dec(clockticks6502);
	end;

procedure slo;
	begin
	asl;
	ora;
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Dec(clockticks6502);
	end;

procedure rla;
	begin
	rol;
	_and;
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Dec(clockticks6502);
	end;

procedure sre;
	begin
	lsr;
	eor;
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Dec(clockticks6502);
	end;

procedure rra;
	begin
	ror;
	adc;
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Dec(clockticks6502);
	end;

procedure nmi6502;
	begin
    push16(pc);
    push8(status);
    status:= status or FLAG_INTERRUPT;
    pc:= read6502($FFFA) or (read6502($FFFB) shl 8);
	end;

procedure irq6502;
	begin
    push16(pc);
    push8(status);
    status:= status or FLAG_INTERRUPT;
    pc:= read6502($FFFE) or (read6502($FFFF) shl 8);
	end;

procedure exec6502(tickcount: Cardinal);
	begin
	System.Inc(clockgoal6502, tickcount);

	while clockticks6502 < clockgoal6502 do
		begin
		opcode:= read6502(pc);
		System.Inc(pc);
		status:= status or FLAG_CONSTANT;

		penaltyop:= 0;
		penaltyaddr:= 0;

		addrtable[opcode];
		optable[opcode];
		clockticks6502:= clockticks6502 + ticktable[opcode];
		if  (penaltyop = 1)
		and (penaltyaddr = 1) then
			System.Inc(clockticks6502);

		System.Inc(instructions);

		if  callexternal <> 0 then
			loopexternal;
		end;
	end;

procedure step6502;
	begin
	opcode:= read6502(pc);
	System.Inc(pc);
	status:= status or FLAG_CONSTANT;

	penaltyop:= 0;
	penaltyaddr:= 0;

	addrtable[opcode];
	optable[opcode];
	clockticks6502:= clockticks6502 + ticktable[opcode];
	if  (penaltyop = 1)
	and (penaltyaddr = 1) then
		System.Inc(clockticks6502);

	clockgoal6502:= clockticks6502;

	System.Inc(instructions);

	if  callexternal <> 0 then
		loopexternal;
	end;

procedure hookexternal(funcptr: callback);
	begin
    if  Assigned(funcptr) then
		begin
        loopexternal:= funcptr;
        callexternal:= 1;
		end
    else 
		callexternal:= 0;
	end;

	
end.
