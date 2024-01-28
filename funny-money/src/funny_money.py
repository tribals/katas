from __future__ import annotations
import pytest

from abc import (
    abstractmethod,
    ABC,
)
# Use the **Interfaces** (not "wrappers" from `typing`), Luke!
from collections.abc import Sequence

from decimal import Decimal as D
from typing import Any, overload

from phantom import Phantom
from phantom.predicates.boolean import true


class Money(D, Phantom, predicate=true):
    @classmethod
    def parse(cls, value: Any) -> Money:
        return super().parse(D(value))


def test_money():
    assert Money(D("42")) == D("42") == D(42)


def test_money_parse():
    assert Money.parse("42") == Money("42") == Money(D("42")) == D("42") == D(42)


@pytest.mark.xfail()
def test_money_parse_fail():
    assert Money(0.3) == D("0.3") == D(0.3)


class Foo(ABC):
    @abstractmethod
    def foo(self, very_important_argument: Money) -> None:
        ...


class FuckYou(Exception):
    pass


class BaseFoo(Foo):
    def foo(self, very_important_argument: Money) -> None:
        if not very_important_argument.is_enough():  # type: ignore[attr-defined]
            raise FuckYou('Stupid!')


class FiatMoney:
    ...


@pytest.mark.xfail
def test_fiat_money():
    assert FiatMoney('$42') == FiatMoney('4200₽') == D('?')


class HeartlyOursFoo(BaseFoo):
    def foo(self, very_important_argument: FiatMoney) -> None:
            ...

            dick = Money(very_important_argument)

            super().foo(dick)

            ...


class Money1(D, Phantom, predicate=true):
    @classmethod
    def parse(cls, value: object) -> Money1:
        return super().parse(D(value))


class Money2(D, Phantom, predicate=true):
    @classmethod
    def parse(cls, value: D | float | str | tuple[int, Sequence[int], int]) -> Money2:
        return super().parse(D(value))


class Money3(D, Phantom, predicate=true):
    @overload
    @classmethod
    def parse(cls, value: object) -> Money3:
        ...

    @overload
    @classmethod
    def parse(cls, value: D | float | str | tuple[int, Sequence[int], int]) -> Money3:
        ...

    @classmethod
    def parse(cls, value: object | D | float | str | tuple[int, Sequence[int], int]) -> Money3:
        if isinstance(value, (D, float, str, tuple)):
            return super().parse(D(value))

        return super().parse(value)
