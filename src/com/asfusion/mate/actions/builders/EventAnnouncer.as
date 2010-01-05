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
import com.asfusion.mate.utils.debug.LogInfo;
import com.asfusion.mate.utils.debug.LogTypes;

import flash.events.Event;

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
	private var _type:String;
	/**
	 *  The type attribute specifies the event type you want to dispatch.
	 */
	public function set type(value:String):void
	{
		_type = value;
	}

	private var _bubbles:Boolean;
	/**
	 * Although you can specify the event's bubbles property, whether you set it to true or false will have little effect,
	 * as the event will be dispatched from the Mate Dispatcher itself.
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
	 */
	public function get cancelable():Boolean
	{
		return _cancelable;
	}

	public function set cancelable(value:Boolean):void
	{
		_cancelable = value;
	}

	override protected function createInstance(scope:IScope):Object
	{
		var realArguments:Array;
		if (_constructorArguments != null)
		{
			realArguments = getRealArguments(scope, _constructorArguments);
		}
		else if (_type != null)
		{
			realArguments = [_type, bubbles, cancelable];
		}
		else
		{
			currentInstance = null;
			scope.getLogger().error(LogTypes.TYPE_NOT_FOUND, new LogInfo(scope));
			return null;
		}

		currentInstance = newInstance(role, realArguments);
		return currentInstance;
	}

	override protected function run(scope:IScope):void
	{
		scope.lastReturn = scope.dispatcher.dispatchEvent(Event(currentInstance));
	}

	private function newInstance(template:Class, p:Array):Object
	{
		if (p == null || p.length == 0)
		{
			return new template();
		}
		else
		{
			// ugly way to call a constructor.
			// if someone knows a better way please let me know (nahuel at asfusion dot com).
			switch (p.length)
			{
				case 1:	return new template(p[0]); break;
				case 2:	return new template(p[0], p[1]); break;
				case 3:	return new template(p[0], p[1], p[2]); break;
				case 4:	return new template(p[0], p[1], p[2], p[3]); break;
				case 5:	return new template(p[0], p[1], p[2], p[3], p[4]); break;
				case 6:	return new template(p[0], p[1], p[2], p[3], p[4], p[5]); break;
				case 7:	return new template(p[0], p[1], p[2], p[3], p[4], p[5], p[6]); break;
			}

			throw new ArgumentError("constructorArguments is too long");
		}
	}
}
}