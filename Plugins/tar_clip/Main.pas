unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls;

type
  TClipEditor = class(TForm)
    MainMenu1: TMainMenu;
    N2: TMenuItem;
    Disappear: TMenuItem;
    AlwaysOnTop: TMenuItem;
    Memo1: TMemo;
    N3: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    Clips: TComboBox;
    Dummy: TPopupMenu;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    IsStatic: TCheckBox;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N21: TMenuItem;
    N20: TMenuItem;
    pureclip1: TMenuItem;
    pureclip2: TMenuItem;
    procedure DisappearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AlwaysOnTopClick(Sender: TObject);
    procedure ClipsChange(Sender: TObject);
    procedure ClipsSelect(Sender: TObject);
    procedure ClipsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N5Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N13Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure pureclip1Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure pureclip2Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
   protected
    Timer1,NextViewer:integer;
    procedure WndProc(var M:TMessage);override;
   public
    AllowClipboard:boolean;
    procedure SendClipboard(Mode:byte);
    procedure PutClipboard;
    procedure StockClipboard;
    procedure Store;
  end;

var
  ClipEditor: TClipEditor;

implementation

{$R *.dfm}

Uses Common,Option,Wins;

Const SpecGroup='Lang_main';

procedure TClipEditor.Store;
var I,Count:integer;
    C:TClip;
begin
 ClipsSelect(nil); // ��������� ��������� ����������� �����
 // ��������� ������ ������� ������
 Ini.WriteInteger(MainGroup,'Left',Left);
 Ini.WriteInteger(MainGroup,'Top',Top);
 Ini.WriteBool(MainGroup,'Disappear',Disappear.Checked);
 Ini.WriteBool(MainGroup,'AlwaysOnTop',AlwaysOnTop.Checked);
// UnregisterHotkey(Handle,1); // ������� ���������� ������� ����
 if PasteMode in [1,2,3] then UnregisterHotkey(Handle,2); // � ���� ������ � �������, ���� ��� ����������
 if Timer1<>0 then KillTimer(Handle,1); // � ������ �����������, ���� ��� ����������
 ChangeClipboardChain(Handle,NextViewer); // � ����������� �� ������� �������� �� �������
 Ini.ResetBinary; // ������� � ����� ������ �������� ������
 Count:=Ini.ReadInteger(MainGroup,'ClipCount',0);
 For I:=1 to Count do begin // ������� ������ �����
  Ini.DeleteKey(MainGroup,'Clip'+inttostr(I));
  Ini.DeleteKey(MainGroup,'Static'+inttostr(I));
  Ini.DeleteKey(MainGroup,'Name'+inttostr(I));
 end;
 Ini.WriteInteger(MainGroup,'ClipCount',Clips.Items.Count);
 For I:=1 to Clips.Items.Count do begin // ��������� ��� �����
  C:=Clips.Items.Objects[I-1] as TClip;
  Ini.WritePChar(Maingroup,'Clip'+inttostr(I),C.FData);
  Ini.WriteBoolean(MainGroup,'Static'+inttostr(I),C.Static);
  Ini.WriteString(MainGroup,'Name'+inttostr(I),Clips.Items.Strings[I-1]);
 end;
end;

Procedure TClipEditor.PutClipboard;
var Clip:TClip;
begin
 if(Clips.ItemIndex>0)then begin
  Clip:=Clips.Items.Objects[Clips.ItemIndex] as TClip;
  Clip.SetClipboard(Handle);
 end;
end;

procedure TClipEditor.StockClipboard;
var Current,I,Count,Last:integer;
    Clip:TClip;
begin
 Sleep(DelayCopy);
 Clip:=TClip.Create(GetForegroundWindow);
 if Clip.Empty then begin
  Clip.Free;
  AllowClipboard:=true;
  exit;
 end;
 Current:=-1;Count:=0;Last:=-1; // ���� ����� �� ����� � �������
 For I:=0 to Clips.Items.Count-1 do begin
  if lstrcmp(Clip.FData,(Clips.Items.Objects[I] as TClip).FData)=0 then Current:=I;
  if not (Clips.Items.Objects[I] as TClip).Static then begin Inc(Count);Last:=I;end;
 end;
 ClipsSelect(ClipEditor);Clips.Tag:=-1; // ��������� ��������� ���������
 if Current=-1 then begin // ����� ����
  while(Count>=MaxDynamic)and(Last>0)do begin
   if not (Clips.Items.Objects[Last] as TClip).Static then begin Clips.Items.Delete(Last);Dec(Count);end;
   Dec(Last);
  end;
  Clips.Items.InsertObject(0,ExtractDescr(Clip.FData),Clip);
  Clips.ItemIndex:=0;
 end else begin // �������� ������ ����
  while Current>0 do begin // ���������� �������� ���� �� ����� ����
   Clips.Items.Exchange(Current,Current-1);
   Dec(Current);
  end;
  Clips.ItemIndex:=0; // �������� ������� ����
  Clip.Free;
 end;
 ClipsSelect(ClipEditor); // ��������� ���������� ���� Memo
end;

procedure TClipEditor.SendClipboard(Mode:byte);
var Data,I:integer;
    P:PChar;
begin
 if Mode=0 then begin
  if PasteMode in [1,2,3] then UnregisterHotkey(Handle,2);
  Wait(DelayCopy,GetForegroundWindow);
  SendHotkey(HotPaste);
  Wait(1,GetForegroundWindow);
  if PasteMode in [1,2,3] then RegisterDelphiHotkey(Handle,2,HotPaste); // ���������� ������� ����� �������
 end else if OpenClipboard(GetForegroundWindow) then begin
  Data:=GetClipboardData(CF_TEXT);
  P:=GlobalLock(Data);
  For I:=0 to GlobalSize(Data)-1 do begin
   case Mode of
    1:if P[I]<>#10 then SendKey(P[I]);
    2:if P[I]='-' then SendKey(#9) else if P[I]<>#10 then SendKey(P[I]);
    3:if P[I]='-' then Sleep(DelayPrint) else if P[I]<>#10 then SendKey(P[I]);
   end;
   Sleep(DelayPrint);
  end;
  GlobalUnlock(Data);
  CloseClipboard;
 end;
end;

procedure TClipEditor.WndProc(var M:TMessage);
// ���� ���� ��������� ������� ���� ������������, �������� ��� ����
var fActive:word;
begin
 if M.Msg=WM_ACTIVATE then begin // ��� ��������� � ����������� ���� - OnActivate �� ��������
  fActive:=M.WParam and $FFFF;
  if((M.WParam shr 16)=0)and(fActive=WA_INACTIVE)and(Disappear.Checked)then begin // �������������� ������������
   M.Result:=0;
   Timer1:=SetTimer(Handle,1,DisappearDelay,nil);
  end;
  if(((M.WParam shr 16)=0)and(fActive=WA_INACTIVE))then PutClipboard;
   // ���� �� ������� ������� �����, �� �������� ����� Windows ������ �������
  if((M.WParam shr 16)=0)and((fActive=WA_ACTIVE)or(fActive=WA_CLICKACTIVE))and(Timer1<>0)then begin
   // ���� �� �������������� �� ���������������� - ���������� ������
   Timer1:=0;
   KillTimer(Handle,1);
  end;
 end else if(M.Msg=WM_TIMER)and(M.WParam=1)then begin // ������ ����������������
  Timer1:=0;
  KillTimer(Handle,1); // ���������� ������
  Hide; // ��������
  M.Result:=0;
 end else if M.Msg=WM_HOTKEY then begin
  if(M.WParam=2)then SendClipboard(PasteMode);// ������ ������� ������� �� ������
  M.Result:=0; // ������� ����� ����������
 end else if(M.Msg=WM_DRAWCLIPBOARD)and(AllowClipboard)then begin // ��� ��������� ����������� ������
  AllowClipboard:=false; // ��������� ���������� ��������� ������
  if AutoPureClip then PureClip;// �������������� �������� ��������������
  M.Result:=SendMessage(NextViewer,WM_DRAWCLIPBOARD,M.WParam,M.LParam);
  StockClipboard;// ��� ���������� ������ � ������� ��� �� ���������
  // ��� ����������� - ��������� ��������� ���������� ������������ ������
  AllowClipboard:=true; // �������� ���������� ��������� ������
 end else if(M.Msg=WM_CHANGECBCHAIN)then begin
  // ���� ������� ������������� ����������
  if NextViewer=M.WParam then NextViewer:=M.LParam // ���� ���������� ��������� ���� - �������� ���������
  else M.Result:=SendMessage(NextViewer,WM_CHANGECBCHAIN,M.WParam,M.LParam);
   // ��� ���� �� ��������� � ������ - ��������� ��������� �� �������
 end else if M.Msg=WM_SYSCOMMAND then begin // ������������ ��������� ���������
  if M.WParam=SC_MINIMIZE then begin // ���������� ������ "��������" ��� "��������������"
   Hide;M.Result:=0;
  end else if M.WParam=SC_CLOSE then begin // ����� - ����� ������ ������
   Hide;M.Result:=0;
  end else inherited WndProc(M); // ��������� ��������� ��������� ��������� - �� ���������
 end else inherited WndProc(M); // ��������� ��������� ������������ Delphi
end;

procedure TClipEditor.DisappearClick(Sender: TObject);
begin // ���� ���������� ��������������
 Disappear.Checked:=not Disappear.Checked;
end;

procedure TClipEditor.FormCreate(Sender: TObject);
var I,Count:cardinal;
    C:TClip;
begin
 Caption:=Ini.ReadString(SpecGroup,'Caption','Clip editor');
 IsStatic.Caption:=Ini.ReadString(SpecGroup,'Static','Static clip');
 N2.Caption:=Ini.ReadString(SpecGroup,'Parameters','Parameters');
 Disappear.Caption:=Ini.ReadString(SpecGroup,'Disappear','Auto disappear');
 AlwaysOnTop.Caption:=Ini.ReadString(SpecGroup,'OnTop','Always on top');
 N5.Caption:=Ini.ReadString(SpecGroup,'BufOpt','Buffer options');
 N6.Caption:=Ini.ReadString(SpecGroup,'WinOpt','Exclusions');
 Pureclip1.Caption:=Ini.ReadString(SpecGroup,'PasteOnPureclip','Paste on ~pureclip');
 PureClip2.Caption:=Ini.ReadString(SpecGroup,'AutoPureclip','Auto ~pureclip');
 N11.Caption:=Ini.ReadString(SpecGroup,'Clips','Clips');
 N12.Caption:=Ini.ReadString(SpecGroup,'AddClip','Add clip');
 N13.Caption:=Ini.ReadString(SpecGroup,'DelClip','Delete clip');
 N17.Caption:=Ini.ReadString(SpecGroup,'DelDynClip','Delete dynamic clips');
 N18.Caption:=Ini.ReadString(SpecGroup,'DelAll','Delete all clips');
 N15.Caption:=Ini.ReadString(SpecGroup,'Regular','Regular paste');
 N16.Caption:=Ini.ReadString(SpecGroup,'KeyPaste','Simulate keyboard');
 N19.Caption:=Ini.ReadString(SpecGroup,'Serial1','Serial number 1');
 N21.Caption:=Ini.ReadString(SpecGroup,'Serial2','Serial number 2');
 N7.Caption:=Ini.ReadString(SpecGroup,'Help','Help');
 N8.Caption:=Ini.ReadString(SpecGroup,'Help','Help');
 N10.Caption:=Ini.ReadString(SpecGroup,'About','About');
 AllowClipboard:=true; // ����� ��������� ������ - ����� �����, � ������� ��������� ��������, ����� ��������
// RegisterHotkey(Handle,1,MOD_CONTROL or MOD_ALT,ord('Q')); // ���� ������ ��� �������
 Timer1:=0;
 NextViewer:=SetClipboardViewer(Handle); // ���������������� ��� ����������� ������
 // ������ ������ �� INI
 Disappear.Checked:=Ini.ReadBool(MainGroup,'Disappear',false);
 AlwaysOnTop.Checked:=Ini.ReadBool(MainGroup,'AlwaysOnTop',false);
 if AlwaysOnTop.Checked then SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE);
 Pureclip1.Checked:=PasteOnPureclip;
 PureClip2.Checked:=AutoPureClip;
 case PasteMode of // ��������, ����� ����������� ������� � �������������� ������� ����
  0:N15Click(N15);
  1:N15Click(N16);
  2:N15Click(N19);
  3:N15Click(N21);
 end;
 Count:=Ini.ReadInteger(MainGroup,'ClipCount',0);
 For I:=1 to Count do begin // ��������� �����
  C:=TClip.Create;
  C.FData:=Ini.ReadPChar(Maingroup,'Clip'+inttostr(I));
  C.Static:=Ini.ReadBoolean(MainGroup,'Static'+inttostr(I),true);
  Clips.AddItem(Ini.ReadString(MainGroup,'Name'+inttostr(I),ExtractDescr(C.FData)),C);
 end;
 // ���������� ������� �� ������� ������
 Left:=Ini.ReadInteger(MainGroup,'Left',GetSystemMetrics(SM_CXSCREEN)-Width);
 Top:=Ini.ReadInteger(MainGroup,'Top',0);
 // ���������� ������ ���� - ������ ���� ����� �� ����� ��� ���� (����� ������ �� �������)
 Clips.ItemIndex:=0;
 ClipsSelect(Sender);
 ClipEditorPresent:=true;
end;

procedure TClipEditor.AlwaysOnTopClick(Sender: TObject);
begin // ���� ����������, ����� ����� ���� ������ ������
 AlwaysOnTop.Checked:=not AlwaysOnTop.Checked;
 if AlwaysOnTop.Checked then SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE)
 else SetWindowPos(Handle,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TClipEditor.ClipsChange(Sender: TObject);
var Temp1,Temp2:integer;
begin // ���� ����� ����������������� (������ �� ��� �� �������������, ��...)
 Temp1:=Clips.SelStart;
 Temp2:=Clips.SelLength;
 Clips.Items.Strings[Clips.Tag]:=Clips.Text;
 Clips.ItemIndex:=Clips.Tag;
 Clips.SelStart:=Temp1;
 Clips.SelLength:=Temp2;
end;

procedure TClipEditor.ClipsSelect(Sender: TObject);
var Clip:TClip;
begin // ���� ���� �������� ������
 if(Clips.Tag>=0)and(Clips.Tag<Clips.Items.Count)then begin // ��������� ������, ���� ��� ����������
  Clip:=Clips.Items.Objects[Clips.Tag] as TClip;
  Clip.Data:=Memo1.Text;
  Clip.Static:=IsStatic.Checked;
 end;
 if(Clips.Tag<>Clips.ItemIndex)and(Clips.ItemIndex<>-1)then begin // �������� ������ ������ �����
  Clips.Tag:=Clips.ItemIndex;
  Clip:=Clips.Items.Objects[Clips.ItemIndex] as TClip;
  Memo1.Text:=Clip.Data;
  IsStatic.Checked:=Clip.Static;
 end;
end;

procedure TClipEditor.ClipsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin // ��������� ������� �� �����
 if((Key=VK_INSERT)and(Shift=[ssCtrl]))or
   ((Key=VK_INSERT)and(Shift=[ssShift]))or
   ((Key=VK_DELETE)and(Shift=[ssShift]))or
   ((Key=ord('C'))and(Shift=[ssCtrl]))or
   ((Key=ord('X'))and(Shift=[ssCtrl]))or
   ((Key=ord('V'))and(Shift=[ssCtrl]))then Key:=0;
end;

procedure TClipEditor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin // ���������� ����������
 Store;
 ClipEditorPresent:=false;
end;

procedure TClipEditor.N5Click(Sender: TObject);
begin // ��� ���� ���������� ���������
 UnregisterHotkey(Handle,2); // ����� ������� �����
 Application.CreateForm(TOptionForm, OptionForm);
 OptionForm.ShowModal; // ������� ���� ����������
 OptionForm.Free;
 if PasteMode in [1,2,3] then RegisterDelphiHotkey(Handle,2,HotPaste); // ���������� ������� ����� �������
end;

procedure TClipEditor.N12Click(Sender: TObject);
begin // ���������� ������ ����� - �� ������� �� � ������ ����, ��...
 ClipsSelect(Sender);Clips.Tag:=-1; // ��������� ���������
 if OpenClipboard(GetForegroundWindow) then begin
  EmptyClipboard; // ���������� ������ ����� (������� ���������)
  CloseClipboard;
  Clips.AddItem('Noname',TClip.Create); // �������� �����, ������ �����
  Clips.ItemIndex:=Clips.Items.Count-1; // ������� ����� ����� ��������
 end;
end;

procedure TClipEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin // ��������� "������� �����"
 if(Key=27)and(Shift=[])then begin Key:=0;Hide;end;
end;

procedure TClipEditor.N13Click(Sender: TObject);
var Old:integer;
begin // ���������� ������� ����
 Old:=Clips.ItemIndex; // ��������� ���������� ����
 Clips.DeleteSelected; // ������� ���������� ����
 Clips.Tag:=-1; // ������� ���������� � ���
 if Old>=Clips.Items.Count then Old:=Clips.Items.Count-1; // ���� ������ ��������� ����
 Clips.ItemIndex:=Old; // �������� ��������� � ������� ����
 if Clips.Items.Count>0 then ClipsSelect(Sender) // �������� ����������
 else begin Memo1.Text:='';IsStatic.Checked:=false;Clips.Text:='';end;
end;

procedure TClipEditor.N17Click(Sender: TObject);
var I,Sel:integer;
begin // ������� "������������" ����� - ��, ������� ��������� �������������
 I:=0;Sel:=Clips.ItemIndex; // ��������� ������ �������
 while I<Clips.Items.Count do begin
  if not (Clips.Items.Objects[I] as TClip).Static then begin // ���� ������������
   Clips.Items.Delete(I); // �������
   if Sel>=I then Dec(Sel);
  end else Inc(I); // ������ �� ������
 end;
 if Sel<0 then Sel:=0; // ������� ��������� ���������� ����
 Clips.ItemIndex:=Sel;
 if Clips.Items.Count=0 then begin Memo1.Text:='';IsStatic.Checked:=false;Clips.Text:='';end;
end;

procedure TClipEditor.N18Click(Sender: TObject);
begin // ������� ��� �����
 Clips.Clear;
 Memo1.Text:='';
 IsStatic.Checked:=false;
end;

procedure TClipEditor.N15Click(Sender: TObject);
begin // ������� ����� �������
 if Sender=N15 then begin // ����������� ����� - ����� ������� ����
  if PasteMode in [1,2,3] then UnregisterHotkey(Handle,2);
  PasteMode:=0;
 end;
 if Sender=N16 then begin // ����� ��������� ������ � ����������
  RegisterDelphiHotkey(Handle,2,HotPaste);
  PasteMode:=1;
 end;
 if Sender=N19 then begin // ��������� ������ � ���������� - ���� ��������� ������
  // (������ ������� �� ������� ���������)
  RegisterDelphiHotkey(Handle,2,HotPaste);
  PasteMode:=2;
 end;
 if Sender=N21 then begin // ��������� ������ � ���������� - ���� ��������� ������
  // (� ��������� �������)
  RegisterDelphiHotkey(Handle,2,HotPaste);
  PasteMode:=3;
 end;
 (Sender as TMenuItem).Checked:=true; // ��������� �������
end;

procedure TClipEditor.pureclip1Click(Sender: TObject);
begin // ��������� ������ 
 PureClip1.Checked:=not PureClip1.Checked; // ������ ������������ ��������� ��� �������
 PureClip2.Checked:=false;
 PasteOnPureclip:=PureClip1.Checked; // �������������� ���������� ����������
 AutoPureclip:=PureClip2.Checked;
end;

procedure TClipEditor.N6Click(Sender: TObject);
begin // ������ ����-���������� � �������������� �������� ���������
 Application.CreateForm(TWinList, WinList);
 WinList.ShowModal;
 WinList.Free;
end;

procedure TClipEditor.pureclip2Click(Sender: TObject);
begin // ���������
 PureClip1.Checked:=false;
 PureClip2.Checked:=not PureClip2.Checked;
 PasteOnPureclip:=PureClip1.Checked;
 AutoPureclip:=PureClip2.Checked;
end;

procedure TClipEditor.N10Click(Sender: TObject);
var X,Y:PChar;
begin
 GetMem(X,128);GetMem(Y,32);
 Application.MessageBox(StrPCopy(X,Ini.ReadString('Language','Info',
  'Clipboard extender')+' by Python'),StrPCopy(Y,Ini.ReadString('Language',
  'About','About')),MB_ICONINFORMATION);
 FreeMem(X,128);FreeMem(Y,32);
end;

procedure TClipEditor.N8Click(Sender: TObject);
var P:PChar;
begin
 GetMem(P,512);
 GetModuleFileName(hInstance,P,512);
 ExecuteFile(ChangeFileExt(StrPas(P),'.htm'),'',ExtractFileDir(StrPas(P)),SW_SHOW);
 FreeMem(P,512);
end;

end.
