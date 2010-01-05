package org.flyti.plexus
{
import com.asfusion.mate.actionLists.Injectors;
import com.asfusion.mate.events.InjectorEvent;

import flash.events.IEventDispatcher;

import org.flyti.lang.Enum;
import org.flyti.plexus.component.ComponentDescriptor;
import org.flyti.plexus.component.ComponentDescriptorRegistry;
import org.flyti.plexus.component.ComponentRequirement;
import org.flyti.plexus.component.InstantiationStrategy;
import org.flyti.plexus.component.RoleHint;
import org.flyti.plexus.configuration.Configurable;
import org.flyti.plexus.configuration.ConfigurationManager;

use namespace plexus;

/**
 * Компонент кешируется там, где его дескриптор (http://juick.com/develar/450898)
 * Так как на данный момент для компонента может отсутствовать дескриптор (он тупо как роль в EventMap),
 * то если мы не нашли дескриптор для него ни у себя, ни в родительских контейнерах — кешируем его у себя
 */
public class DefaultPlexusContainer implements PlexusContainer
{
	private var _parentContainer:PlexusContainer;
	public function get parentContainer():PlexusContainer
	{
		return _parentContainer;
	}

	private var componentDescriptorRegistry:ComponentDescriptorRegistry;

	private var cache:ComponentCache = new ComponentCache();

	public function DefaultPlexusContainer(dispatcher:IEventDispatcher, parentContainer:PlexusContainer = null, componentDescriptorRegistry:ComponentDescriptorRegistry = null)
	{
		_dispatcher = dispatcher;
		_dispatcher.addEventListener(InjectorEvent.INJECT, injectHandler);
		
		this._parentContainer = parentContainer;
		this.componentDescriptorRegistry = componentDescriptorRegistry;
	}

	private function injectHandler(event:InjectorEvent):void
	{
		checkInjectors(event);
	}

	private var _dispatcher:IEventDispatcher;
	public function get dispatcher():IEventDispatcher
	{
		return _dispatcher;
	}

	private var _injectors:Vector.<Injectors> = new Vector.<Injectors>();
	public function get injectors():Vector.<Injectors>
	{
		return _injectors;
	}

	public function getComponentDescriptor(role:Class, roleHint:Enum):ComponentDescriptor
	{
		return componentDescriptorRegistry == null ? null : componentDescriptorRegistry.get(role, roleHint);
	}

	public function lookup(role:Class, roleHint:Enum = null, constructorArguments:Array = null):Object
	{
		if (roleHint == null)
		{
			roleHint = RoleHint.DEFAULT;
		}

		var componentDescriptor:ComponentDescriptor = getComponentDescriptor(role, roleHint);
		if (componentDescriptor == null)
		{
			var currentContainer:PlexusContainer = _parentContainer;
			while (currentContainer != null)
			{
				componentDescriptor = currentContainer.getComponentDescriptor(role, roleHint);
				if (componentDescriptor != null)
				{
					return currentContainer.lookup(role, roleHint);
				}
				else
				{
					currentContainer = currentContainer.parentContainer;
				}
			}
		}

		var instance:Object = cache.get(role, roleHint);
		if (instance != null)
		{
			return instance;
		}

		var implementation:Class = componentDescriptor == null ? role : componentDescriptor.implementation;

		instance = createInstance(implementation, constructorArguments);
		var perLookup:Boolean = componentDescriptor != null && componentDescriptor.instantiationStrategy == InstantiationStrategy.PER_LOOKUP;
		if (!perLookup)
		{
			cache.put(role, roleHint, instance);
		}

		if (instance is PlexusContainerRecipient)
		{
			PlexusContainerRecipient(instance).container = this;
		}

		if (componentDescriptor != null && componentDescriptor.requirements != null)
		{
			for each (var requirement:ComponentRequirement in componentDescriptor.requirements)
			{
				var requiredComponent:Object = cache.get(requirement.role, requirement.roleHint);
				if (requiredComponent == null)
				{
					requiredComponent = lookup(requirement.role, requirement.roleHint);
				}
				instance[requirement.field] = requiredComponent;
			}
		}

		if (!perLookup)
		{
			var injectorEvent:InjectorEvent = new InjectorEvent(instance);
			checkInjectors(injectorEvent);
		}

		if (instance is Configurable)
		{
			var globalContainer:PlexusContainer = _parentContainer == null ? this : _parentContainer;
			var configurationManager:ConfigurationManager = ConfigurationManager(globalContainer.lookup(ConfigurationManager));
			configurationManager.configurate(Configurable(instance), role);
		}

		return instance;
	}

	public function checkInjectors(injectorEvent:InjectorEvent):void
	{
		for each (var injector:Injectors in injectors)
		{
			if ((injector.targetId == null || injectorEvent.uid == injector.targetId) && injectorEvent.instance is injector.target)
			{
				injector.fire(injectorEvent);
			}
		}

		/* концепция такова, что каждый контейнер слушает некий объект в display list, и получает InjectorEvent посредством баблинга
		 должен ли контейнер, первым поймавший InjectorEvent событие, полагаться на этот механизм, или же удобнее если дальше событие идет по его иерархии?
		 нам на данный момент удобно второе — первый контейнер поймавший InjectorEvent, останавливает событие и обрабатывает по своей иерархии
		 (к тому же у нас два, еще не разделенных типа injector target — компонент (может быть вне display list)) и display object. */
		injectorEvent.stopImmediatePropagation();
		if (_parentContainer != null)
		{
			_parentContainer.checkInjectors(injectorEvent);
		}
	}

	private function createInstance(template:Class, p:Array):Object
	{
		if (p == null || p.length == 0)
		{
			return new template();
		}
		else
		{
			switch (p.length)
			{
				case 1:	return new template(p[0]);
				case 2:	return new template(p[0], p[1]);
				case 3:	return new template(p[0], p[1], p[2]);
				case 4:	return new template(p[0], p[1], p[2], p[3]);
				case 5:	return new template(p[0], p[1], p[2], p[3], p[4]);
			}

			throw new ArgumentError("constructorArguments is too long");
		}
	}
}
}