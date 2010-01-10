package com.asfusion.mate.core
{
import com.asfusion.mate.events.DispatcherEvent;

import flash.events.IEventDispatcher;

import org.flyti.plexus.DefaultPlexusContainer;
import org.flyti.plexus.PlexusContainer;
import org.flyti.plexus.component.ComponentDescriptor;
import org.flyti.plexus.component.ComponentDescriptorRegistry;

public class LocalEventMap extends EventMapBase implements IEventMap
{
	private var _componentDescriptors:Vector.<ComponentDescriptor>;
	public function set components(value:Vector.<ComponentDescriptor>):void
	{
		_componentDescriptors = value;
	}

	private var _dispatcher:IEventDispatcher;
	public function get dispatcher():IEventDispatcher
	{
		return _dispatcher;
	}
	public function set dispatcher(value:IEventDispatcher):void
	{
		var oldValue:IEventDispatcher = _dispatcher;
		if (oldValue != value)
		{
			_dispatcher = value;

			var componentDescriptorRegistry:ComponentDescriptorRegistry;
			if (_componentDescriptors != null)
			{
				componentDescriptorRegistry = new ComponentDescriptorRegistry();
				componentDescriptorRegistry.add(_componentDescriptors);
				_componentDescriptors = null;
			}

			_container = new DefaultPlexusContainer(_dispatcher, componentDescriptorRegistry);
			_container.parentContainer = _parentContainer == null ? MateManager.instance.container : _parentContainer;

			var event:DispatcherEvent = new DispatcherEvent(DispatcherEvent.CHANGE);
			event.newDispatcher = value;
			event.oldDispatcher = oldValue;
			dispatchEvent(event);
		}
	}

	private var _parentContainer:PlexusContainer;
	public function set parentContainer(value:PlexusContainer):void
	{
		_parentContainer = value;
		if (container != null)
		{
			container.parentContainer = _parentContainer;
		}
	}

	private var _container:PlexusContainer;
	public function get container():PlexusContainer
	{
		return _container;
	}
}
}