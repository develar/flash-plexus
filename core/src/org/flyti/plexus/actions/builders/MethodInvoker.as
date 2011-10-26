package org.flyti.plexus.actions.builders {
import org.flyti.plexus.MethodCaller;
import org.flyti.plexus.actionLists.IScope;

/**
 * When placed inside a <code>IActionList</code> tag and the list is executed,
 * <code>MethodInvoker</code> will create an object of the class specified in the <code>generator</code> attribute.
 * It will then call the function specified in the <code>method</code> attribute on the newly created object.
 * You can pass arguments to this function that come from a variety of sources, such as the event itself,
 * a server result object, or any other value.
 * Unless you specify cache="none", this <code>MethodInvoker</code> instance will be "cached" and not instantiated again.
 *
 *
 * @mxml
 * <p>The <code>&lt;MethodInvoker&gt;</code> tag has the following tag attributes:</p>
 * <pre>
 * &lt;MethodInvoker
 * <b>Properties</b>
 * generator="Class"
 * constructorArgs="Object|Array"
 * properties="Properties"
 * arguments="Object|Array"
 * method="String"
 * cache="local|global|inherit|none"
 * /&gt;
 * </pre>
 *
 * @see org.flyti.plexus.actionLists.EventHandlers
 */
public class MethodInvoker extends ObjectBuilder {
  private var _arguments:*;
  /**
   *  The property <code>arguments</code> allows you to pass an Object or an Array of objects when calling
   * the function defined in the property <code>method</code> .
   *  <p>You can use an array to pass multiple arguments or use a simple Object if the signature of the
   * <code>method</code> has only one parameter.</p>
   */
  public function set arguments(value:*):void {
    _arguments = value;
  }

  public var method:String;

  override protected function run(scope:IScope):void {
    scope.lastReturn = MethodCaller.call(scope, currentInstance, method, _arguments);
  }
}
}