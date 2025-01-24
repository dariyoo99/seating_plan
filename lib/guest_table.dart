import 'package:hive/hive.dart';
import 'guest.dart'; // Assuming the Guest class is in guest.dart

part 'guest_table.g.dart';

@HiveType(typeId: 1)
class GuestTable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int maxGuests;

  @HiveField(2)
  final List<Guest> assignedGuests;

  GuestTable({
    required this.id,
    required this.maxGuests,
    required this.assignedGuests,
  });

  GuestTable copyWith({
    String? id,
    int? maxGuests,
    List<Guest>? assignedGuests,
  }) {
    return GuestTable(
      id: id ?? this.id,
      maxGuests: maxGuests ?? this.maxGuests,
      assignedGuests: assignedGuests ?? this.assignedGuests,
    );
  }
}
