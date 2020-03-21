#include <windows.h>


typedef struct _TInfo
{
    int   size;           /* stricture size, bytes                           */
    char* PChar;          /* plugin detection string, should be              */
                          /* 'Hello! I am the TypeAndRun plugin.'            */
    char* name;           /* plugin name                                     */
    char* version;        /* plugin version                                  */
    char* description;    /* plugin description                              */
    char* author;         /* plugin author                                   */
    char* copyright;      /* copyright                                       */
    char* homepage;       /* homepage                                        */
} TInfo;

typedef struct _TExec
{
    int   size;           /* structure size                                  */
    /* run ����������
    	0, ���� ������ ��������� ���������
    	1, ���� ������� ��������� ������
    	2, ���� ������� ��������� ������ � ����� �������� ����� � �������    */
    int   run;            /* if string was processed then set non-zero value */
    char* con_text;       /* new text in console                             */
    char* con_sel_start;  /* first symbol to select                          */
    char* con_sel_length; /* length of selection                             */
} TExec;

void   __cdecl Load( HWND mainWindow ); /* launch when plugin loaded         */
void   __cdecl UnLoad();                /* launch when plugin unloaded       */
TInfo  __cdecl GetInfo();               /* getting infomation about plugin   */
int    __cdecl GetCount();              /* get count of plugin aliases       */
char*  GetString( int num );            /* get plugin alias                  */
TExec  __cdecl RunString( char* exec );

