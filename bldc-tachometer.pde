#include <WProgram.h>
#include <util/atomic.h>

#define NUMBER_OF_MOTOR_POLES 14

#define SERVO1 9
#define SERVO2 10
#define TACHOMETER_INT 3

volatile uint32_t pulseCount = 0;
volatile uint32_t pulseTimer = 0;
volatile uint32_t lastPulseTimer = 0;
volatile int32_t rps = 0;

uint32_t outputTimer = 0;
float filteredRPM = 0;

ISR(INT1_vect) {
  // Pulses are between 480 us and 200 us (at 1.67 kHz)
  if ( micros()-lastPulseTimer > 500 ) {
    pulseCount++;
    lastPulseTimer = micros();
  }
  
  if ( pulseCount > 10 ) {
    rps = pulseCount/(float(micros()-pulseTimer)/1000000.0f);
    pulseTimer = micros();
    pulseCount = 0;
  }
}

static __inline__ void checkForZeroPulses() {
  uint32_t safePulseTimer = 0;
  ATOMIC_BLOCK(ATOMIC_FORCEON)
  {
    safePulseTimer = pulseTimer;
  }
  
  if ( micros()-safePulseTimer > 100000l ) {
    rps = 0;
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("start");
  
  // Initialize input/output pins
  pinMode(SERVO1,OUTPUT);
  pinMode(SERVO2,OUTPUT);
  pinMode(TACHOMETER_INT,INPUT);
  
  // Initialize PWM output for 50 Hz
  TCCR1A = (1<<WGM11)|(1<<COM1A1)|(1<<COM1B1);
  TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS11);
  ICR1 = 10000; // CPU/prescaler/frequency = 16000000/8/200 // 200 Hz PWM rate
  
  // Attach the interrupt pin (INT1, Arduino Pin 3)
  EICRA = (EICRA & ~((1 << ISC10) | (1 << ISC11))) | (RISING << ISC10);
  EIMSK |= (1 << INT1);
}

void loop() {
  // If there have been no pulse, the RPM must be reset to zero.
  checkForZeroPulses();
  
  // Low pass filtered RPM calculation
  filteredRPM = filteredRPM*0.95 + rps*60/NUMBER_OF_MOTOR_POLES*0.05;
  
  // Output
  if ( millis() - outputTimer > 10 ) {
    Serial.println(filteredRPM);
    outputTimer = millis();
  }
}