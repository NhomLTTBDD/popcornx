import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/app_bar.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _ratingController = TextEditingController();
  final _viewsController = TextEditingController();
  final _revenueController = TextEditingController();
  final _bookingRateController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedGenre = 'Action';
  String _selectedRating = 'PG-13';
  String _selectedSentiment = 'positive';

  final List<String> _genres = [
    'Action',
    'Comedy',
    'Drama',
    'Sci-Fi',
    'Fantasy',
    'Thriller',
    'Romance',
    'Horror',
  ];

  final List<String> _ratings = ['G', 'PG', 'PG-13', 'R', 'NC-17'];
  final List<String> _sentiments = ['positive', 'negative', 'mixed'];

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _ratingController.dispose();
    _viewsController.dispose();
    _revenueController.dispose();
    _bookingRateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save to a database or API
      final movieData = {
        'title': _titleController.text,
        'genre': _selectedGenre,
        'rating': _selectedRating,
        'views': int.tryParse(_viewsController.text) ?? 0,
        'revenue': int.tryParse(_revenueController.text) ?? 0,
        'bookingRate': double.tryParse(_bookingRateController.text) ?? 0.0,
        'sentiment': _selectedSentiment,
        'description': _descriptionController.text,
      };

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Movie "${movieData['title']}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _viewsController.clear();
      _revenueController.clear();
      _bookingRateController.clear();
      setState(() {
        _selectedGenre = 'Action';
        _selectedRating = 'PG-13';
        _selectedSentiment = 'positive';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show on web
    if (!kIsWeb) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Admin',
          variant: CustomAppBarVariant.detail,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.computer, size: 64, color: Colors.grey),
              SizedBox(height: 2.h),
              Text(
                'Admin page is only available on web',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Admin - Add Movie',
        leading: null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Add New Movie',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Fill in the details below to add a new movie to the platform',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 4.h),

              // Form Fields
              _buildTextField(
                context,
                theme,
                'Movie Title',
                _titleController,
                Icons.movie,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a movie title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Genre Dropdown
              _buildDropdownField(
                context,
                theme,
                'Genre',
                _selectedGenre,
                _genres,
                Icons.category,
                (value) {
                  setState(() {
                    _selectedGenre = value!;
                  });
                },
              ),
              SizedBox(height: 2.h),

              // Rating Dropdown
              _buildDropdownField(
                context,
                theme,
                'Rating',
                _selectedRating,
                _ratings,
                Icons.rate_review,
                (value) {
                  setState(() {
                    _selectedRating = value!;
                  });
                },
              ),
              SizedBox(height: 2.h),

              // Sentiment Dropdown
              _buildDropdownField(
                context,
                theme,
                'Sentiment',
                _selectedSentiment,
                _sentiments,
                Icons.sentiment_satisfied,
                (value) {
                  setState(() {
                    _selectedSentiment = value!;
                  });
                },
              ),
              SizedBox(height: 2.h),

              // Views
              _buildTextField(
                context,
                theme,
                'Views',
                _viewsController,
                Icons.visibility,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter view count';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Revenue
              _buildTextField(
                context,
                theme,
                'Revenue (\$)',
                _revenueController,
                Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter revenue';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Booking Rate
              _buildTextField(
                context,
                theme,
                'Booking Rate (%)',
                _bookingRateController,
                Icons.percent,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter booking rate';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final rate = double.tryParse(value);
                  if (rate != null && (rate < 0 || rate > 100)) {
                    return 'Booking rate must be between 0 and 100';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Description
              _buildTextField(
                context,
                theme,
                'Description',
                _descriptionController,
                Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 4.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Add Movie',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    ThemeData theme,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

