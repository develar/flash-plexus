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
package com.asfusion.mate.core
{
import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.core.mx_internal;
import mx.managers.SystemManager;
import mx.managers.SystemManagerGlobals;

use namespace mx_internal;

public class GlobalDispatcher implements IEventDispatcher
{
	private var topLevelDispatcher:SystemManager;

	public function GlobalDispatcher()
	{
		topLevelDispatcher = SystemManagerGlobals.topLevelSystemManagers[0];
	}

	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
	{
		topLevelDispatcher.$addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	{
		topLevelDispatcher.$removeEventListener(type, listener, useCapture);
	}

	public function dispatchEvent(event:Event):Boolean
	{
		return topLevelDispatcher.dispatchEvent(event);
	}

	public function hasEventListener(type:String):Boolean
	{
		return topLevelDispatcher.hasEventListener(type);
	}

	public function willTrigger(type:String):Boolean
	{
		return topLevelDispatcher.willTrigger(type);
	}
}
}