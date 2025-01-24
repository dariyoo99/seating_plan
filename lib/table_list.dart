import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'assign_guest.dart';
import 'main.dart';

class TableListScreen extends HookConsumerWidget {
  const TableListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a TextEditingController to get the input value
    final TextEditingController tableController = TextEditingController();
    final tables = ref.watch(tableListProvider);
    ref.watch(guestListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tableController,
              decoration: const InputDecoration(
                labelText: 'Table Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final tableName = tableController.text;
                if (tableName.isNotEmpty) {
                  // Check if a table with the same name already exists
                  bool tableExists = tables.any((table) => table.id == tableName);

                  if (tableExists) {
                    // Show a dialog if the table name already exists
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('A table with this name already exists.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Add the table if the name doesn't exist
                    ref.read(tableListProvider.notifier).addTable(tableName, 10);
                    tableController.clear(); // Clear the text field
                  }
                }
              },
              child: const Text('Confirm'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final table = tables[index];
                  return ListTile(
                    title: Text(
                        'Table: ${table.id} (${table.assignedGuests.length}/${table.maxGuests})'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AssignGuestScreen(table: table),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
