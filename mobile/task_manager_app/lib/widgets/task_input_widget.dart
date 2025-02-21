import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskInputWidget extends StatefulWidget {
  final Function(String title, String description, DateTime date) onTaskAdded;

  TaskInputWidget({required this.onTaskAdded});

  @override
  _TaskInputWidgetState createState() => _TaskInputWidgetState();
}

class _TaskInputWidgetState extends State<TaskInputWidget> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  /// 📌 Tarih seçici aç
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(
              labelText: "New Task",
              prefixIcon: Icon(Icons.task),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: "Task Description (Optional)",
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 10),

          /// 📌 Tarih Seçme Butonu
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: "Select Date",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _selectedDate != null
                    ? DateFormat.yMMMMd().format(_selectedDate!) // 📌 Telefonun tarih formatına uyar
                    : "Tap to select date",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                widget.onTaskAdded(
                  _taskController.text,
                  _descriptionController.text.isNotEmpty ? _descriptionController.text : "",
                  _selectedDate ?? DateTime.now(), // 📌 Eğer tarih seçilmezse, bugünün tarihi
                );
                _taskController.clear();
                _descriptionController.clear();
                setState(() {
                  _selectedDate = null;
                });
              }
            },
            child: const Text("Add Task"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }
}
