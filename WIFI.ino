#include <WiFi.h>
#include <WebServer.h>

WebServer server(80); //Server on port 80

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP); //Set mode to access point
  WiFi.softAP("ESP32AP"); //Set SSID

  server.on("/", handleRoot); //Call handleRoot when client requests root page
  server.begin(); //Start server
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient(); //Handle client requests
}

void handleRoot() {
  String html = "<html><body><form method='post' action='setNetwork'>";
  html += "SSID: <input type='text' name='ssid'><br>";
  html += "Password: <input type='password' name='password'><br>";
  html += "<input type='submit' value='Set Network'></form></body></html>";
  server.send(200, "text/html", html);
}
