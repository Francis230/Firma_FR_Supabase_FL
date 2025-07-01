// lib/chat/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final bool isMine;
  final String sender;
  final String? type;
  final String? content;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const MessageBubble({
    super.key,
    required this.isMine,
    required this.sender,
    this.type,
    this.content,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  Widget _buildContent() {
    switch (type) {
      case 'text':
        return Text(
          content ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        );

      case 'location':
        return InkWell(
          onTap: () async {
            // FIX: URL correcta para abrir mapas
            if (latitude != null && longitude != null) {
              final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.location_on, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Ver Ubicación',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        );

      case 'image':
        if (imageUrl == null || imageUrl!.isEmpty) {
          return const Text('URL de imagen no válida');
        }
        // MEJORA: Widget de imagen con indicador de carga y error
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl!,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              return progress == null ? child : const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 220,
                height: 220,
                color: Colors.grey[800],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    SizedBox(height: 8),
                    Text('Error al cargar', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            },
          ),
        );

      default:
        return const Text('Mensaje no soportado', style: TextStyle(color: Colors.white70));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? Colors.blueAccent : const Color(0xFF333333);
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMine
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            isMine ? 'Tú' : sender.split('@')[0],
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}

