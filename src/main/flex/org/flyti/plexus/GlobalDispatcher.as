package org.flyti.plexus {
import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.core.mx_internal;
import mx.managers.SystemManager;
import mx.managers.SystemManagerGlobals;

use namespace mx_internal;

internal class GlobalDispatcher implements IEventDispatcher {
  private var topLevelDispatcher:SystemManager;

  public function GlobalDispatcher() {
    topLevelDispatcher = SystemManagerGlobals.topLevelSystemManagers[0];
  }

  public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
    topLevelDispatcher.$addEventListener(type, listener, useCapture, priority, useWeakReference);
  }

  public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
    topLevelDispatcher.$removeEventListener(type, listener, useCapture);
  }

  public function dispatchEvent(event:Event):Boolean {
    return topLevelDispatcher.dispatchEvent(event);
  }

  public function hasEventListener(type:String):Boolean {
    return topLevelDispatcher.hasEventListener(type);
  }

  public function willTrigger(type:String):Boolean {
    return topLevelDispatcher.willTrigger(type);
  }
}
}