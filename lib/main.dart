import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'content/content.dart';
import 'core/models.dart';
import 'core/scoring.dart';
import 'data/local_store.dart';

const ink = Color(0xFF09090B),
    surface = Color(0xFF17171B),
    surface2 = Color(0xFF222227),
    gold = Color(0xFFF5C542),
    muted = Color(0xFFB7B7C2);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(LocalStore());
  await state.load();
  runApp(EclatApp(state));
}

class AppState extends ChangeNotifier {
  AppState(this.store);
  final LocalStore store;
  String nickname = '';
  bool reduceMotion = false, onboarded = false;
  List<SavedResult> results = [];
  Set<String> favorites = {};
  Future<void> load() async {
    nickname = await store.setting('nickname') ?? '';
    reduceMotion = await store.setting('reduceMotion') == 'true';
    onboarded = await store.setting('onboarded') == 'true';
    results = await store.results();
    favorites = await store.favorites();
  }

  Future<void> onboard(String name) async {
    nickname = name.trim();
    onboarded = true;
    await store.setSetting('nickname', nickname);
    await store.setSetting('onboarded', 'true');
    notifyListeners();
  }

  Future<void> name(String v) async {
    nickname = v.trim();
    await store.setSetting('nickname', nickname);
    notifyListeners();
  }

  Future<void> motion(bool v) async {
    reduceMotion = v;
    await store.setSetting('reduceMotion', '$v');
    notifyListeners();
  }

  Future<void> refresh() async {
    results = await store.results();
    favorites = await store.favorites();
    notifyListeners();
  }

  Future<void> favorite(String id) async {
    await store.toggleFavorite(id);
    await refresh();
  }

  Future<void> clear() async {
    await store.deleteAll();
    nickname = '';
    reduceMotion = false;
    results = [];
    favorites = {};
    await store.setSetting('onboarded', 'true');
    notifyListeners();
  }
}

class EclatApp extends StatelessWidget {
  const EclatApp(this.state, {super.key});
  final AppState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (_, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Éclat — Se connaître',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ink,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          surface: surface,
          onPrimary: ink,
        ),
        cardTheme: const CardThemeData(
          color: surface,
          margin: EdgeInsets.symmetric(vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: ink,
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: gold,
        ),
      ),
      home: state.onboarded ? Shell(state) : Onboarding(state),
    ),
  );
}

class Onboarding extends StatefulWidget {
  const Onboarding(this.state, {super.key});
  final AppState state;
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final c = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.auto_awesome, color: gold, size: 56),
              Text(
                'Éclat',
                style: Theme.of(context).textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Se connaître, sans se mettre dans une case.',
                style: TextStyle(color: muted, fontSize: 18),
              ),
              const SizedBox(height: 24),
              const Info(
                Icons.offline_bolt_outlined,
                'Tout reste sur cet appareil',
                'Questions, calculs et historique fonctionnent hors ligne. Aucun compte, publicité, suivi ou serveur.',
              ),
              const Info(
                Icons.explore_outlined,
                'Une exploration, pas un diagnostic',
                'Ces tendances autodéclarées peuvent varier. Cet outil n’est pas le questionnaire MBTI officiel et n’est pas un diagnostic psychologique.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Prénom ou pseudonyme (facultatif)',
                ),
              ),
              ElevatedButton(
                onPressed: () => widget.state.onboard(c.text),
                child: const Text('Commencer sans inscription'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell(this.state, {super.key});
  final AppState state;
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(widget.state),
      Library(widget.state),
      History(widget.state),
      Settings(widget.state),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: i, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Bibliothèque',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard(this.state, {super.key});
  final AppState state;
  Future<void> open(BuildContext c, QuizKind k) async {
    await Navigator.push(
      c,
      MaterialPageRoute(builder: (_) => QuizIntro(state, k)),
    );
    await state.refresh();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        state.nickname.isEmpty ? 'Bonjour' : 'Bonjour, ${state.nickname}',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const Text(
        'Que souhaitez-vous explorer aujourd’hui ?',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 18),
      QuizCard(
        Icons.person_search_outlined,
        'Préférences de personnalité',
        '80 affirmations • environ 10–15 min',
        'Questionnaire original inspiré du modèle à 16 types.',
        () => open(context, QuizKind.personality),
      ),
      QuizCard(
        Icons.psychology_alt_outlined,
        '7 formes d’intelligence',
        '56 affirmations • environ 7–10 min',
        'Grille inspirée des sept intelligences initialement proposées par Howard Gardner.',
        () => open(context, QuizKind.intelligences),
      ),
      const Info(
        Icons.lightbulb_outline,
        'Suggestion du jour',
        'Dessinez une idée, expliquez-la à voix haute ou essayez-la par un geste. Observez ce qui change.',
      ),
      if (state.results.isNotEmpty) ...[
        const Heading('Dernier résultat'),
        ResultTile(state.results.first, state),
      ],
    ],
  );
}

class QuizIntro extends StatelessWidget {
  const QuizIntro(this.state, this.kind, {super.key});
  final AppState state;
  final QuizKind kind;
  @override
  Widget build(BuildContext context) {
    final p = kind == QuizKind.personality;
    return Scaffold(
      appBar: AppBar(title: const Text('Avant de commencer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            p ? Icons.person_search : Icons.psychology_alt,
            size: 56,
            color: gold,
          ),
          const SizedBox(height: 18),
          Text(
            p ? 'Vos préférences du moment' : 'Vos façons d’explorer',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            p
                ? 'Un questionnaire original autour de quatre axes associés aux 16 types. Il n’est ni le questionnaire MBTI officiel, ni un diagnostic.'
                : 'Une grille inspirée de sept intelligences proposées par Howard Gardner. Elle ne mesure pas objectivement l’intelligence et ne prescrit aucun style d’apprentissage.',
          ),
          const SizedBox(height: 14),
          const Text(
            'Répondez selon ce qui vous ressemble aujourd’hui. Il n’existe pas de bonne réponse. Chaque choix est sauvegardé.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Quiz(state, kind)),
            ),
            child: const Text('Commencer ou reprendre'),
          ),
        ],
      ),
    );
  }
}

class Quiz extends StatefulWidget {
  const Quiz(this.state, this.kind, {super.key});
  final AppState state;
  final QuizKind kind;
  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  late final List<Question> qs;
  final ans = <String, int>{};
  int i = 0;
  bool load = true;
  @override
  void initState() {
    super.initState();
    qs = widget.kind == QuizKind.personality
        ? personalityQuestions
        : intelligenceQuestions;
    restore();
  }

  Future<void> restore() async {
    final s = await widget.state.store.loadSession(
      qs.first.quizId,
      questionnaireVersion,
    );
    if (s != null) {
      ans.addAll(s.answers);
      i = s.index.clamp(0, qs.length - 1);
    }
    if (mounted) setState(() => load = false);
  }

  Future<void> answer(int v) async {
    setState(() => ans[qs[i].id] = v);
    final n = i < qs.length - 1 ? i + 1 : i;
    await widget.state.store.saveSession(
      qs.first.quizId,
      questionnaireVersion,
      n,
      ans,
    );
    if (mounted && i < qs.length - 1) setState(() => i++);
  }

  Future<void> finish() async {
    if (ans.length != qs.length) {
      setState(() => i = qs.indexWhere((q) => !ans.containsKey(q.id)));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Toutes les affirmations doivent recevoir une réponse.',
          ),
        ),
      );
      return;
    }
    final scores = const ScoreEngine().calculate(qs, ans).scores;
    final r = SavedResult(
      id: '${qs.first.quizId}-${DateTime.now().microsecondsSinceEpoch}',
      kind: widget.kind,
      version: 1,
      createdAt: DateTime.now(),
      scores: scores,
    );
    await widget.state.store.addResult(r);
    await widget.state.store.clearSession(qs.first.quizId);
    await widget.state.refresh();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Results(r, widget.state)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (load) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final q = qs[i];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.kind == QuizKind.personality
              ? 'Personnalité'
              : 'Intelligences',
        ),
        actions: [
          IconButton(
            tooltip: 'Quitter et reprendre plus tard',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (i + 1) / qs.length, minHeight: 6),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${i + 1} / ${qs.length}',
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${ans.length} réponses',
                    style: const TextStyle(color: muted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      q.text,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(height: 1.35, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (var v = 1; v <= 5; v++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Semantics(
                        button: true,
                        selected: ans[q.id] == v,
                        label: '${scaleLabels[v - 1]}, $v sur 5',
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            foregroundColor: ans[q.id] == v
                                ? ink
                                : Colors.white,
                            backgroundColor: ans[q.id] == v ? gold : surface,
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () => answer(v),
                          child: Text(scaleLabels[v - 1]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Question précédente',
                    onPressed: i == 0 ? null : () => setState(() => i--),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  if (i == qs.length - 1)
                    ElevatedButton(
                      onPressed: finish,
                      child: const Text('Voir mes résultats'),
                    )
                  else
                    TextButton(
                      onPressed: ans.containsKey(q.id)
                          ? () => setState(() => i++)
                          : null,
                      child: const Text('Suivant'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

PersonalityResult fromScores(Map<String, double> s) {
  final l = <String, String?>{}, n = <String>{}, soft = <String>{};
  for (final a in ['EI', 'SN', 'TF', 'JP']) {
    final v = s[a]!;
    if (v == 50) {
      l[a] = null;
      n.add(a);
    } else {
      l[a] = v > 50 ? a[0] : a[1];
      if (v >= 45 && v <= 55) soft.add(a);
    }
  }
  return PersonalityResult(axes: s, letters: l, neutralAxes: n, softAxes: soft);
}

class Results extends StatelessWidget {
  const Results(this.result, this.state, {super.key});
  final SavedResult result;
  final AppState state;
  Future<void> share() async {
    final title = result.kind == QuizKind.personality
        ? fromScores(result.scores).typeCode ?? 'Profil mixte'
        : 'Mes formes d’intelligence';
    final rec = ui.PictureRecorder(), canvas = Canvas(rec);
    const size = Size(1080, 1080);
    canvas.drawRect(Offset.zero & size, Paint()..color = ink);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(80, 80, 920, 920),
        const Radius.circular(48),
      ),
      Paint()..color = surface,
    );
    void text(String t, double y, double fs, Color c) {
      final p = TextPainter(
        text: TextSpan(
          text: t,
          style: TextStyle(color: c, fontSize: fs, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 820);
      p.paint(canvas, Offset(130, y));
    }

    text('ÉCLAT — SE CONNAÎTRE', 150, 34, gold);
    text(title, 310, 88, Colors.white);
    text('Une exploration personnelle', 760, 40, muted);
    text('Indices issus de mes réponses • pas un diagnostic', 850, 28, muted);
    final image = await rec.endRecording().toImage(1080, 1080),
        bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes!.buffer.asUint8List(),
            mimeType: 'image/png',
            name: 'eclat-resultat.png',
          ),
        ],
        text: 'Mon exploration personnelle avec Éclat.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pers = result.kind == QuizKind.personality,
        p = pers ? fromScores(result.scores) : null,
        sorted = result.scores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
        actions: [
          IconButton(
            tooltip: 'Partager une carte',
            onPressed: share,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (pers) ...[
            Text(
              p!.typeCode ?? 'Profil mixte',
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(color: gold, fontWeight: FontWeight.bold),
            ),
            Text(
              p.typeCode == null
                  ? 'Préférence indéterminée sur au moins un axe. Types possibles : ${p.possibleTypes.join(', ')}.'
                  : typeSummaries[p.typeCode]!,
              style: const TextStyle(fontSize: 17),
            ),
            if (p.softAxes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Préférence peu marquée : ${p.softAxes.map((e) => axisLabels[e]).join(', ')}. La zone 45–55 est une convention sans validation scientifique.',
                  style: const TextStyle(color: muted),
                ),
              ),
          ],
          if (!pers) ...[
            Text(
              'Votre paysage',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: gold, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Chaque indice est indépendant ; ils ne totalisent pas 100.',
              style: TextStyle(color: muted),
            ),
          ],
          const SizedBox(height: 20),
          for (final e in sorted)
            ScoreBar(
              pers ? axisLabels[e.key]! : intelligenceLabels[e.key]!,
              e.value,
              pers ? e.key : null,
            ),
          const Info(
            Icons.info_outline,
            'Comment lire ces indices',
            'Ils viennent uniquement de vos réponses. Ce ne sont ni des probabilités, ni des percentiles, ni des mesures psychométriques validées.',
          ),
          if (pers && p!.typeCode != null)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TypeDetail(p.typeCode!, state),
                ),
              ),
              child: Text('Explorer ${p.typeCode}'),
            ),
          if (!pers) ...[
            const Heading('Activités à essayer'),
            for (final e in sorted.take(3))
              ListTile(
                title: Text(intelligenceLabels[e.key]!),
                subtitle: Text(intelligenceDescriptions[e.key]!),
              ),
            const Text(
              'Explorez aussi une dimension moins présente par une petite activité, sans obligation.',
              style: TextStyle(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

class Library extends StatefulWidget {
  const Library(this.state, {super.key});
  final AppState state;
  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  String q = '';
  bool fav = false;
  @override
  Widget build(BuildContext context) {
    final types = typeSummaries.keys.where(
      (e) =>
          (!fav || widget.state.favorites.contains(e)) &&
          e.toLowerCase().contains(q.toLowerCase()),
    );
    final ints = intelligenceLabels.entries.where(
      (e) =>
          (!fav || widget.state.favorites.contains(e.key)) &&
          e.value.toLowerCase().contains(q.toLowerCase()),
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Bibliothèque',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => q = v),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Rechercher',
          ),
        ),
        SwitchListTile(
          value: fav,
          onChanged: (v) => setState(() => fav = v),
          title: const Text('Favoris uniquement'),
        ),
        const Heading('16 types de personnalité'),
        for (final code in types)
          Card(
            child: ListTile(
              title: Text(
                code,
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                typeSummaries[code]!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                widget.state.favorites.contains(code)
                    ? Icons.star
                    : Icons.star_border,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TypeDetail(code, widget.state),
                ),
              ),
              onLongPress: () => widget.state.favorite(code),
            ),
          ),
        const Heading('7 formes d’intelligence'),
        for (final e in ints)
          Card(
            child: ListTile(
              title: Text(e.value),
              subtitle: Text(
                intelligenceDescriptions[e.key]!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                onPressed: () => widget.state.favorite(e.key),
                icon: Icon(
                  widget.state.favorites.contains(e.key)
                      ? Icons.star
                      : Icons.star_border,
                  color: gold,
                ),
              ),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(e.value),
                  content: Text(intelligenceDescriptions[e.key]!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class TypeDetail extends StatelessWidget {
  const TypeDetail(this.code, this.state, {super.key});
  final String code;
  final AppState state;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(code),
      actions: [
        IconButton(
          onPressed: () => state.favorite(code),
          icon: Icon(
            state.favorites.contains(code) ? Icons.star : Icons.star_border,
            color: gold,
          ),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          code,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(color: gold, fontWeight: FontWeight.bold),
        ),
        Text(
          typeDetail(code),
          style: const TextStyle(fontSize: 17, height: 1.5),
        ),
        const Heading('Les quatre préférences'),
        Wrap(
          spacing: 8,
          children: [
            for (final l in code.split(''))
              Chip(label: Text('$l • ${preferenceNames[l]}')),
          ],
        ),
        const Heading('Forces possibles'),
        for (final s in strengthsFor(code))
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: gold),
            title: Text(s),
          ),
        const Heading('Points d’attention'),
        const Text(
          'Une préférence peut devenir un automatisme. Laisser une place au rythme d’autrui, aux faits comme aux intuitions, entretient la souplesse.',
        ),
        const Heading('Communication et projets'),
        Text(
          'Dans un collectif, $code peut contribuer par ${strengthsFor(code).join(', ').toLowerCase()}. Une demande claire précise le besoin, l’urgence et la place des questions.',
        ),
        const Heading('Pistes de développement'),
        const Text(
          'Essayez ponctuellement le pôle opposé et notez ce que cette expérience apporte.',
        ),
        const Heading('Questions de réflexion'),
        const Text(
          '• Quand ces préférences m’aident-elles ?\n• Quand ai-je utilisé un pôle opposé ?\n• De quoi mon entourage a-t-il besoin ?',
        ),
        const SizedBox(height: 20),
        const Text(
          'Aucun type n’est supérieur. Cette fiche ne prédit ni métier, ni réussite, ni compatibilité.',
          style: TextStyle(color: muted),
        ),
      ],
    ),
  );
}

class History extends StatelessWidget {
  const History(this.state, {super.key});
  final AppState state;
  void compareLatest(BuildContext context) {
    final first = state.results[0], second = state.results[1];
    if (first.kind != second.kind ||
        first.version != second.version ||
        first.scores.keys
            .toSet()
            .difference(second.scores.keys.toSet())
            .isNotEmpty) {
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Comparaison impossible'),
          content: Text(
            'Les deux résultats les plus récents utilisent des types, versions ou formats différents.',
          ),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deux passations comparées'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final key in first.scores.keys)
                ListTile(
                  title: Text(
                    first.kind == QuizKind.personality
                        ? axisLabels[key]!
                        : intelligenceLabels[key]!,
                  ),
                  subtitle: Text(
                    '${second.scores[key]!.round()} → ${first.scores[key]!.round()}',
                  ),
                  trailing: Text(
                    (first.scores[key]! - second.scores[key]!).round().toString().replaceFirst('-', '−'),
                    style: const TextStyle(color: gold),
                  ),
                ),
              const Text(
                'Une variation reflète ces deux passations ; elle ne mesure pas une progression.',
                style: TextStyle(color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Historique',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const Text(
        'Comparaison directe uniquement entre questionnaires de même type et version.',
        style: TextStyle(color: muted),
      ),
      if (state.results.length >= 2)
        OutlinedButton.icon(
          onPressed: () => compareLatest(context),
          icon: const Icon(Icons.compare_arrows),
          label: const Text('Comparer les deux plus récents'),
        ),
      if (state.results.isEmpty)
        const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: Text('Aucun résultat enregistré.')),
        )
      else
        for (final r in state.results)
          Dismissible(
            key: ValueKey(r.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red.shade800,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.delete),
            ),
            confirmDismiss: (_) => showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Supprimer ce résultat ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            ),
            onDismissed: (_) async {
              await state.store.deleteResult(r.id);
              await state.refresh();
            },
            child: ResultTile(r, state),
          ),
    ],
  );
}

class Settings extends StatefulWidget {
  const Settings(this.state, {super.key});
  final AppState state;
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final c = TextEditingController(text: widget.state.nickname);
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Réglages',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const Heading('Profil local'),
      TextField(
        controller: c,
        maxLength: 40,
        decoration: const InputDecoration(labelText: 'Pseudonyme'),
      ),
      ElevatedButton(
        onPressed: () => widget.state.name(c.text),
        child: const Text('Enregistrer'),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Réduire les animations'),
        value: widget.state.reduceMotion,
        onChanged: widget.state.motion,
      ),
      const Heading('Données'),
      ListTile(
        leading: const Icon(Icons.upload_file),
        title: const Text('Exporter en JSON'),
        subtitle: const Text('Copier un export versionné.'),
        onTap: () async {
          await Clipboard.setData(
            ClipboardData(text: await widget.state.store.exportJson()),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Export copié.')));
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.download),
        title: const Text('Importer depuis le presse-papiers'),
        onTap: () async {
          try {
            final data = (await Clipboard.getData('text/plain'))?.text ?? '',
                n = await widget.state.store.importJson(data);
            await widget.state.refresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$n nouveau(x) résultat(s). Doublons ignorés.'),
                ),
              );
            }
          } on FormatException catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.message)));
            }
          }
        },
      ),
      ListTile(
        textColor: Colors.red.shade300,
        iconColor: Colors.red.shade300,
        leading: const Icon(Icons.delete_forever),
        title: const Text('Supprimer toutes les données'),
        onTap: () async {
          final yes = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Tout supprimer ?'),
              content: const Text(
                'Sessions, résultats, favoris et réglages seront effacés.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          );
          if (yes == true) await widget.state.clear();
        },
      ),
      const Heading('Confidentialité'),
      const Text(
        'Aucune donnée ne quitte l’appareil sans partage ou export. Aucun compte, serveur, suivi, publicité ou appel distant. La sauvegarde Android est désactivée.',
      ),
      const Heading('Méthodologie et sources'),
      const Text(
        'Personnalité : questionnaire original inspiré du modèle à 16 types, sans affiliation au MBTI®. Intelligences : grille inspirée des sept intelligences initialement proposées par Howard Gardner. Version de contenu 1.',
      ),
      const Heading('À propos'),
      const Text(
        'Éclat — Se connaître\nVersion 1.0.0\nOutil d’introspection non clinique. Relecture éditoriale humaine recommandée avant publication.',
      ),
    ],
  );
}

class Info extends StatelessWidget {
  const Info(this.icon, this.title, this.text, {super.key});
  final IconData icon;
  final String title, text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(text, style: const TextStyle(color: muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class QuizCard extends StatelessWidget {
  const QuizCard(
    this.icon,
    this.title,
    this.subtitle,
    this.text,
    this.tap, {
    super.key,
  });
  final IconData icon;
  final String title, subtitle, text;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: tap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: gold, size: 34),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(subtitle, style: const TextStyle(color: gold)),
            const SizedBox(height: 7),
            Text(text, style: const TextStyle(color: muted)),
            const SizedBox(height: 12),
            const Text(
              'Explorer  →',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

class ScoreBar extends StatelessWidget {
  const ScoreBar(this.label, this.value, this.axis, {super.key});
  final String label;
  final double value;
  final String? axis;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Semantics(
      label: '$label, ${value.round()} sur 100',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${value.round()} / 100',
                style: const TextStyle(color: gold),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 12,
              backgroundColor: surface2,
            ),
          ),
          if (axis != null)
            Text(
              '${axis![1]}  ←  ${value == 50
                  ? 'indéterminé'
                  : value > 50
                  ? axis![0]
                  : axis![1]}  →  ${axis![0]}',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
        ],
      ),
    ),
  );
}

class Heading extends StatelessWidget {
  const Heading(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 9),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

class ResultTile extends StatelessWidget {
  const ResultTile(this.result, this.state, {super.key});
  final SavedResult result;
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final p = result.kind == QuizKind.personality
        ? fromScores(result.scores)
        : null;
    return Card(
      child: ListTile(
        leading: Icon(
          result.kind == QuizKind.personality
              ? Icons.person_search
              : Icons.psychology,
          color: gold,
        ),
        title: Text(
          p?.typeCode ??
              (result.kind == QuizKind.personality
                  ? 'Profil mixte'
                  : '7 intelligences'),
        ),
        subtitle: Text(
          '${result.createdAt.day.toString().padLeft(2, '0')}/${result.createdAt.month.toString().padLeft(2, '0')}/${result.createdAt.year} • version ${result.version}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Results(result, state)),
        ),
      ),
    );
  }
}
