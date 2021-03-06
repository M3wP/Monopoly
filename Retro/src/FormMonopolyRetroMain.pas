unit FormMonopolyRetroMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
	XInput, dglOpenGL, Vcl.ExtCtrls, Vcl.Menus, C64Machine, Vcl.StdCtrls, C64Types,
	System.Actions, Vcl.ActnList;

type
	TMonopolyRetroMainForm = class(TForm)
		MainMenu1: TMainMenu;
		File1: TMenuItem;
		Edit1: TMenuItem;
		View1: TMenuItem;
		Tools1: TMenuItem;
		Help1: TMenuItem;
		Panel1: TPanel;
		Panel2: TPanel;
		Test1: TMenuItem;
		Label1: TLabel;
		Label2: TLabel;
		Input1: TMenuItem;
		ActionList1: TActionList;
		actInputJoystick: TAction;
		EnableJoystick1: TMenuItem;
		Timer1: TTimer;
		actConfigSID: TAction;
		Configure1: TMenuItem;
		SIDAudio1: TMenuItem;
		actViewDouble: TAction;
		DoubleSize1: TMenuItem;
		actViewFilter: TAction;
		Filtering1: TMenuItem;
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure FormKeyPress(Sender: TObject; var Key: Char);
		procedure actInputJoystickExecute(Sender: TObject);
		procedure Timer1Timer(Sender: TObject);
		procedure FormActivate(Sender: TObject);
		procedure FormDeactivate(Sender: TObject);
		procedure actConfigSIDExecute(Sender: TObject);
		procedure Panel1MouseEnter(Sender: TObject);
		procedure Panel1MouseLeave(Sender: TObject);
		procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);
		procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);
		procedure actViewDoubleExecute(Sender: TObject);
		procedure actViewFilterExecute(Sender: TObject);
	private
		FRC: HGLRC;
		FDC: HDC;
		FThisTime,
		FLastTime,
		FFramesElapsed: DWord;
		FNCKludge: Boolean;
		FFirstTime: Boolean;
		FJoystickIdx: Integer;
		FJoyState: TXInputState;
		FScale: Integer;
		FFilter: Boolean;

		procedure DoGLDraw;
//		procedure DoTryTurnOffVSync;

		procedure DoUpdateFrame;
		procedure DoUpdateFormSize;


		procedure ApplicationMessage(var AMsg: TMsg; var ADone: Boolean);

	protected
		procedure MsgC64MachineUpdVideo(
				var AMsg: TMessage); message MSG_C64MACH_UPDATEVIDEO;

	public
		{ Public declarations }
	end;

var
	MonopolyRetroMainForm: TMonopolyRetroMainForm;

implementation

{$R *.dfm}

uses
	System.Character, AnsiStrings, SyncObjs, C64Memory, C64Video, C64MachineConfig,
	MR64Board, XSIDAudioDSound, XSIDTypes, FormXSIDConfig;

const
	VAL_SIZ_FORM_WIDTH = 720;
	VAL_SIZ_FORM_HEIGHT = 544;


procedure TMonopolyRetroMainForm.actConfigSIDExecute(Sender: TObject);
	begin
	XSIDConfigForm:= TXSIDConfigForm.Create(Self);
	try
		if  XSIDConfigForm.ShowModal = mrOK then
			begin
			C64MachineGlobal.RunSignal.ResetEvent;
			try
				C64MachineGlobal.PausedSignal.WaitFor(INFINITE);
				XSIDGlobalConfig.Assign(XSIDConfigForm.Config);
				C64MachineGlobal.ReinitialiseAudio;

				finally
				C64MachineGlobal.RunSignal.SetEvent;
				end;
			end;

		finally
		XSIDConfigForm.Release;
		end;

	end;

procedure TMonopolyRetroMainForm.actInputJoystickExecute(Sender: TObject);
	var
	i: Integer;
	state: TXInputState;

	begin
	if  actInputJoystick.Checked then
		begin
		FJoystickIdx:= -1;
		actInputJoystick.Checked:= False;
		XInputEnable(False);
		end
	else
		begin
		FJoystickIdx:= -1;
		actInputJoystick.Checked:= False;
		for i:= 0 to 3 do
			begin
			FillChar(state, SizeOf(state), 0);

			if  XInputGetState(i, state) = ERROR_SUCCESS then
				begin
				FJoystickIdx:= i;
				actInputJoystick.Checked:= True;
				XInputEnable(True);
				FillChar(FJoyState, SizeOf(FJoyState), 0);
				Break;
				end;
			end;
		end;

	GlobalC64Config.JoystickEnb:= actInputJoystick.Checked;
	end;

procedure TMonopolyRetroMainForm.actViewDoubleExecute(Sender: TObject);
	begin
	actViewDouble.Checked:= not actViewDouble.Checked;
	if  actViewDouble.Checked then
		FScale:= 2
	else
		FScale:= 1;

	DoUpdateFormSize;
	end;

procedure TMonopolyRetroMainForm.actViewFilterExecute(Sender: TObject);
	begin
	actViewFilter.Checked:= not actViewFilter.Checked;
	FFilter:= actViewFilter.Checked;
	end;

procedure TMonopolyRetroMainForm.ApplicationMessage(var AMsg: TMsg;
		var ADone: Boolean);
	begin
	ADone:= False;

	if  (AMsg.message = WM_NCLBUTTONDOWN)
	and (AMsg.wParam in [HTCLOSE, HTMINBUTTON, HTMAXBUTTON]) then
		begin
		if  C64MachineGlobal.RunSignal.WaitFor(0) = wrSignaled then
			begin
			FNCKludge:= True;
			C64MachineGlobal.RunSignal.ResetEvent;
//			ADone:= False;
			end;
		end
	else if FNCKludge then
		begin
		FNCKludge:= False;
		C64MachineGlobal.RunSignal.SetEvent;
//		ADone:= True;
		end;
	end;

procedure TMonopolyRetroMainForm.DoGLDraw;
	var
	i: Integer;
	b: PByte;
//	x,
//	y: Integer;
//	pb1,
//	pb2: PC64PALScreen;
//	b2: PByte;
//	a: Cardinal;
//	p: TC64RGBA;
	texNames: array[0..5] of GLint;

	begin
	glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
	glEnable(GL_TEXTURE_2D);

	C64MachineGlobal.FMultiOut.FVideoBuffer.FLock.Acquire;
	try
		i:= C64MachineGlobal.FMultiOut.FVideoBuffer.FBufferIdx xor 1;

		glPixelStorei(GL_PACK_ALIGNMENT, 4);

		glGenTextures(6, @texNames[0]);

//		Background/border
		glBindTexture(GL_TEXTURE_2D, texNames[0]);
		if not FFilter then
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			end
		else
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			end;

		b:= @C64MachineGlobal.FMultiOut.FVideoBuffer.FBGBuf[i];
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, VAL_SIZ_SCREEN_PALX2X,
				VAL_SIZ_SCREEN_PALY2X, 0, GL_RGBA, GL_UNSIGNED_BYTE, b);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(0, -60 * FScale, 0); //bottom left

		glTexCoord2f(1.0, 1.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, -60 * FScale, 0); // bottom right

		glTexCoord2f(1.0, 0.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0);//top right

		glTexCoord2f(0.0, 0.0);
		glVertex3f(0, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0); //top left
		glEnd;

//		glWindowPos3i(352 * FScale, 146 * FScale, 0);

//		Overlay/board
		glBindTexture(GL_TEXTURE_2D, texNames[1]);
		if not FFilter then
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			end
		else
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			end;

		b:= @C64MachineGlobal.FMultiOut.FVideoBuffer.FBRBuf[i];
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 640, 640, 0, GL_RGBA,
				GL_UNSIGNED_BYTE, b);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(351 * FScale, 58 * FScale, 0); //bottom left

		glTexCoord2f(1.0, 1.0);
		glVertex3f((351 + 320) * FScale, 58 * FScale, 0); // bottom right

		glTexCoord2f(1.0, 0.0);
		glVertex3f((351 + 320) * FScale, (320 + 58) * FScale, 0);//top right

		glTexCoord2f(0.0, 0.0);
		glVertex3f(351 * FScale, (320 + 58) * FScale, 0); //top left
		glEnd;

//		Overlay/players
		glBindTexture(GL_TEXTURE_2D, texNames[2]);
		if not FFilter then
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			end
		else
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			end;

		b:= @C64MachineGlobal.FMultiOut.FVideoBuffer.FBPBuf[i];
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 640, 640, 0, GL_RGBA,
				GL_UNSIGNED_BYTE, b);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(351 * FScale, 58 * FScale, 0); //bottom left

		glTexCoord2f(1.0, 1.0);
		glVertex3f((351 + 320) * FScale, 58 * FScale, 0); // bottom right

		glTexCoord2f(1.0, 0.0);
		glVertex3f((351 + 320) * FScale, (320 + 58) * FScale, 0);//top right

		glTexCoord2f(0.0, 0.0);
		glVertex3f(351 * FScale, (320 + 58) * FScale, 0); //top left
		glEnd;

//		Playfield background
		glBindTexture(GL_TEXTURE_2D, texNames[3]);
		if not FFilter then
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			end
		else
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			end;

		b:= @C64MachineGlobal.FMultiOut.FVideoBuffer.FFGBuf[i];
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, VAL_SIZ_SCREEN_PALX2X,
				VAL_SIZ_SCREEN_PALY2X, 0, GL_RGBA, GL_UNSIGNED_BYTE, b);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(0, -60 * FScale, 0); //bottom left

		glTexCoord2f(1.0, 1.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, -60 * FScale, 0); // bottom right

		glTexCoord2f(1.0, 0.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0);//top right

		glTexCoord2f(0.0, 0.0);
		glVertex3f(0, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0); //top left
		glEnd;

//		Playfield foreground
		glBindTexture(GL_TEXTURE_2D, texNames[4]);
		if not FFilter then
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			end
		else
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			end;

		b:= @C64MachineGlobal.FMultiOut.FVideoBuffer.FFPBuf[i];
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, VAL_SIZ_SCREEN_PALX2X,
				VAL_SIZ_SCREEN_PALY2X, 0, GL_RGBA, GL_UNSIGNED_BYTE, b);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(0, -60 * FScale, 0); //bottom left

		glTexCoord2f(1.0, 1.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, -60 * FScale, 0); // bottom right

		glTexCoord2f(1.0, 0.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0);//top right

		glTexCoord2f(0.0, 0.0);
		glVertex3f(0, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0); //top left
		glEnd;

//		Sprites
		glBindTexture(GL_TEXTURE_2D, texNames[5]);
		if not FFilter then
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			end
		else
			begin
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			end;

		b:= @C64MachineGlobal.FMultiOut.FVideoBuffer.FSPBuf[i];
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 385, 312, 0, GL_RGBA,
				GL_UNSIGNED_BYTE, b);

		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex3f(0, -60 * FScale, 0); //bottom left

		glTexCoord2f(1.0, 1.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, -60 * FScale, 0); // bottom right

		glTexCoord2f(1.0, 0.0);
		glVertex3f((VAL_SIZ_FORM_WIDTH - 1 + 50) * FScale, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0);//top right

		glTexCoord2f(0.0, 0.0);
		glVertex3f(0, (VAL_SIZ_FORM_HEIGHT - 1 + 20) * FScale, 0); //top left
		glEnd;

		finally
		C64MachineGlobal.FMultiOut.FVideoBuffer.FLock.Release;
		end;

	glDeleteTextures(6, @texNames[0]);

//	Make sure the buffers are sent
	glFlush;
//	glFinish;
	end;


{type
	PFNWGLSWAPINTERVALPROC = function(AValue: Integer): Bool; stdcall;

var
	wglSwapIntervalEXT: PFNWGLSWAPINTERVALPROC = nil;

procedure TMonopolyRetroMainForm.DoTryTurnOffVSync;
	var
	extensions: PAnsiChar;

	begin
// 	Function pointer for the wgl extention function we need to enable/disable
// 	vsync
	extensions:= glGetString(GL_EXTENSIONS);

	if  AnsiStrings.AnsiStrPos(extensions, 'WGL_EXT_swap_control') = nil then
		Exit
	else
		begin
		wglSwapIntervalEXT:= PFNWGLSWAPINTERVALPROC(wglGetProcAddress('wglSwapIntervalEXT'));

		if  Assigned(wglSwapIntervalEXT) then
			wglSwapIntervalEXT(0);
		end;
	end;}

procedure TMonopolyRetroMainForm.DoUpdateFormSize;
	begin
	ClientWidth:= VAL_SIZ_FORM_WIDTH * FScale;
	ClientHeight:= VAL_SIZ_FORM_HEIGHT * FScale + Panel2.Height;

//	2x scaled output (with aspect ratio correction)
	glViewport(0, 0, VAL_SIZ_FORM_WIDTH * FScale, VAL_SIZ_FORM_HEIGHT * FScale);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity;
//	gluOrtho2D(0.0, VAL_SIZ_FORM_WIDTH * FScale, 0.0, VAL_SIZ_FORM_HEIGHT * FScale);
	glOrtho(0, VAL_SIZ_FORM_WIDTH * FScale, VAL_SIZ_FORM_HEIGHT * FScale, 0, 0, 1);

//	glMatrixMode(GL_MODELVIEW);
//	glLoadIdentity;

//	glPixelZoom(1.87301588, 2.0);
//	glPixelZoom(2, 2.1355932);

//	DoTryTurnOffVSync;

//	glEnable(GL_ALPHA_TEST);
//	glAlphaFunc(GL_GREATER, 0.5);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBlendEquation(GL_FUNC_ADD);

	glDisable(GL_DEPTH_TEST);

	end;

procedure TMonopolyRetroMainForm.DoUpdateFrame;
	var
	elapsed: Cardinal;
	ratef,
	rateb,
	diff: Single;
	dur: Integer;
	vcpu,
	acpu: Cardinal;

	begin
//	If we get this message then C64MachineGlobal.FMultiOut.FReady must be
//		in the Reset state!

//	Calculate our performance
	FThisTime:= GetTickCount;
	elapsed:=  FThisTime - FLastTime;
	Inc(FFramesElapsed);

//	Optimise for when minimised so as to release the CPU??  Windows doesn't
//		seem to want to keep updating the OpenGL rending context when it isn't
//		visible anyway, so this probably makes no difference there.
	if  WindowState <> wsMinimized then
		begin
//		Make sure we remain responsive to the user's input and OS requirements
//		Application.ProcessMessages;

//		Output audio

//		Update the display
		DoGLDraw;

//		Show the updated display
		SwapBuffers(FDC);
		end;

//	Update info for the user, too
	if  elapsed > 500 then
		begin
		ratef:= FFramesElapsed / elapsed * 1000;
		C64MachineGlobal.FMultiOut.FVideoBuffer.FLock.Acquire;
		try
			vcpu:= C64MachineGlobal.FMultiOut.FVideoBuffer.FVICIILastCPU;
			rateb:= C64MachineGlobal.FMultiOut.FVideoBuffer.FFrameCnt / elapsed * 1000;
			C64MachineGlobal.FMultiOut.FVideoBuffer.FFrameCnt:= 0;

			finally
			C64MachineGlobal.FMultiOut.FVideoBuffer.FLock.Release;
			end;

		C64MachineGlobal.FMultiOut.FAudioBuffer.FLock.Acquire;
		try
			acpu:= C64MachineGlobal.FMultiOut.FAudioBuffer.FSIDLastCPU;

			finally
			C64MachineGlobal.FMultiOut.FAudioBuffer.FLock.Release;
			end;

		Label1.Caption:= 'UI: ' + IntToStr(GetCurrentProcessorNumber) +
				';  VIC-II: ' + IntToStr(vcpu) +
				';  SID: ' + IntToStr(acpu);

		diff:= rateb - VAL_FRQ_PALRFRSHPS;
		dur:= Trunc((1 / VAL_FRQ_PALRFRSHPS * 1000 - 1 / rateb * 1000));
		Label2.Caption:= Format(
				'Front-end: %5.2ffps; Back-end: %5.2ffps [%5.2f, %dms]',
				[ratef, rateb, diff, dur]);

//		diff:= ratef - 60;
//		dur:= Trunc((1 / 60 - 1 / rateb) * 1000);
//		if  (diff > 0)
//		and (dur > 0) then
//			Sleep(dur);

		FFramesElapsed:= 0;
		FLastTime:= GetTickCount;
		end;
	end;

procedure TMonopolyRetroMainForm.FormActivate(Sender: TObject);
	begin
	XInputEnable(True);
	end;

procedure TMonopolyRetroMainForm.FormCreate(Sender: TObject);
	var
	pfd: TPixelFormatDescriptor;
	pf: Integer;

	begin
	FJoystickIdx:= -1;

	FNCKludge:= False;
	IsMultiThread:= True;

	InitOpenGL;

//	The control's device context that will be painted with the OpenGL buffer
	FDC:= GetDC(Panel1.Handle);

//	Preferred pixel format info
	pfd.nSize:= SizeOf(pfd);
	pfd.nVersion:= 1;
	pfd.dwFlags:= PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
	pfd.iPixelType:= PFD_TYPE_RGBA;
	pfd.iLayerType:= PFD_MAIN_PLANE;
	pfd.cColorBits:= 32;

 //	Get the best matched pixel format for our requirements
	pf:= ChoosePixelFormat(FDC, @pfd);
	SetPixelFormat(FDC, pf, @pfd);

//	Get the rendering context for Windows so it knows what to do
	FRC:= wglCreateContext(FDC);
//	Connect the rendering context to the control
//	wglMakeCurrent(FDC, FRC);
	ActivateRenderingContext(FDC, FRC);

//	Initialise GL environment variables
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glShadeModel(GL_FLAT);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

	FScale:= 1;

	DoUpdateFormSize;

//	State stuff
	FLastTime:= GetTickCount;
	FFramesElapsed:= 0;

	FFirstTime:= True;

	Application.OnMessage:= ApplicationMessage;
//	Application.OnIdle:= ApplicationIdle;

//	PostMessage(Handle, MSG_C64MACH_UPDATEOUTPUT, 0, 0);
	end;

procedure TMonopolyRetroMainForm.FormDeactivate(Sender: TObject);
	begin
	XInputEnable(False);
	end;

procedure TMonopolyRetroMainForm.FormDestroy(Sender: TObject);
	begin
//	Goodbye C64
	C64MachineGlobal.RunSignal.ResetEvent;
	C64MachineGlobal.PausedSignal.WaitFor(10);

	C64MachineGlobal.Terminate;
	C64MachineGlobal.WaitFor;
//	C64MachineGlobal.Free;

	GlobalC64Config.SaveToIniFile(ChangeFileExt(Application.ExeName, '.ini'));

//	Remove the OpenGL rendering from the control's device context
	wglMakeCurrent(0, 0);
//	Delete the rendering context
	wglDeleteContext(FRC);
	end;

procedure TMonopolyRetroMainForm.FormKeyPress(Sender: TObject; var Key: Char);
	begin
	C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Acquire;
	try
		C64MachineGlobal.FMultiIn.FUserBuffer.FKey:= AnsiChar(Key.ToUpper);

		finally
		C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Release;
		end;
	end;

procedure TMonopolyRetroMainForm.FormShow(Sender: TObject);
	begin
	if  FFirstTime then
		begin
		C64CharGenROMInit('res\newchargen.data');

//		GlobalC64Memory.Load($8000, 'test.bin');
//		GlobalC64Memory.Write($FFFC, $00);
//		GlobalC64Memory.Write($FFFD, $80);
//		GlobalC64Memory.Write($FFFE, $64);
//		GlobalC64Memory.Write($FFFF, $90);

		GlobalC64Memory.Load($0000, 'res\clientretro.prg', True);
		GlobalC64Memory.Load($0000, 'res\strings.prg', True);
		GlobalC64Memory.Load($0000, 'res\screen.prg', True);
		GlobalC64Memory.Load($0000, 'res\rules.prg', True);

		GlobalC64Memory.Write($FFFC, $22);
		GlobalC64Memory.Write($FFFD, $08);

		GlobalC64Config:= TC64MachineConfig.Create(
				ChangeFileExt(Application.ExeName, '.ini'));

		if  GlobalC64Config.JoystickEnb then
			actInputJoystickExecute(Self);

//		Go the C64!
		C64MachineGlobal:= TC64Machine.Create(GlobalC64Config);

		FFirstTime:= False;
		end;
	end;

procedure TMonopolyRetroMainForm.MsgC64MachineUpdVideo(var AMsg: TMessage);
	var
	m: TMsg;

	begin
	while  PeekMessage(m, Handle, MSG_C64MACH_UPDATEVIDEO,
			MSG_C64MACH_UPDATEVIDEO, PM_NOYIELD or PM_REMOVE) do
		;

	DoUpdateFrame;
//	Application.ProcessMessages;
	end;

procedure TMonopolyRetroMainForm.Panel1MouseDown(Sender: TObject;
		Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
	begin
	if  Button = mbLeft then
		begin
		Mouse.Capture:= Panel1.Handle;

		C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Acquire;
		try
			C64MachineGlobal.FMultiIn.FUserBuffer.FMouseBtn:= 1;

			finally
			C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Release;
			end;
		end;
	end;

procedure TMonopolyRetroMainForm.Panel1MouseEnter(Sender: TObject);
	begin
	ShowCursor(False);

	C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Acquire;
	try
		C64MachineGlobal.FMultiIn.FUserBuffer.FMouseVis:= 1;

		finally
		C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Release;
		end;
	end;

procedure TMonopolyRetroMainForm.Panel1MouseLeave(Sender: TObject);
	begin
	ShowCursor(True);

	C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Acquire;
	try
		C64MachineGlobal.FMultiIn.FUserBuffer.FMouseVis:= 0;

		finally
		C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Release;
		end;
	end;

procedure TMonopolyRetroMainForm.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
	begin
	if  Button = mbLeft then
		begin
		Mouse.Capture:= 0;

		C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Acquire;
		try
			C64MachineGlobal.FMultiIn.FUserBuffer.FMouseBtn:= 0;

			finally
			C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Release;
			end;
		end;
	end;

procedure TMonopolyRetroMainForm.Timer1Timer(Sender: TObject);
	var
	state: TXInputState;
	j: Byte;
	pt: TPoint;

	begin
	if  FJoystickIdx > -1 then
		begin
		FillChar(state, SizeOf(state), 0);

		if  XInputGetState(FJoystickIdx, state) = ERROR_SUCCESS then
			begin
			if  state.dwPacketNumber <> 0 then
				if  state.dwPacketNumber <> FJoyState.dwPacketNumber then
					begin
					j:= 0;
					if  (state.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_UP) <> 0 then
						j:= j or $01;
					if  (state.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_DOWN) <> 0 then
						j:= j or $02;
					if  (state.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_LEFT) <> 0 then
						j:= j or $04;
					if  (state.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_RIGHT) <> 0 then
						j:= j or $08;
					if  (state.Gamepad.wButtons and XINPUT_GAMEPAD_A) <> 0 then
						j:= j or $10;

					C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Acquire;
					try
						C64MachineGlobal.FMultiIn.FUserBuffer.FJoy:= j;

						finally
						C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Release;
						end;

					FJoyState:= state;

					if  (state.Gamepad.wButtons and XINPUT_GAMEPAD_START) <> 0 then
						if  C64MachineGlobal.RunSignal.WaitFor(0) = wrSignaled then
							C64MachineGlobal.RunSignal.ResetEvent
						else
							C64MachineGlobal.RunSignal.SetEvent;
					end;
			end
		else
			begin
			FJoystickIdx:= -1;
			actInputJoystick.Checked:= False;
			end;
		end;

	pt:= ScreenToClient(Mouse.CursorPos);
	if  pt.X < 0 then
		pt.X:= 0;
	if  pt.X > ClientWidth then
		pt.X:= ClientWidth;

	if  pt.Y < 0 then
		pt.Y:= 0;
	if  pt.Y > ClientHeight then
		pt.Y:= ClientHeight;

	pt.X:= pt.X div FScale;
	pt.Y:= pt.Y div FScale;

	C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Acquire;
	try
		C64MachineGlobal.FMultiIn.FUserBuffer.FMouseY:= pt.Y div 2 + 30;
		C64MachineGlobal.FMultiIn.FUserBuffer.FMouseX:= pt.X div 2;

		finally
		C64MachineGlobal.FMultiIn.FUserBuffer.FLock.Release;
		end;
	end;

end.
