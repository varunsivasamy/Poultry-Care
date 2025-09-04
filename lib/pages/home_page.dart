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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icons.pets,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Manage your poultry farm efficiently',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
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

              // Image Carousel
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterCarousel(
                    options: FlutterCarouselOptions(
                      height: 200.0,
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
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Image.asset(url, fit: BoxFit.cover),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dashboard Statistics (redesigned)
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
                              'Quick Statistics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _QuickStatTile(
                                  title: 'Total Chicks',
                                  value: totalChicks,
                                  color: Colors.blue,
                                  icon: Icons.pets,
                                ),
                                _QuickStatTile(
                                  title: 'Live Chicks',
                                  value: liveChicks,
                                  color: Colors.green,
                                  icon: Icons.favorite,
                                ),
                                _QuickStatTile(
                                  title: 'Deceased',
                                  value: totalDead,
                                  color: Colors.red,
                                  icon: Icons.remove_circle,
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

              const SizedBox(height: 24),

              // Featured Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: Colors.teal.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Featured Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 170,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _databaseService.getDashboardSummary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final summary = snapshot.data ?? {};

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            width: 130,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.teal.shade50,
                                  Colors.teal.shade100,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.teal.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cat['icon']!,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat['title']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      count,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 20),

              // Recent Activity
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
                              Icons.history,
                              color: Colors.teal.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: _databaseService.getRecordsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text(
                                  'Error loading recent activity');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final docs = snapshot.data?.docs ?? [];
                            if (docs.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No recent activity',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Show only the latest 3 records
                            final recentDocs = docs.take(3).toList();

                            return Column(
                              children: recentDocs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                // Get appropriate icon and color based on activity type
                                IconData activityIcon = Icons.record_voice_over;
                                Color activityColor = Colors.teal.shade600;

                                switch (data['type']) {
                                  case 'note':
                                    activityIcon = Icons.note_alt;
                                    activityColor = Colors.blue.shade600;
                                    break;
                                  case 'event':
                                    activityIcon = Icons.event;
                                    activityColor = Colors.orange.shade600;
                                    break;
                                  case 'disease':
                                    activityIcon = Icons.medical_services;
                                    activityColor = Colors.red.shade600;
                                    break;
                                  case 'vaccination':
                                    activityIcon = Icons.vaccines;
                                    activityColor = Colors.green.shade600;
                                    break;
                                  case 'product':
                                    activityIcon = Icons.inventory;
                                    activityColor = Colors.purple.shade600;
                                    break;
                                  case 'feed_info':
                                    activityIcon = Icons.restaurant;
                                    activityColor = Colors.brown.shade600;
                                    break;
                                  case 'chicks_added':
                                    activityIcon = Icons.pets;
                                    activityColor = Colors.green.shade600;
                                    break;
                                  case 'death_registered':
                                    activityIcon = Icons.remove_circle;
                                    activityColor = Colors.red.shade600;
                                    break;
                                  default:
                                    activityIcon = Icons.record_voice_over;
                                    activityColor = Colors.teal.shade600;
                                }

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
                                          color: activityColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          activityIcon,
                                          color: activityColor,
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
                                              data['content'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (data['createdAt'] != null)
                                              Text(
                                                _formatTimestamp(
                                                    data['createdAt']),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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

              const SizedBox(height: 24),

              // More Options Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MoreOptionsPage()),
                      );
                    },
                    icon: const Icon(Icons.more_horiz),
                    label: const Text('More Options'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const _QuickStatTile({
    required this.title,
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
            title,
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
