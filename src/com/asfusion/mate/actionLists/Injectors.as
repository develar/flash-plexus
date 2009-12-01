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
	/**
	 * Flag indicating if this <code>InjectorHandlers</code> is registered to listen to a target or not.
	 */
	protected var targetRegistered:Boolean;

	/**
	 * Flag indicating if this <code>InjectorHandlers</code> is registered to listen to a target list or not.
	 */
	protected var targetsRegistered:Boolean;

	/**
	 * Flag indicating if the includeDerivatives property has been changed.
	 */
	protected var includeDerivativesChanged:Boolean = true;

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

	private var _targets:Vector.<Class>;
	/**
	 * An array of classes that, when an object is created, should trigger the <code>InjectorHandlers</code> to run.
	 * */
	public function get targets():Vector.<Class>
	{
		return _targets;
	}
	public function set targets(value:Vector.<Class>):void
	{
		var oldValue:Vector.<Class> = _targets;
		if (oldValue !== value)
		{
			if (targetRegistered) unregister();
			_targets = value;
			validateNow();
		}
	}

	private var _includeDerivatives:Boolean = true;
	/**
	 * If this property is true, the injector will inject not only the Class in the
	 * target property, but also all the classes that extend from that class.
	 * If the target is an interface, it will inject all the objects that implement
	 * the interface.
	 *
	 *  @default false
	 * */
	public function get includeDerivatives():Boolean
	{
		return _includeDerivatives;
	}

	public function set includeDerivatives(value:Boolean):void
	{
		var oldValue:Boolean = _includeDerivatives;
		if (oldValue !== value)
		{
			_includeDerivatives = value;
			includeDerivativesChanged = true;
			validateNow();
		}
	}

	private var _targetId:String;
	/**
	 * This tag will run if any of the following statements is true:
	 * If the targetId is null.
	 * If the id of the target matches the targetId.
	 *
	 * Note:Target is the instance of the target class.
	 *
	 * @default null
	 * */
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

	//-----------------------------------------------------------------------------------------------------------
	//                                          Protected Methods
	//-----------------------------------------------------------------------------------------------------------

	//.........................................commitProperties..........................................
	/**
	 * Processes the properties set on the component.
	 */
	override protected function commitProperties():void
	{
		if (!dispatcher) return;

		if (dispatcherTypeChanged)
		{
			dispatcherTypeChanged = false;
			unregister();
		}


		if (!targetRegistered && target)
		{
			var type:String = getQualifiedClassName(target);
			dispatcher.addEventListener(type, fireEvent, false, 0, true);
			targetRegistered = true;
		}

		if (!targetsRegistered && targets)
		{
			for each(var currentTarget:* in targets)
			{
				var currentType:String = ( currentTarget is Class) ? getQualifiedClassName(currentTarget) : currentTarget;
				dispatcher.addEventListener(currentType, fireEvent, false, 0, true);
			}
			targetsRegistered = true;
		}

		if (target != null || targets != null)
		{
			manager.addListenerProxy(dispatcher);
			if (includeDerivativesChanged)
			{
				includeDerivativesChanged = false;
				if (includeDerivatives)
				{
					dispatcher.addEventListener(InjectorEvent.INJECT_DERIVATIVES, injectDerivativesHandler, false, 0, true);
				}
				else
				{
					dispatcher.removeEventListener(InjectorEvent.INJECT_DERIVATIVES, injectDerivativesHandler);
				}
			}
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
		if (!dispatcher) return;

		if (targetRegistered && target)
		{
			var type:String = getQualifiedClassName(target);
			dispatcher.removeEventListener(type, fireEvent);
			targetRegistered = false;
		}

		if (targets && targetsRegistered)
		{
			for each(var currentTarget:* in targets)
			{
				var currentType:String = ( currentTarget is Class) ? getQualifiedClassName(currentTarget) : currentTarget;
				dispatcher.removeEventListener(currentType, fireEvent);
			}
			targetsRegistered = false;
		}
	}

	//.........................................setDispatcher..........................................
	/**
	 * @inheritDoc
	 */
	override public function setDispatcher(value:IEventDispatcher, local:Boolean = true):void
	{
		if (currentDispatcher && currentDispatcher != value)
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
		//trace(target, event.injectorTarget);
		if (target != null)
		{
			if ((targetId == null || event.uid == targetId) && isDerivative(event.injectorTarget, target))
			{
				fireEvent(event);
			}
		}
		else if (targets != null)
		{
			for each (var currentTarget:Class in targets)
			{
				if (isDerivative(event.injectorTarget, currentTarget))
				{
					fireEvent(event);
				}
			}
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