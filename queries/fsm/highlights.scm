; FSM declaration keyword
"FSM" @keyword

; Section keywords
"DESCRIPTION" @keyword
"STATES" @keyword
"START_STATE" @keyword
"END_STATE" @keyword
"EVENTS" @keyword
"TRANSITIONS" @keyword
"REACTIONS" @keyword

; Clause keywords inside transition/reaction blocks
"FROM" @keyword
"TO" @keyword
"WHEN" @keyword
"DO" @keyword
"FIRES" @keyword

; Namespace keyword
"ns" @keyword.import

; Braces
"{" @punctuation.bracket
"}" @punctuation.bracket

; Comments
(comment) @comment

; String literals
(string) @string

; @ cross-reference operator
(reference "@" @operator)
(reference (identifier) @variable.member)

; Namespace declarations
(namespace_decl name: (identifier) @module)

; FSM namespace reference and name
(fsm_definition namespace: (identifier) @module)
(fsm_definition name: (identifier) @type)

; State declarations
(states_clause (identifier_list (identifier) @type))

; Event declarations
(events_clause (identifier_list (identifier) @variable))

; Transition definition name
(transition_def name: (identifier) @function)

; Reaction definition name
(reaction_def name: (identifier) @function)
