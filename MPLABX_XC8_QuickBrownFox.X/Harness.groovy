// Harness for uploading data from the target/simulator 
 
import com.microchip.mdbcs.Debugger 
import com.microchip.mdbcs.Helper 
 
class Harness { 
  String filename = "history.exh" 
  String device = "PIC16LF18856" 
  String hwtool = "SIM" 
  String exe = ".\\dist\\default\\debug\\MPLABX_XC8_QuickBrownFox.X.debug.elf" 
 
  Debugger debugger = null 
  File txt = null 
  long pc 
  long ldra_upload 
  long ldra_message 
  long iter_ldra_message 
  long ldra_exit_reached 
  long exit_reached = 0 
 
  static void main(args) { 
    new Harness().run() 
  } 
 
  def run() { 
    byte[] c = new byte[1] 
    byte[] b = new byte[4] 
    byte[] buffer = new byte[2048] 
    try { 
      debugger = new Debugger(device, hwtool, true) 
      debugger.connect() 
      debugger.loadFile(exe) 
      debugger.program() 
 
      // Get addresses of variables / functions 
      ldra_upload = debugger.getSymbolAddress("ldra_upload") 
      ldra_message = debugger.getSymbolAddress("ldra_message") 
      iter_ldra_message = debugger.getSymbolAddress("iter_ldra_message") 
      ldra_exit_reached = debugger.getSymbolAddress("ldra_exit_reached") 
 
      // Set breakpoints 
      println "Setting breakpoints: " + debugger.getNumAvailableBP() + " / " + debugger.getNumMaxBP() + " available " 
      debugger.setBP(ldra_upload) 
 
      // Create the file 
      println "Creating file " + filename 
      txt = new File(filename) 
      txt.write "" 
 
      while ( exit_reached == 0 ) { 
        debugger.run() 
        while (debugger.isRunning()){ 
          debugger.sleep (10) 
        } 
 
        // Check where we are 
        pc = debugger.getPC() 
 
        if ( (pc>=ldra_upload) && (pc<=ldra_upload+8) ) { 
          // How many bytes do we need to read? 
          debugger.readFileRegisters(iter_ldra_message, 2, b) 
          int[] readBuff = Helper.convertBuffer(b) 
          int bytes = readBuff[0] 
          println "Reading " + bytes + " characters" 
 
          // Read the ldra_message 
          debugger.readFileRegisters(ldra_message, bytes, buffer) 
 
          // And save to file 
          for (int i=0; i<bytes; i++) { 
            txt << (char)buffer[i] 
          } 
          debugger.readFileRegisters(ldra_exit_reached, 1, c) 
          exit_reached = c[0] 
        } 
      } 
 
      // Disconnect from the debugger 
      println "Exit reached" 
      println "Writing history.exh" 
      debugger.disconnect() 
      debugger = null 
      System.exit(0) 
    } catch (e) { 
      println "Exception occurred: " + e.toString() 
      if (debugger != null) { 
        debugger.disconnect() 
        debugger = null 
      } 
    } 
  } 
} 
