import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();
  final List<String> imageUrls = [
    'assets/img1.jpg',
    'assets/img2.jpg',
    'assets/img3.jpg',
  ];

  final List<Map<String, String>> categories = [
    {'title': 'Feed Info', 'icon': '🐓'},
    {'title': 'Vaccination', 'icon': '💉'},
    {'title': 'Diseases', 'icon': '🧬'},
    {'title': 'Products', 'icon': '📦'},
  ];

  void _navigateToCategory(BuildContext context, String title) {
    Widget page;
    switch (title) {
      case 'Feed Info':
        page = const FeedInfoPage();
        break;
      case 'Vaccination':
        page = const VaccinationPage();
        break;
      case 'Diseases':
        page = const DiseasesPage();
        break;
      case 'Products':
        page = const ProductsPage();
        break;
      default:
        page = const Placeholder();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poultry Care'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 180.0,
                showIndicator: true,
                slideIndicator: CircularSlideIndicator(),
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: imageUrls.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: const BoxDecoration(color: Colors.amber),
                      child: Image.asset(url, fit: BoxFit.cover),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Welcome to Poultry Care!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Dashboard Statistics
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _databaseService.getUserStats(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final stats = snapshot.data ?? {};
                          final totalChicks = stats['totalChicks'] ?? 0;
                          final totalDead = stats['totalDead'] ?? 0;
                          final liveChicks = totalChicks - totalDead;

                          return Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  'Total Chicks',
                                  totalChicks.toString(),
                                  Icons.pets,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  'Live Chicks',
                                  liveChicks.toString(),
                                  Icons.favorite,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  'Deceased',
                                  totalDead.toString(),
                                  Icons.remove_circle,
                                  Colors.red,
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

            const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                'Featured Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 120,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _databaseService.getDashboardSummary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final summary = snapshot.data ?? {};

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories.map((cat) {
                      String count = '0';
                      String subtitle = 'No data';

                      switch (cat['title']) {
                        case 'Feed Info':
                          count = (summary['feedInfoCount'] ?? 0).toString();
                          if (summary['latestFeedInfo'] != null) {
                            subtitle = summary['latestFeedInfo']['title'] ??
                                'Latest info';
                          }
                          break;
                        case 'Vaccination':
                          count =
                              (summary['vaccinationsCount'] ?? 0).toString();
                          if (summary['latestVaccination'] != null) {
                            subtitle = summary['latestVaccination']['name'] ??
                                'Latest vaccine';
                          }
                          break;
                        case 'Diseases':
                          count = (summary['diseasesCount'] ?? 0).toString();
                          if (summary['latestDisease'] != null) {
                            subtitle = summary['latestDisease']['name'] ??
                                'Latest disease';
                          }
                          break;
                        case 'Products':
                          count = (summary['productsCount'] ?? 0).toString();
                          if (summary['latestProduct'] != null) {
                            subtitle = summary['latestProduct']['name'] ??
                                'Latest product';
                          }
                          break;
                      }

                      return GestureDetector(
                        onTap: () =>
                            _navigateToCategory(context, cat['title']!),
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.teal.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cat['icon']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                cat['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Count: $count',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Recent Activity
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: _databaseService.getRecordsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error loading recent activity');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Text('No recent activity');
                          }

                          // Show only the latest 3 records
                          final recentDocs = docs.take(3).toList();

                          return Column(
                            children: recentDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return ListTile(
                                leading: const Icon(Icons.record_voice_over),
                                title: Text(data['content'] ?? ''),
                                subtitle: data['createdAt'] != null
                                    ? Text(_formatTimestamp(data['createdAt']))
                                    : null,
                                dense: true,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoreOptionsPage()),
                  );
                },
                child: const Text('More Options'),
              ),
            ),

            const SizedBox(height: 20),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FeedInfoPage extends StatelessWidget {
  const FeedInfoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _FeedInfoPageContent();
  }
}

class _FeedInfoPageContent extends StatefulWidget {
  const _FeedInfoPageContent();

  @override
  State<_FeedInfoPageContent> createState() => _FeedInfoPageContentState();
}

class _FeedInfoPageContentState extends State<_FeedInfoPageContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  String? _editingId;

  void _addOrEditFeedInfo() async {
    if (_titleController.text.trim().isNotEmpty) {
      final feedInfo = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'schedule': _scheduleController.text.trim(),
      };

      if (_editingId != null) {
        await _databaseService.updateFeedInfo(_editingId!, feedInfo);
        _editingId = null;
      } else {
        await _databaseService.addFeedInfo(feedInfo);
      }

      _clearForm();
    }
  }

  void _editFeedInfo(String id, Map<String, dynamic> data) {
    setState(() {
      _editingId = id;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _quantityController.text = data['quantity'] ?? '';
      _scheduleController.text = data['schedule'] ?? '';
    });
  }

  void _deleteFeedInfo(String id) async {
    await _databaseService.deleteFeedInfo(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _titleController.clear();
      _descriptionController.clear();
      _quantityController.clear();
      _scheduleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Info'),
        actions: [
          if (_editingId != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearForm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingId != null
                          ? 'Edit Feed Info'
                          : 'Add New Feed Info',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Feed Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _scheduleController,
                            decoration: const InputDecoration(
                              labelText: 'Schedule',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addOrEditFeedInfo,
                        child: Text(_editingId != null ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getFeedInfoStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No feed info yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var feedInfo = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(feedInfo['title'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (feedInfo['description']?.isNotEmpty == true)
                                Text(feedInfo['description']),
                              if (feedInfo['quantity']?.isNotEmpty == true)
                                Text('Quantity: ${feedInfo['quantity']}'),
                              if (feedInfo['schedule']?.isNotEmpty == true)
                                Text('Schedule: ${feedInfo['schedule']}'),
                              if (feedInfo['createdAt'] != null)
                                Text(
                                  _formatTimestamp(feedInfo['createdAt']),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _editFeedInfo(doc.id, feedInfo),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteFeedInfo(doc.id),
                              ),
                            ],
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

class VaccinationPage extends StatelessWidget {
  const VaccinationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _VaccinationPageContent();
  }
}

class _VaccinationPageContent extends StatefulWidget {
  const _VaccinationPageContent();

  @override
  State<_VaccinationPageContent> createState() =>
      _VaccinationPageContentState();
}

class _VaccinationPageContentState extends State<_VaccinationPageContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  String? _editingId;

  void _addOrEditVaccination() async {
    if (_nameController.text.trim().isNotEmpty) {
      final vaccination = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'schedule': _scheduleController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      if (_editingId != null) {
        await _databaseService.updateVaccination(_editingId!, vaccination);
        _editingId = null;
      } else {
        await _databaseService.addVaccination(vaccination);
      }

      _clearForm();
    }
  }

  void _editVaccination(String id, Map<String, dynamic> data) {
    setState(() {
      _editingId = id;
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _scheduleController.text = data['schedule'] ?? '';
      _notesController.text = data['notes'] ?? '';
    });
  }

  void _deleteVaccination(String id) async {
    await _databaseService.deleteVaccination(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _descriptionController.clear();
      _scheduleController.clear();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination'),
        actions: [
          if (_editingId != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearForm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingId != null
                          ? 'Edit Vaccination'
                          : 'Add New Vaccination',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Vaccine Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _scheduleController,
                            decoration: const InputDecoration(
                              labelText: 'Schedule',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addOrEditVaccination,
                        child: Text(_editingId != null ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getVaccinationsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No vaccinations yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var vaccination = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(vaccination['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (vaccination['description']?.isNotEmpty ==
                                  true)
                                Text(vaccination['description']),
                              if (vaccination['schedule']?.isNotEmpty == true)
                                Text('Schedule: ${vaccination['schedule']}'),
                              if (vaccination['notes']?.isNotEmpty == true)
                                Text('Notes: ${vaccination['notes']}'),
                              if (vaccination['createdAt'] != null)
                                Text(
                                  _formatTimestamp(vaccination['createdAt']),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _editVaccination(doc.id, vaccination),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteVaccination(doc.id),
                              ),
                            ],
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

class DiseasesPage extends StatelessWidget {
  const DiseasesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _DiseasesPageContent();
  }
}

class _DiseasesPageContent extends StatefulWidget {
  const _DiseasesPageContent();

  @override
  State<_DiseasesPageContent> createState() => _DiseasesPageContentState();
}

class _DiseasesPageContentState extends State<_DiseasesPageContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _preventionController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  String? _editingId;

  void _addOrEditDisease() async {
    if (_nameController.text.trim().isNotEmpty) {
      final disease = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'symptoms': _symptomsController.text.trim(),
        'prevention': _preventionController.text.trim(),
        'treatment': _treatmentController.text.trim(),
      };

      if (_editingId != null) {
        await _databaseService.updateDisease(_editingId!, disease);
        _editingId = null;
      } else {
        await _databaseService.addDisease(disease);
      }

      _clearForm();
    }
  }

  void _editDisease(String id, Map<String, dynamic> data) {
    setState(() {
      _editingId = id;
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _symptomsController.text = data['symptoms'] ?? '';
      _preventionController.text = data['prevention'] ?? '';
      _treatmentController.text = data['treatment'] ?? '';
    });
  }

  void _deleteDisease(String id) async {
    await _databaseService.deleteDisease(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _descriptionController.clear();
      _symptomsController.clear();
      _preventionController.clear();
      _treatmentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseases'),
        actions: [
          if (_editingId != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearForm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingId != null ? 'Edit Disease' : 'Add New Disease',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Disease Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _symptomsController,
                      decoration: const InputDecoration(
                        labelText: 'Symptoms',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _preventionController,
                            decoration: const InputDecoration(
                              labelText: 'Prevention',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _treatmentController,
                            decoration: const InputDecoration(
                              labelText: 'Treatment',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addOrEditDisease,
                        child: Text(_editingId != null ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getDiseasesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No diseases recorded yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var disease = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(disease['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (disease['description']?.isNotEmpty == true)
                                Text(disease['description']),
                              if (disease['symptoms']?.isNotEmpty == true)
                                Text('Symptoms: ${disease['symptoms']}'),
                              if (disease['prevention']?.isNotEmpty == true)
                                Text('Prevention: ${disease['prevention']}'),
                              if (disease['treatment']?.isNotEmpty == true)
                                Text('Treatment: ${disease['treatment']}'),
                              if (disease['createdAt'] != null)
                                Text(
                                  _formatTimestamp(disease['createdAt']),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editDisease(doc.id, disease),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteDisease(doc.id),
                              ),
                            ],
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

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _ProductsPageContent();
  }
}

class _ProductsPageContent extends StatefulWidget {
  const _ProductsPageContent();

  @override
  State<_ProductsPageContent> createState() => _ProductsPageContentState();
}

class _ProductsPageContentState extends State<_ProductsPageContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  String? _editingId;

  void _addOrEditProduct() async {
    if (_nameController.text.trim().isNotEmpty) {
      final product = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'price': _priceController.text.trim(),
        'supplier': _supplierController.text.trim(),
      };

      if (_editingId != null) {
        await _databaseService.updateProduct(_editingId!, product);
        _editingId = null;
      } else {
        await _databaseService.addProduct(product);
      }

      _clearForm();
    }
  }

  void _editProduct(String id, Map<String, dynamic> data) {
    setState(() {
      _editingId = id;
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _categoryController.text = data['category'] ?? '';
      _priceController.text = data['price'] ?? '';
      _supplierController.text = data['supplier'] ?? '';
    });
  }

  void _deleteProduct(String id) async {
    await _databaseService.deleteProduct(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _descriptionController.clear();
      _categoryController.clear();
      _priceController.clear();
      _supplierController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (_editingId != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearForm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingId != null ? 'Edit Product' : 'Add New Product',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _supplierController,
                      decoration: const InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addOrEditProduct,
                        child: Text(_editingId != null ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No products recorded yet'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var product = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(product['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product['description']?.isNotEmpty == true)
                                Text(product['description']),
                              if (product['category']?.isNotEmpty == true)
                                Text('Category: ${product['category']}'),
                              if (product['price']?.isNotEmpty == true)
                                Text('Price: ${product['price']}'),
                              if (product['supplier']?.isNotEmpty == true)
                                Text('Supplier: ${product['supplier']}'),
                              if (product['createdAt'] != null)
                                Text(
                                  _formatTimestamp(product['createdAt']),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editProduct(doc.id, product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteProduct(doc.id),
                              ),
                            ],
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

class MoreOptionsPage extends StatelessWidget {
  const MoreOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More Options')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
          ListTile(leading: Icon(Icons.info), title: Text('About')),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}
