\d .log

print:{[typ;msg] -1 string[.z.p]," ",typ," ",string[.z.w]," ",$[10=abs type msg;msg;-3!msg];}
info:print"info"
warn:print"warn"
error:print"error"
fatal:{[msg] print["fatal";msg];exit 1}