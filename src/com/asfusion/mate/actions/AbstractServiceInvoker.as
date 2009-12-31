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
import com.asfusion.mate.actionLists.EventHandlers;
import com.asfusion.mate.actionLists.IActionList;
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.events.ActionListEvent;

import flash.events.IEventDispatcher;
import flash.ui.Keyboard;

/**
 * AbstractServiceInvoker is the base class for all the <code>IAction</code> that have inner-handlers/actions.
 *
 * <p>This class has 2 inner-handlers <code>resultHandlers</code> and <code>faultHandlers</code>, but
 * it provides the ability to have more by creating new inner-handlers with the method <code>createInnerHandlers</code>.</p>
 */
public class AbstractServiceInvoker extends BaseAction
{
	/**
	 * Dispatcher that will trigger the inner-handlers execution by
	 * dispatching events (ie: ResultEvent or FaultEvent).
	 */
	protected var innerHandlersDispatcher:IEventDispatcher;

	/**
	 * Class that is used as a template to create the inner-handlers
	 */
	protected var innerHandlersClass:Class = EventHandlers;

	/**
	 * Index used to store groups of inner handlers.
	 */
	protected var currentIndex:int = 0;

	/**
	 * When auto unregistration is true, all inner handlers will be
	 * unregistered after the first inner handlers fires.
	 */
	protected var autoUnregistration:Boolean = true;

	/**
	 * Inner handlers list that stores all inner handlers indexed by the currentIndex.
	 */
	protected var innerHandlersList:Vector.<Vector.<IActionList>> = new Vector.<Vector.<IActionList>>();

	private var _resultHandlers:Vector.<IAction>;
	/**
	 * A set of inner-handlers to run when the server call returns a <em>result</em>. Inside this inner-handlers,
	 * you can use the same tags you would in the main body of a <code>IActionList</code>,
	 * including other service calls.
	 */
	public function get resultHandlers():Vector.<IAction>
	{
		return _resultHandlers;
	}
	public function set resultHandlers(value:Vector.<IAction>):void
	{
		_resultHandlers = value;
		_resultHandlers.fixed = true;
	}

	private var _faultHandlers:Vector.<IAction>;
	/**
	 * A set of inner-handlers to run when the server call returns a <em>fault</em>. Inside this inner-handlers,
	 * you can use the same tags you would in the main body of a <code>IActionList</code>,
	 * including other service calls.
	 */
	public function get faultHandlers():Vector.<IAction>
	{
		return _faultHandlers;
	}
	public function set faultHandlers(value:Vector.<IAction>):void
	{
		_faultHandlers = value;
		_faultHandlers.fixed = true;
	}

	private var _debug:Boolean;
	/**
	 * Whether to show debugging information for its <em>inner-handlers</em>s. If true,
	 * console output will show debugging information for all <em>inner-handlers</em>
	 * (resultHandlers and faultHandlers)
	 */
	public function get debug():Boolean
	{
		return Keyboard.capsLock ? true : _debug;
	}
	public function set debug(value:Boolean):void
	{
		_debug = value;
	}

	override protected function prepare(scope:IScope):void
	{
		currentIndex++;
	}

	/**
	 * Creates IActionList and sets the properties:
	 * debug, type, listeners, dispatcher and inheritScope in the newly IActionList (inner-handlers).
	 */
	protected function createInnerHandlers(scope:IScope, innerType:String, actionList:Vector.<IAction>, innerHandlersClass:Class = null):IActionList
	{
		var innerHandlers:IActionList = innerHandlersClass != null ? new innerHandlersClass() : new this.innerHandlersClass();
		innerHandlers.setInheritedScope(scope);
		innerHandlers.setDispatcher(innerHandlersDispatcher);
		if (actionList != null)
		{
			innerHandlers.actions = actionList;
		}
		innerHandlers.initialized(document, null);

		if (innerHandlers is EventHandlers)
		{
			EventHandlers(innerHandlers).type = innerType;
		}

		if (autoUnregistration)
		{
			var siblings:Vector.<IActionList>;
			if (currentIndex < innerHandlersList.length)
			{
				siblings = innerHandlersList[currentIndex];
				if (siblings == null)
				{
					siblings = new Vector.<IActionList>();
					innerHandlersList[currentIndex] = siblings;
				}
			}
			else
			{
				siblings = new Vector.<IActionList>();
				innerHandlersList.push(siblings);
			}

			innerHandlers.setGroupId(currentIndex);
			innerHandlers.addEventListener(ActionListEvent.START, actionListStartHandler);
			siblings.push(innerHandlers);
		}
		innerHandlers.debug = debug;
		return innerHandlers;
	}

	/**
	 * Handler that will be fired when the first of the innerHandlers starts executing.
	 */
	private function actionListStartHandler(event:ActionListEvent):void
	{
		if (event.target is IActionList)
		{
			var innerHandlers:IActionList = IActionList(event.target);
			var siblings:Vector.<IActionList> = innerHandlersList[innerHandlers.getGroupId()];
			for each (var handlers:IActionList in siblings)
			{
				handlers.removeEventListener(ActionListEvent.START, actionListStartHandler);
				handlers.clearReferences();
			}
			innerHandlersList[innerHandlers.getGroupId()] = null;
		}
	}
}
}