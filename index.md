Ошибка!

Во-первых, оригинальный интерфейс метода `.parse` (https://github.com/antonagestam/phantom-types/blob/main/src/phantom/_base.py#L62) такой:

```python
    def parse(cls: ..., instance: object) -> ...:
```

Я опустил пару ненужных деталей, но суть вы уловили - приходит object. Казалось бы, проблема решена - ведь Any и есть object. Расходимся.

Но проблема в том, что это и есть проблема.

Придумаем свой гипотетический метод foo, и подставим на место object что-то поинтереснее, о чём вы действительно печётесь:

```python
class Money(Decimal, Phantom, predicate=true):
    @classmethod
    def parse(cls, value: Any) -> Money:
        return super().parse(Decimal(value))


class Foo:
    def foo(self, very_important_argument: Money) -> None:
        ...
```

Сделаем для пущей надёжности его абстрактным, потому как нам всюду твердят: пиши в расчёте _на интерфейсы,_ а не на конкретные классы:

```python
from abc import (
    abstractmethod,
    ABC,
)


class Foo(ABC):
    @abstractmethod
    def foo(self, very_important_argument: Money) -> None:
        ...
```

Но напишем "дефолтную реализацию" - в Python нет "просто" интерфейсов, надобно-с изъебнуться:

```python
class BaseFoo(Foo):
    def foo(self, very_important_argument: Money) -> None:
        if not very_important_argument.is_enough():
            raise FuckYou('Stupid!')
```

А теперь, реализуем конкретный метод foo, но сделаем одновременно то, [что называется "overloading"](https://google.com/search?q=oop+overloading), обязательным условием которого в нашем случае (снова - для пущей надёжности) будет вызов "родительского" метода (хотя это не обязательно):

```python
class HeartlyOursFoo(BaseFoo):
    def foo(self, very_important_argument: FiatMoney) -> None:
            ...

            dick = Money(very_important_argument)

            super().foo(dick)

            ...
```

Вопрос "а зачем это мы решили сделать overloading" для обсуждаемого топика по сути не важен. Хоть зачем! Для парсинга! Триста-тридцать-пять!

Но вот незадача! Абстрактный класс "физически написан у них", и принимает "ихний" `Money`, а нам надо засунуть в наш `HeartlyOursFoo.foo` - "наш" же, православный `FiatMoney`!

И заметим, что тут используется вроде как _тип_ `Money` (`FiatMoney`), но так как мы пишем на Python, то для нас тип - это класс. А вообще, это [не обязательно так.](google.com/search?q=type+theory)

Во-вторых, использование `Any` равноценно просто отмене дальнейшей проверки типа.

> Notice that no type checking is performed when assigning a value of type Any to a more precise type. For example, the static type checker did not report an error when assigning `a` to `s` even though `s` was declared to be of type `str` and receives an `int` value at runtime!

Ref: https://docs.python.org/3/library/typing.html#the-any-type

В данном конкретном случае, тип "потеряется" тут:

```python
    def parse(cls, value: Any) -> Money:
        return super().parse(Decimal(value))
        #                            ^^^^^ HERE
```

`mypy` откажется проверять, что value - на самом деле того типа, что принимает конструктор `Decimal`а. А у нас _задача обратная:_ указать тип на столько точно, на сколько это возможно.

А вот _наш вопрос_ будет следующий: как нам выразить то же самое ~~типами~~ классами, учитывая что мы не можем "отнаследоваться взад" - только "вперёд"?

Вот метод `.parse()` из фантомных типов - это гипертрофированный экземпляр как раз этой проблемы. Только у метода `.parse()` из phantom types должен быть настолько широкий интерфейс, на сколько это возможно, потому что для задачи парсинга ввода может потребоваться передать в метод _вообще что угодно,_ и это должно быть "номарльно".

Но при этом заметим, что реализация метода использует `object` в качестве аннотации типа, а не `Any`. Как раз затем, чтобы дать возможность тайп-чекеру всё это проверить.

```python
    def parse(cls: ..., instance: object) -> ...:
```

Ну чтож, давайте дадим. У нас только один путь: прописать "такой же" интерфейс, как у конструктора `Decimal`, его можно взять прямо из ругани `mypy` (ведь object - это "вообще всё"):

```diff
-    def parse(cls, value: Any) -> Money:
+    def parse(cls, value: object) -> Money:
```

```console
$ mypy src/funny_money.py
src/funny_money.py:76: error: Argument 1 to "Decimal" has incompatible type "object"; expected "Union[Decimal, float, str, Tuple[int, Sequence[int], int]]"
Found 1 error in 1 file (checked 1 source file)
```

```python
# Use the **Interfaces** (not "wrappers" from `typing`), Luke!
from collections.abc import Sequence


class Money2(Decimal, Phantom, predicate=true):
    @classmethod
    def parse(cls, value: Decimal | float | str | tuple[int, Sequence[int], int]) -> Money2:
        return super().parse(Decimal(value))
```

Несмотря на то, что я использовал сахарок для `Union`ов - стало ли понятнее? А главное - стоило ли оно того?

```console
$ mypy src/funny_money.py
src/funny_money.py:81: error: Argument 1 of "parse" is incompatible with supertype "PhantomBase"; supertype defines the argument type as "object"  [override]
src/funny_money.py:81: note: This violates the Liskov substitution principle
src/funny_money.py:81: note: See https://mypy.readthedocs.io/en/stable/common_issues.html#incompatible-overrides
```

Как говорил мистер Жопосранчик: "Ойо-ооой!.."

Хотели "удовлетворить тайпчекер", а получили плевок в лицо. Подождите, или мы хотели просто "правильно" типы прописать, йа запутался...

Ладно, сходим почитаем, что там по ссылке пишут:

> It’s unsafe to override a method with a more specific argument type, as it violates the Liskov substitution principle. 

Ref: https://mypy.readthedocs.io/en/stable/common_issues.html#incompatible-overrides

Так, погодите, всё-таки "overrides" или "overloading"? (Я настаиваю на втором.) Ещё и каким-то Principle сразу в лицо тычут. (А вы знали, что Liskov - это баба?!)

Сей риторический ворос оставлю вам в качестве домашнего задания.

Ладно, как блин починить это?

Спойлер: никак, из-за того что в Python тип - это класс. Наследование классов работаеть только по принциппу "уточнения". Тем самым, дочерние классы становятся "more specific", и их становится нельзя использовать для аннотации, _только если_ они не унаследованы от общего предка.

Именно это я имею в виду, когда говорю, что классы - не гибкие, плохо компонуются.

Ладно, а что всё-таки на счёт "overloading"?

> Sometimes the arguments and types in a function depend on each other in ways that can’t be captured with a `Union`.

Напомню, `Union` - это ещё вот так: `Decimal | float | str | ...`.

Так, и что?

> The `@overload` decorator allows describing functions and methods that support multiple different combinations of argument types. A series of `@overload`-decorated definitions must be followed by exactly one non-`@overload`-decorated definition (for the same function/method).

Пробуем:

```python
from typing import overload


class Money3(D, Phantom, predicate=true):
    # series of decorated definitions
    @overload
    @classmethod
    def parse(cls, value: object) -> Money3:
        ...

    @overload
    @classmethod
    def parse(cls, value: D | float | str | tuple[int, Sequence[int], int]) -> Money3:
        ...

    # single non-decorated definition
    @classmethod
    def parse(cls, value: object | D | float | str | tuple[int, Sequence[int], int]) -> Money3:
        if isinstance(value, (D, float, str, tuple)):
            return super().parse(D(value))

        return super().parse(value)
```

```console
$ mypy src/funny_money.py
src/funny_money.py:93: error: Overloaded function signature 2 will never be matched: signature 1's parameter type(s) are the same or broader  [misc]
src/funny_money.py:99: error: Argument 1 to "Decimal" has incompatible type "Decimal | float | str | tuple[Any, ...]"; expected "Decimal | float | str | tuple[int, Sequence[int], int]"  [arg-type]
Found 7 errors in 1 file (checked 1 source file)
```

Да что ж ты будешь делать, опять всё не слава богу!

А всё потому, что если _в родительском методе объявлено,_ что `value: object`, то указать _любой_ другой тип в сигнаруте тупо нельзя...

В случае с `Money` и парсингом, можно эту проблему решить, сделав "диспатч по типам" уже в рантайме, не меняя при этом сигнатуру родительского метода:

```python
class StrictMoney(D, Phantom, predicate=true):
    @classmethod
    def parse(cls, value: object) -> StrictMoney:
        if isinstance(value, str):
            return super().parse(cls._parse_str(value))

        raise TypeError(f"argument must be a string or a Decimal object, not "
                        f"{type(value)}")

    @classmethod
    def _parse_str(cls, value: str) -> D:
        return D(value)


def test_strict_money_parse_only_strings():
    with pytest.raises(TypeError):
        StrictMoney(42)

    assert StrictMoney("0.3") == D("0.3")
```

Но если подумать, наша наивная реализация поломала интерфейс родительского метода:

```python
def test_strict_money_parse_decimal():
    assert StrictMoney(D(42)) == D("42")
```

```console
$ pytest src/funny_money.py
...
E       TypeError: argument must be a string or a Decimal object, not <class 'decimal.Decimal'>
```

Благо, это очень легко починить, таки _делегировав_ выбрасывание исключения супер-классу:

```diff
-        raise TypeError(f"argument must be a string or a Decimal object, not " f"{type(value)}")
+        return super().parse(value)
```

Но _при этом,_ мы берём "только своё" - только то, в чём заинтересовыны, и делегируем основную работу отдельному методу, у которого крайне прямолинейная сигнатура:

```python
    def _parse_str(cls, value: str) -> D:
```

`str -> Decimal`, всё. Пробуем:

```console
$ git switch space
$ do/check src/
Success: no issues found in 1 source file
```

Видите? Уже и старые добрые `Union`ы справляются.

А начиная с три-восьмого Python, там ещё и [протоколы подвезли](https://habr.com/ru/articles/557898/) - становится возможным сделать совсем красиво.

## See also:

- https://www.phind.com/search?cache=r8b9iwi0vzyri7forpurn672
