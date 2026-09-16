# Rapport final

## Implémenté

Deux questionnaires embarqués, score déterministe, reprise après chaque réponse, historique, suppression et comparaison des deux dernières passations compatibles, bibliothèque de 16 types et 7 intelligences, favoris, pseudonyme, réduction d’animations, export/import JSON, effacement complet, carte PNG partageable, politique locale sans sauvegarde Android.

## Vérifications

`dart format`, `flutter analyze` (aucun problème) et `flutter test` (6 tests réussis) ont été exécutés après l’ajout de la comparaison. `flutter build apk --debug` a produit `build/app/outputs/flutter-apk/app-debug.apk` (157 214 151 octets, APK universel de débogage ; SHA-256 `7A11AC6A7F4C58DD07CFE9159E3AB3E17AE6F76572A8855F5C345CAB9287E16D`). La cible fusionnée est API 36 et le minimum API 24. Les essais TalkBack, mode avion, fermeture forcée et différentes tailles n’ont pas pu être confirmés faute d’appareil Android connecté.

## Limites et actions externes

L’import se fait par presse-papiers plutôt que par sélecteur de fichier. Les tests d’intégration sur appareil et l’audit éditorial complet restent à approfondir. L’icône générique doit être remplacée. Le build AAB release a échoué parce que la stratégie de contrôle d’application Windows bloque l’exécutable Flutter `gen_snapshot.exe`; aucun AAB n’a donc été produit. La signature, les captures, l’URL de confidentialité et les formulaires Play sont externes.
