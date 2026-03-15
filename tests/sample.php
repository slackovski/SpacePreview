<?php

declare(strict_types=1);

readonly class User
{
    public function __construct(
        public int    $id,
        public string $name,
        public string $email,
    ) {}
}

class UserService
{
    private array $cache = [];

    public function getUser(int $id): ?User
    {
        if (isset($this->cache[$id])) {
            return $this->cache[$id];
        }

        $data = $this->fetchFromApi($id);
        if ($data === null) return null;

        $user = new User($data['id'], $data['name'], $data['email']);
        $this->cache[$id] = $user;
        return $user;
    }

    private function fetchFromApi(int $id): ?array
    {
        $json = file_get_contents("https://api.example.com/users/{$id}");
        if ($json === false) return null;
        return json_decode($json, true);
    }
}

$service = new UserService();
$user = $service->getUser(1);
echo $user ? "Hello, {$user->name}!" : "User not found";
