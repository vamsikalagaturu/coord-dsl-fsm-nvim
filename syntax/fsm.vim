" Vim syntax file for the TextX FSM DSL
" Language: FSM (coord-dsl)

if exists('b:current_syntax')
  finish
endif

" Section-level keywords
syntax keyword fsmSection NAME DESCRIPTION STATES START_STATE CURRENT_STATE
syntax keyword fsmSection END_STATE EVENTS TRANSITIONS REACTIONS

" Clause keywords inside transition/reaction blocks
syntax keyword fsmClause FROM TO WHEN DO FIRES

" Namespace keyword
syntax keyword fsmNs ns

" Cross-references: @Identifier
syntax match fsmRefAt /@/ nextgroup=fsmRefName
syntax match fsmRefName /[A-Za-z_][A-Za-z0-9_-]*/ contained

" Identifiers in lists and definitions
syntax match fsmIdent /[A-Za-z_][A-Za-z0-9_-]*/

" String literals
syntax region fsmString start=/"/ end=/"/ oneline

" Line comments
syntax match fsmComment /\/\/.*/

highlight default link fsmSection  Keyword
highlight default link fsmClause   Keyword
highlight default link fsmNs       Include
highlight default link fsmRefAt    Operator
highlight default link fsmRefName  Identifier
highlight default link fsmString   String
highlight default link fsmComment  Comment

let b:current_syntax = 'fsm'
