# filigree-texts
This project isn't concerned with creating a complete digital representation of a Magic card. Rather, it aims to JSON-ise the rules text in order to enable better querying.
For example, consider [searching for hexproof](http://mtg-hunter.com/?rulesText=hexproof) as an ability. This finds cards like [Geist of Saint Traft](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=409577), which has this ability unconditionally, but also cards like [Dragonlord Ojutai](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=394549), which has it conditionally, and [Bristling Hydra](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=417720), which acquires it through an activated ability. There's no (sane) string-based query to get around this. 

Therefore, the aim is to build a JSON construct which can embody these concepts in a queryable fashion. This is theoretically doable manually, but doing so for ~16,000 cards would be an insane task. Slightly less insane is to treat the rules text as a programming language. This involves a grammar parser like Antlr4. The .g4 files describe the grammar of Magic-ese (Magic English? Magese?) and parse it into a syntax tree, which the (forthcoming) python code will be able to traverse and subsequently generate a JSON representation.

## Setup
First, download [Antlr v4](http://www.antlr.org/download.html) from the site. This should result in a jar file named something like 'antlr-4.6-complete.jar'. Theoretically, a text editor is all that's needed for editing .g4 files, but why make things more difficult?

[Antlrworks2](tunnelvisionlabs.com/products/demo/antlrworks) is an IDE built specifically for .g4 files, but to test grammar files you have to load them up in a test rig, which slows development of the grammar.

[IntelliJ Idea](https://www.jetbrains.com/idea/) (the community version) is a better solution. It can handle most languages, and with the Antlr4 plugin, it generates live syntax trees on text that you can enter in a sidebox, allowing for instant testing of grammars. In Idea, `File->Settings` and then `Plugins` gets you to a plugin list. Search for Antlr v4 (click 'search in repositories' if you don't see a result) and install it. Once that's done, open the `filigree-text` folder. Then to test the syntax, open the mtg.g4 file and right click on the `evaluate` rule, and select `Test Rule evaluate`. Then use the input text box to test the grammar, or select a file.

Now you can edit grammar files conveniently. However, we need to use the syntax trees the grammar generates, and while the default choice is Java, I'm going full Python. In a terminal, go to the folder containing the grammar files and run this command:

`java -cp antlr-4.6-complete.jar org.antlr.v4.Tool mtg.g4 -Dlanguage=Python3`

where mtg.g4 will be the name of the top-level grammar file (it imports other ones). (You can leave out the `-Dlanguage=Python3` option to generate default Java classes.) This generates Python classes (a lexer, a listener and a parser) which will be used in a future Python file which will read in a (future) corpus file and pass each card into the syntax tree generator.
