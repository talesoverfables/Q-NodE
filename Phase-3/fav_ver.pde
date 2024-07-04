String labelMessage = "Received message: ";
String labelBits = "Bits: ";
String labelEncrypted = "Encrypted message using Pauli X gate: ";
String text = "Hello"; // Updated starting string
String binaryText = "";  // Variable to store binary representation
String encryptedText = "";  // Variable to store encrypted binary representation
int index = 0;
int spacing = 38; // Approximately 1 cm in pixels
int frameCount = 0;
boolean stop = false;
int displayCount = 0;
int displayLimit = 5; // Number of times to display the message
int displaySpeed = 2; // Increase this value to slow down (lower speed)

// Transition phases
int transitionPhase = 0;
int transitionStartTime = 0;
int transitionDuration = 4000; // 4 seconds in milliseconds

void setup() {
  size(1600, 800);   // Set the size of the window to 1600x800 pixels
  background(0);     // Set the background to black
  textSize(32);      // Set the text size
  
  // Convert text to binary
  for (int i = 0; i < text.length(); i++) {
    binaryText += charToBinary(text.charAt(i)) + " ";  // Convert each character to binary
  }
  
  // Encrypt binary using Pauli X gate (bitwise NOT operation)
  encryptedText = applyPauliXGate(binaryText);

  // Draw Alice and Bob boxes
  drawAliceAndBob();
}

void draw() {
  if (displayCount < displayLimit) { // Check if we have displayed the message 5 times
    background(0);     // Clear the background each frame to remove previous text
    drawAliceAndBob(); // Redraw Alice and Bob boxes
    fill(192);         // Set the text color to grey (192 is a light grey value)
    
    // Perform transitions based on phase
    if (transitionPhase == 0) {
      // Transition 1: Encrypting the received text - Hello
      if (millis() - transitionStartTime < transitionDuration) {
        displayTransition("Encrypting the received text - Hello", width / 2, height / 2 - 80);
        animateText("Encrypting the received text - Hello", width / 2, height / 2 - 80, 2);
      } else {
        transitionPhase++;
        transitionStartTime = millis();
        index = 0;
      }
    } else if (transitionPhase == 1) {
      // Transition 2: Display binary representation
      if (millis() - transitionStartTime < transitionDuration) {
        displayTransition("Binary representation:", width / 2, height / 2 - 80);
        animateText(binaryText.substring(0, index * 9), width / 2 + 10, height / 2 + 40, 2); // Display binary
        index++;
        if (index > binaryText.length() / 9) {
          index = binaryText.length() / 9;
        }
      } else {
        transitionPhase++;
        transitionStartTime = millis();
        index = 0;
      }
    } else if (transitionPhase == 2) {
      // Transition 3: Encryption using Pauli X gate
      if (millis() - transitionStartTime < transitionDuration) {
        displayTransition("Encryption using Pauli X gate:", width / 2, height / 2 - 80);
        animateText(encryptedText.substring(0, index * 9), width / 2 + 10, height / 2 + 160, 2); // Display encrypted binary
        index++;
        if (index > encryptedText.length() / 9) {
          index = encryptedText.length() / 9;
        }
      } else {
        transitionPhase++;
        transitionStartTime = millis();
      }
    } else if (transitionPhase == 3) {
      // Transition 4: Decrypting the message for RSA encryption
      if (millis() - transitionStartTime < transitionDuration) {
        displayTransition("Decrypting the message for RSA encryption", width / 2, height / 2 - 80);
        animateText("Decrypting the message for RSA encryption", width / 2, height / 2 - 80, 2);
      } else {
        transitionPhase++;
        transitionStartTime = millis();
        displayTransition("Original text:", width / 2, height / 2 + 40); // Display label for original text
      }
    } else if (transitionPhase == 4) {
      // Display original text
      displayTransition(text, width / 2, height / 2 + 80);
      transitionPhase++;
    } else if (transitionPhase == 5) {
      // Transition 5: Transmitting...
      if (millis() - transitionStartTime < transitionDuration) {
        displayTransition("Transmitting...", width / 2, height / 2 - 80);
        animateText("Transmitting...", width / 2, height / 2 - 80, 2);
      } else {
        transitionPhase++;
      }
    } else {
      noLoop(); // Stop the draw loop after displaying transitions
      stop = true;
    }
  }
}

// Function to display transition message
void displayTransition(String message, int x, int y) {
  textAlign(CENTER);
  text(message, x, y);
}

// Function to animate text with random movement
void animateText(String content, int x, int y, int speed) {
  float xOffset = random(-1, 1) * speed;
  float yOffset = random(-1, 1) * speed;
  text(content, x + xOffset, y + yOffset);
}

// Function to display text content
void displayText(String content, String label, int x, int y, int speed) {
  textAlign(LEFT);
  text(label, x, y);
  text(content, x + textWidth(label) + 10, y);
}

// Function to convert character to binary string
String charToBinary(char c) {
  String binary = Integer.toBinaryString(c); // Convert character to binary string
  // Pad with zeros to ensure 8-bit representation
  while (binary.length() < 8) {
    binary = "0" + binary;
  }
  return binary;
}

// Function to apply Pauli X gate (bitwise NOT operation)
String applyPauliXGate(String binary) {
  String encrypted = "";
  for (int i = 0; i < binary.length(); i++) {
    if (binary.charAt(i) == '0') {
      encrypted += '1';
    } else {
      encrypted += '0';
    }
  }
  return encrypted;
}

// Function to draw Alice and Bob boxes
void drawAliceAndBob() {
  fill(255); // Set fill color to white
  
  // Draw the left box (Alice)
  rect(50, height / 2 - 50, 100, 100); // Adjust position and size as needed
  
  // Draw the right box (Bob)
  rect(width - 150, height / 2 - 50, 100, 100); // Adjust position and size as needed
  
  fill(0); // Set fill color to black for text
  
  // Add labels inside the boxes
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Alice", 50 + 50, height / 2); // Center text inside Alice's box
  text("Bob", width - 150 + 50, height / 2); // Center text inside Bob's box
}
