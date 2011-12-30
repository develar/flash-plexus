package org.flyti.plexus.events {
import flash.events.Event;
import flash.events.IEventDispatcher;

import org.flyti.plexus.PlexusManager;

public class ContextEventDispatcher {
  private var dispatcher:IEventDispatcher;

  public function ContextEventDispatcher() {
    dispatcher = PlexusManager.instance.container.dispatcher;
  }

  public function dispatchContextEvent(event:Event):Boolean {
    return dispatcher.dispatchEvent(event);
  }

  public function addContextEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
    dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
  }

  public function removeContextEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
    dispatcher.removeEventListener(type, listener, useCapture);
  }
}
}