#define BLYNK_TEMPLATE_ID "TMPL6VMq4yjbF"
#define BLYNK_TEMPLATE_NAME "Clothes"
#define BLYNK_AUTH_TOKEN ""


#define BLYNK_PRINT Serial


// =======================
#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <ESP32Servo.h>
#include "BluetoothSerial.h"
#include <Preferences.h>

// =======================
BluetoothSerial SerialBT;
Preferences prefs;
Servo servo;

// =======================
// WIFI
// =======================
String wifiSSID = "";
String wifiPASS = "";
bool wifiConnected = false;

// =======================
// SERVO
// =======================
int currentPos = 0;
int targetPos = 0;
int speedStep = 2;

// =======================
// CONNECT WIFI
// =======================
void connectToWiFi(String ssid, String pass) {
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid.c_str(), pass.c_str());

  int timeout = 0;
  while (WiFi.status() != WL_CONNECTED && timeout < 20) {
    delay(500);
    Serial.print(".");
    timeout++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.println(WiFi.localIP());

    SerialBT.println("STATUS:CONNECTED");

    // simpan
    prefs.putString("ssid", ssid);
    prefs.putString("pass", pass);

    // BLYNK CONNECT (WAJIB pakai ini, bukan begin)
    Blynk.config(BLYNK_AUTH_TOKEN);
    Blynk.connect();

    wifiConnected = true;
  } else {
    Serial.println("\nWiFi Failed!");
    SerialBT.println("STATUS:FAILED");
    wifiConnected = false;
  }
}

// =======================
// BLYNK CONTROL
// =======================
BLYNK_WRITE(V4) {
  int value = param.asInt();

  if (value == 1) {
    targetPos = 90;
  } else {
    targetPos = 0;
  }
}

BLYNK_WRITE(V5) {
  int value = param.asInt();
  speedStep = map(value, 0, 100, 1, 10);
}

// =======================
// SETUP
// =======================
void setup() {
  Serial.begin(115200);

  SerialBT.begin("ESP32-Setup");
  servo.attach(18);

  prefs.begin("wifi", false);

  wifiSSID = prefs.getString("ssid", "");
  wifiPASS = prefs.getString("pass", "");

  if (wifiSSID != "") {
    connectToWiFi(wifiSSID, wifiPASS);
  } else {
    Serial.println("No WiFi saved. Waiting Bluetooth...");
  }
}

// =======================
// LOOP
// =======================
void loop() {
  if (wifiConnected) {
    Blynk.run();
  }

  // =======================
  // BLUETOOTH HANDLER
  // =======================
  if (SerialBT.available()) {
    String data = SerialBT.readStringUntil('\n');
    data.trim();

    Serial.println("BT: " + data);

    // WIFI:SSID,PASS
    if (data.startsWith("WIFI:")) {
      int commaIndex = data.indexOf(',');

      if (commaIndex > 0) {
        String ssid = data.substring(5, commaIndex);
        String pass = data.substring(commaIndex + 1);

        connectToWiFi(ssid, pass);
      }
    }

    // cek status
    if (data == "STATUS") {
      if (wifiConnected) {
        SerialBT.println("STATUS:CONNECTED");
      } else {
        SerialBT.println("STATUS:DISCONNECTED");
      }
    }

    // reset wifi
    if (data == "RESET") {
      prefs.clear();
      SerialBT.println("STATUS:RESET_DONE");
      delay(1000);
      ESP.restart();
    }
  }

  // =======================
  // SERVO SMOOTH
  // =======================
  if (currentPos < targetPos) {
    currentPos += speedStep;
    if (currentPos > targetPos) currentPos = targetPos;
    servo.write(currentPos);
  } 
  else if (currentPos > targetPos) {
    currentPos -= speedStep;
    if (currentPos < targetPos) currentPos = targetPos;
    servo.write(currentPos);
  }

  delay(10);
}