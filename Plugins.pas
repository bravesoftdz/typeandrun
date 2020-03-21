unit Plugins;

interface

uses Classes, Windows, Dialogs, SysUtils, IniFiles;

type
	TInfo=record
		size: integer; // ������ ���������
		//plugin: PChar; // ����������� ������ 'Hello! I am the TypeAndRun plugin.' - ��� ����������� �������
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

	TDll=class(TObject)
		Name: string; // ��� dll
		Path: string; // ���� � dll
		Loaded: boolean; // ��������� �� dll
		Loading: boolean; // ��������� �� dll ��� �������
		SaveHistory: boolean; // ��������� �� �������
		private
			LibHandle: THandle; // �������� ����� ����������� ����������
			tmpLoad: procedure(WinHWND: HWND); cdecl;
			tmpUnload: procedure; cdecl;
			tmpGetInfo: function(): TInfo; cdecl;
			tmpInfo: TInfo;
			tmpGetCount: function(): integer; cdecl;
			tmpGetString: function(num: integer): PChar; cdecl;
			tmpGetCountET: function(str: PChar): integer; cdecl;
			tmpGetStringET: function(num: integer): PChar; cdecl;
		protected
		public
			constructor Create; // �����������
			destructor Destroy; override; // ����������
			function Load: boolean; // ��������� ����������
			procedure Unload; // ��������� ����������
			function GetInfo: TInfo; // ���������� ���������� �� �������
			function GetCount: integer; // ���������� ������������ �������� ����� �����
			function GetString(Num: integer): string; // ���������� ������ ������ �� ������������ ��������
			function GetCountET(Str: string): integer; // ���������� ���������� ����������� �����
			function GetStringET(Num: integer): string; // ���������� ������ ����������
			function RunString(Str: string): TExec; // ����������, ����������� �� ������, � ������, ������������ � �������
		published
	end;

procedure ReadPlugins(FileName: string); // ������ ������� �� ini'���
procedure SavePlugins(FileName: string); // ��������� ������� � ini'���
procedure LoadPlugins; // ��������� ��� �������
procedure UnloadPlugins; // ��������� ��� �������
procedure ApplyPluginShow(Item: integer); // ���������� ���� �� ����������� ��������
procedure ShowPlugin(Show: boolean); // ���������� ��� �������� �������� ��������� �� �������
function PluginAliasCount: integer; // ���������� ���������� ��������� �������
procedure MovePlugin(Start, Finish: integer); // ����������� ������� � �������
procedure AddPlugin; // ��������� ������
procedure DeletePlugin(DelItem: integer); // ������� ������

var
	PluginDll: array of Tdll; // ����������� dll'���

implementation

uses frmConsoleUnit, ForAll, Static, Configs, frmSettingsUnit, frmAboutUnit, Settings;

// �����������
constructor TDll.Create;
begin
	inherited Create;
end;

// ����������
destructor TDll.Destroy;
begin
	inherited Destroy;
end;

// ��������� ����������
// WinHWND - ����� �������� ����
function TDll.Load: boolean;
var
	tmpPath: string;
begin
	Result:=False;
	if FileExists(Path) then begin
    if (GetMyPath+'Plugins\')=Copy(Path, 0, Length(GetMyPath+'Plugins\')) then begin
      tmpPath:=Path;
			Delete(Path, 1, Length(GetMyPath+'Plugins\'));
    end
    else
      tmpPath:=Path;
  end
  else
    tmpPath:=GetMyPath+'Plugins\'+Path;
  if not Loaded then begin
    LibHandle:=LoadLibrary(PChar(tmpPath));
		if LibHandle>=32 then begin
			if @tmpLoad=nil then
				tmpLoad:=GetProcAddress(LibHandle, 'Load');
			if @tmpLoad<>nil then begin
        tmpLoad(frmTARConsole.Handle);
        Loaded:=True;
        Result:=True;
      end;
    end;
	end;
end;

// ��������� ����������
procedure TDll.Unload;
begin
	if Loaded then begin
		if @tmpUnload=nil then
			tmpUnload:=GetProcAddress(LibHandle, 'Unload');
		if @tmpUnload<>nil then
			tmpUnload;
  	FreeLibrary(LibHandle);
    Loaded:=False;
  end;
end;

// ���������� ���������� �� �������
function TDll.GetInfo: TInfo;
begin
	if @tmpGetInfo=nil then begin
		tmpGetInfo:=GetProcAddress(LibHandle, 'GetInfo');
		if @tmpGetInfo<>nil then begin
			tmpInfo:=tmpGetInfo;
		end;
	end;
	if @tmpGetInfo<>nil then
		Result:=tmpInfo;
end;

// ���������� ������������ �������� ����� �����
function TDll.GetCount: integer;
var
	tmp: integer;
begin
	if @tmpGetCount=nil then
		tmpGetCount:=GetProcAddress(LibHandle, 'GetCount');
	if @tmpGetCount<>nil then begin
		tmp:=tmpGetCount;
		Result:=tmp;
	end
	else
		Result:=0;
end;

// ���������� ������ ������ �� ������������ ��������
// Num - ����� ������ ������ � ������
function TDll.GetString(Num: integer): string;
var
	tmp: string;
begin
	if @tmpGetString=nil then
		tmpGetString:=GetProcAddress(LibHandle, 'GetString');
	if @tmpGetString<>nil then begin
		tmp:=tmpGetString(Num);
		Result:=tmp;
	end
	else
		Result:='';
end;

// ���������� ���������� ����������� �����
// Str - ������ �� �������
function TDll.GetCountET(Str: string): integer;
var
  tmp: integer;
begin
	if @tmpGetCountET=nil then
  	tmpGetCountET:=GetProcAddress(LibHandle, 'GetCountET');
  if @tmpGetCountET<>nil then begin
  	tmp:=tmpGetCountET(PChar(Str));
    Result:=tmp;
  end
  else
    Result:=0;
end;

// ���������� ������ ����������
// Num - ����� ������
function TDll.GetStringET(Num: integer): string;
var
	tmp: string;
begin
	if @tmpGetStringET=nil then
		tmpGetStringET:=GetProcAddress(LibHandle, 'GetStringET');
  if @tmpGetStringET<>nil then begin
  	tmp:=tmpGetStringET(Num);
		Result:=tmp;
  end
  else
    Result:='';
end;

// ����������, ����������� �� ������, � ������, ������������ � �������
// Str - ����������� ������
function TDll.RunString(Str: string): TExec;
var
  tmpRunString: function(str: PChar): TExec; cdecl;
  tmp: TExec;
begin
  tmpRunString:=GetProcAddress(LibHandle, 'RunString');
  if @tmpRunString<>nil then begin
  	tmp:=tmpRunString(PChar(Str));
    Result:=tmp;
  end
  else begin
    tmp.run:=0;
    tmp.con_text:='';
    Result:=tmp;
  end;
end;

// ������ ������� �� ini'���
// FileName - ��� ini'���
procedure ReadPlugins(FileName: string);
var
	IniFile: TMemIniFile;
  tmpName: TStringList;
  i: integer;
begin
	IniFile:=TMemIniFile.Create(FileName);

  tmpName:=TStringList.Create;
  IniFile.ReadSections(tmpName);

  SetLength(PluginDll, tmpName.Count);
  for i:=0 to tmpName.Count-1 do begin
    PluginDll[i]:=TDll.Create;
    PluginDll[i].Name:=tmpName.Strings[i];
		PluginDll[i].Path:=IniFile.ReadString(tmpName.Strings[i], 'Path', '');
		PluginDll[i].Loading:=IniFile.ReadBool(tmpName.Strings[i], 'Load', True);
		PluginDll[i].SaveHistory:=IniFile.ReadBool(tmpName.Strings[i], 'SaveHistory', True);
  end;
  tmpName.Free;

  IniFile.Free;
end;

// ��������� ������� � ini'���
// FileName - ��� ini'���
procedure SavePlugins(FileName: string);
var
	IniFile: TMemIniFile;
  i: integer;
begin
	IniFile:=TMemIniFile.Create(FileName);

  IniFile.Clear;
  for i:=0 to High(PluginDll) do begin
		IniFile.WriteString(PluginDll[i].Name, 'Path', PluginDll[i].Path);
		IniFile.WriteBool(PluginDll[i].Name, 'Load', PluginDll[i].Loading);
		IniFile.WriteBool(PluginDll[i].Name, 'SaveHistory', PluginDll[i].SaveHistory);
  end;

  IniFile.UpdateFile;
  IniFile.Free;
end;

// ��������� ��� �������
procedure LoadPlugins;
var
  i: integer;
begin
  for i:=0 to High(PluginDll) do begin
    if (not PluginDll[i].Loaded) and PluginDll[i].Loading then
			PluginDll[i].Load;
	end;
end;

// ��������� ��� �������
procedure UnloadPlugins;
var
  i: integer;
begin
  for i:=0 to High(PluginDll) do begin
    if PluginDll[i].Loaded then begin
      PluginDll[i].Unload;
      PluginDll[i].Free;
    end;
  end;
end;

// ���������� ���� �� ����������� ��������
// Item - ����� ������� � ���������� �����
procedure ApplyPluginShow(Item: integer);
var
	tmpStr: string;
	i: integer;
begin
	if frmSettings=nil then exit;

  if PluginDll[Item].Loaded then begin
    ShowPlugin(True);
    frmSettings.lblPluginStatus.Caption:=GetLangStr('statusloaded');
    frmSettings.txtPluginName.Text:=PluginDll[Item].GetInfo.name;
    frmSettings.txtPluginVersion.Text:=PluginDll[Item].GetInfo.version;
    tmpStr:=PluginDll[Item].GetInfo.description;
    frmSettings.txtPluginDescription.Clear;
    while Pos(#13, tmpStr)<>0 do begin
	    frmSettings.txtPluginDescription.Lines.Add(Copy(tmpStr, 0, Pos(#13, tmpStr)));
      Delete(tmpStr, 1, Pos(#13, tmpStr));
    end;
    frmSettings.txtPluginDescription.Lines.Add(tmpStr);
    frmSettings.txtPluginAuthor.Text:=PluginDll[Item].GetInfo.author;
    frmSettings.txtPluginCopyright.Text:=PluginDll[Item].GetInfo.copyright;
    frmSettings.txtPluginHomepage.Text:=PluginDll[Item].GetInfo.homepage;
		frmSettings.txtPluginPath.Text:=PluginDll[Item].Path;
		frmSettings.btnLoadPlugin.Visible:=False;
		frmSettings.btnUnLoadPlugin.Visible:=True;
		frmSettings.lstPluginAliases.Clear;
		for i:=0 to PluginDll[Item].GetCount-1 do begin
			frmSettings.lstPluginAliases.Items.Add(PluginDll[Item].GetString(i));
		end;
		if (frmSettings.lstPluginAliases.Items.Count>0) then
			frmSettings.lstPluginAliases.Visible:=True
		else
    	frmSettings.lstPluginAliases.Visible:=False;
	end
	else begin
		ShowPlugin(False);
		frmSettings.lblPluginStatus.Caption:=GetLangStr('statusunloaded');
		frmSettings.btnLoadPlugin.Visible:=True;
		frmSettings.btnUnLoadPlugin.Visible:=False;
    frmSettings.lstPluginAliases.Visible:=False;
	end;
	frmSettings.chkLoadingPlugin.Checked:=PluginDll[Item].Loading;
  frmSettings.chkSaveHistoryPlugin.Checked:=PluginDll[Item].SaveHistory;
	frmSettings.lstPluginList.ItemIndex:=Item;
	frmSettings.spnSortPlugins.Position:=Item;
end;

// ���������� ��� �������� �������� ��������� �� �������
// Show - �������� ��� ������ ��������
procedure ShowPlugin(Show: boolean);
begin
	if frmSettings=nil then exit;

  if High(PluginDll)=-1 then frmSettings.lblPluginStatus.Visible:=False else frmSettings.lblPluginStatus.Visible:=True;
  frmSettings.lblPluginName.Visible:=Show;
  frmSettings.txtPluginName.Visible:=Show;
  frmSettings.lblPluginVersion.Visible:=Show;
  frmSettings.txtPluginVersion.Visible:=Show;
  frmSettings.lblPluginDescription.Visible:=Show;
  frmSettings.txtPluginDescription.Visible:=Show;
  frmSettings.lblPluginAuthor.Visible:=Show;
  frmSettings.txtPluginAuthor.Visible:=Show;
  frmSettings.lblPluginCopyright.Visible:=Show;
  frmSettings.txtPluginCopyright.Visible:=Show;
  frmSettings.lblPluginHomepage.Visible:=Show;
  frmSettings.txtPluginHomepage.Visible:=Show;
  frmSettings.lblPluginPath.Visible:=Show;
  frmSettings.txtPluginPath.Visible:=Show;
  frmSettings.btnLoadPlugin.Visible:=Show;
	frmSettings.btnUnloadPlugin.Visible:=Show;
	frmSettings.chkLoadingPlugin.Visible:=Show;
	frmSettings.chkSaveHistoryPlugin.Visible:=Show;
	frmSettings.lstPluginAliases.Visible:=Show;
	frmSettings.btnPluginDelete.Visible:=(frmSettings.lstPluginList.Count>0);
	frmSettings.spnSortPlugins.Visible:=(frmSettings.lstPluginList.Count>0);
	frmSettings.lstPluginList.Visible:=(frmSettings.lstPluginList.Count>0);
end;

// ���������� ���������� ��������� �������
function PluginAliasCount: integer;
var
  i, j, Counter: integer;
begin
  Counter:=0;
  for i:=0 to High(PluginDll) do begin
    if PluginDll[i].Loaded then begin
      for j:=0 to PluginDll[i].GetCount-1 do begin
        Inc(Counter);
      end;
    end;
  end;
  Result:=Counter;
end;

// ������� ������
procedure MovePlugin(Start, Finish: integer);
var
	tmp: TDll;
begin
	if frmSettings=nil then exit;

	tmp:=PluginDll[Start];
	PluginDll[Start]:=PluginDll[Finish];
	PluginDll[Finish]:=tmp;
	frmSettings.lstPluginList.Items.Move(Start, Finish);
	frmSettings.lstPluginList.ItemIndex:=Finish;
end;

// ��������� ������
procedure AddPlugin;
var
	i, j: integer;
	flag: boolean;
begin
	dlgOpen:=TOpenDialog.Create(frmSettings);
	dlgOpen.Options:=[ofNoChangeDir, ofPathMustExist, ofFileMustExist, ofShareAware, ofNoDereferenceLinks,  ofEnableSizing, ofForceShowHidden, ofAllowMultiSelect];
	dlgOpen.Filter:=GetLangStr('plugins')+' (*.dll)|*.dll';
	dlgOpen.Title:=GetLangStr('selectfile');
	dlgOpen.InitialDir:=GetMyPath + 'Plugins';
	if dlgOpen.Execute then begin
		for i:=0 to dlgOpen.Files.Count-1 do begin
			flag:=false;
			for j:=0 to High(PluginDll) do begin
				if(PluginDll[j].Name = Copy(ExtractFileName(dlgOpen.Files.Strings[i]), 0, Length(ExtractFileName(dlgOpen.Files.Strings[i]))-4)) then
					flag:=true;
			end;
			if flag then begin
				continue;
			end;
			SetLength(PluginDll, High(PluginDll)+2);
			PluginDll[High(PluginDll)]:=TDll.Create;
			PluginDll[High(PluginDll)].Name:=Copy(ExtractFileName(dlgOpen.Files.Strings[i]), 0, Length(ExtractFileName(dlgOpen.Files.Strings[i]))-4);
			PluginDll[High(PluginDll)].Path:=dlgOpen.Files.Strings[i];
			PluginDll[High(PluginDll)].Loading:=True;
			PluginDll[High(PluginDll)].SaveHistory:=True;
			if not PluginDll[High(PluginDll)].Load then begin
				ShowMes(PluginDll[High(PluginDll)].Name + ' - ' + GetLangStr('badplugin'));
				PluginDll[High(PluginDll)].Unload;
				SetLength(PluginDll, High(PluginDll));
			end
			else begin
				frmSettings.lstPluginList.Items.Add(Copy(ExtractFileName(dlgOpen.Files.Strings[i]), 0, Length(ExtractFileName(dlgOpen.Files.Strings[i]))-4));
				frmSettings.lstPluginList.ItemIndex:=frmSettings.lstPluginList.Count-1;
				ApplyPluginShow(frmSettings.lstPluginList.ItemIndex);
			end;
			SyncPluginSpn(frmSettings.lstPluginList.Count+1);
			SavePlugins(Program_Plugin);
		end;
	end;
	dlgOpen.Free;
end;

// ������� ������
// DelItem - ����� �������
procedure DeletePlugin(DelItem: integer);
var
	i: integer;
begin
	PluginDll[DelItem].Unload;
	PluginDll[DelItem].Free;
	for i:=DelItem to High(PluginDll)-1 do begin
		PluginDll[i]:=PluginDll[i+1];
	end;
	SetLength(PluginDll, High(PluginDll));
	frmSettings.lstPluginList.Items.Delete(DelItem);
	if High(PluginDll)>-1 then begin
		if DelItem=0 then begin
			frmSettings.lstPluginList.ItemIndex:=0;
			ApplyPluginShow(0);
		end
		else if DelItem<frmSettings.lstPluginList.Items.Count then begin
			frmSettings.lstPluginList.ItemIndex:=DelItem;
			ApplyPluginShow(DelItem);
		end
		else if DelItem=frmSettings.lstPluginList.Items.Count then begin
			frmSettings.lstPluginList.ItemIndex:=DelItem-1;
			ApplyPluginShow(DelItem-1);
		end;
	end
	else
		ShowPlugin(False);
	SyncPluginSpn(frmSettings.lstPluginList.Count+1);
	SavePlugins(Program_Plugin);
end;

end.
