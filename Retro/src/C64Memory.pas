unit C64Memory;

interface

uses
	System.Generics.Collections;

type
	TC64MemoryRead = function(const AAddress: Word): Byte of object;
	TC64MemoryWrite = procedure(const AAddress: Word; const AValue: Byte) of object;

	TC64MemoryIO = packed record
		AStart,
		AEnd: Word;
		ARead: TC64MemoryRead;
		AWrite: TC64MemoryWrite;
	end;

	TC64Memory = class
	private
		FIO: TList<TC64MemoryIO>;

	public
		FRAM: array[0..$FFFF] of Byte;

		constructor Create;
		destructor Destroy; override;

		function  AddIO(const AStart, AEnd: Word; const ARead: TC64MemoryRead;
				const AWrite: TC64MemoryWrite): Integer;
		procedure RemoveIO(AIndex: Integer);

		procedure Write(const AAddress: Word; const AValue: Byte);
		function  Read(const AAddress: Word): Byte;
		procedure Load(const AAddress: Word; const AFile: string;
				const AUsePrgAddr: Boolean = False);
	end;

var
	GlobalC64Memory: TC64Memory;

function ReadMemory(AAddress: Word): Byte;
procedure WriteMemory(AAddress: Word; AValue: Byte);

implementation

uses
	Windows, Classes;

function ReadMemory(AAddress: Word): Byte;
	begin
	Result:= GlobalC64Memory.Read(AAddress);
	end;

procedure WriteMemory(AAddress: Word; AValue: Byte);
	begin
	GlobalC64Memory.Write(AAddress, AValue);
	end;


{ TC64Memory }

function TC64Memory.AddIO(const AStart, AEnd: Word; const ARead: TC64MemoryRead;
		const AWrite: TC64MemoryWrite): Integer;
	var
	io: TC64MemoryIO;

	begin
	io.AStart:= AStart;
	io.AEnd:= AEnd;
	io.ARead:= ARead;
	io.AWrite:= AWrite;

	Result:= FIO.Add(io);
	end;

constructor TC64Memory.Create;
	begin
	inherited Create;

	FIO:= TList<TC64MemoryIO>.Create;

	end;

destructor TC64Memory.Destroy;
	begin
	FIO.Free;

	inherited;
	end;

procedure TC64Memory.Load(const AAddress: Word; const AFile: string;
		const AUsePrgAddr: Boolean);
	var
	a: Word;
	b: Byte;
	f: TMemoryStream;

	begin
	a:= AAddress;
	f:= TMemoryStream.Create;
	try
		f.LoadFromFile(AFile);
		f.Position:= 0;

		if  AUsePrgAddr then
			begin
			f.ReadData(b, 1);
			a:= b;
			f.ReadData(b, 1);
			a:= a or (b shl 8);
			end;

		while f.Position < f.Size do
			begin
			f.ReadData(b, 1);
			Write(a, b);
			Inc(a);
			end;

		finally
		f.Free;
		end;
	end;

function TC64Memory.Read(const AAddress: Word): Byte;
	var
	i: Integer;

	begin
	for i:= 0 to FIO.Count - 1 do
		if  (AAddress >= FIO[i].AStart)
		and (AAddress <= FIO[i].AEnd) then
			begin
			Result:= FIO[i].ARead(AAddress);
			Exit;
			end;

	Result:= FRAM[AAddress];
	end;

procedure TC64Memory.RemoveIO(AIndex: Integer);
	begin
    FIO.Delete(AIndex);
	end;

procedure TC64Memory.Write(const AAddress: Word; const AValue: Byte);
	var
	i: Integer;

	begin
	for i:= 0 to FIO.Count - 1 do
		if  (AAddress >= FIO[i].AStart)
		and (AAddress <= FIO[i].AEnd) then
			begin
			FIO[i].AWrite(AAddress, AValue);
			Exit;
			end;

	FRAM[AAddress]:= AValue;
	end;

initialization
	GlobalC64Memory:= TC64Memory.Create;

finalization
	GlobalC64Memory.Free;

end.
