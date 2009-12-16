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
import com.asfusion.mate.componentMap.Component;
import com.asfusion.mate.componentMap.ComponentMap;
import com.asfusion.mate.componentMap.Requirement;
import com.asfusion.mate.configuration.Configurable;
import com.asfusion.mate.configuration.ConfigurationManager;
import com.asfusion.mate.di;

import flash.utils.Dictionary;

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
	public function create(role:Class, scope:IScope, notify:Boolean = false, constructorArguments:Object = null, cache:String = "none"):Object
	{
		var realArguments:Array;
		if (constructorArguments != null)
		{
			realArguments = SmartArguments.getRealArguments(scope, constructorArguments);
		}

		var implementation:Class;
		var component:Component;
		if (ComponentMap.has(role))
		{
			component = ComponentMap.get(role);
			implementation = component.implementation;
		}
		else
		{
			implementation = role;
		}

		var instance:Object = createInstance(implementation, realArguments);
		if (cache != Cache.NONE)
		{
			if (scope == null)
			{
				MateManager.instance.cacheCollection[role] = instance;
			}
			else
			{
				Cache.addCachedInstance(role, instance, cache, scope);
			}
		}

		if (component != null && component.requirements != null)
		{
			var cacheCollection:Dictionary = MateManager.instance.cacheCollection;
			for each (var requirement:Requirement in component.requirements)
			{
				// компоненты всегда создаются с кешем GLOBAL
				var requiredComponent:Object = cacheCollection[requirement.role];
				if (requiredComponent == null)
				{
					requiredComponent = create(requirement.role, scope, true, null, Cache.GLOBAL);
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
			var configurationManager:ConfigurationManager = ConfigurationManager(Cache.getCachedInstance(ConfigurationManager, Cache.GLOBAL, scope));
			configurationManager.configurate(Configurable(instance), role);
		}

		return instance;
	}

	/**
	 * It is the actual creation method. It can throw errors if parameters are wrong.
	 */
	public function createInstance(template:Class, p:Array):Object
	{
		var newInstance:Object;
		if (p == null || p.length == 0)
		{
			newInstance = new template();
		}
		else
		{
			// ugly way to call a constructor.
			// if someone knows a better way please let me know (nahuel at asfusion dot com).
			switch (p.length)
			{
				case 1:	newInstance = new template(p[0]); break;
				case 2:	newInstance = new template(p[0], p[1]); break;
				case 3:	newInstance = new template(p[0], p[1], p[2]); break;
				case 4:	newInstance = new template(p[0], p[1], p[2], p[3]); break;
				case 5:	newInstance = new template(p[0], p[1], p[2], p[3], p[4]); break;
				case 6:	newInstance = new template(p[0], p[1], p[2], p[3], p[4], p[5]); break;
				case 7:	newInstance = new template(p[0], p[1], p[2], p[3], p[4], p[5], p[6]); break;
				case 8:	newInstance = new template(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]); break;
				case 9:	newInstance = new template(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]); break;
				case 10:newInstance = new template(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]); break;
			}
		}
		return newInstance;
	}
}
}