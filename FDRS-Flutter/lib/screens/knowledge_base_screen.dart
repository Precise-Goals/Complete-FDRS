import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .black, // Background color with radial gradient achieved with container
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.0,
            colors: [Color(0xFF1a1a1a), Colors.black],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 40),

                    _buildSectionTitle('Protocol Categories',
                        const Color.fromARGB(255, 255, 30, 0)),
                    const SizedBox(height: 24),
                    _buildProtocolCards(),

                    const SizedBox(height: 40),

                    _buildSectionTitle('Official Documents', Colors.white),
                    const SizedBox(height: 24),
                    _buildDocumentList(context),

                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FDRS',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.white30, blurRadius: 10)],
                ),
              ),
              Text(
                'KNOWLEDGE BASE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x99141414), // rgba(20, 20, 20, 0.6)
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(20)),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, blurRadius: 24, offset: Offset(0, 4))
              ],
            ),
            child:
                const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withAlpha(153) ??
            const Color(0xFF1A1A1A).withAlpha(153),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search knowledge base...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color indicatorColor) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: indicatorColor.withAlpha(204),
                blurRadius: 0,
              )
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProtocolCards() {
    return SizedBox(
      height: 384, // 96 * 4
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildCard(
            Icons.warning_amber_rounded,
            'Disaster Response',
            'Critical procedures for earthquakes, floods, and structural failures.',
            'https://fdrs.vercel.app/',
          ),
          const SizedBox(width: 24),
          _buildCard(
            Icons.medical_services_outlined,
            'Medical Triage',
            'First aid protocols, casualty assessment, and field treatment guides.',
            'https://pmc.ncbi.nlm.nih.gov/articles/PMC7472824/',
          ),
          const SizedBox(width: 24),
          _buildCard(
            Icons.shield_outlined,
            'Safety & Security',
            'Perimeter control, evacuation routes, and personal safety measures.',
            'https://vmmc-sjh.mohfw.gov.in/sites/default/files/Policy%20on%20Security%20and%20Safety%281%29.pdf',
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      IconData icon, String title, String subtitle, String urlString) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(urlString);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Container(
        width: 288, // 72 * 4
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withAlpha(26), Colors.transparent],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(36, 255, 30, 0), // shadow-card-glow-orange
              blurRadius: 30,
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2a1a0f), Colors.black],
                  ),
                  border: Border.all(color: Colors.orange.withAlpha(51)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x26FF9500), blurRadius: 30),
                  ],
                ),
                child: Center(
                  child: Icon(icon, size: 40, color: Colors.orange[500]),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[500]?.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[500]!.withAlpha(51)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Browse Guides'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[100],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward,
                        size: 16, color: Colors.orange[100]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context) {
    return Column(
      children: [
        _buildDocumentItem(
            context,
            Icons.description_outlined,
            'National Policy 2024',
            'PDF • 2.4 MB • ENCRYPTED',
            'assets/np.pdf'),
        const SizedBox(height: 16),
        _buildDocumentItem(context, Icons.map_outlined, 'Relief Camp Map',
            'VECTOR • LIVE UPDATE', 'assets/rcm.pdf'),
        const SizedBox(height: 16),
        _buildDocumentItem(context, Icons.medical_services_outlined,
            'Triage Manual', 'PDF • 5 MB • RESTRICTED', 'assets/tm.pdf'),
      ],
    );
  }

  Widget _buildDocumentItem(BuildContext context, IconData icon, String title,
      String subtitle, String urlString) {
    return GestureDetector(
      onTap: () async {
        if (urlString.startsWith('http')) {
          final url = Uri.parse(urlString);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        } else if (urlString.startsWith('assets/')) {
          try {
            final byteData = await rootBundle.load(urlString);
            final tempDir = await getTemporaryDirectory();
            final tempFile =
                File('${tempDir.path}/${urlString.split('/').last}');
            await tempFile.writeAsBytes(byteData.buffer
                .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
            await OpenFilex.open(tempFile.path);
          } catch (e) {
            debugPrint('Error opening local asset file: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to open PDF file')),
              );
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1c1c1c),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(13)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[800]?.withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(13)),
                  ),
                  child: Icon(icon, color: Colors.grey[400]),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_rounded,
                  color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
