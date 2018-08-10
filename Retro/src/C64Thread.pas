unit C64Thread;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
{$H+}

interface

uses
	Classes, SyncObjs, C64Types;

type
{ TC64SystemThread }

	TC64SystemThread = class(TThread)
	protected
//		FLock: TCriticalSection;
		FRunSignal: TSimpleEvent;
		FPausedSignal: TSimpleEvent;

		FWasPaused: Boolean;

		FCycPSec: Cardinal;
		FIntrval: Double;

		FCycPUpd: TC64CycCnt;
		FCycResidual: Integer;

		FRefreshCnt: Integer;
		FRefreshUpd: Integer;
		FCycRefresh: Cardinal;

		FThsDiff,
		FLstIntrv,
		FThsIntrv: Double;

		FName: string;
		FFreeRun: Boolean;

		procedure DoConstruction; virtual; abstract;
		procedure DoDestruction; virtual; abstract;
		procedure DoClock(const ATicks: Cardinal); virtual; abstract;
		procedure DoPause; virtual; abstract;
		procedure DoPlay; virtual; abstract;

		procedure UpdateFrontEnd(const ATicks: Cardinal); virtual;

		procedure Execute; override;
        procedure ExtendClock(const ATicks: Cardinal);

	public
		constructor Create(const ASystemType: TC64SystemType);
		destructor  Destroy; override;

		property  RunSignal: TSimpleEvent read FRunSignal;
		property  PausedSignal: TSimpleEvent read FPausedSignal;

//		procedure Lock;
//		procedure Unlock;
	end;


implementation

uses
	SysUtils;

{ TC64SystemThread }

procedure TC64SystemThread.UpdateFrontEnd(const ATicks: Cardinal);
	begin

	end;

procedure TC64SystemThread.Execute;
	var
	doCycles: TC64CycCnt;
	s: Integer;
	t,
	r: Double;

	begin
//	FLock:= TCriticalSection.Create;
	FRunSignal:= TSimpleEvent.Create;
	FRunSignal.SetEvent;

	FPausedSignal:= TSimpleEvent.Create;
	FPausedSignal.ResetEvent;

	FCycResidual:= 0;
	FRefreshCnt:= 0;
	r:= 0;
	FThsDiff:= 0;

//	It seems that we have to call this here.  See the constructor.
	DoConstruction;

	while not Terminated do
		begin
		if  FRunSignal.WaitFor(0) = wrSignaled then
			begin
			if  FWasPaused then
				begin
				FWasPaused:= False;
				DoPlay;
				end;

			doCycles:= Integer(FCycPUpd) + FCycResidual;
			FCycResidual:= 0;

			FThsIntrv:= C64TimerGetTime;

			DoClock(doCycles);

			FLstIntrv:= C64TimerGetTime;
			FThsDiff:= FThsDiff + FLstIntrv - FThsIntrv;

			Inc(FRefreshCnt, doCycles);
			end
		else if not (FPausedSignal.WaitFor(0) = wrSignaled) then
			begin
			if  not FWasPaused then
				begin
				FWasPaused:= True;
				FPausedSignal.SetEvent;
				DoPause;
				end;
			end
		else
			FRunSignal.WaitFor(10);

		if  FRefreshCnt >= FRefreshUpd then
			begin
			t:= (FIntrval * FRefreshCnt * 1000) - FThsDiff * 1000 + r;
			s:= Round(t);
			r:= s - t;

//			UpdateFrontEnd;

			FRefreshCnt:= 0;
			FThsDiff:= 0;

//			if  s > 0 then
//				begin
//				if  not FFreeRun then
//					Sleep(s);
////				C64Wait(s);
//				end;
			end;
		end;

	DoDestruction;
	FPausedSignal.Free;
	FRunSignal.Free;
//	FLock.Free;
	end;

procedure TC64SystemThread.ExtendClock(const ATicks: Cardinal);
	begin
	Inc(FRefreshCnt, ATicks);
	FCycResidual:= FCycResidual - Integer(ATicks);
	end;

constructor TC64SystemThread.Create(const ASystemType: TC64SystemType);
	begin
//	We can't call DoConstruction here because the memory doesn't seem to get
//		allocated in a way in which we can use it if we do...  Annoying.

	FRefreshUpd:= ARR_VAL_SYSCYCPLIN[ASystemType] * ARR_VAL_SYSSCRNLNS[ASystemType];

//	FCycRefresh:= Trunc(ARR_VAL_SYSCYCPRFS[ASystemType]);
	FCycPUpd:= ARR_VAL_SYSCYCPLIN[ASystemType];

	FCycPSec:= ARR_VAL_SYSCYCPSEC[ASystemType];
	FIntrval:= (1 / FCycPSec);

	inherited Create(False);
	end;

destructor TC64SystemThread.Destroy;
	begin
//	Don't call DoDestruction here because we aren't calling DoConstruction in
//		the constructor.

	inherited Destroy;
	end;

//procedure TC64SystemThread.Lock;
//	begin
//	FLock.Acquire;
//	end;

//procedure TC64SystemThread.Unlock;
//	begin
//	FLock.Release;
//	end;

end.

