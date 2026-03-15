from dataclasses import dataclass
from typing import Optional
import asyncio
import aiohttp


@dataclass
class User:
    id: int
    name: str
    email: str


class UserService:
    def __init__(self) -> None:
        self._cache: dict[int, User] = {}

    async def get_user(self, user_id: int) -> Optional[User]:
        if user_id in self._cache:
            return self._cache[user_id]

        async with aiohttp.ClientSession() as session:
            async with session.get(f"https://api.example.com/users/{user_id}") as resp:
                if resp.status != 200:
                    return None
                data = await resp.json()
                user = User(**data)
                self._cache[user_id] = user
                return user


async def main() -> None:
    svc = UserService()
    user = await svc.get_user(1)
    if user:
        print(f"Hello, {user.name}!")
    else:
        print("User not found")


if __name__ == "__main__":
    asyncio.run(main())
