netgear-dgnd3300
================

Customizations on netgear router DGND330 - Support DOCSIS, local dns server, general fixes.

NETGEAR DGND3300 Firmware Version 1.1.00.41 Open Source Code

1. Make custom modifications to source code and compile.

2. Change to the "root" user.
   su

3. Unpack the target image directory.
   tar jxf target.tar.bz2

4. Copy modified executable code to appropriate location in "target" directory.
   Note: Netgear will not support software modifications.

5. Create the firmware image. The new firmware will be called "newimage.img".
   ./build.sh "DGND3300NA-V1.1.00.41_1.00.41.img" target newimage.img

6. Change back to the normal user.
   exit

7. Use the normal web-based firmware upgrade procedure to load "newimage.img".
