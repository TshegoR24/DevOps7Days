import pytest

from Day3_CI_CD.sample_app.calculator import add, divide, multiply


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
    with pytest.raises(ValueError):
        divide(1, 0)
