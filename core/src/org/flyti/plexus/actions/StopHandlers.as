/*
 Copyright 2008 Nahuel Foronda/AsFusion

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. Y
 ou may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, s
 oftware distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and limitations under the License

 Author: Nahuel Foronda, Principal Architect
 nahuel at asfusion dot com

 @ignore
 */
package org.flyti.plexus.actions
{
import org.flyti.plexus.ISmartObject;
import org.flyti.plexus.actionLists.IScope;

/**
 * The <code>StopHandlers</code> tag lets you stop a certain <code>IActionList</code>
 * before it reaches the end of the listeners list. The <code>IActionList</code> can be stopped based on whether
 * the "lastReturn" is equal to some value, or based on an external function that tells whether
 * or not the <code>IActionList</code> must be stopped.
 *
 * @example This example demonstrates how you can use a StopHandlers tag with a custom
 * custom <code>stopFunction</code>.
 *
 * <listing version="3.0">
 * private function myStopHandlersFunction(scope:Scope):Boolean
 * {
 *	... here you do some evaluation to determine
 *		whether to stop the Actionlist or not...
 *	 return false; //or return true;
 * }
 *
 * &lt;StopHandlers
 *		  stopFunction="myStopHandlersFunction"/&gt;
 * </listing>
 *
 * @mxml
 * <p>The <code>&lt;StopHandlers&gt;</code> tag has the following tag attributes:</p>
 * <pre>
 * &lt;StopHandlers
 * <b>Properties</b>
 * lastReturnEquals="value"
 * stopFunction="Function"
 * eventPropagation="noStop|stopPropagation|stopImmediatePropagation"
 * /&gt;
 * </pre>
 *
 * @see org.flyti.plexus.actionLists.EventHandlers
 */
public class StopHandlers extends AbstractAction implements IAction
{
	private var _lastReturnEquals:Object;
	/**
	 * If there exists a <code>MethodInvoker</code> right before the StopHandlers, and the execution of the
	 * function of the <code>MethodInvoker</code> returned a value ("lastReturn"), you can compare it to some other
	 * value and stop the <code>IActionList</code> if it is equal.
	 */
	public function set lastReturnEquals(value:Object):void
	{
		_lastReturnEquals = value;
	}

	private var _stopFunction:Function;
	/**
	 * A function to call to determine whether or not the <code>IActionList</code> must stop
	 * execution. This is a more flexible approach than using lastReturnEquals.
	 * The function that you implement needs to return true if the <code>IActionList</code> must stop or false if not.
	 */
	public function set stopFunction(value:Function):void
	{
		_stopFunction = value;
	}

	private var _eventPropagation:String = "stopImmediatePropagation";
	/**
	 * This attribute lets you stop the event that triggered the <code>IActionList</code>. If there are any handlers for
	 * this event other than this <code>IActionList</code>, they will not be notified if the propagation of the event
	 * is stopped. See Flex documentation regarding the difference between stop propagation and stop immediate propagation
	 *
	 * @default stopImmediatePropagation
	 */
	[Inspectable(enumeration="noStop,stopPropagation,stopImmediatePropagation")]
	public function set eventPropagation(value:String):void
	{
		_eventPropagation = value;
	}

	override protected function run(scope:IScope):void
	{
		if (_stopFunction != null)
		{
			if (_stopFunction(scope))
			{
				scope.stopRunning();
			}
		}
		else if (_lastReturnEquals != null && ((_lastReturnEquals is ISmartObject) ? ISmartObject(_lastReturnEquals).getValue(scope) : _lastReturnEquals) == scope.lastReturn)
		{
			scope.stopRunning();
		}

		if (!scope.isRunning() && _eventPropagation != "noStop" && scope.event != null)
		{
			if (_eventPropagation == "stopImmediatePropagation")
			{
				scope.event.stopImmediatePropagation();
			}
			else
			{
				scope.event.stopPropagation();
			}
		}

		if (_stopFunction != null && _lastReturnEquals != null)
		{
			trace("Warning : stopFunction and lastReturnEquals cannot both be used. lastReturnEquals was ignored");
		}
	}
}
}