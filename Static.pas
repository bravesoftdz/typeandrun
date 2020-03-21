unit Static;

interface

uses Windows, SysUtils, Classes, Tlhelp32, Dialogs, Plugins, ShellApi, Forms, mmSystem;

function GetMyPath: string; // ���������� �����, ��� ��������� ��������� �� ������ � �����
function GetProgPath(Str: string): string; // �������� ����� �� ������� ���� (C:\Tmp\yo.exe -> C:\Tmp\)
function GetProgDrive(Str: string): string; // �������� ���� �� ������� ���� (C:\Tmp\yo.exe -> C:\)
function GetProgName(Str: string): string; // �������� ��� �� ������� ���� (C:\Tmp\yo.exe qwe rty -> C:\Tmp\yo.exe)
function GetProgParam(Str: string): string; // �������� ��������� �� ������� ���� (alias qwe rty -> qwe rty)
function GetLastDelimiter(Str: string): integer; // ���������� ������� ���������� ����� ��� 0, ���� �� � ������ ���
function IsWWW(Str: string): boolean; // ���������� true, ���� ���������� �������� - ��� ���������
function IsEmail(Str: string): boolean; // ���������� true, ���� ���������� �������� - ����� �����
function CorrectEMail(Str: string): string; // ��������� ������ �������� - %20
function BindHotKey(keyAlt, keyCtrl, keyShift, keyWin: boolean; keyCode: cardinal; id: integer; frmHadle: HWND): boolean; // �������� � ������� ������
procedure UnBindHotKey(id: integer; frmHadle: HWND); // ������ ���
function ParseConsole(strCon: string): boolean; // ������ ��� ������, ���������� � �������
function ParseAlias(Str: string): boolean; // ������ ������
function ParseSysAlias(Str: string): boolean; // ������ ��������� ������
function ParseInternal(Str: string): boolean; // ������ ���������� �������
function ParseWWW(Str: string): boolean; // ������ ������ ���������
function ParseEMail(Str: string): boolean; // ������ ������ �����
function ParseFolder(Str: string): boolean; // ������ ����� (����)
function ParseFile(Str: string): boolean; // ������ ����� (����)
function ParsePlugin(Str: string; FromAlias: boolean): boolean; // ������ �������
function ParseDOS(Str: string): boolean; // ������ DOS
function IsNumber(Str: string): boolean; // �������� �� ������ ����� ������
function KillZero(Str: string): string; // ������� ��������� ���� � ������
function GetWinVersion: String; // ���������� ������ windows
function KillTask(ExeFileName: string): integer; // ������� ������� �� ����� �����
function SetProcessPriority(Priority: integer): integer; // �������� ��������� ������ ��������
function GetProcessPriority: integer; // ���������� ��������� ������ ��������
function GetTypePath(Str: string; SelStart: integer): integer; // ���������� ����� �������, ��� ���������� ���������� ����
function GetDOSEnvVar(const VarName: string): string; // ���������� �������� ��������� ����������
function GetPathFolder(Str: string): string; // ���������� ������ ���� � �����, ���� �� ���� � ����� ����� �� ���������� PATH
function GetNumWord(Str, Separator: string; Num: integer): string; // ���������� ������ �� ����� ����� � ������ ������ � � ������ ������������
procedure SetKeyboardLayout(Str: string); // ������������� ������ ���������
function DriveState(DrvLetter: string): integer; // ���������� ��������� �����
function RunShell(action: string; param: string = ''; path: string = ''; state: integer = SW_ShowNormal; method: string = 'open'; handle: HWND = 0): HWND; // ��������� ����� ShellExecute � �������, ���������� ��
procedure PlayFile(FileName: string); // ����������� ��������� ����

const
	// ���������� ������� WinConsole
	InSide: array[1..14] of string=('/about',
																 '/checkconfig',
                                 '/config',
																 '/exit',
																 '/help',
																 '/hide',
																 '/homedir',
																 '/inidir',
																 '/inifiles',
																 '/load',
																 '/reread',
																 '/settings',
                                 '/show',
																 '/unload'{,
																 '/test'});
	Program_Name='TypeAndRun'; // �������� ���������
	Program_Version='4.7b11'; // ������ ���������
	HotKeyId=666; // Id �������� ������

var
	Program_Config: string; // �������� ������ �������
	Program_History: string; // �������� ������ �������
  Program_Config_Old: string; // ������ � �������� ��������
  Program_Plugin: string; // �������� ������ ��������

implementation

uses Configs, ForAll, frmConsoleUnit, StrUtils, Settings;

// ���������� �����, ��� ��������� ��������� �� ������ � �����
// ���������� ������� GetProgPath ��� ��������� ����
function GetMyPath: string;
begin
	Result:=GetProgPath(ParamStr(0));
end;

// �������� ����� �� ������� ���� (C:\Tmp\yo.exe -> C:\Tmp\)
// ���������� ������� GetLastDelimiter ��� ��������� ������� ���������� �����
// Str - ������ ����
function GetProgPath(Str: string): string;
begin
	if Copy(Str, 0, 1)='"' then
	  Result:=Copy(Str, 2, GetLastDelimiter(Str)-1)
  else
	  Result:=Copy(Str, 1, GetLastDelimiter(Str));
end;

// �������� ���� �� ������� ���� (C:\Tmp\yo.exe -> C:\)
// Str - ������ ����
function GetProgDrive(Str: string): string;
begin
  Result:=Copy(Str, 1, 3);
end;

// �������� ��� �� ������� ���� (C:\Tmp\yo.exe qwe rty -> C:\Tmp\yo.exe)
// Str - ������ ����
function GetProgName(Str: string): string;
var
	tmpStr, tmpProg, tmpParam: string;
begin
	tmpStr:=Trim(Str);
	tmpParam:='';
	if Copy(tmpStr, 0, 1)='"' then begin
		Delete(tmpStr, 1, 1);
		tmpProg:=Copy(tmpStr, 0, Pos('"', tmpStr)-1);
		Delete(tmpStr, 1, Length(tmpProg)+2);
		tmpParam:=tmpStr;
	end
	else if Pos(' ', tmpStr)<>0 then begin
		tmpProg:=Copy(tmpStr, 0, Pos(' ', tmpStr)-1);
		Delete(tmpStr, 1, Pos(' ', tmpStr));
		tmpParam:=tmpStr;
	end
	else
		tmpProg:=tmpStr;
	Result:=tmpProg;
	{if Pos(' ', Str)<> 0 then
		Result:=Copy(Str, 0, Pos(' ', str)-1)
	else
		Result:=Str;}
end;

// �������� ��������� �� ������� ���� (alias qwe rty -> qwe rty)
// Str - ������ ����
function GetProgParam(Str: string): string;
var
	tmpStr, tmpProg, tmpParam: string;
begin
	tmpStr:=Trim(Str);
	tmpParam:='';
	if Copy(tmpStr, 0, 1)='"' then begin
		Delete(tmpStr, 1, 1);
		tmpProg:=Copy(tmpStr, 0, Pos('"', tmpStr)-1);
		Delete(tmpStr, 1, Length(tmpProg)+2);
		tmpParam:=tmpStr;
	end
	else if Pos(' ', tmpStr)<>0 then begin
		tmpProg:=Copy(tmpStr, 0, Pos(' ', tmpStr)-1);
		Delete(tmpStr, 1, Pos(' ', tmpStr));
		tmpParam:=tmpStr;
	end
	else
		tmpProg:=tmpStr;
	Result:=tmpParam;
	{if Pos(' ', Str)<> 0 then
		Result:=Copy(Str, Pos(' ', str)+1, Length(Str)-Pos(' ', str)+1)
	else
		Result:='';}
end;

// ���������� ������� ���������� ����� ��� 0, ���� �� � ������ ���
// ��� ������� ������������, ��� ���� �������� ����� ����
// Str - ����
function GetLastDelimiter(Str: string): integer;
var
	i: integer;
begin
	for i:=length(Str) downto 0 do begin
		if Copy(Str, i, 1)='\' then Break;
	end;
	Result:=i;
end;

// ���������� true, ���� ���������� �������� - ��� ���������
// ���������� �� ��������� 'www.' ��� 'http://' � ������
// Str - ���
function IsWWW(Str: string): boolean;
begin
  Result:=(AnsiLowerCase(Copy(Str, 1, 4))=AnsiLowerCase('www.')) or (AnsiLowerCase(Copy(Str, 1, 7))=AnsiLowerCase('http://'));
end;

// ���������� true, ���� ���������� �������� - ����� �����
// � ������ ������ ���� ������� '@', � ����� '.' - ������ ��� ����
// Str - ����� �����
function IsEMail(Str: string): boolean;
begin
  if (Pos('@', Str)<>0) and (Copy(Str, 0, 1)<>'@') then begin
    Delete(Str, 1, Pos('@', Str));
   	Result:=(Pos('.', Str)<>0) and (Copy(Str, 0, 1)<>'.');
  end
  else
  	Result:=False;
end;

// ��������� ������ �������� - %20
// ��������� ��� ������� ����� ����� 'mailto:'
// Str - ����� ����� ��� �������� 
function CorrectEMail(Str: string): string;
begin
	while Pos(' ', Str)<>0 do begin
		Insert('%20', Str, Pos(' ', Str));
		Delete(Str, Pos(' ', Str), 1);
  end;
	Result:=Str;
end;

// �������� � ������� ������
// ������������ ���������: Alt, Ctrl, Shift, Win, ���� �������, Id ������ � Handle �����
// ������� ���������� True, ���� ������ ������ �����, ����� - False
function BindHotKey(keyAlt, keyCtrl, keyShift, keyWin: boolean; keyCode: cardinal; id: integer; frmHadle: HWND): boolean;
var
	ModKey: cardinal;
begin
	ModKey:=0;
	if keyAlt then ModKey:=ModKey+1;
	if keyCtrl then ModKey:=ModKey+2;
  if keyShift then ModKey:=ModKey+4;
	if keyWin then ModKey:=ModKey+8;
	Result:=RegisterHotkey(frmHadle, id, ModKey, keyCode);
end;

// ������ ������� ������
// ������������ ���������: Handle ����� � Id ������
procedure UnBindHotKey(id: integer; frmHadle: HWND);
begin
	UnRegisterHotkey(frmHadle, id);
end;

// ������ ��� ������, ���������� � �������, �� ������� ������������� �� ������ ����������
// ���������� TRUE, ���� ���-�� ������� ���������
// strCon - ����� � ������� �� ������ �������
function ParseConsole(strCon: string): boolean;
var
	IfExec: boolean;
//  tmpCon: string;
begin
	IfExec:=False;

{  while Pos(' & ', strCon)<>0 do begin
		tmpCon:=Copy(strCon, 0, Pos(' & ', strCon)-1);
    ShowMessage('|'+tmpCon+'|');
    Exit;
  end;}

	if (not IfExec) and Options.Exec.Internal then
		if ParseInternal(strCon) then IfExec:=True;
	if (not IfExec) and Options.Exec.Alias then
		if ParseAlias(strCon) then IfExec:=True;
	if (not IfExec) and Options.Exec.SysAlias then
		if ParseSysAlias(strCon) then IfExec:=True;
	if (not IfExec) and Options.Exec.WWW then
		if ParseWWW(strCon) then IfExec:=True;
	if (not IfExec) and Options.Exec.EMail then
		if ParseEMail(strCon) then IfExec:=True;
	if (not IfExec) and Options.Exec.Folders then
		if ParseFolder(strCon) then ifExec:=True;
	if (not IfExec) and Options.Exec.Files then
		if ParseFile(strCon) then IfExec:=True;
	if (not IfExec) and Options.Exec.Plugins then
		if ParsePlugin(strCon, False) then IfExec:=True;
	if (not IfExec) and Options.Exec.Shell then
		if ParseDOS(strCon) then IfExec:=True;
	IsShift:=False;
  IsParseCL:=False;
  IsParseMessage:=False;
 	Result:=IfExec;
end;

// ������ ���������� �������
// ���������� TRUE, ���� ������� ��������� ���������� �������
// Str - ���������� �������
function ParseInternal(Str: string): boolean;
var
	i: integer;
	IfExec: boolean;
begin
	IfExec:=False;
	for i:=1 to High(InSide) do begin
		if (GetProgName(Str)=Copy(InSide[i], 0, Length(Str))) or (not Options.EasyType.CaseSensitivity and (AnsiLowerCase(Str)=AnsiLowerCase(InSide[i]))) then begin
			IfExec:=True;
      HideCon;
			ExecInternal(i, GetProgParam(Str));
      SaveHistoryInternal(i, GetProgParam(Str));
			Break;
		end;
	end;
	Result:=IfExec;
end;

// ������ ������
// ���������� TRUE, ���� ������� ��������� ���� ���� �� ���
// Str - �����
function ParseAlias(Str: string): boolean;
var
	i: integer;
	IfExec: boolean;
  tmpStr: string;
begin
  IfExec:=False;
	for i:=0 to ConfigStr.Count-1 do begin
		if (GetProgName(Str)=GetName('alias', ConfigStr.Strings[i])) or (not Options.EasyType.CaseSensitivity and (AnsiLowerCase(GetProgName(Str))=AnsiLowerCase(GetName('alias', ConfigStr.Strings[i])))) then begin
    	HideCon;
			if not IsShift then begin
      	tmpStr:=GetName('action', ConfigStr.Strings[i]);
        if IsWWW(tmpStr) then begin
					InsertS(tmpStr, GetProgParam(Str));
					ExecWWW(tmpStr);
        end
        else begin
					ExecAlias(i, GetProgParam(Str));
        end;
			end
			else begin
      	tmpStr:=GetName('action', ConfigStr.Strings[i]);
        if IsWWW(tmpStr) then begin
          ExecAlias(i, GetProgParam(Str));
        end
        else
  				KillTask(ExtractFileName(tmpStr));
      end;
      SaveHistoryAlias(i, GetProgParam(Str));
      MoveTopConfig(i);
			IfExec:=True;
		end;
	end;
	Result:=IfExec;
end;

// ������ ��������� ������
// ���������� TRUE, ���� ������� ��������� ���� ���� �� ���
// Str - �����
function ParseSysAlias(Str: string): boolean;
var
	i: integer;
	IfExec: boolean;
begin
	IfExec:=False;
	for i:=0 to Options.SystemAliases.Name.Count-1 do begin
		if (GetProgName(Str)=Options.SystemAliases.Name.Strings[i]) or (not Options.EasyType.CaseSensitivity and (AnsiLowerCase(GetProgName(Str))=AnsiLowerCase(Options.SystemAliases.Name.Strings[i]))) then begin
    	HideCon;
			if not IsShift then begin
				ExecSysAlias(i, GetProgParam(Str));
				SaveSysHistoryAlias(i, GetProgParam(Str));
			end
			else
				KillTask(ExtractFileName(Options.SystemAliases.Action.Strings[i]));
			IfExec:=True;
		end;
	end;
	Result:=IfExec;
end;

// ������ ������ ���������
// ���������� TRUE, ���� ������� ��������� ����� ���������
// Str - ���
function ParseWWW(Str: string): boolean;
begin
	if IsWWW(Str) then begin
  	HideCon;
		ExecWWW(Str);
		SaveHistoryWWW(Str);
		Result:=True;
	end
	else
		Result:=False;
end;

// ������ ������ �����
// ���������� TRUE, ���� ������� ��������� ����� �����
// Str - ����� �����
function ParseEMail(Str: string): boolean;
begin
	if IsEmail(Str) then begin
  	HideCon;
		ExecEMail(Str);
		SaveHistoryEMail(Str);
		Result:=True;
	end
	else
		Result:=False;
end;

// ������ ����� (����)
// ���������� TRUE, ���� ������� ������� �����
// Str - ���� � �����
function ParseFolder(Str: string): boolean;
begin
	if DirectoryExists(Str) then begin
  	HideCon;
		ExecFolder(Str);
		SaveHistoryFolder(Str);
		Result:=True;
	end
	else
		Result:=False;
end;

// ������ ����� (����)
// Str - ���� � �����
function ParseFile(Str: string): boolean;
var
	tmpStr: string;
begin
	tmpStr:=Str;
 	while Pos('"', tmpStr)<>0 do begin
   	Delete(tmpStr, Pos('"', tmpStr), 1);
  end;
	if FileExists(tmpStr) then begin
  	HideCon;
		ExecFile(tmpStr, '', GetProgPath(Str));
		SaveHistoryDOS(Str);
		Result:=True;
	end
  else if FileExists(GetProgName(tmpStr)) then begin
  	HideCon;
		ExecFile(GetProgName(tmpStr), GetProgParam(Str), GetProgPath(tmpStr));
		SaveHistoryDOS(Str);
		Result:=True;
	end
  else if GetPathFolder(GetProgName(tmpStr))<>'' then begin
  	HideCon;
		ExecFile(GetPathFolder(GetProgName(tmpStr)), GetProgParam(Str), GetProgPath(tmpStr));
		SaveHistoryDOS(Str);
		Result:=True;
  end
	else
		Result:=False;
end;

// ������ �������
// Str - ���� � �����
// FromAlias - ���� ������ ������� �������� �� ������
function ParsePlugin(Str: string; FromAlias: boolean): boolean;
var
  i: integer;
  tmpParse: TExec;
begin
  Result:=False;
  for i:=0 to High(PluginDll) do begin
		tmpParse.con_text:='';
		tmpParse:=ExecPlugin(i, Str);
    if tmpParse.run<>0 then begin
      if tmpParse.run=2 then begin
        frmTARConsole.txtConsole.Text:=tmpParse.con_text;
        frmTARConsole.txtConsole.SelStart:=tmpParse.con_sel_start;
        frmTARConsole.txtConsole.SelLength:=tmpParse.con_sel_length;
      end
      else
      	HideCon;
      if (not FromAlias) and PluginDll[i].SaveHistory then SaveHistoryPlugin(Str);
      Result:=True;
      Break;
    end;
  end;
end;

// ������ DOS
// ��������� TRUE, ���� ������� ���������
// Str - ������ �� ������ ����� shell
function ParseDOS(Str: string): boolean;
begin
	if Options.Path.Shell<>'' then begin
	  HideCon;
		ExecDOS(Str);
		SaveHistoryDOS(Str);
		Result:=True
	end
	else
		Result:=False;
end;

// �������� �� ������ ����� ������
// Str - ������ ��� ��������
function IsNumber(Str: string): boolean;
var
	i: integer;
	flag: boolean;

  // �������� �� ������ ����� ������
  // Str - ������ ��� ��������
	function IsNum(Str: string): boolean;
	begin
    IsNum:=((Str='0') or (Str='1') or (Str='2') or (Str='3') or (Str='4') or (Str='5') or (Str='6') or (Str='7') or (Str='8') or (Str='9'));
	end;

begin
	flag:=False;
	for i:=0 to Length(Str) do begin
		if (not IsNum(Copy(Str, i, 1))) then flag:=True;
	end;
  Result:=not flag;
end;

// ������� ��������� ���� � ������
// Str - ������ ������
function KillZero(Str: string): string;
begin
	while (Copy(Str, 0, 1)='0') and (Length(Str)<>1) do
		Delete(Str, 1, 1);
	Result:=Str;
end;

// ���������� ������ windows
function GetWinVersion: String;
var
	VersionInfo: TOSVersionInfo;
	OSName: string;
begin
	VersionInfo.dwOSVersionInfoSize:= SizeOf(TOSVersionInfo);
	if Windows.GetVersionEx(VersionInfo) then begin
		with VersionInfo do begin
			case dwPlatformId of
				VER_PLATFORM_WIN32s: OSName:='Win32s';
				VER_PLATFORM_WIN32_WINDOWS: OSName:='Windows 95';
				VER_PLATFORM_WIN32_NT: OSName:='Windows NT';
			end;
			Result:=OSName+'|'+IntToStr(dwMajorVersion)+'|'+IntToStr(dwMinorVersion)+'|'+IntToStr(dwBuildNumber)+'|'+szCSDVersion;
		end;
	end
	else
		Result:='';
end;

// ������� ������� �� ����� �����
// ExeFileName - ��� �����
function KillTask(ExeFileName: string): integer;
const
	PROCESS_TERMINATE=$0001;
var
	ContinueLoop: boolean;
	FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result:= 0;
  FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
  ContinueLoop:=Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop)<>0 do begin
		if((UpperCase(ExtractFileName(FProcessEntry32.szExeFile))=UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile)=UpperCase(ExeFileName))) then
			Result:=Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
		ContinueLoop:=Process32Next(FSnapshotHandle, FProcessEntry32);
	end;
	CloseHandle(FSnapshotHandle);
end;

// �������� ��������� ������ ��������
// Priority - ���������:
// -1 - idle
// 0 - normal
// 1 - high
// 2 - realtime
function SetProcessPriority(Priority: integer): integer;
var
	H: THandle;
begin
	Result:=0;
	H:=GetCurrentProcess();
	if(Priority=-1) then
		SetPriorityClass(H, IDLE_PRIORITY_CLASS)
	else if (Priority=0) then
		SetPriorityClass(H, NORMAL_PRIORITY_CLASS)
	else if (Priority=1) then
		SetPriorityClass(H, HIGH_PRIORITY_CLASS)
	else if (Priority=2) then
		SetPriorityClass(H, REALTIME_PRIORITY_CLASS);
	case GetPriorityClass(H) Of
		IDLE_PRIORITY_CLASS: Result:=-1;
		NORMAL_PRIORITY_CLASS: Result:=0;
		HIGH_PRIORITY_CLASS: Result:=1;
		REALTIME_PRIORITY_CLASS: Result:=2;
	end;
end;

// ���������� ��������� ������ ��������
function GetProcessPriority: integer;
var
	H: THandle;
begin
	Result:=0;
	H:=GetCurrentProcess();
	case GetPriorityClass(H) Of
		IDLE_PRIORITY_CLASS: Result:=-1;
		NORMAL_PRIORITY_CLASS: Result:=0;
		HIGH_PRIORITY_CLASS: Result:=1;
		REALTIME_PRIORITY_CLASS: Result:=2;
	end;
end;

// ���������� ����� �������, ��� ���������� ���������� ����
function GetTypePath(Str: string; SelStart: integer): integer;
var
	Posit: integer;
begin
  Str:=Copy(Str, 0, SelStart);
  Posit:=0;
  while pos(':\', Str)<>0 do begin
    Posit:=Pos(':\', Str);
    Str[Posit]:='�';
    Str[Posit+1]:='�';
  end;
	Result:=Posit;
end;

// ���������� �������� ��������� ����������
// VarName - ��� ����������, �������� PATH
function GetDOSEnvVar(const VarName: string): string;
var
	i: integer;
begin
	Result:='';

  try
    i:=GetEnvironmentVariable(PChar(VarName), nil, 0);
    if i>0 then begin
      SetLength(Result, i-1);
      GetEnvironmentVariable(Pchar(VarName), PChar(Result), i);
    end
    else begin
      Result:='';
    end;
  except
    Result:='';
  end;
end;

// ���������� ������ ���� � �����, ���� �� ���� � ����� ����� �� ���������� PATH
// Str - ��� �����
function GetPathFolder(Str: string): string;
var
	strPATH, tmpPath: string;
  tmpPos: integer;
  i: integer;
const
  extArr: array[1..10] of string=('.com', '.exe', '.bat', '.cmd', '.vbs', '.vbe', '.js', '.jse', '.wsf', '.wsh');
begin
	strPATH:=GetDOSEnvVar('PATH');
  while Pos(';', strPATH)<>0 do begin
  	tmpPos:=Pos(';', strPATH);
    tmpPath:=Copy(strPATH, 0, tmpPos-1);
    // ���� ����� ���� ���� � ����� �������
    if FileExists(tmpPath + '\' + Str) then begin
      Result:=tmpPath + '\' + Str;
      Exit;
    end;
    // ���� ��� - ������� ����������� ������ ����������� ����������
    for i:=1 to High(ExtArr) do begin
      if FileExists(tmpPath + '\' + Str + extArr[i]) then begin
        Result:=tmpPath + '\' + Str;
        Exit;
      end;
    end;
    Delete(strPATH, 1, tmpPos);
  end;
  Result:='';
end;

// ���������� ������ �� ����� ����� � ������ ������ � � ������ ������������
// Str - ����������� ������
// Separator - ����������� ����
// Num - ������ �� ����� ����� �����
function GetNumWord(Str, Separator: string; Num: integer): string;
var
  i: integer;
  tmpStr: string;
begin
  i:=0;
  tmpStr:=Str;
  while Pos(Separator, tmpStr)<>0 do begin
    Inc(i);
    Insert('�', tmpStr, Pos(Separator, tmpStr));
    Delete(tmpStr, Pos(Separator, tmpStr), 1);
  end;
  if Num>i+1 then begin
    Result:='';
  end
  else begin
    i:=0;
    Str:=Str+Separator;
    while i+1<=Num do begin
      tmpStr:=Copy(Str, 1, Pos(Separator, Str)-1);
      Delete(Str, 1, Pos(Separator, Str)+Length(Separator)-1);
      Inc(i);
    end;
    Result:=tmpStr;
  end;
end;

// ������������� ������ ���������
// Str - ��� ������ ���������
procedure SetKeyboardLayout(Str: string);
var
  Layout: array [0..KL_NAMELENGTH] of char;
begin
  LoadKeyboardLayout(StrCopy(Layout, PChar(Str)), KLF_ACTIVATE);
end;

// ���������� ��������� �����
// DrvLetter - ����� �����+':'
function DriveState(DrvLetter: string): integer;
var
  SearchRec: TSearchRec;
  oldMode: Cardinal;
  ReturnCode: Integer;
begin
  oldMode:=SetErrorMode(SEM_FAILCRITICALERRORS);
  {$I-}
  ReturnCode:=FindFirst(DrvLetter+'\*.*', faAnyfile, SearchRec);
  FindClose(SearchRec);
  {$I+}
  Result:=ReturnCode;
  SetErrorMode(oldMode);
end;

// ��������� ����� ShellExecute � �������, ���������� ��
function RunShell(action: string; param: string = ''; path: string = ''; state: integer = SW_ShowNormal; method: string = 'open'; handle: HWND = 0): HWND;
begin
	if handle=0 then
		handle:=Application.Handle;
	if (method='') and not Options.Exec.DefaultAction then
		method:='open';
	Result:=ShellExecute(handle, PAnsiChar(method), PAnsiChar(action), PAnsiChar(param), PAnsiChar(path), state);
end;

// ����������� ��������� ����
procedure PlayFile(FileName: string);
var
	tmpFile: PChar;
begin
	if Options.Sounds.EnableSounds then begin
		tmpFile:='';
		if FileExists(FileName) then
			tmpFile:=PChar(FileName)
		else if FileExists(GetMyPath + FileName) then
			tmpFile:=PChar(GetMyPath + FileName);
		if tmpFile<>'' then
			PlaySound(tmpFile, 0, SND_ASYNC or SND_FILENAME);
	end;
end;

end.
