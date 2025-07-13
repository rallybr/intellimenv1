import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Feed',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () {
              // Implementar criar post
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10, // Placeholder
          itemBuilder: (context, index) {
            return _buildPostCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildPostCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do post
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    'U${index + 1}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuário ${index + 1}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Há ${index + 1} horas',
                        style: const TextStyle(
                          color: AppColors.mediumGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.white),
                  onPressed: () {
                    // Implementar menu do post
                  },
                ),
              ],
            ),
          ),
          
          // Conteúdo do post
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                size: 50,
                color: AppColors.mediumGray,
              ),
            ),
          ),
          
          // Ações do post
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: AppColors.white),
                  onPressed: () {
                    // Implementar curtir
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.comment, color: AppColors.white),
                  onPressed: () {
                    // Implementar comentar
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.white),
                  onPressed: () {
                    // Implementar compartilhar
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: AppColors.white),
                  onPressed: () {
                    // Implementar salvar
                  },
                ),
              ],
            ),
          ),
          
          // Curtidas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${(index + 1) * 5} curtidas',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Descrição do post
          Padding(
            padding: const EdgeInsets.all(12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.white),
                children: [
                  TextSpan(
                    text: 'Usuário ${index + 1} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Completou o desafio da semana ${index + 1}! 💪 #IntelliMen #Desafio',
                  ),
                ],
              ),
            ),
          ),
          
          // Comentários
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Ver todos os ${(index + 1) * 3} comentários',
              style: const TextStyle(
                color: AppColors.mediumGray,
                fontSize: 12,
              ),
            ),
          ),
          
          // Campo de comentário
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      hintText: 'Adicione um comentário...',
                      hintStyle: TextStyle(color: AppColors.mediumGray),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Implementar enviar comentário
                  },
                  child: const Text(
                    'Enviar',
                    style: TextStyle(color: AppColors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 