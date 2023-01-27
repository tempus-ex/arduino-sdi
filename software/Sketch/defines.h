#define TDI         12
#define TDO         15
#define TCK         13
#define TMS         14
#define MB_INT      28
#define MB_INT_PIN  31
#define SIGNAL_OUT  41
#define SIGNAL_IN   33

#define SET_PIN 5
#define LED_PIN 6

#define no_data 0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0xFF, 0xFF, 0xFF, 0xFF, \
                0x00, 0x00, 0x00, 0x00  \

#define NO_BOOTLOADER   no_data
#define NO_APP          no_data
#define NO_USER_DATA    no_data

__attribute__ ((used, section(".fpga_bitstream_signature")))
const unsigned char signatures[4096] = {
  #include "signature.h"
};
__attribute__ ((used, section(".fpga_bitstream")))
const unsigned char bitstream[] = {
  #include "app.h"
};

void setup_fpga()
{
  int ret;
  uint32_t ptr[1];

  //enableFpgaClock();
  pinPeripheral(30, PIO_AC_CLK);
  clockout(0, 1);
  delay(1000);
  
  //Init Jtag Port
  ret = jtagInit();
  mbPinSet();

  // Load FPGA user configuration
  ptr[0] = 0 | 3;
  mbEveSend(ptr, 1);

  // Give it delay
  delay(1000);

  // Configure onboard LED Pin as output
  pinMode(LED_BUILTIN, OUTPUT);

  // Disable all JTAG Pins (useful for USB BLASTER connection)
  pinMode(TDO, INPUT);
  pinMode(TMS, INPUT);
  pinMode(TDI, INPUT);
  pinMode(TCK, INPUT);

  // Configure other share pins as input too
  pinMode(SIGNAL_IN, INPUT);  // oSAM_INTstat
  pinMode(MB_INT_PIN, INPUT);
  pinMode(MB_INT, INPUT);
}
