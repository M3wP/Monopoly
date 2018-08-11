unit C64Classes;

interface

uses
	Classes, SyncObjs, C64Video, XSIDTypes, MR64Board;

type
	TC64Phi2AECState = (cp2Avaliable, cp2NotReady, cp2NotAvailable);

	TC64LineSignal = class(TObject)
		FState: Boolean;
		FLock: TCriticalSection;

		constructor Create; virtual;
		destructor  Destroy; override;

		procedure SignalHigh; virtual;
		procedure SignalLow; virtual;
	end;

	TC64LineSignalClass = class of TC64LineSignal;

	TC64LineDriver = class(TC64LineSignal)
	private
		FList: TList;

	public
		FProcessed: TCountdownEvent;

		constructor Create; override;
		destructor  Destroy; override;

		procedure Connect(ALine: TC64LineSignal);
		procedure Disconnect(ALine: TC64LineSignal);

		procedure SignalHigh; override;
		procedure SignalLow; override;
	end;


	TC64VideoBuffer = class(TC64LineSignal)
		FProcessed: TLightweightEvent;

		FBufferIdx: Byte;

		FBGBuf: array [0..1] of TC64PALScreen;
		FBG: PC64PALScreen;

		FBRBuf: array [0..1] of TMR64Board;
		FBR: PMR64Board;

		FBPBuf: array [0..1] of TMR64Board;
		FBP: PMR64Board;

		FFGBuf: array [0..1] of TC64PALScreen;
		FFG: PC64PALScreen;

		FSPBuf: array [0..1] of TC64PALScreen;
		FSP: PC64PALScreen;

		FFrameCnt: Cardinal;
		FFrameDone: Boolean;
		FVICIILastCPU: Cardinal;

		FRaster: Word;
		FBADLine: Word;

		constructor Create; override;

		procedure SignalHigh; override;
	end;

	TC64AudioBuffer = class(TC64LineSignal)
		FBuf: array[0..15] of SmallInt;
		FBufIdx: Integer;
		FBuffer: PArrSmallInt;

		FRenderer: TXSIDAudioRenderer;

		FSIDLastCPU: Cardinal;

		constructor Create; override;
		destructor Destroy; override;

		procedure SignalHigh; override;
	end;

	TC64UserBuffer = class(TC64LineSignal)
		FKey: AnsiChar;
		FJoy: Byte;
		FMouseX,
		FMouseY: Word;
		FMouseBtn: Byte;
		FMouseVis: Byte;
	end;

implementation

uses
	Types, C64Types, Forms, Windows;

{ TC64LineDriver }

constructor TC64LineDriver.Create;
	begin
	inherited;

	FList:= TList.Create;
	FProcessed:= TCountdownEvent.Create;
	FProcessed.Reset(0);
	end;

destructor TC64LineDriver.Destroy;
//	var
//	i: Integer;
//	c: PC64Clock;

	begin
//	for i:= FList.Count - 1 downto 0 do
//		begin
//		c:= PC64Clock(FList[i]);
//
//		Assert(c^.FReady.WaitFor(INFINITE) = wrSignaled,
//				'Clock could not be freed by driver');
//
//		c^.Free;
//		end;

	FList.Free;

	FProcessed.Free;

	inherited;
	end;

procedure TC64LineDriver.SignalHigh;
	var
	i: Integer;
	l: TC64LineSignal;

	begin
	FProcessed.Reset(FList.Count);

	FLock.Acquire;
	try
		for i:= 0 to FList.Count - 1 do
			begin
			l:= TC64LineSignal(FList[i]);
			l.SignalHigh;
			end;

		finally
		FLock.Release;
		end;
	end;

procedure TC64LineDriver.SignalLow;
	var
	i: Integer;
	l: TC64LineSignal;

	begin
	FLock.Acquire;
	try
		for i:= 0 to FList.Count - 1 do
			begin
			l:= TC64LineSignal(FList[i]);
			l.SignalLow;
			end;
		finally
		FLock.Release;
		end;

	FProcessed.Reset(0);
	end;

procedure TC64LineDriver.Connect(ALine: TC64LineSignal);
	begin
	FLock.Acquire;
	try
		if  FList.IndexOf(ALine) = -1 then
			FList.Add(ALine);

		finally
		FLock.Release;
		end;
	end;

procedure TC64LineDriver.Disconnect(ALine: TC64LineSignal);
	begin
	FLock.Acquire;
	try
		Assert(FList.IndexOf(ALine) <> -1, 'Failed to find line connection');
		FList.Remove(ALine);

		finally
		FLock.Release;
		end;
	end;

{ TC64LineSignal }

constructor TC64LineSignal.Create;
	begin
	inherited;

	FLock:= TCriticalSection.Create;
	FState:= False;
	end;

destructor TC64LineSignal.Destroy;
	begin
	FLock.Free;

	inherited;
	end;

procedure TC64LineSignal.SignalHigh;
	begin
	FLock.Acquire;
	try
		FState:= True;

		finally
		FLock.Release;
		end;
	end;

procedure TC64LineSignal.SignalLow;
	begin
	FLock.Acquire;
	try
		FState:= False;

		finally
		FLock.Release;
		end;
	end;


{ TC64VideoBuffer }

constructor TC64VideoBuffer.Create;
	begin
	inherited;
	FProcessed:= TLightweightEvent.Create;
	FProcessed.ResetEvent;

	FBufferIdx:= 0;
	FBG:= @FBGBuf[FBufferIdx];
	FBR:= @FBRBuf[FBufferIdx];
	FBP:= @FBPBuf[FBufferIdx];
	FFG:= @FFGBuf[FBufferIdx];
	FSP:= @FSPBuf[FBufferIdx];

	FFrameDone:= False;
	FFrameCnt:= 0;
	end;

procedure TC64VideoBuffer.SignalHigh;
	begin
	FLock.Acquire;
	try
		FBufferIdx:= FBufferIdx xor 1;
		FBG:= @FBGBuf[FBufferIdx];
		FBR:= @FBRBuf[FBufferIdx];
		FBP:= @FBPBuf[FBufferIdx];
		FFG:= @FFGBuf[FBufferIdx];
		FSP:= @FSPBuf[FBufferIdx];
		Inc(FFrameCnt);
		FFrameDone:= True;

		finally
		FLock.Release;
		end;

//	FProcessed.SetEvent;
	PostMessage(Application.MainForm.Handle, MSG_C64MACH_UPDATEVIDEO, 0, 0);
	end;

{ TC64AudioBuffer }

constructor TC64AudioBuffer.Create;
	begin
	inherited;

//	FAudioIdx:= 0;
//	FAudio:= @FAudioBuf[FAudioIdx];
//	FAudioPending:= 0;
//	FAudioSamples:= 0;
	end;

destructor TC64AudioBuffer.Destroy;
	begin
	if Assigned(FRenderer) then
		FRenderer.Free;

	inherited;
	end;


procedure TC64AudioBuffer.SignalHigh;
	begin
//	FLock.Acquire;
//	try
//		FAudio:= @FAudioBuf[FAudioIdx];
//		FAudioIdx:= FAudioIdx xor 1;
//		FAudioPending:= FAudioSamples;
//		FAudioSamples:= 0;
//
//		finally
//		FLock.Release;
//		end;

//	PostMessage(Application.MainForm.Handle, MSG_C64MACH_UPDATEAUDIO, 0, 0);
	end;


end.
