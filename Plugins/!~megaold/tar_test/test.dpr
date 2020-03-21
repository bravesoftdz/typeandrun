// ������ ���� ������� TypeAndRun 4.5.0.
// Copyright �2003 by -=GaLaN=- (Evgeniy Galantsev)

library test;

uses
  Windows,
  SysUtils,
  Forms;

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
	tmpList: array of string; // ������ ����� �������
  tmp: TForm;

// ����������� ��� �������� dll
// WinHWND - ����� �������� ����
procedure Load(WinHWND: HWND); cdecl;
begin
  // ������������� 3-� ������� ��� �������
	SetLength(tmpList, 1);
  tmpList[0]:='~showform';
end;
exports Load;

// ����������� ��� �������� dll
procedure Unload; cdecl;
begin
  SetLength(tmpList, 0);
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
	info.name:='test';
  info.version:='0.0.0.1 prealfa';
  info.description:='Testing plugin interface';
  info.author:='Evgeniy Galanstev (-=GaLaN=-)';
  info.copyright:='Copyright �2003 Evgeniy Galanstev';
  info.homepage:='http://galan.dogmalab.ru/';
	Result:=info;
end;
exports GetInfo;

// ���������� ���������� ����� � ������ � dll
function GetCount: integer; cdecl;
begin
	Result:=High(tmpList)+1;
end;
exports GetCount;

// ���������� ������ ������ �� ������ � dll
// num - ����� ������ ������
function GetString(num: integer): PChar; cdecl;
begin
	Result:=PChar(tmpList[num]);
end;
exports GetString;

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
    // ���� ����������� ������ ��������� � ����� �� �������
  	if tmpList[0]=str then begin
      // �� ���������� 1 - ���� ����� � ������� �������� �� ����� � 2 - ���� �����
      exec.run:=1;
		  tmp.Create(nil);
//		  tmp.Visible:=false;
//		  tmp.Run;
//			tmp.Show;
    end;
  Result:=exec;
end;
exports RunString;

end.
