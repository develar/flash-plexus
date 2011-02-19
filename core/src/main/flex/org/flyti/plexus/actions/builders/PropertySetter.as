package org.flyti.plexus.actions.builders {
import org.flyti.plexus.ISmartObject;
import org.flyti.plexus.actionLists.IScope;
import org.flyti.plexus.events.InjectorEvent;

[Exclude(name="properties", kind="property")]
/**
 * <code>PropertySetter</code> will create an object of the class specified
 *  in the <code>generator</code> attribute. After that, it will set a
 * property in the <code>key</code> attribute on the newly created object.
 * The value to set can be the <code>source</code> object or a property of
 * the source object that is specified in the <code>sourceKey</code> attribute.
 */
public class PropertySetter extends ObjectBuilder {
  private var _targetKey:String;
  /**
   * The name of the property that will be set in the generated object.
   * */
  public function set targetKey(value:String):void {
    _targetKey = value;
  }

  private var _source:Object;
  /**
   * An object that contains the data that will be used to set the target object.
   */
  [Inspectable(enumeration="event,data,result,fault,lastReturn,message,scope")]
  public function set source(value:Object):void {
    _source = value;
  }

  private var _sourceKey:String;
  /**
   * The name of the property on the source object that will be used to read
   * the value to be set the generated object.
   */
  public function set sourceKey(value:String):void {
    _sourceKey = value;
  }

  override protected function run(scope:IScope):void {
    var realSource:Object = _source == null ? InjectorEvent(scope.event).instance : getRealObject(_source, scope);
    var value:Object = _sourceKey == null ? realSource : realSource[_sourceKey];
    currentInstance[_targetKey] = value;
    scope.lastReturn = value;
  }

  /**
   * Helper function to get the source or destination objects
   * from either a String value, a SmartObject or other.
   */
  protected function getRealObject(object:Object, scope:IScope):Object {
    if (object is Function) {
      object = (object as Function)();
    }

    if (object is Class) {
      return scope.eventMap.container.lookup(Class(object));
    }
    else if (object is ISmartObject) {
      return ISmartObject(object).getValue(scope);
    }
    else if (object is String) {
      return scope[object];
    }
    else {
      return object;
    }
  }
}
}