# CSTroN

CSTN was once popular among low-end laptops and cellphones, and its predecessor, STN was almost the only viable option for laptop before TFT LCD was invented. Thanks to the advance of technology, they are fully replaced with TFT LCD. But just for fun, how would software and games today look like on a 90s CSTN LCD?

Basically, this project aims to build an LCD monitor based around a CSTN screen (specifically SX21V004, but once done, it is easy to adapt other panels).

This task would be easy for normal TFT LCDs, one would just need to buy the screen, the driver board, and optionally a case, assemble them together, done. Though one may build driver board and/or case yourself, but given they are easy to find and very affordable, there is not many reasons to build by oneself.

But the story is quite different for CSTN. Most of the large (>3") CSTNs use a very different interface than TFT LCD, making it impossible to connect them to normal driver board designed for TFT LCDs. CSTN driver boards are just no longer available. (But I do confirm that they once existed) Currently, the only solution is to use an FPGA to build a driver board.

This project, once again, utilize my Xilinx ML505 Virtex-5 development board. The on-board VGA decoder is used for capturing incoming VGA video signal, and the CSTN screen is connected to the XGI expansion port. (By the way, Xilinx ditched both ports on their 6 series development boards, making ML505 the last development board with lots of on-board peripherals and a 2.54mm expansion port.)

Currently, the project is almost done. It could capture the VGA signal and display the image on the screen at 60Hz Vsync. STN LCD runs at 120Hz or 240Hz to improve color depth. Demo video is coming.

# License

OHDL