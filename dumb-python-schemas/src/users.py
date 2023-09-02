from typing import TypedDict

import attrs
import pendulum
from cattrs import Converter
from phantom.datetime import TZAware

EmailAddress = str


@attrs.define
class Permission:
    description: str


@attrs.define
class User:
    id: int
    member_since: TZAware
    full_name: str
    email: EmailAddress
    permissions: tuple[Permission, ...]


class UserSchema(TypedDict):
    id: int
    member_since: TZAware
    full_name: str
    email: EmailAddress


me = User(
    id=42,
    member_since=pendulum.now(),
    full_name="Anthony",
    email="anthony@example.com",
    permissions=(
        Permission("read_users"),
        Permission("manage_users"),
    ),
)

c = Converter()
data = c.unstructure(me, UserSchema)

# {'id': 42,
#  'member_since': DateTime(..., tzinfo=timezone.utc),
#  'full_name': 'Anthony',
#  'email': 'anthony@example.com'}
