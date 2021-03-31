@echo off
set mplabx=C:\Program Files (x86)\Microchip\MPLABX\v5.35\
set compiler=C:\Program Files (x86)\Microchip\xc8\v2.05\
set path=%compiler%bin;%mplabx%mplab_ide\bin;%mplabx%mplab_platform\bin;%mplabx%gnuBins\GnuWin32\bin;%PATH%;
set device=16LF18856
set project=MPLABX_XC8_QuickBrownFox.X
set conf=default
set mode=debug
set file=main

rem Ensure that the folders are created
if not exist build\%conf%\%mode% mkdir build\%conf%\%mode%
if not exist dist\%conf%\%mode% mkdir dist\%conf%\%mode%

xc8-cc.exe -mcpu=%device% -c -D__DEBUG=1 -fno-short-double -fno-short-float -fasmfile -Og -maddrqual=ignore -xassembler-with-cpp -Wa,-a -DXPRJ_default=%conf% -msummary=-psect,-class,+mem,-hex,-file -ginhx032 -Wl,--data-init -mno-keep-startup -mosccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -std=c99 -gdwarf-3 -mstack=compiled:auto:auto -o build/%conf%/%mode%/%file%.p1 %file%.c

xc8-cc.exe -mcpu=%device% -Wl,-Map=dist/%conf%/%mode%/%project%.%mode%.map -D__DEBUG=1 -DXPRJ_default=%conf% -Wl,--defsym=__MPLAB_BUILD=1 -fno-short-double -fno-short-float -fasmfile -Og -maddrqual=ignore -xassembler-with-cpp -Wa,-a -msummary=-psect,-class,+mem,-hex,-file -ginhx032 -Wl,--data-init -mno-keep-startup -mosccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -std=c99 -gdwarf-3 -mstack=compiled:auto:auto -w -Wl,--memorysummary,dist/%conf%/%mode%/memoryfile.xml -o dist/%conf%/%mode%/%project%.%mode%.elf build/%conf%/%mode%/%file%.p1

if errorlevel 1 pause
