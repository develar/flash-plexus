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
package org.flyti.plexus.actions
{
import flash.events.IEventDispatcher;

import org.flyti.plexus.ISmartObject;
import org.flyti.plexus.Uninjectable;
import org.flyti.plexus.actionLists.IScope;
import org.flyti.plexus.events.InjectorEvent;

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
	 */
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
	 */
	public function set targetId(value:String):void
	{
		_targetId = value;
	}

	private var _source:Object;
	/**
	 * An object that contains the data that the injector will use to set the target object
	 * */
	public function set source(value:Object):void
	{
		_source = value;
	}
	
	private var _sourceKey:String;
	/**
	 * The name of the property on the source object that the injector will use to read and set on the target object
	 */
	public function set sourceKey(value:String):void
	{
		_sourceKey = value;
	}

	private var _changeEventType:String;
	public function set changeEventType(value:String):void
	{
		_changeEventType = value;
	}

	override protected function prepare(scope:IScope):void
	{
		if (_targetId == null || _targetId == InjectorEvent(scope.event).uid)
		{
			if (_source is Class)
			{
				currentInstance = scope.eventMap.container.lookup(Class(_source));
			}
			else if (_source is ISmartObject)
			{
				currentInstance = ISmartObject(_source).getValue(scope);
			}
			else
			{
				currentInstance = _source;
			}
		}
	}

	override protected function run(scope:IScope):void
	{
		var event:InjectorEvent = InjectorEvent(scope.event);
		if (_targetId != null && _targetId != event.uid)
		{
			return;
		}

		if (_sourceKey == null)
		{
			event.instance[_targetKey] = currentInstance;
		}
		else if (currentInstance is IEventDispatcher)
		{
			var watcher:ChangeWatcher = ChangeWatcher.watch(IEventDispatcher(currentInstance), _sourceKey.split("."), event.instance, _targetKey, _changeEventType);
			if (event.instance is Uninjectable)
			{
				Uninjectable(event.instance).addWatcher(watcher);
			}
		}
		else
		{
			event.instance[_targetKey] = currentInstance[_sourceKey];
		}
	}
}
}