package com.asfusion.mate.actionLists
{
import com.asfusion.mate.events.InjectorEvent;

import flash.events.IEventDispatcher;

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
	}

	override public function setDispatcher(value:IEventDispatcher):void
	{
		super.setDispatcher(value);

		// @todo смена dispatcher недопустима — мы сознательно это не поддерживаем
		map.container.injectors.push(this);
	}

	/**
	 * This function is a handler for the injection event, if the target it is a
	 * derivative class the injection gets triggered
	 */
	public function fire(injectorEvent:InjectorEvent):void
	{
		var currentScope:Scope = new Scope(injectorEvent, debug, map, inheritedScope);
		currentScope.owner = this;
		setScope(currentScope);
		runSequence(currentScope, actions);
	}
}
}