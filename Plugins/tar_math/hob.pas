unit hob;
{
���� ������ �������� 3 �������, �������������
����� � 16-�, 8-� ��� 2-� ���� � ������������
�� �������������. ���� ��� � ����� ���������-
����� ������� �� ����������. �������� �� ���-
��������� ����� �� ����� ����: ��������������,
��� �� ���� ��� ������������.
������ ������ ���� � ASCIIZ ������� (�.�.
������������� �������� #00.
}
interface
function hex(x:PChar):Longint;
function oct(x:PChar):Longint;
function bin(x:PChar):Longint;

implementation
function hex(x:PChar):Longint; assembler;
asm
  mov esi,eax; // ����� ������
  xor edx,edx; // ������� �������� � �����������
  cld; // �������� ������ "������"
  @1:
  lodsb; // ��������� ��������� ������ � al
  cmp al,0; // ��������� ����� ������
  jz @2;
  shl edx,4;  // �������� �� 16
  cmp al,$40; // ��������� ���� ('A'..'F')
  jb @3;
  add al,9;
  @3:
  and al,$f; // ������� ������� �������
  or dl,al;  // ������� ��������� ����� � ����������
  jmp @1;    // ����: ��������� � ��������� ����-�� �������
  @2:
  mov eax,edx;// ��������� �� ������
end;

function oct(x:PChar):Longint; assembler;
asm
  mov esi,eax;
  xor edx,edx;
  cld;
  @1:
  lodsb;
  cmp al,0;
  jz @2;
  shl edx,3;
  and al,$f;
  or dl,al;
  jmp @1;
  @2:
  mov eax,edx;
end;

function bin(x:PChar):Longint; assembler;
asm
  mov esi,eax;
  xor edx,edx;
  cld;
  @1:
  lodsb;
  cmp al,0;
  jz @2;
  shl edx,1;
  and al,$f;
  or dl,al;
  jmp @1;
  @2:
  mov eax,edx;
end;

end.
