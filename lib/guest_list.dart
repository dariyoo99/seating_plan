import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'main.dart';

class GuestListScreen extends HookConsumerWidget {
  const GuestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a TextEditingController to get the input value
    final TextEditingController guestController = TextEditingController();
    final guests = ref.watch(guestListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guests'),
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
              controller: guestController,
              decoration: const InputDecoration(
                labelText: 'Guest Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add the guest if the field is not empty and guest doesn't already exist
                final guestName = guestController.text.trim();
                final guests = ref.read(guestListProvider);

                if (guestName.isNotEmpty && !guests.any((guest) => guest.name.toLowerCase() == guestName.toLowerCase())) {
                  ref.read(guestListProvider.notifier).addGuest(guestName);
                  // Clear the text field after adding the guest
                  guestController.clear();
                } else if (guests.any((guest) => guest.name.toLowerCase() == guestName.toLowerCase())) {
                  // Show a dialog if the guest already exists
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('A guest with this name already exists.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Confirm Guest'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: guests.length,
                itemBuilder: (context, index) {
                  final guest = guests[index];
                  return ListTile(
                    title: Text(guest.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(guestListProvider.notifier).removeGuest(guest);
                      },
                    ),
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
