{$MODE OBJFPC}
program Test;
	
var
	testString: string;
	toReal: real;
	code: Integer;
	Error: Boolean;
begin
	Error := false;
	testString:='2e+2000';
	writeln(testString);

	try
		val(testString, toReal, code);
		except 
		writeln('toReal');
		Error := true;
	end;
	writeln(toReal);
	writeln(Error);


	readln;
end.