// tar_hotkeys - �������� ��������� ������ � ����������� �� � ������������ �������� � �������
// Copyright � Evgeniy Galantsev 2003-2005

library tar_hotkeys;

uses
	Windows,
  SysUtils,
  frmTARHookUnit in 'frmTARHookUnit.pas' {frmTARHook};

type
	TInfo=record
  	size: integer; // ������ ���������
  	plugin: PChar; // ����������� ������ 'Hello! I am the TypeAndRun plugin.' - ��� ����������� �������
		name: PChar; // �������� �������
		version: PChar; // ��� ������
    description: PChar; // ������� �������� ����������������
    author: PChar; // ����� �������
    copyright: PChar; // ����� �� ������
		homepage: PChar; // �������� �������� �������
  end;
  TExec=record
  	size: integer; // ������ ���������  
    run: integer; // ����������, ����������� �� ������
    con_text: PChar; // ���� ���� ���������� ����� � �������
    con_sel_start: integer; // ������ ��������� ������ � �������
    con_sel_length: integer; // ����� ���������
	end;

// ����������� ��� �������� dll
// WinHWND - ����� �������� ����
procedure Load(WinHWND: HWND); cdecl;
var
	i: integer;
	hAlt, hShift, hCtrl, hWin: boolean;
begin
	frmTARHook:=TfrmTARHook.Create(nil);
	ConsoleHWND:=WinHWND;
	GetModuleFileName(HInstance, DllFileName, MAX_PATH); // ��������� ������ ���� � dll
	frmTARHook.ReadConfig(ExtractFilePath(DllFileName)+'\tar_hotkeys.ini');
	for i:=0 to ConfigStr.Count-1 do begin
		if Pos('A', UpperCase(frmTARHook.GetName('mods', ConfigStr.Strings[i])))<>0 then hAlt:=True else hAlt:=False;
		if Pos('S', UpperCase(frmTARHook.GetName('mods', ConfigStr.Strings[i])))<>0 then hShift:=True else hShift:=False;
		if Pos('C', UpperCase(frmTARHook.GetName('mods', ConfigStr.Strings[i])))<>0 then hCtrl:=True else hCtrl:=False;
		if Pos('W', UpperCase(frmTARHook.GetName('mods', ConfigStr.Strings[i])))<>0 then hWin:=True else hWin:=False;
		frmTARHook.BindHotKey(hAlt, hCtrl, hShift, hWin, frmTARHook.getCode(frmTARHook.GetName('hotkey', ConfigStr.Strings[i])), 1000+i, frmTARHook.Handle);
	end;
end;
exports Load;

// ����������� ��� �������� dll
procedure Unload; cdecl;
var
	i: integer;
begin
	for i:=0 to ConfigStr.Count-1 do
		frmTARHook.UnBindHotKey(1000+i, frmTARHook.Handle);
  ConfigStr.Free;
  frmTARHook.Free;
end;
exports Unload;

// �������� ��� �������������� dll � �������� TypeAndRun
// � ������� ���������� � �������
function GetInfo: TInfo; cdecl;
var
	info: TInfo;
begin
	info.size:=SizeOf(TInfo);
	info.plugin:='Hello! I am the TypeAndRun plugin.';
	info.name:='tar_hotkeys';
	info.version:='1.0';
	info.description:='Hotkey manager (string executing) for TypeAndRun';
	info.author:='Evgeniy Galantsev (-=GaLaN=-)';
  info.copyright:='Copyright � Evgeniy Galantsev 2003-2005';
  info.homepage:='http://galanc.com/';
	Result:=info;
end;
exports GetInfo;

// ������ ������ � ������� ������� - ����������, ������ �� ������ � ������, ������������ � �������
// str - ����������� ������
function RunString(str: PChar): TExec; cdecl;
var
	exec: TExec;
begin
	// ������������� ������������ ���������
	exec.size:=SizeOf(TExec);
	exec.run:=0;
	exec.con_text:='';
	exec.con_sel_start:=0;
	exec.con_sel_length:=0;
  Result:=exec;
end;
exports RunString;

end.
