grammar mtg;

// Take care of whitespace.
WS : [ \r\t\f\n]+ -> skip;

OTHER: . -> skip;

STRING
    : '"' [A-z ]+ '"'
    ;

AND_OR
    : 'and' | 'or'
    ;

NUMBER
    : [1-9][0-9]* /* don't allow flat {0}. */
    ;

COLOURS_SHORT
    : 'W' | 'w'
    | 'U' | 'u'
    | 'R' | 'r'
    | 'B' | 'b'
    | 'G' | 'g'
    | 'C' | 'c'
    ;

/*
Mana costs can be simply {3}, or {r}, or {2/r}, or {3}{G/P}.
Multiples are handled by the mana_cost rule.
Need / to handle hybrid costs, and 2 for two-brid costs.
*/
MANA_COST
    : '{' ( NUMBER | COLOURS_SHORT | ('2' '/' COLOURS_SHORT) | (COLOURS_SHORT '/' ('P'|'p')) ) '}'
    ;

/*
This will be the entry point of our parser.
*/
evaluate
	: textbox? // could be an empty textbox.
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

/*
An ability list is strictly evergreen keywords, comma-separated.
*/
ability_list
    : static_ability (',' static_ability)* // only static abilities get listed in one line with commas.
    ;

ability
	:/* spell_ability // Instants/sorceries only (unless those themselve are any of the 3 other types).
	|*/ activated_ability
	| triggered_ability
	| static_ability
	| STRING
	;

/*
112.3b Activated abilities have a cost and an effect. They are written as “[Cost]: [Effect.] [Activation instructions
(if any).]” A player may activate such an ability whenever he or she has priority. Doing so puts it on the stack,
where it remains until it’s countered, it resolves, or it otherwise leaves the stack.
See rule 602, “Activating Activated Abilities.”
*/
activated_ability
    : activation_cost (',' activation_cost)* ':' STRING //(one_time_effect duration)+
    ;

activation_cost
    : mana_cost
    | '{T}' | '{t}'
    | '{Q}' | '{q}'
    ;
/*
112.3c Triggered abilities have a trigger condition and an effect. They are written as “[Trigger condition], [effect],”
and include (and usually begin with) the word “when,” “whenever,” or “at.” Whenever the trigger event occurs,
the ability is put on the stack the next time a player would receive priority and stays there until it’s countered,
it resolves, or it otherwise leaves the stack. See rule 603, “Handling Triggered Abilities.”
*/
triggered_ability
    : trigger_words ',' STRING // Add compatibility with 'or' (e.g. Shrine of Limitless Power).
    ;

trigger_words
    : ('when'|'whenever'|'as') whenever_triggers|'at' at_triggers
    ;

whenever_triggers
    : triggerer (('or'|'and') triggerer)* action
    ;

/*
Who's doing the triggering.
*/

qualifier
    : COLOURS (('and'|' or')* qualifier)* // for some reason this needs a space? ' or' instead of 'or'. but 'and' works...
    ;

triggerer
    : self
    | ((quantity|'another'|'a'|'an'|'that') qualifier? (CREATURE_TYPE|TYPES|SUBTYPES|player_opponent))
    |
    ;

quantity
    : ('one'|'two') 'or more'? // this also has the space problem...
    ;

action
    : 'dies'
    | 'enters the battlefield'
    ;

self // difference between this being a parser (nocaps) and lexer (CAPS) rule is whether it appears in the tree.
    : '~'
    ;

/*
At varieties:
"at the beginning of your|each|each player's|that player's|the|each opponent's upkeep|draw step|end step|precombat main phase,"
"at the beginning of combat on your|each opponent's turn,"
"at end of combat,"
Note that this will accept invalid combinations, it's not an ultra-strict grammar checker.
*/
at_triggers
    : ('the beginning of' (combat|not_combat))
    |'end of combat'
    ;

not_combat
    : (ownership|'the') PHASES
    ;

combat
    : 'combat on' ownership 'turn'
    ;

ownership
    : SELECTIVES (player_opponent'\'s'?)? // this last one needed to be a parser rule, failed on lexer rule... dunno why.
    ;

PHASES
    : 'draw step'|'upkeep'|'precombat main phase'|'postcombat main phase'|'combat'|'end step'
    ;

SELECTIVES
    : 'your'|'each'|'that'
    ;

player_opponent
    : 'player'|'opponent'
    ;

/*
112.3d Static abilities are written as statements. They’re simply true. Static abilities create continuous effects
which are active while the permanent with the ability is on the battlefield and has the ability, or while the object
with the ability is in the appropriate zone. See rule 604, “Handling Static Abilities.”
*/
static_ability
	: static_keyword
	| /* FINISH ME */
	;

mana_cost
    : MANA_COST+
    ;

/* This rule covers static keywords. */
static_keyword
	: evergreen_static_keyword
	;

/* This rule covers evergreen static keywords. */
evergreen_static_keyword
	: 'deathtouch'
	| 'defender'
	| 'double strike'
	| 'enchant' object_or_player (',' 'or'? object_or_player)* // Supports multiple targets like what's done in 'Imprisoned in the Moon'.
	| 'first strike'
	| 'flash'
	| 'flying'
	| 'haste'
	| 'hexproof'
	| 'indestructible'
	| 'lifelink'
	| 'menace'
	| 'reach'
	| 'trample'
	| 'vigilance'
	| 'banding'
	| 'fear'
	| 'shroud'
	| 'intimidate'
	| 'landwalk'
	| protection
	;

/*
*/
object_or_player
	: ENCHANT_TYPES | 'player'
    ;

ENCHANT_TYPES
    : 'creature'
    | 'creature an opponent controls'
    | 'creature you control'
    | 'opponent' // should probably be a type of 'player'
    | TYPES ' card in a graveyard'
    | 'enchantment'
    | 'land'
    | 'artifact'
    | 'planeswalker'
    ;

/*
702.16a Protection is a static ability, written “Protection from [quality].” This quality is usually a color
(as in “protection from black”) but can be any characteristic value. If the quality happens to be a card name,
it is treated as such only if the protection ability specifies that the quality is a name. If the quality is a card type,
subtype, or supertype, the ability applies to sources that are permanents with that card type, subtype, or supertype
and to any sources not on the battlefield that are of that card type, subtype, or supertype. This is an exception to rule 109.2.
*/
protection
    : 'protection from' quality ('and from' quality)*
    ;

COLOURS
    : 'black'
    | 'blue'
    | 'green'
    | 'red'
    | 'white'
    ;

TYPES
    : 'instant'
    | 'creature'
    ;

/*
Reference table: http://mtgsalvation.gamepedia.com/Protection#History
*/
quality
    : COLOURS
    | 'artifacts'
    | 'chosen color' // All 'choose' ones will probably change with implementation of 'choose' syntax.
    | CREATURE_TYPE
    | 'all colors' // Need to expand this to encompass blue and white etc.
    | 'creatures'
    | 'enchantments'
    | 'instants'
    | 'its colors' // Expand or no?
    | 'sorceries'
    | 'chosen type'
    | 'arcane'
    | 'monocolored'
    | 'multicolored'
    | 'snow'
    | 'converted mana cost' NUMBER 'or greater'
    | 'chosen card'
    | 'everything'
    | 'lands'
    | 'colored spells'
    | 'chosen player'
    ;

CREATURE_TYPE
    : 'eldrazi'
    | 'wizard'
    ;