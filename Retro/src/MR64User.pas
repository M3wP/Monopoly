unit MR64User;

interface

uses
	C64Classes;

type
	TMR64USERIO = class
	private
		FBuffer: TC64UserBuffer;

	public
		constructor Create(ABuffer: TC64UserBuffer);

		procedure Write(const AAddress: Word; const AValue: Byte);
		function  Read(const AAddress: Word): Byte;
	end;


implementation

{ TC64USERIO }

constructor TMR64USERIO.Create(ABuffer: TC64UserBuffer);
	begin
	FBuffer:= ABuffer;
	end;

function TMR64USERIO.Read(const AAddress: Word): Byte;
	var
	r: Word;

	begin
	r:= AAddress and $00FF;
	case r of
		$00:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= Ord(FBuffer.FKey);
				FBuffer.FKey:= #0;

				finally
				FBuffer.FLock.Release;
				end;
			end;
//		$01:    Reserved
		$02:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= FBuffer.FJoy;

				finally
				FBuffer.FLock.Release;
				end;
			end;
		$03:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= FBuffer.FMouseX and $00FF;

				finally
				FBuffer.FLock.Release;
				end;
			end;
		$04:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= (FBuffer.FMouseX and $FF00) shr 8;

				finally
				FBuffer.FLock.Release;
				end;
			end;
		$05:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= FBuffer.FMouseY and $00FF;

				finally
				FBuffer.FLock.Release;
				end;
			end;
		$06:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= (FBuffer.FMouseY and $FF00) shr 8;

				finally
				FBuffer.FLock.Release;
				end;
			end;
		$07:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= FBuffer.FMouseBtn;

				finally
				FBuffer.FLock.Release;
				end;
			end;
		$08:
			begin
			FBuffer.FLock.Acquire;
			try
				Result:= FBuffer.FMouseVis;

				finally
				FBuffer.FLock.Release;
				end;
			end;
		else
			Result:= 0;
		end;
	end;

procedure TMR64USERIO.Write(const AAddress: Word; const AValue: Byte);
	begin

	end;

end.
