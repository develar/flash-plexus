package org.flyti.plexus {
import flash.events.Event;

public final class Dispatcher {
  public static function dispatch(event:Event):void {
    MateManager.instance.container.dispatcher.dispatchEvent(event);
  }
}
}