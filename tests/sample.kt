data class User(val id: Int, val name: String, val email: String)

sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
}

class UserRepository {
    private val db = mapOf(
        1 to User(1, "Alice", "alice@example.com"),
        2 to User(2, "Bob", "bob@example.com"),
    )

    fun findById(id: Int): Result<User> =
        db[id]?.let { Result.Success(it) }
            ?: Result.Error("User $id not found")
}

fun main() {
    val repo = UserRepository()
    when (val result = repo.findById(1)) {
        is Result.Success -> println("Hello, ${result.data.name}!")
        is Result.Error   -> println("Error: ${result.message}")
    }
}
