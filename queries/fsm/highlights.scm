; Section keywords
"NAME" @keyword
"DESCRIPTION" @keyword
"STATES" @keyword
"START_STATE" @keyword
"CURRENT_STATE" @keyword
"END_STATE" @keyword
"EVENTS" @keyword
"TRANSITIONS" @keyword
"REACTIONS" @keyword

; Clause keywords
"FROM" @keyword
"TO" @keyword
"WHEN" @keyword
"DO" @keyword
"FIRES" @keyword

; Namespace keyword
"ns" @keyword.import

; Comments
(comment) @comment

; String literals
(string) @string

; @ cross-reference operator
(reference "@" @operator)
(reference (identifier) @variable.member)

; Namespace declarations
(namespace_decl name: (identifier) @module)

; FSM qualified name - namespace part (optional)
(qualified_name namespace: (identifier) @module)
(qualified_name local: (identifier) @type)

; State declarations
(states_clause (identifier_list (identifier) @type))

; Event declarations
(events_clause (identifier_list (identifier) @variable))

; Transition definition name
(transition_def name: (identifier) @function)

; Reaction definition name
(reaction_def name: (identifier) @function)
