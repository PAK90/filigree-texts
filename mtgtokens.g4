grammar mtgtokens;

// First declare individual words, then group them in revelant lexer rules.

TAP: 'T' | 't';
UNTAP: 'Q' | 'q';

COLOURS_SHORT
    : 'W' | 'w'
    | 'U' | 'u'
    | 'R' | 'r'
    | 'B' | 'b'
    | 'G' | 'g'
    | 'C' | 'c'
    ;

AND: 'and';
OR: 'or';
THE: 'the';
OF: 'of';
COMMA: ',';
COLON: ':';
TILDE: '~';
WMORE: 'more';
WHEN: 'when';
WHENEVER: 'whenever';
AS: 'as';
AT: 'at';
A: 'a';
AN: 'an';
ANOTHER: 'another';
THAT: 'that';
EACH: 'each';
TARGET: 'target';
YOU: 'you';
YOUR: 'your';
OPPONENT: 'opponent';
PLAYER: 'player';
DRAW: 'draw';
STEP: 'step';
COMBAT: 'combat';
UPKEEP: 'upkeep';
PRECOMBAT: 'precombat';
POSTCOMBAT: 'postcombat';
BEGINNING: 'beginning';
MAIN: 'main';
END: 'end';
PHASE: 'phase';

SELECTIVES: YOUR | EACH | THAT;

NUMBER
    : [1-9][0-9]* // don't allow flat {0}.
    ;

WORD_NUMBER: 'one' | 'two' | 'three' | 'four' | 'five' | 'six' | 'seven' | 'eight' | 'nine' | 'ten'
    | 'eleven' /* not used */ | 'twelve' | 'thirteen' | 'fourteen' /* not used */ | 'fifteen' | 'twenty'
    ;


COLOURS_LONG
    : 'white' | 'blue' | 'red' | 'black' | 'green' | 'colorless'
    ;

/*
Mana costs can be simply {3}, or {r}, or {2/r}, or {3}{G/P}.
Multiples are handled by the mana_cost rule.
Need / to handle hybrid costs, and 2 for two-brid costs.
*/
MANA_COST
    : '{' ( NUMBER | COLOURS_SHORT | ('2' '/' COLOURS_SHORT) | (COLOURS_SHORT '/' ('P'|'p')) ) '}'
    ;



// Maybe don't even list all of them, just accept a string.
CREATURE_TYPE
    : [A-z ]+
    ;

// These are catchall rules, so put them at the end.

WS : [ \r\t\f\n]+ -> skip;
OTHER: . -> skip;

STRING
    : '"' [A-z ]+ '"'
    ;
