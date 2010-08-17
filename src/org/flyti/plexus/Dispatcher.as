package org.flyti.plexus {
import flash.events.Event;

public final class Dispatcher {
  public static function dispatch(event:Event):void {
    PlexusManager.instance.container.dispatcher.dispatchEvent(event);
  }
}
}