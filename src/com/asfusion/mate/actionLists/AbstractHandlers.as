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
import com.asfusion.mate.actions.IAction;
import com.asfusion.mate.core.IEventMap;
import com.asfusion.mate.core.IMateManager;
import com.asfusion.mate.core.MateManager;
import com.asfusion.mate.core.mate;
import com.asfusion.mate.events.ActionListEvent;
import com.asfusion.mate.events.DispatcherEvent;
import com.asfusion.mate.utils.debug.IMateLogger;
import com.asfusion.mate.utils.debug.LogInfo;
import com.asfusion.mate.utils.debug.LogTypes;


import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.ui.Keyboard;

import mx.core.IMXMLObject;

use namespace mate;

[DefaultProperty("actions")]
[Exclude(name="activate", kind="event")]
[Exclude(name="deactivate", kind="event")]

/**
 *  This event is dispatched right before the list of IActions are called,
 *  when the IActionList starts execution.
 *
 *  @eventType com.asfusion.mate.events.ActionListEvent.START
 */
[Event(name="start", type="com.asfusion.mate.events.ActionListEvent")]


/**
 *  This event is dispatched right after all the IActions have been called,
 *  when the IActionList ends execution (although this event might be dispatched before asynchronous calls have returned).
 *
 *  @eventType com.asfusion.mate.events.ActionListEvent.END
 */
[Event(name="end", type="com.asfusion.mate.events.ActionListEvent")]

/**
 * AbstractHandlers is a base class for all the IActionList implementations.
 */
public class AbstractHandlers extends EventDispatcher implements IMXMLObject, IActionList
{
	/**
	 * Internal instance of <code>IMateManager</code>.
	 */
	protected var manager:IMateManager;

	/**
	 * Internal instance of <code>IEventMap</code>.
	 */
	protected var map:IEventMap;

	/**
	 * Parent scope that is passed to the IActionList when it is a sub-ActionList.
	 */
	protected var inheritedScope:IScope;

	/**
	 * Flag indicating whether the <code>dispatcherType</code> has been changed and needs invalidation.
	 */
	protected var dispatcherTypeChanged:Boolean;

	private var _actions:Vector.<IAction>;
	public function get actions():Vector.<IAction>
	{
		return _actions;
	}
	public function set actions(value:Vector.<IAction>):void
	{
		_actions = value;
	}

	private var _scope:IScope;
	[Bindable(event="scopeChange")]
	public function get scope():IScope
	{
		return _scope;
	}

	private var _debug:Boolean;
	public function get debug():Boolean
	{
		return Keyboard.capsLock ? true : _debug;
	}

	public function set debug(value:Boolean):void
	{
		_debug = value;
	}

	private var _dispatcherType:String = "inherit";
	/**
	 * String that defines whether the dispatcher used by this tag is <code>global</code> or
	 * <code>inherit</code>. If it is <code>inherit</code>, the dispatcher used is the
	 * dispatcher provided by the EventMap where this tag lives.
	 */
	public function get dispatcherType():String
	{
		return _dispatcherType;
	}

	[Inspectable(enumeration="inherit,global")]
	public function set dispatcherType(value:String):void
	{
		var oldValue:String = _dispatcherType;
		if (oldValue != value)
		{
			if (oldValue == "global")
			{
				manager.removeEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
			}
			else if (oldValue == "inherit" && map)
			{
//				map.removeEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
			}
			if (value == "global")
			{
				manager.addEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
			}
			else if (value == "inherit" && map)
			{
//				map.addEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
			}
			_dispatcherType = value;
			dispatcherTypeChanged = true;
			validateNow();
		}
	}

	protected var currentDispatcher:IEventDispatcher;
	private var _dispatcher:IEventDispatcher;
	/**
	 *	 The IActionList registers itself as an event listener of the dispatcher specified in this property.
	 *  By the default, this dispatcher is the Application. dispatcher property only available when using mate namespace
	 *
	 *  @default Application.application
	 *
	 */
	mate function get dispatcher():IEventDispatcher
	{
		if (_dispatcher)
		{
			currentDispatcher = _dispatcher;
		}
		else
		{
			if (dispatcherType == "global")
			{
				currentDispatcher = manager.dispatcher;
			}
			else if (dispatcherType == "inherit" && map)
			{
				currentDispatcher = map.dispatcher;
			}
		}
		return currentDispatcher;
	}

	mate function set dispatcher(value:IEventDispatcher):void
	{
		if (_dispatcher !== value)
		{
			currentDispatcher = _dispatcher = value;
			dispatcherType = "local";
		}
	}

	public function AbstractHandlers()
	{
		manager = MateManager.instance;
	}

	public function setDispatcher(value:IEventDispatcher, local:Boolean = true):void
	{
		if (local)
		{
			dispatcher = value;
		}
		else if (!_dispatcher)
		{
			currentDispatcher = value;
		}
		validateNow();
	}

	private var needsInvalidation:Boolean;

	/**
	 *  @inheritDoc
	 */
	public function invalidateProperties():void
	{
		if (!isInitialized) needsInvalidation = true;
		else commitProperties();
	}

	/**
	 * @inheritDoc
	 */
	public function setInheritedScope(inheritedScope:IScope):void
	{
		this.inheritedScope = inheritedScope;
	}

	/**
	 * @inheritDoc
	 */
	public function validateNow():void
	{
		commitProperties();
	}

	/*-.........................................errorString..........................................*/
	/**
	 * @inheritDoc
	 */
	public function errorString():String
	{
		return "Error was found in a AbstractHandlers in file " + document;
	}

	/**
	 * Internal storage for a group id.
	 */
	private var _groupId:int = -1;

	/*-.........................................setGroupIndex..........................................*/
	/**
	 *  @inheritDoc
	 */
	public function setGroupId(id:int):void
	{
		_groupId = id;
	}

	public function clearReferences():void
	{
		// this method is abstract it will be implemented by children
	}

	public function getGroupId():int
	{
		return _groupId;
	}

	/**
	 * Goes over all the listeners (<code>IAction</code>s)
	 * and calls the method <code>trigger</code> on them, passing the scope as an argument.
	 * It also dispatches the <code>start</code> and <code>end</code> sequence events.
	 */
	protected function runSequence(scope:IScope, actionList:Vector.<IAction>):void
	{
		var logger:IMateLogger = scope.getLogger();
		var loggerActive:Boolean = logger.active;
		if (loggerActive)
		{
			logger.info(LogTypes.SEQUENCE_START, new LogInfo(scope));
		}
		dispatchEvent(new ActionListEvent(ActionListEvent.START, scope.event));

		for each(var action:IAction in actionList)
		{
			if (scope.isRunning())
			{
				scope.currentTarget = action;
				if (loggerActive)
				{
					logger.info(LogTypes.SEQUENCE_TRIGGER, new LogInfo(scope));
				}
				action.trigger(scope);
			}
		}

		dispatchEvent(new ActionListEvent(ActionListEvent.END));
		if (loggerActive)
		{
			logger.debug(LogTypes.SEQUENCE_END, new LogInfo(scope));
		}
		_scope = null;
	}

	/*-.........................................commitProperties..........................................*/
	/**
	 * Processes the properties set on the component.
	 */
	protected function commitProperties():void
	{
		// this method is abstract it will be implemented by children
	}

	/**
	 * Set the scope on this IActionList.
	 */
	protected function setScope(scope:IScope):void
	{
		_scope = scope;
		dispatchEvent(new ActionListEvent(ActionListEvent.SCOPE_CHANGE));
	}

	/**
	 * A handler for the mate dispatcher changed.
	 * This method is called by <code>IMateManager</code> when the dispatcher changes.
	 */
	protected function dispatcherChangeHandler(event:DispatcherEvent):void
	{
		setDispatcher(event.newDispatcher, false);
	}

	protected var document:Object;

	public function getDocument():Object
	{
		return document;
	}

	private var isInitialized:Boolean;

	/**
	 * Called automatically by the MXML compiler if the IActionList is set up using a tag.
	 */
	public function initialized(document:Object, id:String):void
	{
		this.document = document;

		if (document is IEventMap)
		{
			map = IEventMap(document);
		}

		if (dispatcherType == "inherit" && map)
		{
			var inheritDispatcher:IEventDispatcher = map.dispatcher;

//			map.addEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
			if (inheritDispatcher)
			{
				setDispatcher(inheritDispatcher, false);
			}
		}
		else if (dispatcherType == "global")
		{
			setDispatcher(manager.dispatcher, false);
		}

		if (needsInvalidation)
		{
			commitProperties();
			needsInvalidation = false;
		}

		isInitialized = true;
	}
}
}