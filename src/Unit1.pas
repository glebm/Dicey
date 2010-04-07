unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, sLabel, sButton, sEdit, sGroupBox, sSkinProvider,
  sSkinManager, Grids, ValEdit, ComCtrls, IniFiles, StrUtils, sHintManager,
  sListView, ExtCtrls, sPanel, ImgList;

type
  TThrow = class
    name, expr: string;
  end;
  TForm1 = class(TForm)
    sGroupBox1: TsGroupBox;
    exprEdt: TsEdit;
    btnThrow: TsButton;
    btnD4: TsButton;
    btnD8: TsButton;
    btnD20: TsButton;
    gridHistory: TValueListEditor;
    sSkinManager1: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    sHintManager1: TsHintManager;
    pnl: TsPanel;
    sButton1: TsButton;
    sButton2: TsButton;
    resultLabel: TsLabelFX;
    sPanel1: TsPanel;
    icons: TImageList;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnThrowClick(Sender: TObject);
    procedure btnD4Click(Sender: TObject);
    procedure gridHistoryClick(Sender: TObject);
    procedure exprEdtKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    history: TStringList;
    procedure eval(const expr: String);
    procedure add(const s: string; v: integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.add(const s: string; v: Integer);
begin
  history.Insert(0, s + '=' + inttostr(v));
  gridHistory.Strings := history;
  resultLabel.Caption := inttostr(v);
end;

procedure TForm1.btnD4Click(Sender: TObject);
begin
  eval((Sender as TButton).Caption);
end;

procedure TForm1.btnThrowClick(Sender: TObject);
begin
  eval(exprEdt.Text);
end;

procedure TForm1.eval(const expr: string);
var a, b, c, i, n: integer;
    negative: boolean;
    s: String;
begin
  i := 1;
  a := 0;
  b := 0;
  c := 0;
  s := AnsiLowerCase(expr);
  n := length(s);
  while (s[i] <> 'd') and (i <= n) do begin
    if not (s[i] in ['0'..'9']) then exit;
    a := a * 10 + ord(s[i]) - ord('0');
    inc(i);
  end;
  if a = 0 then a := 1;
  if i = n then exit;
  inc(i);
  while (i <= n) do begin
    if not (s[i] in ['0'..'9']) then break;
    b := b * 10 + ord(s[i]) - ord('0');
    inc(i);
  end;
  while (s[i] = ' ') do inc(i);
  if (s[i] = '+') or (s[i] = '-') then begin
    negative := s[i] = '-';
    inc(i);
    while (s[i] = ' ') do inc(i);
    while (i <= n) do begin
      if not (s[i] in ['0'..'9']) then break;
      c := c * 10 + ord(s[i]) - ord('0');
      inc(i);
      end;
  end;

  if (b = 0) then exit;
  n := 0;
  for i := 1 to a do begin
    n := n + random(b) + 1;
    sleep(100);
    end;
  if negative then c := -c;
  n := n + c;
  add(expr, n);
end;

procedure TForm1.exprEdtKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var Mgs: TMsg;
begin
  if Key = VK_RETURN then begin
    eval(exprEdt.Text);
    PeekMessage(Mgs, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var ini: TIniFile;
    t: TThrow;
    sname: string;
    keys, sections: TStrings;
    lv: array of TsListView;
    ListItem: TListItem;
    i, j: integer;
    x: TsPanel;//TsGroupBox;
    it, it2: TStringsEnumerator;
begin
  try
    keys := TStringList.Create();
    sections := TStringList.Create();
    ini := TIniFile.Create(GetCurrentDir + '/dnd3.ini');
    ini.ReadSections(sections);
    setlength(lv, sections.Count);
    it2 := sections.GetEnumerator;

    i := 0;
    while it2.MoveNext do begin
      sname := it2.GetCurrent;
      ini.ReadSection(sname, keys);
      it := keys.GetEnumerator;
      x := TsPanel.Create(Self);
      with x do begin
        Parent := pnl;
        Align := alTop;
        AlignWithMargins := true;
        Margins.Left := 5;
        Margins.Top := 5;
        Margins.Right := 5;
        //Caption := ReplaceStr(sname, '_', ' ');
        Font.Name := 'Trebuchet MS';
        Font.Size := 10;
        Font.Style := Font.Style + [fsBold];
        SkinData.SkinSection := 'PANEL_LOW';
        Height := Height + 15;
      end;
      lv[i] := TsListView.Create(Self);
      with lv[i] do begin
        Parent := x;
        ViewStyle := vsSmallIcon;
        HotTrackStyles := [htHandPoint];
        ShowColumnHeaders:=false;
        Align := alClient;
   {     Margins.Top := 5;
        Margins.Bottom := 5;
        Margins.Left := 5;
        Margins.Right := 5;    }
        SmallImages := icons;

        ShowWorkAreas := false;       
        AlignWithMargins := true;
        OnSelectItem := lvSelectItem;
        Font.Name := 'Trebuchet MS';
        Font.Size := 8;
        Font.Style := Font.Style - [fsBold];
      end;
      j := 0;
      while it.MoveNext do begin
        t := TThrow.Create;
        t.name := ReplaceStr(it.GetCurrent, '_', ' ');
        t.expr := ini.ReadString(sname, it.GetCurrent, '0');
        ListItem := lv[i].Items.Add;
        lv[i].IconOptions.WrapText := true;
        ListItem.Caption := t.name + ' (' + t.expr + ')';
        ListItem.Data := t;
        //ListItem.SubItems.Add('Test');
        //ListItem.SubItems.Add('Test2');
        ListItem.ImageIndex := j;
//      ini.
      end;
      inc(i);
    end;
  finally
    ini.Free;
    keys.Free;
  end;
  Randomize;
  history := TStringList.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  history.Free;
end;

procedure TForm1.gridHistoryClick(Sender: TObject);
var x, y: integer;
    s: string;
    p: TPoint;
begin
  p := gridHistory.ParentToClient(ScreenToClient(Mouse.CursorPos));
  (Sender as TValueListEditor).MouseToCell(p.x, p.y, x, y);
  s := (Sender as TValueListEditor).Cells[0, y];
  eval(s);
end;

procedure TForm1.lvSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if selected then begin
    eval(TThrow(Item.Data).expr + ' (' + TThrow(Item.Data).name + ')');
    Item.Selected := false;
  end;
end;

end.
