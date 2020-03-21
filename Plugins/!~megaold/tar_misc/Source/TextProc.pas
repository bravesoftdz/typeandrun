unit TextProc;

interface
Const MaxS=25;
      MaxId=20;
      MaxBuf=2048;

Procedure IDDetect(S1:string);       // ��������� ������ ������ �� ������� � ���������� ��������� � ���������� IDs
Procedure ContDetect(var F:file);    // ������ ��������� ������ � ������������ � ����������� ������ IDDetect
Procedure FormatDetect(var F,F2:file);   // ���������� ���� F � ���� F2, ��������� ����������� ���������������
Function ValidID:boolean;

var ID:word;                         // ���������� ���������������
    UseClearID:boolean;              // ���� ����������, �� ��� ���������� ����������� ������������� �������� ������, ����� - � ���������
    IDs:array[1..MaxId]of record     // ������ ������ ��������������� �� ����������
     Name:string;                    // ��� ��������������
     Cont:string;                    // ���������� �������������� (�������!)
     Star:boolean;                   // ������� �������������
     NonClear:boolean;               // ���� ������������� ����, � ���� ����������, �� ������ �� �����������
     Trimmer:boolean;
     CaseUp,CaseDown:boolean;        // �������� ������ �������� ��������������. ��������� CaseDown, ���� ������� ���
     Wid:integer;                    // ������ ���������� ���� (0 ��� ����� ������������ ������)
     K:word;                         // ������� ����� ���������
     Divs:array[1..Maxs]of string;   // ��������
    end;

implementation

Uses SysUtils,Windows;

Procedure IDDetect(S1:string);
var Temp:string[40];                 // ������� �������� ������ (� ����������� �� ���������� ����� ����� �������� � ���������� ����������)
    I,C:integer;                     // ������� � ������ � �������� ������, �������� �����
    Mask,Start:boolean;              // �������� ����� � ���� ��������� ��������
    Mode:(SeekID,ReadID,ReadFree,ReadNum,ReadQ);// ����� ��������
begin
 FillChar(Ids,sizeof(Ids),0);
 Mode:=SeekID;I:=1;S1:=S1+',';ID:=1; // ����������� ��������� ����������� - ��� ��������� ���������
 while(I<=Length(S1))do begin        // ���������� �������� ��������� ��� ������
  case Mode of
   SeekID:if S1[I]='%' then begin    // ����� �������� ������ �������������� - ������� % (��������)
    Mode:=ReadID;Temp:=''; // ���������� � ������ ��������������
    Start:=true;Mask:=false;
    //FillChar(Ids[Id],sizeof(Ids[Id]),0);
   end;
   ReadID:case upcase(S1[I]) of      // ������ ���������� ��������������
    '%':begin Ids[Id].Name:=Temp;Mode:=ReadFree;Temp:='';end; // ������ ����� ��������������
    'A'..'Z':begin // ������ ������ ���������� ������
     if Start then begin // ���������������� ������� ������ ����
      if(Temp='')then Temp:='0';
      try Ids[Id].Wid:=StrToInt(temp);except Ids[Id].Wid:=0;end;
      Temp:='';Start:=false;
     end;
     Temp:=Temp+upcase(S1[I]); // � ����� ������, ������ ���������� � �������������
     end;
    '0'..'9':Temp:=Temp+S1[I]; // ��������� ����� (��� ������ ����, ��� � ����� ��������������)
    '*':if Start then Ids[Id].Star:=true; // ��������� ��������� ����� � ������ ��������������
    '!':if Start then Ids[Id].NonClear:=true;
    '^':if Start then begin Ids[Id].CaseUp:=true;Ids[Id].CaseDown:=false;end;
    '_':if Start then begin Ids[Id].CaseDown:=true;Ids[Id].CaseUp:=false;end;
    '&':if Start then Ids[Id].Trimmer:=true;
   end;
   ReadFree:case S1[I]of // ������ ������������
    '\':if Mask then begin Temp:=Temp+'\';Mask:=false;end else Mask:=true; // ������������� �������
    '#':if Mask then begin Temp:=temp+'#';Mask:=false;end else begin Mode:=ReadNum;C:=0;end; // ������� ASCII ����
    '''':if Mask then begin Temp:=Temp+'''';Mask:=false;end else Mode:=readQ; // ������� ������� ����� ������
    '%':if Mask then begin temp:=Temp+'%';Mask:=false;end else begin // ������� ������ ������ ��������������
     if(Temp<>'')then begin Inc(Ids[Id].K);Ids[Id].Divs[Ids[Id].K]:=Temp;end;Dec(I);Mode:=SeekID;
     if(Ids[Id].K=0){and(Ids[Id].Wid=0)}then if(ID>1)then begin IDs[Id].Divs:=Ids[Id-1].Divs;IDs[Id].K:=Ids[Id-1].K;end else Dec(Id);
     // ������������ ��� ������� ����������� ���������� ��������, ����� ������������� "������" �������������
     Inc(Id); // ������� �� ����� �������������
    end;
    ',':if Mask then begin Temp:=Temp+',';Mask:=false;end else begin // ������� ������ �����������
     Inc(Ids[Id].K);Ids[Id].Divs[Ids[Id].K]:=Temp;Temp:=''; // ���������� �������� ����������� � ������� � ������
    end;
    else begin Mask:=false;Temp:=temp+S1[I];end; // ��� ��������� ������� ������ ������� �� ����������
   end;
   ReadNum:if(S1[I]in['0'..'9'])and(10*C+ord(S1[I])-ord('0')<255)then C:=10*C+ord(S1[I])-ord('0')
    else begin Temp:=Temp+chr(C);Mode:=ReadFree;Dec(I);end; // ���� ASCII ����
   ReadQ:if(S1[I]='''')then Mode:=ReadFree else Temp:=Temp+S1[I]; // ������ ���� ������
  end;
  Inc(I); // ������� �� ��������� ������
 end;
 // ������ ������� �� �������, ������� �������� � ������.
 // � ����� ������ ������������� ������ ������������, �� �� �������� ���������� - ����� ����� ������ ����������.
end;

Procedure ContDetect(var F:file);
var Buf:array[1..MaxBuf]of char;
    I,J,Cur,Last,Len,Stop:integer;
Function APos(S:string):integer;
var I,J:integer;
begin
 if S='' then begin Result:=0;Exit;end;
 // �� ������������ ������ ������
 J:=0;I:=1;While(I+J<=Len)do begin
  if J=Length(S) then begin Result:=I;Exit;end else   // ���������
  if Buf[I+J]=S[J+1] then Inc(J) else // �����
  begin Inc(I);J:=0;end;  // ������������
 end;
 if J<Length(S) then Result:=0 else Result:=I; // �� �������
end;
begin
 For I:=1 to ID do with Ids[I] do begin
  if Wid=0 then begin                                 // ���� � ����� ������ -1 - ���������
   Last:=0;BlockRead(F,Buf,MaxBuf,Len);Stop:=0;
   For J:=1 to K do begin                             // ����� ���������� � ������ ����������� ��� �������� ��������������
    Cur:=APos(Divs[J]);
    if((Last=0)or(Last>Cur))and(Cur<>0)then begin Last:=Cur;Stop:=Last+Length(Divs[J])-1;end;
   end;
   if Last<>0 then begin                              // ���� �� ���� ����������� ������ � ���� ������
    SetLength(Cont,Last);
    For J:=1 to Last do Cont[J]:=Buf[J];              // ����������� ��������� � ��������
    Seek(F,FilePos(F)-(Len-Stop));                    // ������� ��������� � �����
    if Star then repeat                               // ������� ��� ����������� ����� �������, ���� ��� ����������
     BlockRead(F,Buf,MaxBuf,Len);
     For J:=1 to K do if APos(Divs[J])=1 then break;  // ����� �����������
     if J>K then Seek(F,FilePos(F)-Len)
     else Seek(F,FilePos(F)-(Len-Length(Divs[J])));   // ��������, ���� ����������� ������
    until J>K;
   end else if EOF(F) then begin
    SetLength(Cont,Len);
    For J:=1 to Len do Cont[J]:=Buf[J];
   end else if UseClearID then begin                  // ����������� �� ������� - ���� ������
    Seek(F,FilePos(F)-MaxBuf);                        // ��������� �����
    Cont:='';                                         // ������������� ������ �������������
   end else begin
    SetLength(Cont,Len div 2);                     // ������ �������: �������� ��� �������� ���������
    For J:=1 to Len div 2 do Cont[J]:=Buf[J];
    Seek(F,FilePos(F)-Len div 2);
   end;
  end else if Wid>0 then begin
   BlockRead(F,Buf,Wid,Len);                          // ������ ���� ������������� ������
   if Len<Wid then SetLength(Cont,Len)else SetLength(Cont,Wid);
   For J:=1 to Length(Cont) do Cont[J]:=Buf[J];       // ���� � ������
  end;
  if CaseUp then Cont:=AnsiUpperCase(Cont);           // ��������� �������� � ��������� �������, ���� ��� ����������
  if CaseDown then Cont:=AnsiLowerCase(Cont);
  if Trimmer then Cont:=Trim(Cont);
  //FillChar(Buf,sizeof(Buf),0);
 end;
end;

Procedure FormatDetect(var F,F2:file);
var I,Cur,Last,Len,Num:integer;
    Buf:array[1..MaxBuf]of char;
Function APos(S:string):integer; // ����� ����������� ������, �� � ��������������
var I,J,ii:integer;
begin
 if S='' then begin Result:=0;Exit;end;
 // �� ������������ ������ ������
 ii:=2;While(upcase(S[1])<>upcase(S[ii]))and(ii<Length(S))do Inc(ii);Dec(ii);
 // ����������� ������ �� ������� ������� (������, �� �������� �����)
 J:=0;I:=1;While(I+J<=Len)do begin
  if J=Length(S) then begin Result:=I;Exit;end else   // ���������
  if(upcase(Buf[I+J])=upcase(S[J+1]))and(J<Length(S))then Inc(J) else // �����
  if J>0 then begin Inc(I,ii);J:=0;end else // ��������� ������������
  Inc(I);                                   // ������ ������������
 end;
 if J<Length(S) then Result:=0 else Result:=I; // �� �������
end;
begin
 Seek(F,0);
 repeat                                           // ���� �� ����� �������� �����
  BlockRead(F,Buf,MaxBuf,Len);Num:=0;Last:=0;     // ����� ��������������
  For I:=1 to Id do with Ids[I] do begin
   Cur:=Apos('%'+Name+'%');
   if((Last=0)or(Last>Cur))and(Cur<>0)then begin Num:=I;Last:=Cur;end;
  end;
  if Num=0 then begin                             // �����������, ���� �� �������
   BlockWrite(F2,Buf,Len,Cur);if Cur<>Len then break;
  end else begin                                  // ������, ���� ������ �������������
   Seek(F,FilePos(F)-Len+Last+Length(Ids[Num].Name)+1);
   BlockWrite(F2,Buf,Last-1,Cur);if Cur<>Last-1 then break;
   BlockWrite(F2,Ids[Num].Cont[1],Length(Ids[Num].Cont),Cur);
   if Cur<>Length(Ids[Num].Cont) then break;
   Len:=MaxBuf;
  end;
 until Len<MaxBuf;
end;

Function ValidID:boolean;
var I:integer;
begin
 Result:=false;
 For I:=1 to Id do with Ids[I] do if NonClear and(Cont='')then Exit;
 Result:=true;
end;

end.
