package org.flyti.plexus {
import flash.events.EventDispatcher;
import flash.utils.describeType;

import org.flyti.plexus.actionLists.ScopeProperties;

[Exclude(name="activate", kind="event")]
[Exclude(name="deactivate", kind="event")]
[Abstract]
internal class EventMapBase extends EventDispatcher {
  protected var _container:PlexusContainer;
  public function get container():PlexusContainer {
    return _container;
  }

  protected final function isInjectable(clazz:Class):Boolean {
    var xml:XML = describeType(clazz);
    if (xml.factory.implementsInterface.(@type == "org.flyti.plexus::Injectable").length() == 1 || xml.factory.extendsClass.(@type == "spark.components.supportClasses::GroupBase").length() == 1) {
      return true;
    }
    else {
      var name:String = xml.@name;
      return name == "cocoa::Application";
    }
  }

  /**
   * It refers to the event that made the <code>EventHandlers</code> execute. The event itself or properties of the event
   * can be used as arguments of <code>MethodInvoker</code> methods, service methods, properties of all the <code>IAction</code>, etc.
   *
   * @see currentEvent
   * @see org.flyti.plexus.SmartObject
   */
  public static const event:SmartObject = new SmartObject(ScopeProperties.EVENT);

  /**
   * It refers to the currentEvent that made the action-list (or inner-action-list) execute.
   * Inside the inner-action-list this property has the value of the current event while event has the
   * value of the original event of the main action-list.
   * The currentEvent itself or properties of the event  can be used as arguments of <code>MethodInvoker</code>
   *  methods, service methods, properties of all the <code>IAction</code>, etc.
   *
   * @see event
   * @see org.flyti.plexus.SmartObject
   */
  public static const currentEvent:SmartObject = new SmartObject(ScopeProperties.CURENT_EVENT);

  /**
   * It refers to the fault returned by a service that made the inner-action-list (<code>faultHandlers</code>) execute.
   * The fault itself or properties of the fault can be used as arguments of <code>MethodInvoker</code>
   *  methods, service methods, properties of all the <code>IAction</code>, etc.
   *
   * <p>Available only inside a <code>faultHandlers</code> inner tag.</p>
   *
   * @see org.flyti.plexus.actions.builders.ServiceInvoker
   * @see org.flyti.plexus.SmartObject
   */
  public static const fault:SmartObject = new SmartObject(ScopeProperties.FAULT);

  /**
   * It refers to the result returned by a service that made the inner-action-list (<code>resultHandlers</code>) execute.
   * The result itself or properties of the result can be used as arguments of <code>MethodInvoker</code>
   *  methods, service methods, properties of all the <code>IAction</code>, etc.
   *
   * <p>Available only inside a <code>resultHandlers</code> inner tag.</p>
   *
   * @see org.flyti.plexus.actions.builders.ServiceInvoker
   * @see org.flyti.plexus.SmartObject
   */
  public static const resultObject:SmartObject = new SmartObject(ScopeProperties.RESULT);

  /**
   * lastReturn is always available, although its value might be <code>null</code>.
   * It typically represents the value returned by a method call made on a <code>MethodInvoker</code>,
   * but other <code>IActions</code> might also return a value, such as:
   * <ul><li><code>token</code>: returned by <code>RemoteObjectInvoker</code>,
   * <code>WebServiceInvoker</code> and <code>HTTPServiceInvoker</code> (value is returned before call result is received)</li>
   * <li><code>Boolean value</code>: returned by <code>EventAnnouncer</code> after dispatching the event. True for successful dispatch,
   * false for unsuccessful (either a failure or when preventDefault() was called on the event).</li></ul>
   *
   * @see org.flyti.plexus.SmartObject
   */
  public static const lastReturn:SmartObject = new SmartObject(ScopeProperties.LAST_RETURN);

  /**
   * It refers to the message received that made the <code>MessageHandlers</code> execute.
   * The message itself or properties of the message can be used as arguments of
   * <code>MethodInvoker</code> methods, service methods, properties of all the <code>IActions</code>, etc.
   * <p>Available only inside a <code>MessageHandlers</code> tag.</p>
   *
   * @see org.flyti.plexus.actionLists.MessageHandlers
   * @see org.flyti.plexus.SmartObject
   */
  public static const message:SmartObject = new SmartObject(ScopeProperties.MESSAGE);

  /**
   * Every <code>IActionList</code> contains a placeholder object called <code>data</code>.
   * This object can be used to store temporary data that many tags in the <code>IActionList</code> can share.
   *
   * @see org.flyti.plexus.SmartObject
   */
  public static const data:SmartObject = new SmartObject(ScopeProperties.DATA);

  /**
   * It refers to the <code>scope</code> of the <code>IActionList</code>.
   * The type of the <code>scope</code> is depending the type of <code>IActionList</code>.
   * <p>Available types are:
   * <ul><li><code>Scope</code> for <code>EventHandlers, InjectorHandlers</code></li>
   * <li><code>ServiceScope</code> for <code>ServiceHandlers</code></li>
   * <li><code>MessageScope</code> for <code>MessageHandlers</code></li></ul>
   * </p>
   *
   * @see org.flyti.plexus.SmartObject
   */
  public static const scope:SmartObject = new SmartObject(ScopeProperties.SCOPE);
}
}