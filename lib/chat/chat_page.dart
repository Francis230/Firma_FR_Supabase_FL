// lib/chat/chat_page.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import 'message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseService _supabaseService = SupabaseService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // MEJORA: Función para auto-scroll
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await supabase.from('messages').insert({
        'user_id': supabase.auth.currentUser!.id,
        'user_email': supabase.auth.currentUser!.email,
        'content': text,
        'type': 'text',
      });
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al enviar mensaje: $e")));
      }
    }
  }

  // FIX: Función de ubicación completa con manejo de permisos
  Future<void> _sendLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, activa el GPS')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso denegado permanentemente. Ve a configuración para habilitarlo.')));
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      await supabase.from('messages').insert({
        'user_id': supabase.auth.currentUser!.id,
        'user_email': supabase.auth.currentUser!.email,
        'type': 'location',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener ubicación: $e')));
      }
    }
  }

  Future<void> _sendImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 800);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('chat-photos').uploadBinary(fileName, bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

      final imageUrl = supabase.storage.from('chat-photos').getPublicUrl(fileName);

      await supabase.from('messages').insert({
        'user_id': supabase.auth.currentUser!.id,
        'user_email': supabase.auth.currentUser!.email,
        'type': 'image',
        'image_url': imageUrl,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar imagen: $e')));
      }
    }
  }

  Future<void> _logout() async {
    await _supabaseService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${supabase.auth.currentUser?.email?.split('@')[0] ?? ''}'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('messages').stream(primaryKey: ['id']).order('created_at', ascending: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Inicia una conversación 👋'));
                }
                final messages = snapshot.data!;

                // MEJORA: Llama al auto-scroll después de que la lista se construya
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  // (Paso 2) Asegúrate de que 'reverse' sea false (o no esté definido)
                  reverse: false,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return MessageBubble(
                      isMine: msg['user_id'] == userId,
                      sender: msg['user_email'] ?? 'Anónimo',
                      type: msg['type'],
                      content: msg['content'],
                      imageUrl: msg['image_url'],
                      latitude: msg['latitude'],
                      longitude: msg['longitude'],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar() {
    return SafeArea(
      child: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.redAccent),
              onPressed: _sendLocation,
              tooltip: 'Enviar ubicación',
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              onPressed: () => _sendImage(ImageSource.camera),
              tooltip: 'Tomar foto',
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.greenAccent),
              onPressed: _sendMessage,
              tooltip: 'Enviar mensaje',
            )
          ],
        ),
      ),
    );
  }
}
