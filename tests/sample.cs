using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SpacePreview.Demo;

public record User(int Id, string Name, string Email);

public interface IUserRepository
{
    Task<User?> FindByIdAsync(int id);
    Task<IReadOnlyList<User>> ListAllAsync();
}

public sealed class InMemoryUserRepository : IUserRepository
{
    private readonly Dictionary<int, User> _store = new()
    {
        [1] = new User(1, "Alice", "alice@example.com"),
        [2] = new User(2, "Bob",   "bob@example.com"),
    };

    public Task<User?> FindByIdAsync(int id) =>
        Task.FromResult(_store.GetValueOrDefault(id));

    public Task<IReadOnlyList<User>> ListAllAsync() =>
        Task.FromResult<IReadOnlyList<User>>([.. _store.Values]);
}

class Program
{
    static async Task Main()
    {
        IUserRepository repo = new InMemoryUserRepository();
        var user = await repo.FindByIdAsync(1);
        Console.WriteLine(user is not null ? $"Hello, {user.Name}!" : "Not found.");
    }
}
