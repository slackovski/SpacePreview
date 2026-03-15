use std::collections::HashMap;

#[derive(Debug, Clone)]
struct User {
    id: u32,
    name: String,
    email: String,
}

struct UserService {
    cache: HashMap<u32, User>,
}

impl UserService {
    fn new() -> Self {
        Self { cache: HashMap::new() }
    }

    fn get_user(&mut self, id: u32) -> Option<&User> {
        if !self.cache.contains_key(&id) {
            let user = self.fetch_from_db(id)?;
            self.cache.insert(id, user);
        }
        self.cache.get(&id)
    }

    fn fetch_from_db(&self, id: u32) -> Option<User> {
        match id {
            1 => Some(User { id: 1, name: "Alice".into(), email: "alice@example.com".into() }),
            2 => Some(User { id: 2, name: "Bob".into(),   email: "bob@example.com".into() }),
            _ => None,
        }
    }
}

fn main() {
    let mut svc = UserService::new();
    match svc.get_user(1) {
        Some(u) => println!("Hello, {}!", u.name),
        None    => println!("User not found"),
    }
}
