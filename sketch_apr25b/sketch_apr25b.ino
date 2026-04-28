#define BLYNK_TEMPLATE_ID "TMPL6VMq4yjbF"
#define BLYNK_TEMPLATE_NAME "Clothes"
#define BLYNK_AUTH_TOKEN ""
#define BLYNK_PRINT Serial

#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <ESP32Servo.h>
#include <Preferences.h>
#include <DHT.h>
#include <BluetoothSerial.h> // Tambahkan ini

// =======================
Preferences prefs;
Servo servo;
BluetoothSerial SerialBT; // Tambahkan ini

// =======================
// DHT
// =======================
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

float temp = 0;
float hum = 0;
float lastTemp = 0;

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
// RAIN SENSOR
// =======================
int rainPin = 34;
int rainValue = 0;
int threshold = 3000;
bool isWet = false;

// =======================
// MODE
// =======================
bool autoMode = true;
bool manualOverride = false;

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
    Serial.println("\nConnected!");
    Serial.println(WiFi.localIP());

    Blynk.config(BLYNK_AUTH_TOKEN);
    Blynk.connect();

    wifiConnected = true;
    SerialBT.println("STATUS:CONNECTED"); // Kirim ke HP
  } else {
    Serial.println("\nFailed!");
    wifiConnected = false;
    SerialBT.println("STATUS:FAILED"); // Kirim ke HP
  }
}

// =======================
// DECISION ENGINE
// =======================
void updateDecision() {

  // PRIORITAS 1: HUJAN FISIK
  if (isWet) {
    Serial.println("DECISION: HUJAN → TUTUP");
    targetPos = 0;
    manualOverride = false; // reset override
    Blynk.virtualWrite(V4, 0);
    return;
  }

  // PRIORITAS 2: MANUAL OVERRIDE
  if (manualOverride) {
    Serial.println("DECISION: MANUAL OVERRIDE");
    return;
  }

  // PRIORITAS 3: AUTO DHT
  if (autoMode) {

    if (hum > 80 && temp < lastTemp) {
      Serial.println("DECISION: LEMBAB + TURUN → TUTUP");
      targetPos = 0;
      Blynk.virtualWrite(V4, 0);
      return;
    }

    if (temp >= 40) {
      Serial.println("DECISION: PANAS → BUKA");
      targetPos = 90;
      Blynk.virtualWrite(V4, 1);
      return;
    }
  }
}

// =======================
// BLYNK CONTROL
// =======================
BLYNK_WRITE(V4) {
  int value = param.asInt();

  Serial.print("API/BLYNK V4: ");
  Serial.println(value);

  manualOverride = true;

  if (!isWet) {
    targetPos = (value == 1) ? 90 : 0;
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

  // Bluetooth Setup
  SerialBT.begin("ESP32-Setup"); // Nama yang dicari aplikasi
  Serial.println("Bluetooth ESP32-Setup Ready!");

  servo.attach(18, 500, 2400);
  servo.write(0);

  pinMode(rainPin, INPUT);
  dht.begin();

  prefs.begin("wifi", false);

  wifiSSID = prefs.getString("ssid", "");
  wifiPASS = prefs.getString("pass", "");

  if (wifiSSID != "") {
    connectToWiFi(wifiSSID, wifiPASS);
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
  // BLUETOOTH CONTROL
  // =======================
  if (SerialBT.available()) {
    String data = SerialBT.readStringUntil('\n');
    data.trim();

    if (data.startsWith("WIFI:")) {
      // Format: WIFI:SSID,PASS
      int commaIndex = data.indexOf(',');
      if (commaIndex != -1) {
        String ssid = data.substring(5, commaIndex);
        String pass = data.substring(commaIndex + 1);
        
        Serial.println("Bluetooth received WiFi: " + ssid);
        
        // Simpan ke memory
        prefs.putString("ssid", ssid);
        prefs.putString("pass", pass);
        
        connectToWiFi(ssid, pass);
      }
    } 
    else if (data == "RESET") {
      prefs.clear();
      Serial.println("WiFi Config Cleared!");
      SerialBT.println("STATUS:CLEARED");
      ESP.restart();
    }
  }

  // =======================
  // RAIN SENSOR
  // =======================
  rainValue = analogRead(rainPin);

  if (rainValue < threshold) {
    isWet = true;
  } else {
    isWet = false;
  }

  // =======================
  // DHT SENSOR
  // =======================
  static unsigned long lastDHT = 0;
  if (millis() - lastDHT > 2000) {

    float t = dht.readTemperature();
    float h = dht.readHumidity();

    if (!isnan(t) && !isnan(h)) {
      temp = t;
      hum = h;

      Serial.print("Temp: ");
      Serial.print(temp);
      Serial.print(" | Hum: ");
      Serial.println(hum);

      Blynk.virtualWrite(V6, (int)temp);
      Blynk.virtualWrite(V7, (int)hum);
      Blynk.virtualWrite(V8, isWet ? 1 : 0); // Tambahkan ini (ID Datastream 8)

      updateDecision();

      lastTemp = temp;
    }

    lastDHT = millis();
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