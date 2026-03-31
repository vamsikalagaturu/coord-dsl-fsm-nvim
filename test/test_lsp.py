#!/usr/bin/env python3
"""Basic tests for the FSM language server."""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
SERVER = ROOT / "server" / "fsm_lsp.py"
VALID_FSM = ROOT / "test" / "fixtures" / "valid.fsm"
INVALID_FSM = ROOT / "test" / "fixtures" / "invalid.fsm"
GRAMMAR_DIR = ROOT / "server" / "grammar"
SRC_DIR = ROOT / "src"


def test_server_imports():
    """Server script must import without errors."""
    result = subprocess.run(
        [sys.executable, str(SERVER), "--help"],
        capture_output=True, text=True,
        timeout=5,
    )
    # --help will fail with an unknown-arg error, but if ImportError occurs
    # the stderr will mention it.  We only care that pygls / textx loaded.
    assert "ModuleNotFoundError" not in result.stderr, \
        f"Import failed: {result.stderr}"
    print("PASS: server imports cleanly")


def test_grammar_loads():
    """TextX metamodel must load from bundled grammar files."""
    result = subprocess.run(
        [sys.executable, "-c",
         f"from textx import metamodel_from_file; "
         f"mm = metamodel_from_file(r'{GRAMMAR_DIR}/fsm.tx'); "
         f"print('metamodel loaded')"],
        capture_output=True, text=True,
    )
    assert result.returncode == 0, f"Grammar load failed:\n{result.stderr}"
    assert "metamodel loaded" in result.stdout
    print("PASS: grammar loads")


def test_valid_fsm_parses():
    """Valid fixture must parse without errors."""
    result = subprocess.run(
        [sys.executable, "-c",
         f"from textx import metamodel_from_file; "
         f"mm = metamodel_from_file(r'{GRAMMAR_DIR}/fsm.tx'); "
         f"mm.model_from_file(r'{VALID_FSM}'); "
         f"print('ok')"],
        capture_output=True, text=True,
    )
    assert result.returncode == 0, f"Valid FSM parse failed:\n{result.stderr}"
    assert "ok" in result.stdout
    print("PASS: valid.fsm parses without errors")


def test_invalid_fsm_raises():
    """Invalid fixture must raise a TextX exception."""
    result = subprocess.run(
        [sys.executable, "-c",
         f"from textx import metamodel_from_file; "
         f"from textx.exceptions import TextXError; "
         f"mm = metamodel_from_file(r'{GRAMMAR_DIR}/fsm.tx'); "
         f"raised = False\n"
         f"try:\n"
         f"    mm.model_from_file(r'{INVALID_FSM}')\n"
         f"except TextXError:\n"
         f"    raised = True\n"
         f"print('raised:', raised)"],
        capture_output=True, text=True,
    )
    assert "raised: True" in result.stdout, \
        f"Expected TextXError but got none. stdout={result.stdout} stderr={result.stderr}"
    print("PASS: invalid.fsm raises TextXError")


def test_parser_c_exists():
    """src/parser.c must exist for nvim-treesitter to compile."""
    parser_c = SRC_DIR / "parser.c"
    assert parser_c.exists(), f"src/parser.c not found at {parser_c}"
    assert parser_c.stat().st_size > 0, "src/parser.c is empty"
    print("PASS: src/parser.c exists")


def test_queries_exist():
    """Tree-sitter highlight queries must exist."""
    highlights = ROOT / "queries" / "fsm" / "highlights.scm"
    assert highlights.exists(), f"highlights.scm not found at {highlights}"
    content = highlights.read_text()
    assert "@keyword" in content
    assert "@comment" in content
    assert "@string" in content
    print("PASS: queries/fsm/highlights.scm exists and has expected captures")


if __name__ == "__main__":
    failures = []
    for name, fn in [
        ("server_imports", test_server_imports),
        ("grammar_loads", test_grammar_loads),
        ("valid_fsm_parses", test_valid_fsm_parses),
        ("invalid_fsm_raises", test_invalid_fsm_raises),
        ("parser_c_exists", test_parser_c_exists),
        ("queries_exist", test_queries_exist),
    ]:
        try:
            fn()
        except AssertionError as e:
            print(f"FAIL: {name}: {e}")
            failures.append(name)
        except Exception as e:
            print(f"ERROR: {name}: {e}")
            failures.append(name)

    if failures:
        print(f"\n{len(failures)} test(s) failed: {', '.join(failures)}")
        sys.exit(1)
    else:
        print("\nAll tests passed.")
