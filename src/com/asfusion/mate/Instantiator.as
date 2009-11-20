package com.asfusion.mate
{
import com.asfusion.mate.componentMap.Component;
import com.asfusion.mate.componentMap.ComponentMap;
import com.asfusion.mate.core.Cache;

import flash.utils.Dictionary;

public class Instantiator
{
	private var instanceCache:Dictionary;

	public function Instantiator(cacheCollection:Dictionary)
	{
	}

	public function lookup(role:Class):void
	{
		if (role in instanceCache)
		{
			return instanceCache[role];
		}
		else
		{
			instantiate(role);
		}
	}

	public function instantiate(role:Class, cache:String):Object
	{
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

		var instance:Object = new implementation();

		if (cache != Cache.NONE)
		{
			instanceCache[role] = instance;
		}

		return instance;
	}
}
}