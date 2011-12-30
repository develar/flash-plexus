package org.flyti.plexus.component {
import cocoa.lang.Enum;

/**
 * http://plexus.codehaus.org/ref/component-configuration.html
 */
public final class InstantiationStrategy extends Enum {
  /**
   * This ensures a component is only used as a singleton, and is only shutdown when the container shuts down
   */
  public static const KEEP_ALIVE:InstantiationStrategy = new InstantiationStrategy("keepAlive");

  /**
   * Every time you lookup a component one will be created
   */
  public static const PER_LOOKUP:InstantiationStrategy = new InstantiationStrategy("perLookup");

  public function InstantiationStrategy(name:String) {
    super(name);
  }
}
}