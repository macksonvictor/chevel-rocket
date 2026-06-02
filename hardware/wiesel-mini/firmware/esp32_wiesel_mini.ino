/*
  WIESEL Mini - ESP32 bridge draft

  Purpose:
  - Receive simple serial commands.
  - Control a small prototype arm through PCA9685.
  - Keep servo angles inside safe prototype limits.

  Hardware:
  - ESP32 DevKit V1
  - PCA9685 16-channel servo driver
  - MG90S or SG90 servos
*/

#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver(0x40);

const int SERVO_MIN = 110;
const int SERVO_MAX = 510;
const int EMERGENCY_PIN = 33;
const int LED_ONLINE = 25;
const int LED_WARNING = 26;
const int LED_EMERGENCY = 27;

bool emergencyLatched = false;

struct ServoLimit {
  int channel;
  int minAngle;
  int maxAngle;
  int currentAngle;
};

ServoLimit baseServo     = {0, 0, 180, 90};
ServoLimit shoulderServo = {1, 20, 160, 90};
ServoLimit elbowServo    = {2, 20, 160, 90};
ServoLimit gripperServo  = {3, 20, 110, 60};

int angleToPulse(int angle) {
  return map(angle, 0, 180, SERVO_MIN, SERVO_MAX);
}

void setServo(ServoLimit &servo, int angle) {
  if (emergencyLatched) {
    Serial.println("ERR EMERGENCY");
    return;
  }
  angle = constrain(angle, servo.minAngle, servo.maxAngle);
  servo.currentAngle = angle;
  pwm.setPWM(servo.channel, 0, angleToPulse(angle));
}

void updateLeds() {
  digitalWrite(LED_ONLINE, emergencyLatched ? LOW : HIGH);
  digitalWrite(LED_WARNING, LOW);
  digitalWrite(LED_EMERGENCY, emergencyLatched ? HIGH : LOW);
}

void homePosition() {
  if (emergencyLatched) {
    Serial.println("ERR EMERGENCY");
    updateLeds();
    return;
  }
  setServo(baseServo, 90);
  setServo(shoulderServo, 90);
  setServo(elbowServo, 90);
  setServo(gripperServo, 60);
  Serial.println("OK HOME");
}

void printStatus() {
  Serial.print(emergencyLatched ? "STATE EMERGENCY " : "STATE READY ");
  Serial.print("BASE ");
  Serial.print(baseServo.currentAngle);
  Serial.print(" SHOULDER ");
  Serial.print(shoulderServo.currentAngle);
  Serial.print(" ELBOW ");
  Serial.print(elbowServo.currentAngle);
  Serial.print(" GRIPPER ");
  Serial.println(gripperServo.currentAngle);
}

void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);

  pinMode(EMERGENCY_PIN, INPUT_PULLUP);
  pinMode(LED_ONLINE, OUTPUT);
  pinMode(LED_WARNING, OUTPUT);
  pinMode(LED_EMERGENCY, OUTPUT);

  pwm.begin();
  pwm.setPWMFreq(50);

  delay(500);
  homePosition();
  updateLeds();
  Serial.println("WIESEL MINI READY");
}

void latchEmergency(const char *source) {
  emergencyLatched = true;
  updateLeds();
  Serial.print("OK STOP ");
  Serial.println(source);
}

void handleSetCommand(String target, int angle) {
  target.toUpperCase();

  if (target == "BASE") {
    setServo(baseServo, angle);
    Serial.println("OK BASE");
  } else if (target == "SHOULDER") {
    setServo(shoulderServo, angle);
    Serial.println("OK SHOULDER");
  } else if (target == "ELBOW") {
    setServo(elbowServo, angle);
    Serial.println("OK ELBOW");
  } else if (target == "GRIPPER") {
    setServo(gripperServo, angle);
    Serial.println("OK GRIPPER");
  } else {
    Serial.println("ERR UNKNOWN_SERVO");
  }
}

void loop() {
  if (digitalRead(EMERGENCY_PIN) == LOW && !emergencyLatched) {
    latchEmergency("GPIO33");
  }

  if (!Serial.available()) {
    return;
  }

  String line = Serial.readStringUntil('\n');
  line.trim();

  if (line.length() == 0) {
    return;
  }

  if (line == "PING") {
    Serial.println("OK PONG");
    return;
  }

  if (line == "STATUS") {
    printStatus();
    return;
  }

  if (line == "HOME") {
    homePosition();
    updateLeds();
    return;
  }

  if (line == "STOP") {
    latchEmergency("SERIAL");
    return;
  }

  if (line.startsWith("SET ")) {
    int firstSpace = line.indexOf(' ');
    int secondSpace = line.indexOf(' ', firstSpace + 1);

    if (secondSpace < 0) {
      Serial.println("ERR BAD_SET_FORMAT");
      return;
    }

    String target = line.substring(firstSpace + 1, secondSpace);
    int angle = line.substring(secondSpace + 1).toInt();

    handleSetCommand(target, angle);
    return;
  }

  Serial.println("ERR UNKNOWN_COMMAND");
}
