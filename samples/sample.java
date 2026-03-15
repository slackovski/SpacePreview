import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class UserService {

    record User(int id, String name, String email) {}

    private final Map<Integer, User> cache = new HashMap<>();

    public Optional<User> getUser(int id) {
        return Optional.ofNullable(cache.computeIfAbsent(id, this::fetchFromDB));
    }

    private User fetchFromDB(int id) {
        // Simulated DB lookup
        return switch (id) {
            case 1 -> new User(1, "Alice", "alice@example.com");
            case 2 -> new User(2, "Bob", "bob@example.com");
            default -> null;
        };
    }

    public static void main(String[] args) {
        var service = new UserService();
        service.getUser(1).ifPresentOrElse(
            u -> System.out.printf("Found: %s (%s)%n", u.name(), u.email()),
            () -> System.out.println("User not found")
        );
    }
}
