# CBM_4032_WS
A CBM 4032 / 8032 implementation on a Waveshare core3s500e

This is a VHDL implementation of a Commodore CBM 4032 / 8032 on a Spartan 3E-500. An impletation of CBM 2031 logic working with a SD card is added.

I've used the Waveshare Core3S500E mounted on a board I've designed. The board contain :
- The Core3S500E
- 128k of SRAM (only 64k needed)
- SPI Flash PM25LV010
- VGA connector, direct output
- PS2 connector
- A 6-pin header for SD Card
- Others headers for I/O

The 64k SRAM is mapped on all memory location of original CBM (RAM & ROM). At the reset, a bootloader fetch the content of SPI Flash (contain the ROM image of both 4032 and 8032) and load it in corresponding SRAM location.

ROM image for CBM 2031 is loaded when creating ROM with the ISE IP Wizard, by load the corresponding .coe files.

ROM images are modified to add more compatibility with a standard Qwerty PS2 keyboard.
