import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FIX: Hide 'State' to prevent conflict with Flutter's State class
import 'package:country_state_city/country_state_city.dart' hide State;
import 'package:country_state_city/models/state.dart' as csc;

// Project-specific imports
import 'package:s_a/Screens/CheckOutSummary.dart';
import 'package:s_a/const/color/colors.dart';
import 'package:s_a/const/endpoint/ApiService.dart';
import 'package:s_a/const/endpoint/endpoint.dart';
import 'package:s_a/const/Modal/profectionalListModal.dart' as cat_pro;
import 'package:s_a/const/Modal/schedule_modal.dart';

// ─────────────────────────────────────────────────────────
//  Models (Address & Schedule)
// ─────────────────────────────────────────────────────────



class Address {
  final String id;
  final String address;
  final String landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String type;

  Address({
    required this.id, required this.address, this.landmark = '',
    required this.city, required this.state, required this.postalCode,
    required this.country, this.type = 'Home',
  });

  String get apiAddressFormat => landmark.isNotEmpty ? "$address, $landmark" : address;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: (json['id'] ?? json['address_id'] ?? '').toString(),
      address: (json['address'] ?? json['address_line1'] ?? '').toString(),
      landmark: json['landmark']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      type: json['type'] ?? 'Home',
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Address Repository
// ─────────────────────────────────────────────────────────
class AddressRepository {
  static Future<bool> pushToApi(int userId, Address addr) async {
    try {
      final response = await ApiService().addUserAddress(
        userId: userId, address: addr.apiAddressFormat,
        city: addr.city, state: addr.state,
        postalCode: addr.postalCode, country: addr.country,
      );
      return response != null && response.status == true;
    } catch (e) { return false; }
  }

  static Future<List<Address>> fetchFromServer(int userId) async {
    try {
      final response = await ApiService().getUserAddresses(userId);
      if (response != null && response['status'] == true) {
        final List<dynamic> rawData = response['data'] ?? [];
        return rawData.map((e) => Address.fromJson(e)).toList();
      }
    } catch (e) { debugPrint('Fetch Error: $e'); }
    return [];
  }
}

// ─────────────────────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────────────────────
class ChooseProfessionalScreen extends StatefulWidget {
  final int servidId;
  final int ownerId;

  const ChooseProfessionalScreen({super.key, required this.ownerId, required this.servidId});

  @override
  State<ChooseProfessionalScreen> createState() => _ChooseProfessionalScreenState();
}

class _ChooseProfessionalScreenState extends State<ChooseProfessionalScreen> {
  int _selectedIdx = 0;
  List<cat_pro.Data> _professionals = [];
  bool _isLoading = true;
  bool _isProceedLoading = false;
  // This will now refer to the one in schedule_modal.dart


  // Store schedules for each pro
// This will now refer to the one in schedule_modal.dart
  Map<int, List<ScheduleItem>> _proSchedules = {};

  Address? _selectedAddress;
  List<Address> _cachedAddresses = [];

  late List<DateTime> _availableDates;
  String _selectedDate = '';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 30);

  @override
  void initState() {
    super.initState();
    _generateDates();
    _loadInitialData();
  }

  void _generateDates() {
    _availableDates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    _selectedDate = _formatDateValue(_availableDates[0]);
  }

  String _formatDateValue(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTimeValue(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.fetchProfessionals(widget.ownerId);
      if (mounted && result is cat_pro.ProffectionalModal) {
        _professionals = result.data ?? [];

        // Fetch schedules for all professionals in parallel
        for (var pro in _professionals) {
          if (pro.id != null) {
            final response = await ApiService.getProfessionalSchedule(pro.id!);
            _proSchedules[pro.id!] = response;
          }
        }
      }
    } catch (e) {
      debugPrint("Load Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TimeOfDay> _generateTimeSlots() {
    List<TimeOfDay> slots = [];
    // Starting from 8:00 AM to 10:00 PM (22:00)
    for (int hour = 8; hour <= 22; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      if (hour != 22) { // Don't add 10:30 PM if 10:00 PM is the cutoff
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choose Professional', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          Expanded(
            child: _professionals.isEmpty
                ? const Center(child: Text('No professionals found.'))
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _professionals.length,
              itemBuilder: (_, i) => _buildProfessionalCard(i),
            ),
          ),
          if (_professionals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: _fullWidthButton('Proceed', _isProceedLoading ? null : _handleProceed, isLoading: _isProceedLoading),
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(int index) {
    final pro = _professionals[index];
    final isSelected = _selectedIdx == index;

    // Get and flatten all slots for this professional
    final List<ScheduleItem> proSchedules = _proSchedules[pro.id] ?? [];
    final List<String> allSlots = proSchedules.expand((s) => s.timeSlots ?? <String>[]).toList();

    return GestureDetector(
      onTap: () => setState(() => _selectedIdx = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Softer Ranchi-style corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top Info Row ───
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: (pro.image != null)
                      ? NetworkImage("${ApiEndoint.baseUrl}${pro.image}")
                      : null,
                  child: pro.image == null
                      ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pro.name ?? 'Professional',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Verified Professional • 4.8 ★",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  size: 26,
                ),
              ],
            ),

            // ─── Time Slots Section ───
            if (allSlots.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F1F1)),
              ),
              const Text(
                "AVAILABLE SLOTS",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: allSlots.map((slot) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Text(
                        slot,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ] else if (!_isLoading) ...[
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  "No slots available for today",
                  style: TextStyle(fontSize: 12, color: Colors.redAccent, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── PROCEED & BOTTOM SHEETS ───

  Future<void> _handleProceed() async {
    setState(() => _isProceedLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 3;
    final List<Address> addresses = await AddressRepository.fetchFromServer(userId);
    if (!mounted) return;
    setState(() { _cachedAddresses = addresses; _isProceedLoading = false; });
    _showAddressSelectionSheet();
  }

  void _showAddressSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('Select Service Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              Expanded(
                child: _cachedAddresses.isEmpty
                    ? const Center(child: Text('No saved addresses found.'))
                    : ListView.builder(
                  itemCount: _cachedAddresses.length,
                  itemBuilder: (_, idx) {
                    final addr = _cachedAddresses[idx];
                    return AddressCard(
                      address: addr,
                      isSelected: _selectedAddress?.id == addr.id,
                      onSelect: () {
                        setModal(() => _selectedAddress = addr);
                        setState(() {});
                      },
                      onDelete: () {},
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _fullWidthButton('+ Add New Address', () { Navigator.pop(ctx); _showAddAddressSheet(context); }, isOutlined: true),
              ),
              if (_selectedAddress != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _fullWidthButton('Use this address & proceed', () { Navigator.pop(ctx); _showSlotsBottomSheet(context); }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final houseCtrl = TextEditingController();
    final landmarkCtrl = TextEditingController();
    final postalCodeCtrl = TextEditingController();
    String addressType = 'Home';

    Country? selectedCountry;
    csc.State? selectedState;
    City? selectedCity;

    List<Country> countries = [];
    List<csc.State> states = [];
    List<City> cities = [];
    bool loadingCountries = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          if (loadingCountries) {
            loadingCountries = false;
            getAllCountries().then((list) => setModal(() => countries = list));
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add New Address', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _customTextField('House / Flat Number *', houseCtrl),
                  const SizedBox(height: 12),
                  _customTextField('Landmark (Optional)', landmarkCtrl),
                  const SizedBox(height: 20),
                  Row(children: [
                    for (var t in ['Home', 'Work', 'Other']) ...[
                      GestureDetector(
                        onTap: () => setModal(() => addressType = t),
                        child: _selectionChip(t, isSelected: addressType == t),
                      ),
                      const SizedBox(width: 10),
                    ]
                  ]),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Country>(
                    value: selectedCountry,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Country *', border: OutlineInputBorder()),
                    items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (country) async {
                      if (country == null) return;
                      final loaded = await getStatesOfCountry(country.isoCode);
                      setModal(() { selectedCountry = country; selectedState = null; selectedCity = null; states = loaded.cast<csc.State>(); cities = []; });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<csc.State>(
                    value: selectedState,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
                    items: states.map((s) => DropdownMenuItem(value: s, child: Text(s.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: states.isEmpty ? null : (s) async {
                      final loaded = await getStateCities(selectedCountry!.isoCode, s!.isoCode);
                      setModal(() { selectedState = s; selectedCity = null; cities = loaded; });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<City>(
                    value: selectedCity,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
                    items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: cities.isEmpty ? null : (c) => setModal(() => selectedCity = c),
                  ),
                  const SizedBox(height: 12),
                  _customTextField('Postal Code *', postalCodeCtrl),
                  const SizedBox(height: 30),
                  isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : _fullWidthButton('Save Address', () async {
                    if (houseCtrl.text.isEmpty || selectedCity == null || postalCodeCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }
                    setModal(() => isSaving = true);
                    final newAddr = Address(
                      id: '', address: houseCtrl.text.trim(), landmark: landmarkCtrl.text.trim(),
                      type: addressType, country: selectedCountry!.name, state: selectedState!.name,
                      city: selectedCity!.name, postalCode: postalCodeCtrl.text.trim(),
                    );
                    final prefs = await SharedPreferences.getInstance();
                    final int userId = prefs.getInt('userId') ?? 2;
                    final bool success = await AddressRepository.pushToApi(userId, newAddr);
                    if (!mounted) return;
                    setModal(() => isSaving = false);
                    if (success) {
                      Navigator.pop(context);
                      final updatedList = await AddressRepository.fetchFromServer(userId);
                      setState(() => _cachedAddresses = updatedList);
                      _showAddressSelectionSheet();
                    } else { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Failed to save address'))); }
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSlotsBottomSheet(BuildContext context) {
    final List<TimeOfDay> allSlots = _generateTimeSlots();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Set to true to allow more space for the grid
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Container(
          padding: const EdgeInsets.all(25),
          // Use constraints to ensure it doesn't cover the whole screen but fits the slots
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
              ),
              const SizedBox(height: 20),
              const Text('Select Date & Time',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(height: 40),

              // Date Selection
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableDates.length,
                  itemBuilder: (_, i) {
                    final date = _availableDates[i];
                    final dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
                    return GestureDetector(
                      onTap: () => setModal(() => _selectedDate = _formatDateValue(date)),
                      child: _dateCard(i == 0 ? 'Today' : dayName, date.day.toString(),
                          isSelected: _selectedDate == _formatDateValue(date)),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Available Intervals (30 min)",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 15),

              // ─── DYNAMIC TIME GRID ───
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10, // Horizontal space between chips
                    runSpacing: 12, // Vertical space between lines
                    alignment: WrapAlignment.start,
                    children: allSlots.map((time) {
                      // Formatting TimeOfDay to String (e.g., 08:30 AM)
                      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                      final minute = time.minute.toString().padLeft(2, '0');
                      final displayTime = "$hour:$minute $period";

                      return GestureDetector(
                        onTap: () => setModal(() => _selectedTime = time),
                        child: _timeChip(displayTime, isSelected: _selectedTime == time),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _fullWidthButton('Proceed to Checkout', () {
                Navigator.pop(ctx);
                _navigateToCheckout(context);
              }),
            ],
          ),
        );
      }),
    );
  }





  void _navigateToCheckout(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SummaryScreen(
      professional: _professionals[_selectedIdx], houseNumber: _selectedAddress!.address,
      landmark: _selectedAddress!.landmark, id: int.parse(_selectedAddress!.id),
      date: _selectedDate, time: _formatTimeValue(_selectedTime),
      ownerId: widget.ownerId, serviceId: widget.servidId,
    )));
  }

  // ── UI Helpers ────────────────────────────────────────

  Widget _buildSlotTime(Function setModal, String display, TimeOfDay value) {
    return GestureDetector(
      onTap: () => setModal(() => _selectedTime = value),
      child: _timeChip(display, isSelected: _selectedTime == value),
    );
  }

  Widget _customTextField(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary))),
    );
  }

  Widget _selectionChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300)),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  Widget _dateCard(String day, String date, {required bool isSelected}) {
    return Container(
      width: 56, margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.grey)),
          Text(date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  Widget _timeChip(String time, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300)),
      child: Text(time, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
    );
  }

  Widget _fullWidthButton(String text, VoidCallback? onPressed, {bool isOutlined = false, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: isOutlined
          ? OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primary), shape: const StadiumBorder()), child: Text(text, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))
          : ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()), child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const AddressCard({super.key, required this.address, required this.isSelected, required this.onSelect, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: isSelected ? 1.8 : 1)),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(address.apiAddressFormat, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${address.city}, ${address.state} - ${address.postalCode}', style: const TextStyle(fontSize: 12, color: Colors.grey))])),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}