import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database_service.dart';
import '../notification_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final TextEditingController _recordController = TextEditingController();
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _chicksController = TextEditingController();
  final TextEditingController _deadController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  Map<String, dynamic> _userStats = {
    'totalChicks': 0,
    'totalDead': 0,
  };
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  void _loadUserStats() async {
    final stats = await _databaseService.getUserStats();
    if (stats != null) {
      setState(() {
        _userStats = stats;
      });
    }
  }

  void _addOrEditRecord() async {
    if (_recordController.text.trim().isNotEmpty) {
      await _databaseService.addRecord({
        'type': 'record',
        'content': _recordController.text.trim(),
      });
      _recordController.clear();
      _loadUserStats();
    }
  }

  void _addChicks() async {
    final String input = _chicksController.text.trim();
    final int count = int.tryParse(input) ?? 0;
    if (count <= 0) return;

    await _databaseService.addRecord({
      'type': 'chicks_added',
      'content': 'Added $count chicks',
      'chicks': count,
      'dead': 0,
    });

    _chicksController.clear();
    _loadUserStats();
  }

  void _registerDeath() async {
    final String input = _deadController.text.trim();
    final int count = int.tryParse(input) ?? 0;
    if (count <= 0) return;

    await _databaseService.addRecord({
      'type': 'death_registered',
      'content': 'Registered $count deaths',
      'chicks': 0,
      'dead': count,
    });

    _deadController.clear();
    _loadUserStats();
  }

  void _deleteRecord(String recordId) async {
    await _databaseService.deleteRecord(recordId);
    _loadUserStats();
  }

  Future<void> _pickDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 1))),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addEvent() async {
    if (_eventController.text.trim().isNotEmpty) {
      final String eventTitle = _eventController.text.trim();

      // Fallback: schedule 1 minute from now if user didn't pick a time
      final DateTime scheduled = _selectedDateTime ??
          DateTime.now().add(const Duration(minutes: 1));

      final event = {
        'title': eventTitle,
        'scheduledAt': Timestamp.fromDate(scheduled),
      };

      await _databaseService.addEvent(event);

      await NotificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: eventTitle,
        body: 'Reminder: $eventTitle',
        scheduledDate: scheduled,
      );

      _eventController.clear();
      setState(() {
        _selectedDateTime = null;
      });
    }
  }

  void _deleteEvent(String eventId) async {
    await _databaseService.deleteEvent(eventId);
  }

  @override
  Widget build(BuildContext context) {
    final totalChicks = _userStats['totalChicks'] ?? 0;
    final totalDead = _userStats['totalDead'] ?? 0;
    final liveChicks = totalChicks - totalDead;
    final livePercent =
        totalChicks > 0 ? (liveChicks / totalChicks) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders & Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dashboard Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chick Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _CircleProgressBar(
                            percentage: livePercent,
                            total: totalChicks,
                            live: liveChicks,
                            dead: totalDead,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatItem(
                                  'Total Chicks', totalChicks, Colors.blue),
                              const SizedBox(height: 8),
                              _StatItem(
                                  'Live Chicks', liveChicks, Colors.green),
                              const SizedBox(height: 8),
                              _StatItem('Deceased', totalDead, Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chick Management Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chick Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chicksController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Add chicks count',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addChicks,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _deadController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Register deaths',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _registerDeath,
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Records Section
            const Text(
              'Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recordController,
                    decoration: const InputDecoration(
                      labelText: 'Add record',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addOrEditRecord,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getRecordsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No records yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var record = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(record['content'] ?? ''),
                          subtitle: record['createdAt'] != null
                              ? Text(_formatTimestamp(record['createdAt']))
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteRecord(doc.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Events Section
            const Text(
              'Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _eventController,
                    decoration: const InputDecoration(
                      labelText: 'Event title/message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: Text(_selectedDateTime == null
                      ? 'Pick time'
                      : 'Change time'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addEvent,
                  child: const Text('Set'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedDateTime == null
                    ? 'No time selected (defaults to +1 min)'
                    : 'Scheduled: '
                        '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} '
                        '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getEventsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No events yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var event = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(event['title'] ?? ''),
                          subtitle: event['createdAt'] != null
                              ? Text(_formatTimestamp(event['createdAt']))
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteEvent(doc.id),
                          ),
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    }
    return 'Unknown date';
  }
}

class _CircleProgressBar extends StatelessWidget {
  final double percentage;
  final int total;
  final int live;
  final int dead;

  const _CircleProgressBar({
    required this.percentage,
    required this.total,
    required this.live,
    required this.dead,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 50 ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }
}
