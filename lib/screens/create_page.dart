import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_Provider.dart';
import '../providers/post_provider.dart';
import '../providers/category_provider.dart';
import 'login_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return _buildLoginPrompt(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Create'),
        backgroundColor:  Colors.white,
        foregroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    label: 'Post',
                    icon: Icons.article_outlined,
                    isActive: _currentTab == 0,
                    onTap: () => setState(() => _currentTab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    label: 'Category',
                    icon: Icons.category_outlined,
                    isActive: _currentTab == 1,
                    onTap: () => setState(() => _currentTab = 1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentTab == 0
                ? const _CreatePostForm()
                : const _CreateCategoryForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2E7D32)
              : const Color(0xFF2E7D32).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              const Text(
                'Login Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Login dulu untuk membuat post atau kategori',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatePostForm extends StatefulWidget {
  const _CreatePostForm();

  @override
  State<_CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<_CreatePostForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _selectedCategoryId;
  XFile? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();

    setState(() => _isSubmitting = true);

    final success = await postProvider.createPost(
      userId: authProvider.user!.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      categoryId: _selectedCategoryId,
      imageFile: _selectedImage,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedCategoryId = null;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post berhasil dibuat!'),
          backgroundColor: Colors.white,
        ),
      );

      context.read<PostProvider>().loadAllPosts();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(postProvider.errorMessage ?? 'Gagal buat post'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FutureBuilder<Uint8List>(
                          future: _selectedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap untuk tambah gambar',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Judul wajib diisi';
                if (value.length < 3) return 'Judul minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedCategoryId,
                      isExpanded: true,
                      hint: const Text('Pilih Kategori (Opsional)'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Tanpa Kategori'),
                        ),
                        ...provider.categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Konten',
                hintText: 'Tulis konten di sini...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Konten wajib diisi';
                if (value.length < 10) return 'Konten minimal 10 karakter';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Publish Post',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCategoryForm extends StatefulWidget {
  const _CreateCategoryForm();

  @override
  State<_CreateCategoryForm> createState() => _CreateCategoryFormState();
}

class _CreateCategoryFormState extends State<_CreateCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryProvider = context.read<CategoryProvider>();

    setState(() => _isSubmitting = true);

    final success = await categoryProvider.createCategory(
      name: _nameController.text.trim(),
      slug: _slugController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _nameController.clear();
      _slugController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );

      context.read<CategoryProvider>().loadCategories();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(categoryProvider.errorMessage ?? 'Gagal buat kategori'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kategori digunakan untuk mengelompokkan post',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32).withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Contoh: Teknologi',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                final slug = value
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                    .replaceAll(RegExp(r'^-|-$'), '');
                _slugController.text = slug;
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Nama wajib diisi';
                if (value.length < 2) return 'Nama minimal 2 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _slugController,
              decoration: InputDecoration(
                labelText: 'Slug',
                hintText: 'otomatis dari nama',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Slug wajib diisi';
                if (value.length < 3) return 'Slug minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Deskripsi kategori...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Buat Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}