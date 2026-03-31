#!/usr/bin/env python3
"""Language server for the TextX FSM DSL (.fsm files)."""

import logging
import re
import sys
from pathlib import Path

from lsprotocol import types
from pygls.lsp.server import LanguageServer

GRAMMAR_DIR = Path(__file__).parent / "grammar"

logger = logging.getLogger(__name__)

server = LanguageServer("fsm-ls", "v0.1.0")


def _load_metamodel():
    """Load the FSM TextX metamodel. Returns None if textX is not available."""
    try:
        from textx import metamodel_from_file
        from textx.exceptions import TextXError

        mm = metamodel_from_file(str(GRAMMAR_DIR / "fsm.tx"))
        return mm, TextXError
    except ImportError:
        logger.warning("textX not installed; diagnostic support disabled")
        return None, None
    except Exception as exc:
        logger.error("Failed to load FSM metamodel: %s", exc)
        return None, None


_METAMODEL, _TextXError = _load_metamodel()


def _parse_and_diagnose(uri: str, source: str) -> list[types.Diagnostic]:
    """Parse source text and return LSP diagnostics for any errors."""
    diagnostics: list[types.Diagnostic] = []

    if _METAMODEL is None:
        return diagnostics

    try:
        _METAMODEL.model_from_str(source, file_name=uri)
    except Exception as exc:
        # TextXSyntaxError and TextXSemanticError carry line/col attributes.
        line = getattr(exc, "line", 1) or 1
        col = getattr(exc, "col", 1) or 1
        message = str(exc)
        # Strip the redundant "line N, col M" prefix that textX already embeds.
        message = re.sub(r"^\s*\(line \d+, col \d+\):?\s*", "", message)

        diagnostics.append(
            types.Diagnostic(
                range=types.Range(
                    start=types.Position(line=line - 1, character=col - 1),
                    end=types.Position(line=line - 1, character=col),
                ),
                message=message or str(exc),
                severity=types.DiagnosticSeverity.Error,
                source="fsm-ls",
            )
        )

    return diagnostics


def _publish(ls: LanguageServer, uri: str, source: str) -> None:
    diagnostics = _parse_and_diagnose(uri, source)
    ls.text_document_publish_diagnostics(
        types.PublishDiagnosticsParams(uri=uri, diagnostics=diagnostics)
    )


@server.feature(types.TEXT_DOCUMENT_DID_OPEN)
def did_open(ls: LanguageServer, params: types.DidOpenTextDocumentParams) -> None:
    _publish(ls, params.text_document.uri, params.text_document.text)


@server.feature(types.TEXT_DOCUMENT_DID_CHANGE)
def did_change(ls: LanguageServer, params: types.DidChangeTextDocumentParams) -> None:
    doc = ls.workspace.get_text_document(params.text_document.uri)
    _publish(ls, params.text_document.uri, doc.source)


@server.feature(types.TEXT_DOCUMENT_DID_SAVE)
def did_save(ls: LanguageServer, params: types.DidSaveTextDocumentParams) -> None:
    doc = ls.workspace.get_text_document(params.text_document.uri)
    _publish(ls, params.text_document.uri, doc.source)


@server.feature(
    types.TEXT_DOCUMENT_HOVER,
    types.HoverOptions(),
)
def hover(
    ls: LanguageServer, params: types.HoverParams
) -> types.Hover | None:
    doc = ls.workspace.get_text_document(params.text_document.uri)
    word = _word_at(doc.source, params.position.line, params.position.character)
    info = _HOVER_DOCS.get(word)
    if info is None:
        return None
    return types.Hover(
        contents=types.MarkupContent(kind=types.MarkupKind.Markdown, value=info)
    )


_HOVER_DOCS: dict[str, str] = {
    "NAME": "**NAME** `:` `(ns=<namespace>)<local>`\n\nFully qualified name of this FSM.",
    "DESCRIPTION": "**DESCRIPTION** `:` `\"<text>\"`\n\nOptional human-readable description.",
    "STATES": "**STATES** `:` `S1, S2, ...`\n\nComma-separated list of state identifiers.",
    "START_STATE": "**START_STATE** `:` `@<state>`\n\nInitial state when the FSM is created.",
    "CURRENT_STATE": "**CURRENT_STATE** `:` `@<state>`\n\nState at construction time (usually same as START_STATE).",
    "END_STATE": "**END_STATE** `:` `@<state>`\n\nTerminal state; reaching it stops execution.",
    "EVENTS": "**EVENTS** `:` `E1, E2, ...`\n\nComma-separated list of event identifiers.",
    "TRANSITIONS": "**TRANSITIONS** `:` `<T_name>: FROM: @S1 TO: @S2 ...`\n\nDefines valid state transitions.",
    "REACTIONS": "**REACTIONS** `:` `<R_name>: WHEN: @E DO: @T [FIRES: @E2, ...]`\n\nEvent-driven reactions that trigger transitions and optionally fire new events.",
    "FROM": "**FROM** `:` `@<state>`\n\nSource state of a transition.",
    "TO": "**TO** `:` `@<state>`\n\nDestination state of a transition.",
    "WHEN": "**WHEN** `:` `@<event>`\n\nEvent that triggers this reaction.",
    "DO": "**DO** `:` `@<transition>`\n\nTransition to execute when this reaction fires.",
    "FIRES": "**FIRES** `:` `@<event> [, @<event>]...`\n\nEvents produced after this reaction executes.",
    "ns": "**ns** `<name>` `=` `\"<uri>\"`\n\nNamespace declaration. Binds a short prefix to a URI.",
}


def _word_at(source: str, line: int, character: int) -> str:
    """Extract the word (identifier or keyword) at the given position."""
    lines = source.splitlines()
    if line >= len(lines):
        return ""
    text = lines[line]
    if character >= len(text):
        return ""
    # Expand left
    start = character
    while start > 0 and re.match(r"[A-Za-z0-9_]", text[start - 1]):
        start -= 1
    # Expand right
    end = character
    while end < len(text) and re.match(r"[A-Za-z0-9_]", text[end]):
        end += 1
    return text[start:end]


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.WARNING,
        stream=sys.stderr,
        format="%(levelname)s %(name)s: %(message)s",
    )
    server.start_io()
