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
package org.flyti.plexus.events
{
import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * Event that notifies when Dispatcher changes.
 */
public class DispatcherEvent extends Event
{
	public static const CHANGE:String = "changeDispatcherEvent";
	/**
	 * Reference to the previous dispatcher.
	 */
	public var oldDispatcher:IEventDispatcher;

	/**
	 * Reference to the new dispatcher.
	 */
	public var newDispatcher:IEventDispatcher;

	public function DispatcherEvent(type:String)
	{
		super(type);
	}

	override public function clone():Event
	{
		var event:DispatcherEvent = new DispatcherEvent(type);
		event.newDispatcher = newDispatcher;
		event.oldDispatcher = oldDispatcher;
		return event;
	}
}
}