#ifndef COMMUNICATION_FUNCTIONS_H
#define COMMUNICATION_FUNCTIONS_H

#include <Arduino.h>

void connectToWiFi(const char* ssid, const char* password);
String getMacAddress();
void sendMacAddress();

#endif