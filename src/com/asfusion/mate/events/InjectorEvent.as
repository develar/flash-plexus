package com.asfusion.mate.events
{
import flash.events.Event;

/**
 * This event is used by the InjectorRegistry to register a target for Injection.
 */
public class InjectorEvent extends Event
{
	/**
	 * Target that wants to register for Injection.
	 */
	public var injectorTarget:Object;

	/**
	 * Unique identifier to distinguish the target
	 */
	public var uid:String;

	public function InjectorEvent()
	{
		super("$fake$InjectorEvent");
	}
}
}