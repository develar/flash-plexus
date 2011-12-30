package org.flyti.plexus.actions {
import flash.events.Event;
import flash.events.IEventDispatcher;

public class ChangeWatcher {
  private static const CHANGE_EVENT_TYPE_POSTFIX:String = "Changed";

  private var source:IEventDispatcher;

  private var sourcePropertyName:String;
  private var nextWatcher:ChangeWatcher;

  private var target:Object;
  private var targetPropertyName:String;

  private var eventName:String;
  private var nullValue:Object;

  public function ChangeWatcher(sourcePropertyName:String, target:Object, targetPropertyName:String, nextWatcher:ChangeWatcher, nullValue:Object) {
    this.sourcePropertyName = sourcePropertyName;

    this.target = target;
    this.targetPropertyName = targetPropertyName;

    this.nextWatcher = nextWatcher;
    this.nullValue = nullValue;

    eventName = sourcePropertyName + CHANGE_EVENT_TYPE_POSTFIX;
  }

  public static function watch(source:IEventDispatcher, chain:Array, target:Object, targetPropertyName:String, changeEventType:String = null, nullValue:Object = null):ChangeWatcher {
    var nextWatcher:ChangeWatcher;
    if (chain.length > 1) {
      assert(changeEventType == null);
      nextWatcher = watch(null, chain.slice(1), target, targetPropertyName, null, nullValue);
    }

    var watcher:ChangeWatcher = new ChangeWatcher(chain[0], target, targetPropertyName, nextWatcher, nullValue);
    if (changeEventType != null) {
      watcher.eventName = changeEventType;
    }
    if (source != null) {
      watcher.reset(source);
    }
    return watcher;
  }

  public function unwatch():void {
    source.removeEventListener(eventName, wrapHandler);
    source = null;
    target = null;

    if (nextWatcher != null) {
      nextWatcher.unwatch();
    }
  }

  private function reset(newSource:IEventDispatcher):void {
    if (source != null) {
      source.removeEventListener(eventName, wrapHandler);
    }

    source = newSource;
    if (source != null) {
      source.addEventListener(eventName, wrapHandler, false, 100);
    }

    execute();
  }

  private function wrapHandler(event:Event):void {
    execute();
  }
  
  private function resetNotBindable(newSource:Object):void {
    target[targetPropertyName] = newSource[sourcePropertyName];
  }

  private function execute():void {
    var isExecuting:Boolean;
    if (!isExecuting) {
      //            try
      //            {
      //                isExecuting = true;

      var sourcePropertyValue:Object = source == null ? nullValue : source[sourcePropertyName];
      if (nextWatcher == null) {
        target[targetPropertyName] = sourcePropertyValue;
      }
      else if (sourcePropertyValue is IEventDispatcher || sourcePropertyValue == null) {
        nextWatcher.reset(IEventDispatcher(sourcePropertyValue));
      }
      else {
        nextWatcher.resetNotBindable(sourcePropertyValue);
      }
      //			}
      //			finally
      //            {
      //                isExecuting = false;
      //            }
    }
  }
}
}