package com.asfusion.mate.actionLists
{
import com.asfusion.mate.core.LocalEventMap;
import com.asfusion.mate.core.MateManager;
import com.asfusion.mate.events.InjectorEvent;

import mx.core.IID;

/**
 * An <code>Injectors</code> defined in the <code>EventMap</code> will run whenever an instance of the
 * class specified in the <code>Injectors</code>'s "target" argument is created.
 */
public class Injectors extends AbstractHandlers
{
	private var _target:Class;
	/**
	 * The class that, when an object is created, should trigger the <code>InjectorHandlers</code> to run.
	 * */
	public function get target():Class
	{
		return _target;
	}
	public function set target(value:Class):void
	{
		_target = value;
	}

	private var _targetId:String;
	public function get targetId():String
	{
		return _targetId;
	}
	public function set targetId(value:String):void
	{
		_targetId = value;
	}

	override public function initialized(document:Object, id:String):void
	{
		super.initialized(document, id);

		var injectors:Vector.<Injectors> = map.injectors;
		if (injectors == null)
		{
			injectors = MateManager.instance.injectors;
		}

		injectors.push(this);
	}

	/**
	 * This function is a handler for the injection event, if the target it is a
	 * derivative class the injection gets triggered
	 */
	private function check(instance:Object, injectorEvent:InjectorEvent, uid:String = null):void
	{
		if ((targetId == null || uid == targetId) && instance is target)
		{
			var currentScope:Scope = new Scope(injectorEvent, debug, map, inheritedScope);
			currentScope.owner = this;
			setScope(currentScope);
			runSequence(currentScope, actions);
		}
	}

	public static function injectByInstanceInMap(instance:Object, localEventMap:LocalEventMap):void
	{
		var uid:String = instance is IID ? IID(instance).id : null;
		var injectorEvent:InjectorEvent = new InjectorEvent();
		injectorEvent.injectorTarget = instance;
		injectorEvent.uid = uid;

		if (localEventMap != null)
		{
			checkInjectors(localEventMap.injectors, instance, uid, injectorEvent);
		}
		checkInjectors(MateManager.instance.injectors, instance, uid, injectorEvent);
	}

	public static function inject(instance:Object, scope:IScope, uid:String = null):void
	{
		var injectorEvent:InjectorEvent = new InjectorEvent();
		injectorEvent.injectorTarget = instance;
		injectorEvent.uid = uid;
		var localInjectors:Vector.<Injectors> = scope.eventMap.injectors;
		if (localInjectors != null)
		{
			checkInjectors(localInjectors, instance, uid, injectorEvent);
		}
		checkInjectors(MateManager.instance.injectors, instance, uid, injectorEvent);
	}

	public static function injectByInstanceInGlobalScope(instance:Object, uid:String = null):void
	{
		var injectorEvent:InjectorEvent = new InjectorEvent();
		injectorEvent.injectorTarget = instance;
		injectorEvent.uid = uid;
		checkInjectors(MateManager.instance.injectors, instance, uid, injectorEvent);
	}

	private static function checkInjectors(injectors:Vector.<Injectors>, instance:Object, uid:String, injectorEvent:InjectorEvent):void
	{
		for each (var injector:Injectors in injectors)
		{
			injector.check(instance, injectorEvent, uid);
		}
	}
}
}