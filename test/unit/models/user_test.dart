import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/user.dart';

void main() {
  group('User Model', () {
    test('should create User instance with all required fields', () {
      final createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final user = User(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: createdAt,
      );

      expect(user.id, 'user123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.createdAt, createdAt);
    });

    test('should serialize User to JSON correctly', () {
      final createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final user = User(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: createdAt,
      );

      final json = user.toJson();

      expect(json['id'], 'user123');
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('should deserialize User from JSON correctly', () {
      final createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final json = {
        'id': 'user123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'createdAt': createdAt.toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(user.id, 'user123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.createdAt, createdAt);
    });

    test('should handle JSON round-trip correctly', () {
      final createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final originalUser = User(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: createdAt,
      );

      final json = originalUser.toJson();
      final deserializedUser = User.fromJson(json);

      expect(deserializedUser, originalUser);
      expect(deserializedUser.id, originalUser.id);
      expect(deserializedUser.name, originalUser.name);
      expect(deserializedUser.email, originalUser.email);
      expect(deserializedUser.createdAt, originalUser.createdAt);
    });

    test('should correctly implement equality', () {
      final createdAt = DateTime(2024, 1, 1, 12, 0, 0);
      final user1 = User(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: createdAt,
      );
      final user2 = User(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: createdAt,
      );
      final user3 = User(
        id: 'user456',
        name: 'Jane Doe',
        email: 'jane@example.com',
        createdAt: createdAt,
      );

      expect(user1, user2);
      expect(user1 == user3, false);
    });
  });
}
