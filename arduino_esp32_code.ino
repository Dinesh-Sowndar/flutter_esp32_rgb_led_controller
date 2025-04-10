#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <FastLED.h>

#define LED_NUM 200
#define DATA_PIN 5
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

CRGB leds[LED_NUM];
BLECharacteristic* pCharacteristic;
bool isAnimating = false;
uint8_t currentAnimation = 0;
CRGB currentColor = CRGB::Black;

// Color palettes
CRGBPalette16 rainbowPalette = RainbowColors_p;
CRGBPalette16 pastelPalette = CloudColors_p;
CRGBPalette16 warmPalette = HeatColors_p;
CRGBPalette16 coolPalette = OceanColors_p;

void setup() {
  Serial.begin(115200);

  // Setup LEDs
  FastLED.addLeds<WS2812B, DATA_PIN, GRB>(leds, LED_NUM);
  FastLED.setBrightness(100);
  fill_solid(leds, LED_NUM, CRGB::Black);
  FastLED.show();

  // Start BLE
  BLEDevice::init("RGB LED Controller");
  BLEServer* pServer = BLEDevice::createServer();
  BLEService* pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_NOTIFY
  );

  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->start();

  Serial.println("BLE advertising started. Waiting for connection...");
}

void loop() {
  String value = String(pCharacteristic->getValue().c_str());

  if (value.length() > 0) {
    Serial.print("Received: ");
    Serial.println(value);
    processCommand(value);
    pCharacteristic->setValue(""); // Clear after use
  }

  if (isAnimating) {
    switch (currentAnimation) {
      case 5: animationPulse(); break;
      case 6: animationRainbow(); break;
      case 7: animationStrobe(); break;
      case 8: animationCylon(); break;
    }
    FastLED.show();
    FastLED.delay(30);
  }
}

void processCommand(String command) {
  command.trim();

  if (command.startsWith("#") && command.length() == 7) {
    isAnimating = false;
    currentAnimation = 0;

    long number = strtol(command.substring(1).c_str(), NULL, 16);
    currentColor = CRGB((number >> 16) & 0xFF, (number >> 8) & 0xFF, number & 0xFF);

    fill_solid(leds, LED_NUM, currentColor);
    FastLED.setBrightness(100);
    FastLED.show();
  } 
  else if (command.length() == 1 && command[0] >= '1' && command[0] <= '4') {
    isAnimating = false;
    currentAnimation = 0;
    applyPalette(command.toInt());
  } 
  else if (command.length() == 1 && command[0] >= '5' && command[0] <= '8') {
    currentAnimation = command.toInt();
    isAnimating = true;
  }
}

void applyPalette(uint8_t index) {
  CRGBPalette16 palette;

  switch (index) {
    case 1: palette = rainbowPalette; break;
    case 2: palette = pastelPalette; break;
    case 3: palette = warmPalette; break;
    case 4: palette = coolPalette; break;
    default: return;
  }

  for (int i = 0; i < LED_NUM; i++) {
    leds[i] = ColorFromPalette(palette, i * (255 / LED_NUM), 255, LINEARBLEND);
  }
  FastLED.setBrightness(100);
  FastLED.show();
}

// === Animations ===

void animationPulse() {
  static uint8_t hue = 0;
  fill_solid(leds, LED_NUM, CHSV(hue++, 255, 255));
}

void animationRainbow() {
  static uint8_t startIndex = 0;
  startIndex++;
  fill_rainbow(leds, LED_NUM, startIndex);
}

void animationStrobe() {
  static bool on = false;
  on = !on;
  fill_solid(leds, LED_NUM, on ? CRGB::White : CRGB::Black);
}

void animationCylon() {
  static uint8_t hue = 0;
  for(int i = 0; i < LED_NUM; i++) {
    leds[i] = CHSV(hue++, 255, 255);
    FastLED.show();
    fadeAll();
    delay(10);
  }
  for(int i = LED_NUM - 1; i >= 0; i--) {
    leds[i] = CHSV(hue++, 255, 255);
    FastLED.show();
    fadeAll();
    delay(10);
  }
}

void fadeAll() {
  for(int i = 0; i < LED_NUM; i++) {
    leds[i].nscale8(250);
  }
}

// void animationFade() {
//   static uint8_t brightness = 0;
//   static bool increasing = true;

//   brightness += (increasing ? 5 : -5);
//   if (brightness >= 255 || brightness <= 0) increasing = !increasing;

//   fill_solid(leds, LED_NUM, currentColor);
//   FastLED.setBrightness(brightness);
// }
