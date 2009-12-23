/*
 Copyright 2008 Nahuel Foronda/AsFusion

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. Y
 ou may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, s
 oftware distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and limitations under the License

 Author: Nahuel Foronda, Principal Architect
 nahuel at asfusion dot com

 @ignore
 */
package com.asfusion.mate.core
{
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.actionLists.Injectors;
import com.asfusion.mate.configuration.Configurable;
import com.asfusion.mate.configuration.ConfigurationManager;
import com.asfusion.mate.di;

import org.flyti.lang.Enum;
import org.flyti.plexus.ComponentCache;
import org.flyti.plexus.ComponentCachePolicy;
import org.flyti.plexus.ComponentDescriptor;
import org.flyti.plexus.ComponentDescriptorRegistry;
import org.flyti.plexus.Requirement;
import org.flyti.plexus.RoleHint;

use namespace mate;
use namespace di;

/**
 * Creator is a factory class that uses a template and an array of arguments to create objects.
 */
public class Creator
{
	/**
	 * A method that calls createInstance to create the object
	 * and logs any problem that may encounter.
	 */
	public function create(role:Class, scope:IScope, notify:Boolean = false, constructorArguments:Object = null, cachePolicy:String = "none", roleHint:Enum = null):Object
	{
		if (roleHint == null)
		{
			roleHint = RoleHint.DEFAULT;
		}

		var realArguments:Array;
		if (constructorArguments != null)
		{
			realArguments = SmartArguments.getRealArguments(scope, constructorArguments);
		}

		var component:ComponentDescriptor = ComponentDescriptorRegistry.get(role, roleHint);
		var implementation:Class = component == null ? role : component.implementation;

		var instance:Object = createInstance(implementation, realArguments);
		if (cachePolicy != ComponentCachePolicy.NONE)
		{
			if (scope == null)
			{
				MateManager.instance.cache[role] = instance;
			}
			else
			{
				if (cachePolicy == ComponentCachePolicy.INHERIT)
				{
					cachePolicy = scope.eventMap.cachePolicy;
				}

				var cache:ComponentCache = cachePolicy == ComponentCachePolicy.LOCAL ? scope.eventMap.cache : scope.manager.cache;
				cache.put(role, RoleHint.DEFAULT, instance);
			}
		}

		var globalCache:ComponentCache = MateManager.instance.cache;
		if (component != null && component.requirements != null)
		{
			// компоненты всегда создаются с кешем GLOBAL
			for each (var requirement:Requirement in component.requirements)
			{
				var requiredComponent:Object = globalCache.get(requirement.role, requirement.roleHint);
				if (requiredComponent == null)
				{
					requiredComponent = create(requirement.role, scope, true, null, ComponentCachePolicy.GLOBAL, requirement.roleHint);
				}
				instance[requirement.field] = requiredComponent;
			}
		}

		if (notify && scope != null)
		{
			Injectors.inject(instance, scope);
		}

		if (instance is Configurable)
		{
			var configurationManager:ConfigurationManager = ConfigurationManager(globalCache.get(ConfigurationManager, RoleHint.DEFAULT));
			configurationManager.configurate(Configurable(instance), role);
		}

		return instance;
	}

	public function createInstance(template:Class, p:Array):Object
	{
		if (p == null || p.length == 0)
		{
			return new template();
		}
		else
		{
			// ugly way to call a constructor.
			// if someone knows a better way please let me know (nahuel at asfusion dot com).
			switch (p.length)
			{
				case 1:	return new template(p[0]); break;
				case 2:	return new template(p[0], p[1]); break;
				case 3:	return new template(p[0], p[1], p[2]); break;
				case 4:	return new template(p[0], p[1], p[2], p[3]); break;
				case 5:	return new template(p[0], p[1], p[2], p[3], p[4]); break;
				case 6:	return new template(p[0], p[1], p[2], p[3], p[4], p[5]); break;
				case 7:	return new template(p[0], p[1], p[2], p[3], p[4], p[5], p[6]); break;
			}

			throw new ArgumentError("constructorArguments is too long");
		}
	}
}
}