#define LED_PIN A1
#define BUTTON_PIN A0
#define PERIOD 15
#define check 0
#include <Arduino.h>

// RSA parameters
unsigned long p = 5; // First prime
unsigned long q = 29; // Second prime
unsigned long n, e, d; // RSA keys
unsigned long phi;

char* string;
int string_length;
String inputString = ""; // Variable to hold the input string
int receiver = 0; // Variable to hold the receiver number
bool dataReceived = false; // Flag to indicate that data has been received

void setup() 
{
  pinMode(LED_PIN, OUTPUT);
  Serial.begin(9600); // Initialize serial communication at 9600 bits per second
  while (!Serial) {
    ; // Wait for the serial port to connect. Needed for native USB port only
  }
  Serial.println("Enter the text input:");
  generateKeys(); // Generate RSA keys
}

void loop() 
{
  if (!dataReceived) {
    if (Serial.available() > 0) {
      inputString = Serial.readStringUntil('\n'); // Read the input string from the Serial Monitor
      inputString.trim(); // Remove any leading or trailing whitespace
      
      if (inputString.length() > 0) {
        Serial.println("Enter the receiver number (1 or 2):");
        
        while (Serial.available() == 0) {
          // Wait for the user to enter the receiver number
        }
        receiver = Serial.parseInt(); // Read the receiver number from the Serial Monitor
        Serial.read(); // Clear the newline character left in the buffer
        
        // Create the final string with repeated receiver number
        String finalString = inputString + String(receiver) + String(receiver) + String(receiver) + String(receiver);
        string_length = finalString.length();

        // Allocate memory for the string and copy the finalString to it
        string = new char[string_length + 1];
        finalString.toCharArray(string, string_length + 1);
        
        // Print the final string to the Serial Monitor
        Serial.print("Final string to transmit: ");
        Serial.println(string);

        // RSA encryption and display on serial monitor
        Serial.println("RSA Encrypted Message:");
        for (int i = 0; i < string_length; i++) {
          unsigned long encryptedValue = encrypt(string[i]);
          Serial.print(encryptedValue);
          Serial.print(" ");
        }
        Serial.println();

        dataReceived = true; // Set the flag to indicate that data has been received
      }
    }
  } else {
    if (string_length > 0) {
      for (int i = 0; i < string_length; i++) {
        send_byte(string[i]);
      }
      delay(1000); // Wait for a second before repeating the transmission
    }
  }
}

void send_byte(char my_byte)
{
  digitalWrite(LED_PIN, LOW);
  delay(PERIOD);

  // Transmission of bits
  for (int i = 0; i < 8; i++) {
    digitalWrite(LED_PIN, (my_byte & (0x01 << i)) != 0);
    delay(PERIOD);
  }

  digitalWrite(LED_PIN, HIGH);
  delay(PERIOD);
}

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
