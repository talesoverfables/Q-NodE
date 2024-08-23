import processing.serial.*;

Serial myPort;        // The serial port
String inString;      // Input string from serial port
String labelMessage = "Received message: ";
String labelBits = "Bits: ";
String labelEncrypted = "Encrypted message using Pauli X gate: ";
String text = "";  // Starting string, will be updated from serial input
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

// Variables for animation
ArrayList<Bit> bits = new ArrayList<Bit>(); // List to store moving bits

void setup() {
  size(1600, 800);   // Set the size of the window to 1600x800 pixels
  background(0);     // Set the background to black
  textSize(32);      // Set the text size
  
  // Initialize serial communication
  String portName = Serial.list()[0];  // Get the first available port
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  
  // Draw Alice and Bob boxes
  drawRouters();
  
  // Create initial bits
  for (int i = 0; i < 20; i++) {
    float startX = random(100, 300); // Random start X within range for R1
    float startY = random(300, 500); // Random start Y within range
    float endX = random(1200, 1400); // Random end X within range for R2
    float endY = random(300, 500); // Random end Y within range
    int routerColor = color(255, 0, 0); // Red color for R1
    
    if (random(1) > 0.5) {
      startX = random(1200, 1400); // Random start X within range for R2
      endX = random(100, 300); // Random end X within range for R1
      routerColor = color(0, 0, 255); // Blue color for R2
    }
    
    bits.add(new Bit(startX, startY, endX, endY, routerColor));
  }
}

void draw() {
  background(0);     // Clear the background each frame to remove previous text and drawings
  drawRouters(); // Redraw routers
  fill(192);         // Set the text color to grey (192 is a light grey value)
  
  // Display binary representation
  textAlign(LEFT);
  text(labelBits, 50, height - 50); // Display label for binary representation
  text(binaryText, 50 + textWidth(labelBits), height - 50); // Display binary text
  
  // Perform transitions based on phase
  if (transitionPhase == 0) {
    // Transition 1: Encrypting the received text
    if (millis() - transitionStartTime < transitionDuration) {
      displayTransition("Encrypting the received text - " + text, width / 2, height / 2 - 80);
      animateText("Encrypting the received text - " + text, width / 2, height / 2 - 80, 2);
    } else {
      transitionPhase++;
      transitionStartTime = millis();
      index = 0;
    }
  } else if (transitionPhase == 1) {
    // Transition 2: Display binary representation
    if (millis() - transitionStartTime < transitionDuration) {
      displayTransition("Binary representation:", width / 2, height / 2 - 80);
      animateBinary(); // Animate binary bits moving
    } else {
      transitionPhase++;
      transitionStartTime = millis();
      index = 0;
    }
  } else if (transitionPhase == 2) {
    // Transition 3: Encryption using Pauli X gate
    if (millis() - transitionStartTime < transitionDuration) {
      displayTransition("Encryption using Pauli X gate:", width / 2, height / 2 - 80);
      animateEncrypted(); // Animate encrypted bits moving
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
    // Reset transition phase to restart animation
    transitionPhase = 0;
    transitionStartTime = millis();
    index = 0;
  }

  // Update and display each bit
  for (Bit bit : bits) {
    bit.update();
    bit.display();
  }
}

// Function to display transition message
void displayTransition(String message, int x, int y) {
  textAlign(CENTER);
  text(message, x, y);
}

// Function to animate binary bits moving
void animateBinary() {
  // Animate existing bits
  for (Bit bit : bits) {
    bit.move();
  }
}

// Function to animate encrypted bits moving
void animateEncrypted() {
  // Animate existing bits
  for (Bit bit : bits) {
    bit.move();
  }
}

// Function to display text content
void animateText(String content, int x, int y, int speed) {
  float xOffset = random(-1, 1) * speed;
  float yOffset = random(-1, 1) * speed;
  text(content, x + xOffset, y + yOffset);
}

// Function to draw routers R1 and R2
void drawRouters() {
  fill(255); // Set fill color to white
  
  // Draw router R1
  rect(50, height / 2 - 50, 100, 100); // Adjust position and size as needed
  
  // Draw router R2
  rect(width - 150, height / 2 - 50, 100, 100); // Adjust position and size as needed
  
  fill(0); // Set fill color to black for text
  
  // Add labels inside the routers
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Router R1", 50 + 50, height / 2); // Center text inside router R1's box
  text("Router R2", width - 150 + 50, height / 2); // Center text inside router R2's box
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

// Class to represent a moving bit
class Bit {
  float startX, startY; // Starting position
  float endX, endY;     // Ending position
  float x, y;           // Current position
  float speed;          // Speed of movement
  int routerColor;      // Color of router (red or blue)

  Bit(float startX, float startY, float endX, float endY, int routerColor) {
    this.startX = startX;
    this.startY = startY;
    this.endX = endX;
    this.endY = endY;
    this.routerColor = routerColor;
    this.x = startX;
    this.y = startY;
    this.speed = random(5, 10); // Random speed between 5 and 10
  }

  // Update the position of the bit
  void update() {
    move();
  }

  // Display the bit as a colored circle
  void display() {
    noStroke();
    fill(routerColor);
    ellipse(x, y, 10, 10); // Adjust size of circle as needed
  }

  // Check if the bit has reached the end point
  boolean reachedEnd() {
    return dist(x, y, endX, endY) < 1;
  }

  // Move the bit along the path
  void move() {
    float dx = (endX - startX) / transitionDuration * speed;
    float dy = (endY - startY) / transitionDuration * speed;
    x += dx;
    y += dy;
    
    // Reset position if bit reaches the end point
    if (reachedEnd()) {
      x = startX;
      y = startY;
    }
  }
}

// Function to handle serial event
void serialEvent(Serial myPort) {
  inString = myPort.readStringUntil('\n'); // Read until newline
  if (inString != null) {
    inString = trim(inString); // Trim any whitespace
    text = inString; // Update text with the received string

    // Convert text to binary
    binaryText = "";
    for (int i = 0; i < text.length(); i++) {
      binaryText += charToBinary(text.charAt(i)) + " ";  // Convert each character to binary
    }
  
    // Encrypt binary using Pauli X gate (bitwise NOT operation)
    encryptedText = applyPauliXGate(binaryText);
    
    // Reset transition phase and start animation
    transitionPhase = 0;
    transitionStartTime = millis();
    loop(); // Start the draw loop again
  }
}
