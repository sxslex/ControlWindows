(*
Program to view and control all the windows open.
You can also control some features of these windows .
by sx.slex@gmail.com
*)
unit ufrmcwimain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Buttons, Windows;

type
  TLibHandle = Integer;
  { TInfoWindow }
  TInfoWindow = class
  public
    id: Integer;
    handle: HWND;
    process: String;
    cname: String;
    caption : String;
    node: TTreeNode;
  end;

  { Tfrmcwimain }

  Tfrmcwimain = class(TForm)
    btnRefresh: TButton;
    btnSave: TBitBtn;
    btnKill: TButton;
    btnClose: TButton;
    chbEnabled: TCheckBox;
    chbVisibled: TCheckBox;
    edtCaption: TLabeledEdit;
    edtClass: TLabeledEdit;
    edtID: TLabeledEdit;
    edtHandle: TLabeledEdit;
    Panel1: TPanel;
    pnlRight: TPanel;
    Splitter1: TSplitter;
    trvWindows: TTreeView;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
    procedure chbEnabledChange(Sender: TObject);
    procedure chbEnabledClick(Sender: TObject);
    procedure chbVisibledChange(Sender: TObject);
    procedure chbVisibledClick(Sender: TObject);
    procedure edtCaptionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure trvWindowsClick(Sender: TObject);
    procedure trvWindowsExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure trvWindowsGetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private
    { private declarations }
  public
    { public declarations }
    infoWindowExpand: TInfoWindow;
  end;

var
  frmcwimain: Tfrmcwimain;

implementation
//function GetModuleFileName(Module: TLibHandle; Buffer: PChar; BufLen: Integer): Integer;

{$R *.lfm}

{ Tfrmcwimain }

function GetWindowFileName(const hWin: HWND): string;
var
  lpBuff: PChar;
  nCount: Integer;
  dwProcessId, dwThreadId, hInst, hProcess: Cardinal;
begin
  Result := '';
  nCount := 1024;
  GetMem(lpBuff, nCount);
  try
    hInst := GetWindowLong(hWin, GWL_HINSTANCE);
    dwThreadId := GetWindowThreadProcessId(hWin, dwProcessId);
    hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessId);
    if hProcess > 0 then
      try
        //GetModuleFileNameEx(hProcess, hInst, lpBuff, nCount);
      finally
        CloseHandle(hProcess);
      end;
    Result := string(lpBuff);
  finally
    ReallocMem(lpBuff, 0);
  end;
end;

function CallBackEnumWindows(wnd:Cardinal; lParam: Integer): longbool; stdcall;
var
  caption, cname, processo: string;
  infoWindow: TInfoWindow;
begin
  Result := True;
  try
    if IsWindow(wnd) then
    begin
      SetLength(caption, MAX_PATH);
      SetLength(cname, MAX_PATH);
      SetLength(processo, MAX_PATH);

      SetLength(caption, GetWindowText(wnd, PChar(caption), MAX_PATH));
      SetLength(cname, GetClassName(wnd, PChar(cname), MAX_PATH));
      processo := GetWindowFileName(wnd);
      if caption <> '' then
      begin
        infoWindow := TInfoWindow.Create;
        infoWindow.handle := wnd;
        infoWindow.id := GetDlgCtrlID(wnd);
        infoWindow.process := processo;
        infoWindow.caption := caption;
        infoWindow.cname := cname;
        infoWindow.node := frmcwimain.trvWindows.Items.AddChildObject(
          nil,
          infoWindow.caption + ' [' + infoWindow.cname + ']',
          infoWindow
        );
        frmcwimain.trvWindows.Items.AddChild(infoWindow.node, '-');
        Result := True;
      end;
    end;
  except
    Exit;
  end;
end;

function CallBackEnumChildWindows(wnd: HWND; ParentInfoWindow: LPARAM): BOOL; stdcall;
var
  hwnd,
  caption: array[0..255] of char;
  cname: array[0..255] of char;
  id: Integer;
  infoWindow: TInfoWindow;
begin
  GetClassName(wnd, cname, SizeOf(hwnd) - 1);
  SendMessage(wnd, WM_GETTEXT, 256, Integer(@caption));
  infoWindow := TInfoWindow.Create();
  infoWindow.cname := cname;
  infoWindow.caption := caption;
  infoWindow.handle := wnd;
  infoWindow.id := GetDlgCtrlID(wnd);
  infoWindow.node := frmcwimain.trvWindows.Items.AddChildObject(
    frmcwimain.infoWindowExpand.node,
    '[' + infoWindow.cname + '] -' + infoWindow.caption,
    infoWindow
  );
  frmcwimain.trvWindows.Items.AddChild(infoWindow.node, '-');
  Result := True;
end;

procedure Tfrmcwimain.btnRefreshClick(Sender: TObject);
begin
  trvWindows.Items.Clear;
  EnumWindows(@CallBackEnumWindows, 0);
  trvWindows.AlphaSort
end;

procedure Tfrmcwimain.BitBtn1Click(Sender: TObject);
begin

end;

procedure Tfrmcwimain.btnCloseClick(Sender: TObject);
begin
  SendMessage(infoWindowExpand.handle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

procedure Tfrmcwimain.btnSaveClick(Sender: TObject);
var
  scaption: String;
begin
  caption := edtCaption.Text;
  SendMessage(infoWindowExpand.handle, WM_SETTEXT, 0, Integer(PChar(scaption)));
end;

procedure Tfrmcwimain.btnKillClick(Sender: TObject);
var
   dwProcessId: Cardinal;
begin
  GetWindowThreadProcessId(infoWindowExpand.handle, dwProcessId);
  TerminateProcess(
    OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessId),
    0
  )
end;

procedure Tfrmcwimain.chbEnabledChange(Sender: TObject);
begin

end;

procedure Tfrmcwimain.chbEnabledClick(Sender: TObject);
begin
  EnableWindow(infoWindowExpand.handle, chbEnabled.Checked);
end;

procedure Tfrmcwimain.chbVisibledChange(Sender: TObject);
begin

end;

procedure Tfrmcwimain.chbVisibledClick(Sender: TObject);
begin
  if chbVisibled.Checked then
  begin
    ShowWindow(infoWindowExpand.handle, SW_SHOW);
  end else begin
    ShowWindow(infoWindowExpand.handle, SW_HIDE);
  end;
end;

procedure Tfrmcwimain.edtCaptionChange(Sender: TObject);
begin
  btnSave.Enabled:=True;
end;

procedure Tfrmcwimain.FormCreate(Sender: TObject);
begin
  btnRefreshClick(btnRefresh);
end;

procedure Tfrmcwimain.trvWindowsClick(Sender: TObject);
begin                            ;
  infoWindowExpand := TInfoWindow(trvWindows.Selected.Data);
  edtID.Text := IntToStr(infoWindowExpand.id);
  edtHandle.Text := IntToStr(infoWindowExpand.handle);
  edtCaption.Text := infoWindowExpand.caption;
  edtClass.Text := infoWindowExpand.cname;
  chbEnabled.Checked := IsWindowEnabled(infoWindowExpand.handle);
  chbVisibled.Checked := IsWindowVisible(infoWindowExpand.handle);
end;

procedure Tfrmcwimain.trvWindowsExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  infoWindowExpand := TInfoWindow(Node.Data);
  if ((Node.Count = 1) and (Node.Items[0].Text = '-')) then
  begin
    infoWindowExpand.node.DeleteChildren;
    EnumChildWindows(
      infoWindowExpand.handle,
      @CallBackEnumChildWindows,
      Integer(infoWindowExpand)
    );
  end;
end;

procedure Tfrmcwimain.trvWindowsGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin

end;

end.

