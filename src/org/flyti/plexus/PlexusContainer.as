package org.flyti.plexus
{
import com.asfusion.mate.actionLists.Injectors;
import com.asfusion.mate.events.InjectorEvent;

import flash.events.IEventDispatcher;

import org.flyti.lang.Enum;

public interface PlexusContainer
{
	function get dispatcher():IEventDispatcher;
	function get injectors():Vector.<Injectors>;

	function checkInjectors(injectorEvent:InjectorEvent):void;
	function lookup(role:Class, roleHint:Enum = null, constructorArguments:Array = null):Object;
}
}