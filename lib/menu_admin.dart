import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // <--- Import sizer DITAMBAHKAN

class MenuAdmin extends StatelessWidget {
  const MenuAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Admin'),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Container(
              padding: EdgeInsets.all(6.w), // Menggunakan w, Dihapus const
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 2.5.h), // Menggunakan h, Dihapus const
                      textStyle: TextStyle(
                          // Dihapus const
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold), // Menggunakan sp
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to sales details page
                    },
                    child: const Text('Detail Penjualan'),
                  ),
                  SizedBox(height: 2.5.h), // Menggunakan h, Dihapus const
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 2.5.h), // Menggunakan h, Dihapus const
                      textStyle: TextStyle(
                          // Dihapus const
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold), // Menggunakan sp
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to login activities page
                    },
                    child: const Text('Aktivitas Login'),
                  ),
                  SizedBox(height: 2.5.h), // Menggunakan h, Dihapus const
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 2.5.h), // Menggunakan h, Dihapus const
                      textStyle: TextStyle(
                          // Dihapus const
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold), // Menggunakan sp
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to reports page
                    },
                    child: const Text('Laporan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
