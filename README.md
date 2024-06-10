#  SHASM (Smart Home Automation System Management) scmu_2024_smartconnect

## Overview
SHASM is an advanced smart home management system designed to seamlessly integrate mobile applications with ESP32 microcontrollers and cloud services via Firebase. This project exemplifies the practical application of Mobile and Ubiquitous Computing theories, offering a scalable and user-centric smart home environment.

## Features
- **Multi-client Support**: Allows multiple users to control and monitor home automation securely.
- **Serverless Architecture**: Utilizes Firebase for robust backend support without the need for a dedicated server.
- **Real-time Interactivity**: Offers real-time control and updates of home devices via a custom mobile application developed using Flutter.
- **Offline Functionality**: Ensures limited system operability even without internet connectivity.
- **Customizable Automation**: Users can create personalized automation "scenes" for handling devices based on specific conditions.

## System Components
- **ESP32 Microcontrollers**: Provide WiFi connectivity and manage multiple home automation tasks efficiently.
- **Sensors and Actuators**: Include motion sensors (PIR), photoresistors for light sensing, servos for mechanical control, and LEDs for lighting.

## Getting Started

### Prerequisites
- Flutter installed on your system
- Android Studio for app development
- Access to Firebase for backend services

### Installation
1. Clone the repository
2. Navigate into the project directory
3. Install dependencies
   `flutter pub get`
4. Set up your Firebase project and download the `google-services.json`, placing it in the appropriate directory.
   
### Configuration
Ensure your Firebase project is set up with the following configurations:
- FlutterFire
- Firebase Firestore
- Firebase Realtime Database
- Firebase Authentication

### Running the Application
1. Open the project in Android Studio.
2. Build the app
   `flutter run`

## Acknowledgements
- Nova University SCMU 23/24 Course Team
