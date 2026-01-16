import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'add_event_page.dart';

class RegistrationPage extends StatelessWidget {
  final String title; // Club name

  const RegistrationPage({super.key, required this.title});

  // 🔗 Open registration link
  Future<void> openLink(String link) async {
    final uri = Uri.parse(link);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // 📅 Add to Google Calendar
  Future<void> addToGoogleCalendar({
    required String eventTitle,
    required String description,
    required DateTime startDateTime,
  }) async {
    final startUtc = startDateTime.toUtc();
    final endUtc = startUtc.add(const Duration(hours: 2));

    String format(DateTime dt) =>
        dt.toIso8601String()
            .replaceAll('-', '')
            .replaceAll(':', '')
            .split('.')
            .first +
        'Z';

    final url = Uri.parse(
      'https://www.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(eventTitle)}'
      '&details=${Uri.encodeComponent(description)}'
      '&dates=${format(startUtc)}/${format(endUtc)}',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // 🗑️ Delete event
  Future<void> deleteEvent(
    BuildContext context,
    String docId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(title)
          .collection('events')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted')),
      );
    }
  }

  // 🎫 Event Card
  Widget eventCard({
    required BuildContext context,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    final name = data['name'] ?? 'Untitled Event';
    final desc = data['description'] ?? 'No description available';
    final link = data['registrationLink'] ?? '';
    final DateTime? eventDateTime =
        data['eventDateTime'] != null
            ? (data['eventDateTime'] as Timestamp).toDate()
            : null;

    final formattedDate = eventDateTime != null
        ? DateFormat('dd MMM yyyy • hh:mm a').format(eventDateTime)
        : 'Date not available';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    TextButton(
                      onPressed:
                          link.isNotEmpty ? () => openLink(link) : null,
                      child: const Text('Register'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: eventDateTime != null
                          ? () => addToGoogleCalendar(
                                eventTitle: name,
                                description: desc,
                                startDateTime: eventDateTime,
                              )
                          : null,
                      child: const Text('Add to Calendar'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✏️ Edit icon (TOP-RIGHT)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEventPage(
                      clubName: title,
                      docId: docId,
                      existingData: data,
                    ),
                  ),
                );
              },
            ),
          ),

          // 🗑️ Delete icon (BOTTOM-RIGHT)
          Positioned(
            bottom: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteEvent(context, docId),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: const Color(0xFF6F8795),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .doc(title)
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No events yet',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: snapshot.data!.docs.map((doc) {
              return eventCard(
                context: context,
                docId: doc.id,
                data: doc.data() as Map<String, dynamic>,
              );
            }).toList(),
          );
        },
      ),

      // ➕ Add Event
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEventPage(clubName: title),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
