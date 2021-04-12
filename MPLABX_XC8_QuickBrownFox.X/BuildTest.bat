@echo off
@echo calling prjMakeFilesGenerator
set mplabx=C:\Program Files (x86)\Microchip\MPLABX\v5.35\
set path=%mplabx%mplab_ide\bin;%mplabx%mplab_platform\bin;%mplabx%gnuBins\GnuWin32\bin;%PATH%;
set proj=%cd%
set conf=default

call prjMakefilesGenerator.bat -v -f "%proj%"@%conf%
make clean

rem Need to set the path to just this directory, otherwise mkdir fails
set path=%mplabx%gnuBins\GnuWin32\bin
@echo on
make TYPE_IMAGE=DEBUG_RUN

if errorlevel = 1 pause
