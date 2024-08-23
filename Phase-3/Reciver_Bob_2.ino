// Bob 2 code
#define LED_PIN A1
#define LDR_PIN A2
#define THRESHOLD 100
#define PERIOD 15

bool previous_state;
bool current_state;
String received_message = "";
unsigned long previous_millis = 0;
const unsigned long RECEIVE_DURATION = 10000; // 10 seconds

void setup() 
{
    Serial.begin(9600);
    pinMode(LED_PIN, OUTPUT);
    pinMode(LDR_PIN, INPUT);
    Serial.println("Bob 2: Receiving mode");
    previous_millis = millis();
}

void loop() 
{
    unsigned long current_millis = millis();
    
    if (current_millis - previous_millis <= RECEIVE_DURATION) {
        // Receiving mode
        current_state = get_ldr();
        if (!current_state && previous_state) {
            char received_char = get_byte();
            print_byte(received_char);
            received_message += received_char;
        }
        previous_state = current_state;
    } else {
        // Display mode
        Serial.println();
        Serial.print("Received message: ");
        Serial.println(received_message);

        if (received_message.indexOf('1') != -1) {
            // Shift ASCII values by 11
            for (int i = 0; i < received_message.length(); i++) {
                received_message[i] = received_message[i] + 11;
            }
            Serial.print("Transformed message: ");
            Serial.println(received_message);
        } else {
            Serial.print("Message displayed: ");
            Serial.println(received_message);
        }

        // Reset for next receive cycle
        received_message = "";
        previous_millis = current_millis;
        Serial.println("Bob 2: Receiving mode");
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
