from setuptools import setup

setup(
    name="refal-pygments",
    version="0.1",
    py_modules=["refal_lexer"],
    entry_points={
        "pygments.lexers": ["refal = refal_lexer:RefalLexer"],
        "pygments.styles": ["refal = refal_lexer:RefalStyle"],
    },
)