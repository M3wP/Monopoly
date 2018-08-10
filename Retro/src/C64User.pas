unit C64User;

interface

uses
	C64Classes;

type
	TC64USERIO = class
	private
		FBuffer: TC64UserBuffer;

	public
		constructor Create(ABuffer: TC64UserBuffer);

		procedure Write(const AAddress: Word; const AValue: Byte);
		function  Read(const AAddress: Word): Byte;
	end;


implementation

{ TC64USERIO }

constructor TC64USERIO.Create(ABuffer: TC64UserBuffer);
	begin
	FBuffer:= ABuffer;
	end;

function TC64USERIO.Read(const AAddress: Word): Byte;
	var
	r: Word;

	begin
	r:= AAddress and $00FF;
	case r of
		$00:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= FBuffer.FKey;
				FBuffer.FKey:= 0;

				finally
				FBuffer.FLock.Release;
				end;
            end;
		end;
	end;

procedure TC64USERIO.Write(const AAddress: Word; const AValue: Byte);
	begin

	end;

end.
