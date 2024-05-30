#include <WiFi.h>
#include <WiFiClient.h>
#include <ESP32Servo.h>

const char* ssid = "Vodafone-A4638F";
const char* password = "MEV8s2EbE7";

Servo myServo;

// int ledPin = 21;
// int photoResistorPin = 34;
// static const int servoPin = 13;

bool lightSceneEnabled = false; // Flag to control light scene activation


void scene() {
    WiFiClient client = server.available();
    if (client) {
        Serial.println("New Client Connected");
        String currentLine = "";
        while (client.connected()) {
            if (client.available()) {
                char c = client.read();
                if (c == '\n') {
                    // Check the request
                    if (currentLine.startsWith("GET /servo/photoresistor/on")) {
                        lightSceneEnabled = true;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("Light scene enabled");
                        client.println();
                        Serial.println("Light scene enabled");
                    } else if (currentLine.startsWith("GET /servo/photoresistor/off")) {
                        lightSceneEnabled = false;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("Light scene disabled");
                        client.println();
                        Serial.println("Light scene disabled");
                    }
                    currentLine = "";
                } else if (c != '\r') {
                    currentLine += c;
                }
            }
        }
        client.stop();
        Serial.println("Client Disconnected");
    }

    checkSensors();
}

void checkSensors() {
    int lightLevel = analogRead(photoResistorPin);
    Serial.print("Light Level: ");
    Serial.println(lightLevel);

    if (lightSceneEnabled) {
        if (lightLevel > 1500) {
            activateServo();
        } else {
            deactivateServo();
        }
    }
}

void activateServo() {
    Serial.println("Activating servo");
    myServo.write(180); // Rotate to 180 degrees
}

void deactivateServo() {
    Serial.println("Deactivating servo");
    myServo.write(0); // Rotate back to 0 degrees
}
