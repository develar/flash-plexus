package com.asfusion.mate.actionLists
{
import com.asfusion.mate.core.mate;
import com.asfusion.mate.events.InjectorEvent;
import com.asfusion.mate.utils.debug.DebuggerUtil;

import flash.events.IEventDispatcher;
import flash.utils.getQualifiedClassName;

use namespace mate;

/**
 * An <code>Injectors</code> defined in the <code>EventMap</code> will run whenever an instance of the
 * class specified in the <code>Injectors</code>'s "target" argument is created.
 */
public class Injectors extends AbstractHandlers
{
	protected var targetRegistered:Boolean;

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
		var oldValue:Class = _target;
		if (oldValue !== value)
		{
			if (targetRegistered) unregister();
			_target = value;
			validateNow();
		}
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

	/**
	 * @inheritDoc
	 */
	override public function errorString():String
	{
		return "Injector target:" + DebuggerUtil.getClassName(target) + ". Error was found in a Injectors list in file "
				+ DebuggerUtil.getClassName(document);
	}

	override protected function commitProperties():void
	{
		if (dispatcher == null)
		{
			return;
		}

		if (dispatcherTypeChanged)
		{
			dispatcherTypeChanged = false;
			unregister();
		}

		if (!targetRegistered && target != null)
		{
			var type:String = getQualifiedClassName(target);
			dispatcher.addEventListener(type, fireEvent, false, 0, true);
			targetRegistered = true;
		}

		if (target != null)
		{
			manager.addListenerProxy(dispatcher);
			dispatcher.addEventListener(InjectorEvent.INJECT_DERIVATIVES, injectDerivativesHandler, false, 0, true);
		}
	}

	/**
	 * Called by the dispacher when the event gets triggered.
	 * This method creates a scope and then runs the sequence.
	 */
	protected function fireEvent(event:InjectorEvent):void
	{
		//trace(target, event.injectorTarget);
		if (targetId != null && event.uid != targetId)
		{
			return;
		}

		var currentScope:Scope = new Scope(event, debug, map, inheritedScope);
		currentScope.owner = this;
		setScope(currentScope);
		runSequence(currentScope, actions);
	}

	/**
	 * Unregisters a target or targets. Used internally whenever a new target/s is set or dispatcher changes.
	 */
	protected function unregister():void
	{
		if (dispatcher == null)
		{
			return;
		}

		if (targetRegistered && target != null)
		{
			var type:String = getQualifiedClassName(target);
			dispatcher.removeEventListener(type, fireEvent);
			targetRegistered = false;
		}
	}

	override public function setDispatcher(value:IEventDispatcher, local:Boolean = true):void
	{
		if (currentDispatcher != null && currentDispatcher != value)
		{
			unregister();
		}
		super.setDispatcher(value, local);
	}

	/**
	 * This function is a handler for the injection event, if the target it is a
	 * derivative class the injection gets triggered
	 */
	protected function injectDerivativesHandler(event:InjectorEvent):void
	{
		if ((targetId == null || event.uid == targetId) && isDerivative(event.injectorTarget, target))
		{
			fireEvent(event);
		}
	}

	/**
	 * Check if the current object is a derivative class and return a boolean value
	 * true / false.
	 */
	protected function isDerivative(injectorTarget:Object, targetClass:Class):Boolean
	{
		return injectorTarget is targetClass && (injectorTarget is Class ? Class(injectorTarget) : injectorTarget.constructor) != targetClass;
	}
}
}