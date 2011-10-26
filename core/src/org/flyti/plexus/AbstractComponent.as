package org.flyti.plexus {
import flash.events.Event;

import mx.utils.OnDemandEventDispatcher;

public class AbstractComponent extends OnDemandEventDispatcher implements PlexusContainerRecipient {
  protected var _container:PlexusContainer;
  public final function set container(value:PlexusContainer):void {
    _container = value;
  }

  protected function dispatchContextEvent(event:Event):void {
    _container.dispatcher.dispatchEvent(event);
  }
}
}