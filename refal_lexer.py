import re
from pygments.lexer import RegexLexer
from pygments.style import Style
from pygments.token import (
    Comment, Name, Number, Operator,
    Punctuation, String, Text, Token,
)

# Custom subtokens for distinct styling.
EVar = Token.Name.Variable.EVar
TVar = Token.Name.Variable.TVar
SVar = Token.Name.Variable.SVar
Ellipsis_ = Token.Generic.Ellipsis     # the "..." placeholder
Paren = Token.Punctuation.Paren        # ( )
Angle = Token.Punctuation.Angle        # < >

_VAR_SUFFIX = r"[A-Za-z0-9_][A-Za-z0-9_\-]*"
_Q_ESC = r"\\(?:['\"]|x[0-9A-Fa-f]+|[tnrabfv]|\\)"


class RefalLexer(RegexLexer):
    name = "Refal"
    aliases = ["refal"]
    filenames = ["*.ref", "*.refal"]

    # Order matters: longer/more specific patterns first.
    tokens = {
        "root": [
            (r"/\*[\s\S]*?\*/", Comment.Multiline),
            (r"\s+", Text.Whitespace),

            # Ellipsis placeholder (must come before generic punctuation/names).
            (r"\.\.\.", Ellipsis_),

            # Variables: e.X, t.X, s.X -- match before generic names.
            (r"e\." + _VAR_SUFFIX, EVar),
            (r"t\." + _VAR_SUFFIX, TVar),
            (r"s\." + _VAR_SUFFIX, SVar),

            # Strings (single line, with escapes).
            (r"'(?:[^'\\\n]|" + _Q_ESC + r")*'", String.Single),
            (r'"(?:[^"\\\n]|' + _Q_ESC + r')*"', String.Double),

            (r"[0-9]+", Number.Integer),
            (r"[A-Za-z_][A-Za-z0-9_\-]*", Name),

            # Distinct bracket types.
            (r"[()]", Paren),
            (r"[<>]", Angle),

            (r"[{}]", Punctuation),
            (r"[=;]", Punctuation),
        ],
    }


class RefalStyle(Style):
    """
    Custom style with stronger contrast for variables and distinct
    colors for parentheses and angle brackets.
    """
    background_color = "#f0f0f0"

    styles = {
        Comment.Multiline:  "italic #2e8b8b",   # teal, like in your screenshot
        String:             "#24292e",
        Number:             "#24292e",
        Name:               "#24292e",          # near-black for plain names

        # Variables — saturated, clearly distinct from black text.
        EVar:               "bold #888888",     # grey
        TVar:               "bold #888888",     # grey
        SVar:               "bold #888888",     # grey

        # Brackets.
        Paren:              "bold #9f5e00",     # amber/orange for ( )
        Angle:              "bold #24292e",

        Punctuation:        "#24292e",          # { } = ;  stay neutral
    }