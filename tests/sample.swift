import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

actor UserCache {
    private var store: [Int: User] = [:]

    func get(_ id: Int) -> User? { store[id] }
    func set(_ id: Int, user: User) { store[id] = user }
}

final class UserService {
    private let cache = UserCache()
    private let baseURL = URL(string: "https://api.example.com")!

    func fetchUser(id: Int) async throws -> User {
        if let cached = await cache.get(id) { return cached }

        let url = baseURL.appendingPathComponent("users/\(id)")
        let (data, _) = try await URLSession.shared.data(from: url)
        let user = try JSONDecoder().decode(User.self, from: data)
        await cache.set(id, user: user)
        return user
    }
}

// Entry point
let service = UserService()
Task {
    let user = try await service.fetchUser(id: 1)
    print("Hello, \(user.name)!")
}
