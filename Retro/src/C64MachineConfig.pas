unit C64MachineConfig;

interface

uses
	Classes, SyncObjs, IniFiles, C64Types;

type
	TC64MachineConfig = class(TObject)
	protected
		FLock: TCriticalSection;
		FIniFile: string;

		FStarted: Boolean;
		FChanged: Boolean;

		FSystem: TC64SystemType;
		FJoystickEnb: Boolean;

		function  GetChanged: Boolean;
		function  GetStarted: Boolean;
		procedure SetChanged(AValue: Boolean);
		procedure SetStarted(AValue: Boolean);

		procedure SetSystem(AValue: TC64SystemType);
		function  GetSystem: TC64SystemType;

		procedure SetJoystickEnb(AValue: Boolean);
		function  GetJoystickEnb: Boolean;

		function  GetCyclesPerSec: Cardinal;
		function  GetRefreshPerSec: TC64Float;

	public
		constructor Create(const AIniFile: string = '');
		destructor  Destroy; override;

		procedure Lock;
		procedure Unlock;

		procedure Assign(AConfig: TC64MachineConfig);

		procedure LoadFromIniFile(const AIniFile: TIniFile);
		procedure SaveToIniFile(const AIniFile: TIniFile); overload;
		procedure SaveToIniFile(const AIniFile: string); overload;

		property  Started: Boolean read GetStarted write SetStarted;
		property  Changed: Boolean read GetChanged write SetChanged;

		property  IniFile: string read FIniFile write FIniFile;

		property  System: TC64SystemType read GetSystem write SetSystem;
		property  JoystickEnb: Boolean read GetJoystickEnb write SetJoystickEnb;

		property  CyclesPerSec: Cardinal read GetCyclesPerSec;
		property  RefreshPerSec: TC64Float read GetRefreshPerSec;
	end;

var
	GlobalC64Config: TC64MachineConfig;


implementation

const
	LIT_TOK_CONFIGSEC = 'MONOPOLY Retro';

function TC64MachineConfig.GetStarted: Boolean;
	begin
	FLock.Acquire;
	try
		Result:= FStarted;

		finally
		FLock.Release;
		end;
	end;

procedure TC64MachineConfig.SetStarted(AValue: Boolean);
	begin
	FLock.Acquire;
	try
		FStarted:= AValue;

		finally
		FLock.Release;
		end;
	end;

procedure TC64MachineConfig.SaveToIniFile(const AIniFile: string);
	var
	ini: TIniFile;

	begin
	ini:= TIniFile.Create(AIniFile);
	try
		SaveToIniFile(ini);

		finally
		ini.Free;
		end;
	end;

procedure TC64MachineConfig.SetChanged(AValue: Boolean);
	begin
	FLock.Acquire;
	try
		FChanged:= AValue;

		finally
		FLock.Release;
		end;
	end;

procedure TC64MachineConfig.SetJoystickEnb(AValue: Boolean);
	begin
	FLock.Acquire;
	try
		FJoystickEnb:= AValue;

		finally
		FLock.Release;
		end;
	end;

function TC64MachineConfig.GetChanged: Boolean;
	begin
	FLock.Acquire;
	try
		Result:= FChanged;

		finally
		FLock.Release;
		end;
	end;

procedure TC64MachineConfig.LoadFromIniFile(const AIniFile: TIniFile);
	var
	i: Integer;

	begin
	FLock.Acquire;
	try
		i:= AIniFile.ReadInteger(LIT_TOK_CONFIGSEC, 'System', Ord(FSystem));
		FSystem:= TC64SystemType(i);

		FJoystickEnb:= AIniFile.ReadBool(LIT_TOK_CONFIGSEC, 'JoystickEnb', False);

		finally
		FLock.Release;
		end;
	end;

procedure TC64MachineConfig.SaveToIniFile(const AIniFile: TIniFile);
	begin
	FLock.Acquire;
	try
		AIniFile.WriteInteger(LIT_TOK_CONFIGSEC, 'System', Ord(FSystem));
		AIniFile.WriteBool(LIT_TOK_CONFIGSEC, 'JoystickEnb', FJoystickEnb);

		finally
		FLock.Release;
		end;
	end;

procedure TC64MachineConfig.SetSystem(AValue: TC64SystemType);
	begin
	FLock.Acquire;
	try
		if AValue <> FSystem then
			begin
			FSystem:= AValue;
			FChanged:= True;
			end;

		finally
		FLock.Release;
		end;
	end;

function TC64MachineConfig.GetSystem: TC64SystemType;
	begin
	FLock.Acquire;
	try
		Result:= FSystem;

		finally
		FLock.Release;
		end;
	end;

function TC64MachineConfig.GetCyclesPerSec: Cardinal;
	begin
	FLock.Acquire;
	try
		Result:= ARR_VAL_SYSCYCPSEC[FSystem];

		finally
		FLock.Release;
		end;
	end;

function TC64MachineConfig.GetJoystickEnb: Boolean;
	begin
	FLock.Acquire;
	try
		Result:= FJoystickEnb;

		finally
		FLock.Release;
		end;
	end;

function TC64MachineConfig.GetRefreshPerSec: TC64Float;
	begin
	FLock.Acquire;
	try
		Result:= ARR_VAL_SYSRFRSHPS[FSystem];

		finally
		FLock.Release;
		end;
	end;

constructor TC64MachineConfig.Create(const AIniFile: string);
	var
	ini: TIniFile;

	begin
	FLock:= TCriticalSection.Create;

	FSystem:= VAL_DEF_C64SYSTYPE;

	FIniFile:= AIniFile;

	if  AIniFile <> '' then
		begin
		ini:= TIniFile.Create(AIniFile);
		try
			LoadFromIniFile(ini);

			finally
			ini.Free;
			end;
		end;
	end;

destructor TC64MachineConfig.Destroy;
	begin
	FLock.Free;

	inherited Destroy;
	end;

procedure TC64MachineConfig.Lock;
	begin
	FLock.Acquire;
	end;

procedure TC64MachineConfig.Unlock;
	begin
	FLock.Release;
	end;

procedure TC64MachineConfig.Assign(AConfig: TC64MachineConfig);
	begin
	FLock.Acquire;
	try
		AConfig.FLock.Acquire;
		try
			FSystem:= AConfig.FSystem;

			FChanged:= AConfig.FChanged;

			finally
			AConfig.FLock.Release;
			end;

		finally
		FLock.Release;
		end;
	end;


end.
