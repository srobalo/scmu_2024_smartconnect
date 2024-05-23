#include <WiFi.h> 


// String getMacAddress(){
//   return WiFi.macAddress();
// }
// void sendMacAddress(){

//   String myMAC = getMacAddress();
//    if (WiFi.status() == WL_CONNECTED) {
//         HTTPClient http;
//         http.begin(serverName);
//         http.addHeader("Content-Type", "application/x-www-form-urlencoded");
//         String httpRequestData = "mac=" + macAddress;
//         int httpResponseCode = http.POST(httpRequestData);

//         if (httpResponseCode > 0) {
//             String response = http.getString();
//             Serial.print("HTTP Response code: ");
//             Serial.println(httpResponseCode);
//             Serial.print("Response from server: ");
//             Serial.println(response);
//         } else {
//             Serial.print("Error code: ");
//             Serial.println(httpResponseCode);
//         }
//         http.end();
//     } else {
//         Serial.println("WiFi Disconnected");
//     }


// }
