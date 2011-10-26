package org.flyti.plexus.component {
import cocoa.lang.Enum;

public final class ComponentRequirement {
  public var role:Class;
  public var roleHint:Enum = RoleHint.DEFAULT;

  /**
   * if not specified, then constructor injection
   */
  public var field:String;
}
}