unit Configs;

interface

uses Forms, IniFiles, Graphics, Classes, SysUtils, Registry, Windows, Dialogs, AlignEdit, CoolTrayIcon;

// ������ � �����������
procedure ApplySettings; // ��������� ���������

// ������ � ��������
procedure ReadConfig(FileName: string); // ������ ������
procedure SaveConfig(FileName: string); // ��������� ������
function GetName(Query, Stroka: string): string; // ���������� ��� ������ ������������ �������
procedure MoveTopConfig(Num: integer); // ������ ����� � ������ �������
function GetFullString(Name, Action, Param, Path, State, History, MoveTop, Priori, Comment: string): string; // ��������� ���������� ������ � ���� ������
procedure GetEdit(Num: integer); // ���������� ���� ��� ��������������
procedure SetEdit(Num: integer; Query: string); // ��������� ���������, ��������� � ���� ��������������
procedure GetFullEdit; // ��������� ���� ������� ������
procedure MoveItem(Start, Finish: integer); // ����������� ������ � �������
procedure AddItem; // ���������� ������ � ������
procedure DelItem(Num: integer); // �������� ������ �� �������

// ������ � ��������
procedure ReadHistory(FileName: string); // ������ �������
procedure SaveHistory(FileName: string); // ��������� �������
procedure AddHistory(Str: string); // ��������� �������
procedure SaveHistoryInternal(Num: integer; Str: string); // ��������� ��������� ���������� ������� � �������
procedure SaveHistoryAlias(Num: integer; Str: string); // ��������� ��������� ����� � �������
procedure SaveSysHistoryAlias(Num: integer; Str: string); // ��������� ��������� ��������� ����� � �������
procedure SaveHistoryWWW(Str: string); // ��������� ��������� ��� � �������
procedure SaveHistoryEMail(Str: string); // ��������� ��������� ����� ����� � �������
procedure SaveHistoryFolder(Str: string); // ��������� ��������� ����� � �������
procedure SaveHistoryPlugin(Str: string); // ��������� ��������� ������ � �������
procedure SaveHistoryDOS(Str: string); // ��������� ��������� ���� � �������
procedure HistoryUp; // ����������� ������� �����
procedure HistoryDown; // ����������� ������� ����

// ������ � �������
function GetLangStr(Name: string): string; // ���������� ������ ������ � �������� ������
function GetConstStr(Str: string): string; // ���������� ������ �� ������������ �����������
procedure SetLanguages; // ������������� ����

var
	ConfigStr: TStringList; // ������ ����� �� �������
	HistoryStr: TStringList; // ������ ����� �� �������
	HisViewPos: integer; // ������� ��������� �������

implementation

uses Static, ForAll, frmConsoleUnit, frmSettingsUnit, frmAboutUnit, Plugins, StrUtils, Settings;

// ��������� ���������
procedure ApplySettings;
begin
	Application.ShowMainForm:=False;
	SetProcessPriority(Options.Show.Priority);
	if Options.Show.ConsoleWidthPercent then
		frmTARConsole.Width:=round(Options.Show.ConsoleWidth/100*Screen.Width)
	else
		frmTARConsole.Width:=Options.Show.ConsoleWidth;
	frmTARConsole.Height:=Options.Show.ConsoleHeight;
	if Options.Show.CenterScreenX then
		frmTARConsole.Left:=Screen.Width div 2-frmTARConsole.Width div 2
	else
		frmTARConsole.Left:=Options.Show.ConsoleX;
	if Options.Show.CenterScreenY then
		frmTARConsole.Top:=Screen.Height div 2-frmTARConsole.Height div 2
	else
		frmTARConsole.Top:=Options.Show.ConsoleY;
	frmTARConsole.txtConsole.Top:=0;
	frmTARConsole.txtConsole.Left:=0;
	frmTARConsole.txtConsole.Width:=frmTARConsole.Width-2*Options.Show.BorderSize;
	frmTARConsole.txtConsole.Height:=frmTARConsole.Height-2*Options.Show.BorderSize;
	frmTARConsole.txtConsole.Color:=Options.Color[Options.EasyType.EasyType].Console;
	if Options.Show.Transparent=255 then begin
		frmTARConsole.AlphaBlend:=False;
	end
	else begin
		frmTARConsole.AlphaBlend:=True;
		frmTARConsole.AlphaBlendValue:=Options.Show.Transparent;
	end;
	frmTARConsole.TransparentColorValue:=Options.Color[Options.EasyType.EasyType].Console;
	frmTARConsole.TransparentColor:=Options.Show.DestroyForm;
	frmTARConsole.BorderWidth:=Options.Show.BorderSize;
	frmTARConsole.Color:=Options.Color[Options.EasyType.EasyType].Border;
	frmTARConsole.trayIcon.IconVisible:=Options.Show.TrayIcon;
	tmrAutoHide.Interval:=Options.Show.AutoHideValue;
	frmTARConsole.txtConsole.Font.Name:=Options.Font.Name;
	if Options.Font.AutoSize then
		frmTARConsole.txtConsole.Font.Height:=frmTARConsole.Height-2*Options.Show.BorderSize
	else
		frmTARConsole.txtConsole.Font.Size:=Options.Font.Size;
	if Options.Font.Bold then frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style+[fsBold] else frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style-[fsBold];
	if Options.Font.Italic then frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style+[fsItalic] else frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style-[fsItalic];
	if Options.Font.StrikeOut then frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style+[fsStrikeOut] else frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style-[fsStrikeOut];
	if Options.Font.UnderLine then frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style+[fsUnderLine] else frmTARConsole.txtConsole.Font.Style:=frmTARConsole.txtConsole.Font.Style-[fsUnderLine];
	if Options.Font.Align=1 then
		frmTARConsole.txtConsole.Alignment:=eaCenter
	else if Options.Font.Align=2 then
  	frmTARConsole.txtConsole.Alignment:=eaRight
  else
  	frmTARConsole.txtConsole.Alignment:=eaLeft;
	frmTARConsole.txtConsole.Font.Color:=Options.Color[Options.EasyType.EasyType].Text;
	frmTARConsole.mnuUndo.Visible:=Options.Undo.UseUndo;
	UnBindHotKey(HotKeyId, frmTARConsole.Handle);
	if not BindHotKey(Options.Hotkey.AltKey, Options.Hotkey.CtrlKey, Options.Hotkey.ShiftKey, Options.Hotkey.WinKey, Options.Hotkey.Key, HotKeyId, frmTARConsole.Handle) then begin
		frmTARConsole.trayIcon.IconVisible:=True;
		ShowMes(GetLangStr('cannotusehotkey'));
	end;

	tmrAutoReread.Interval:=Options.Config.AutoRereadValue;
	tmrAutoReread.Enabled:=Options.Config.AutoReread;
  if Options.EasyType.EasyType=0 then
  	frmTARConsole.mnuToggleET.Checked:=False
  else
    frmTARConsole.mnuToggleET.Checked:=True;
	SetLanguages;
end;

// ������ ������ �� �������
// FileName - ��� �����
procedure ReadConfig(FileName: string);
begin
	if FileExists(FileName) then begin
		ConfigStr.LoadFromFile(FileName);
  end
	else
		ConfigStr.SaveToFile(FileName);
end;

// ��������� ������ � ������
// FileName - ��� �����
procedure SaveConfig(FileName: string);
begin
	if Options.Config.AutoSort then ConfigStr.Sort;
	ConfigStr.SaveToFile(FileName);
end;

// ���������� ��� ������ ������������ �������
// Query - ������ �������. ����������� - � ����� �������
// Stroka - ������ �������� ������.
function GetName(Query, Stroka: string): string;
var
	TempStr: string;
	str: array[1..9] of string;
	i: integer;
begin
	TempStr:=Stroka;
	for i:=1 to 9 do str[i]:='';
	str[1]:=Copy(TempStr, 1, Pos('|', TempStr)-1);
	Delete(TempStr, 1, Pos('|', TempStr));
	for i:=2 to 9 do begin
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
	// �������� ������
	if Query='alias' then Result:=str[1];
	// ��������. ����� ������ - ����������� ���������
	if Query='action' then Result:=str[2];
	// ���������, ������������ ���������
	if Query='param' then Result:=str[3];
	// ����, ������� �������� ������� ��� ����������� ���������
	if Query='dir' then Result:=str[4];
	// ���������, � ������� ����������� ���������:
	// 0 - �������
	// 1 - ���������
	// 2 - ���������
	// 3 - �����������
	// 4 - ���������� ��� ������
	// 5 - ��������� ��� ������
	if Query='state' then Result:=str[5];
	// ��������� �� ����������� � ���� ���������� ��������� � �������
	// 0 - ��� � ����������
	// 1 - ������ (���� �������� ����)
	// 2 - �������
	if Query='history' then Result:=str[6];
	// ������ �� ���� ����� ������ � ������� ����� ��� �������
	// 0 - ��� � ����������
	// 1 - ������
	// 2 - �������
	if Query='top' then Result:=str[7];
	// ���������, � ������� ����������� ���������
	// -1 - Low
	// 0 - Normal
	// 1 - High
	// 2 - Realtime
	if Query='priori' then Result:=str[8];
  // ����������� � ������
  if Query='comment' then Result:=str[9];
end;

// ������ ����� � ������ �������
// Num - ����� ������ � �������
procedure MoveTopConfig(Num: integer);
begin
	If (Options.Config.MoveTop) or (GetName('top', ConfigStr.Strings[Num])='1') then begin
		If GetName('top', ConfigStr.Strings[Num])<>'2' then begin
			ConfigStr.Move(Num, 0);
			//SaveConfig(Program_Config);
		end;
	end;
end;

// ��������� ���������� ������ � ���� ������
// Name - ��� ������
// Action - ����������� ��������
// Param - ���������
// Path - ��������� ����
// State - ��������� ����
// History - ��������� �� � �������
// MoveTop - ������ �� ������ �������
// Priori - ��������� ���������� ���������
// Comment - ����������� � ������
function GetFullString(Name, Action, Param, Path, State, History, MoveTop, Priori, Comment: string): string;
var
	OutStr: string;
	Flag: boolean;
begin
	OutStr:='';
	Flag:=False;
	// Comment
	if (Comment<>'') then begin
		OutStr:='|'+Comment;
		Flag:=True;
	end;
	// Priori
	if Flag then begin
		if ((Priori<>'') and (Priori<>'0')) then
			OutStr:='|'+Priori+OutStr
		else
			OutStr:='|'+OutStr;
	end
	else begin
		if ((Priori<>'') and (Priori<>'0')) then begin
			OutStr:='|'+Priori+OutStr;
			Flag:=True;
		end;
	end;
  // MoveTop
	if Flag then begin
		if ((MoveTop<>'') and (MoveTop<>'0')) then
			OutStr:='|'+MoveTop+OutStr
		else
			OutStr:='|'+OutStr;
	end
	else begin
		if ((MoveTop<>'') and (MoveTop<>'0')) then begin
			OutStr:='|'+MoveTop+OutStr;
			Flag:=True;
		end;
	end;
  // Hystory
	if Flag then begin
		if ((History<>'') and (History<>'0')) then
			OutStr:='|'+History+OutStr
		else
			OutStr:='|'+OutStr;
	end
	else begin
		if ((History<>'') and (History<>'0')) then begin
			OutStr:='|'+History+OutStr;
			Flag:=True;
		end;
	end;
	// State
	if Flag then begin
		if ((State<>'') and (State<>'1')) then
			OutStr:='|'+State+OutStr
		else
			OutStr:='|'+OutStr;
	end
	else begin
		if ((State<>'') and (State<>'1')) then begin
			OutStr:='|'+State+OutStr;
			Flag:=True;
		end;
	end;
  // Path
	if Flag then begin
		if (Path<>'') then
			OutStr:='|'+Path+OutStr
		else
			OutStr:='|'+OutStr;
	end
	else begin
		if (Path<>'') then begin
			OutStr:='|'+Path+OutStr;
			Flag:=True;
		end;
	end;
  // Param
	if Flag then begin
		if (Param<>'') then
			OutStr:='|'+Param+OutStr
		else
			OutStr:='|'+OutStr;
	end
	else begin
		if (Param<>'') then begin
			OutStr:='|'+Param+OutStr;
		end;
	end;
	OutStr:=Name+'|'+Action+OutStr;
	Result:=OutStr;
end;

// ���������� ���� ��� ��������������
// Num - ����� ������ � �������
procedure GetEdit(Num: integer);
begin
	if frmSettings=nil then exit;

	frmSettings.lstConfig.ItemIndex:=Num;
	frmSettings.spnConfig.Position:=Num;

	frmSettings.txtAliasName.Text:=GetName('alias', TempConfigStr.Strings[Num]);
	frmSettings.txtAliasAction.Text:=GetName('action', TempConfigStr.Strings[Num]);
	frmSettings.txtAliasParams.Text:=GetName('param', TempConfigStr.Strings[Num]);
	frmSettings.txtAliasStartPath.Text:=GetName('dir', TempConfigStr.Strings[Num]);

	if GetName('state', TempConfigStr.Strings[Num])='' then
		frmSettings.boxAliasState.ItemIndex:=1
	else
		frmSettings.boxAliasState.ItemIndex:=StrToInt(GetName('state', TempConfigStr.Strings[Num]));

	if GetName('history', TempConfigStr.Strings[Num])='' then
		frmSettings.boxAliasHistory.ItemIndex:=0
	else
		frmSettings.boxAliasHistory.ItemIndex:=StrToInt(GetName('history', TempConfigStr.Strings[Num]));

	if GetName('top', TempConfigStr.Strings[Num])='' then
		frmSettings.boxAliasMoveTop.ItemIndex:=0
	else
		frmSettings.boxAliasMoveTop.ItemIndex:=StrToInt(GetName('top', TempConfigStr.Strings[Num]));

	if GetName('priori', TempConfigStr.Strings[Num])='' then
		frmSettings.boxAliasPriori.ItemIndex:=1
	else
		frmSettings.boxAliasPriori.ItemIndex:=StrToInt(GetName('priori', TempConfigStr.Strings[Num]))+1;

	frmSettings.txtAliasComment.Text:=GetName('comment', TempConfigStr.Strings[Num]);
end;

// ��������� ���������, ��������� � ���� ��������������
// Num - ����� ������ � �������
// Query - ������, ��� ��������
procedure SetEdit(Num: integer; Query: string);
begin
	if frmSettings=nil then exit;

	if Query='alias' then TempConfigStr.Strings[Num]:=GetFullString(frmSettings.txtAliasName.Text, GetName('action', TempConfigStr.Strings[Num]), GetName('param', TempConfigStr.Strings[Num]), GetName('dir', TempConfigStr.Strings[Num]), GetName('state', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), GetName('top', TempConfigStr.Strings[Num]), GetName('priori', TempConfigStr.Strings[Num]), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='action' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), frmSettings.txtAliasAction.Text, GetName('param', TempConfigStr.Strings[Num]), GetName('dir', TempConfigStr.Strings[Num]), GetName('state', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), GetName('top', TempConfigStr.Strings[Num]), GetName('priori', TempConfigStr.Strings[Num]), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='param' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), GetName('action', TempConfigStr.Strings[Num]), frmSettings.txtAliasParams.Text, GetName('dir', TempConfigStr.Strings[Num]), GetName('state', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), GetName('top', TempConfigStr.Strings[Num]), GetName('priori', TempConfigStr.Strings[Num]), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='dir' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), GetName('action', TempConfigStr.Strings[Num]), GetName('param', TempConfigStr.Strings[Num]), frmSettings.txtAliasStartPath.Text, GetName('state', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), GetName('top', TempConfigStr.Strings[Num]), GetName('priori', TempConfigStr.Strings[Num]), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='state' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), GetName('action', TempConfigStr.Strings[Num]), GetName('param', TempConfigStr.Strings[Num]), GetName('dir', TempConfigStr.Strings[Num]), IntToStr(frmSettings.boxAliasState.ItemIndex), GetName('history', TempConfigStr.Strings[Num]), GetName('top', TempConfigStr.Strings[Num]), GetName('priori', TempConfigStr.Strings[Num]), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='history' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), GetName('action', TempConfigStr.Strings[Num]), GetName('param', TempConfigStr.Strings[Num]), GetName('dir', TempConfigStr.Strings[Num]), GetName('state', TempConfigStr.Strings[Num]), IntToStr(frmSettings.boxAliasHistory.ItemIndex), GetName('top', TempConfigStr.Strings[Num]), GetName('priori', TempConfigStr.Strings[Num]), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='top' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), GetName('action', TempConfigStr.Strings[Num]), GetName('param', TempConfigStr.Strings[Num]), GetName('dir', TempConfigStr.Strings[Num]), GetName('state', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), IntToStr(frmSettings.boxAliasMoveTop.ItemIndex), GetName('priori', TempConfigStr.Strings[Num]), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='priori' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), GetName('action', TempConfigStr.Strings[Num]), GetName('param', TempConfigStr.Strings[Num]), GetName('dir', TempConfigStr.Strings[Num]), GetName('state', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), IntToStr(frmSettings.boxAliasPriori.ItemIndex-1), GetName('comment', TempConfigStr.Strings[Num]));
	if Query='comment' then TempConfigStr.Strings[Num]:=GetFullString(GetName('alias', TempConfigStr.Strings[Num]), GetName('action', TempConfigStr.Strings[Num]), GetName('param', TempConfigStr.Strings[Num]), GetName('dir', TempConfigStr.Strings[Num]), GetName('state', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), GetName('history', TempConfigStr.Strings[Num]), GetName('priori', TempConfigStr.Strings[Num]), frmSettings.txtAliasComment.Text);
	if Query='all' then TempConfigStr.Strings[Num]:=GetFullString(frmSettings.txtAliasName.Text, frmSettings.txtAliasAction.Text, frmSettings.txtAliasParams.Text, frmSettings.txtAliasStartPath.Text, IntToStr(frmSettings.boxAliasState.ItemIndex), IntToStr(frmSettings.boxAliasHistory.ItemIndex), IntToStr(frmSettings.boxAliasMoveTop.ItemIndex), IntToStr(frmSettings.boxAliasPriori.ItemIndex), frmSettings.txtAliasComment.Text);
end;

// ��������� ���� ������� ������
procedure GetFullEdit;
begin
	if frmSettings=nil then exit;

	if ((frmSettings.txtAliasName.Text<>'') and (frmSettings.txtAliasAction.Text<>'')) then
		frmSettings.txtFullAlias.Text:=GetFullString(frmSettings.txtAliasName.Text, frmSettings.txtAliasAction.Text, frmSettings.txtAliasParams.Text, frmSettings.txtAliasStartPath.Text, IntToStr(frmSettings.boxAliasState.ItemIndex), IntToStr(frmSettings.boxAliasHistory.ItemIndex), IntToStr(frmSettings.boxAliasMoveTop.ItemIndex), IntToStr(frmSettings.boxAliasPriori.ItemIndex-1), frmSettings.txtAliasComment.Text)
	else
		frmSettings.txtFullAlias.Text:=GetLangStr('erroraliasname');
end;

// ����������� ������ � �������
// Start - ��������� ������� ������
// Finish - �������� ������� ������
procedure MoveItem(Start, Finish: integer);
begin
	if frmSettings=nil then exit;

	TempConfigStr.Move(Start, Finish);
	frmSettings.lstConfig.Items.Move(Start, Finish);
	frmSettings.lstConfig.ItemIndex:=Finish;
end;

// ���������� ������ � ������
procedure AddItem;
var
	AddAction: string;
  tmpAliasName: string;
begin
	if frmSettings=nil then exit;

	if (PathString<>'') and (PathString<>'!@#$%^&*()') then begin
  	AddAction:=ExtractFileName(PathString);
		AddAction:=AnsiReplaceStr(AddAction, ' ', '_');
		if DirectoryExists(PathString) then
      TempConfigStr.Add(AddAction+'|'+Options.Path.FM+'|'+PathString)
    else
    	TempConfigStr.Add(Copy(AddAction, 1, Length(AddAction)-Length(ExtractFileExt(AddAction)))+'|'+PathString);
		frmSettings.lstConfig.Items.Add(ExtractFileName(PathString));
    PathString:='';
  end
  else begin
    tmpAliasName:='alias_name';
		TempConfigStr.Add(tmpAliasName+'|C:\Path\To\Document.exe');
		frmSettings.lstConfig.Items.Add(tmpAliasName);
  end;
	SyncSpn(TempConfigStr.Count);
	GetEdit(TempConfigStr.Count-1);
	ShowEdit(True);
  if frmSettings.Visible and frmSettings.Enabled and frmSettings.txtAliasName.Visible and frmSettings.txtAliasName.Enabled then frmSettings.txtAliasName.SetFocus;
	frmSettings.txtAliasName.SelectAll;
	GetFullEdit;
end;

// �������� ������ �� �������
// Num - ����� ������ � �������
procedure DelItem(Num: integer);
var
	DelItem: integer;
begin
	if frmSettings=nil then exit;

	DelItem:=Num;
	TempConfigStr.Delete(DelItem);
	frmSettings.lstConfig.Items.Delete(DelItem);
	if frmSettings.lstConfig.Items.Count>0 then begin
		SyncSpn(TempConfigStr.Count);
		if DelItem=0 then
			GetEdit(0)
		else if DelItem<frmSettings.lstConfig.Items.Count then
			GetEdit(DelItem)
		else if DelItem=frmSettings.lstConfig.Items.Count then
			GetEdit(DelItem-1);
	end
	else begin
		ShowEdit(False);
	end;
end;

// ������ ������� �� �����
// FileName - ��� �����
procedure ReadHistory(FileName: string);
begin
	if FileExists(FileName) then
		HistoryStr.LoadFromFile(FileName)
	else
		HistoryStr.SaveToFile(FileName);
	HisViewPos:=HistoryStr.Count;
end;

// ��������� ������� � ����
// FileName - ��� �����
procedure SaveHistory(FileName: string);
begin
	HistoryStr.SaveToFile(FileName);
end;

// ��������� �������
// Str - ������ ��� ���������� � �������
procedure AddHistory(Str: string);
var
	i: integer;
  tmp: TStringList;
begin
	tmp:=TStringList.Create;
  for i:=0 to HistoryStr.Count-1 do begin
    if HistoryStr.Strings[i]<>Str then begin
      tmp.Add(HistoryStr.Strings[i]);
    end;
  end;
  HistoryStr.Clear;
  // ���� ����������� �� ���������� ����� � ������� ��� ��� ����, �� ��� �� �����������
	if (Options.History.MaxHistory=0) or (Options.History.MaxHistory>tmp.Count) then begin
    for i:=0 to tmp.Count-1 do
      HistoryStr.Add(tmp.Strings[i]);
  end
  // ����� ���������� �� ���������
  else begin
		for i:=1 to tmp.Count-1 do
      HistoryStr.Add(tmp.Strings[i]);
  end;
  tmp.Free;
  HistoryStr.Add(Str);
  SaveHistory(Program_History);
  ReadHistory(Program_History);
end;

// ��������� ��������� ���������� ������� � �������
// Num - ����� �������
// Str - ���������� ��������� ����� �������
procedure SaveHistoryInternal(Num: integer; Str: string);
begin
	if Options.History.SaveHistory then begin
  	if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
			if (Options.History.SaveParamInternal) and (Str<>'')  then
        AddHistory(InSide[Num]+' '+Str)
			else if Options.History.SaveInternal then
        AddHistory(InSide[Num]);
    end;
	end;
end;

// ��������� ��������� ����� � �������
// Num - ����� ������ � �������
// Str - ���������� ��������� ����� �������
procedure SaveHistoryAlias(Num: integer; Str: string);
begin
	if ((Options.History.SaveHistory) and (GetName('history', ConfigStr.Strings[Num])<>'2')) then begin
	  if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
			if ((Options.History.SaveParamAlias) or (GetName('history', ConfigStr.Strings[Num])='1')) and (Str<>'')  then
				AddHistory(GetName('alias', ConfigStr.Strings[Num])+' '+Str)
			else if Options.History.SaveAlias then
				AddHistory(GetName('alias', ConfigStr.Strings[Num]));
    end;
	end;
end;

// ��������� ��������� ��������� ����� � �������
// Num - ����� ������ � �������
// Str - ���������� ��������� ����� �������
procedure SaveSysHistoryAlias(Num: integer; Str: string);
begin
	if Options.History.SaveHistory then begin
  	if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
			if (Options.History.SaveSysParamAlias) and (Str<>'')  then
				AddHistory(Options.SystemAliases.Name.Strings[Num]+' '+Str)
			else if Options.History.SaveSysAlias then
				AddHistory(Options.SystemAliases.Name.Strings[Num]);
    end;
	end;
end;

// ��������� ��������� ��� � �������
// Str - ���
procedure SaveHistoryWWW(Str: string);
begin
	If (Options.History.SaveHistory and Options.History.SaveWWW) then begin
	  if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
			AddHistory(Str);
    end;
	end;
end;

// ��������� ��������� ����� ����� � �������
// Str - ����� �����
procedure SaveHistoryEMail(Str: string);
begin
	If (Options.History.SaveHistory and Options.History.SaveEMail) then begin
	  if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
			AddHistory(Str);
  	end;
	end;
end;

// ��������� ��������� ����� � �������
// Str - ���� � �����
procedure SaveHistoryFolder(Str: string);
begin
	If (Options.History.SaveHistory and Options.History.SavePath) then begin
	  if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
			AddHistory(Str);
    end;
	end;
end;

// ��������� ��������� ������ � �������
// Str - ���� �� ������ ����� ������
procedure SaveHistoryPlugin(Str: string);
var
	tmpParam: string;
begin
	tmpParam:=GetProgParam(Str);
	if tmpParam='' then begin
		If (Options.History.SavePlugins and Options.History.SaveUnknown) then begin
			if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
				AddHistory(Str);
			end;
		end;
	end
	else begin
		If (Options.History.SaveParamPlugins and Options.History.SaveUnknown) then begin
			if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
				AddHistory(Str);
			end;
		end;
	end;
end;

// ��������� ��������� ���� � �������
// Str - ���� �� ������ ����� shell
procedure SaveHistoryDOS(Str: string);
begin
	If (Options.History.SaveHistory and Options.History.SaveUnknown) then begin
	  if (not IsParseCL or (IsParseCL and Options.History.SaveCommandLine)) and (not IsParseMessage or (IsParseMessage and Options.History.SaveMessage)) then begin
			AddHistory(Str);
    end;
	end;
end;

// ����������� ������� �����
procedure HistoryUp;
begin
  if IsShift then begin

  end
  else begin
    if HisViewPos>0 then begin
      Dec(HisViewPos);
      frmTARConsole.txtConsole.Text:=HistoryStr.Strings[HisViewPos];
    end;
    frmTARConsole.txtConsole.SelStart:=Length(frmTARConsole.txtConsole.Text);
    frmTARConsole.txtConsole.SelLength:=0;
  end;
end;

// ����������� ������� ����
procedure HistoryDown;
begin
  if IsShift then begin

  end
  else begin
    if (HisViewPos<HistoryStr.Count-1) then begin
      Inc(HisViewPos);
      frmTARConsole.txtConsole.Text:=HistoryStr.Strings[HisViewPos];
      frmTARConsole.txtConsole.SelStart:=Length(frmTARConsole.txtConsole.Text);
      frmTARConsole.txtConsole.SelLength:=0;
    end
    else begin
      if (HisViewPos<HistoryStr.Count) then begin
        frmTARConsole.txtConsole.Text:='';
        Inc(HisViewPos);
      end;
    end;
  end;
end;

// ���������� ������ �� �������� �������
function GetLangStr(Name: string): string;
var
	i: integer;
	outText: string;
begin
	outText:='';
	for i:=0 to Options.Language.LangStr.Count-1 do begin
		if(GetNumWord(Options.Language.LangStr.Strings[i], ' = ', 1)=Name) then
			outText:=GetNumWord(Options.Language.LangStr.Strings[i], ' = ', 2);
	end;
	if outText='' then
		outText:=Name;
	Result:=GetConstStr(outText);
end;

// ���������� ������ �� ������������ �����������
function GetConstStr(Str: string): string;
begin
	while Pos('%p', Str)<>0 do begin
		Insert(Program_Name, Str, Pos('%p', Str));
		Delete(Str, Pos('%p', Str), 2);
	end;
	while Pos('%v', Str)<>0 do begin
		Insert(Program_Version, Str, Pos('%v', Str));
		Delete(Str, Pos('%v', Str), 2);
	end;
	Result:=Str;
end;


// ������������� ����
procedure SetLanguages;
begin
  Options.Language.ReadLanguages;
	if frmAbout<>nil then begin
		with frmAbout do begin
			Caption:=GetLangStr('aboutprogram');
			lblGohomepage.Caption:=GetLangStr('visitoffsite');
			lblGoEmail1.Caption:=GetLangStr('mailme1');
			lblGoEmail2.Caption:=GetLangStr('mailme2');
	  	btnClose.Caption:=GetLangStr('close');
		end;
	end;
	if frmSettings<>nil then begin
		with frmSettings do begin
      Caption:=GetLangStr('settings');
      with lstSettings do begin
				Clear;
				Items.Add(GetLangStr('settingsappearance'));
				Items.Add(GetLangStr('settingsconsolelook'));
				Items.Add(GetLangStr('settingshintpopup'));
				Items.Add(GetLangStr('settingsdropdownlist'));
				Items.Add(GetLangStr('settingscolors'));
				Items.Add(GetLangStr('settingsfont'));
				Items.Add(GetLangStr('settingshotkey'));
				Items.Add(GetLangStr('settingseasytype'));
				Items.Add(GetLangStr('settingsexec'));
				Items.Add(GetLangStr('settingshistory'));
				Items.Add(GetLangStr('settingspath'));
				Items.Add(GetLangStr('settingsregistry'));
				Items.Add(GetLangStr('settingslanguage'));
				Items.Add(GetLangStr('settingsundo'));
				Items.Add(GetLangStr('settingssounds'));
				Items.Add(GetLangStr('settingsconfig'));
				Items.Add(GetLangStr('settingseditconfig'));
				Items.Add(GetLangStr('settingsplugins'));
			end;
			btnOK.Caption:=GetLangStr('ok');
			btnCancel.Caption:=GetLangStr('cancel');
			btnApply.Caption:=GetLangStr('apply');

			chkShowConsoleOnStart.Caption:=GetLangStr('showconsoleonstart');
      chkHideConsole.Caption:=GetLangStr('closeafterenter');
			chkTriggerShow.Caption:=GetLangStr('hideconsoletrigger');
			chkTrayIcon.Caption:=GetLangStr('systemtrayicon');
			chkShowBalloonTips.Caption:=GetLangStr('showballontips');
			chkPutMouseIntoConsole.Caption:=GetLangStr('putmouseintoconsole');
			chkAutoHide.Caption:=GetLangStr('autohideconsole');
			lblPriority.Caption:=GetLangStr('prioriincantatem');
			boxPriority.Clear;
			boxPriority.Items.Add(GetLangStr('priorilow'));
			boxPriority.Items.Add(GetLangStr('priorinormal'));
			boxPriority.Items.Add(GetLangStr('priorihigh'));
			boxPriority.Items.Add(GetLangStr('priorirealtime'));

			chkShowCenterX.Caption:=GetLangStr('showcenterx');
			chkShowCenterY.Caption:=GetLangStr('showcentery');
			lblConsoleWidth.Caption:=GetLangStr('consolewidth');
			chkConsoleWidthPercent.Caption:=GetLangStr('consolewidthpercent');
			lblConsoleHeight.Caption:=GetLangStr('consoleheight');
			lblBorderSize.Caption:=GetLangStr('bordersize');
			chkDestroyForm.Caption:=GetLangStr('showonlyborder');
			lblTransparent.Caption:=GetLangStr('transparent');

			chkShowHint.Caption:=GetLangStr('showhint');

			lblDropdownLineNum.Caption:=GetLangStr('dropdownlinenum');

			boxETColor.Clear;
      boxETColor.Items.Add(GetLangStr('noetcolor'));
			boxETColor.Items.Add(GetLangStr('normaletcolor'));
      boxETColor.Items.Add(GetLangStr('linuxcolor'));
      lblTextColor.Caption:=GetLangStr('fontcolor');
			lblConsoleColor.Caption:=GetLangStr('consolecolor');
      lblBorderColor.Caption:=GetLangStr('bordercolor');
			lblHintTextColor.Caption:=GetLangStr('hinttextcolor');
			lblHintColor.Caption:=GetLangStr('hintcolor');
			lblDropdownTextColor.Caption:=GetLangStr('dropdowntextcolor');
			lblDropdownColor.Caption:=GetLangStr('dropdowncolor');

			btnFont.Caption:=GetLangStr('changefont');
			chkFontAutoSize.Caption:=GetLangStr('fontautosize');
			lblTextAlignment.Caption:=GetLangStr('textalign');
			optAlignLeft.Caption:=GetLangStr('alignleft');
			optAlignCenter.Caption:=GetLangStr('aligncenter');
			optAlignRight.Caption:=GetLangStr('alignright');
			chkApplyEnglish.Caption:=GetLangStr('applyenglish');
			chkLockEnglish.Caption:=GetLangStr('lockenglish');

			chkAlt.Caption:=GetLangStr('hotkeyalt');
			chkCtrl.Caption:=GetLangStr('hotkeyctrl');
			chkShift.Caption:=GetLangStr('hotkeyshift');
			chkWin.Caption:=GetLangStr('hotkeywin');

			optNoType.Caption:=GetLangStr('noet');
			optEasyType.Caption:=GetLangStr('standartet');
      optLinuxType.Caption:=GetLangStr('linuxt');
      chkETInternal.Caption:=GetLangStr('etinternal');
			chkETAlias.Caption:=GetLangStr('etalias');
			chkETSysAlias.Caption:=GetLangStr('etsysalias');
      chkETPath.Caption:=GetLangStr('etpath');
      chkETPlugins.Caption:=GetLangStr('etplugin');
      chkETHistory.Caption:=GetLangStr('ethistory');
			chkSpace.Caption:=GetLangStr('addspace');
      chkCase.Caption:=GetLangStr('casesensitivity');
			chkEnableET.Caption:=GetLangStr('applyet');
			chkAdvancedBackspace.Caption:=GetLangStr('advancedbackspace');
			chkAdvancedSpace.Caption:=GetLangStr('advancedspace');
			chkDeleteDuplicate.Caption:=GetLangStr('deleteduplicates');

			chkExecInternal.Caption:=GetLangStr('runinternal');
			chkExecAlias.Caption:=GetLangStr('runalias');
			chkExecUseDefaultAction.Caption:=GetLangStr('usedefaultaction');
			chkExecSysAlias.Caption:=GetLangStr('runsysalias');
			chkExecWWW.Caption:=GetLangStr('runwww');
			chkExecEMail.Caption:=GetLangStr('runemail');
      chkExecFolder.Caption:=GetLangStr('runfolder');
			chkExecFile.Caption:=GetLangStr('runfile');
      chkExecPlugins.Caption:=GetLangStr('runplugin');
			chkExecShell.Caption:=GetLangStr('runother');

			optNoSaveHistory.Caption:=GetLangStr('nohistory');
      optSaveHistory.Caption:=GetLangStr('hisfile');
      chkSaveInternal.Caption:=GetLangStr('hisinternal');
			chkSaveInternalParam.Caption:=GetLangStr('hisinternalparam');
      chkSaveAlias.Caption:=GetLangStr('hisalias');
      chkSaveAliasParam.Caption:=GetLangStr('hisaliasparam');
			chkSaveSysAlias.Caption:=GetLangStr('hissysalias');
      chkSaveSysAliasParam.Caption:=GetLangStr('hissysaliasparam');
			chkSaveWWW.Caption:=GetLangStr('hiswww');
			chkSaveEMail.Caption:=GetLangStr('hisemail');
			chkSaveFolder.Caption:=GetLangStr('hisfolder');
			chkSavePlugins.Caption:=GetLangStr('hisplugin');
			chkSavePluginParam.Caption:=GetLangStr('hispluginparam');
			chkSaveShell.Caption:=GetLangStr('hisother');
			chkSaveCommandLine.Caption:=GetLangStr('hiscommandline');
			chkSaveMessage.Caption:=GetLangStr('hismessage');
			chkInvertScroll.Caption:=GetLangStr('invertscroll');
			lblMaxHistory.Caption:=GetLangStr('maxhistorysize');

			lblBrowser.Caption:=GetLangStr('yourbrowser');
      lblFileManager.Caption:=GetLangStr('yourfm');
			lblShell.Caption:=GetLangStr('yourshell');
      lblCmdParamClose.Caption:=GetLangStr('enterparam');
			lblCmdParamNoclose.Caption:=GetLangStr('shiftenterparam');

			optNoAutorun.Caption:=GetLangStr('noautostart');
			optAutostartLM.Caption:=GetLangStr('starthklm');
			optAutostartCU.Caption:=GetLangStr('starthkcu');
			chkAddTo.Caption:=GetLangStr('shellintegration');

			chkMoveTop.Caption:=GetLangStr('moveupalias');
			chkAutoSort.Caption:=GetLangStr('autosortconfig');
      chkAutoReread.Caption:=GetLangStr('autoreread');
			chkRereadHotKey.Caption:=GetLangStr('rereadhotkey');
      chkCreateOldFile.Caption:=GetLangStr('createdabackup');
      chkConfirm.Caption:=GetLangStr('confirmkillda');
      chkSearchFileCDA.Caption:=GetLangStr('searchdadisk');
			chkSearchPluginsCDA.Caption:=GetLangStr('searchdaplugin');
      chkStartCDA.Caption:=GetLangStr('searchdaonstart');
			btnCheckDeadAliases.Caption:=GetLangStr('searchdanow');
			btnBackAllDA.Caption:=GetLangStr('backallda');

			lblLanguage.Caption:=GetLangStr('delectlang');
			lblAuthor.Caption:=GetLangStr('authorlang');
			lblVersion.Caption:=GetLangStr('versionlang');

			chkUseUndo.Caption:=GetLangStr('useundo');

			chkEnableSounds.Caption:=GetLangStr('enablesounds');
			btnBrowseSound.Caption:=GetLangStr('browsesound');
			lstSounds.Clear;
			lstSounds.Items.Add(GetLangStr('soundexecinternal'));
			lstSounds.Items.Add(GetLangStr('soundexecalias'));
			lstSounds.Items.Add(GetLangStr('soundexecsysalias'));
			lstSounds.Items.Add(GetLangStr('soundexecurl'));
			lstSounds.Items.Add(GetLangStr('soundexecemail'));
			lstSounds.Items.Add(GetLangStr('soundexecfolder'));
			lstSounds.Items.Add(GetLangStr('soundexecfile'));
			lstSounds.Items.Add(GetLangStr('soundexecplugin'));
			lstSounds.Items.Add(GetLangStr('soundexecallother'));

			lblAliasName.Caption:=GetLangStr('aliasname');
      lblAliasAction.Caption:=GetLangStr('aliasaction');
      lblAliasParams.Caption:=GetLangStr('aliasparam');
      lblAliasStartPath.Caption:=GetLangStr('aliaspath');
			lblAliasState.Caption:=GetLangStr('aliasstate');
      lblAliasHistory.Caption:=GetLangStr('aliasaddhistory');
      lblAliasMoveTop.Caption:=GetLangStr('aliasmoveup');
      lblAliasPriori.Caption:=GetLangStr('aliasprioriincantatem');
			btnAddAlias.Caption:=GetLangStr('newalias');
			btnDeleteAlias.Caption:=GetLangStr('deletealias');
      boxAliasState.Clear;
      boxAliasState.Items.Add(GetLangStr('statehide'));
			boxAliasState.Items.Add(GetLangStr('statenormal'));
      boxAliasState.Items.Add(GetLangStr('stateminimize'));
      boxAliasState.Items.Add(GetLangStr('statemaximize'));
      boxAliasState.Items.Add(GetLangStr('statenormalnofocus'));
			boxAliasState.Items.Add(GetLangStr('stateminimizenofocus'));
      boxAliasHistory.Clear;
      boxAliasHistory.Items.Add(GetLangStr('addhisdefault'));
			boxAliasHistory.Items.Add(GetLangStr('addhisalways'));
      boxAliasHistory.Items.Add(GetLangStr('addhisnever'));
      boxAliasMoveTop.Clear;
			boxAliasMoveTop.Items.Add(GetLangStr('moveupdefault'));
      boxAliasMoveTop.Items.Add(GetLangStr('moveupalways'));
      boxAliasMoveTop.Items.Add(GetLangStr('moveupnever'));
			boxAliasPriori.Clear;
      boxAliasPriori.Items.Add(GetLangStr('aliaspriorilow'));
      boxAliasPriori.Items.Add(GetLangStr('aliaspriorynormal'));
			boxAliasPriori.Items.Add(GetLangStr('aliaspriorihigh'));
			boxAliasPriori.Items.Add(GetLangStr('aliaspriorirealtime'));
			lblAliasComment.Caption:=GetLangStr('aliascomment');

			lblPluginName.Caption:=GetLangStr('pluginname');
			lblPluginVersion.Caption:=GetLangStr('pluginversion');
			lblPluginDescription.Caption:=GetLangStr('plugindesc');
      lblPluginAuthor.Caption:=GetLangStr('pluginauthor');
			lblPluginCopyright.Caption:=GetLangStr('plugincopyright');
			lblPluginHomepage.Caption:=GetLangStr('pluginsite');
			lblPluginPath.Caption:=GetLangStr('pluginpath');
			btnPluginAdd.Caption:=GetLangStr('addplugin');
			btnPluginDelete.Caption:=GetLangStr('deleteplugin');
			btnLoadPlugin.Caption:=GetLangStr('loadplugin');
			btnUnloadPlugin.Caption:=GetLangStr('unloadplugin');
			chkLoadingPlugin.Caption:=GetLangStr('loadpluginonstart');
			chkSaveHistoryPlugin.Caption:=GetLangStr('savehistoryplugin');
		end;
	end;
	with frmTARConsole do begin
		Caption:=GetLangStr('systemtrayhint');
		mnuShowConsole.Caption:=GetLangStr('consoleshow');
		mnuHideConsole.Caption:=GetLangStr('consolehide');
		mnuCut.Caption:=GetLangStr('consolecut');
		mnuCopy.Caption:=GetLangStr('consolecopy');
		mnuPaste.Caption:=GetLangStr('consolepaste');
		mnuClear.Caption:=GetLangStr('consoleclear');
		mnuSelectAll.Caption:=GetLangStr('consoleselectall');
		mnuUndo.Caption:=GetLangStr('consoleundo');
		mnuNewAlias.Caption:=GetLangStr('consolenewalias');
		mnuDelString.Caption:=GetLangStr('consoledeletestring');
		mnuOpenFolder.Caption:=GetLangStr('consoleopenfolder');
		mnuReread.Caption:=GetLangStr('consolerereadconfig');
		mnuToggleET.Caption:=GetLangStr('consoleonoffet');
		mnuSettings.Caption:=GetLangStr('consolesettings');
		mnuEditor.Caption:=GetLangStr('consoleconfigeditor');
		mnuHelp.Caption:=GetLangStr('consolehelp');
		mnuAbout.Caption:=GetLangStr('consoleaboutprogram');
		mnuExit.Caption:=GetLangStr('consoleexit');
	end;
end;

end.
