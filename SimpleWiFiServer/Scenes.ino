#include <WiFi.h>  // Include WiFi library only once
#include <WiFiClient.h>
#include <ESP32Servo.h>

const char* ssid = "AccessPoint";
const char* password = "00000001";

Servo myServo;
int photoResistorPin = 34;
int servoPin = 13;  // Define a pin for the servo
int motionSensorPin = 12;
int ledPin = 2;

bool ledEnabled_motion = false;
bool ledEnabled_photoresistor = false;
bool lightSceneEnabled = false;  // Flag to control light scene activation
bool motionSensorEnabled = false;
WiFiServer server(80);  // Create a server that listens on port 80

void setup() {
    Serial.begin(9600);  // Start serial communication at 9600 baud rate
    while (!Serial);  // Wait for serial port to connect - necessary for ESP32

    myServo.attach(servoPin);  // Attach servo to defined pin
    pinMode(motionSensorPin, INPUT);
    pinMode(ledPin, OUTPUT);

    WiFi.begin(ssid, password);  // Start WiFi connection
    while (WiFi.status() != WL_CONNECTED) {  // Wait for the connection to establish
        delay(500);
        Serial.println("Connecting to WiFi...");
    }
    Serial.println("Connected to WiFi");
    Serial.print("IP Address: ");  // Print the IP address to the serial monitor
    Serial.println(WiFi.localIP());

    server.begin();  // Start the server
    pinMode(photoResistorPin, INPUT);  // Set photoresistor pin as input
}

void loop() {
    scene();  // Handle client connections and sensor checking
}

void scene() {
    WiFiClient client = server.available();  // Listen for incoming clients
    if (client) {
        Serial.println("New Client Connected");
        String currentLine = "";  // Make a String to hold incoming data from the client
        while (client.connected()) {
            if (client.available()) {
                char c = client.read();  // Read a byte
                Serial.write(c);  // Echo it back to the serial monitor
                if (c == '\n') {  // If the byte is a newline character
                    // Check the current line for a GET request
                    if (currentLine.startsWith("GET /servo/photoresistor/on")) {
                        lightSceneEnabled = true;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("Light scene enabled");
                        client.println();
                        Serial.println("Light scene enabled");
                        break;
                    } else if (currentLine.startsWith("GET /servo/photoresistor/off")) {
                        lightSceneEnabled = false;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("Light scene disabled");
                        client.println();
                        Serial.println("Light scene disabled");
                        break;
                    } else if (currentLine.startsWith("GET /servo/motionSensor/on")) {
                        motionSensorEnabled = true;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("Motion sensor enabled");
                        client.println();
                        Serial.println("Motion sensor enabled");
                        break;
                    } else if (currentLine.startsWith("GET /servo/motionSensor/off")) {
                        motionSensorEnabled = false;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("Motion sensor disabled");
                        client.println();
                        Serial.println("Motion sensor disabled");
                        break;
                    } else if (currentLine.startsWith("GET /led/photoresistor/on")) {
                        ledEnabled_photoresistor = true;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("LED control enabled");
                        client.println();
                        Serial.println("LED control enabled");
                        break;
                    } else if (currentLine.startsWith("GET /led/photoresistor/off")) {
                        ledEnabled_photoresistor = false;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("LED control photoresistor disabled");
                        client.println();
                        Serial.println("LED control photoresistor disabled");
                        break;
                    } else if (currentLine.startsWith("GET /led/motionSensor/on")) {
                        ledEnabled_motion = true;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("LED control motion enabled");
                        client.println();
                        Serial.println("LED control motion enabled");
                        break;
                    } else if (currentLine.startsWith("GET /led/motionSensor/off")) {
                        ledEnabled_motion = false;
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type: text/plain");
                        client.println();
                        client.println("LED control motion disabled");
                        client.println();
                        Serial.println("LED control motion disabled");
                        break;
                    }
                    currentLine = "";  // Clear the currentLine
                } else if (c != '\r') {  // If the byte is not a carriage return character
                    currentLine += c;  // Add it to the end of the currentLine
                }
            }
        }
        client.stop();  // Close the connection
        Serial.println("Client Disconnected");
    }
    checkSensors();  // Function to check the sensors
}

void checkSensors() {
    int lightLevel = analogRead(photoResistorPin);  // Read the light level
    //Serial.print("Light Level: ");
    //Serial.println(lightLevel);
    delay(500);
    if (lightSceneEnabled) {
        if (lightLevel < 1000) {
            activateServo();
        } else {
            deactivateServo();
        }
    }
    if (ledEnabled_photoresistor) {
        if (lightLevel > 1000) {
            digitalWrite(ledPin, HIGH);  // Turn on LED if light level is high
            Serial.println("LED On");
        } else {
            digitalWrite(ledPin, LOW);  // Turn off LED if light level is low
            Serial.println("LED Off");
        }
    }
    Serial.print(digitalRead(motionSensorPin));
    if (motionSensorEnabled && digitalRead(motionSensorPin) == HIGH) {  // Read the motion sensor
        Serial.println("Motion Detected");
        myServo.write(180);  // Simulate door opening
        delay(5000);
        myServo.write(0);
    }

    if (ledEnabled_motion && digitalRead(motionSensorPin) == HIGH) {  // Read the motion sensor
        digitalWrite(ledPin, HIGH);  // Turn on LED if light level is high
        Serial.println("LED On");  // Simulate door opening
        delay(5000);
        digitalWrite(ledPin, LOW);  // Turn off LED if light level is low
        Serial.println("LED Off");
    }
}

void activateServo() {
    Serial.println("Activating servo");
    myServo.write(180);  // Rotate to 180 degrees
}

void deactivateServo() {
    Serial.println("Deactivating servo");
    myServo.write(0);  // Rotate back to 0 degrees
}