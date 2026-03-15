interface User {
  id: number;
  name: string;
  email: string;
  createdAt: Date;
}

type Role = "admin" | "editor" | "viewer";

async function fetchUser(id: number): Promise<User | null> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) return null;
  return res.json() as Promise<User>;
}

class UserService {
  private cache = new Map<number, User>();

  async getUser(id: number): Promise<User | null> {
    if (this.cache.has(id)) return this.cache.get(id)!;
    const user = await fetchUser(id);
    if (user) this.cache.set(id, user);
    return user;
  }
}

export { UserService, type User, type Role };
