package com.asfusion.mate.events
{
import flash.events.Event;
import flash.utils.getQualifiedClassName;

import mx.core.IID;

/**
 * This event is used by the InjectorRegistry to register a target for Injection.
 */
public class InjectorEvent extends Event
{
	public static const INJECT_DERIVATIVES:String = "injectDerivativesInjectorEvent";

	/**
	 * Target that wants to register for Injection.
	 */
	public var injectorTarget:Object;

	/**
	 * Unique identifier to distinguish the target
	 */
	public var uid:String;

	public function InjectorEvent(type:String, target:Object, bubbles:Boolean = false, cancelable:Boolean = false)
	{
		injectorTarget = target;
		if (target is IID)
		{
			uid = (target as IID).id;
		}

		if (type == null)
		{
			type = getQualifiedClassName(target);
		}

		super(type, bubbles, cancelable);
	}
}
}