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
package com.asfusion.mate.actionLists
{
import com.asfusion.mate.core.IEventMap;
import com.asfusion.mate.core.MateManager;
import com.asfusion.mate.utils.debug.IMateLogger;

import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * Scope is an object created by the <code>IActionList</code>.
 * <p>It represents the running scope of a <code>IActionList</code>.
 * The <code>IActionList</code> and its actions share this object to transfer data
 * between them.</p>
 */
public class Scope implements IScope
{
	/**
	 * Current Event, different from the original event when
	 * a sub-action-list is running.
	 */
	public var currentEvent:Event;

	/**
	 * Flag that indicates whether <code>IActionList</code> is running or not.
	 */
	public var running:Boolean = true;

	/**
	 * An <code>IMateLogger</code> used to log errors.
	 * Similar to Flex <code>ILogger</code>
	 */
	private var logger:IMateLogger;

	private var _data:Object;
	/**
	 * @inheritDoc
	 */
	public function get data():Object
	{
		return _data;
	}

	public function set data(value:Object):void
	{
		_data = value;
	}

	private var _owner:IActionList;
	public function get owner():IActionList
	{
		return _owner;
	}

	public function set owner(value:IActionList):void
	{
		_owner = value;
	}

	private var _event:Event;
	public function get event():Event
	{
		return _event;
	}

	public function set event(value:Event):void
	{
		_event = value;
	}

	private var _lastReturn:Object;
	public function get lastReturn():Object
	{
		return _lastReturn;
	}
	public function set lastReturn(value:Object):void
	{
		_lastReturn = value;
	}

	private var _dispatcher:IEventDispatcher;
	public function get dispatcher():IEventDispatcher
	{
		return _dispatcher;
	}
	public function set dispatcher(value:IEventDispatcher):void
	{
		_dispatcher = value;
	}

	private var _currentTarget:Object;
	public function get currentTarget():Object
	{
		return _currentTarget;
	}

	public function set currentTarget(value:Object):void
	{
		_currentTarget = value;
	}

	private var _eventMap:IEventMap;
	public function get eventMap():IEventMap
	{
		return _eventMap;
	}

	public function set eventMap(value:IEventMap):void
	{
		_eventMap = value;
	}

	public function Scope(event:Event, active:Boolean, map:IEventMap, inheritScope:IScope = null)
	{
		if (inheritScope)
		{
			lastReturn = inheritScope.lastReturn;
			data = inheritScope.data;
			this.event = inheritScope.event;
			currentEvent = event;
		}
		else
		{
			this.event = event;
			currentEvent = event;
			data = new Object();
		}
		eventMap = map;
		logger = MateManager.instance.getLogger(active);
		dispatcher = map.dispatcher;
	}

	public function getDocument():Object
	{
		return owner.getDocument();
	}

	public function errorString():String
	{
		return owner.errorString();
	}

	public function getCurrentTarget():Object
	{
		return currentTarget;
	}

	public function getLogger():IMateLogger
	{
		return logger;
	}

	public function stopRunning():void
	{
		running = false;
	}

	public function isRunning():Boolean
	{
		return running;
	}
}
}