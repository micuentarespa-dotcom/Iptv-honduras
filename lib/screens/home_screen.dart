import 'package:flutter/material';
import '../models/user_model.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  void _openPlayer(BuildContext context, String streamTitle, String streamId, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          user: user,
          streamTitle: streamTitle,
          streamId: streamId,
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBaseOrDemo = !user.allowVod;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.tv_rounded, color: Colors.blueAccent),
            const SizedBox(width: 8),
            const Text('IPTV Honduras', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            // Badge del Plan / Demo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: user.isDemo ? Colors.amber : (isBaseOrDemo ? Colors.blueAccent : Colors.green),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isDemo
                    ? '⚡ DEMO 5H'
                    : (isBaseOrDemo ? 'PLAN BASE (95 HNL)' : 'PLAN COMPLETO (110 HNL)'),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Banner de Bienvenida y Vencimiento
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${user.fullName}!',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.expiresAt != null
                        ? 'Vence el: ${user.expiresAt!.day}/${user.expiresAt!.month}/${user.expiresAt!.year} a las ${user.expiresAt!.hour}:${user.expiresAt!.minute.toString().padLeft(2, '0')}'
                        : 'Suscripción Activa',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'CATEGORÍAS DE CONTENIDO',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 15),

            // GRIDA DE MENÚS CON FILTRADO DINÁMICO POR PLAN
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // 1. TV EN VIVO (Habilitado para todos)
                _buildMenuCard(
                  context,
                  title: 'TV EN VIVO',
                  subtitle: 'Canales HD / FHD',
                  icon: Icons.live_tv_rounded,
                  color: Colors.blueAccent,
                  isEnabled: true,
                  onTap: () => _openPlayer(context, 'Deportes TV HD', '101', 'live'),
                ),

                // 2. DEPORTES EN VIVO (Habilitado para todos)
                _buildMenuCard(
                  context,
                  title: 'DEPORTES HD',
                  subtitle: 'Liga Nacional y Mundial',
                  icon: Icons.sports_soccer_rounded,
                  color: Colors.orangeAccent,
                  isEnabled: true,
                  onTap: () => _openPlayer(context, 'Deportes Honduras HD', '102', 'live'),
                ),

                // 3. PELÍCULAS VOD (Filtrado por Plan)
                _buildMenuCard(
                  context,
                  title: 'PELÍCULAS VOD',
                  subtitle: isBaseOrDemo ? '🔒 Requiere Plan Completo' : 'Catálogo HD/4K',
                  icon: Icons.movie_rounded,
                  color: isBaseOrDemo ? Colors.grey : Colors.purpleAccent,
                  isEnabled: !isBaseOrDemo,
                  onTap: () => _openPlayer(context, 'Película Estreno 2026', '501', 'movie'),
                ),

                // 4. SERIES VOD (Filtrado por Plan)
                _buildMenuCard(
                  context,
                  title: 'SERIES VOD',
                  subtitle: isBaseOrDemo ? '🔒 Requiere Plan Completo' : 'Temporadas Completas',
                  icon: Icons.tv_off_rounded,
                  color: isBaseOrDemo ? Colors.grey : Colors.pinkAccent,
                  isEnabled: !isBaseOrDemo,
                  onTap: () => _openPlayer(context, 'Serie Temporada 1', '601', 'series'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔒 Tu Plan Base (o Demo) incluye únicamente TV en Vivo y Deportes. Actualiza a Plan Completo por L. 110 HNL.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF1E293B) : const Color(0xFF1E293B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.5) : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: isEnabled ? color : Colors.white30),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isEnabled ? Colors.white60 : Colors.white30,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
