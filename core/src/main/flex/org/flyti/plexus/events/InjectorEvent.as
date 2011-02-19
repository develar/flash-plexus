package org.flyti.plexus.events {
import flash.events.Event;

import mx.core.IDeferredInstantiationUIComponent;

/**
 * This event is used by the InjectorRegistry to register a target for Injection.
 */
public class InjectorEvent extends Event {
  public static const INJECT:String = "inject";

  public var instance:Object;

  /**
   * Unique identifier to distinguish the target
   */
  public var uid:String;

  public function InjectorEvent(target:Object, uid:String = null) {
    this.instance = target;
    if (uid == null && target is IDeferredInstantiationUIComponent) {
      this.uid = IDeferredInstantiationUIComponent(target).id;
    }
    else {
      this.uid = uid;
    }

    super(INJECT, true);
  }
}
}