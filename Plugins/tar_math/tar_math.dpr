// tar_math v1.6
// Copyright � Evgeniy Galantsev 2003-2005

library tar_math;

uses
	Math,
	SysUtils,
	IniFiles,
	Windows,
  FuncParser in 'FuncParser.pas';

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

var
  pf: TParsedFunction; // ����� ��������������� �������
  DllFileName: Array[0..MAX_PATH] of Char; // ���� � dll'��� - ����� ��� ����������� �����, ��� ������� ���������
  SelectAnswer: boolean; // �������� �� ����� � �������
  CopyToClipboard: boolean; // ���������� �� ����� � ����� ������
  UseEqual: boolean; // ������������ �� ������ = ��� ����������� ���������
	UseOriginal: boolean; // ������������ �� ������������ ��������� � ������
	Round: boolean; // ��������� �� �����
	RoundLimit: integer; // ��������� - ������� ������ ����� �������

// ������ ����� � ����� ������
procedure SetClipboard(Buffer: PChar);
var
  Data: THandle;
  DataPtr: Pointer;
begin
  try
    OpenClipboard(0);
    try
      EmptyClipboard;
      Data:=GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, StrLen(Buffer)+1);
      try
        DataPtr:=GlobalLock(Data);
        try
          Move(Buffer^, DataPtr^, StrLen(Buffer)+1);
          SetClipboardData(CF_TEXT, Data);
        finally
          GlobalUnlock(Data);
        end;
      except
        GlobalFree(Data);
        raise;
      end;
    finally
      CloseClipboard;
    end;
  finally
    CloseClipboard;
  end;
end;

// ��������� ��������� �� ������
procedure LoadSettings;
var
  IniFile: TMemIniFile;
begin
  IniFile:=TMemIniFile.Create(ExtractFilePath(DllFileName)+'\tar_math.ini');
  SelectAnswer:=IniFile.ReadBool('General', 'SelectAnswer', True);
  CopyToClipboard:=IniFile.ReadBool('General', 'CopyToClipboard', True);
  UseEqual:=IniFile.ReadBool('General', 'UseEqual', True);
	UseOriginal:=IniFile.ReadBool('General', 'UseOriginal', True);
	Round:=IniFile.ReadBool('General', 'Round', True);
	RoundLimit:=IniFile.ReadInteger('General', 'RoundLimit', 13);
	if (RoundLimit<0) or (RoundLimit>13) then
		RoundLimit:=13;  
  IniFile.Destroy;
end;

// ��������� ��������� � ������
procedure SaveSettings;
var
  IniFile: TMemIniFile;
begin
  IniFile:=TMemIniFile.Create(ExtractFilePath(DllFileName)+'\tar_math.ini');
  IniFile.WriteBool('General', 'SelectAnswer', SelectAnswer);
  IniFile.WriteBool('General', 'CopyToClipboard', CopyToClipboard);
  IniFile.WriteBool('General', 'UseEqual', UseEqual);
	IniFile.WriteBool('General', 'UseOriginal', UseOriginal);
	IniFile.WriteBool('General', 'Round', Round);
	IniFile.WriteInteger('General', 'RoundLimit', RoundLimit);
  IniFile.UpdateFile;
  IniFile.Destroy;
end;

// ����������� ��� �������� dll
// WinHWND - ����� �������� ����
procedure Load(WinHWND: HWND); cdecl;
begin
  GetModuleFileName(HInstance, DllFileName, MAX_PATH); // ��������� ������ ���� � tar_math.dll
  pf:=TParsedFunction.create;
	LoadSettings; // ��������� ���������
end;
exports Load;

// ����������� ��� �������� dll
procedure Unload; cdecl;
begin
  pf.Destroy;
	//SaveSettings; // ���������� ��������
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
	info.name:='tar_math';
  info.version:='1.6';
  info.description:='Console calculator plugin';
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
	tmpStr, AnswerText: string;
	ec: byte;
begin
	// ������������� ������������ ���������
	exec.size:=SizeOf(TExec);
	exec.run:=0;
	exec.con_text:='';
	exec.con_sel_start:=0;
	exec.con_sel_length:=0;
	tmpStr:=str;
	// ���� ������ ������������ �� '=', �� ������
	if (Copy(tmpStr, Length(tmpStr), 1)='=') and UseEqual then
		tmpStr:=Copy(tmpStr, 0, Length(tmpStr)-1)
	else if UseEqual then
		exit;
	pf.ParseFunction(tmpStr, ec);
	// ���� ����������� �������� ���������
	if ec=0 then begin
		exec.run:=2;
		if Round then begin
			AnswerText:=FloatToStr(RoundTo(pf.Compute(0, 0, 0), -RoundLimit));
		end
		else begin
			AnswerText:=FloatToStr(pf.Compute(0, 0, 0));
		end;
		AnswerText:=Trim(AnswerText);
		while pos(',', AnswerText)<>0 do begin
			Insert('.', AnswerText, pos(',', AnswerText));
			Delete(AnswerText, pos(',', AnswerText), 1);
		end;
		if UseOriginal then begin
			if UseEqual then
				tmpStr:=tmpStr+'='+AnswerText
			else
				tmpStr:=tmpStr+AnswerText;
		end
		else
			tmpStr:=AnswerText;
		//exec.con_text:=PChar(tmpStr+'='+AnswerText);
		exec.con_text:=PChar(tmpStr);
		// � ����������� �� ��������� �������� ����� ��� ���
    if SelectAnswer then begin
    	if UseOriginal then begin
	      exec.con_sel_start:=Length(str);
	      exec.con_sel_length:=Length(AnswerText);
      end
      else begin
				exec.con_sel_start:=0;
	      exec.con_sel_length:=Length(AnswerText);
      end;
    end
    else begin
    	if UseOriginal then begin
	    	exec.con_sel_start:=Length(str);
	      exec.con_sel_length:=0;
			end;
    end;
    // ���� ���������, �� �������� ������ � ����� ������
    if CopyToClipboard then
      SetClipboard(PChar(AnswerText));
  end;
	Result:=exec;
end;
exports RunString;

end.
