package com.asfusion.mate.events
{
import com.asfusion.mate.core.MateManager;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class EventDispatcher extends flash.events.EventDispatcher
{
	private var dispatcher:IEventDispatcher;

	public function EventDispatcher()
	{
		dispatcher = MateManager.instance.container.dispatcher;
	}

	public function dispatchContextEvent(event:Event):Boolean
	{
		return dispatcher.dispatchEvent(event);
	}

	public function addContextEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
	{
		dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function removeContextEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
}
}