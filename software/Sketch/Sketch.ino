
// Source adapted from https://github.com/wd5gnr/VidorFPGA
// Adaptions: Moved the define statements and the FPGA
//            setup routine to a separate file and changed
//            a few names in this file and added a few comments.

#include <wiring_private.h>
#include "jtag.h"
#include "defines.h"

int blinkSpeed = HIGH;

void setup()
{
  setup_fpga();

  Serial.begin(9600);

  pinMode(SET_PIN, OUTPUT);
  pinMode(LED_PIN, INPUT);

  digitalWrite(SET_PIN, blinkSpeed);

  Serial.println("FPGA and MCU started!");
  Serial.println("Input anything to change the LED toggle speed!");
}

void loop()
{
  static int oldstate = -1;
  static int linect = 0;
  int state;

  // The following block sets a pin high which tells
  // the FPGA how quickly it should flash the LED
  if (Serial.read() != -1)
  {
    Serial.println("Changing speed!");
    blinkSpeed = blinkSpeed == HIGH ? LOW : HIGH;
    digitalWrite(SET_PIN, blinkSpeed);
  }

  // A value can also be read from the FPGA
  // In this case, the LED state is read and
  // printed to the console
  state = digitalRead(LED_PIN);
  
  if (state != oldstate)
  {
    digitalWrite(LED_BUILTIN, state);
    Serial.print(state);

    // Insert a line break once 16 states got printed
    if (++linect == 16)
    {
      Serial.println();
      linect = 0;
    }
    
    oldstate = state;
  }
}
