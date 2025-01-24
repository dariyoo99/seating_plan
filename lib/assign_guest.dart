import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'guest_table.dart';
import 'main.dart';

class AssignGuestScreen extends HookConsumerWidget {
  final GuestTable table;

  const AssignGuestScreen({super.key, required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the tables list to update the UI when changes occur
    final tables = ref.watch(tableListProvider);
    final updatedTable = tables.firstWhere(
      (t) => t.id == table.id,
      orElse: () =>
          GuestTable(id: '', maxGuests: 0, assignedGuests: []), // Fallback
    );
    final guests = ref.watch(guestListProvider);
    final tableNotifier = ref.read(tableListProvider.notifier);

    // Filter guests: show only those without a table or those assigned to the current table
    final filteredGuests = guests.where((guest) {
      final assignedTable = tables.firstWhere(
        (t) => t.assignedGuests.any((g) => g.name == guest.name),
        orElse: () => GuestTable(id: '', maxGuests: 0, assignedGuests: []),
      );
      return assignedTable.id == '' || assignedTable.id == table.id;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add guests to ${updatedTable.id}'),
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
        actions: [
          GestureDetector(
            child: const Icon(Icons.delete, color: Colors.white,),
            onTap: () {
              tableNotifier.deleteTable(context, table.id);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredGuests.length,
          itemBuilder: (context, index) {
            final guest = filteredGuests[index];
            final isAssigned =
                updatedTable.assignedGuests.any((g) => g.name == guest.name);

            return ListTile(
              title: Text(guest.name),
              trailing: isAssigned
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, color: Colors.green),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            // Remove the guest from the table
                            tableNotifier.removeGuestFromTable(
                                updatedTable.id, guest);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        // Assign the guest to the table
                        tableNotifier.assignGuestToTable(
                            context, updatedTable.id, guest);
                      },
                      child: const Text('Add'),
                    ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Watch the updated table's maxGuests to refresh the UI
            Text("Max guests: ${updatedTable.maxGuests}"),
            Row(
              children: [
                // Decrease button with gray background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[700], // Gray background color
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    key: const Key("decrease"),
                    onPressed: () {
                      tableNotifier.decreaseMaxGuests(context, table.id);
                    },
                    icon: const Icon(Icons.remove),
                    color: Colors.white, // Icon color
                    iconSize: 30, // Icon size
                  ),
                ),
                const SizedBox(width: 10),

                // Increase button with gray background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[700], // Gray background color
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    key: const Key("increase"),
                    onPressed: () {
                      tableNotifier.increaseMaxGuests(table.id);
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.white, // Icon color
                    iconSize: 30, // Icon size
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}
