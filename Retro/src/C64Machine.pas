unit C64Machine;

interface

uses
	Messages, Classes, SyncObjs, C64Types, C64Classes, C64Thread,
	C64MachineConfig, C64Video, XSIDTypes, C64SID, C64VICII, MR64USER, MR64Board;

type
	TC64MultiOutput = class(TObject)
		FVideoBuffer: TC64VideoBuffer;
		FAudioBuffer: TC64AudioBuffer;

		constructor Create;
		destructor  Destroy; override;
	end;

	TC64MultiInput = class(TObject)
		FUserBuffer: TC64UserBuffer;

		constructor Create;
		destructor  Destroy; override;
	end;

	TC64Machine = class(TC64SystemThread)
	protected
		FIniFile: string;

		procedure DoConstruction; override;
		procedure DoDestruction; override;
		procedure DoClock(const ATicks: Cardinal); override;
		procedure DoPause; override;
		procedure DoPlay; override;

	public
		FConfig: TC64MachineConfig;
		FMultiOut: TC64MultiOutput;
		FMultiIn: TC64MultiInput;

		FSID: TC64SID;
		FSIDIO: TC64SIDIO;

		FUSERIO: TMR64USERIO;
		FBoardIO: TMR64BoardIIO;

		FVICIIFrame: TC64VICIIFrame;
		FVICIIRaster: TC64VICIIRaster;
		FVICIIBadLine: TC64VICIIBadLine;
		FVICIIIO: TC64VICIIIO;

		constructor Create(const AConfig: TC64MachineConfig);
		destructor  Destroy; override;
	end;

var
	C64MachineGlobal: TC64Machine;


implementation

uses
	Windows, SysUtils, IniFiles, Forms, C64Memory, C64CPU;

{ TC64MultiOutput }

constructor TC64MultiOutput.Create;
	begin
	inherited;

	FVideoBuffer:= TC64VideoBuffer.Create;
	FAudioBuffer:= TC64AudioBuffer.Create;
	end;

destructor TC64MultiOutput.Destroy;
	begin
	FAudioBuffer.Free;
	FVideoBuffer.Free;

	inherited;
	end;


{ TC64Machine }

constructor TC64Machine.Create(const AConfig: TC64MachineConfig);
	begin
	Assert(not Assigned(C64MachineGlobal));

	read6502:= ReadMemory;
	write6502:= WriteMemory;

	reset6502;

	C64MachineGlobal:= Self;

//	FIniFile:= AIniFile;
//	InitialiseConfig(AIniFile);
	FConfig:= AConfig;

	XSIDInitialiseConfig(FConfig.IniFile);

	FConfig.Lock;
	try
		FConfig.System:= cstPAL;

		finally
		FConfig.Unlock;
		end;

	FMultiOut:= TC64MultiOutput.Create;
	FMultiIn:= TC64MultiInput.Create;

	FSID:= TC64SID.Create(FMultiOut.FAudioBuffer);
	FSIDIO:= TC64SIDIO.Create(FSID);

	FVICIIFrame:= TC64VICIIFrame.Create(FMultiOut.FVideoBuffer);
	FVICIIRaster:= TC64VICIIRaster.Create(FMultiOut.FVideoBuffer);
	FVICIIBadLine:= TC64VICIIBadLine.Create(FMultiOut.FVideoBuffer);
	FVICIIIO:= TC64VICIIIO.Create;

	FUSERIO:= TMR64USERIO.Create(FMultiIn.FUserBuffer);
	FBoardIO:= TMR64BoardIIO.Create;

	GlobalC64Memory.AddIO($D400, $D7FF, FSIDIO.Read, FSIDIO.Write);
	GlobalC64Memory.AddIO($D000, $D3FF, FVICIIIO.Read, FVICIIIO.Write);
	GlobalC64Memory.AddIO($DE00, $DEFF, FUSERIO.Read, FUSERIO.Write);
	GlobalC64Memory.AddIO($DF00, $DFFF, FBoardIO.Read, FBoardIO.Write);

	GlobalC64Memory.Write($D021, $06);

	inherited Create(FConfig.System);

	FreeOnTerminate:= False;
	end;

destructor TC64Machine.Destroy;
	begin
	inherited;
	end;


procedure TC64Machine.DoClock(const ATicks: Cardinal);
	var
	actual: Cardinal;
	diff: Integer;
	bad: Word;

	begin
	if  FMultiOut.FVideoBuffer.FRaster = 0 then
		begin
		FMultiOut.FVideoBuffer.FBADLine:= $FF;
		FVICIIFrame.RunSignal.SetEvent;
		end
//	else if FMultiOut.FVideoBuffer.FRaster = 8 then
//		FVICIIFrame.DoneSignal.WaitFor(INFINITE)
	else if (FMultiOut.FVideoBuffer.FRaster >= 51) and
			(FMultiOut.FVideoBuffer.FRaster <= 250) then
		begin
		bad:= (FMultiOut.FVideoBuffer.FRaster - 51) div 8;
		if  bad <> FMultiOut.FVideoBuffer.FBADLine then
			begin
			FVICIIBadLine.DoneSignal.WaitFor(INFINITE);
			FMultiOut.FVideoBuffer.FBADLine:= bad;
			FVICIIBadLine.FRaster:= FMultiOut.FVideoBuffer.FRaster;
			FVICIIBadLine.RunSignal.SetEvent;
			end;
		end;

	C64GlobalVICIIRegs.rasterY:= FMultiOut.FVideoBuffer.FRaster;
	C64GlobalVICIIRegs.rasterIRQSrc:= False;

	if  C64GlobalVICIIRegs.rasterIRQ
	and (C64GlobalVICIIRegs.rasterY = C64GlobalVICIIRegs.rasterIRQY) then
		begin
		C64GlobalVICIIRegs.rasterIRQSrc:= True;
		irq6502;
		end;

	FVICIIRaster.RunSignal.SetEvent;

	lastticks6502:= clockticks6502;

	FSIDIO.FirstTick:= lastticks6502;

	exec6502(ATicks);
	actual:= clockticks6502 - lastticks6502;
	diff:= actual - ATicks;
	if  diff > 0 then
		ExtendClock(diff);

	FSID.Clock(actual);

	FVICIIRaster.DoneSignal.WaitFor(INFINITE);

	if  FMultiOut.FVideoBuffer.FRaster = 311 then
		begin
		FVICIIBadLine.DoneSignal.WaitFor(INFINITE);
		FVICIIFrame.DoneSignal.WaitFor(INFINITE);

		FMultiOut.FVideoBuffer.FRaster:= 0;
		FMultiOut.FVideoBuffer.SignalHigh;
		end
	else
		Inc(FMultiOut.FVideoBuffer.FRaster);
	end;

procedure TC64Machine.DoConstruction;
	begin
	NameThreadForDebugging('C64 Machine');
	end;

procedure TC64Machine.DoDestruction;
	begin
	FVICIIRaster.RunSignal.ResetEvent;
	FVICIIRaster.Terminate;
	FVICIIBadLine.RunSignal.ResetEvent;
	FVICIIBadLine.Terminate;
	FVICIIFrame.RunSignal.ResetEvent;
	FVICIIFrame.Terminate;

	FMultiOut.Free;
	FMultiIn.Free;

//	FinaliseConfig(FIniFile);
	end;

procedure TC64Machine.DoPause;
	begin
	FMultiOut.FAudioBuffer.FRenderer.Pause(FMultiOut.FAudioBuffer.FBuffer);
	FConfig.Started:= False;
	end;

procedure TC64Machine.DoPlay;
	begin
	FMultiOut.FAudioBuffer.FRenderer.Play(FMultiOut.FAudioBuffer.FBuffer);
	FConfig.Started:= True;
	end;


{ TC64MultiInput }

constructor TC64MultiInput.Create;
	begin
	FUserBuffer:= TC64UserBuffer.Create;
	end;

destructor TC64MultiInput.Destroy;
	begin
	FUserBuffer.Free;

	inherited;
	end;

end.
