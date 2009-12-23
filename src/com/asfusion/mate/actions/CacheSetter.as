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

 Author: Collin Peters

 @ignore
 */
package com.asfusion.mate.actions
{
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.core.ISmartObject;

import org.flyti.plexus.ComponentCachePolicy;

/**
 * CacheCopier Mate tag - adds an existing instance of a class to the specified Mate cache
 *
 * <mate:CacheCopier cacheKey="{AbstractClassName}" instance="{concreteInstance}" destinationCache="whatever" />
 */
public class CacheSetter extends AbstractAction implements IAction
{
	private var _cacheKey:Class;

	/**
	 * The key to use for the cache
	 */
	public function get role():Class
	{
		return _cacheKey;
	}

	public function set role(value:Class):void
	{
		_cacheKey = value;
	}

	private var _instance:Object;
	/**
	 * The instance to set in the cache
	 */
	public function get instance():Object
	{
		return _instance;
	}

	public function set instance(value:Object):void
	{
		_instance = value;
	}

	private var _cache:String = ComponentCachePolicy.INHERIT;
	/**
	 * The cache atribute is only useful when the destination is a class.
	 * This attribute defines which cache we will look up for a created object.
	 */
	public function get cache():String
	{
		return _cache;
	}

	[Inspectable(enumeration="local,global,inherit")]
	public function set cache(value:String):void
	{
		_cache = value;
	}

	/**
	 * @inheritDoc
	 */
	override protected function prepare(scope:IScope):void
	{
		// Get the actual concrete instance
		currentInstance = instance is ISmartObject ? ISmartObject(instance).getValue(scope) : instance;

		if (currentInstance == null)
		{
			// Remove it from the cache
			currentInstance = clearCachedInstance(role, cache, scope);
		}
		else
		{
			// Add it to the cache
			putCachedInstance(currentInstance, role, cache, scope);
		}
	}

	/**
	 * @inheritDoc
	 */
	override protected function run(scope:IScope):void
	{
		scope.lastReturn = currentInstance;
	}
}
}