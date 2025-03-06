import 'package:flutter/material.dart';

class DeleteDataPage extends StatefulWidget {
  const DeleteDataPage({super.key});

  @override
  _DeleteDataPageState createState() => _DeleteDataPageState();
}

class _DeleteDataPageState extends State<DeleteDataPage> {
  final TextEditingController _entryNumberController = TextEditingController();

  Future<void> _deleteData() async {
    final String entryNumber = _entryNumberController.text.trim();

    if (entryNumber.isNotEmpty) {
      print("In single student update field");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data deleted successfully.'),
        ),
      );

      _entryNumberController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an entry number.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _entryNumberController,
              decoration: const InputDecoration(
                labelText: 'Entry Number',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _deleteData,
              child: const Text('Delete Data'),
            ),
          ],
        ),
      ),
    );
  }
}
