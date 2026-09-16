# Signature Android

1. Créer un keystore de téléversement hors du dépôt avec `keytool`.
2. Créer localement `android/key.properties` avec `storeFile`, `storePassword`, `keyAlias` et `keyPassword`.
3. Ajouter dans `android/app/build.gradle.kts` une `signingConfig` release qui lit ce fichier, puis l’assigner au type `release`.
4. Construire avec `flutter build appbundle --release` et conserver clés et mots de passe dans un gestionnaire de secrets.

Le projet ne contient aucun secret et n’utilise pas la clé de débogage comme signature publiable.
