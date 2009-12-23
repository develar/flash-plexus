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
package com.asfusion.mate.actions.builders
{
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.actions.IAction;
import com.asfusion.mate.core.SmartArguments;
import com.asfusion.mate.core.mate;
import com.asfusion.mate.utils.debug.LogInfo;
import com.asfusion.mate.utils.debug.LogTypes;

import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.events.DynamicEvent;

import org.flyti.plexus.ComponentCachePolicy;

use namespace mate;

[Exclude(name="cache", kind="property")]

/**
 * <code>EventAnnouncer</code> allows you to dispatch events from a <code>IActionList</code>.
 * When the <code>IActionList</code> is executed, it will create an event of the class specified in the <code>generator</code>
 * attribute.
 * <p>It will then add any properties to the newly created event and dispatch it.
 * You can pass properties to the event that come from a variety of sources,
 * such as the original event that triggered the <code>IActionList</code>, a server result object, or any other value.</p>
 *
 * @example This example demonstrates how you can create an
 * event using the EventAnnouncer and set its properties using the Properties inner tag.
 *
 * <listing version="3.0">
 * &lt;EventAnnouncer
 *		  generator="MyEventClass"
 *		  type="myEventType"/&gt;
 *
 *		  &lt;Properties
 *		  myProperty="myValue"
 *		  myProperty2="100"/&gt;
 *
 * &lt;/EventAnnouncer/&gt;
 * </listing>
 *
 * @mxml
 * <p>The <code>&lt;EventAnnouncer&gt;</code> tag has the following tag attributes:</p>
 * <pre>
 * &lt;EventAnnouncer
 * <b>Properties</b>
 * generator="Class"
 * constructorArguments="Object|Array"
 * type="String"
 * bubbles="true|false"
 * cancelable="true|false"
 * /&gt;
 * </pre>
 *
 * @see com.asfusion.mate.actionLists.EventHandlers
 */
public class EventAnnouncer extends ObjectBuilder implements IAction
{
	private var _generator:Class = DynamicEvent;
	/**
	 * The generator attribute specifies what class should be instantiated.
	 * If this attribute is not specified, then a DynamicEvent will be generated.
	 *
	 *  @default mx.events.DynamicEvent
	 */
	override public function get generator():Class
	{
		return _generator;
	}

	override public function set generator(value:Class):void
	{
		_generator = value;
	}

	private var _type:String;
	/**
	 *  The type attribute specifies the event type you want to dispatch.
	 *
	 *  @default null
	 */
	public function get type():String
	{
		return _type;
	}
	public function set type(value:String):void
	{
		_type = value;
	}

	private var _bubbles:Boolean;
	/**
	 * Although you can specify the event's bubbles property, whether you set it to true or false will have little effect,
	 * as the event will be dispatched from the Mate Dispatcher itself.
	 *
	 *  @default false
	 */
	public function get bubbles():Boolean
	{
		return _bubbles;
	}

	public function set bubbles(value:Boolean):void
	{
		_bubbles = value;
	}

	private var _cancelable:Boolean = true;
	/**
	 * Indicates whether the behavior associated with the event can be prevented.
	 *
	 *  @default true
	 */
	public function get cancelable():Boolean
	{
		return _cancelable;
	}

	public function set cancelable(value:Boolean):void
	{
		_cancelable = value;
	}

	override public function get cache():String
	{
		return ComponentCachePolicy.NONE;
	}
	override public function set cache(value:String):void
	{
		throw(new Error("Events and responses cannot be cached"));
	}

	//.........................................dispatcherType..........................................
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
			_dispatcherType = value;
		}
	}

	override protected function createInstance(scope:IScope):Object
	{
		var realArguments:Array;
		if (constructorArguments !== undefined)
		{
			realArguments = SmartArguments.getRealArguments(scope, constructorArguments);
		}
		else if (type != null)
		{
			realArguments = [type, bubbles, cancelable];
		}
		else
		{
			currentInstance = null;
			scope.getLogger().error(LogTypes.TYPE_NOT_FOUND, new LogInfo(scope));
			return null;
		}

		currentInstance = scope.manager.instantiator.createInstance(generator, realArguments);
		return currentInstance;
	}

	override protected function run(scope:IScope):void
	{
		var dispatcher:IEventDispatcher = (dispatcherType == "inherit") ? scope.dispatcher : scope.manager.dispatcher;
		scope.lastReturn = dispatcher.dispatchEvent(Event(currentInstance));
	}
}
}