package org.flyti.plexus {
import flash.events.IEventDispatcher;

import org.flyti.plexus.actionLists.Injectors;

/**
 * A fundamental part of <strong>Mate</strong> is the <code>EventMap</code> tag which allows you define mappings for the events that your application creates.
 * It is basically a list of <code>IActionList</code> blocks, where each block matches an event type (if the block is an <code>EventHandlers</code>).
 *
 * @example
 *
 * <listing version="3.0">
 * &lt;EventMap
 *      xmlns:mx="http://www.adobe.com/2006/mxml"
 *      xmlns:mate="http://mate.asfusion.com/"&gt;
 *
 *      &lt;EventHandlers type="myEventType"&gt;
 *         ... here what you want to happen when this event is dispatched...
 *      &lt;/EventHandlers&gt;
 *
 * &lt;/EventMap&gt;
 * </listing>
 */
public class EventMap extends EventMapBase implements IEventMap {
  public function EventMap() {
    _container = PlexusManager.instance.container;
  }

  public function set injectors(value:Vector.<Injectors>):void {
    value.fixed = true;
    var containerInjectors:Vector.<Injectors> = _container.injectors;
    containerInjectors.fixed = false;

    var n:int = value.length;
    var oldLength:int = containerInjectors.length;
    containerInjectors.length = oldLength + n;
    for (var i:int = 0; i < n; i++) {
      if (!isInjectable(value[i].target)) {
        throw new Error(value[i].target + " is not injectable");
      }
      containerInjectors[i + oldLength] = value[i];
    }

    containerInjectors.fixed = true;
  }

  public function get dispatcher():IEventDispatcher {
    return _container.dispatcher;
  }
}
}