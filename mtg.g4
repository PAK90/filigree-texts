grammar mtg;

// Take care of whitespace.
WS  :  [ \r\t]+ -> skip;

/*
This will be the entry point of our parser.
*/
evaluate
	: textbox?
	;

/*
Split everything into rows, divided by newlines. Can be 0 to infinite number of rows.
Can't quite get it to ignore newlines on last line...
*/
textbox
	: (row '\n')*
	;

/*
Every row either has one ability, or a list of them.
*/
row
    : ability
    | ability_list
    ;
