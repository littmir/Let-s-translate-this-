program LexTranslator;
{
	Let's start translate!
}

uses sysutils; 

var
	inputName, outputName: string; // имена входного и выходного файлов
	input, output: text; // входной и выходный файлы
	tempChar: Char; // буферный симовл
	tempString: string; //буферная строка
	StringNumber: Integer; // номер строки
	divider: string; // разделитель
	commentOutput: boolean;
	overflowOutput: boolean;


// Чтение из входного файла /.///////////////////////////////////////////////////+
// return false, если конец файла, tempChar = считанный символ
// понижает регистр
function readChar(): Boolean;
begin
	if tempChar = chr(13) then begin inc(StringNumber);
	writeln('String num: ', StringNumber); end;
	// Если конец файла
	if eof(input) then
		begin
			readChar := false;
			writeln('End of file');
			exit;		
		end;
	read(input, tempChar);
	writeln('Readed: ',tempChar); 
	// Понижение регистра
	tempChar := ansilowercase(tempChar)[1];
	readChar := true;
end;
// Конец чтения из входного файла //////////////////////////////////////////////+


// Считыаание пока есть схожие символы /////////////////////////////////////////+
// Начинает работу с проверки символа tempChar /////////////////////////////////+
function readWhileIn(str: string): string;
begin
	writeln('readWhileIn works...');
	readWhileIn := '';
	while true do
		begin
			// Если символов нет/не осталось
			// выход из цикла 
			if pos(tempChar, str) = 0 then break;
			readWhileIn := readWhileIn + tempChar;
			// если продолжаются символы, продолжаем считывать
			if not readChar() then break;
		end;
end;
// Конец считыаания пока есть схожие символы ///////////////////////////////////+


// Чтение до разделителя ///////////////////////////////////////////////////////+
// return считанную строку до разделителя //////////////////////////////////////+
function readTo(str: string): string;
begin
	writeln('readTo works...');
	readTo := '';
	while true do
		begin
			// Tсли достигли разделителя - возврат
	 		if pos(tempChar, str) <> 0 then break;
	 		// Иначе считывание продолжается
	 		readTo := readTo + tempChar;
	 		if not readChar() then break;
	 	end; 
end;
// Конец чтения до разделителя /////////////////////////////////////////////////+



// Вывод распознанной лексемы числа в файл /////////////..///////////////////////+
procedure numberOutput(lexName: string; value: string; numberValue: string);
begin
	write(output, StringNumber, chr(9), 'lex:', lexName);
	lexName[1] := ansilowercase(lexName[1])[1];
	writeln(output, chr(9), lexName, ':', numberValue, chr(9), 'val:', value);
end;
// Конец вывода распознанной лексемы числа в файл ///////////////////////////////+

// Вывод ошибочной лексемы //////////////////////////////////////////////////////+
procedure ErrorLex(value: string; message: string);
begin
	writeln('Error:', StringNumber, ':', message);
	// Дочитвание строки, до возврата каретки
	readTo(chr(13));
end;
// Конец вывода ошибочной лексемы ///////////////////////////////////////////////+

procedure idFound();
var
	lexName: string;
	lexValue: string;
begin
	writeln('You are in a ID proc!');
	lexValue := readWhileIn('_qwertyuiopasdfghjklzxcvbnm0123456789');
		begin
			if (pos(tempChar, ' '+chr(9)+chr(13)) = 0) and (eof(input) = false) then
			begin
				lexValue := lexValue + readTo(chr(9) + ' ' +chr(13));
				writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', lexValue);
				exit;
			end;
			// Чтение строки до разделителя
			if (eof(input) = false) then
			lexValue := lexValue + readTo(divider);
			writeln('lex value: ', lexValue);
			if ((lexValue = 'rem') and (pos(tempChar, chr(9) + ' ' + chr(13)) <> 0))  then
			begin
				writeln('You are in a COM handler!');
				lexValue := lexValue + readTo(chr(13));
				if (commentOutput = true) then writeln(output, StringNumber, chr(9), 'lex:Comment', chr(9), 'val:', lexValue);
				exit;				
			end;
		end;
	lexName := 'Id';

	// Арифметика 
	if lexValue = 'mul' then lexName := 'Mul';
	if lexValue = 'div' then lexName := 'Div';
	if lexValue = 'mod' then lexName := 'Mod';
	if lexValue = 'add' then lexName := 'Add';
	if lexValue = 'sub' then lexName := 'Min';
	if lexValue = 'equ' then lexName := 'EQ';
	if lexValue = 'neq' then lexName := 'NE';
	if lexValue = 'lth' then lexName := 'LT';
	if lexValue = 'gth' then lexName := 'GT';
	if lexValue = 'leq' then lexName := 'LE';
	if lexValue = 'geq' then lexName := 'GE';

	if lexValue = 'mov' then lexName := 'Let';
	if lexValue = 'var' then lexName := 'Var';
	if lexValue = 'cast' then lexName := 'Cast';
	if lexValue = 'tools' then lexName := 'Tools';
	if lexValue = 'box' then lexName := 'Box';
	if lexValue = 'end' then lexName := 'End';
	if lexValue = 'vector' then lexName := 'Vector';
	if lexValue = 'of' then lexName := 'Of';
	if lexValue = 'int' then lexName := 'TypeInt';
	if lexValue = 'real' then lexName := 'TypeReal';
	if lexValue = 'break' then lexName := 'Break';
	if lexValue = 'goto' then lexName := 'Goto';
	if lexValue = 'read' then lexName := 'Read';
	if lexValue = 'write' then lexName := 'Write';
	if lexValue = 'skip' then lexName := 'Skip';
	if lexValue = 'space' then lexName := 'Space';
	if lexValue = 'tab' then lexName := 'Tab';
	if lexValue = 'if' then lexName := 'If';
	if lexValue = 'then' then lexName := 'Then';
	if lexValue = 'else' then lexName := 'Else';
	if lexValue = 'while' then lexName := 'While';
	if lexValue = 'do' then lexName := 'Do';
	if lexValue = 'proc' then lexName := 'Proc';
	if lexValue = 'call' then lexName := 'Call';

	writeln(output, StringNumber, chr(9),  'lex:', lexName, chr(9), 'val:', lexValue);
end;


{+}function toDec(str: string; size: integer): integer;
var 
	i: integer;
	x: QWord; // unsignt int64
begin
	toDec := 0;
	x := 0;
	for i := 1 to length(str) do
	begin
		x := x * size;
		x := x + pos(str[i], '0123456789abcdef') - 1;
		// Если переполнение int
		if x > 2147483647 then
		begin
	 		toDec := -1;
			exit;
		end; 
	end;
	toDec := x;
end;

procedure isItBinary(number: string);
var
	i: integer;
	sizeOfInt: integer;
	size: string;
begin
	writeln('You are in a binary proc!');
	for i := 1 to length(number) do
		begin
			// Если в двоичном числе встретились неверные числа
			if pos(number[i],'01') = 0 then 
			begin
				writeln('uncorrect binary');
				exit;
			end;
		end;
	sizeOfInt := toDec(number, 2);
	number := number + 'b';
    if sizeOfInt < 0 then
    begin
        // Переполнение Int
        writeln('Error:',StringNumber,':int Overflow');
        //errorLex(number, 'IntOverFlow - *' + number + '*');
        exit;
    end;
    str(sizeOfInt, size);
    numberOutput('Int', number, size);				 	
end;

procedure isItHex(number: string);
var
	sizeOfInt: integer;
	size: string;
begin
	writeln('You are in a HEX proc!');
	sizeOfInt := toDec(number, 16);
	number := number + 'h';
    if sizeOfInt < 0 then
    begin
    	//Переполнение Int
    	//writeln('Error:',StringNumber,':int Overflow!');
        writeln('Int Overflow!');
        //errorLex(number, 'IntOverFlow - *' + number + '*');
        //exit;
    end;
    str(sizeOfInt, size);
    numberOutput('Int', number, size);		
end;

{+}procedure isItOctal(number: string);
var
	i: integer;
	sizeOfInt: integer;
	size: string;
begin
	writeln('You are in an OCT proc!');
	for i := 1 to length(number) do
	begin
		// Если в восьмиричном числе встретились неверные числа
		if pos(number[i],'01234567') = 0 then 
		begin
			number := number + 'c';
			writeln('Error:',StringNumber,':uncorrect OCT!');
			writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
			exit;
		end;
	end;
	sizeOfInt := toDec(number, 8);
	number := number + 'c';
    if sizeOfInt < 0 then
    begin
        // Переполнение Int
        writeln('Error:',StringNumber,':int Overflow!');
        //errorLex(number, 'IntOverFlow - *' + number + '*');
        exit;
    end;
    str(sizeOfInt, size);
    numberOutput('Int', number, size);		
end;


function isItDecimal(number: string; bufNumb: char): boolean;
var
	sizeOfInt: integer;
	size: string;
begin
	isItDecimal := true;
	writeln('You are in a DEC proc!');
	sizeOfInt := toDec(number, 10);
	
	// Если десяичное задано через d
	if bufNumb = 'd' then number := number + bufNumb;
		
    if sizeOfInt < 0 then
    begin
        // Переполнение Int
        writeln('Error:',StringNumber,':int Overflow!');
        //errorLex(number, 'IntOverFlow - *' + number + '*');
        exit;
    end;
    str(sizeOfInt, size);
    numberOutput('Int', number, size);	
end;

function isItReal(number: string; bufNumb: char): boolean; // . или e
begin
	isItReal := true;
	writeln('You are in a REAL proc!');
	writeln('bufNumb: ', bufNumb);
	
	 // числовая_строка порядок 
	if (bufNumb = 'e') then
	begin
	writeln('temp: ', tempChar);
		if (pos(tempChar, '0123456789+-') <> 0) then
		begin
			number := number + tempChar;
			readChar();
			if pos(tempChar,'+-') = 0 then
			begin
				number := number + readWhileIn('0123456789');
				writeln('******************* number: ', number);
				if (pos(tempChar, divider) <> 0) or eof(input) then
				begin

					writeln(output, StringNumber, chr(9), 'lex:Real', chr(9), 'val:', number);
					exit;
				end;	
			end;
			writeln('Error:',StringNumber,':uncorrect REAL!');
			number := number + readTo(chr(9) + ' ' +chr(13));
			writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
			exit;
		end;
		writeln('Error:',StringNumber,':uncorrect REAL!');
		isItReal := false;
		exit;
	end;

	// числовая_строка "." числовая_строка [порядок] 
	if (bufNumb = '.') then
	begin
		number := number + bufNumb;
		if (pos(tempChar, '0123456789') <> 0) then
		begin
			number := number + tempChar;
			readChar();
			number := number + readWhileIn('0123456789');
			if (tempChar = 'e') then
			begin
			writeln('###################');
				number := number + tempChar;
				readChar();
				if pos(tempChar,'+-') <> 0 then
				begin
					number := number + tempChar;
					readChar();
					number := number + readWhileIn('0123456789');
					writeln('num1: ', number, ' temp: ', tempChar);
				end;
				if pos(tempChar, '0123456789') <> 0 then
				begin
					number := number + readWhileIn('0123456789');
					writeln('num2: ', number);
				end;
			end;	

			if pos(tempChar, divider) <> 0 then
			begin
				writeln(output, StringNumber, chr(9), 'lex:Real', chr(9), 'val:', number);
				exit;
			end;
			writeln('Error:',StringNumber,':uncorrect REAL!');
			//writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
			isItReal := false;
			exit;
		end;
		writeln('Error:',StringNumber,':uncorrect REAL!');
		//writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
		isItReal := false;
		exit;
	end;	
end;

procedure isItLabel(number: string);
var
	i: integer;
begin
	writeln('You are in a LABEL proc!');
	number := number + tempChar;
	readChar();
	// Если метка и после нее есть пробел или переход на новую строку
	if (tempChar = ' ') or (tempChar = chr(13)) or eof(input) then
	begin
		i := 1;
		writeln('number1: ', number);
		// Если есть незначащие нули  0000: 0: 01: 001:
		if number[1] = '0' then
		begin
			// Пропуск незначащих нулей
			while number[i] = '0' do inc(i);
			
			// Если метка состоит только из нулей
			if number[i] = ':' then
			begin
				writeln('Are you here?');
				number := '0:';
				writeln(output, StringNumber, chr(9), 'lex:Label', chr(9), 'val:', number);
				exit;
			end;

			number := copy(number, i, length(number)-i+1);
		end;
		writeln(output, StringNumber, chr(9), 'lex:Label', chr(9), 'val:', number);	
	end;
	// переход к обработчику деления
end;

procedure numberFound();
var
	number: string;
	bufNumb: char;
begin
	writeln('You are in NUM proc!');
	number := readWhileIn('0123456789');
	
	if pos(tempChar, '+-/*;{}[],()=!<>') <> 0 then
	begin
		number := number + readTo(chr(9) + ' ' +chr(13));
		writeln('Error:',StringNumber,':uncorrect number');
		writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
		exit;
	end;
	// Десятичная
	if tempChar = 'd' then
	begin
		bufNumb := tempChar;
		number := number + tempChar;
		readChar();
		if (pos(tempChar, divider) <> 0) then
		begin
			if eof(input) then dec(StringNumber);
			if isItDecimal(number, tempChar) = true then exit;
		end;
	end;
	if pos(tempChar, divider) <> 0 then 
	begin 
		// Метка
		if tempChar = ':' then
		begin
			isItLabel(number);
			exit;
		end;
		isItDecimal(number, tempChar);
		exit;
	end;


	bufNumb := tempChar;
	readChar();
	writeln('number: ', number, ' bufNumb: ', bufNumb, ' tempChar: ', tempChar);

	

	// Двоичная
	if ((bufNumb = 'b') and ((pos(tempChar, divider) <> 0) or eof(input))) then
	begin
		isItBinary(number);
	 	exit;
	end; 
	
	// Восьмиричная
	if (((bufNumb = 'c') and (pos(tempChar, divider) <> 0)) or ((pos(tempChar, divider) <> 0) and eof(input))) then  
	begin
	 	isItOctal(number);
		exit;
	end;
	
	
	// Шестнадцатиричное
	if (pos(bufNumb, 'abcdef') <> 0) then
	begin
		writeln('You are in a HEX handler!');
		number := number + bufNumb;
		if (pos(tempChar, 'abcdef') <> 0) then
		begin
			//number := number + tempChar;
			number := number + readWhileIn('abcdef');
		end;
		if (tempChar = 'h') then
		begin
			readChar();
			if (pos(tempChar, divider) <> 0) then
			begin
				isItHex(number);
				exit;
			end;
		end;
		// Вещественное
		if bufNumb = 'e' then
		begin
			if isItReal(number, bufNumb) = true then exit;
			//for i := 1 to length(number)-1 do bufString[i] := number[i];
			//number := bufString;
		end;
		writeln('number: ', number, ' buf: ', bufNumb, ' temp: ', tempChar);
		number := number + readTo(chr(9) + ' ' +chr(13));
		writeln('Error:',StringNumber,':uncorrect number');
		writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
		exit;
	end;
	if ((bufNumb = 'h') and ((pos(tempChar, divider) <> 0) or eof(input))) then 
	begin
		writeln('You are in a HEX handler!');
		isItHex(number);
		exit;
	end;



	// Вещественное
	if (bufNumb = '.') then 
	begin
		// if buf = e then number := number + bufNumb - в шестнадцатиричной части
		if isItReal(number, bufNumb) = true then exit;
	end;

	// Остальное	
	writeln('number: ', number, ' buf: ', bufNumb, ' temp: ', tempChar);
	number := number + bufNumb + readTo(chr(9) + ' ' +chr(13));
	writeln('number: ', number);
	writeln('Error:',StringNumber,':uncorrect number');
	writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
end;


begin
	// Проверка кол-ва входных параметров
	if ParamCount < 2 then
		begin
			writeln('Error:Params:More parameters needed!');
			exit;
		end;
	
	// Присвоить параметры именем фалйлов
	inputName := ParamStr(1);
	outputName := ParamStr(2);
	
	// Открытиве входного файла 
	assign (input, inputName);
	reset(input);
	if IOResult <> 0 then
	begin
		writeln('Error:', inputName, ':File not found');
		exit;
	end;

	// Открытие выходного файла
	assign(output, outputName);
	rewrite(output);
	if IOResult <> 0 then
	begin
		writeln('Error:', outputName, ':File not found');	
		close(input);
		exit;
	end;

	// Подготовка к началу считывания
	StringNumber := 1;
	overflowOutput := false;
	commentOutput := true;

	//Разделители: chr(9) - табуляция, chr(13) - возврат каретки 
	divider := ' ' + chr(9) + chr(13) + ':;{}[],()=!<>';

	while true do
		begin
			// Считать 1 символ 
		 	if not readChar() then break;

		 	// Пропуск пустых символов в начале строки
		 	readWhileIn(' ' + chr(13) + chr(10) + chr (9));
		 	tempString := '';

		 	// Если начало идентификатора или метки
		 	if pos(tempChar,'_qwertyuiopasdfghjklzxcvbnm') <> 0 then
		 		begin
		 			idFound();
		 		end; 

		 	// Если начало числа
		 	if pos(tempChar,'0123456789') <> 0 then
		 		begin
		 			numberFound();
		 		end;

		 	if tempChar = ':' then begin writeln(output, StringNumber, chr(9), 'lex:Colon', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = ';' then begin writeln(output, StringNumber, chr(9), 'lex:Semicolon', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = ',' then begin writeln(output, StringNumber, chr(9), 'lex:Comma', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = '(' then begin writeln(output, StringNumber, chr(9), 'lex:LRB', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = ')' then begin writeln(output, StringNumber, chr(9), 'lex:RRB', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = '[' then begin writeln(output, StringNumber, chr(9), 'lex:LSB', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = ']' then begin writeln(output, StringNumber, chr(9), 'lex:RSB', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = '{' then begin writeln(output, StringNumber, chr(9), 'lex:LCB', chr(9), 'val:', tempChar); continue; end;
		 	if tempChar = '}' then begin writeln(output, StringNumber, chr(9), 'lex:RCB', chr(9), 'val:', tempChar); continue; end;

		 	if tempChar = '.' then
		 	begin
		 		writeln('You are in a DOT handler!');
		 		tempString := tempChar;
		 		readChar();
		 		if pos(tempChar, '0123456789e') <> 0 then
		 		begin
			 		tempString := tempString + readTo(chr(9) + ' ' +chr(13));
					writeln('number: ', tempString);
					writeln('Error:',StringNumber,':uncorrect number');
					writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', tempString);
				end;
			end;
		 end;

close(input); close(output);
end.