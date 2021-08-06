unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Character;

type

  { TForm1 }

  TForm1 = class(TForm)
    acfunc: TButton;
    backspace: TButton;
    cfunc: TButton;
    cos: TButton;
    decop: TButton;
    deg: TRadioButton;
    divop: TButton;
    view: TEdit;
    equop: TButton;
    fact: TButton;
    field: TEdit;
    frac: TButton;
    inv: TButton;
    ln: TButton;
    log: TButton;
    memadd: TButton;
    memclr: TButton;
    memrec: TButton;
    memsub: TButton;
    mulop: TButton;
    negfunc: TButton;
    num0: TButton;
    num1: TButton;
    num2: TButton;
    num3: TButton;
    num4: TButton;
    num5: TButton;
    num6: TButton;
    num7: TButton;
    num8: TButton;
    num9: TButton;
    parleft: TButton;
    parright: TButton;
    pi: TButton;
    pow2: TButton;
    powe: TButton;
    powy: TButton;
    rad: TRadioButton;
    RadioGroup1: TRadioGroup;
    root2: TButton;
    rooty: TButton;
    sin: TButton;
    subop: TButton;
    sumop: TButton;
    tan: TButton;
    procedure bckspc(Sender: TObject);
    procedure invert(Sender: TObject);
    procedure memadd(Sender: TObject);
    procedure memclrClick(Sender: TObject);
    procedure memsub(Sender: TObject);
    procedure radioClick(Sender: TObject);
    procedure typetxt(Sender: TObject);
    procedure typetxthint(Sender: TObject);
    procedure typetxthintshift(Sender: TObject);
    procedure resetC(Sender: TObject);
    procedure resetmemoryAC(Sender: TObject);
    procedure resetmemory(Sender: TObject);
    procedure UpdateField();
    procedure ShiftOff();
    procedure CheckString();
    procedure equalsfunc(Sender: TObject);
    procedure displayerror();

  private

  public

  end;

var
  Form1: TForm1;
  holder: string = '0';
  degrees: boolean = True;
  memory: extended = 0;
  answer: extended;
  answerbool: boolean = False;

implementation

{$R *.lfm}

{ TForm1 }

{Cada função da calculadora possui um código de 1 caractere para que o programa interprete-o
de maneira mais simplificada e para permitir que funções como "arcsin(" possam ser apagadas de
com apenas 1 backspace, com um código simplificado.
A desvantagem desta abordagem é que é necessário traduzir os códigos para inserí-los no display
da calculadora.
Apesar de simples e razoavelmente legível, o código do display implementado é ineficiente, já que,
toda vez que o usuário introduz um valor, todo o texto display precisa ser reconstruído do início.

a é ln
b é log
c é √x
d é y√x
f é ! (fatorial)
g é sin
G é arcsin
h é cos
H é arccos
i é tan
I é arctan
j é pi
z é Erro}

// Atualiza o campo de display da calculadora
procedure TForm1.UpdateField();
var
  txt: string;
  i: char;
begin
  txt := '';
  for i in holder do
  begin
    case i of
      // Interpreta o código e mostra ao usuário de maneira legível
      'a': txt := Concat(txt, 'ln');
      'b': txt := Concat(txt, 'log');
      'c', 'd': txt := Concat(txt, '√');
      'f': txt := Concat(txt, '!');
      'g': txt := Concat(txt, 'sin');
      'G': txt := Concat(txt, 'arcsin');
      'h': txt := Concat(txt, 'cos');
      'H': txt := Concat(txt, 'arccos');
      'i': txt := Concat(txt, 'tan');
      'I': txt := Concat(txt, 'arctan');
      'j': txt := Concat(txt, 'π');
      'z': txt := 'Erro';
      else
        txt := Concat(txt, i);
    end;
  end;
  field.Text := txt;
  // Debug tirar depois
  view.Text := holder;
end;

// Desligar shift
procedure TForm1.ShiftOff();
begin
  inv.Font.Style := [];
  sin.Font.Style := [];
  cos.Font.Style := [];
  tan.Font.Style := [];
  sin.Hint := 'g(';
  cos.Hint := 'h(';
  tan.Hint := 'i(';
end;

// Eu chamo quando aperto =
procedure TForm1.CheckString();
var
  // Parenteses
  par: integer = 0;
  C: char;
  // Trocar essa verificação na hora da digitação
  numberflag: boolean = False;
  decimalflag: boolean = False;
  operatorflag: boolean = False;
begin
  // Se o visor tiver Erro, eu saio
  if holder = 'z' then
    exit;

  for C in holder do
  begin

    case C of
      '.':
      begin
        if decimalflag = True then
        begin
          displayerror();
          exit;
        end;
        decimalflag := True;
        continue;
      end;

      // Cada abertura de parenteses soma 1
      '(': par += 1;
      // Cada fechamento de parenteses subtrai 1
      ')':
      begin
        par -= 1;
        if par < 0 then
        begin
          displayerror();
          exit;
        end;
      end;
      else
      begin
        if IsNumber(C) = True then
        begin
          if decimalflag = True then
            decimalflag := False;
        end;
      end;
    end;
  end;

  // Se parenteses for ≠ 0,
  if (par <> 0) or (decimalflag = True) or (operatorflag = True) then
  begin
    displayerror();
  end;
end;

procedure TForm1.displayerror();
begin
  holder := 'z';
  UpdateField();
end;

procedure TForm1.resetmemory(Sender: TObject);
begin
  // TODO
end;

procedure TForm1.resetmemoryAC(Sender: TObject);
begin
  resetC(Sender);
  resetmemory(Sender);
end;

// Chamo quando aperto =
procedure TForm1.equalsfunc(Sender: TObject);
begin
  CheckString();
  //answerbool := True;
end;

// Botão 2nd na interface. Shift para as funções sin, cos e tan
procedure TForm1.invert(Sender: TObject);
begin
  if TButton(Sender).Font.Style = [] then
  begin
    TButton(Sender).Font.Style := [fsBold];
    sin.Font.Style := [fsItalic];
    cos.Font.Style := [fsItalic];
    tan.Font.Style := [fsItalic];
    sin.Hint := 'G(';
    cos.Hint := 'H(';
    tan.Hint := 'I(';
  end
  else
  begin
    ShiftOff();
  end;
end;

procedure TForm1.memadd(Sender: TObject);
begin
   memory += holder;
end;

procedure TForm1.memclrClick(Sender: TObject);
begin
  // TODO
end;

procedure TForm1.memsub(Sender: TObject);
begin
    memory -= holder;
end;

procedure TForm1.radioClick(Sender: TObject);
begin
  if deg.Checked then
    degrees := True
  else
    degrees := False;
end;

// Apaga
procedure TForm1.bckspc(Sender: TObject);
var
  str: string;
begin
  answerbool := false;
  str := holder;
  // Caso tenha tamanho 1, define o display para 0
  if LENGTH(str) = 1 then
    str := '0'
  else
    // Senão
  begin
    // Apaga 1 caractere
    SetLength(str, LENGTH(str) - 1);
    // Se o último caractere for uma letra, com base na tabela ASCII E não for J (pi)
    if (Ord(str[LENGTH(str)]) < 40) or (Ord(str[LENGTH(str)]) > 57) and not
      (str[LENGTH(str)] = 'j') then
    begin
      // Caso o holder tenha tamanho 1, define o display para 0
      if LENGTH(str) = 1 then
        str := '0'
      else
      // Senão
      // Caso o último char seja ^ e o antecessor seja e (e^)
      if ((str[LENGTH(str)]) = '^') and ((str[LENGTH(str) - 1]) = 'e') then
      begin
        // Se o tamanho da string for 2, mudar o display para 0
        if LENGTH(str) = 2 then
          str := '0'
        else
          // Senão, apaga 2 caracteres
          SetLength(str, LENGTH(str) - 2);
      end
      else
        // Senão apaga 1 caractere
        SetLength(str, LENGTH(str) - 1);
    end;
  end;
  holder := str;
  UpdateField();
end;

// Botão C
procedure TForm1.resetC(Sender: TObject);
begin
  answerbool := false;
  holder := '0';
  UpdateField();
end;

// Insere o texto do campo Caption do objeto no holder
procedure TForm1.typetxt(Sender: TObject);
begin
  answerbool := false;
  if (holder = '0') or (holder = 'z') then
    holder := TButton(Sender).Caption
  else
    holder := Concat(holder, TButton(Sender).Caption);
  UpdateField();
end;

// Insere o texto do campo Hint do objeto no holder
procedure TForm1.typetxthint(Sender: TObject);
begin
  answerbool := false;
  if (holder = '0') or (holder = 'z') then
    if (TButton(Sender).Caption = ',') then
      holder := Concat('0', TButton(Sender).Hint)
    else
      holder := TButton(Sender).Hint
  else
    holder := Concat(holder, TButton(Sender).Hint);
  UpdateField();
end;

// Insere o texto do campo Hint do objeto no holder e desativa o shift
procedure TForm1.typetxthintshift(Sender: TObject);
begin
  answerbool := false;
  if (holder = '0') or (holder = 'z') then
    holder := TButton(Sender).Hint
  else
    holder := Concat(holder, TButton(Sender).Hint);
  ShiftOff();
  UpdateField();

end;


end.
