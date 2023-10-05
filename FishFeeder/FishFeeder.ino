#include <Stepper.h>

#define STEPS 2048

Stepper stepper(STEPS, 8, 10, 9, 11);

void setup() {
  stepper.setSpeed(5);
}


void loop() {
  stepper.step(STEPS / 4.0);
  delay(1000);
}
