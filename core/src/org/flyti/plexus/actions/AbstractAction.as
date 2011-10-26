package org.flyti.plexus.actions {
import mx.core.IMXMLObject;

import org.flyti.plexus.IDataReceiver;
import org.flyti.plexus.IEventReceiver;
import org.flyti.plexus.IScopeReceiver;
import org.flyti.plexus.SmartArguments;
import org.flyti.plexus.actionLists.IScope;

/**
 * AbstractAction is a base class for all classes implementing <code>IAction</code>.
 */
public class AbstractAction implements IMXMLObject {
  /**
   *  The <code>currentInstance</code> is the Object that this class will
   *  use and modify to do its work. The type of this object depends on the
   *  child implementations.
   *  <p>Usually, this <code>currentInstance</code> is set or created
   *  in the prepare method, but it is not mandatory.</p>
   */
  protected var currentInstance:Object;

  /**
   * This method gets called when the IActionList (ex: EventHandlers) is running.
   * This method is called on each IAction that the IActionList contains in its
   * <code>listeners</code> array.
   * <p>It is recomended that you do not override this method unless needed.
   * Instead, override the four methods that
   * this method calls (prepare, setProperties, run or complete).</p>
   * .
   */
  public function trigger(scope:IScope):void {
    prepare(scope);
    setProperties(scope);
    run(scope);
    complete(scope);
  }

  /**
   * The first method that <code>trigger</code> calls.
   * Usually, this is where the <code>currentInstance</code> is created or set if needed.
   * In this method you can also perform any code that must be done first.
   */
  protected function prepare(scope:IScope):void {
    // this method is abstract it will be implemented by children
  }

  /**
   * Where all the properties are set into the <code>currentInstance</code>.
   * At this time, the <code>currentInstance</code> is already intantiated and ready to be set.
   */
  protected function setProperties(scope:IScope):void {
    if (currentInstance is IScopeReceiver) {
      IScopeReceiver(currentInstance).scope = scope;
    }
    if (currentInstance is IDataReceiver) {
      IDataReceiver(currentInstance).data = scope.data;
    }
    if (currentInstance is IEventReceiver) {
      IEventReceiver(currentInstance).event = scope.event;
    }

  }

  /**
   * Where all the action occurs. At this moment, the <code>currentInstance</code>
   * is already instantiated and all the properties are already set.
   */
  protected function run(scope:IScope):void {
    // this method is abstract it will be implemented by children
  }

  /**
   * The last method that <code>trigger</code> calls.
   * This is your last chance to perform any action before the IActionList calls the next
   * IAction in the list.
   */
  protected function complete(scope:IScope):void {
    currentInstance = null;
  }

  /**
   * A reference to the document object associated with the IActionList that contains this action item.
   * A document object is an Object at the top of the hierarchy of a Flex application, MXML component, or AS component.
   */
  protected var document:Object;

  public function initialized(document:Object, id:String):void {
    this.document = document;
  }

  protected function getRealArguments(scope:IScope, parameters:*):Array {
    return SmartArguments.getRealArguments(scope, parameters);
  }
}
}