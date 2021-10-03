# Control Panel for DCEMS

***Embedded Systems Class***

Web-based control panel for the DCEMS project.

This project is a proof-of-concept. 

It's main feature is to manage and monitor UPS and servers hosted on DCC@FCUP. 

## Requirements
- Dart >= 2.0

## Instructions
- Installation

1. Install the Dart SDK by following the instructions here: https://dart.dev/get-dart
2. Download the repository to your PC
3. Run "dart --version" to make sure the dart VM is installed.
3. In the main folder, run: ***pub get*** in order to get the project dependencies.
- Client
1. Run: ***webdev serve***
2. Go to: "http://127.0.0.1:8080" to try the project.
- Server
1. Run ***dart server.dart*** on another terminal.

(Internet is required to get the Bootstrap assets from the CDN.)

## Notes
The dummy server is listening on the 8500 port and the client app in the 8080.

This project was made on a Windows 10 machine running the Dart VM 2.7.2 on the Windows Powershell.

It should run in macOS and Linux too.

If you run into any problems when getting dependencies, make sure the folder you're currently on has the file "pubspec.yaml", and delete the file "pubspec.lock", then run ***pub get*** again.