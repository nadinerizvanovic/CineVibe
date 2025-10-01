import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:cinevibe_mobile/model/screening.dart';
import 'package:cinevibe_mobile/providers/ticket_provider.dart';
import 'package:cinevibe_mobile/providers/user_provider.dart';
import 'package:cinevibe_mobile/utils/base_snackbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class TicketPaymentScreen extends StatefulWidget {
  final Screening screening;
  final List<int> selectedSeatIds;
  final List<String> selectedSeatNumbers;
  final double totalAmount;

  const TicketPaymentScreen({
    super.key,
    required this.screening,
    required this.selectedSeatIds,
    required this.selectedSeatNumbers,
    required this.totalAmount,
  });

  @override
  State<TicketPaymentScreen> createState() => _TicketPaymentScreenState();
}

class _TicketPaymentScreenState extends State<TicketPaymentScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _paymentCompleted = false;
  List<int> _generatedTicketIds = [];

  final commonDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Color(0xFF004AAD), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF004AAD),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF004AAD).withOpacity(0.05),
              const Color(0xFFF8FAFC),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF004AAD)),
                )
              : _paymentCompleted
                  ? _buildPaymentSuccessScreen()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildPaymentForm(context),
                    ),
        ),
      ),
    );
  }

  Widget _buildPaymentSuccessScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Success message
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004AAD).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.2),
                        const Color(0xFF10B981).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your tickets have been purchased successfully.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_generatedTicketIds.length} ticket${_generatedTicketIds.length > 1 ? 's' : ''} created',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Ticket details card
          _buildTicketDetailsCard(),

          const SizedBox(height: 32),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                // Pop back to movie list or home
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.home_outlined, size: 22),
              label: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ).decorated(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF004AAD).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF004AAD).withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Movie', widget.screening.movieTitle),
                const SizedBox(height: 12),
                _buildSummaryRow('Hall', widget.screening.hallName),
                const SizedBox(height: 12),
                _buildSummaryRow('Showtime', DateFormat('MMM d, HH:mm').format(widget.screening.startTime)),
                const SizedBox(height: 12),
                _buildSummaryRow('Seats', widget.selectedSeatNumbers.join(', ')),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Total Amount',
                  '\$${widget.totalAmount.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please arrive 15 minutes before showtime.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF1E293B) : Colors.grey[700],
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFF004AAD) : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 24),
          _buildTicketItemsList(),
          const SizedBox(height: 24),
          _buildBillingSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.confirmation_number,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '\$${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.selectedSeatIds.length} ticket${widget.selectedSeatIds.length > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF004AAD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ticket Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Movie Title
          _buildDetailRow(Icons.movie_outlined, 'Movie', widget.screening.movieTitle),
          const SizedBox(height: 12),
          
          // Hall
          _buildDetailRow(Icons.meeting_room_outlined, 'Hall', widget.screening.hallName),
          const SizedBox(height: 12),
          
          // Screening Type
          _buildDetailRow(Icons.movie_filter_outlined, 'Type', widget.screening.screeningTypeName),
          const SizedBox(height: 12),
          
          // Date & Time
          _buildDetailRow(Icons.schedule_outlined, 'Showtime', 
              DateFormat('EEEE, MMM d, yyyy • HH:mm').format(widget.screening.startTime)),
          const SizedBox(height: 16),
          
          const Divider(),
          const SizedBox(height: 16),
          
          // Seats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.event_seat,
                  color: Color(0xFF004AAD),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Seats',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.selectedSeatNumbers.map((seat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            seat,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF004AAD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF004AAD),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF004AAD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Billing Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'name',
            'Full Name',
            initialValue: _getUserFullName(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'address',
            'Address',
            initialValue: 'Sjeverni logor bb',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'city',
                  'City',
                  initialValue: 'Mostar',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('state', 'State', initialValue: 'HNK'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'country',
                  'Country',
                  initialValue: 'BIH',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'pincode',
                  'ZIP Code',
                  keyboardType: TextInputType.number,
                  isNumeric: true,
                  initialValue: '88000',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserFullName() {
    final user = UserProvider.currentUser;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'John Doe';
  }

  Widget _buildTextField(
    String name,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
    String? initialValue,
  }) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: commonDecoration.copyWith(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      validator: isNumeric
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
              FormBuilderValidators.numeric(
                errorText: 'This field must be numeric',
              ),
            ])
          : FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
            ]),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.lock_outline, size: 22),
        label: const Text(
          "Proceed to Payment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          if (formKey.currentState?.saveAndValidate() ?? false) {
            final formData = formKey.currentState?.value;

            try {
              await _processStripePayment(formData!);
            } catch (e) {
              BaseSnackbar.showErrorSnackbar(
                context,
                'Payment failed: $e',
              );
            }
          }
        },
      ).decorated(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004AAD).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
    );
  }

  // Stripe Payment Methods
  Future<void> _initPaymentSheet(Map<String, dynamic> formData) async {
    try {
      final data = await _createPaymentIntent(
        amount: (widget.totalAmount * 100).round().toString(),
        currency: 'USD',
        name: formData['name'],
        address: formData['address'],
        pin: formData['pincode'],
        city: formData['city'],
        state: formData['state'],
        country: formData['country'],
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'CineVibe',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.light,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required String amount,
    required String currency,
    required String name,
    required String address,
    required String pin,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
      if (secretKey == null) {
        throw Exception('STRIPE_SECRET_KEY not found in environment variables');
      }

      // Create customer
      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': UserProvider.currentUser?.email ?? 'test@example.com',
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
        },
      );

      if (customerResponse.statusCode != 200) {
        throw Exception('Failed to create customer: ${customerResponse.body}');
      }

      final customerData = jsonDecode(customerResponse.body);
      final customerId = customerData['id'];

      // Create ephemeral key
      final ephemeralKeyResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Stripe-Version': '2023-10-16',
        },
        body: {'customer': customerId},
      );

      if (ephemeralKeyResponse.statusCode != 200) {
        throw Exception(
          'Failed to create ephemeral key: ${ephemeralKeyResponse.body}',
        );
      }

      final ephemeralKeyData = jsonDecode(ephemeralKeyResponse.body);

      // Create payment intent
      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency.toLowerCase(),
          'customer': customerId,
          'payment_method_types[]': 'card',
          'description': 'CineVibe Movie Tickets - ${widget.screening.movieTitle}',
          'metadata[name]': name,
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
          'metadata[screening_id]': widget.screening.id.toString(),
          'metadata[tickets]': widget.selectedSeatIds.length.toString(),
          'metadata[seats]': widget.selectedSeatNumbers.join(', '),
        },
      );

      if (paymentIntentResponse.statusCode == 200) {
        final paymentIntentData = jsonDecode(paymentIntentResponse.body);
        return {
          'client_secret': paymentIntentData['client_secret'],
          'ephemeralKey': ephemeralKeyData['secret'],
          'id': customerId,
          'amount': amount,
          'currency': currency,
        };
      } else {
        throw Exception(
          'Failed to create payment intent: ${paymentIntentResponse.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<void> _processStripePayment(Map<String, dynamic> formData) async {
    setState(() => _isLoading = true);

    try {
      await _initPaymentSheet(formData);
      await stripe.Stripe.instance.presentPaymentSheet();

      // Create tickets in backend
      final ticketIds = await _createTickets();

      setState(() {
        _paymentCompleted = true;
        _generatedTicketIds = ticketIds;
        _isLoading = false;
      });

      BaseSnackbar.showSuccessSnackbar(context, 'Payment successful!');
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (e.toString().contains('canceled')) {
        BaseSnackbar.showInfoSnackbar(context, 'Payment was canceled');
      } else {
        BaseSnackbar.showErrorSnackbar(context, 'Payment failed: $e');
      }
    }
  }

  Future<List<int>> _createTickets() async {
    try {
      final user = UserProvider.currentUser;
      if (user == null) throw Exception('User not found');

      final ticketProvider = TicketProvider();
      final ticketIds = <int>[];

      // Create a ticket for each selected seat
      for (var seatId in widget.selectedSeatIds) {
        final ticketData = {
          'userId': user.id,
          'screeningId': widget.screening.id,
          'seatId': seatId,
          'isActive': true,
        };

        final result = await ticketProvider.insert(ticketData);
        ticketIds.add(result.id);
      }

      return ticketIds;
    } catch (e) {
      throw Exception('Failed to create tickets: $e');
    }
  }
}

// Extension to apply decoration to widgets
extension WidgetDecoration on Widget {
  Widget decorated({required BoxDecoration decoration}) {
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }
}

