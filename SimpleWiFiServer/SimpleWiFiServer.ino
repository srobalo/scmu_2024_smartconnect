
#include <ESP32Firebase.h>
#include <WiFiManager.h>

const char* firebaseHost = "scmu-2024-smartconnect-default-rtdb.europe-west1.firebasedatabase.app";
//const char* firebaseAuth  = "QbSDiFbhpZLFahaXUakYKmF2KCtD9DvZgpCutLw8";

Firebase firebase(firebaseHost);

WiFiServer server(80);
int ledPin = 21;
int photoResistorPin = 34;
static const int servoPin = 13;
String MAC;
IPAddress IP;
//Servo servo1;
void setup() {
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);  // set the LED pin mode
  pinMode(photoResistorPin, INPUT);
  delay(10);


  WiFiManager wm;
  wm.resetSettings();

  if (!wm.autoConnect("SHASM", "password")) {
    Serial.println("Failed to connect");
    ESP.restart();
    delay(1000);
  }

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());


  /** FiREBASE */
  firebase.setString("Example/setString", "It's Working");
  firebase.setInt("Example/setInt", 123);
  firebase.setFloat("Example/setFloat", 45.32);

  MAC = WiFi.macAddress();
  IP = WiFi.localIP();
  server.begin();

}

void loop() {

  WiFiClient client = server.available();  // listen for incoming clients
  int lightLevel = analogRead(photoResistorPin);
  // Send the light level to Firebase
  if (!firebase.setInt("sensorData/photoResistor", lightLevel)) {
    Serial.println("Failed to write photoresistor value to Firebase");
  } else {
    Serial.print("Photoresistor level sent to Firebase: ");
    Serial.println(lightLevel);
  }
  if (client) {                     // if you get a client,
    Serial.println("New Client.");  // print a message out the serial port
    String currentLine = "";        // make a String to hold incoming data from the client
    while (client.connected()) {    // loop while the client's connected
      if (client.available()) {     // if there's bytes to read from the client,
        char c = client.read();     // read a byte, then
        Serial.write(c);            // print it out the serial monitor
        if (c == '\n') {            // if the byte is a newline character

          // if the current line is blank, you got two newline characters in a row.
          // that's the end of the client HTTP request, so send a response:
          if (currentLine.length() == 0) {
            // HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
            // and a content-type so the client knows what's coming, then a blank line:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println();
              client.println("Backdoor control");
            
            // the content of the HTTP response follows the header:
            //client.print("Click <a href=\"/H\">here</a> 180.<br>");
            //client.print("Click <a href=\"/L\">here</a> 0<br>");

            // The HTTP response ends with another blank line:
            client.println();
            // break out of the while loop:
            break;
          } else {  // if you got a newline, then clear currentLine:
             if (currentLine.startsWith("GET /mac")) {
              client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println();
              client.println(MAC);
             }else if(currentLine.startsWith("GET /ip")){

             }else if (currentLine.startsWith("GET /3/on")) {
              Serial.println("Turning Backdoor ON (Mover o servo)");
              // Add code to perform the action
            } else if (currentLine.startsWith("GET /3/off")) {
              Serial.println("Turning Backdoor OFF (Mover o servo)");
              // Add code to perform the action
            } else if (currentLine.startsWith("GET /1/on")) {
              Serial.println("Ligar luzes de fora");
            } else if (currentLine.startsWith("GET /1/off")) {
              Serial.println("Desligar luzes de fora");
            } else if (currentLine.startsWith("GET /2/on")) {
              Serial.println("Ligar luzes da casa");
            } else if (currentLine.startsWith("GET /2/off")) {
              Serial.println("Desligar luzes da casa");
            } else if (currentLine.startsWith("GET /4/on")) {
              Serial.println("Abrir porta da garagem");
            } else if (currentLine.startsWith("GET /4/off")) {
              Serial.println("Fechar porta da garagem");
            } else if (currentLine.startsWith("GET /5/on")) {
              Serial.println("Ligar LED temperatura");
            } else if (currentLine.startsWith("GET /5/off")) {
              Serial.println("Desligar LED temperatura");
            }
            currentLine = "";
          }
        } else if (c != '\r') {  // if you got anything else but a carriage return character,
          currentLine += c;      // add it to the end of the currentLine
        }

        // Check to see if the client request was "GET /H" or "GET /L":
        /**if (currentLine.endsWith("GET /H")) {
          servo1.write(180);               // GET /H turns the LED on
        }
        if (currentLine.endsWith("GET /L")) {
          servo1.write(0);                // GET /L turns the LED off
        }**/
      }
    }
    // close the connection:
    client.stop();
    Serial.println("Client Disconnected.");
  }
}
