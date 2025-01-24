import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seating_plan/table_list.dart';

import 'guest.dart';
import 'guest_list.dart';
import 'guest_table.dart';

final guestListProvider =
    StateNotifierProvider<GuestListNotifier, List<Guest>>((ref) {
  return GuestListNotifier();
});

final tableListProvider =
    StateNotifierProvider<TableListNotifier, List<GuestTable>>((ref) {
  return TableListNotifier();
});

class GuestListNotifier extends StateNotifier<List<Guest>> {
  final Box _box = Hive.box('weddingPlannerBox');

  GuestListNotifier() : super([]) {
    loadGuests();
  }

  void loadGuests() {
    final List storedGuests = _box.get('guests') ?? [];
    state = storedGuests.map((name) => Guest(name: name)).toList();
  }

  void addGuest(String name) {
    state = [...state, Guest(name: name)];
    _saveGuests();
  }

  void removeGuest(Guest guest) {
    state = state.where((g) => g != guest).toList();
    _saveGuests();
  }

  void _saveGuests() {
    final guestNames = state.map((guest) => guest.name).toList();
    _box.put('guests', guestNames);
  }
}

class TableListNotifier extends StateNotifier<List<GuestTable>> {
  TableListNotifier() : super([]) {
    loadTables();
  }

  void addTable(String id, int maxGuests) {
    final newTable =
        GuestTable(id: id, maxGuests: maxGuests, assignedGuests: []);
    state = [...state, newTable];
    saveTables();
  }

  void assignGuestToTable(BuildContext context, String tableId, Guest guest) {
    // Find the table by ID
    final table = state.firstWhere((table) => table.id == tableId, orElse: () {
      throw Exception("Table not found!");
    });
    if (table.assignedGuests.length >= table.maxGuests) {
      // Show a dialog if the table is full
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Table Full'),
            content: Text(
                'The table "${table.id}" is already full. Please assign the guest to another table.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function
    }

    // Update the state only if the table is not full
    state = [
      for (final table in state)
        if (table.id == tableId)
          table.copyWith(
            assignedGuests: [...table.assignedGuests, guest],
          )
        else
          table,
    ];

    saveTables();
  }

  void removeGuestFromTable(String tableId, Guest guest) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          table.copyWith(
            assignedGuests: table.assignedGuests
                .where((g) => g.name != guest.name)
                .toList(),
          )
        else
          table,
    ];
    saveTables();
  }

  void increaseMaxGuests(String tableId) {
    state = [
      for (final table in state)
        if (table.id == tableId)
          table.copyWith(maxGuests: table.maxGuests + 1)
        else
          table,
    ];

    saveTables(); // Save the updated tables
  }

  void decreaseMaxGuests(BuildContext context, String tableId) {
    final table = state.firstWhere((t) => t.id == tableId, orElse: () {
      throw Exception("Table not found!");
    });

    if (table.assignedGuests.length >= table.maxGuests) {
      // Show a dialog if the table already has more guests than the new limit
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cannot Decrease Max Guests'),
            content: Text(
                'The table "${table.id}" already has ${table.assignedGuests.length} guests assigned. '
                'Please remove some guests before decreasing the maximum guest limit.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function
    }

    // Decrease max guests if the condition is met
    state = [
      for (final t in state)
        if (t.id == tableId) t.copyWith(maxGuests: t.maxGuests - 1) else t,
    ];

    saveTables();
  }

  void deleteTable(BuildContext context, String tableId) {
    final table = state.firstWhere((t) => t.id == tableId, orElse: () {
      throw Exception("Table not found!");
    });

    // Show confirmation dialog before deleting the table
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Table'),
          content: Text(
              'Are you sure you want to delete the table "${table.id}"? All assigned guests will be unassigned.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
                // Move assigned guests to "unassigned" and delete the table
                _deleteTableConfirmed(tableId, table.assignedGuests);
                // After deletion, pop again to go back to the main screen
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            )
          ],
        );
      },
    );
  }

  void _deleteTableConfirmed(String tableId, List<Guest> assignedGuests) {
    // Remove the table and move assigned guests to unassigned
    state = [
      for (final t in state)
        if (t.id != tableId) t,
    ];

    // Move guests to unassigned guest provider (you can adjust this logic if needed)
    for (final guest in assignedGuests) {
      removeGuestFromTable(tableId, guest);
    }

    saveTables();
  }

  Future<void> saveTables() async {
    final box = await Hive.openBox<GuestTable>('guest_tables');
    await box.clear(); // Clear previous data
    await box.addAll(state); // Add updated state
  }

  Future<void> loadTables() async {
    final box = await Hive.openBox<GuestTable>('guest_tables');
    state = box.values.toList();
  }

  Future<void> resetData() async {
    final box = await Hive.openBox<GuestTable>('guest_tables');
    await box.clear(); // Clear all tables
    state = []; // Reset state
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('weddingPlannerBox');
  Hive.registerAdapter(GuestAdapter());
  Hive.registerAdapter(GuestTableAdapter());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Planner',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the guest list and table list from providers
    final guests = ref.watch(guestListProvider);
    final tables = ref.watch(tableListProvider);

    // Calculate the number of unassigned guests
    final unassignedGuests = guests.where((guest) {
      return !tables.any(
          (table) => table.assignedGuests.any((g) => g.name == guest.name));
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEATING PLAN'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[600]!, Colors.grey[100]!, Colors.grey[600]!],
              stops: const [0.0, 0.2, 1.0], // Ensure the center is lighter
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 50,
                ),
                Text(
                  "SEATING PLANER",
                  style: TextStyle(fontSize: 24),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Display total guests and unassigned guests information
                Text(
                  'Total guests: ${guests.length}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Guests without a table: $unassignedGuests',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GuestListScreen()),
                      );
                    },
                    child: const Text('Add Guests'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TableListScreen()),
                    );
                  },
                  child: const Text('Edit Tables'),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
