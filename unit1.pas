unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Character;

type

  { TForm1 }
  // GUI
  TForm1 = class(TForm)
    acfunc: TButton;
    backspace: TButton;
    cfunc: TButton;
    sintax: TCheckBox;
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

    // Subprogramas
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
    procedure equalsfunc(Sender: TObject);
    procedure displayerror();
    procedure AssemblyGrau();
    procedure AssemblyRadiano();
    function IsNumberOnly(str: string): boolean;
    function calcular(numb1, numb2: double; operation: string): double;
    function precedencia(operador: string): byte;
    function solve(polish: array of string; parlow, parhigh: integer): string;
    function CheckString(str: string): boolean;
    function parse(): string;

  private

  public

  end;

var
  Form1: TForm1;
  // Onde os códigos são armazenados
  holder: string = '0';
  // O radial Deg está selecionado?
  degrees: integer = 1;
  // Memória
  memory: double = 0;
  // Flag de operação
  rootflag: boolean = False;
  // Constantes
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

Demais limitações:
O campo hint não é o local apropriado para armazenar os códigos dos botões.

O validador da sintaxe é bem permissivo e avalia apenas casos
simples. Há um botão para desativar a verificação, no caso de contratempos.
Não há tratamento de erros fora do validador da sintaxe.


Glossário:

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
z é Erro


holder: Onde os códigos digitados são armazenados
field: Caixa de texto que mostra os códigos digitados convertidos para o usuário (display)
2nd: Função inv
⌫  : Backspace
}

// Atualiza o campo de display da calculadora
procedure TForm1.UpdateField();
var
  txt: string;
  i: char;
begin
  txt := '';
  // Para cada caractere no holder, faça
  for i in holder do
  begin
    // Interpreta o código e mostra ao usuário de maneira legível
    case i of
      // Utiliza a função Concat para legibilidade do código
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
  // Atualizar display, de fato
  field.Text := txt;
  // TODO: Debug tirar depois
  view.Text := holder;
end;

// Desligar shift
procedure TForm1.ShiftOff();
begin
  // Remover itálico
  inv.Font.Style := [];
  sin.Font.Style := [];
  cos.Font.Style := [];
  tan.Font.Style := [];
  // Minúsculas, para tirar o arc
  sin.Hint := 'g(';
  cos.Hint := 'h(';
  tan.Hint := 'i(';
end;

// É chamada dentro da função equalsfunc, quando = (igual) é pressionado
function TForm1.CheckString(str: string): boolean;
var
  C: char;
  i: integer = 1;
  // Flag de decimal
  decimalflag: boolean = False;
  // Contagem de parênteses
  par: integer = 0;
begin
  // Se houver um erro no holder, saia
  if holder = 'z' then
    exit(False);

  // Se o primeiro caractere do holder for um operador fora de ordem, saia
  if holder[1] in ['+', '-', '*', '/', '^', 'f', 'd'] then
  begin
    displayerror();
    exit(False);
  end;

  // Para todo caractere de str, faça
  while i <= length(str) do
  begin
    case str[i] of
      // Caso for um ponto
      '.':
      begin
        // Se já houver um ponto na mesma sequência de números, saia
        if decimalflag = True then
        begin
          displayerror();
          exit(False);
        end;
        // Indicar que há um ponto nesta sequência de números
        decimalflag := True;
      end;

      // Operadores primários e operações
      // ln, log, √x, sin, cos, tan, arcsin, arccos, arctan
      '+', '-', '*', '/', 'a'..'c', 'e', 'g'..'j', 'G'..'I', '(':
      begin
        // Se o operador/operação não for sucedido por um número, saia
        if not (str[i + 1] in ['0'..'9', 'a'..'c', 'e', 'g'..'j',
          'G'..'I', '(', '~']) then
        begin
          displayerror();
          exit(False);
        end;
        decimalflag := False;
      end;

      '~':
      begin
        if i < length(str) then
        begin
          // Se o operador não for sucedido por um número ou abrir parêntese, saia
          if not (str[i + 1] in ['0'..'9', '(']) then
          begin
            displayerror();
            exit(False);
          end;
        end;
      end;
      // Números
      '0'..'9':
      begin
        // Desde que dentro dos limites da string, faça
        if i < length(str) then
        begin
          // Se o número não for sucedido por um outro número, operador ou fechar parêntese, saia
          if not (str[i + 1] in ['0'..'9', '+', '-', '*', '/', '^', 'f', ')', 'd']) then
          begin
            displayerror();
            exit(False);
          end;
        end;

      end;
      // y√x
      'd':
      begin
        // TODO: Testar fatorial
        // Se o y não for um número, fechar parêntese ou operador de fatorial, saia
        if not (str[i - 1] in ['0'..'9', ')', '!']) then
        begin
          displayerror();
          exit(False);
        end;

      end;

      // ! fatorial
      'f':
      begin
        // Desde que dentro dos limites da string, faça
        if i < length(str) then
        begin
          // Se o fatorial não for sucedido por um operador ou fecha parêntese, saia
          if not (str[i + 1] in ['+', '-', '*', '/', '^', ')']) then
          begin
            displayerror();
            exit(False);
          end;
        end;

      end;
    end;
    i += 1;
  end;

  // Se o número de abre parenteses subtraído de fecha parênteses for ≠ 0, saia
  if (par <> 0) or (decimalflag = True) then
  begin
    displayerror();
    exit(False);
  end;
  // Senão, verdadeiro
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
  // Caso o usuário tenha habilidado a verificação E a string for inválida, saia
  if ((sintax.Checked = True) and not (CheckString(holder))) then
  begin
    exit();
  end;
  // Senão, calcule
  holder := parse();
  UpdateField();
end;

// Botão 2nd na interface. Shift para as funções sin, cos e tan
procedure TForm1.invert(Sender: TObject);
begin
  // Se o botão 2nd não estiver em negrito
  if TButton(Sender).Font.Style = [] then
  begin
    // Deixar o botão 2nd em negrito
    TButton(Sender).Font.Style := [fsBold];
    // Definir operações como itálico
    sin.Font.Style := [fsItalic];
    cos.Font.Style := [fsItalic];
    tan.Font.Style := [fsItalic];
    // Alterar os códigos para as maíusculas (arc)
    sin.Hint := 'G(';
    cos.Hint := 'H(';
    tan.Hint := 'I(';
  end
  // Se o botão 2nd estiver em negrito
  else
  begin
    // Desative o shift
    ShiftOff();
  end;
end;

// Botão m+
// Soma à memória
procedure TForm1.memoryadd(Sender: TObject);
begin
  if IsNumberOnly(holder) then
    memory += StrToFloat(holder);
end;

// Botão mc
// Limpa a memória
procedure TForm1.memclrClick(Sender: TObject);
begin
  memory := 0;
end;

// Botão m-
// Subtrai à memória
procedure TForm1.memorysub(Sender: TObject);
begin
  if IsNumberOnly(holder) then
    memory -= StrToFloat(holder);
end;

// Botão mr
// Insere o número no holder
procedure TForm1.memoryrecall(Sender: TObject);
var
  aux: string;
begin
  // Se o número for negativo, retire o sinal, converta para string e
  // adicione ~ antes do número
  if memory < 0 then
  begin
    memory *= -1;
    aux := '~' + floattostr(memory);
  end
  // Se o número for positivo, apenas converta para string
  else
  begin
    aux := floattostr(memory);
  end;
  // Se o holder estiver "vazio" ou com erro, substitua
  if (holder = 'z') or (holder = '0') then
    holder := aux
  // Senão, acrescente
  else
    holder += aux;
  // Atualize o display
  UpdateField();
end;

// Botões circulares Deg e Rad
procedure TForm1.radioClick(Sender: TObject);
begin
  // Se o botão Deg estiver selecionado
  if deg.Checked then
    degrees := 1
  // Se o botão Rad estiver selecionado
  else
    degrees := 0;
end;

// Apaga
procedure TForm1.bckspc(Sender: TObject);
var
  str: string;
begin
  // Copiar o holder, para fins de legibilidade
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
  // Atualizar o holder
  holder := str;
  // Atualizar o display
  UpdateField();
end;

// Botão C - Clear
// Limpa o holder
procedure TForm1.resetC(Sender: TObject);
begin
  holder := '0';
  UpdateField();
end;

// Insere o texto do campo Hint do objeto no holder
procedure TForm1.typetxthint(Sender: TObject);
begin
  if (length(holder) = 255) then
    exit();
  if ((holder = '0') or (holder = 'z')) AND (TButton(Sender).Hint <> '.') then
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
  // Pilha de números
  pilha: array[1..256] of string;
  // Notação polonesa
  polish: array[1..256] of string;
  polindex: integer = 0;
  // Pilha de índices de parênteses
  parindex: array[1..256] of integer;
  parindextop: integer = 0;
  // Pilha de operadores
  operators: array[1..256] of string;
  operatorstop: integer = 0;
  // Variáveis auxiliares
  aux: double;
  aux2: double;
  i: integer = 1;
  str: string;
begin
  // Envolver o holder entre parênteses
  holder := '(' + holder + ')';
  // Enquanto i for menor que o tamanho do holder
  while i <= length(holder) do
  begin
    // Avaliar cada caractere
    case holder[i] of
      // Se o caractere for um número
      '0' .. '9':
      begin
        // Inclua todos caracteres subsequentes que contenham números ou pontos
        // num mesmo item da pilha polish
        polindex += 1;
        polish[polindex] := '';
        while (IsNumber(holder[i])) or (holder[i] = '.') do
        begin
          polish[polindex] += holder[i];
          i += 1;
        end;
        continue;
      end;

      // Se for o caractere for "e", incluir o número de euler na pilha polish
      'e':
      begin
        polindex += 1;
        polish[polindex] := FloatToStr(euler);
      end;
      // Se for o caractere for "j", incluir pi na pilha polish
      'j':
      begin
        polindex += 1;
        polish[polindex] := FloatToStr(pii);
      end;

      // Se for fatorial
      'f':
      begin
        // Execute a operação no último número da pilha polish
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
        // E substitua-o pelo resultado
        polish[polindex] := floattostr(aux2);
      end;

      // ln, log, √x, y√x, sin, cos, tan, arcsin, arccos, arctan
      'a', 'b', 'c', 'd', 'g', 'h', 'i', 'G', 'H', 'I':
      begin
        polindex += 1;
        parindextop += 1;
        // Inserir o item "x(" na pilha polish
        polish[polindex] := holder[i] + '(';
        parindex[parindextop] := polindex;
        // Pular o parêntese subsequente no holder
        i += 2;
        continue;
      end;

      // Se for a abertura de um parêntese
      '(':
      begin
        // Inserir na pilha polish, parindex e operators
        polindex += 1;
        parindextop += 1;
        operatorstop += 1;
        polish[polindex] := '(';
        parindex[parindextop] := polindex;
        operators[operatorstop] := '(';

      end;

      // Se for o fechamento de um parêntese
      ')':
      begin
        // Enquanto o elemento do topo da pilha não for um (
        while (operatorstop > 0) and (operators[operatorstop] <> '(') do
        begin
          // Remove os operadores da pilha de operadores
          polindex += 1;
          polish[polindex] := operators[operatorstop];
          operatorstop -= 1;
        end;
        // Remove o (
        operatorstop -= 1;
        // Calcula as operações e coloca no lugar do ( removido acima
        polish[parindex[parindextop]] :=
          solve(polish, parindex[parindextop], polindex);
        polindex := parindex[parindextop];
        // Caso tenha havido uma operação y√x
        if rootflag = True then
        begin
          // Colocar o resultado no lugar do y ao invés do ( removido acima
          polish[polindex - 1] := polish[polindex];
          polindex -= 1;
          rootflag := False;
        end;

        parindextop -= 1;

      end;
        // Qualquer outra coisa (operador)
      else
      begin
        // Se não houver operadores, não comparar precedência, apenas inserir
        if operatorstop = 0 then
        begin
          operatorstop := 1;
          operators[operatorstop] := holder[i];
        end
        // Se houver algum operador
        else
        begin
          // Se a precência do operador a ser inserido for menor ou igual
          // a precedência do operador no topo da pilha
          if precedencia(holder[i]) <= precedencia(operators[operatorstop]) then
          begin
            // Colocar o operador do topo da pilha na pilha polish e
            // mover o operador a ser inserido para o topo da pilha
            // de operadores
            polindex += 1;
            polish[polindex] := operators[operatorstop];
            operators[operatorstop] := holder[i];
          end
          // Senão
          else
          begin
            // Insira o operador no topo da pilha de operadores
            operatorstop += 1;
            operators[operatorstop] := holder[i];
          end;

        end;

      end;

    end;
    i += 1;
  end;
  // Retornar resultado
  exit(polish[1]);

end;

// Conversão de Grau para Radiano
procedure TForm1.AssemblyGrau();
var
  centoeoitenta: double = 180;
begin

   {$ASMMODE intel}
  asm
           FLDPI
           FMULP   ST(1), ST(0)
           FLD     centoeoitenta
           FDIVP   ST(1), ST(0)
  end;

end;

// Conversão de Radiano para Grau
procedure TForm1.AssemblyRadiano();
var
  centoeoitenta: double = 180;
begin

   {$ASMMODE intel}
  asm
           FLD     centoeoitenta
           FMULP   ST(1), ST(0)
           FLDPI
           FDIVP   ST(1), ST(0)
  end;

end;

// Resolver notação polonesa
function TForm1.solve(polish: array of string; parlow, parhigh: integer): string;
var
  // Pilha de operandos em formato double
  // A pilha polish é um array de strings
  pilha: array[1..256] of double;
  pilhatop: integer = 0;

  // Variáveis auxiliares
  aux: double;
  i: integer;
  radianss: integer; // Para não dar erro na compilação
  resultado: double;
begin
  i := parlow;
  radianss := degrees;

  while i < parhigh do
  begin
    case polish[i] of
      // Se for negação
      '~':
      begin
        // Inverta o sinal do número no topo da pilha
        pilha[pilhatop] := pilha[pilhatop] * -1;
      end;
      // Se for um operador primário
      '^', '*', '/', '+', '-':
      begin
        // Calcule e armazene na pilha
        pilha[pilhatop - 1] :=
          calcular(pilha[pilhatop - 1], pilha[pilhatop], polish[i]);
        pilhatop -= 1;
      end;
      // Se for uma operação ou parêntese, ignore
      '(', 'a(', 'b(', 'c(', 'd(', 'g(', 'h(', 'i(', 'j(', 'G(', 'H(', 'I(':
      begin
        i += 1;
        continue;
      end

      else
        // Se for qualquer outra coisa (número)
      begin
        // Converta para float e armazene na pilha
        pilhatop += 1;
        pilha[pilhatop] := strtofloat(polish[i]);
      end;

    end;
    i += 1;
  end;

  // Resultado provisório, pode mudar no case abaixo
  resultado := pilha[1];

  // Se houver alguma operação junto ao parêntese inicial, faça-a
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
      rootflag := True;
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
               FSTP  resultado
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

  // Retornar resultado definitivo
  exit(floattostr(resultado));
end;

// Armazena a precedência dos operadores
function TForm1.precedencia(operador: string): byte;
begin

  {
   6. ~
   5. ^
   4. *, /
   3. +, -
   2. (
   }

  case operador of
    '~': exit(6);
    '^': exit(5);
    '*', '/': exit(4);
    '+', '-': exit(3);
    '(': exit(2);
  end;
end;

// Calcula várias operações em assembly, reduzindo o tamanho da outra função
// Diferente do case com as operações, esta parte pode ser modularizada com maior facilidade
// Já que depende de poucos parâmetros
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
