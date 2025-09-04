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

  // Records moved to RecordsPage

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
      DateTime scheduled =
          _selectedDateTime ?? DateTime.now().add(const Duration(minutes: 1));

      // Ensure the scheduled time is in the future (grace: 5 seconds)
      final DateTime now = DateTime.now();
      if (!scheduled.isAfter(now.add(const Duration(seconds: 5)))) {
        scheduled = now.add(const Duration(minutes: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Selected time was in the past. Scheduled for +1 minute.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      final event = {
        'title': eventTitle,
        'scheduledAt': Timestamp.fromDate(scheduled),
        'createdAt': Timestamp.fromDate(DateTime.now()),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.shade600,
                      Colors.teal.shade400,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dashboard,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dashboard & Reminders',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Manage your farm efficiently',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dashboard Section (redesigned)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              color: Colors.teal.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chick Statistics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double ringSize =
                                constraints.maxWidth > 420 ? 160 : 120;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: ringSize + 20,
                                  child: _CircleProgressBar(
                                    percentage: livePercent,
                                    total: totalChicks,
                                    live: liveChicks,
                                    dead: totalDead,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _StatTile(
                                        label: 'Total Chicks',
                                        value: totalChicks,
                                        color: Colors.blue,
                                        icon: Icons.pets,
                                      ),
                                      _StatTile(
                                        label: 'Live Chicks',
                                        value: liveChicks,
                                        color: Colors.green,
                                        icon: Icons.favorite,
                                      ),
                                      _StatTile(
                                        label: 'Deceased',
                                        value: totalDead,
                                        color: Colors.red,
                                        icon: Icons.remove_circle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Chick Management Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.pets_outlined,
                              color: Colors.teal.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chick Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chicksController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Add chicks count',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _addChicks,
                              icon: const Icon(Icons.add),
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _deadController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Register deaths',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _registerDeath,
                              icon: const Icon(Icons.remove),
                              label: const Text('Register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Records moved to its own tab

              const SizedBox(height: 20),

              // Events Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event_outlined,
                              color: Colors.teal.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Events & Reminders',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _eventController,
                                decoration: InputDecoration(
                                  labelText: 'Event title/message',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _pickDateTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(_selectedDateTime == null
                                  ? 'Pick time'
                                  : 'Change'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _addEvent,
                              icon: const Icon(Icons.add_alarm),
                              label: const Text('Set'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _selectedDateTime == null
                                ? 'No time selected (defaults to +1 min)'
                                : 'Scheduled: '
                                    '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} '
                                    '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _databaseService.getEventsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Something went wrong'));
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_available_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No events yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var doc = snapshot.data!.docs[index];
                                  var event =
                                      doc.data() as Map<String, dynamic>;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.event,
                                            color: Colors.orange.shade600,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event['title'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (event['scheduledAt'] != null)
                                                Text(
                                                  'When: ' +
                                                      _formatTimestamp(
                                                          event['scheduledAt']),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red.shade400,
                                          ),
                                          onPressed: () => _deleteEvent(doc.id),
                                        ),
                                      ],
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
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
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
    final double baseSize = 140;
    return SizedBox(
      width: baseSize,
      height: baseSize,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: baseSize - 24,
              height: baseSize - 24,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage >= 70
                      ? Colors.green
                      : percentage >= 40
                          ? Colors.orange
                          : Colors.red,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 13,
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

// Removed unused _StatItem widget to clear lints.

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
