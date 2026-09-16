# Suivi

- [x] Prompts lus ; le correctif des 16 types est prioritaire.
- [x] Dossier inspecté : initialement vide, sans `AGENTS.md`.
- [x] Versions identifiées : Flutter 3.47.2 stable, Dart 3.13.2.
- [x] Projet Flutter initialisé.
- [x] Contenus et moteur de score.
- [x] Persistance et fonctionnalités hors ligne.
- [x] Interface et parcours essentiels.
- [x] Formatage, analyse et tests unitaires/widgets.
- [x] APK debug généré.
- [x] Documentation Android/Play et procédure de signature.
- [ ] AAB release : bloqué par la stratégie Windows qui interdit `gen_snapshot.exe`.

## Observations d'environnement

- La commande enveloppe `flutter` attend actuellement un verrou du SDK détenu par un processus Flutter existant ; les outils peuvent être appelés directement via leur snapshot si nécessaire.
- Android SDK 37.0.0, cible effective API 36, minimum API 24 ; Java OpenJDK 25.0.2 fourni par Android Studio.
- Aucun appareil Android connecté ; Windows, Chrome et Edge seulement. Les validations physiques n’ont donc pas été exécutées.
