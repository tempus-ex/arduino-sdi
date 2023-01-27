# arduino-sdi

This repo contains the project files for the Arduino-based SDI signal generator described in [this blog post](https://blog.tempus-ex.com/pro-video-with-arduinos-an-intro-to-sdi-video-and-pcb-fab/).

The final product looks like this:

![result](result.gif)

## Building

:warning: This hardware is not designed for production environments and comes with no guarantees or warrantees whatsoever.

This repo contains everything you need to build, alter, and run this hardware yourself using 100% free tools. If you choose to build the hardware, it'll cost about $87 for the Arduino, and at [JLCPCB](https://jlcpcb.com), assembly costs about $92 per board, including the cost of parts.

Steps from start to finish are as follows:

- In the hardware directory, there is a project file for [EasyEDA Pro](https://easyeda.com). From that project, you can export the files you need to get the parts and have them assembled.
- In the hardware directory, there is also a model for a clip which can be 3D printed to hold the Arduino in place once inserted into the MiniPCIe slot.
- In the firmware/projects directory, there is an Intel Quartus project file, which can be used to compile the FPGA bitstream. This can be done with Intel Quartus Prime Lite.
- Once the FPGA bitstream is created, you'll need to convert it to a format that the Arduino can load. For this, make sure Go and Make are installed, then run `make software/Sketch/app.h` from the root of this repo.
- To run the code on the Arduino, use the sketch in the software directory with the Arduino IDE.
