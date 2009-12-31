package org.flyti.plexus
{
import com.asfusion.mate.actionLists.Injectors;
import com.asfusion.mate.configuration.Configurable;
import com.asfusion.mate.configuration.ConfigurationManager;
import com.asfusion.mate.events.InjectorEvent;

import flash.events.IEventDispatcher;

import org.flyti.lang.Enum;
import org.flyti.plexus.component.ComponentDescriptor;
import org.flyti.plexus.component.ComponentDescriptorSet;
import org.flyti.plexus.component.ComponentRequirement;
import org.flyti.plexus.component.InstantiationStrategy;
import org.flyti.plexus.component.RoleHint;

use namespace plexus;

/**
 * Компонент кешируется там, где его дескриптор (http://juick.com/develar/450898)
 * Но так как пока что дескриптор всегда на глобальном, мы и кешируем их только на глобальном уровне
 */
public class DefaultPlexusContainer implements PlexusContainer
{
	private var parentContainer:PlexusContainer;

	private var cache:ComponentCache = new ComponentCache();

	public function DefaultPlexusContainer(dispatcher:IEventDispatcher, parentContainer:PlexusContainer = null)
	{
		_dispatcher = dispatcher;
		_dispatcher.addEventListener(InjectorEvent.INJECT, injectHandler);
		
		this.parentContainer = parentContainer;
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

	public function lookup(role:Class, roleHint:Enum = null, constructorArguments:Array = null):Object
	{
		if (roleHint == null)
		{
			roleHint = RoleHint.DEFAULT;
		}

		var globalContainer:PlexusContainer = parentContainer == null ? this : parentContainer;

		var componentDescriptor:ComponentDescriptor = ComponentDescriptorSet.get(role, roleHint);
		
		var instance:Object = componentDescriptor == null || globalContainer == this ? cache.get(role, roleHint) : globalContainer.lookup(role, roleHint);
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

		if (componentDescriptor != null && componentDescriptor.requirements != null)
		{
			// компоненты на данный момент всегда создаются с кешем GLOBAL
			for each (var requirement:ComponentRequirement in componentDescriptor.requirements)
			{
				var requiredComponent:Object = cache.get(requirement.role, requirement.roleHint);
				if (requiredComponent == null)
				{
					requiredComponent = globalContainer.lookup(requirement.role, requirement.roleHint);
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
		
		if (parentContainer)
		{
			parentContainer.checkInjectors(injectorEvent);
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
				case 1:	return new template(p[0]); break;
				case 2:	return new template(p[0], p[1]); break;
				case 3:	return new template(p[0], p[1], p[2]); break;
				case 4:	return new template(p[0], p[1], p[2], p[3]); break;
				case 5:	return new template(p[0], p[1], p[2], p[3], p[4]); break;
			}

			throw new ArgumentError("constructorArguments is too long");
		}
	}
}
}