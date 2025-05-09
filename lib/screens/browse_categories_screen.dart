import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:the_cue/models/track.dart'; // Import Track for onSongSelected
import 'package:the_cue/screens/search_page.dart'; // Import SearchPage
import 'package:the_cue/services/spotify_service.dart';

final Logger _logger = Logger();

class BrowseCategoriesScreen extends StatefulWidget {
  final void Function(Track track, String? note) onSongSelected;

  const BrowseCategoriesScreen({super.key, required this.onSongSelected});

  @override
  State<BrowseCategoriesScreen> createState() => _BrowseCategoriesScreenState();
}

class _BrowseCategoriesScreenState extends State<BrowseCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;
  String? _userCountry;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _userCountry = await SpotifyService.getUserCountry();
      final categories = await SpotifyService.getBrowseCategories(
          country: _userCountry, limit: 50); // Fetch up to 50 categories
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching browse categories: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load categories. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('Browse Categories',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF161616),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
    if (_categories.isEmpty) {
      return const Center(
          child: Text('No categories found.',
              style: TextStyle(color: Colors.white70, fontSize: 16)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2, // Adjust aspect ratio as needed
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final String categoryName = category['name'] ?? 'Unknown Category';
        final String categoryId = category['id'] ?? '';
        String? imageUrl;
        if (category['icons'] != null &&
            (category['icons'] as List).isNotEmpty) {
          imageUrl = category['icons'][0]['url'];
        }

        return GestureDetector(
          onTap: () {
            if (categoryName.isNotEmpty) {
              // Navigate with category name as search query
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    onSongSelected: widget.onSongSelected, // Pass the callback
                    initialQuery: categoryName,
                    // event: null, // Assuming discovery is not tied to a specific event
                  ),
                ),
              );
            } else {
              _logger.w('Category name is empty, cannot navigate to search.');
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot open this category.')));
            }
          },
          child: Card(
            color: Colors.grey[850],
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                if (imageUrl != null)
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                              child: Icon(Icons.category,
                                  color: Colors.white54, size: 40)),
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
