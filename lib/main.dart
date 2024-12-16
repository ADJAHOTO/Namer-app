import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var selectIndexInAnotherWidget = 0;
  var indexInYetAnotherWidget = 42;
  var optionASelected = false;
  var optionBSelected = false;
  var loadingInNetwork = false;

  void getNext() {
    // WordPair.random() est une methode issue de la dependance english_word qui genere des paires de mot aleatoires
    current = WordPair.random();
    notifyListeners();
  }

  //<WordPair>[] specifie que la liste vide ne devrais comptenir que des mots paires
  var favorites = <WordPair>[];

  //Methode ou fonction pour ajouter ou retirer la paire de mot
  void toggleFavorites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
                extended: true,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text("Favorites"),
                  ),
                ],
                selectedIndex: 0,
                // ignore: avoid_print
                onDestinationSelected: (value) {
                  print('selected: $value');
                }),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const GeneratorPage(),
            ),
          )
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
                child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(
                          icon: Icon(Icons.home), label: Text('Home')),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text("Favorites"),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    // ignore: avoid_print
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    })),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            )
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    //Ici on marque comme favoris une pair existant dans favoir et non si c'est pas le cas
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        BigCard(pair: pair),
        // Creer une ligne de séparation entre le Card et le bouton Next
        const SizedBox(height: 10),
        Row(
          //Indique a la Row d'occuper juste un espace minimale
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                appState.toggleFavorites();
              },
              icon: Icon(icon),
              label: const Text('Like'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                //Utilisation de la methode pour obtenir les pairs de mots apres chaque clic du boutton
                appState.getNext();
              },
              child: const Text('Next'),
            ),
          ],
        )
      ]),
    ));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) demande la couleur actuelle de namer_app
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet'),
      );
    } else {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'You have ${appState.favorites.length} favorites:',
            ),
          ),
          // Correct usage of for-loop inside a list
          for (var pair in appState.favorites)
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(pair.asLowerCase),
            ),
        ],
      );
    }
  }
}

