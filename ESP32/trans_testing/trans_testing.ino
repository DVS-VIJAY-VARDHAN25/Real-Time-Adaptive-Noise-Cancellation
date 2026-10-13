#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <ESP_I2S.h>

#define CE_PIN 4
#define CSN_PIN 5

#define I2S_BCLK 26
#define I2S_WS   25
#define I2S_DIN  33

#define SAMPLE_RATE 8000
#define SAMPLES_PER_PACKET 14

RF24 radio(CE_PIN, CSN_PIN);
I2SClass micI2S;

const byte address[6] = "00001";

struct AudioPacket {
  uint8_t type;
  uint16_t sequence;
  int16_t samples[SAMPLES_PER_PACKET];
};

AudioPacket packet;
uint16_t sequenceNumber = 0;

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("WIRELESS AUDIO TRANSMITTER");

  micI2S.setPins(
    I2S_BCLK,
    I2S_WS,
    -1,
    I2S_DIN
  );

  if (!micI2S.begin(
        I2S_MODE_STD,
        SAMPLE_RATE,
        I2S_DATA_BIT_WIDTH_32BIT,
        I2S_SLOT_MODE_MONO,
        I2S_STD_SLOT_LEFT)) {
    Serial.println("MIC I2S FAILED");
    while (true) delay(100);
  }

  Serial.println("INMP441 READY");

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

  radio.openWritingPipe(address);
  radio.stopListening();

  Serial.print("Packet size: ");
  Serial.println(sizeof(AudioPacket));
  Serial.println("TRANSMITTING AUDIO");
}

void loop() {
  int32_t micSamples[SAMPLES_PER_PACKET];

  size_t bytesRead = micI2S.readBytes(
    (char *)micSamples,
    sizeof(micSamples)
  );

  if (bytesRead != sizeof(micSamples)) {
    return;
  }

  packet.type = 1;
  packet.sequence = ++sequenceNumber;

  for (int i = 0; i < SAMPLES_PER_PACKET; i++) {
    // Convert the 32-bit I2S sample to 16-bit PCM.
    packet.samples[i] =
      (int16_t)(micSamples[i] >> 16);
  }

  bool sent = radio.write(
    &packet,
    sizeof(packet)
  );

  if (sequenceNumber % 500 == 0) {
    Serial.print("Packet ");
    Serial.print(sequenceNumber);
    Serial.println(sent ? " SENT" : " FAILED");
  }
}