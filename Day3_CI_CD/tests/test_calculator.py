import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "sample_app"))
from calculator import add, multiply, divide

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0

def test_multiply():
    assert multiply(4, 3) == 12
    assert multiply(0, 5) == 0

def test_divide():
    assert divide(10, 2) == 5
    assert divide(9, 3) == 3

def test_divide_by_zero():
    import pytest
    with pytest.raises(ValueError):
        divide(1, 0)
