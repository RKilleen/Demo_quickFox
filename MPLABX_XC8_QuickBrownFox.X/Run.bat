@echo off
rem Get the short path to get rid of spaces
for %%i in ("C:\Program Files (x86)\Microchip\MPLABX\v5.35\sys\java\jre1.8.0_181\") do set JAVA_HOME=%%~si
set JAVA_OPTS="-Xmx400m"
set path=C:\Program Files (x86)\Groovy\Groovy-3.0.0\bin;%path%
set tbed="C:\LDRA_Toolsuite"

set mplabx=C:\Program Files (x86)\Microchip\MPLABX\v5.35\
set sdk="C:\mplab-x-sdk\"
set conf=default
set res=history.exh
set hwtool=SIM
set device=PIC16LF18856
set power=TRUE
set voltage=3.0
set drive=z
set exe=.\\dist\\%conf%\\debug\\MPLABX_XC8_QuickBrownFox.X.debug.elf
set root=%cd%
set script="Harness.groovy"
set exit_function=
set exit_count=
set baud=9600
set comport=12
set comporter=%tbed%\Utils\Comporter
set mode=LDRA_SCRIPT

if not exist %exe% (
  echo ERROR: Failed to locate the executable: %exe%
  echo        Please ensure that the project is built
  echo.
  ping localhost -n 6 >nul
  exit /B 1
)

rem ensure that the mplabx path does not have a trailing backslash
if %mplabx:~-1%==\ set mplabx=%mplabx:~0,-1%

rem set up the path/drive substitution to ensure that classpath is within windows limit
if exist %drive%: subst %drive%: /D

rem prior to v4.20 the mplab_ide folder existed
if exist "%mplabx%\mplab_ide\bin\mplab_ide.exe" subst %drive%: "%mplabx%\mplab_ide"
rem from v4.20, it was replaced with mplab_platform folder
if exist "%mplabx%\mplab_platform\bin\mplab_ide.exe" subst %drive%: "%mplabx%"

rem create the classpath using the %drive% drive to reduce the length of the classpath
cd /d %sdk%MPLAB_X\mdbcs\utils
call groovy.bat getcp.groovy %drive%:
if not exist "%JAVA_HOME%\bin\java.exe" (
  echo ERROR: Failed to locate "%JAVA_HOME%\bin\java.exe"
  echo.
  ping localhost -n 6 >nul
  exit /B 1
)

call classpath.bat
if errorlevel 1 (
  echo ERROR: Problem when creating the Class Path"
  echo.
  ping localhost -n 6 >nul
  exit /B 1
)

cd /d %root%

rem Delete any existing file
if exist history.exh del /F history.exh
if exist tbrun.top del /F tbrun.top

rem create the groovy script
echo // Harness for uploading data from the target/simulator > %script%
echo. >> %script%
echo import com.microchip.mdbcs.Debugger >> %script%
echo import com.microchip.mdbcs.Helper >> %script%
echo. >> %script%
echo class Harness { >> %script%
if ["%mode%"]==["LDRA_SCRIPT"] (
  echo   String filename = "%res%" >> %script%
)
echo   String device = "%device%" >> %script%
echo   String hwtool = "%hwtool%" >> %script%
echo   String exe = "%exe%" >> %script%
echo. >> %script%
echo   Debugger debugger = null >> %script%
echo   File txt = null >> %script%
echo   long pc >> %script%
if ["%mode%"]==["LDRA_SCRIPT"] (
  echo   long ldra_upload >> %script%
  echo   long ldra_message >> %script%
  echo   long iter_ldra_message >> %script%
  echo   long ldra_exit_reached >> %script%
) else (
  echo   long ldra_exit >> %script%
)
echo   long exit_reached = 0 >> %script%
echo. >> %script%
echo   static void main(args) { >> %script%
echo     new Harness().run() >> %script%
echo   } >> %script%
echo. >> %script%
echo   def run() { >> %script%
if ["%mode%"]==["LDRA_SCRIPT"] (
  echo     byte[] c = new byte[1] >> %script%
  echo     byte[] b = new byte[4] >> %script%
  echo     byte[] buffer = new byte[2048] >> %script%
)
echo     try { >> %script%
echo       debugger = new Debugger(device, hwtool, true) >> %script%
if not %hwtool% == SIM (
  if %power% == TRUE (
    echo       debugger.setVDD(%voltage%^) >> %script%
  )
)
echo       debugger.connect() >> %script%
echo       debugger.loadFile(exe) >> %script%
echo       debugger.program() >> %script%
echo. >> %script%
echo       // Get addresses of variables / functions >> %script%
if ["%mode%"]==["LDRA_SCRIPT"] (
  echo       ldra_upload = debugger.getSymbolAddress("ldra_upload"^) >> %script%
  echo       ldra_message = debugger.getSymbolAddress("ldra_message"^) >> %script%
  echo       iter_ldra_message = debugger.getSymbolAddress("iter_ldra_message"^) >> %script%
  echo       ldra_exit_reached = debugger.getSymbolAddress("ldra_exit_reached"^) >> %script%
  echo. >> %script%
  echo       // Set breakpoints >> %script%
  echo       println "Setting breakpoints: " + debugger.getNumAvailableBP(^) + " / " + debugger.getNumMaxBP(^) + " available " >> %script%
  echo       debugger.setBP(ldra_upload^) >> %script%
  echo. >> %script%
  echo       // Create the file >> %script%
  echo       println "Creating file " + filename >> %script%
  echo       txt = new File(filename^) >> %script%
  echo       txt.write "" >> %script%
) else (
  echo       ldra_exit = debugger.getSymbolAddress("ldra_exit"^) >> %script%
  echo. >> %script%
  echo       // Set breakpoints >> %script%
  echo       println "Setting breakpoints: " + debugger.getNumAvailableBP(^) + " / " + debugger.getNumMaxBP(^) + " available " >> %script%
  echo       debugger.setBP(ldra_exit^) >> %script%
)
echo. >> %script%
echo       while ( exit_reached == 0 ) { >> %script%
echo         debugger.run() >> %script%
echo         while (debugger.isRunning()){ >> %script%
echo           debugger.sleep (10) >> %script%
echo         } >> %script%
echo. >> %script%
echo         // Check where we are >> %script%
echo         pc = debugger.getPC() >> %script%
echo. >> %script%
if ["%mode%"]==["LDRA_SCRIPT"] (
  echo         if ( (pc^>=ldra_upload^) ^&^& (pc^<=ldra_upload+8^) ^) { >> %script%
  echo           // How many bytes do we need to read? >> %script%
  echo           debugger.readFileRegisters(iter_ldra_message, 2, b^) >> %script%
  echo           int[] readBuff = Helper.convertBuffer(b^) >> %script%
  echo           int bytes = readBuff[0] >> %script%
  echo           println "Reading " + bytes + " characters" >> %script%
  echo. >> %script%
  echo           // Read the ldra_message >> %script%
  echo           debugger.readFileRegisters(ldra_message, bytes, buffer^) >> %script%
  echo. >> %script%
  echo           // And save to file >> %script%
  echo           for (int i=0; i^<bytes; i++^) { >> %script%
  echo             txt ^<^< (char^)buffer[i] >> %script%
  echo           } >> %script%
  echo           debugger.readFileRegisters(ldra_exit_reached, 1, c^) >> %script%
  echo           exit_reached = c[0] >> %script%
  echo         } >> %script%
) else (
  echo         if ( (pc^>=ldra_exit^) ^&^& (pc^<=ldra_exit+8^) ^) { >> %script%
  echo           exit_reached = 1 >> %script%
  echo         } >> %script%
)
echo       } >> %script%
echo. >> %script%
echo       // Disconnect from the debugger >> %script%
echo       println "Exit reached" >> %script%
if ["%mode%"]==["LDRA_SCRIPT"] (
  echo       println "Writing %res%" >> %script%
)
echo       debugger.disconnect() >> %script%
echo       debugger = null >> %script%
echo       System.exit(0) >> %script%
echo     } catch (e) { >> %script%
echo       println "Exception occurred: " + e.toString() >> %script%
echo       if (debugger != null) { >> %script%
echo         debugger.disconnect() >> %script%
echo         debugger = null >> %script%
echo       } >> %script%
echo     } >> %script%
echo   } >> %script%
echo } >> %script%

if ["%mode%"]==["LDRA_SERIAL"] (
  cd /d %comporter%
  if not exist Comporter.exe (
    echo ERROR: Failed to locate Comporter: %comporter%\Comporter.exe
    echo.
    ping localhost -n 6 >nul
    exit /B 1
  )
  
  rem Configure the Comporter to listen to the serial port
  rem This generates the file %comporter%\comports.ini
  rem ======================================================
  @echo configuring Comporter for %baud% baud on port %comport%
  start "ldra" /wait Gencomporterini.exe %comporter% "mplabx" %comport% %baud% N 8 1 comNone %root%\%res% 10

  rem Start the Comporter
  rem It starts capturing data after receiving LDRA_Start
  rem It stops capturing data after receiving LDRA_Terminate
  rem It will save the captured data to the file %res%
  rem ======================================================
  @echo starting Comporter to capture file %res%
  start "ldra" Comporter.exe

  if errorLevel 1 (
    echo ERROR: Comporter has failed to start
    echo        Possibly it can't open port %comport%
    echo        Or the baud rate may be unsupported
    echo.
    ping localhost -n 6 >nul
    exit /B 1
  )
  cd /d %root%
)

rem Program software and start execution
@echo on
call groovy.bat Harness.groovy
@echo off

if errorLevel 1 (
  echo ERROR: Groovy script has failed
  echo.
  ping localhost -n 6 >nul
  exit /B 1
)

if ["%mode%"]==["LDRA_SERIAL"] (
  @echo waiting for Comporter to capture the data and exit
:LOOP
  ping localhost -n 3 >nul
  for /F %%x in ('tasklist /NH /FI "IMAGENAME eq Comporter.exe"') do if %%x == Comporter.exe goto LOOP
)

rem clean up
if exist MPLABXLog.* del /F MPLABXLog.*

rem Remove substituted drive
if exist %drive%: subst %drive%: /D

if exist %res% (
  %tbed%\TBbrowse %res%
  exit
) else (
  echo ERROR: Failed to locate file: %res%
  echo.
  ping localhost -n 6 >nul
  exit /B 1
)
