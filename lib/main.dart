import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Praktikum PBM 3'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  final List<Map<String, dynamic>> _players = [
    {
      'nama': 'Lionel Messi',
      'negara': 'Argentina',
      'klub': 'Inter Miami CF',
      'rating': 5,
      'foto': 'assets/images/messi.jpg',
    },
    {
      'nama': 'Cristiano Ronaldo',
      'negara': 'Portugal',
      'klub': 'Al Nassr',
      'rating': 4,
      'foto': 'assets/images/ronaldo.jpg',
    },
    {
      'nama': 'Kylian Mbappé',
      'negara': 'Prancis',
      'klub': 'Real Madrid',
      'rating': 5,
      'foto': 'assets/images/mbappe.jpg',
    },
    {
      'nama': 'Erling Haaland',
      'negara': 'Norwegia',
      'klub': 'Manchester City',
      'rating': 4,
      'foto': 'assets/images/haaland.jpg',
    },
    {
      'nama': 'Vinicius Jr.',
      'negara': 'Brasil',
      'klub': 'Real Madrid',
      'rating': 4,
      'foto': 'assets/images/vinicius.jpg',
    },
    {
      'nama': 'Rodri',
      'negara': 'Spanyol',
      'klub': 'Manchester City',
      'rating': 5,
      'foto': 'assets/images/rodri.jpg',
    },
    {
      'nama': 'Lamine Yamal',
      'negara': 'Spanyol',
      'klub': 'FC Barcelona',
      'rating': 4,
      'foto': 'assets/images/yamal.jpg',
    },
  ];

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: 22,
        );
      }),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1A7A6E), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            ClipOval(
              child: Image.asset(
                player['foto'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: const Color(0xFF1A7A6E),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF1A7A6E),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player['nama'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    player['negara'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    player['klub'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStarRating(player['rating']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(widget.title),
        leading: const Icon(Icons.menu),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ),
      body: Column(
        children: [
          
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1A7A6E), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Data Pemain Sepakbola',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                return _buildPlayerCard(_players[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Pencarian",
          ),
        ],
      ),
    );
  }
}