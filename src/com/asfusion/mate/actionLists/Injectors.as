package com.asfusion.mate.actionLists
{
import com.asfusion.mate.events.InjectorEvent;

/**
 * An <code>Injectors</code> defined in the <code>EventMap</code> will run whenever an instance of the
 * class specified in the <code>Injectors</code>'s "target" argument is created.
 */
public class Injectors extends AbstractHandlers
{
	private var documentId:String;

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
		documentId = id;

		super.initialized(document, id);

		map.container.injectors.push(this);
	}

	/**
	 * This function is a handler for the injection event, if the target it is a
	 * derivative class the injection gets triggered
	 */
	private function check(injectorEvent:InjectorEvent):void
	{
		if ((targetId == null || injectorEvent.uid == targetId) && injectorEvent.instance is target)
		{
			var currentScope:Scope = new Scope(injectorEvent, debug, map, inheritedScope);
			currentScope.owner = this;
			setScope(currentScope);
			runSequence(currentScope, actions);
		}
	}

//	public static function inject(instance:Object, scope:IScope, uid:String = null):void
//	{
//		var injectorEvent:InjectorEvent = new InjectorEvent(instance, uid);
//		var localInjectors:Vector.<Injectors> = scope.eventMap.injectors;
//		if (localInjectors != null)
//		{
//			checkInjectors(localInjectors, injectorEvent);
//		}
//		checkInjectors(MateManager.instance.injectors, injectorEvent);
//	}

	public static function checkInjectors(injectors:Vector.<Injectors>, injectorEvent:InjectorEvent):void
	{
		for each (var injector:Injectors in injectors)
		{
			injector.check(injectorEvent);
		}
	}
}
}