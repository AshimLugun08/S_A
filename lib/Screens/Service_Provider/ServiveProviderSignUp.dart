import 'package:flutter/material.dart';
import 'package:s_a/Screens/Service_Provider/bottom_nav.dart';

class IdentityTrustScreen extends StatefulWidget {
  const IdentityTrustScreen({super.key});

  @override
  State<IdentityTrustScreen> createState() => _IdentityTrustScreenState();
}

class _IdentityTrustScreenState extends State<IdentityTrustScreen> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Fluid Marketplace',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a'), // Placeholder
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Step & Progress ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('STEP 02/03',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Identity & Trust',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        value: 0.66,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const Text('66%', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            // --- Info Banner ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Verification in progress',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Submit your documents to get the "Verified Pro" badge.',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- Contact Details ---
            _sectionHeader(Icons.phone_android, 'Contact Details'),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Text('+1'),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '000-000-0000',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0, left: 4),
              child: Text("We'll send a 6-digit verification code to this number.",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            const SizedBox(height: 30),

            // --- Document Upload ---
            _sectionHeader(Icons.description, 'Document Upload'),
            const SizedBox(height: 16),

            // Identity Proof Card
            _uploadCard(
              title: 'Identity Proof',
              subtitle: 'Passport or Driver\'s License',
              icon: Icons.badge,
              hasError: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none), // Simplified
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: const [
                    Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 40),
                    Text('Tap to upload front side',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text('PNG, JPG up to 10MB',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Certifications Card
            _uploadCard(
              title: 'Certifications',
              subtitle: 'Trade licenses or diplomas',
              icon: Icons.workspace_premium,
              trailing: const Icon(Icons.add_circle, color: Colors.grey),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.picture_as_pdf, size: 20, color: Colors.grey),
                    SizedBox(width: 10),
                    Text('HVAC_Certification.pdf', style: TextStyle(fontSize: 13)),
                    Spacer(),
                    Icon(Icons.close, size: 18, color: Colors.red),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- What Happens Next ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WHAT HAPPENS NEXT?',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 15),
                  _nextStepItem(true, 'Manual Review', 'Our safety team verifies your identity and credentials within 24-48 hours.'),
                  const SizedBox(height: 15),
                  _nextStepItem(false, 'Background Check', ''),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Footer ---
            Row(
              children: [
                Checkbox(
                  value: isAgreed,
                  onChanged: (val) => setState(() => isAgreed = val!),
                ),
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(fontSize: 12),
                      children: [
                        TextSpan(text: 'Partner Terms of Service', style: TextStyle(color: Colors.blue)),
                        TextSpan(text: ' and '),
                        TextSpan(text: 'Privacy Policy', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MainContainer()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Continue to Service Setup', style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Save progress and exit', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _uploadCard({required String title, required String subtitle, required IconData icon, required Widget child, bool hasError = false, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(icon, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (hasError) const Icon(Icons.error, color: Colors.red),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _nextStepItem(bool isActive, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)),
              if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }
}