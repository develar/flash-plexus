package org.flyti.plexus.actions
{
import org.flyti.plexus.actionLists.IScope;

/**
 * Allows calling an inline function (a function defined in the event map)
 * or calling a static function in any class.
 * You can pass arguments to this function that come from a variety of sources, such as the event itself,
 `* a server result object, or any other value.
 */
public class InlineInvoker extends AbstractAction implements IAction
{
	private var _arguments:*;

	/**
	 *  The property <code>arguments</code> allows you to pass an Object or an Array of objects when calling
	 * the function defined in the property <code>method</code> .
	 *  <p>You can use an array to pass multiple arguments or use a simple Object if the signature of the
	 * <code>method</code> has only one parameter.</p>
	 */
	public function set arguments(value:*):void
	{
		_arguments = value;
	}

	private var _method:Function;
	public function set method(value:Function):void
	{
		_method = value;
	}

	override protected function run(scope:IScope):void
	{
		scope.lastReturn = _method.apply(null, getRealArguments(scope, _arguments));
	}
}
}