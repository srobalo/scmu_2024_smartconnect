#include <WiFiManager.h>
#include <ESP32Servo.h>
#include <ESP32Firebase.h>
#include <NTPClient.h>
#include <WiFiUdp.h>


// WiFiUDP instance for the NTP client
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 1);
#define HISTORY_LENGTH 5  // Number of readings to keep track of


const char* ssid = "SHASM";
const char* password = "password";
const char* firebaseHost = "scmu-2024-smartconnect-default-rtdb.europe-west1.firebasedatabase.app";

Servo myServo;
int photoResistorPin = 34;
int servoPin = 13;  // Define a pin for the servo
int motionSensorPin = 12;
int ledPin = 32;

bool ledEnabled_motion = false;
bool ledEnabled_photoresistor = false;
bool lightSceneEnabled = false;  // Flag to control light scene activation
bool motionSensorEnabled = false;
WiFiServer server(80);  // Create a server that listens on port 80

Firebase firebase(firebaseHost);

String formatISO8601(long epochTime) {
    time_t rawTime = (time_t)epochTime;
    struct tm * timeInfo = gmtime(&rawTime);  // Get UTC time

    char buffer[25];
    strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%S", timeInfo);
    return String(buffer);
}
void setup() {
    Serial.begin(9600);  // Start serial communication at 9600 baud rate
    while (!Serial)
        ;  // Wait for serial port to connect - necessary for ESP32

    myServo.attach(servoPin);  // Attach servo to defined pin
    pinMode(motionSensorPin, INPUT);
    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, LOW);
    WiFi.mode(WIFI_STA);
    WiFiManager wm;
    wm.resetSettings();
    wm.setConfigPortalTimeout(300);
    if (!wm.autoConnect("SHASM", "password")) {
        Serial.println("Failed to connect");
        ESP.restart();
        delay(1000);
    }
    while (WiFi.status() != WL_CONNECTED) {  // Wait for the connection to establish
        delay(500);
        Serial.println("Connecting to WiFi...");
    }
    Serial.println("Connected to WiFi");
    Serial.print("IP Address: ");  // Print the IP address to the serial monitor
    Serial.println(WiFi.localIP());


    server.begin();                    // Start the server
    pinMode(photoResistorPin, INPUT);  // Set photoresistor pin as input

    // Initialize a NTPClient to get time
    timeClient.begin();
    timeClient.setTimeOffset(0);

    timeClient.update();
    long currentTime = timeClient.getEpochTime();
    String formattedTime = formatISO8601(currentTime);
    firebase.setString("Device/MAC", WiFi.macAddress());
    firebase.setString("Device/IP", WiFi.localIP().toString());
    firebase.setString("Device/timestamp", formattedTime);
}

void loop() {
    timeClient.update();
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
                Serial.write(c);         // Echo it back to the serial monitor
                if (c == '\n') {         // If the byte is a newline character
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
                    } else if (currentLine.startsWith("GET /32/on")){
                        digitalWrite(ledPin, HIGH);  // Turn on LED if light level is high
                        Serial.println("LED On");
                        break;
                    } else if (currentLine.startsWith("GET /32/off")){
                        digitalWrite(ledPin, LOW);  // Turn on LED if light level is high
                        Serial.println("LED Off");
                        break;
                    } else if (currentLine.startsWith("GET /13/on")){
                        myServo.write(90); // Turn on LED if light level is high
                        Serial.println("Door Opened");
                        break;
                    } else if (currentLine.startsWith("GET /13/on")){
                        myServo.write(0); // Turn on LED if light level is high
                        Serial.println("Door Closed");
                        break;
                    }
                    currentLine = "";      // Clear the currentLine
                } else if (c != '\r') {  // If the byte is not a carriage return character
                    currentLine += c;      // Add it to the end of the currentLine
                }
            }
        }
        client.stop();  // Close the connection
        Serial.println("Client Disconnected");
    }

    checkSensors();  // Function to check the sensors
}


int motionReadings[HISTORY_LENGTH] = { 0, 0, 0, 0, 0 };  // Initialize all readings to 0
int readIndex = 0;                                       // Index for where to store the next reading

void updateMotionHistory(int newReading) {
    motionReadings[readIndex] = newReading;        // Update the current index with the new reading
    readIndex = (readIndex + 1) % HISTORY_LENGTH;  // Move index forward and wrap around if necessary
}

bool checkMotionHistory() {
    for (int i = 0; i < HISTORY_LENGTH; i++) {
        if (motionReadings[i] != 0) {
            return false;  // If any reading is not 0, return false
        }
    }
    return true;  // All readings were 0
}


void checkSensors() {
    digitalWrite(ledPin, LOW);
    int lightLevel = analogRead(photoResistorPin);  // Read the light level

    // Read motion sensor and update history
    int currentMotion = digitalRead(motionSensorPin);

    // Get current time
    timeClient.update();
    long currentTime = timeClient.getEpochTime();
    String formattedTime = formatISO8601(currentTime);
    Serial.print(currentMotion);  // Output current motion reading

    delay(500);
    if (lightSceneEnabled) {
        if (lightLevel < 1000) {
            firebase.setInt("sensorData/photoResistor/id", ledPin);
            firebase.setInt("sensorData/photoResistor/value", lightLevel);
            firebase.setString("sensorData/photoResistor/timestamp", formattedTime);
            activateServo(formattedTime);
        } else {
            deactivateServo(formattedTime);
        }
    }
    if (ledEnabled_photoresistor) {
        if (lightLevel > 1000) {

            digitalWrite(ledPin, HIGH);  // Turn on LED if light level is high
            Serial.println("LED On");
        } else {
            firebase.setInt("sensorData/photoResistor/id", ledPin);
            firebase.setInt("sensorData/photoResistor/value", lightLevel);
            firebase.setString("sensorData/photoResistor/timestamp", formattedTime);
            digitalWrite(ledPin, LOW);  // Turn off LED if light level is low
            Serial.println("LED Off");
        }
    }

    // Check motion history BEFORE updating it to make sure the last 5 were zero and current is HIGH
    bool previousHistoryClear = checkMotionHistory();  // Check if previous readings were all zero
    updateMotionHistory(currentMotion);                // Then update motion history with current state

    // Only trigger motion-related actions if current motion is detected AND the previous five were zero
    if (motionSensorEnabled && currentMotion == HIGH && previousHistoryClear) {
        Serial.println("Motion Detected");
        myServo.write(0);  // Simulate door opening
        firebase.setInt("sensorData/motionDetected/id", motionSensorPin);
        //firebase.setInt("sensorData/motionDetected/value", 0);
        firebase.setString("sensorData/motionDetected/timestamp", formattedTime);
        delay(3000);
        myServo.write(90);  // Simulate door closing
        firebase.setInt("sensorData/motionDetected/id", motionSensorPin);
        //firebase.setInt("sensorData/motionDetected/value", 90);
        firebase.setString("sensorData/motionDetected/timestamp", formattedTime);
    }

    if (ledEnabled_motion && currentMotion == HIGH && previousHistoryClear) {
        digitalWrite(ledPin, HIGH);  // Turn on LED
        firebase.setInt("sensorData/ledAction/id", ledPin);
        firebase.setInt("sensorData/ledAction/value", 1);
        firebase.setString("sensorData/ledAction/timestamp", formattedTime);
        Serial.println("LED On");
        firebase.setInt("sensorData/motionDetected/id", motionSensorPin);
        firebase.setString("sensorData/motionDetected/timestamp", formattedTime);
        delay(5000);
        digitalWrite(ledPin, LOW);  // Turn off LED
        firebase.setInt("sensorData/ledAction/id", ledPin);
        firebase.setInt("sensorData/ledAction/value", 0);
        firebase.setString("sensorData/ledAction/timestamp", formattedTime);
        Serial.println("LED Off");
    }
}
void activateServo(String formattedTime) {
    Serial.println("Activating servo");
    firebase.setInt("sensorData/servoAction/id", servoPin);
    firebase.setInt("sensorData/servoAction/value", 180);
    firebase.setString("sensorData/servoAction/timestamp", formattedTime);
    myServo.write(90);  // Rotate to 180 degrees
}

void deactivateServo(String formattedTime) {
    Serial.println("Deactivating servo");
    firebase.setInt("sensorData/servoAction/id", servoPin);
    firebase.setInt("sensorData/servoAction/value", 0);
    firebase.setString("sensorData/servoAction/timestamp", formattedTime);
    myServo.write(0);  // Rotate back to 0 degrees
}