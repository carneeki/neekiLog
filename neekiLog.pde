/**
 * neekiLog - Logging Class by Adam Carmichael
 * (C) 2011 - Adam Carmichael <carneeki@carneeki.net>
 * <p>
 * @author  : $Author$
 * @version : $Revision$
 * @Date    : $Date$
 * @HeadURL : https://github.com/carneeki/neekiLog/raw/master/neekiLog.pde
 * @copyright This class is released under MIT License as follows below.
 */
/*
Copyright (c) 2011 Adam Carmichael <carneeki@carneeki.net>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

static class neekiLog extends PApplet {
  import java.io.BufferedWriter;
  import java.io.File;
  import java.io.FileNotFoundException;
  import java.io.FileWriter;
  import java.io.IOException;

  static int EMERG  = 6;
  static int ALERT  = 5;
  static int CRIT   = 4;
  static int WARN   = 3;
  static int NOTICE = 2;
  static int INFO   = 1;
  static int DEBUG  = 0;
  static String[] strLogLevelMap =
    {"DEBUG","INFO","NOTICE","WARN","CRIT","ALERT","EMERG"};

  String sLogFilename = "neekiLog.txt";
  String sLogFilePath;

  boolean bLoggingOn,bLogToFile = false;


  File fLogFile;
  BufferedWriter bufWriter;

  int LogLevel = 0; // modelled on syslog levels 0-6
      /* 6 - EMERG  - system is or will be unusable if situation is not
                      resolved
       * 5 - ALERT  - immediate action required
       * 4 - CRIT   - critical situations
       * 3 - WARN   - recoverable errors
       * 2 - NOTICE - unusual situation that merits investigation; a
                      significant event that is typically part of normal
                      day-to-day operation
       * 1 - INFO   - informational messages
       * 0 - DEBUG  - verbose data for debugging
       */
  /**
   * create a neekiLog object and log to a file given a path to place the log
   * file.
   * <p>
   * @param iLogLevel the logging level to be used. Can take any of the
            values 0 to 6, or use of the local immutable constants:
            this.EMERG
            this.ALERT
            this.CRIT
            this.WARN
            this.NOTICE
            this.INFO
            this.DEBUG
   * @param bLoggingOn a boolean value to determine whether to use logging or
   *        not. true to activate logging, else false.
   * @param sLogFilePath a string value denoting the path of the log file
   */
  neekiLog(int iLogLevel, boolean bLoggingOn, String sLogFilePath) {
    println(String.format("neekiLog( %d, %s, %s )", iLogLevel, bLoggingOn, sLogFilePath) );
    this.bLoggingOn = bLoggingOn;
    this.setLogToFile(sLogFilePath);
    this.setLogLevel(iLogLevel);
  }

  /**
   * create a neekiLog object and log to a file given a path to place the log
   * file.
   * <p>
   * @param iLogLevel the logging level to be used. Can take any of the
            following values:
   *        6 - EMERG  - system is or will be unusable if situation is not
   *                     resolved
   *        5 - ALERT  - immediate action required
   *        4 - CRIT   - critical situations
   *        3 - WARN   - recoverable errors
   *        2 - NOTICE - unusual situation that merits investigation; a
   *                     significant event that is typically part of normal
   *                     day-to-day operation
   *        1 - INFO   - informational messages
   *        0 - DEBUG  - verbose data for debugging
   * @param bLoggingOn a boolean value to determine whether to use logging or
   *        not. true to activate logging, else false.
   * @param bLogToFile a boolean value which, regardless of value, disables
   *        logging to a file. A string value here will result in logging to
   *        file.
   */
  neekiLog(int iLogLevel, boolean bLoggingOn, boolean bLogToFile) {
    this.bLoggingOn = bLoggingOn;
    this.bLogToFile = false;
    this.setLogLevel(iLogLevel);
  }

  /**
   * sets the logging threshold such that log entries beneath this threshold
   * will not be logged.
   * <p>
   * @param LogLevel an integer from 0-6 with the following values and meanings:
   *        6 - EMERG  - system is or will be unusable if situation is not
   *                     resolved
   *        5 - ALERT  - immediate action required
   *        4 - CRIT   - critical situations
   *        3 - WARN   - recoverable errors
   *        2 - NOTICE - unusual situation that merits investigation; a
   *                     significant event that is typically part of normal
   *                     day-to-day operation
   *        1 - INFO   - informational messages
   *        0 - DEBUG  - verbose data for debugging
   */
  public void setLogLevel(int LogLevel) {
    this.msg(this.INFO, String.format("Changing log level to: [%d]",LogLevel));
    this.LogLevel = LogLevel;
  }
  
  /**
   * sets the file path to be logged to and creates logging objects.
   * <p>
   * @param sLogFilePath a string with the path the log file shall reside in.
   * @throws IOException if an input or output error occurred
   */
  private void setLogToFile(String sLogFilePath) {
    this.bLogToFile = true;
    this.sLogFilePath = sLogFilePath + this.sLogFilename;
    try {
      this.fLogFile = new File(sketchPath(this.sLogFilePath));
      this.bufWriter = new BufferedWriter(new FileWriter(this.fLogFile,true) );
    } catch (IOException e) {
      System.out.println("Error attempted to create logfile: " + this.fLogFile.getAbsolutePath() );
      e.printStackTrace();
    }

    this.msg(this.INFO,
      String.format("File based logging ON. Using file %s.",
        this.fLogFile.getAbsolutePath()) );
  }
  
  /**
   * logs the message to the required log locations (console, file, etc),
   * preceded by a YYYY-MM-DD HH:mm:ss date and a log level by name.
   * @param MsgLevel an integer denoting the level of logging this message will
   *        be logged (or ignored) as.
   * @param strMessage a string containing a message to be logged.
   */
  public void msg(int MsgLevel, String strMessage) {
    String logMsg = String.format("[%04d-%02d-%02d %02d:%02d:%02d] %6s: %s\n",
           year(), month(), day(), hour(), minute(), second(),
           strLogLevelMap[MsgLevel], strMessage);

    if(this.bLoggingOn == true && this.LogLevel <= MsgLevel) { // threshold?
      print(logMsg);

      if(this.bLogToFile == true) { // log to file?
        try {
          this.bufWriter.write(logMsg);
          this.bufWriter.flush();
        } catch (IOException e) {
          System.out.println("Error attempted to write to log: " + this.fLogFile.getAbsolutePath() );
          e.printStackTrace();
        }
      }
    }
  }
  
  public void alert(String strMessage) {
    this.msg(this.ALERT, strMessage);
  }
  
  public void emerg(String strMessage) {
    this.msg(this.EMERG, strMessage);
  }

  public void crit(String strMessage) {
    this.msg(this.CRIT, strMessage);
  }
  
  public void warn(String strMessage) {
    this.msg(this.WARN, strMessage);
  }

  public void notice(String strMessage) {
    this.msg(this.NOTICE, strMessage);
  }

  public void info(String strMessage) {
    this.msg(this.INFO, strMessage);
  }
  
  public void debug(String strMessage) {
    this.msg(this.DEBUG, strMessage);
  }  

  /**
   * turn logging off, useful for debugging to avoid copious amounts of logs
   * inside loops. It should be used carefully however and never be seen in
   * production code.
   */
  public void off() {
    this.msg(this.ALERT, "Turning logging off");
    this.bLoggingOn = false;
  }

  /**
   * turn logging on, useful for debugging to avoid copious amounts of logs
   * inside loops. It should be used carefully however and never be seen in
   * production code.
   */
  public void on() {
    this.bLoggingOn = true;
    this.msg(this.ALERT, "Turning logging on");
  }
}