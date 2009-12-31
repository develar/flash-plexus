package com.asfusion.mate.core
{
import flash.events.IEventDispatcher;

import org.flyti.plexus.PlexusContainer;

[Exclude(name="activate", kind="event")]
[Exclude(name="deactivate", kind="event")]

/**
 * A fundamental part of <strong>Mate</strong> is the <code>EventMap</code> tag which allows you define mappings for the events that your application creates.
 * It is basically a list of <code>IActionList</code> blocks, where each block matches an event type (if the block is an <code>EventHandlers</code>).
 *
 * @example
 *
 * <listing version="3.0">
 * &lt;EventMap
 *		  xmlns:mx="http://www.adobe.com/2006/mxml"
 *		  xmlns:mate="http://mate.asfusion.com/"&gt;
 *
 *		  &lt;EventHandlers type="myEventType"&gt;
 *			   ... here what you want to happen when this event is dispatched...
 *		  &lt;/EventHandlers&gt;
 *
 * &lt;/EventMap&gt;
 * </listing>
 */
public class EventMap extends EventMapBase implements IEventMap
{
	public function EventMap()
	{
		_container = MateManager.instance.container;
	}

	public function get dispatcher():IEventDispatcher
	{
		return _container.dispatcher;
	}

	private var _container:PlexusContainer;
	public function get container():PlexusContainer
	{
		return _container;
	}
}
}