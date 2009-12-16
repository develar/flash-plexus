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
import com.asfusion.mate.core.mate;
import com.asfusion.mate.events.DispatcherEvent;
import com.asfusion.mate.utils.debug.DebuggerUtil;

import flash.events.Event;
import flash.events.IEventDispatcher;

use namespace mate;

/**
 * A <code>EventHandlers</code> defined in the <code>EventMap</code> will run whenever an event of the type specified in the <code>EventHandlers</code>'s "type" argument is dispatched.
 * Note that in order for the <code>EventMap</code> to be able to listen for the given event,
 * this event must have its bubbling setting as true and be dispatched from an object that has Application as its root ancestor,
 * or the event must be dispatched by a Mate Dispatcher (such is the case when dispatching events from a PopUp window).
 *
 * @example
 *
 * <listing version="3.0">
 *  &lt;EventHandlers type="myEventType"&gt;
 *	   ... here what you want to happen when this event is dispatched...
 *  &lt;/EventHandlers&gt;
 *  </listing>
 */
public class EventHandlers extends AbstractHandlers
{
	private var documentId:String;

	public var oneTime:Boolean;

	/**
	 * Flag indicating if this <code>EventHandlers</code> tag is registered to listen to an event or not.
	 */
	protected var registered:Boolean;

	/*-.........................................type..........................................*/
	private var _type:String;
	/**
	 * The event type that, when dispatched, should trigger the handlers to run.
	 * It should match the type specified in the event when created.
	 * All events extending from flash.events.Event have a "type" property.
	 * The type is case-sensitive.
	 *
	 *  @default null
	 * */
	public function get type():String
	{
		return _type;
	}

	public function set type(value:String):void
	{
		var oldValue:String = _type;
		if (oldValue !== value)
		{
			_type = value;
			if (oldValue)
			{
				unregister(oldValue, dispatcher, useCapture);
			}
			validateNow();
		}
	}


	/*-.........................................priority..........................................*/
	private var _priority:int = 0;
	/**
	 * (default = 0) — The priority level of the <code>EventHandlers</code>.
	 * The higher the number, the higher the priority. All <code>EventHandlers</code> with priority n are
	 * processed before <code>EventHandlers</code> of priority n-1.
	 * If two or more <code>EventHandlers</code> share the same priority, they are processed
	 * in the order in which they were added. The default priority is 0.
	 *
	 *  @default 0
	 * */
	public function get priority():int
	{
		return _priority;
	}

	public function set priority(value:int):void
	{
		if (_priority !== value)
		{
			_priority = value;
			unregister(type, dispatcher, useCapture);
			validateNow();
		}
	}

	private var _useWeakReference:Boolean = false;
	/**
	 * (default = true) — Determines whether the reference to the listener is strong or weak.
	 * A strong reference (the default) prevents your listener from being garbage-collected.
	 * A weak reference does not.
	 * When using modules, it is recomended to use weak references to garbage-collect unused modules
	 *
	 *  @default false
	 * */
	public function get useWeakReference():Boolean
	{
		return _useWeakReference;
	}

	public function set useWeakReference(value:Boolean):void
	{
		if (_useWeakReference !== value)
		{
			unregister(type, dispatcher, useCapture);
			_useWeakReference = value;
			validateNow();
		}
	}

	private var _useCapture:Boolean = false;
	/**
	 * (default = false) — Determines whether the listener works in the capture phase or the target and bubbling phases.
	 * If useCapture is set to true, the listener processes the event only during the capture phase and not in the target
	 * or bubbling phase. If useCapture is false, the listener processes the event only during the target or bubbling phase.
	 *
	 *  @default false
	 * */
	public function get useCapture():Boolean
	{
		return _useCapture;
	}

	public function set useCapture(value:Boolean):void
	{
		if (_useCapture !== value)
		{
			unregister(type, dispatcher, _useCapture);
			_useCapture = value;
			validateNow();
		}
	}

	/**
	 * @inheritDoc
	 */
	override public function setDispatcher(value:IEventDispatcher, local:Boolean = true):void
	{
		if (value !== dispatcher)
		{
			if (registered)
			{
				unregister(type, dispatcher, useCapture);
			}
		}
		super.setDispatcher(value, local);
	}

	/**
	 * @inheritDoc
	 */
	override public function errorString():String
	{
		return "EventType:" + type + ". Error was found in a EventHandlers list in file "
				+ DebuggerUtil.getClassName(document);
	}

	/**
	 *  @inheritDoc
	 */
	override public function clearReferences():void
	{
		unregister(type, dispatcher, useCapture);
	}

	/**
	 * Processes the properties set on the component.
	 */
	override protected function commitProperties():void
	{
		if (dispatcherTypeChanged)
		{
			dispatcherTypeChanged = false;
			if (registered)
			{
				unregister(type, currentDispatcher, useCapture);
			}
		}
		if (!registered && type && dispatcher)
		{
			dispatcher.addEventListener(type, fireEvent, useCapture, priority, useWeakReference);
			registered = true;
		}
	}

	/**
	 *  Un-register as a listener of the event type provided.
	 */
	protected function unregister(oldType:String, oldDispatcher:IEventDispatcher, oldCapture:Boolean):void
	{
		if (oldDispatcher && oldType)
		{
			oldDispatcher.removeEventListener(oldType, fireEvent, oldCapture);
			registered = false;
		}
	}

	/**
	 * Called by the dispacher when the event gets triggered.
	 * This method creates a scope and then runs the sequence.
	 */
	protected function fireEvent(event:Event):void
	{
		var currentScope:Scope = new Scope(event, debug, map, inheritedScope);
		currentScope.owner = this;
		setScope(currentScope);
		runSequence(currentScope, actions);

		if (oneTime)
		{
			currentDispatcher.removeEventListener(type, fireEvent, useCapture);
			manager.removeEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
			map.removeEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
			document[documentId] = null;
		}
	}

	override public function initialized(document:Object, id:String):void
	{
		super.initialized(document, id);

		documentId = id;
	}
}
}