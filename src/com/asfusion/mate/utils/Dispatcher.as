package com.asfusion.mate.utils
{
import com.asfusion.mate.core.MateManager;

import flash.events.Event;

public class Dispatcher
{
	public static function dispatch(event:Event):void
	{
		MateManager.instance.dispatcher.dispatchEvent(event);
	}
}
}