import '../core/models.dart';

const personalityQuizId = 'personality-axes-v1';
const intelligenceQuizId = 'intelligences-7-v1';
const questionnaireVersion = 1;

const axisLabels = <String, String>{
  'EI': 'Extraversion / Introversion',
  'SN': 'Sensation / Intuition',
  'TF': 'Pensée / Sentiment',
  'JP': 'Jugement / Perception',
};
const axisExplanations = <String, String>{
  'EI': 'E concerne l’énergie trouvée dans l’interaction ; I, celle retrouvée dans le recul. L’introversion n’est pas la timidité.',
  'SN': 'S privilégie les faits observables et l’expérience ; N, les liens, possibilités et significations.',
  'TF': 'T met d’abord en balance les principes et la cohérence ; F, les valeurs et les effets humains. Les deux peuvent être logiques et empathiques.',
  'JP': 'J apprécie davantage la décision et la structure ; P, l’adaptation et les options ouvertes. P ne signifie pas désorganisation.',
};

List<Question> _axis(
  String axis,
  List<String> reference,
  List<String> opposite,
) => [
  for (var i = 0; i < reference.length; i++)
    Question(
      id: 'p-${axis.toLowerCase()}-${(i + 1).toString().padLeft(2, '0')}',
      quizId: personalityQuizId,
      dimension: axis,
      pole: axis[0],
      text: reference[i],
      version: questionnaireVersion,
    ),
  for (var i = 0; i < opposite.length; i++)
    Question(
      id: 'p-${axis.toLowerCase()}-${(i + 11).toString().padLeft(2, '0')}',
      quizId: personalityQuizId,
      dimension: axis,
      pole: axis[1],
      text: opposite[i],
      version: questionnaireVersion,
      reversed: true,
    ),
];

final personalityQuestions = <Question>[
  ..._axis(
    'EI',
    const [
      'Après une journée calme, j’ai envie d’échanger avec plusieurs personnes.',
      'Je clarifie souvent mes idées en les disant à voix haute.',
      'Dans un nouveau groupe, je vais volontiers vers les autres.',
      'Les activités collectives me donnent généralement de l’élan.',
      'Je prends facilement la parole quand une discussion commence.',
      'Je préfère partager rapidement une idée encore incomplète.',
      'Je me sens stimulé par un environnement animé.',
      'Je cherche spontanément de la compagnie pendant mes pauses.',
      'Rencontrer plusieurs personnes nouvelles dans la même journée m’enthousiasme.',
      'Je participe volontiers à une conversation avec beaucoup d’intervenants.',
    ],
    const [
      'J’ai besoin d’un moment seul pour retrouver mon énergie.',
      'Je préfère réfléchir avant de formuler une idée.',
      'Dans un nouveau groupe, j’observe avant d’intervenir.',
      'Un long moment de solitude choisie me fait du bien.',
      'Je suis plus à l’aise dans une conversation en petit comité.',
      'Je garde d’abord mes idées pour les approfondir.',
      'Les environnements très animés finissent par m’épuiser.',
      'Je choisis volontiers une pause tranquille sans conversation.',
      'Je préfère rencontrer de nouvelles personnes une par une.',
      'Je suis à l’aise en laissant d’autres personnes occuper la parole.',
    ],
  ),
  ..._axis(
    'SN',
    const [
      'Pour apprendre, je commence volontiers par un exemple concret.',
      'Je remarque rapidement les détails pratiques d’une situation.',
      'Je fais confiance à une méthode qui a déjà fait ses preuves.',
      'Une consigne précise m’aide à bien démarrer.',
      'Je décris d’abord ce que j’ai directement observé.',
      'Je préfère traiter les faits disponibles avant les hypothèses.',
      'Je repère facilement ce qui manque dans une liste ou un plan.',
      'J’avance plus sereinement avec des étapes concrètes.',
      'Je m’intéresse à l’usage immédiat d’une nouvelle idée.',
      'Je me souviens souvent des circonstances précises d’un événement.',
    ],
    const [
      'Une idée nouvelle m’intéresse avant même que son usage soit clair.',
      'Je repère spontanément des liens entre des sujets éloignés.',
      'J’aime imaginer plusieurs futurs possibles.',
      'Une vue d’ensemble me suffit souvent pour commencer.',
      'Je cherche volontiers le sens caché derrière les faits.',
      'Explorer une hypothèse me stimule, même sans preuve immédiate.',
      'Je pense souvent en images, analogies ou associations.',
      'Je change volontiers de méthode pour essayer une possibilité.',
      'Je m’attarde davantage sur le potentiel que sur l’état actuel.',
      'Je retiens surtout l’impression générale d’un événement.',
    ],
  ),
  ..._axis(
    'TF',
    const [
      'Pour trancher, je cherche d’abord la règle la plus cohérente.',
      'Je peux critiquer une idée sans remettre en cause la personne.',
      'Dans un désaccord, je vérifie d’abord la solidité des arguments.',
      'Je préfère un retour direct qui nomme clairement le problème.',
      'Une décision juste doit appliquer des critères comparables à chacun.',
      'Je repère vite les contradictions dans un raisonnement.',
      'Quand un choix est difficile, je liste les avantages et les risques.',
      'Je peux maintenir une décision impopulaire si elle me semble fondée.',
      'Je cherche la cause d’un problème avant de rassurer.',
      'Une discussion exigeante peut être utile même si elle est inconfortable.',
    ],
    const [
      'Pour trancher, je considère d’abord l’effet sur les personnes concernées.',
      'Je choisis mes mots pour préserver la relation.',
      'Dans un désaccord, j’essaie d’abord de comprendre les valeurs de chacun.',
      'Je préfère un retour attentif au ressenti de la personne.',
      'Une décision juste peut tenir compte des situations particulières.',
      'Je remarque vite quand quelqu’un se sent exclu d’une discussion.',
      'Quand un choix est difficile, je me demande ce qui compte le plus pour moi.',
      'Je reconsidère volontiers une décision qui fragilise fortement le groupe.',
      'Je cherche à apaiser une personne avant d’analyser le problème.',
      'Je valorise un accord qui respecte les besoins exprimés.',
    ],
  ),
  ..._axis(
    'JP',
    const [
      'Je préfère savoir à l’avance comment ma journée va s’organiser.',
      'Terminer une tâche avant d’en commencer une autre me satisfait.',
      'Je prends volontiers une décision dès que les informations suffisent.',
      'Une échéance personnelle m’aide à avancer régulièrement.',
      'Je range les informations pour pouvoir les retrouver facilement.',
      'Je suis soulagé quand les choix importants sont arrêtés.',
      'Avant un déplacement, je prépare les étapes principales.',
      'Je préfère un projet avec des responsabilités clairement définies.',
      'Je traite rapidement les petites obligations en attente.',
      'Je réserve du temps précis pour mes priorités.',
    ],
    const [
      'J’aime pouvoir modifier le programme de ma journée au dernier moment.',
      'Je passe volontiers d’une tâche à une autre selon mon élan.',
      'Je garde plusieurs options ouvertes aussi longtemps que possible.',
      'Une pression proche de l’échéance peut stimuler mon action.',
      'Je retrouve souvent mes informations sans classement formel.',
      'Une décision provisoire me convient tant que la situation évolue.',
      'En voyage, je laisse volontiers une grande place à l’improvisation.',
      'Je m’adapte facilement quand les rôles d’un projet changent.',
      'Je laisse parfois de petites obligations ouvertes pour rester disponible.',
      'Je choisis souvent ma prochaine priorité selon le contexte du moment.',
    ],
  ),
];

const intelligenceLabels = <String, String>{
  'linguistique': 'Linguistique',
  'logique': 'Logico-mathématique',
  'spatiale': 'Spatiale et visuelle',
  'musicale': 'Musicale',
  'corporelle': 'Corporelle et kinesthésique',
  'interpersonnelle': 'Interpersonnelle',
  'intrapersonnelle': 'Intrapersonnelle',
};
const _intelligenceTexts = <String, List<(String, bool)>>{
  'linguistique': [
    ('J’aime chercher le mot précis pour exprimer une idée.', false),
    ('Rédiger m’aide à organiser ma pensée.', false),
    ('Je retiens facilement une tournure de phrase marquante.', false),
    ('Je prends plaisir à raconter une expérience.', false),
    ('Je lis volontiers pour approfondir un sujet.', false),
    ('Expliquer oralement une idée me vient naturellement.', false),
    ('Les jeux de mots attirent peu mon attention.', true),
    ('Mettre mes idées en phrases m’intéresse rarement.', true),
  ],
  'logique': [
    ('J’aime décomposer un problème en étapes.', false),
    ('Je cherche spontanément des régularités dans des données.', false),
    ('Vérifier une hypothèse par un essai me plaît.', false),
    ('Je suis à l’aise avec les relations de cause à effet.', false),
    ('Classer des informations selon une règle m’intéresse.', false),
    ('Je compare volontiers plusieurs solutions de façon méthodique.', false),
    ('Les problèmes chiffrés suscitent rarement ma curiosité.', true),
    ('Je préfère éviter les raisonnements à plusieurs étapes.', true),
  ],
  'spatiale': [
    ('Je visualise facilement un objet sous plusieurs angles.', false),
    ('Un schéma m’aide à comprendre une explication.', false),
    ('Je remarque les proportions et l’agencement d’un lieu.', false),
    ('Je me repère à l’aide de points de vue visuels.', false),
    ('J’aime organiser une page ou un espace.', false),
    ('Je peux imaginer le résultat d’une transformation visuelle.', false),
    ('Les cartes et plans me sont rarement utiles.', true),
    ('J’ai du mal à me représenter une forme décrite oralement.', true),
  ],
  'musicale': [
    ('Je remarque rapidement le rythme d’un morceau.', false),
    ('Une mélodie reste facilement dans ma mémoire.', false),
    ('Je distingue des changements subtils de son.', false),
    ('Je prends plaisir à reproduire un rythme.', false),
    ('La musique influence nettement mon attention.', false),
    ('J’entends quand une note ou un rythme semble décalé.', false),
    ('Je remarque peu les motifs sonores autour de moi.', true),
    ('Suivre une pulsation régulière me paraît difficile.', true),
  ],
  'corporelle': [
    ('J’apprends volontiers un geste en le pratiquant.', false),
    ('Bouger m’aide à maintenir mon attention.', false),
    ('Je coordonne facilement mes mouvements dans une activité.', false),
    ('Manipuler un objet m’aide à comprendre son fonctionnement.', false),
    ('Je remarque les signaux physiques de tension ou de fatigue.', false),
    (
      'Je prends plaisir aux activités qui demandent de la précision gestuelle.',
      false,
    ),
    ('Je préfère ne pas apprendre par la manipulation.', true),
    ('Exprimer une idée par le mouvement me semble peu naturel.', true),
  ],
  'interpersonnelle': [
    ('Je remarque les changements d’ambiance dans un groupe.', false),
    ('J’adapte mon explication à la personne qui m’écoute.', false),
    ('Je prends plaisir à faire coopérer plusieurs personnes.', false),
    ('Je comprends souvent ce qui motive un désaccord.', false),
    ('Les autres viennent parfois chercher mon écoute.', false),
    ('Je trouve des façons de mettre chacun à l’aise.', false),
    ('Je remarque rarement qu’une personne se met en retrait.', true),
    ('Coordonner mes actions avec un groupe m’intéresse peu.', true),
  ],
  'intrapersonnelle': [
    ('Je peux nommer ce que je ressens avec précision.', false),
    ('Je connais les conditions dans lesquelles je travaille le mieux.', false),
    ('Je prends du recul pour comprendre mes réactions.', false),
    ('Je remarque quand une décision contredit mes valeurs.', false),
    ('Je me fixe des objectifs cohérents avec mes priorités.', false),
    ('Je sais reconnaître mes limites du moment.', false),
    ('J’examine rarement les raisons de mes choix.', true),
    ('Identifier mes besoins personnels me semble peu utile.', true),
  ],
};
final intelligenceQuestions = [
  for (final d in _intelligenceTexts.entries)
    for (var i = 0; i < d.value.length; i++)
      Question(
        id: 'i-${d.key}-${(i + 1).toString().padLeft(2, '0')}',
        quizId: intelligenceQuizId,
        dimension: d.key,
        text: d.value[i].$1,
        reversed: d.value[i].$2,
        version: questionnaireVersion,
      ),
];

const typeSummaries = <String, String>{
  'ISTJ': 'Fiable et attentif aux faits, ce profil cherche souvent à rendre les engagements concrets et durables.',
  'ISFJ': 'Attentif aux besoins observables, ce profil contribue avec constance et un sens discret du soin.',
  'INFJ': 'Guidé par une vision intérieure et des valeurs relationnelles, ce profil cherche une cohérence porteuse de sens.',
  'INTJ': 'Tourné vers les systèmes et le long terme, ce profil aime transformer une vision en stratégie.',
  'ISTP': 'Observateur et pragmatique, ce profil explore volontiers le fonctionnement réel des choses.',
  'ISFP': 'Sensible à l’expérience présente, ce profil agit souvent en accord avec des valeurs personnelles discrètes.',
  'INFP': 'Imaginatif et attaché à l’authenticité, ce profil explore les possibles à partir de convictions intimes.',
  'INTP': 'Curieux des principes, ce profil aime construire et réviser des modèles explicatifs.',
  'ESTP': 'Réactif et concret, ce profil mobilise volontiers les ressources disponibles pour agir maintenant.',
  'ESFP': 'Expressif et attentif au vivant, ce profil apporte souvent énergie et sens du moment partagé.',
  'ENFP': 'Enthousiaste devant les possibilités humaines, ce profil relie volontiers idées, personnes et valeurs.',
  'ENTP': 'Explorateur d’idées, ce profil aime tester les conventions et ouvrir des pistes inattendues.',
  'ESTJ': 'Structuré et orienté vers l’action, ce profil organise volontiers les moyens autour d’un objectif clair.',
  'ESFJ': 'Coopératif et concret, ce profil veille souvent à la coordination et à la qualité des liens.',
  'ENFJ': 'Mobilisateur et attentif au potentiel des personnes, ce profil cherche volontiers un cap collectif porteur de sens.',
  'ENTJ': 'Décidé et stratégique, ce profil aime structurer les efforts pour atteindre une ambition partagée.',
};
const preferenceNames = <String, String>{
  'E': 'Extraversion',
  'I': 'Introversion',
  'S': 'Sensation',
  'N': 'Intuition',
  'T': 'Pensée',
  'F': 'Sentiment',
  'J': 'Jugement',
  'P': 'Perception',
};
List<String> strengthsFor(String code) => [
  if (code.contains('I'))
    'Approfondissement et recul'
  else
    'Élan dans l’échange',
  if (code.contains('N'))
    'Vision des possibilités'
  else
    'Attention aux faits utiles',
  if (code.contains('F'))
    'Prise en compte des valeurs'
  else
    'Analyse cohérente des choix',
  if (code.contains('P'))
    'Souplesse face au changement'
  else
    'Organisation et continuité',
];
String typeDetail(String code) =>
    '${typeSummaries[code]} Ces préférences ne décrivent ni une capacité ni une identité figée : une personne peut utiliser chaque pôle selon le contexte, son expérience et ses besoins.';
const intelligenceDescriptions = <String, String>{
  'linguistique': 'Sensibilité aux mots, aux nuances du langage et à la construction d’un récit. À explorer par la lecture variée, l’écriture courte ou l’explication orale.',
  'logique': 'Goût possible pour les structures, les relations et la résolution progressive de problèmes. Essayez une énigme, un tableau comparatif ou une petite expérience.',
  'spatiale': 'Attention aux formes, positions, images et transformations visuelles. Un croquis, une carte mentale ou un objet à assembler peut nourrir cette dimension.',
  'musicale': 'Sensibilité aux rythmes, hauteurs et motifs sonores. Explorer ne demande pas d’être musicien : écouter activement ou reproduire un rythme suffit.',
  'corporelle': 'Usage du mouvement, du geste et des sensations pour agir ou comprendre. Essayez d’apprendre debout, de manipuler ou de répéter un geste lentement.',
  'interpersonnelle': 'Attention aux dynamiques entre personnes et adaptation dans la coopération. Une écoute reformulée ou un projet en binôme peut l’explorer.',
  'intrapersonnelle': 'Capacité à observer ses états, valeurs et manières de fonctionner. Un journal bref ou une pause de bilan peut soutenir cette exploration.',
};
const scaleLabels = [
  'Pas du tout d’accord',
  'Plutôt pas d’accord',
  'Ni d’accord ni pas d’accord',
  'Plutôt d’accord',
  'Tout à fait d’accord',
];
