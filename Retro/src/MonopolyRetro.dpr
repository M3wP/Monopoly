program MonopolyRetro;

uses
  Vcl.Forms,
  FormMonopolyRetroMain in 'FormMonopolyRetroMain.pas' {MonopolyRetroMainForm},
  C64Classes in 'C64Classes.pas',
  C64Machine in 'C64Machine.pas',
  C64MachineConfig in 'C64MachineConfig.pas',
  C64Types in 'C64Types.pas',
  C64Thread in 'C64Thread.pas',
  XSIDTypes in 'XSIDTypes.pas',
  XSIDAudioDump in 'XSIDAudioDump.pas',
  C64Video in 'C64Video.pas',
  ReSIDFP in 'ReSIDFP.pas',
  C64SID in 'C64SID.pas',
  XSIDAudioOpenAL in 'XSIDAudioOpenAL.pas',
  openal in 'openal.pas',
  C64CPU in 'C64CPU.pas',
  C64Memory in 'C64Memory.pas',
  C64VICII in 'C64VICII.pas',
  dglOpenGL in 'dglOpenGL.pas',
  MR64User in 'MR64User.pas',
  XInput in 'XInput.pas',
  MR64Board in 'MR64Board.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMonopolyRetroMainForm, MonopolyRetroMainForm);
  Application.Run;
end.
