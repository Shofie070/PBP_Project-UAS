import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  // --- DATA ANGGOTA ---
  final List<Map<String, String>> members = const [
    {
      'name': 'Putu Novita Darmadewi',
      'nim': '24111814007',
      'image': 'assets/images/anggota1.jpg'
    },
    {
      'name': 'Sultan Raffi Suryanegara',
      'nim': '24111814108',
      'image': 'assets/images/anggota2.jpg'
    },
    {
      'name': 'Shofie Ardhya Safina',
      'nim': '24111814070',
      'image': 'assets/images/anggota3.jpg'
    },
    {
      'name': 'Nakula Syafa Saputra',
      'nim': '24111814116',
      'image': 'assets/images/anggota4.jpg'
    },
    {
      'name': 'Priyo Prakuso',
      'nim': '24111814103',
      'image': 'assets/images/anggota5.jpg'
    },
    {
      'name': 'Tabligh Akbar',
      'nim': '24111814134',
      'image': 'assets/images/anggota6.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Urban Wear',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // LAYER 1: Background
            Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF111111)),
            ),

            // LAYER 2: Overlay Gelap
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.95)
                  ],
                ),
              ),
            ),

            // LAYER 3: Dekorasi Garis
            CustomPaint(
                painter: TechnicalBackgroundPainter(), child: Container()),

            // LAYER 4: Konten Utama
            ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Our Team.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    Container(
                        height: 3,
                        width: 60,
                        color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 15),

                    Text(
                      'Kelompok 1 — Mobile Programming',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: 600,
                      child: Text(
                        'Kami berdedikasi menciptakan aplikasi mobile yang modern, responsif, dan elegan.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.4),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // GRID ANGGOTA
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth < 600 ? 3 : 6;

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return MemberCard(data: members[index]);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET KARTU ---
class MemberCard extends StatelessWidget {
  final Map<String, String> data;
  final ValueNotifier<bool> isHovered = ValueNotifier(false);

  MemberCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. FOTO
        Expanded(
          child: MouseRegion(
            onEnter: (_) => isHovered.value = true,
            onExit: (_) => isHovered.value = false,
            child: GestureDetector(
              onTapDown: (_) => isHovered.value = true,
              onTapUp: (_) => isHovered.value = false,
              onTapCancel: () => isHovered.value = false,
              child: ValueListenableBuilder<bool>(
                valueListenable: isHovered,
                builder: (context, hovered, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: hovered
                          ? Border.all(
                              color: Colors.white.withOpacity(0.9), width: 1)
                          : Border.all(
                              color: Colors.white.withOpacity(0.1), width: 1),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: ClipRect(
                      child: AnimatedScale(
                        scale: hovered ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutQuart,
                        child: Image.asset(
                          data['image'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(Icons.person,
                                  size: 20,
                                  color: Colors.white.withOpacity(0.2)),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 2. NAMA
        Text(
          data['name'] ?? 'Nama',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        // 3. NIM (BOLD)
        Text(
          data['nim'] ?? '-',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white
                .withOpacity(0.7), // Sedikit lebih terang biar jelas
            fontSize: 9,
            fontWeight: FontWeight.bold, // <--- SUDAH DIGANTI JADI BOLD
          ),
        ),
      ],
    );
  }
}

class TechnicalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    void drawCross(double x, double y) {
      canvas.drawLine(Offset(x - 8, y), Offset(x + 8, y), paint);
      canvas.drawLine(Offset(x, y - 8), Offset(x, y + 8), paint);
    }

    drawCross(30, 80);
    drawCross(size.width - 30, 80);
    drawCross(30, size.height - 30);
    drawCross(size.width - 30, size.height - 30);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
