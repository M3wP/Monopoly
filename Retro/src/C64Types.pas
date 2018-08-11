unit C64Types;

interface

//23420

uses
    Messages;

const
	MSG_C64MACH_UPDATEVIDEO = WM_USER + $10;
//	MSG_C64MACH_UPDATEAUDIO = WM_USER + $11;

type
	TC64Uns2  = 0..$03;
	TC64Uns3  = 0..$07;
	TC64Uns4  = 0..$0F;
	TC64Uns8  = Byte;
	TC64Uns10 = 0..$03FF;
	TC64Uns11 = 0..$07FF;
	TC64Uns12 = 0..$0FFF;
	TC64Uns16 = 0..$FFFF;
	TC64Uns24 = 0..$FFFFFF;
	TC64Uns32 = Cardinal;

	TC64CycCnt = Cardinal;

	TC64SystemType = (cstPAL, cstNTSC, cstNTSCOLD, cstPALN, cstNominal);
	TC64SIDModel = (csmAny, csmMOS6581, csmMOS8580);

	TC64Float = Single;

const
//	(1 shl 24) - 24 is the number of bits in the SID oscillator accumulators
	VAL_SIZ_SIDFREQGEN = $01000000;

//	PAL System
	VAL_CNT_PALCYCPLIN = 63;
	VAL_CNT_PALSCRNLNS = 312;
	VAL_CNT_PALCPFRESH = VAL_CNT_PALCYCPLIN * VAL_CNT_PALSCRNLNS;

	VAL_CNT_PALCYCPSEC = 985248;
//	50.124542124542124542124542124542
	VAL_FRQ_PALRFRSHPS = 1.0 / (VAL_CNT_PALCPFRESH / VAL_CNT_PALCYCPSEC);
	VAL_FAC_PALSIDFREQ = VAL_CNT_PALCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	NTSC System
	VAL_CNT_NTSCYCPLIN = 65;
	VAL_CNT_NTSSCRNLNS = 263;
	VAL_CNT_NTSCPFRESH = VAL_CNT_NTSCYCPLIN * VAL_CNT_NTSSCRNLNS;

	VAL_CNT_NTSCYCPSEC = 1022730;
//  59.826264989763088622404211757824
	VAL_FRQ_NTSRFRSHPS = 1.0 / (VAL_CNT_NTSCPFRESH / VAL_CNT_NTSCYCPSEC);
 	VAL_FAC_NTSSIDFREQ = VAL_CNT_NTSCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	Old NTSC System
	VAL_CNT_NTOCYCPLIN = 64;
	VAL_CNT_NTOSCRNLNS = 262;
	VAL_CNT_NTOCPFRESH = VAL_CNT_NTOCYCPLIN * VAL_CNT_NTOSCRNLNS;

	VAL_CNT_NTOCYCPSEC = 1022730;
	VAL_FRQ_NTORFRSHPS = 1.0 / (VAL_CNT_NTOCPFRESH / VAL_CNT_NTOCYCPSEC);
	VAL_FAC_NTOSIDFREQ = VAL_CNT_NTOCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	PAL-N System
	VAL_CNT_PLNCYCPLIN = 65;
	VAL_CNT_PLNSCRNLNS = 312;
	VAL_CNT_PLNCPFRESH = VAL_CNT_PLNCYCPLIN * VAL_CNT_PLNSCRNLNS;

	VAL_CNT_PLNCYCPSEC = 1023440;
	VAL_FRQ_PLNRFRSHPS = 1.0 / (VAL_CNT_PLNCPFRESH / VAL_CNT_PLNCYCPSEC);
	VAL_FAC_PLNSIDFREQ = VAL_CNT_PLNCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	Nominal System
	VAL_CNT_NOMCYCPLIN = 50;
	VAL_CNT_NOMSCRNLNS = 400;
	VAL_CNT_NOMCPFRESH = VAL_CNT_NOMCYCPLIN * VAL_CNT_NOMSCRNLNS;

	VAL_CNT_NOMCYCPSEC = 1000000;
	VAL_FRQ_NOMRFRSHPS = 1.0 / (VAL_CNT_NOMCPFRESH / VAL_CNT_NOMCYCPSEC);
	VAL_FAC_NOMSIDFREQ = VAL_CNT_NOMCYCPSEC / VAL_SIZ_SIDFREQGEN;


	ARR_VAL_SYSCYCPSEC: array[TC64SystemType] of Cardinal = (
			VAL_CNT_PALCYCPSEC, VAL_CNT_NTSCYCPSEC, VAL_CNT_NTOCYCPSEC,
			VAL_CNT_PLNCYCPSEC, VAL_CNT_NOMCYCPSEC);

	ARR_VAL_SYSRFRSHPS: array[TC64SystemType] of TC64Float = (
			VAL_FRQ_PALRFRSHPS, VAL_FRQ_NTSRFRSHPS, VAL_FRQ_NTORFRSHPS,
			VAL_FRQ_PLNRFRSHPS, VAL_FRQ_NOMRFRSHPS);

	ARR_VAL_SYSCYCPLIN: array[TC64SystemType] of Cardinal = (
			VAL_CNT_PALCYCPLIN, VAL_CNT_NTSCYCPLIN, VAL_CNT_NTOCYCPLIN,
			VAL_CNT_PLNCYCPLIN, VAL_CNT_NOMCYCPLIN);

	ARR_VAL_SYSSCRNLNS: array[TC64SystemType] of Cardinal = (
			VAL_CNT_PALSCRNLNS, VAL_CNT_NTSSCRNLNS, VAL_CNT_NTOSCRNLNS,
			VAL_CNT_PLNSCRNLNS, VAL_CNT_NOMSCRNLNS);

	ARR_VAL_SYSSIDFRQF: array[TC64SystemType] of TC64Float = (
			VAL_FAC_PALSIDFREQ, VAL_FAC_NTSSIDFREQ, VAL_FAC_NTOSIDFREQ,
			VAL_FAC_PLNSIDFREQ, VAL_FAC_NOMSIDFREQ);


	VAL_DEF_C64SYSTYPE = cstPAL;
	VAL_DEF_C64SIDMODL = csmMOS6581;



function C64TimerGetTime: Double;

function GetCurrentProcessorNumber: Cardinal; stdcall;

procedure DoFillInt(const AArr: PInteger; const ASize: Integer;
		const AValue: Integer);

implementation
uses
{$IFDEF MSWINDOWS}
	Windows;
{$ENDIF}
{$IFDEF LINUX}
	Unix;
{$ENDIF}
{$IFDEF DARWIN}
	MacOSAll;
{$ENDIF}


{$IFDEF MSWINDOWS}
function GetCurrentProcessorNumber: Cardinal; stdcall;
		external 'Kernel32.dll' name 'GetCurrentProcessorNumber';

var
	FTickFreq: Int64;
	FUSecPTick: Double;
{$ENDIF}

function C64TimerGetTime: Double;
	var
{$IFDEF MSWINDOWS}
	T: Int64;
{$ENDIF}
{$IFDEF LINUX}
	T: TimeVal;
{$ENDIF}
{$IFDEF DARWIN}
	T: UnsignedWide;
{$ENDIF}

	begin
{$IFDEF WIN32}
	QueryPerformanceCounter(T);
	Result:= T * FUSecPTick;
{$ENDIF}
{$IFDEF LINUX}
	FPGetTimeOfDay(@T, nil);
	Result:= ((T.tv_sec * 1000000) + T.tv_usec) / 1000000;
{$ENDIF}
{$IFDEF DARWIN}
	Microseconds(T);
	Result:= T / 1000000;
{$ENDIF}
	end;

procedure DoFillInt(const AArr: PInteger; const ASize: Integer;
		const AValue: Integer);
	begin
{$IFDEF WIN32}
	asm
		push edi // points to the destination
		mov edi, AArr
		mov eax, AValue
		mov ecx, ASize
		cld // clear the direction flag
		rep stosd
		pop edi
		end;
{$ENDIF}
{$IFDEF WIN64}
	asm
		push rdi // points to the destination
		mov rdi, AArr
		mov eax, AValue
		mov ecx, ASize
		cld // clear the direction flag
		rep stosd
		pop rdi
		end;
{$ENDIF}
	end;



{$IFDEF MSWINDOWS}
initialization
	QueryPerformanceFrequency(FTickFreq);
	FUSecPTick:= 1 / FTickFreq;
{$ENDIF}


end.
