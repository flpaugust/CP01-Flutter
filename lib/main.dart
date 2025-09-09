import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ---------------------------
// ROTAS
// ---------------------------
class AppRoutes {
  static const home = '/';
  static const details = '/details';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const SportListScreen(),
      details: (context) => const SportDetailScreen(),
    };
  }
}

// ---------------------------
// MODELO DE SPORT
// ---------------------------
class Sport {
  final int id;
  final String image;
  final String name;
  final String description;
  final double popularity;

  Sport({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.popularity,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      description: json['description'],
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'description': description,
      'popularity': popularity,
    };
  }
}

// ---------------------------
// APP PRINCIPAL
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Sports',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.home,
    );
  }
}

// ---------------------------
// TELA DE LISTA
// ---------------------------
class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  State<SportListScreen> createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  List<Sport> sports = [];
  Sport? lastViewed;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadSports();
    await _loadLastViewed();
    setState(() {});
  }

  Future<void> _loadSports() async {
     // TODO: carregar JSON de assets/data/sports.json e preencher lista sports

    try {
      final String response = await rootBundle.loadString('assets/data/sports.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        sports = data.map((json) => Sport.fromJson(json)).toList();
      });
    } catch (e) {
    }
  }

  Future<void> _loadLastViewed() async {
      // TODO: carregar último esporte visto de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? sportJson = prefs.getString('lastViewedSport');
    if (sportJson != null) {
      setState(() {
        lastViewed = Sport.fromJson(json.decode(sportJson));
      });
    }
  }

  Future<void> _saveLastViewed(Sport sport) async {
    // TODO: salvar esporte em SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastViewedSport', json.encode(sport.toJson()));
  }

  void _openDetails(Sport sport) async {
    // TODO: abrir SportDetailScreen via Navigator e salvar como último visto
    await _saveLastViewed(sport);
    await Navigator.pushNamed(context, AppRoutes.details, arguments: sport);
    _loadLastViewed();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: montar Scaffold com AppBar, seção "Último esporte visto" e lista de esportes

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Last Viewed Sport',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          LastViewedCard(
            sport: lastViewed,
            onTap: lastViewed != null ? () => _openDetails(lastViewed!) : null,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'All Sports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sports.length,
              itemBuilder: (context, index) {
                final sport = sports[index];
                return SportCard(
                  sport: sport,
                  onTap: () => _openDetails(sport),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// WIDGET: CARD ÚLTIMO SPORT
// ---------------------------
class LastViewedCard extends StatelessWidget {
  final Sport? sport;
  final VoidCallback? onTap;

  const LastViewedCard({super.key, this.sport, this.onTap});

  @override
  Widget build(BuildContext context) {
    // TODO: retornar Card com informações do último esporte ou SizedBox.shrink() se null
    if (sport == null) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        leading: Image.asset(sport!.image, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(sport!.name),
        subtitle: Text(sport!.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------
// WIDGET: CARD SPORT
// ---------------------------
class SportCard extends StatelessWidget {
  final Sport sport;
  final VoidCallback? onTap;

  const SportCard({super.key, required this.sport, this.onTap});

  @override
  // TODO: retornar Card/ListTile com nome, imagem, categoria e descrição do esporte

  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Image.asset(sport.image, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(sport.name),
        subtitle: Text(sport.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------
// TELA DE DETALHES
// ---------------------------
class SportDetailScreen extends StatelessWidget {
  const SportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
  // TODO: recuperar esporte via ModalRoute e exibir detalhes (imagem, nome, categoria, popularidade, descrição)

    final sport = ModalRoute.of(context)!.settings.arguments as Sport;

    return Scaffold(
      appBar: AppBar(
        title: Text(sport.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                sport.image,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              sport.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              sport.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8.0),
                Text(
                  'Popularity: ${sport.popularity}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}