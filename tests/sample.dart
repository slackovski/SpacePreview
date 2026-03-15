import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  @override
  String toString() => 'User(id: $id, name: $name)';
}

class UserService {
  final String _baseUrl;
  final _cache = <int, User>{};

  UserService(this._baseUrl);

  Future<User?> getUser(int id) async {
    if (_cache.containsKey(id)) return _cache[id];

    final uri = Uri.parse('$_baseUrl/users/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;

    final user = User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    _cache[id] = user;
    return user;
  }
}

void main() async {
  final svc = UserService('https://api.example.com');
  final user = await svc.getUser(1);
  print(user != null ? 'Hello, ${user.name}!' : 'User not found');
}
