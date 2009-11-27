package com.asfusion.mate.utils
{
import flash.events.Event;

import com.asfusion.mate.events.Dispatcher;

public class Dispatcher
{
	private static var dispatcher:com.asfusion.mate.events.Dispatcher = new com.asfusion.mate.events.Dispatcher();

	public static function dispatch(event:Event):void
	{
		dispatcher.dispatchEvent(event);
	}
}
}