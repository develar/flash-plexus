package org.flyti.plexus.debug {
/**
 * These are the different types of logs that Mate Framework may show.
 * Each type has a default message that is displayed if the
 * <code>Debugger</code> is off.
 */
public class LogTypes {
  /**
   * Sequence started
   */
  public static const SEQUENCE_START:String = "Sequence started";

  /**
   * Sequence ended
   */
  public static const SEQUENCE_END:String = "Sequence ended";

  /**
   * Sequence triggered
   */
  public static const SEQUENCE_TRIGGER:String = "Sequence triggered";
}
}