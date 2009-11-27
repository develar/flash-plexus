package com.asfusion.mate.events
{
import com.asfusion.mate.core.MateManager;

import flash.events.Event;

public class ContextEventDispatcher
{
	public function dispatchContextEvent(event:Event):Boolean
	{
		return MateManager.instance.dispatcher.dispatchEvent(event);
	}

	public function addContextEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
	{
		MateManager.instance.dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function removeContextEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	{
		MateManager.instance.dispatcher.removeEventListener(type, listener, useCapture);
	}
}
}