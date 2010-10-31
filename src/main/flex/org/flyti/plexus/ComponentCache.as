package org.flyti.plexus
{
import flash.utils.Dictionary;

import cocoa.lang.Enum;

public class ComponentCache
{
	private var cache:Dictionary = new Dictionary();

	public function put(role:Class, roleHint:Enum, instance:Object):void
	{
		var map:Dictionary = cache[roleHint];
		if (map == null)
		{
			map = new Dictionary();
			cache[roleHint] = map;
		}

		map[role] = instance;
	}

	public function get(role:Class, roleHint:Enum):Object
	{
		var map:Dictionary = cache[roleHint];
		if (map == null)
		{
			return null;
		}
		else
		{
			return map[role];
		}
	}

	public  function clear(role:Class, roleHint:Enum):Object
	{
		var map:Dictionary = cache[roleHint];
		var instance:Object = map[role];
		delete map[role];

		return instance;
	}
}
}
