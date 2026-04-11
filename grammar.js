/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "fsm",

  word: ($) => $.identifier,

  extras: ($) => [/\s+/, $.comment],

  rules: {
    source_file: ($) =>
      seq(repeat($.namespace_decl), optional($.fsm_definition)),

    comment: (_) => token(/\/\/.*/),

    namespace_decl: ($) =>
      seq("ns", field("name", $.identifier), "=", field("uri", $.string)),

    // FSM (ns=<namespace>) <name> { ... }
    fsm_definition: ($) =>
      seq(
        "FSM",
        "(",
        "ns",
        "=",
        field("namespace", $.identifier),
        ")",
        field("name", $.identifier),
        "{",
        optional($.description_clause),
        $.states_clause,
        $.start_state_clause,
        $.end_state_clause,
        $.events_clause,
        $.transitions_clause,
        $.reactions_clause,
        "}",
      ),

    description_clause: ($) => seq("DESCRIPTION", ":", $.string),

    states_clause: ($) => seq("STATES", ":", $.identifier_list),

    start_state_clause: ($) => seq("START_STATE", ":", $.reference),

    end_state_clause: ($) => seq("END_STATE", ":", $.reference),

    events_clause: ($) => seq("EVENTS", ":", $.identifier_list),

    transitions_clause: ($) =>
      seq("TRANSITIONS", ":", repeat($.transition_def)),

    reactions_clause: ($) => seq("REACTIONS", ":", repeat($.reaction_def)),

    identifier_list: ($) =>
      seq($.identifier, repeat(seq(",", $.identifier))),

    reference: ($) => seq("@", $.identifier),

    transition_def: ($) =>
      seq(
        field("name", $.identifier),
        ":",
        "FROM",
        ":",
        field("from", $.reference),
        "TO",
        ":",
        field("to", $.reference),
      ),

    reaction_def: ($) =>
      seq(
        field("name", $.identifier),
        ":",
        "WHEN",
        ":",
        field("when", $.reference),
        "DO",
        ":",
        field("do_transition", $.reference),
        optional($.fires_clause),
      ),

    fires_clause: ($) =>
      seq("FIRES", ":", $.reference, repeat(seq(",", $.reference))),

    identifier: (_) => /[A-Za-z_][A-Za-z0-9_-]*/,

    string: (_) => /"[^"]*"/,
  },
});
