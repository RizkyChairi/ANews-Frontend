import 'dart:typed_data';                   
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';    
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/category_provider.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int? _selectedCategoryId;
  XFile? _selectedImage;                         
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _selectedCategoryId = widget.post.categoryId;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;               
      });
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await context.read<PostProvider>().updatePost(
      postId: widget.post.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      categoryId: _selectedCategoryId,
      imageFile: _selectedImage,                   
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<PostProvider>().errorMessage ??
                'Failed to update post',
          ),
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

  Widget _buildImagePreview() {
    // Kalau pilih gambar baru
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FutureBuilder<Uint8List>(
          future: _selectedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          },
        ),
      );
    }

    // Kalau sudah ada gambar dari server
    if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.post.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.broken_image, size: 40)),
            );
          },
        ),
      );
    }

    // Belum ada gambar
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 60,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 10),
        Text(
          'Tap to change image',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                  child: _buildImagePreview(), 
                ),
              ),
              const SizedBox(height: 20),

              // title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  if (value.length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // category
              Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  // Cek apakah categoryId ada di list categories
                  final validValue = provider.categories
                          .any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: validValue,
                        isExpanded: true,
                        hint: const Text('Select Category'),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('No Category'),
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

              //content
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Content',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Content is required';
                  }
                  if (value.length < 10) {
                    return 'Content must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              //submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Post',
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
      ),
    );
  }
}