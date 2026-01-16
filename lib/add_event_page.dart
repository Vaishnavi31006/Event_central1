import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  final String clubName;

  // 🔹 NEW (for edit mode)
  final String? docId; // null = add, not null = edit
  final Map<String, dynamic>? existingData;

  const AddEventPage({
    super.key,
    required this.clubName,
    this.docId,
    this.existingData,
  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  DateTime? _eventDateTime;
  bool _loading = false;

  // 🔹 Prefill fields if editing
  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      _nameCtrl.text = widget.existingData!['name'] ?? '';
      _descCtrl.text = widget.existingData!['description'] ?? '';
      _linkCtrl.text = widget.existingData!['registrationLink'] ?? '';

      if (widget.existingData!['eventDateTime'] != null) {
        _eventDateTime =
            (widget.existingData!['eventDateTime'] as Timestamp).toDate();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _eventDateTime ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _eventDateTime != null
          ? TimeOfDay.fromDateTime(_eventDateTime!)
          : TimeOfDay(hour: now.hour, minute: now.minute),
    );
    if (time == null) return;

    setState(() {
      _eventDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in')),
      );
      return;
    }

    if (_eventDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick event date & time')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final ref = FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.clubName)
          .collection('events');

      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'registrationLink': _linkCtrl.text.trim(),
        'eventDateTime': Timestamp.fromDate(_eventDateTime!),
      };

      if (widget.docId == null) {
        // ➕ ADD MODE
        await ref.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          //'createdBy': user.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event added')),
        );
      } else {
        // ✏️ EDIT MODE
        await ref.doc(widget.docId).update(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated')),
        );
      }

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.message ?? e.code}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _eventDateTime == null
        ? 'Pick date & time'
        : DateFormat('dd MMM yyyy • hh:mm a').format(_eventDateTime!);

    final isEdit = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Edit event — ${widget.clubName}'
              : 'Add event — ${widget.clubName}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Event name'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _linkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Registration link (https://...)',
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(dateLabel),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDateTime,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Update Event' : 'Add Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
