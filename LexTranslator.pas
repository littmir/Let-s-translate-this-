program LexTranslator;
{
	Let's start translate!
}

uses sysutils; 

var
	inputName, outputName: string; // имена входного и выходного файлов
	input, output: text; // входной и выходный файлы
	flagError: Boolean; // флаг наличия ошибки
	flagNeedToRead: Boolean; // флаг считывания след. символа
	tempChar: Char; // буферный симовл
	tempString: string; //буферная строка
	StringNumber: Integer; // номер строки
	divider: string; // разделитель

// Инифиализация ////////////////////////////////////////////////////////////////+
// return False при ошибке //////////////////////////////////////////////////////+
function initiator(): boolean;
begin
	flagError := false;

	// проверка кол-ва входных параметров
	if ParamCount < 2 then
		begin
			writeln('Error:Params:More parameters needed!');
			initiator  := false;
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
			initiator  := false;
			exit;
		end
	else
		begin
			writeln('All is OK!(1)');
		end;

	// Открытие выходного файла
	assign(output, outputName);
	rewrite(output);
	if IOResult <> 0 then
		begin
			writeln('Error:', outputName, ':File not found');	
			// Зактрытие входного файла
			close(input);
			initiator  := false;
			exit;
		end
	else
		begin
			writeln('All is OK!(2)');
		end;

	// Подготовка к началу считывания
	flagNeedToRead := True;
	StringNumber := 1;

	//Разделители: chr(9) - табуляция, chr(13) - возврат каретки 
	divider := ' ' + chr(9) + chr(13) + '/*:+-;{}[],()%=!<>';

	initiator  := true;
end;
// Конец инициализации //////////////////////////////////////////////////////////+




// Понижение регистра ///////////////////////////////////////////////////////////+
function down(x: char): char;
begin
     if (ord(x) >= ord('A')) and (ord(x) <= ord('Z')) then
        x := chr(ord(x) - ord('A') + ord('a'));
     Down := x;
end;
// Конец понижения регистра /////////////////////////////////////////////////////+



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
			//inc(StringNumber);
			writeln('End of file');
			exit;		
		end;
	// Чтение символа
	//writeln('exTemp: ', tempChar);
	read(input, tempChar);
	writeln('Readed: ',tempChar); //------------------------------------------------------------------------------------ look at this!
	// Понижение регистра
	tempChar := down(tempChar);
	flagNeedToRead := true;
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
			if pos(tempChar, str) = 0 then
				begin
					//if readWhileIn = '' then flagNeedToRead := false;
					break;
				end;
			// Если переход на новую строку, увеличить счетчик строк
			//if tempChar = chr(13) then inc(StringNumber);
			readWhileIn := readWhileIn + tempChar;
			// если продолжаются символы, продолжаем считывать
			if not readChar() then break;
		end;
end;
// Конец считыаания пока есть схожие символы ///////////////////////////////////+




// Проверка на конец лексемы ///////////////////////////////////////////////////+
// return false если символ равен разделителю или достигнут конец файла ////////+
function endOfLex(): Boolean;
begin
	endOfLex := (pos(tempChar, divider) <> 0) or eof(input);
end;
// Конец проверки на конец лексемы /////////////////////////////////////////////+




// Чтение до разделителя ///////////////////////////////////////////////////////+
// return считанную строку до разделителя //////////////////////////////////////+
function readToDivider(str: string): string;
begin
	writeln('readToDivider works...');
	readToDivider := '';
	while true do
		begin
			// Tсли достигли разделителя - возврат
	 		if pos(tempChar, str) <> 0 then break;
	 		// Иначе считывание продолжается
	 		readToDivider := readToDivider + tempChar;
	 		if not readChar() then break;
	 	end; 
end;
// Конец чтения до разделителя /////////////////////////////////////////////////+





// Чтение до опредленного символа //////////////////////////////////////////////+
// return true - если дочиатала, false - если конец файла //////////////////////+
function readToChar(chr: char): boolean;
begin
	while true do
		begin
		 	if tempChar = chr then
		 		begin
		 			readToChar := true;
		 			exit
		 		end;
		 	if not readChar() then
		 		begin
		 			readToChar := false;
		 			exit;
		 		end;
		 end;
		 readToChar := false; 
end;
// Конец чтения до определенного символа ///////////////////////////////////////+ 




// Вывод распознанной лексемы в выходной файл //////////////////////////////////+
procedure LexOutput(lexName: string; value: string);
begin
	writeln(output, StringNumber, chr(9), 'lex:', lexName, chr(9), 'val:', value);
end;
// Конец вывода распознанной лексемы в файл ////////////////////////////////////+


// Вывод распознанной лексемы числа в файл /////////////..///////////////////////+
procedure LexNumberOutput(lexName: string; value: string; numberValue: string);
begin
	write(output, StringNumber, chr(9), 'lex:', lexName);
	lexName[1] := down(lexName[1]);
	writeln(output, chr(9), lexName, ':', numberValue, chr(9), 'val:', value);
end;
// Конец вывода распознанной лексемы числа в файл ///////////////////////////////+

// Вывод ошибочной лексемы //////////////////////////////////////////////////////+
procedure ErrorLex(value: string; message: string);
begin
	LexOutput('Error', value);
	flagError := true;
	writeln('Error:', StringNumber, ':', message);
	// Дочитвание строки, до возврата каретки
	readToChar(chr(13));
	if not eof(input) then
		flagNeedToRead := false;
end;
// Конец вывода ошибочной лексемы ///////////////////////////////////////////////+


// Распознавание идентификатора ////////////////////////////////////////////////+-
procedure idFound();
var
	// Имя и значение лексемы
	lexName: string;
	lexValue: string;
begin
	writeln('You are in a ID proc!');
	lexValue := readWhileIn('_qwertyuiopasdfghjklzxcvbnm0123456789');
	// Если не дошли до конца лексемы
	if not endOfLex() then
		begin //----------------------------------------------------------------------------------- look at this! Возможно, нужен обрабочтчик ошибки!
			// Чтение строки до разделителя
			lexValue := lexValue + readToDivider(divider);
		end;
	lexName := 'Id';
	// если не идентификатор, а ключевые слова
	if lexValue = 'cast' then lexName := 'Cast';
	if lexValue = 'var' then lexName := 'Var';
	if lexValue = 'goto' then lexName := 'Goto';
	if lexValue = 'read' then lexName := 'Read';
	if lexValue = 'write' then lexName := 'Write';
	if lexValue = 'skip' then lexName := 'Skip';
	if lexValue = 'space' then lexName := 'Space';
	if lexValue = 'tab' then lexName := 'Tab';
	if lexValue = 'end' then lexName := 'End';
	if lexValue = 'int' then lexName := 'Int';
	if lexValue = 'real' then lexName := 'Real';
	if lexValue = 'skip' then lexName := 'Skip';
	if lexValue = 'space' then lexName := 'Space';
	if lexValue = 'break' then lexName := 'Break';
	if lexValue = 'tools' then lexName := 'Tools';
	if lexValue = 'proc' then lexName := 'Proc';
	if lexValue = 'call' then lexName := 'Call';
	if lexValue = 'if' then lexName := 'If';
	if lexValue = 'case' then lexName := 'Case';
	if lexValue = 'then' then lexName := 'Then';
	if lexValue = 'else' then lexName := 'Else';
	if lexValue = 'loop' then lexName := 'Loop';
	if lexValue = 'while' then lexName := 'While';
	LexOutput(lexName, lexValue);
end;
// Конец распознавания идентификатора //////////////////////////////////////////+-

function toDec(str: string; size: integer): integer;
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
        errorLex(number, 'IntOverFlow - *' + number + '*');
        exit;
    end;
    str(sizeOfInt, size);
    LexNumberOutput('Int', number, size);				 	
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
        writeln('Int Overflow!');
        //errorLex(number, 'IntOverFlow - *' + number + '*');
        //exit;
    end;
    str(sizeOfInt, size);
    LexNumberOutput('Int', number, size);		
end;

procedure isItOctal(number: string);
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
        errorLex(number, 'IntOverFlow - *' + number + '*');
        exit;
    end;
    str(sizeOfInt, size);
    LexNumberOutput('Int', number, size);		
end;


procedure isItDecimal(number: string; bufNumb: char);
var
	sizeOfInt: integer;
	size: string;
begin
	writeln('You are in a DEC proc!');

	sizeOfInt := toDec(number, 10);
	if bufNumb = 'd' then
	begin
		
		readChar();
		if pos(tempChar, divider) = 0 then 
		begin
			//writeln('number: ', number, ' buf: ', bufNumb, ' temp: ', tempChar);
			//number := number + readToDivider(chr(9) + ' ' +chr(13));
			//writeln('number: ', number);
			//writeln('Error:', StringNumber, ':uncorrect DEC!');
			//writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
			exit;
		end;
		number := number + bufNumb;
	end;
		
    if sizeOfInt < 0 then
    begin
        // Переполнение Int
        errorLex(number, 'IntOverFlow - *' + number + '*');
        exit;
    end;
    str(sizeOfInt, size);
    LexNumberOutput('Int', number, size);	
end;

function isItReal(number: string; bufNumb: char): boolean; // . или e
var
	i: integer;
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
			//writeln('number: ', number, ' buf: ', bufNumb, ' temp: ', tempChar);
			number := number + readToDivider(chr(9) + ' ' +chr(13));
			writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
			//isItReal := false;
			exit;
		end;
		writeln('Error:',StringNumber,':uncorrect REAL!');
		//writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
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


// Распознавание числа ////////////////////////////////////////////////////////
procedure numberFound();
var
	number: string;
	bufNumb: char;
	i:  integer;
	bufString: string;
begin
	writeln('You are in NUM proc!');
	number := readWhileIn('0123456789');
	

	// Десятичная
	if (tempChar = 'd') or (pos(tempChar, divider) <> 0) or eof(input) then
	//if (((tempChar = 'd') and (pos(tempChar, divider) <> 0)) or (pos(bufNumb, divider) <> 0)) or eof(input) then
	begin
		if eof(input) then dec(StringNumber);
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
		number := number + readToDivider(chr(9) + ' ' +chr(13));
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
	if ((bufNumb = '.') {or (bufNumb = 'e')}) then 
	begin
		// if buf = e then number := number + bufNumb - в шестнадцатиричной части
		if isItReal(number, bufNumb) = true then exit;
		{if bufNumb = 'e' then
		begin
			for i := 1 to length(number)-1 do bufString[i] := number[i];
			number := bufString;
		end;}
	end;

	// Остальное	
	writeln('number: ', number, ' buf: ', bufNumb, ' temp: ', tempChar);
	number := number + bufNumb + readToDivider(chr(9) + ' ' +chr(13));
	writeln('number: ', number);
	writeln('Error:',StringNumber,':uncorrect number');
	writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', number);
end;

// Конец распознавания числа ///////////////////////////////////////////////////



// Главная функция /////////////////////////////////////////////////////////////

begin
	// Ошибка инициализации
	if not initiator() then 
		begin
			flagError := true;
			exit;
		end
	else
		begin
			writeln('All is OK!(3)');
		end;

	// Успешная инициализация
	while true do
		begin
			// Если необходимо считывать
			//writeln('fntr: ', flagNeedToRead);
		 	if flagNeedToRead then
		 		begin
		 			// Считать 1 символ
		 			if not readChar() then
		 				// Если достигнут конец файла	
		 				break;
		 		end
		 	// Если флаг считывания был опущен, поднять
		 	else
		 		flagNeedToRead := true;

		 	// Пропуск пустых символов в начале строки
		 	readWhileIn(' ' + chr(13) + chr(10) + chr (9));
		 	tempString := '';
		 	// Если начало идентификатора или метки
		 	if pos(tempChar,'_qwertyuiopasdfghjklzxcvbnm') <> 0 then
		 		begin
		 			idFound();
		 			flagNeedToRead := false or eof(input);
		 			continue;
		 		end; 
		 	// Если начало числа
		 	if pos(tempChar,'0123456789') <> 0 then
		 		begin
		 			numberFound();
		 			//flagNeedToRead := false or eof(input);
		 			//continue;
		 		end;

		 	if tempChar = '.' then
		 	begin
		 		writeln('You are in a DOT handler!');
		 		tempString := tempChar;
		 		readChar();
		 		if pos(tempChar, '0123456789e') <> 0 then
		 		begin
			 		tempString := tempString + readToDivider(chr(9) + ' ' +chr(13));
					writeln('number: ', tempString);
					writeln('Error:',StringNumber,':uncorrect number');
					writeln(output, StringNumber, chr(9), 'lex:Error', chr(9), 'val:', tempString);
				end;
			end;
		 end;



close(input); close(output);
//ReadLn;
end.
// Конец главной функции ///////////////////////////////////////////////////////