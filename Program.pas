Program _;
var
f1,f2:text;
a:longint;
begin
assign(f1,'INPUT.TXT');
assign(f2,'OUTPUT.TXT');
reset(f1);
rewrite(f2);
read(f1,a);
a:=a div 10;
a:=a*(a+1);
if a=0 then write(f2,'25')
else write(f2,a,'25');
close(f1);
close(f2);
end.