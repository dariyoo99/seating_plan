import 'package:hive/hive.dart';

// Generated
part 'guest.g.dart';

@HiveType(typeId: 0)
class Guest {
  @HiveField(0)
  final String name;

  Guest({required this.name});
}
