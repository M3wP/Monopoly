unit C64SID;

interface

uses
	Classes, SyncObjs, C64Types, C64Classes, XSIDTypes, ReSIDFP;

type
	TSIDEventQueueData = record
		Head,
		Tail: PXSIDEvent;
		Count: Integer;
		Next: PXSIDEvent;
		Index: Integer;
		TTL: TC64CycCnt;
	end;

{ TXSIDEventManager }

	TSIDEventManager = class(TObject)
	protected
//		FLock: TCriticalSection;
//		FQueues: array[TXSIDEventQueue] of TXSIDEventQueueData;
		FQueue: TSIDEventQueueData;

		procedure DoAddEvent({const AQueue: TXSIDEventQueue;}
				AEvent: PXSIDEvent); {$IFDEF DEF_FNC_XSIDINLNE}inline;{$ENDIF}
		procedure DoClearQueueData{(const AQueue: TXSIDEventQueue)}; {$IFDEF DEF_FNC_XSIDINLNE}inline;{$ENDIF}

	public
		constructor Create;
		destructor  Destroy; override;

//		procedure Lock;
//		procedure Unlock;

		procedure AddEvent({const AQueue: TXSIDEventQueue;}
				const AOffset: TC64CycCnt; const AReg, AValue: TC64Uns8);
		procedure InsertEvent({const AQueue: TXSIDEventQueue;}
				const AOffset: TC64CycCnt; const AReg, AValue: TC64Uns8);
		procedure CopyEvents({const AQueue: TXSIDEventQueue;}
				const AList: TList);
		procedure ClearEvents(const ARelease: Boolean = True){(const AQueue: TXSIDEventQueue)};
//		procedure ClearAllEvents;
		function  Seek({const AQueue: TXSIDEventQueue; }const AOffset: TC64CycCnt;
				var AContext: TXSIDContext): TC64CycCnt;

		procedure Clock(const ATicks: TC64CycCnt; var ADeltaT: TC64CycCnt;
				var AEvents: TXSIDEventArr);
	end;


	TC64SID = class
	private
		FLstTick: Cardinal;

		FAudioBuffer: TC64AudioBuffer;
		FReSID: Pointer;
		FBufSzDiv2: Cardinal;
		FEventData: TXSIDEventArr;

	public
		constructor Create(ABuffer: TC64AudioBuffer);
		destructor Destroy; override;

		procedure Clock(const ACycles: TC64CycCnt);

	end;

	TC64SIDIO = class
	private
		FSID: TC64SID;

	public
		FirstTick: Cardinal;

		constructor Create(const ASID: TC64SID);

		procedure Write(const AAddress: Word; const AValue: Byte);
		function  Read(const AAddress: Word): Byte;
	end;


var
	SIDGlobalEvents: TSIDEventManager;


implementation

uses
	C64Machine, C64CPU;

{ TC64SID }

procedure TC64SID.Clock(const ACycles: TC64CycCnt);
	var
	t: Cardinal;
	i,
	j: Integer;

	begin
	FLstTick:= ACycles;
	while FLstTick > 0 do
		begin
		SIDGlobalEvents.Clock(FLstTick, t, FEventData);
		System.Dec(FLstTick, t);

//		UpdateFrontEnd(t);

		while t > 0 do
			begin
			j:= ReSIDClock(FReSID, 1, @(FAudioBuffer.FBuf[0]));

			if  Cardinal(FAudioBuffer.FBufIdx + j) >= FBufSzDiv2 then
				begin
				FAudioBuffer.FRenderer.SwapBuffers(FAudioBuffer.FBuffer,
						FAudioBuffer.FBufIdx * 2);
				FAudioBuffer.FBufIdx:= 0;
				end;

			if j > 0 then
				begin
				Move(FAudioBuffer.FBuf[0], FAudioBuffer.FBuffer[FAudioBuffer.FBufIdx],
						j * 2);
				System.Inc(FAudioBuffer.FBufIdx, j);
				end;

			System.Dec(t, 1);
			end;

		if  Length(FEventData) > 0 then
			for i:= 0 to High(FEventData) do
				ReSIDWrite(FReSID, FEventData[i].reg, FEventData[i].val);
		end;
	end;

constructor TC64SID.Create(ABuffer: TC64AudioBuffer);
	var
	sl: TStringList;
	r: TXSIDAudioRendererClass;
	f,
	sr,
	sz: Cardinal;

	begin
	FAudioBuffer:= ABuffer;

	XSIDGlobalConfig.Lock;
	try
		sr:= ARR_VAL_SAMPLERATE[XSIDGlobalConfig.SampleRate];

		sl:= TStringList.Create;
		try
			r:= XSIDGlobalRenderers.ItemByName(XSIDGlobalConfig.Renderer);
			if  not Assigned(r) then
				begin
				r:= XSIDGlobalRenderers.DefaultRenderer;
				r.FillParameterNames(sl);
				end
			else
				sl.AddStrings(XSIDGlobalConfig.GetRenderParams);

			FAudioBuffer.FRenderer:= r.Create(XSIDGlobalConfig.SampleRate,
					Round(ARR_VAL_SYSRFRSHPS[XSIDGlobalConfig.System]),
					XSIDGlobalConfig.BufferSize, sl, FAudioBuffer.FBuffer, sz);

			FBufSzDiv2:= sz div 2;

			finally
			sl.Free;
			end;

		SetLength(FEventData, 0);

		FReSID:= ReSIDCreate;
		ReSIDSetSamplingParameters(FReSID, ARR_VAL_SYSCYCPSEC[XSIDGlobalConfig.System],
				Ord(XSIDGlobalConfig.Interpolation), sr, {16384} 0.9 * sr / 2);
		ReSIDSetChipModel(FReSID, Ord(XSIDGlobalConfig.Model));

		ReSIDSetFilter6581Curve(FReSID, XSIDGlobalConfig.Filter6581);
		ReSIDSetFilter8580Curve(FReSID, XSIDGlobalConfig.Filter8580);

		ReSIDEnableFilter(FReSID, XSIDGlobalConfig.FilterEnable);

		if  (XSIDGlobalConfig.Model = csmMOS8580)
		and (XSIDGlobalConfig.DigiBoostEnable) then
			ReSIDInput(FReSID, Integer(INPUT_BOOST))
		else
			ReSIDInput(FReSID, 0);

		finally
		XSIDGlobalConfig.Unlock;
		end;

//  Test tone
	f:= Trunc(55.000 / XSIDGlobalConfig.FreqFactor);

	ReSIDWrite(FReSID, 1, (f and $FF00) shr 8);
	ReSIDClock(FReSID, 3, @FAudioBuffer.FBuffer[0]);
	ReSIDWrite(FReSID, 0, f and $00FF);
	ReSIDClock(FReSID, 3, @FAudioBuffer.FBuffer[0]);
	ReSIDWrite(FReSID, 5, $0F);
	ReSIDClock(FReSID, 3, @FAudioBuffer.FBuffer[0]);
	ReSIDWrite(FReSID, 6, $F0);
	ReSIDClock(FReSID, 3, @FAudioBuffer.FBuffer[0]);
	ReSIDWrite(FReSID, 24, $0F);
	ReSIDClock(FReSID, 3, @FAudioBuffer.FBuffer[0]);
	ReSIDWrite(FReSID, 4, $11);
	ReSIDClock(FReSID, 3, @FAudioBuffer.FBuffer[0]);

	end;

destructor TC64SID.Destroy;
	begin
	ReSIDDestroy(FReSID);

	inherited;
	end;


{ TXSIDEventManager }

procedure TSIDEventManager.DoAddEvent({const AQueue: TXSIDEventQueue;}
		AEvent: PXSIDEvent);
	begin
	AEvent^.prev:= FQueue{s[AQueue]}.Tail;
	AEvent^.next:= nil;

	if  Assigned(FQueue{s[AQueue]}.Tail) then
		FQueue{s[AQueue]}.Tail^.next:= AEvent;

	FQueue{s[AQueue]}.Tail:= AEvent;
	if  not Assigned(FQueue{s[AQueue]}.Head) then
		FQueue{s[AQueue]}.Head:= AEvent;

	System.Inc(FQueue{s[AQueue]}.Count);
	end;

procedure TSIDEventManager.DoClearQueueData{(const AQueue: TXSIDEventQueue)};
	begin
	FQueue{s[AQueue]}.Head:= nil;
	FQueue{s[AQueue]}.Tail:= nil;
	FQueue{s[AQueue]}.Count:= 0;
	FQueue{s[AQueue]}.Next:= nil;
	FQueue{s[AQueue]}.Index:= -1;
	FQueue{s[AQueue]}.TTL:= 0;
	end;

constructor TSIDEventManager.Create;
//	var
//	q: TXSIDEventQueue;

	begin
	inherited Create;

//	FLock:= TCriticalSection.Create;

//	for q:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
		DoClearQueueData{(q)};
	end;

destructor TSIDEventManager.Destroy;
	begin
//	ClearAllEvents;
	ClearEvents;

//	FLock.Free;

	inherited Destroy;
	end;

//procedure TXSIDEventManager.Lock;
//	begin
//	FLock.Acquire;
//	end;

//procedure TXSIDEventManager.Unlock;
//	begin
//	FLock.Release;
//	end;

procedure TSIDEventManager.AddEvent({const AQueue: TXSIDEventQueue;}
		const AOffset: TC64CycCnt; const AReg, AValue: TC64Uns8);
	var
	evt: PXSIDEvent;

	begin
	evt:= XSIDCreateEvent(AOffset, AReg, AValue);

//	Lock;
//	try
		DoAddEvent({AQueue, }evt);

//		finally
//		Unlock;
//		end;
	end;

procedure TSIDEventManager.InsertEvent({const AQueue: TXSIDEventQueue;}
		const AOffset: TC64CycCnt; const AReg, AValue: TC64Uns8);
	var
	evt: PXSIDEvent;

	begin
	evt:= XSIDCreateEvent(AOffset, AReg, AValue);

//	Lock;
//	try
		if  Assigned(FQueue{s[AQueue]}.Next) then
			begin
//			There is a cursor, insert before
//todo 		Need to insert _after_
			evt^.prev:= FQueue{s[AQueue]}.Next;
			evt^.next:= FQueue{s[AQueue]}.Next^.next;
			FQueue{s[AQueue]}.Next^.next:= evt;
			end
		else if Assigned(FQueue{s[AQueue]}.Tail) then
			begin
//			No cursor, but not empty list, insert after last
//todo		Could just call add?
			FQueue{s[AQueue]}.Tail^.next:= evt;
			evt^.prev:= FQueue{s[AQueue]}.Tail;
			evt^.Next:= nil;
			FQueue{s[AQueue]}.Tail:= evt;
			end
		else
			begin
//			No cursor, no list.  Create a new list
//todo		Could just call add?
			evt^.prev:= nil;
			evt^.next:= nil;
			FQueue{s[AQueue]}.Tail:= evt;
			FQueue{s[AQueue]}.Head:= evt;
			end;

		System.Inc(FQueue{s[AQueue]}.Count);

//		finally
//		Unlock;
//		end;
	end;

procedure TSIDEventManager.CopyEvents({const AQueue: TXSIDEventQueue;}
		const AList: TList);
	var
	i: Integer;

	begin
//	Lock;
//	try
		for i:= 0 to AList.Count - 1 do
			DoAddEvent({AQueue, }PXSIDEvent(AList[i]));

//		finally
//		Unlock;
//		end;
	end;

procedure TSIDEventManager.ClearEvents(const ARelease: Boolean){(const AQueue: TXSIDEventQueue)};
	var
	evt,
	dis: PXSIDEvent;

	begin
//	Lock;
//	try
(*		if  ARelease then
			begin
			evt:= FQueue{s[AQueue]}.Tail;
			if  Assigned(evt) then
				repeat
					dis:= evt;
					evt:= evt^.prev;

					GlobalEventPool.ReleaseEvent(dis);

					until not Assigned(evt);
			end;*)

		DoClearQueueData{(AQueue)};

//		finally
//		Unlock;
//		end;
	end;

//procedure TXSIDEventManager.ClearAllEvents;
//	var
//	q: TXSIDEventQueue;
//
//	begin
//	Lock;
//	try
//		for q:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
//			ClearEvents(q);
//
//		finally
//		Unlock;
//		end;
//	end;

function TSIDEventManager.Seek({const AQueue: TXSIDEventQueue;}
		const AOffset: TC64CycCnt; var AContext: TXSIDContext): TC64CycCnt;
	var
	i: Integer;

	function DoGetNextEvent{(AQueue: TXSIDEventQueue)}: Boolean;
		var
		nxt: PXSIDEvent;

		begin
		if  FQueue{s[AQueue]}.Index < 0 then
			nxt:= FQueue{s[AQueue]}.Head
		else
			nxt:= FQueue{s[AQueue]}.Next^.next;

		if  Assigned(nxt) then
			begin
			FQueue{s[AQueue]}.Next:= nxt;
//			AssignEvent(FThisEvent, FNextEvent^);
			FQueue{s[AQueue]}.TTL:= nxt^.offs;
			Inc(FQueue{s[AQueue]}.Index);

			Result:= True;
			end
		else
			begin
			FQueue{s[AQueue]}.TTL:= 0;
			Result:= False;
			end;
		end;

	begin
	Result:= 0;
//	Lock;
//	try
		FQueue{s[AQueue]}.Index:= -1;
		FQueue{s[AQueue]}.Next:= nil;
		FQueue{s[AQueue]}.TTL:= 0;

//		finally
//		Unlock;
//		end;

	for i:= 0 to High(AContext) do
		begin
		AContext[i].isUsed:= False;
		AContext[i].value:= 0;
		end;


	while  DoGetNextEvent do
		begin
		if  Assigned(FQueue.Next) then
			begin
			if ((Result + FQueue.TTL) > AOffset)  then
				Break;

			AContext[FQueue.Next^.data.reg].isUsed:= True;
			AContext[FQueue.Next^.data.reg].value:= FQueue.Next^.data.val;

			Inc(Result, FQueue.TTL);
			end;
		end;
	end;

procedure TSIDEventManager.Clock(const ATicks: TC64CycCnt;
		var ADeltaT: TC64CycCnt; var AEvents: TXSIDEventArr);
	var
//	i: TXSIDEventQueue;
//	d: array[TXSIDEventQueue] of Boolean;
	d: Boolean;
	t: TC64CycCnt;

	function DoGetNextEvent{(AQueue: TXSIDEventQueue)}: Boolean;
		var
		nxt: PXSIDEvent;

		begin
		if  FQueue{s[AQueue]}.Index < 0 then
			nxt:= FQueue{s[AQueue]}.Head
		else
			nxt:= FQueue{s[AQueue]}.Next^.next;

		if  Assigned(nxt) then
			begin
			if  Assigned(FQueue.Next) then
				begin
				GlobalEventPool.ReleaseEvent(FQueue.Next);
				FQueue.Next:= nil;
				end;

			FQueue{s[AQueue]}.Next:= nxt;
//			AssignEvent(FThisEvent, FNextEvent^);
			FQueue{s[AQueue]}.TTL:= nxt^.offs;
			Inc(FQueue{s[AQueue]}.Index);

//todo		Need to instantly write and move to next for any events with 0 offs?

			Result:= True;
			end
		else
			begin
			FQueue{s[AQueue]}.TTL:= 0;
			Result:= False;
			end;
		end;

	procedure DoNextEvent{(const AQueue: TXSIDEventQueue)};
//		var
//		evt: PReSIDEvent;

		begin
//todo	Why do I need this?
		if  Assigned(FQueue{s[AQueue]}.Next) then
			begin
			SetLength(AEvents, Length(AEvents) + 1);
			AEvents[0].reg:= FQueue{s[AQueue]}.Next^.data.reg;
			AEvents[0].val:= FQueue{s[AQueue]}.Next^.data.val;

//			if AQueue <> reqPattern then
//				begin
////				Assert(FQueues[AQueue].Index = 0);
//
//				evt:= FQueues[AQueue].Next;
//
//				FQueues[AQueue].Head:= evt^.next;
//				if Assigned(evt^.next) then
//					evt^.next^.prev:= nil
//				else
//					FQueues[AQueue].Tail:= nil;
//
//				Dec(FQueues[AQueue].Count);
//				Dec(FQueues[AQueue].Index);
//
//				GlobalEventPool.ReleaseEvent(evt);
//
////				DoGetNextEvent(AQueue);
//				end;
			end;
		end;

	procedure DoExpireEvent({const AQueue: TXSIDEventQueue;}
			ATicks: TC64CycCnt);
		var
		doEvent: Boolean;
		doTicks: TC64CycCnt;

		begin
//		Lock;
//		try
			if (ATicks >= FQueue{s[AQueue]}.TTL) then
				begin
//				doTicks:= FQueues[AQueue].TTL;
				doEvent:= True;
				end
			else
				begin
				doTicks:= ATicks;
				Dec(FQueue{s[AQueue]}.TTL, doTicks);
				doEvent:= False;
				end;

//			finally
//			Unlock;
//			end;

		if  doEvent then
			begin
//			Lock;
//			try
				DoNextEvent{(AQueue)};
				DoGetNextEvent{(AQueue)};

//				finally
//				Unlock;
//				end;
			end;

//Hmm..  What's this?  Already commented out...
//		Dec(ATicks, doTicks);
		end;

	begin
	t:= ATicks;
	SetLength(AEvents, 0);

//	Lock;
//	try
//		for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
			d{[i]}:= FQueue{s[i]}.TTL > 0;

//		for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
			if  FQueue{s[i]}.TTL = 0 then
				d{[i]}:= DoGetNextEvent{(i)};

//Hmm..  What's this?  Already commented out...
//		d:= FQueues[reqPattern].TTL > 0;

//		for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
			if d{[i]} then
				if FQueue{s[i]}.TTL < t then
					t:= FQueue{s[i]}.TTL;
//		finally
//		Unlock;
//		end;

	ADeltaT:= t;

//	for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
//		begin
		if  d{[i]} then
			DoExpireEvent({i, }t);
//Hmm..  What's this?  Already commented out...
//		else
//			Dec(FThsTick);
//		end;
	end;


{ TC64SIDIO }

constructor TC64SIDIO.Create(const ASID: TC64SID);
	begin
	inherited Create;

	FSID:= ASID;
	end;

function TC64SIDIO.Read(const AAddress: Word): Byte;
	begin
	Result:= ReSIDRead(FSID.FReSID, AAddress and $00FF);
	end;

procedure TC64SIDIO.Write(const AAddress: Word; const AValue: Byte);
	begin
	SIDGlobalEvents.AddEvent(clockticks6502 - FirstTick, AAddress and $00FF, AValue);
	end;

initialization
	SIDGlobalEvents:= TSIDEventManager.Create;

finalization
	SIDGlobalEvents.Free;

end.


