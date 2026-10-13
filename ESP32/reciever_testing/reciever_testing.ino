#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <ESP_I2S.h>

#define CE_PIN 4
#define CSN_PIN 5

#define I2S_BCLK 26
#define I2S_WS   25
#define I2S_DOUT 22

#define SAMPLE_RATE 8000
#define SAMPLES_PER_PACKET 14

RF24 radio(CE_PIN, CSN_PIN);
I2SClass speakerI2S;

const byte address[6] = "00001";

struct AudioPacket {
  uint8_t type;
  uint16_t sequence;
  int16_t samples[SAMPLES_PER_PACKET];
};

AudioPacket packet;

uint16_t lastSequence = 0;
uint32_t receivedPackets = 0;
uint32_t missingPackets = 0;

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("WIRELESS AUDIO RECEIVER");

  // Initialize MAX98357A I2S output.
  speakerI2S.setPins(
    I2S_BCLK,
    I2S_WS,
    I2S_DOUT,
    -1
  );

  if (!speakerI2S.begin(
        I2S_MODE_STD,
        SAMPLE_RATE,
        I2S_DATA_BIT_WIDTH_16BIT,
        I2S_SLOT_MODE_MONO,
        I2S_STD_SLOT_LEFT)) {
    Serial.println("SPEAKER I2S FAILED");
    while (true) delay(100);
  }

  Serial.println("MAX98357A I2S READY");

  // Initialize nRF24.
  SPI.begin(18, 19, 21, 5);

  if (!radio.begin()) {
    Serial.println("NRF24 NOT DETECTED");
    while (true) delay(100);
  }

  radio.setChannel(100);
  radio.setDataRate(RF24_250KBPS);
  radio.setPALevel(RF24_PA_LOW);
  radio.setAutoAck(true);
  radio.setRetries(3, 5);
  radio.setPayloadSize(sizeof(AudioPacket));

  radio.openReadingPipe(1, address);
  radio.startListening();

  Serial.print("Packet size: ");
  Serial.println(sizeof(AudioPacket));
  Serial.println("WAITING FOR AUDIO...");
}

void loop() {
  if (!radio.available()) {
    return;
  }

  radio.read(&packet, sizeof(packet));

  if (packet.type != 1) {
    return;
  }

  if (lastSequence != 0 &&
      packet.sequence > lastSequence + 1) {
    missingPackets +=
      packet.sequence - lastSequence - 1;
  }

  lastSequence = packet.sequence;
  receivedPackets++;

  // Play received samples through the MAX98357A.
  size_t bytesToWrite = sizeof(packet.samples);
  size_t bytesWritten = speakerI2S.write(
    (uint8_t *)packet.samples,
    bytesToWrite
  );

  if (receivedPackets % 500 == 0) {
    Serial.print("Received: ");
    Serial.print(receivedPackets);
    Serial.print("  Missing: ");
    Serial.print(missingPackets);
    Serial.print("  I2S bytes written: ");
    Serial.println(bytesWritten);
  }
}