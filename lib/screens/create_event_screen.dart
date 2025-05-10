import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

import '../models/event.dart' as app_event; // Alias to avoid conflict
import '../services/event_service.dart';

final Logger _logger = Logger();
const Uuid uuid = Uuid();

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _accessCodeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  bool _requestsOpen = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _accessCodeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate:
          DateTime.now().subtract(const Duration(days: 1)), // Allow today
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
      );
      if (pickedTime != null) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartTime) {
            _startTime = selectedDateTime;
            // Ensure end time is after start time
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 2));
            }
          } else {
            _endTime = selectedDateTime;
            // Ensure start time is before end time
            if (_startTime.isAfter(_endTime)) {
              _startTime = _endTime.subtract(const Duration(hours: 2));
            }
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _logger.e("User not logged in to create event.");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: You must be logged in.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final newEvent = app_event.Event(
        id: uuid.v4(), // Generate a unique ID
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startTime: Timestamp.fromDate(_startTime),
        endTime: Timestamp.fromDate(_endTime),
        location: app_event.Location(
          venue: _venueController.text.trim(),
          address: _addressController.text.trim(),
          coordinates:
              app_event.Coordinates(lat: 0, lng: 0), // Default coordinates
        ),
        djId: currentUser.uid,
        accessCode: _accessCodeController.text.trim(),
        requestsOpen: _requestsOpen,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
      );

      try {
        await _eventService.createEvent(newEvent);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.pop(context); // Go back to DJ Dashboard
      } catch (e) {
        _logger.e('Error creating event: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('Create New Event'),
        backgroundColor: const Color(0xFF161616),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField(_nameController, 'Event Name',
                  isRequired: true),
              _buildTextFormField(
                  _descriptionController, 'Description (Optional)'),
              _buildTextFormField(_venueController, 'Venue Name',
                  isRequired: true),
              _buildTextFormField(_addressController, 'Address',
                  isRequired: true),
              _buildTextFormField(
                  _accessCodeController, 'Access Code (for attendees)',
                  isRequired: true),
              _buildTextFormField(_imageUrlController, 'Image URL (Optional)'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start Time: ${MaterialLocalizations.of(context).formatMediumDate(_startTime)} ${TimeOfDay.fromDateTime(_startTime).format(context)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today,
                        color: Color(0xFFFF9100)),
                    onPressed: () => _selectDateTime(context, true),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'End Time: ${MaterialLocalizations.of(context).formatMediumDate(_endTime)} ${TimeOfDay.fromDateTime(_endTime).format(context)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today,
                        color: Color(0xFFFF9100)),
                    onPressed: () => _selectDateTime(context, false),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Allow Song Requests Initially?',
                    style: TextStyle(color: Colors.white)),
                value: _requestsOpen,
                onChanged: (bool value) {
                  setState(() {
                    _requestsOpen = value;
                  });
                },
                activeColor: const Color(0xFFFF9100),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[700],
                tileColor: const Color(0xFF161616),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9100),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle:
                        const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  child: const Text('Create Event',
                      style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white60),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFFF9100)),
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the $label';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
