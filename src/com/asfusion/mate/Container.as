package com.asfusion.mate
{
import flash.events.Event;
import flash.events.IEventDispatcher;

public class Container
{
	private var dispatcher:IEventDispatcher;

	public function Container(dispatcher:IEventDispatcher)
	{
		this.dispatcher = dispatcher;
	}

	public function lookup(role:Class):Object
	{
		
	}

	public function dispatchEvent(event:Event):Boolean
	{
		return dispatcher.dispatchEvent(event);
	}

	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
	{
		dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
}
}