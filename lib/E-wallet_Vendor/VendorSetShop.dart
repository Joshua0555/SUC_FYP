import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suc_fyp/login_system/api_service.dart';

class CloudinaryService {
  static const cloudName = 'dj5err3f6';
  static const uploadPreset = 'flutter_upload';

  static Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final responseData = jsonDecode(res.body);
      return responseData['secure_url'];
    } else {
      print('❌ Cloudinary upload failed: ${res.body}');
      return null;
    }
  }
}

class VendorSetShopPage extends StatefulWidget {
  const VendorSetShopPage({super.key});

  @override
  State<VendorSetShopPage> createState() => _VendorSetShopPageState();
}

class _VendorSetShopPageState extends State<VendorSetShopPage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _pickUpAddressController = TextEditingController();
  String? _uid;
  String? _adImageUrl;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      final response = await ApiService.getVendorByUID(user.uid);
      if (response['success']) {
        final data = response['vendor'] ?? response['user'];
        if (data == null) return;

        setState(() {
          _shopNameController.text = data['ShopName'] ?? '';
          _pickUpAddressController.text = data['PickupAddress'] ?? '';
          _adImageUrl = data['AdShopImage'] ?? '';
        });
      }
    }
  }

  Future<void> _uploadAdImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final uploadedUrl = await CloudinaryService.uploadImage(file);
      if (uploadedUrl != null) {
        setState(() {
          _adImageUrl = uploadedUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_uid == null) return;

    final result = await ApiService.updateVendorProfile(
      uid: _uid!,
      image_url: '', // 不更新头像
      ShopName: _shopNameController.text,
      PickupAddress: _pickUpAddressController.text,
      SixDigitPassword: '', // 不更新密码
      AdShopImage: _adImageUrl ?? '',
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop info updated')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update')),
      );
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _pickUpAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/UserMainBackground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/image/BackButton.jpg', width: 40, height: 40),
                                  const SizedBox(width: 8),
                                  const Text('Back', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Center(
                              child: Text('Set Shop Information', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 40),
                            const Text('Advertise Pictures', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: _uploadAdImage,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: _adImageUrl != null && _adImageUrl!.isNotEmpty
                                    ? Image.network(_adImageUrl!, width: double.infinity, height: 200, fit: BoxFit.cover)
                                    : Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(child: Text("Tap to upload image")),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildInputField('Shop Name', _shopNameController),
                            const SizedBox(height: 30),
                            _buildAddressField(),
                            const Spacer(),
                            const SizedBox(height: 40),
                            Center(
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Submit', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick Up Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        TextField(
          controller: _pickUpAddressController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter your shop address',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
