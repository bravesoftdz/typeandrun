unit frmTARHookUnit;

interface

uses
	Windows, Messages, Forms, Classes, SysUtils;

type
	TfrmTARHook = class(TForm)
	private
		procedure WMHotkey(var Msg: TWMHotkey); message WM_HOTKEY;
	public
		procedure SendText(WinHandle: HWND; txtText: string);
		function BindHotKey(keyAlt, keyCtrl, keyShift, keyWin: boolean; keyCode: cardinal; Id: integer; frmHadle: HWND): boolean;
		procedure UnBindHotKey(Id: integer; frmHadle: HWND);
		procedure ReadConfig(FileName: string);
		function GetName(Query, Stroka: string): string;
		function getCode(str: string): integer;
  end;

var
	frmTARHook: TfrmTARHook;
	ConsoleHWND: HWND;
	DllFileName: Array[0..MAX_PATH] of Char; // ���� � dll'��� - ����� ��� ����������� �����, ��� ������� ���������
	ConfigStr: TStringList;

const
	hStr: array[1..21] of string=('`', '-', '=', '\', ';', '''', ',', '.', '/', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F11');
	hCode: array[1..21] of integer=(192, 189, 187, 220, 186, 222, 188, 190, 191, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123);

implementation

{$R *.dfm}

function TfrmTARHook.getCode(str: string): integer;
var
	i: integer;
	code: integer;
begin
	code:=0;
	for i:=1 to 21 do begin
		if UpperCase(hStr[i])=UpperCase(str) then
			code:=hCode[i];
	end;
	if code=0 then code:=Ord(UpperCase(str)[1]);
	getCode:=code;
end;

// ������ ������ �� �������
// FileName - ��� �����
procedure TfrmTARHook.ReadConfig(FileName: string);
begin
	ConfigStr:=TStringList.Create;
	if FileExists(FileName) then begin
		ConfigStr.LoadFromFile(FileName);
	end
	else
		ConfigStr.SaveToFile(FileName);
end;

// ���������� ��� ������ ������������ �������
// Query - ������ �������. ����������� - � ����� �������
// Stroka - ������ �������� ������.
function TfrmTARHook.GetName(Query, Stroka: string): string;
var
	TempStr: string;
	str: array[1..3] of string;
	i: integer;
begin
	TempStr:=Stroka;
	for i:=1 to 3 do str[i]:='';
	str[1]:=Copy(TempStr, 1, Pos('|', TempStr)-1);
	Delete(TempStr, 1, Pos('|', TempStr));
	for i:=2 to 3 do begin
		if(Pos('|', TempStr)<>0) then begin
			str[i]:=Copy(TempStr, 1, Pos('|', TempStr)-1);
			Delete(TempStr, 1, Pos('|', TempStr));
		end
		else begin
			str[i]:=TempStr;
			break;
		end;
	end;
	// ��������� ������� � ������� ������� �� ���:
	// ������������
	if Query='mods' then Result:=str[1];
	// �������
	if Query='hotkey' then Result:=str[2];
	// ��������. ����� ������ - ����������� ���������
	if Query='action' then Result:=str[3];
end;

// �������� � ������� ������
// ������������ ���������: Alt, Ctrl, Shift, Win, ���� �������, Id ������ � Handle �����
// ������� ���������� True, ���� ������ ������ �����, ����� - False
function TfrmTARHook.BindHotKey(keyAlt, keyCtrl, keyShift, keyWin: boolean; keyCode: cardinal; Id: integer; frmHadle: HWND): boolean;
var
	ModKey: cardinal;
begin
	ModKey:=0;
	if keyAlt then ModKey:=ModKey+1;
	if keyCtrl then ModKey:=ModKey+2;
  if keyShift then ModKey:=ModKey+4;
	if keyWin then ModKey:=ModKey+8;
	Result:=RegisterHotkey(frmHadle, Id, ModKey, keyCode);
end;

// ������ ������� ������
// ������������ ���������: Handle ����� � Id ������
procedure TfrmTARHook.UnBindHotKey(Id: integer; frmHadle: HWND);
begin
	UnRegisterHotkey(frmHadle, Id);
end;

// �������� ����� ����
// WinHandle - ����� ����
// txtText - ���������� ������
procedure TfrmTARHook.SendText(WinHandle: HWND; txtText: string);
var
	Data: TCopyDataStruct;
	s: string;
begin
	s:=txtText;
	Data.dwData := 0;
	Data.cbData := Length(s);
	Data.lpData := @s[1];
	SendMessage(WinHandle, WM_COPYDATA, 0, integer(@Data));
end;

// ����������� ��� ������� �������� ���������� ������
procedure TfrmTARHook.WMHotkey(var Msg: TWMHotkey);
begin
	if msg.HotKey-1000 >=0 then
		SendText(ConsoleHWND, GetName('action', ConfigStr.Strings[msg.HotKey-1000]));
end;

end.
