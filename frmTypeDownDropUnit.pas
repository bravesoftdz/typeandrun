unit frmTypeDownDropUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmTypeDropDown = class(TForm)
    lstDropDown: TListBox;
    procedure FormShow(Sender: TObject);
    procedure lstDropDownClick(Sender: TObject);
    procedure lstDropDownKeyPress(Sender: TObject; var Key: Char);
    procedure lstDropDownKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lstDropDownKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

	public
    
  end;

var
  frmTypeDropDown: TfrmTypeDropDown;
  TextSelStart: integer;
	modCtrl: boolean;

implementation

uses ForAll, Static, Configs, frmConsoleUnit, Settings;

{$R *.dfm}

// ��� ������ �����
procedure TfrmTypeDropDown.FormShow(Sender: TObject);
begin
	ShowWindow(Application.Handle, SW_HIDE);
  lstDropDown.ItemIndex:=0;
  lstDropDown.SetFocus;
end;

// ����� ��������� ��� ������ �������
procedure TfrmTypeDropDown.lstDropDownClick(Sender: TObject);
begin
  frmTARConsole.txtConsole.Text:=lstDropDown.Items.Strings[lstDropDown.ItemIndex];
  if Options.Hint.ShowHint then ViewHint(frmTARConsole.txtConsole.Text);
end;

// ������� ������
procedure TfrmTypeDropDown.lstDropDownKeyPress(Sender: TObject; var Key: Char);
begin
	if (Key=Char(VK_RETURN)) or (Key=Char(VK_ESCAPE)) then begin
		Key:=#0;
		frmTARConsole.txtConsole.SelStart:=TextSelStart;
		frmTARConsole.txtConsole.SelLength:=Length(frmTARConsole.txtConsole.Text)-TextSelStart;
		frmTARConsole.txtConsole.SetFocus;
	end;
	//frmTARConsole.txtConsoleKeyPress(self, Key);
	if (Key=#10) then begin
		frmTARConsole.txtConsole.SelStart:=TextSelStart;
		frmTARConsole.txtConsole.SelLength:=Length(frmTARConsole.txtConsole.Text)-TextSelStart;
		frmTARConsole.txtConsole.SetFocus;
		if modCtrl then begin
			Key:=#13;
			frmTARConsole.txtConsoleKeyPress(Self, Key);
		end;
		Key:=#0;
	end;
end;

// ������ ������
procedure TfrmTypeDropDown.lstDropDownKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if Shift=[ssCtrl] then
		modCtrl:=True;
end;

// ������ ������
procedure TfrmTypeDropDown.lstDropDownKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if Shift=[ssCtrl] then
    modCtrl:=False;
end;

end.
