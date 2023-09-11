# Importation d'utilisateurs dans Active Directory à partir d'un CSV

Ce script permet d'importer des utilisateurs dans Active Directory à partir d'un fichier CSV.

## Prérequis

- Avoir les **droits nécessaires** pour créer des utilisateurs dans Active Directory.
- Avoir **installé le module ActiveDirectory** pour PowerShell.
- Le fichier CSV doit être correctement formaté avec les champs appropriés.

### Voici les champs attendus :
- First name
- Last name
- Display name
- User logon name
- User principal name
- Street
- City
- State/province
- Zip/Postal Code
- Country/region
- Job Title
- Department
- Company
- Manager
- OU
- Description
- Office
- Telephone number
- E-mail
- Mobile
- Notes
- Account status

## Utilisation

1. Modifiez la valeur de `$FichierCsv` pour pointer vers votre fichier CSV.
2. Exécutez le script dans PowerShell avec les droits administratifs appropriés.
3. Le script importera les utilisateurs et affichera un message pour chaque utilisateur importé.

## Problèmes connus

- Le script n'actualise pas les utilisateurs déjà existants ; il passe simplement à l'utilisateur suivant s'il trouve un utilisateur existant avec le même nom de connexion.
- Le mot de passe par défaut pour tous les utilisateurs est `P@ssw0rd1234`. Assurez-vous de le changer si nécessaire.
