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

import mx.core.EventPriority;

import org.flyti.plexus.ISmartObject;
import org.flyti.plexus.actionLists.IScope;
import org.flyti.plexus.events.InjectorEvent;

/**
 * Registers an event listener object with an EventDispatcher object so that the listener receives notification of an event.
 */
public class ListenerInjector extends AbstractAction implements IAction
{
	private var _dispatcher:Object;
	/**
	 * Event Dispatcher to which we will register to listen to events.
	 * It can be an ISmartObject or an IEventDispatcher.
	 */
	public function set dispatcher(value:Object):void
	{
		_dispatcher = value;
	}

	private var _eventType:String;
	/**
	 * The type of event that we want to register to listen to.
	 */
	public function get eventType():String
	{
		return _eventType;
	}

	public function set eventType(value:String):void
	{
		_eventType = value;
	}

	private var _method:String;
	/**
	 * The listener function that processes the event. This function must accept an Event object
	 * as its only parameter and must return nothing
	 */
	public function get method():String
	{
		return _method;
	}

	public function set method(value:String):void
	{
		_method = value;
	}

	private var _useCapture:Boolean;
	/**
	 * Determines whether the listener works in the capture phase or the target and bubbling phases.
	 * If useCapture is set to true, the listener processes the event only during the capture phase
	 * and not in the target or bubbling phase. If useCapture is false, the listener processes the
	 * event only during the target or bubbling phase.
	 */
	public function get useCapture():Boolean
	{
		return _useCapture;
	}

	public function set useCapture(value:Boolean):void
	{
		_useCapture = value;
	}

	private var _useWeakReference:Boolean;
	/**
	 * Determines whether the reference to the listener is strong or weak. A strong reference
	 * prevents your listener from being garbage-collected. A weak reference does not.
	 */
	public function get useWeakReference():Boolean
	{
		return _useWeakReference;
	}

	public function set useWeakReference(value:Boolean):void
	{
		_useWeakReference = value;
	}

	private var _priority:int = EventPriority.DEFAULT;
	/**
	 * The priority level of the event listener. The priority is designated by a signed 32-bit integer.
	 * The higher the number, the higher the priority. All listeners with priority n are processed
	 * before listeners of priority n-1. If two or more listeners share the same priority, they
	 * are processed in the order in which they were added. The default priority is 0.
	 */
	public function get priority():int
	{
		return _priority;
	}

	public function set priority(value:int):void
	{
		_priority = value;
	}

	private var _targetId:String;
	/**
	 * This tag will run if any of the following statements is true:
	 * If the targetId is null.
	 * If the id of the target matches the targetId.
	 *
	 * Note:Target is the instance of the target class.
	 * */
	public function get targetId():String
	{
		return _targetId;
	}
	public function set targetId(value:String):void
	{
		_targetId = value;
	}

	override protected function run(scope:IScope):void
	{
		var event:InjectorEvent = InjectorEvent(scope.event);

		if (eventType == null)
		{
			throw new ArgumentError("eventType must be specified");
		}

		if (targetId == null || targetId == event.uid)
		{
			var currentDispatcher:IEventDispatcher = IEventDispatcher((_dispatcher is ISmartObject) ? ISmartObject(_dispatcher).getValue(scope) : _dispatcher);
			if (currentDispatcher == null)
			{
				currentDispatcher = scope.dispatcher;
			}

			currentDispatcher.addEventListener(eventType, event.instance[method] as Function, useCapture, priority, useWeakReference);
		}
	}
}
}
