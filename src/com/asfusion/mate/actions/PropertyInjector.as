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
package com.asfusion.mate.actions
{
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.core.Cache;
import com.asfusion.mate.core.ISmartObject;
import com.asfusion.mate.events.InjectorEvent;

import flash.events.IEventDispatcher;

/**
 * PropertyInjector sets a value from an object (source) to a destination (target).
 * If the source key is bindable, the PropertyInjector will bind
 * the source to the targetKey. Otherwise, it will only set the property once.
 */
public class PropertyInjector extends AbstractAction implements IAction
{
	private var _targetKey:String;
	/**
	 * The name of the property that the injector will set in the target object
	 *
	 * @default null
	 * */
	public function get targetKey():String
	{
		return _targetKey;
	}

	public function set targetKey(value:String):void
	{
		_targetKey = value;
	}

	private var _targetId:String;
	/**
	 * This tag will run if any of the following statements is true:
	 * If the targetId is null.
	 * If the id of the target matches the targetId.
	 *
	 * Note:Target is the instance of the target class.
	 *
	 * @default null
	 * */
	public function get targetId():String
	{
		return _targetId;
	}
	public function set targetId(value:String):void
	{
		_targetId = value;
	}

	private var _source:Object;
	/**
	 * An object that contains the data that the injector will use to set the target object
	 *
	 * @default null
	 * */
	public function get source():Object
	{
		return _source;
	}

	public function set source(value:Object):void
	{
		_source = value;
	}

	//.........................................sourceKey..........................................
	private var _sourceKey:String;
	/**
	 * The name of the property on the source object that the injector will use to read and set on the target object
	 *
	 * @default null
	 * */
	public function get sourceKey():String
	{
		return _sourceKey;
	}

	public function set sourceKey(value:String):void
	{
		_sourceKey = value;
	}

	private var _sourceCache:String = "inherit";
	/**
	 * If the source is a class we will try to get an instance of that class from the cache.
	 * This property defines whether the cache is local, global, or inherit.
	 *
	 * @default inherit
	 */
	public function get sourceCache():String
	{
		return _sourceCache;
	}

	[Inspectable(enumeration="local,global,inherit")]
	public function set sourceCache(value:String):void
	{
		_sourceCache = value;
	}

	private var _softBinding:Boolean = false;
	/**
	 * Flag that will be used to define the type of binding used by the PropertyInjector tag.
	 * If softBinding is true, it will use weak references in the binding. Default value is false
	 * */
	public function get softBinding():Boolean
	{
		return _softBinding;
	}
	public function set softBinding(value:Boolean):void
	{
		_softBinding = value;
	}

	/**
	 * Creates an instance of the <code>source</code> class.
	 */
	protected function createInstance(scope:IScope):Object
	{
		var clazz:Class = Class(source);
		var sourceObject:Object = Cache.getCachedInstance(clazz, sourceCache, scope);
		if (sourceObject == null)
		{
			sourceObject = scope.manager.instantiator.create(clazz, scope, true, null, sourceCache);
		}
		return sourceObject;
	}

	override protected function prepare(scope:IScope):void
	{
		if (targetId == null || targetId == InjectorEvent(scope.event).uid)
		{
			if (source is Class)
			{
				currentInstance = createInstance(scope);
			}
			else if (source is ISmartObject)
			{
				currentInstance = ISmartObject(source).getValue(scope);
			}
			else
			{
				currentInstance = source;
			}
		}
	}

	override protected function run(scope:IScope):void
	{
		var event:InjectorEvent = InjectorEvent(scope.event);
		if (targetId != null && targetId != event.uid)
		{
			return;
		}

		if (sourceKey == null)
		{
			event.instance[targetKey] = currentInstance;
		}
		else if (currentInstance is IEventDispatcher)
		{
			ChangeWatcher.watch(IEventDispatcher(currentInstance), sourceKey.split("."), event.instance, targetKey);
		}
		else
		{
			event.instance[targetKey] = currentInstance[sourceKey];
		}
	}
}
}

import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.core.EventPriority;

class ChangeWatcher
{
	private static const CHANGE_EVENT_TYPE_POSTFIX:String = "Changed";

	private var isExecuting:Boolean;

	private var source:IEventDispatcher;

	private var sourcePropertyName:String;
	private var nextWatcher:ChangeWatcher;

	private var target:Object;
	private var targetPropertyName:String;

	private var eventName:String;

	public function ChangeWatcher(sourcePropertyName:String, target:Object, targetPropertyName:String, nextWatcher:ChangeWatcher)
    {
		this.sourcePropertyName = sourcePropertyName;

		this.target = target;
        this.targetPropertyName = targetPropertyName;

        this.nextWatcher = nextWatcher;

		eventName = sourcePropertyName + CHANGE_EVENT_TYPE_POSTFIX;
    }

	public static function watch(source:IEventDispatcher, chain:Array, target:Object, targetPropertyName:String):ChangeWatcher
    {
		var nextWatcher:ChangeWatcher;
		if (chain.length > 1)
		{
			nextWatcher = watch(null, chain.slice(1), target, targetPropertyName);
		}

		var watcher:ChangeWatcher = new ChangeWatcher(chain[0], target, targetPropertyName, nextWatcher);
		if (source != null)
		{
			watcher.reset(source);
		}
		return watcher;
	}

	private function reset(newSource:IEventDispatcher):void
    {
        if (source != null)
        {
            source.removeEventListener(eventName, wrapHandler);
        }

        source = newSource;
        if (source != null)
		{
			source.addEventListener(eventName, wrapHandler, false, EventPriority.BINDING);
		}

		execute();
    }

	private function wrapHandler(event:Event):void
    {
        execute();
    }

	private function execute():void
	{
		if (!isExecuting)
        {
            try
            {
                isExecuting = true;

				var sourcePropertyValue:Object = source == null ? null : source[sourcePropertyName];
				if (nextWatcher == null)
				{
					target[targetPropertyName] = sourcePropertyValue;
				}
				else
				{
					nextWatcher.reset(IEventDispatcher(sourcePropertyValue));
				}
			}
			finally
            {
                isExecuting = false;
            }
        }
	}
}
