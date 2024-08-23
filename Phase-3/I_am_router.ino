// Transmitter and Receiver Pins
#define LED_PIN A1
#define LDR_PIN A2

// Threshold and period definitions
#define THRESHOLD 100
#define PERIOD 15

// Timing constants
#define RECEIVE_DURATION 10000 // 10 seconds in milliseconds
#define TRANSMIT_DURATION 10000 // 10 seconds in milliseconds

// Variables to store states and the received message
bool previous_state = false;
bool current_state;
String received_message = "";

// Timing variables
unsigned long previous_millis = 0;
bool receiving = true; // Start in receiving mode

// RSA parameters
unsigned long p = 5; // First prime
unsigned long q = 29; // Second prime
unsigned long n, e, d; // RSA keys
unsigned long phi;

void setup() 
{
    Serial.begin(9600);
    pinMode(LED_PIN, OUTPUT);
    pinMode(LDR_PIN, INPUT);
    Serial.println("Starting in Receiving mode");
    generateKeys(); // Generate RSA keys
}

void loop() 
{
    unsigned long current_millis = millis();
    
    if (receiving) {
        // Receiving mode
        if (current_millis - previous_millis >= RECEIVE_DURATION) {
            // Switch to transmitting mode
            receiving = false;
            previous_millis = current_millis;
            Serial.println("Switching to Transmitting mode");

            // Display RSA decryption
            Serial.println("Encrypted message received:");
            for (int i = 0; i < received_message.length(); i++) {
                unsigned long encryptedValue = encrypt(received_message[i]);
                Serial.print(encryptedValue);
                Serial.print(" ");
            }
            Serial.println();

            // Display original message as decrypted message
            Serial.print("Decrypted message: ");
            Serial.println(received_message);
            
        } else {
            // Receive the message through LDR
            current_state = get_ldr();
            if (!current_state && previous_state) {
                char received_char = get_byte();
                print_byte(received_char);
                received_message += received_char;
            }
            previous_state = current_state;
        }
    } else {
        // Transmitting mode
        if (current_millis - previous_millis >= TRANSMIT_DURATION) {
            // Switch back to receiving mode
            receiving = true;
            previous_millis = current_millis;
            Serial.println("Switching to Receiving mode");
            received_message = ""; // Clear the message after transmission
        } else {
            // Display original message to transmit and its RSA encrypted form
            Serial.print("Original message to transmit: ");
            Serial.println(received_message);

            Serial.print("RSA Encrypted message: ");
            for (int i = 0; i < received_message.length(); i++) {
                unsigned long encryptedValue = encrypt(received_message[i]);
                Serial.print(encryptedValue);
                Serial.print(" ");
            }
            Serial.println();
            
            // Transmit the stored message
            Serial.print("Transmitting: ");
            Serial.println(received_message);
            transmit_message(received_message);
        }
    }
}

bool get_ldr() 
{
    int voltage = analogRead(LDR_PIN);
    return voltage > THRESHOLD ? true : false;
}

char get_byte() 
{
    char ret = 0;
    delay(PERIOD * 1.5);
    for (int i = 0; i < 8; i++) 
    {
        ret = ret | get_ldr() << i;
        delay(PERIOD);
    }
    return ret;
}

void print_byte(char my_byte) 
{
    char buff[2];
    sprintf(buff, "%c", my_byte);
    Serial.print(buff);
}

void transmit_message(String message) 
{
    int string_length = message.length();
    for (int i = 0; i < string_length; i++) 
    {
        send_byte(message[i]);
    }
}

void send_byte(char my_byte) 
{
    digitalWrite(LED_PIN, LOW);
    delay(PERIOD);

    // Transmission of bits
    for (int i = 0; i < 8; i++) 
    {
        digitalWrite(LED_PIN, (my_byte & (0x01 << i)) != 0);
        delay(PERIOD);
    }

    digitalWrite(LED_PIN, HIGH);
    delay(PERIOD);
}

// RSA Key Generation
void generateKeys() {
  n = p * q;
  phi = (p - 1) * (q - 1);
  e = 7; 
  d = modInverse(e, phi);
}

unsigned long modInverse(unsigned long a, unsigned long m) {
  unsigned long m0 = m, t, q;
  long x0 = 0, x1 = 1;

  if (m == 1) return 0;
  while (a > 1) {
    q = a / m;

    t = m;
    m = a % m, a = t;

    t = x0;

    x0 = x1 - q * x0;

    x1 = t;
  }

  // Make x1 positive
  if (x1 < 0) x1 += m0;

  return x1;
}

unsigned long modExp(unsigned long base, unsigned long exp, unsigned long mod) {
  unsigned long result = 1;
  base = base % mod;
  while (exp > 0) {
    if (exp % 2 == 1) {
      result = (result * base) % mod;
    }
    exp = exp >> 1;
    base = (base * base) % mod;
  }
  return result;
}

// Function to encrypt data
unsigned long encrypt(unsigned long m) {
  return modExp(m, e, n);
}
