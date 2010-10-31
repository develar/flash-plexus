package org.flyti.plexus
{
import flash.errors.IllegalOperationError;
import flash.events.IEventDispatcher;

import cocoa.lang.Enum;
import org.flyti.plexus.actionLists.Injectors;
import org.flyti.plexus.component.ComponentDescriptor;
import org.flyti.plexus.component.ComponentDescriptorRegistry;
import org.flyti.plexus.events.DispatcherEvent;
import org.flyti.plexus.events.InjectorEvent;

public class LocalEventMap extends EventMapBase implements IEventMap
{
	private var _componentDescriptors:Vector.<ComponentDescriptor>;
	public function set components(value:Vector.<ComponentDescriptor>):void
	{
		_componentDescriptors = value;
		_componentDescriptors.fixed = true;
	}

	protected var _injectors:Vector.<Injectors>;
	public function set injectors(value:Vector.<Injectors>):void
	{
		_injectors = value;
		_injectors.fixed = true;

		for each (var injector:Injectors in _injectors)
		{
			if (!isInjectable(injector.target))
			{
				throw new Error(injector.target + " is not injectable");
			}
		}
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

			if (_container == null)
			{
				initializeContainer();
			}
			else
			{
				_container.dispatcher = _dispatcher;
			}

			var event:DispatcherEvent = new DispatcherEvent(DispatcherEvent.CHANGE);
			event.newDispatcher = value;
			event.oldDispatcher = oldValue;
			dispatchEvent(event);
		}
	}

	private function initializeContainer():void
	{
		var componentDescriptorRegistry:ComponentDescriptorRegistry;
		if (_componentDescriptors != null)
		{
			componentDescriptorRegistry = new ComponentDescriptorRegistry();
			componentDescriptorRegistry.add(_componentDescriptors);
			_componentDescriptors = null;
		}

		_container = new DefaultPlexusContainer(_dispatcher, componentDescriptorRegistry, _injectors);
		_container.parentContainer = _parentContainer == null ? PlexusManager.instance.container : _parentContainer;
	}

	/**
	 * @see PlexusContainer#composeComponent
	 */
	public function composeOwnerUIComponent(instance:Object, role:Class = null, roleHint:Enum = null):void
	{
		if (_dispatcher != null)
		{
			throw new IllegalOperationError("dispatcher already set and container is initialized");
		}

		initializeContainer();
		container.composeComponent(instance, role, roleHint);
		container.checkInjectors(new InjectorEvent(instance));
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
}
}