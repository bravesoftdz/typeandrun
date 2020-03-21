unit PicList;

interface

Uses Classes,IniFiles;

Const MainGroup='Changer';

Type TMyList=class(TStringList) // ���������������� ������, �������� ��� �������������� ����������
       Constructor Create;
      public
       FileName:string;
       Pos:integer;   // ����� ��������� �������
       IsWall:boolean; // ���������, ��� ����� ������� ���� �������� �����
       IsJpeg2Bmp:boolean; // ���������, ��� ��� ����������� ��������� ���������� �������������� JPG � BMP (������ ��� �����)
     end;

var Ini:TIniFile;

Procedure CopyPic(const Name1,Name2:string;Jpg:boolean);

implementation

Uses Windows,SysUtils,Jpeg,Graphics;

Constructor TMyList.Create;
begin
 inherited Create;
 FileName:='';Pos:=-1;
 IsWall:=false;IsJpeg2Bmp:=false;
end;

Procedure CopyPic(const Name1,Name2:string;Jpg:boolean);
var MyJpeg:TJpegImage;
    Bmp:TBitmap;
    X,Y:PChar;
begin
 if Jpg then begin        // �������� �������������� JPEG � BMP
  MyJpeg:=TJpegImage.Create;Bmp:=TBitmap.Create;
  MyJpeg.LoadFromFile(Name1);  // ������ ����������� �� ����� JPEG
  Bmp.Width:=MyJpeg.Width;Bmp.Height:=MyJpeg.Height;
  case MyJpeg.PixelFormat of
   jf24Bit:Bmp.PixelFormat:=pf24bit;
   else Bmp.PixelFormat:=pf8bit;
  end;
  Bmp.Canvas.Draw(0,0,MyJpeg);
  Bmp.SaveToFile(Name2);  // ���������� �� ����� ����������� � ������� BMP
  MyJpeg.Free;
  Bmp.Free;
 end else begin
  GetMem(X,256);GetMem(Y,256);
  CopyFile(StrPCopy(X,Name1),StrPCopy(Y,Name2),false); // � ��������� ������, ������� �����������
  FreeMem(Y,256);FreeMem(X,256);
 end;
end;

end.
