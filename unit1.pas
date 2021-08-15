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
    procedure memoryrecall(Sender: TObject);
    procedure memclrClick(Sender: TObject);
    procedure memoryadd(Sender: TObject);
    procedure memorysub(Sender: TObject);
    procedure radioClick(Sender: TObject);
    procedure typetxthint(Sender: TObject);
    procedure typetxthintshift(Sender: TObject);
    procedure resetC(Sender: TObject);
    procedure resetmemoryAC(Sender: TObject);
    procedure resetmemory(Sender: TObject);
    procedure UpdateField();
    procedure ShiftOff();
    function CheckString(str: string): boolean;
    procedure equalsfunc(Sender: TObject);
    procedure displayerror();
    function IsNumberOnly(str: string): boolean;
    function calcular(numb1, numb2: double; operation: string): double;
    function precedencia(operador: string): byte;
    function solve(polish: array of string; parlow, parhigh: integer): string;
    procedure AssemblyGrau();
    procedure AssemblyRadiano();
    function parse(): string;

  private

  public

  end;

var
  Form1: TForm1;
  holder: string = '0';
  degrees: shortint = 1;
  memory: double = 0;
  par: integer = 0;
  numberflag: boolean = True;
  decimalflag: boolean = False;
  operatorflag: boolean = False;
  parflag: boolean = False;
  endopflag: boolean = False;
  reqnumberflag: boolean = False;
  euler: double = 2.7182818284590452353602874713527;
  pii: double = 3.1415926535897932384626433832795;

implementation

{$R *.lfm}

{ TForm1 }

{Cada função da calculadora possui um código de 1 caractere para que o programa interprete-o
de maneira mais simplificada e para permitir que funções como "arcsin(" possam ser apagadas de
com apenas 1 backspace.
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

{ É chamada quando = (igual) é pressionado
  O validador da sintaxe é bem permissivo e
  avalia apenas casos simples}
function TForm1.CheckString(str: string): boolean;
var
  C: char;
  i: integer;
begin
  if holder = 'z' then
    exit(False);

  if holder[1] in ['+', '-', '*', '/', 'f', 'd'] then
  begin
    displayerror();
    exit(False);
  end;
  for C in str do
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

      '+', '-', '*', '/', '^':
      begin
        if operatorflag = True then
        begin
          displayerror();
          exit;
        end;
        operatorflag := True;
        decimalflag := False;
      end;

      'd':
      begin
        if numberflag = False then
        begin
          displayerror();
          exit;
        end;
        operatorflag := True;
      end;

      // Cada abertura de parenteses soma 1
      '(':
      begin

        if numberflag = True then
        begin
          displayerror();
          exit;
        end;
        par += 1;
      end;
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
        operatorflag := False;
      begin
        if IsNumber(C) = True then
        begin
          numberflag := True;
        end;
      end;

    end;
  end;
  // Se parenteses for ≠ 0,
  if (par <> 0) or (decimalflag = True) or (operatorflag = True) then
  begin
    displayerror();
    exit(False);
  end;
  exit(True);
end;

// Mostrar erro na tela
procedure TForm1.displayerror();
begin
  holder := 'z';
  UpdateField();
end;

// Apagar memória
procedure TForm1.resetmemory(Sender: TObject);
begin
  memory := 0;
end;

// Apagar memória e display
procedure TForm1.resetmemoryAC(Sender: TObject);
begin
  resetC(Sender);
  resetmemory(Sender);
end;

// Chamo quando aperto =
procedure TForm1.equalsfunc(Sender: TObject);
begin
  if CheckString(holder) then
  begin
    holder := parse();
    UpdateField();
  end;
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

// Botão m+
procedure TForm1.memoryadd(Sender: TObject);
begin
  if IsNumberOnly(holder) then
    memory += StrToFloat(holder);
end;

// Botão mc
procedure TForm1.memclrClick(Sender: TObject);
begin
  memory := 0;
end;

// Botão m-
procedure TForm1.memorysub(Sender: TObject);
begin
  if IsNumberOnly(holder) then
    memory -= StrToFloat(holder);
end;

// Botão mr
procedure TForm1.memoryrecall(Sender: TObject);
begin
  if memory < 0 then
  begin
    memory *= -1;
    if (holder = 'z') or (holder = '0') then
      holder := '~' + floattostr(memory)
    else
      holder += '~' + floattostr(memory);

  end
  else

  if (holder = 'z') or (holder = '0') then
    holder := floattostr(memory)
  else
    holder += floattostr(memory);


  UpdateField();
end;

// Botões circulares Deg e Rad
procedure TForm1.radioClick(Sender: TObject);
begin
  if deg.Checked then
    degrees := 1
  else
    degrees := 0;
end;

// Apaga
procedure TForm1.bckspc(Sender: TObject);
var
  str: string;
begin
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
      (str[LENGTH(str)] in ['f', 'j']) then
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
  par := 0;
  numberflag := True;
  decimalflag := False;
  operatorflag := False;
  holder := '0';
  UpdateField();
end;

// Insere o texto do campo Hint do objeto no holder
procedure TForm1.typetxthint(Sender: TObject);
begin
  if (length(holder) = 255) then
    exit();
  if (holder = '0') or (holder = 'z') then
  begin
    case TButton(Sender).Hint of
      '+', '-', '*', '/', 'f', 'd(': holder := Concat('0', TButton(Sender).Hint);
      else
        holder := TButton(Sender).Hint;
    end;
  end
  else
    holder := Concat(holder, TButton(Sender).Hint);
  UpdateField();
end;

// Insere o texto do campo Hint do objeto no holder e desativa o shift
procedure TForm1.typetxthintshift(Sender: TObject);
begin
  if (length(holder) = 255) then
    exit();
  if (holder = '0') or (holder = 'z') then
    holder := TButton(Sender).Hint
  else
    holder := Concat(holder, TButton(Sender).Hint);
  ShiftOff();
  UpdateField();

end;

// A string contém apenas números e .?
function TForm1.IsNumberOnly(str: string): boolean;
var
  C: char;
begin
  for C in str do
  begin
    if not (IsNumber(C)) and (C <> '.') then
      exit(False);

  end;
  exit(True);
end;



// Converter para notação polonesa
function TForm1.parse(): string;
var
  pilha: array[1..256] of string;
  str: string;
  polish: array[1..256] of string;
  polindex: integer = 0;
  i: integer = 1;
  parindex: array[1..256] of integer;
  parindextop: integer = 0;
  operators: array[1..256] of string;
  operatorstop: integer = 0;
  aux: double;
  aux2: double;
begin

  holder := '(' + holder + ')';

  while i <= length(holder) do
  begin
    case holder[i] of
      '0' .. '9', '.':
      begin
        polindex += 1;
        polish[polindex] := '';
        while (IsNumber(holder[i])) and (holder[i] <> '.') do
        begin
          polish[polindex] += holder[i];
          i += 1;
        end;
        continue;
      end;

      'e':
      begin
        polindex += 1;
        polish[polindex] := FloatToStr(euler);
      end;

      'j':
      begin
        polindex += 1;
        polish[polindex] := FloatToStr(pii);
      end;

      'f':
      begin
        aux := strtofloat(polish[polindex]);
         {$ASMMODE intel}
        asm
                 // TODO: Arrumar código
                 FINIT
                 FLD1
                 FLDZ
                 MOV   ECX, aux

                 @loop:
                 FLD1
                 FADDP ST(1), ST(0)
                 FMUL  ST(1), ST(0)

                 DEC   ECX
                 JNZ   @loop

                 FSTP  aux
                 FSTP  aux2
        end;
        polish[polindex] := floattostr(aux2);
      end;

      // ln, log, √x, y√x, sin, cos, tan, arcsin, arccos, arctan
      'a', 'b', 'c', 'd', 'g', 'h', 'i', 'G', 'H', 'I':
      begin
        polindex += 1;
        parindextop += 1;
        polish[polindex] := holder[i] + '(';
        parindex[parindextop] := polindex;
        i += 2;
        continue;
      end;


      '(':
      begin
        polindex += 1;
        parindextop += 1;
        operatorstop += 1;
        polish[polindex] := '(';
        parindex[parindextop] := polindex;
        operators[operatorstop] := '(';

      end;

      ')':
      begin
        while (operatorstop > 0) and (operators[operatorstop] <> '(') do
        begin
          polindex += 1;
          polish[polindex] := operators[operatorstop];
          operatorstop -= 1;
        end;
        operatorstop -= 1;
        polish[parindex[parindextop]] :=
          solve(polish, parindex[parindextop], polindex);
        polindex := parindex[parindextop];
        parindextop -= 1;

      end;
      else
      begin

        if operatorstop = 0 then
        begin
          operatorstop := 1;
          operators[operatorstop] := holder[i];
        end
        else
        begin

          if precedencia(holder[i]) <= precedencia(operators[operatorstop]) then
          begin
            polindex += 1;
            polish[polindex] := operators[operatorstop];
            operators[operatorstop] := holder[i];
          end
          else
          begin
            operatorstop += 1;
            operators[operatorstop] := holder[i];
          end;

        end;

      end;

    end;
    i += 1;
  end;
  exit(polish[1]);

end;

// Conversão de Grau para Radiano
procedure TForm1.AssemblyGrau();
var
  cento: double = 180;
begin

   {$ASMMODE intel}
  asm
           FLDPI
           FMULP   ST(1), ST(0)
           FLD     cento
           FDIVP   ST(1), ST(0)
  end;

end;

// Conversão de Radiano para Grau
procedure TForm1.AssemblyRadiano();
var
  cento: double = 180;
begin

   {$ASMMODE intel}
  asm
           FLD     cento
           FMULP   ST(1), ST(0)
           FLDPI
           FDIVP   ST(1), ST(0)
  end;

end;

// Resolver notação polonesa
function TForm1.solve(polish: array of string; parlow, parhigh: integer): string;
var
  i: integer;
  pilha: array[1..256] of double;
  pilhatop: integer = 0;
  resultado: double;
  radianss: shortint;
  aux: double;
begin
  i := parlow;
  radianss := degrees;
  while i < parhigh do
  begin
    case polish[i] of
      '~':
      begin
        pilha[pilhatop] := pilha[pilhatop] * -1;
      end;

      '^', '*', '/', '+', '-':
      begin
        pilha[pilhatop - 1] :=
          calcular(pilha[pilhatop - 1], pilha[pilhatop], polish[i]);
        pilhatop -= 1;
      end;

      '(', 'a(', 'b(', 'c(', 'd(', 'g(', 'h(', 'i(', 'j(', 'G(', 'H(', 'I(':
      begin
        i += 1;
        continue;
      end

      else
      begin
        pilhatop += 1;
        pilha[pilhatop] := strtofloat(polish[i]);
      end;

    end;
    i += 1;
  end;

  resultado := pilha[1];

  case polish[parlow - 1] of
    // 'a', 'b', 'c', 'g', 'h', 'i', 'j', 'H', 'I', 'J':
    // ln, log, √x, y√x, sin, cos, tan, arcsin, arccos, arctan


    // ln
    'a(':
    begin
      aux := euler;
       {$ASMMODE intel}
      asm
               FINIT
               FLD1
               FLD   aux
               FYL2X
               FLD1
               FDIV  ST, ST(1)
               FLD   resultado
               FYL2X
               FSTP  resultado
      end;
    end;


    // log
    'b(':

    begin
      aux := 10;
       {$ASMMODE intel}
      asm
               FINIT
               FLD1
               FLD   aux
               FYL2X
               FLD1
               FDIV  ST, ST(1)
               FLD   resultado
               FYL2X
               FSTP  resultado
      end;
    end;


    // √x
    'c(':
    begin
 {$ASMMODE intel}
      asm
               FLD   resultado
               FSQRT
               FSTP  resultado
      end;
    end;


    // y√x
    'd(':
    begin
      aux := strtofloat(polish[parlow - 2]);
           {$ASMMODE intel}
      asm
               FINIT
               FLD1
               FLD   aux
               FDIV
               FSTP  aux
               FINIT  // Segunda inicialização para evitar lixo de memória
               FLD   aux
               FLD1
               FLD   resultado
               FYL2X
               FMUL
               FLD   ST
               FRNDINT
               FSUB  ST(1), ST
               FXCH
               F2XM1
               FLD1
               FADD
               FSCALE
               FSTP  resultado // Resultado armazenado no topo da pilha
      end;
    end;


    // sin
    'g(':
    begin
      {$ASMMODE intel}
      asm
               FINIT
               FLD   resultado
               MOV   EAX, radianss
               SUB   EAX, 1
               JZ    @GRAU
               JMP   @RADIANO

               @GRAU:
               CALL  AssemblyGrau
               JMP   @RADIANO

               @RADIANO:
               FSIN
               FSTP  resultado
      end;
    end;


    // cos
    'h(':
    begin
      {$ASMMODE intel}
      asm
               FINIT
               FLD   resultado
               MOV   EAX, radianss
               SUB   EAX, 1
               JZ    @GRAU
               JMP   @RADIANO

               @GRAU:
               CALL  AssemblyGrau
               JMP   @RADIANO

               @RADIANO:
               FCOS
               FSTP  resultado
      end;
    end;


    // tan
    'i(':
    begin
      {$ASMMODE intel}
      asm
               FINIT
               FLD   resultado
               MOV   EAX, radianss
               SUB   EAX, 1
               JZ    @GRAU
               JMP   @RADIANO

               @GRAU:
               CALL  AssemblyGrau
               JMP   @RADIANO

               @RADIANO:
               FSINCOS
               FDIVP ST(1), ST(0)
               FSTP  resultado
      end;
    end;


    // arcsin
    'G(':
    begin
         {$ASMMODE intel}
      asm
               FINIT
               FLD   resultado
               FLD   resultado
               FMULP ST(1), ST(0)
               FLD1
               FLD   ST(1)
               FSUBP ST(1), ST(0)
               FDIVP ST(1), ST(0)

               FSQRT
               FLD1
               FPATAN

               MOV   EAX, radianss
               SUB   EAX, 1
               JZ    @GRAU
               JMP   @RADIANO

               @GRAU:
               CALL  AssemblyRadiano
               JMP   @RADIANO

               @RADIANO:
               FST   resultado
      end;

    end;


    //arccos
    'H(':
    begin
          {$ASMMODE intel}
      asm
               // aaa
      end;

    end;


    //arctan
    'I(':
    begin
          {$ASMMODE intel}
      asm

               FINIT
               FLD   resultado
               FLD1
               FPATAN
               MOV   EAX, radianss
               SUB   EAX, 1
               JZ    @GRAU
               JMP   @RADIANO

               @GRAU:
               CALL  AssemblyRadiano
               JMP   @RADIANO

               @RADIANO:
               FST   resultado
      end;
    end;
  end;


  exit(floattostr(resultado));
end;

// Armazena a precedência dos operadores
function TForm1.precedencia(operador: string): byte;
begin

  case operador of
    '~': exit(6);
    '^': exit(5);
    '*', '/': exit(4);
    '+', '-': exit(3);
    '(': exit(2);
  end;
end;

// Calcula várias operações em assembly
function TForm1.calcular(numb1, numb2: double; operation: string): double;
begin
  case operation of
    '+':
    begin
  {$ASMMODE intel}
      asm
               FINIT
               FLD   numb1
               FLD   numb2
               FADDP ST(1),ST(0)
               FSTP  result
      end;
    end;

    '-':
    begin
    {$ASMMODE intel}
      asm
               FINIT
               FLD   numb1
               FLD   numb2
               FSUBP ST(1), ST(0)
               FSTP  result
      end;
    end;

    '*':
    begin
  {$ASMMODE intel}
      asm
               FINIT
               FLD   numb1
               FLD   numb2
               FMULP ST(1), ST(0)
               FSTP  result
      end;
    end;

    '/':
    begin
  {$ASMMODE intel}
      asm
               FINIT
               FLD   numb1
               FLD   numb2
               FDIVP ST(1), ST(0)
               FSTP  result
      end;
    end;

    '^':
    begin
  {$ASMMODE intel}
      asm
               FINIT
               FLD   numb2
               FLD1
               FLD   numb1
               FYL2X
               FMUL  numb2
               FLD   ST
               FRNDINT
               FSUB  ST(1), ST
               FXCH
               F2XM1
               FLD1
               FADD
               FSCALE
               FSTP  result
      end;
    end;
  end;
end;

end.
