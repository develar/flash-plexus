package com.asfusion.mate.core
{
import com.asfusion.mate.actionLists.Injectors;
import com.asfusion.mate.actionLists.ScopeProperties;

import flash.events.EventDispatcher;

import org.flyti.plexus.PlexusContainer;

[Exclude(name="activate", kind="event")]
[Exclude(name="deactivate", kind="event")]
public class EventMapBase extends EventDispatcher
{
	protected var _container:PlexusContainer;
	public function get container():PlexusContainer
	{
		return _container;
	}

	/**
	 * It refers to the event that made the <code>EventHandlers</code> execute. The event itself or properties of the event
	 * can be used as arguments of <code>MethodInvoker</code> methods, service methods, properties of all the <code>IAction</code>, etc.
	 *
	 * @see currentEvent
	 * @see com.asfusion.mate.core.SmartObject
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
	 * @see com.asfusion.mate.core.SmartObject
	 */
	public static const currentEvent:SmartObject = new SmartObject(ScopeProperties.CURENT_EVENT);

	/**
	 * It refers to the fault returned by a service that made the inner-action-list (<code>faultHandlers</code>) execute.
	 * The fault itself or properties of the fault can be used as arguments of <code>MethodInvoker</code>
	 *  methods, service methods, properties of all the <code>IAction</code>, etc.
	 *
	 * <p>Available only inside a <code>faultHandlers</code> inner tag.</p>
	 *
	 * @see com.asfusion.mate.actions.builders.ServiceInvoker
	 * @see com.asfusion.mate.core.SmartObject
	 */
	public static const fault:SmartObject = new SmartObject(ScopeProperties.FAULT);

	/**
	 * It refers to the result returned by a service that made the inner-action-list (<code>resultHandlers</code>) execute.
	 * The result itself or properties of the result can be used as arguments of <code>MethodInvoker</code>
	 *  methods, service methods, properties of all the <code>IAction</code>, etc.
	 *
	 * <p>Available only inside a <code>resultHandlers</code> inner tag.</p>
	 *
	 * @see com.asfusion.mate.actions.builders.ServiceInvoker
	 * @see com.asfusion.mate.core.SmartObject
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
	 * @see com.asfusion.mate.core.SmartObject
	 */
	public static const lastReturn:SmartObject = new SmartObject(ScopeProperties.LAST_RETURN);

	/**
	 * It refers to the message received that made the <code>MessageHandlers</code> execute.
	 * The message itself or properties of the message can be used as arguments of
	 * <code>MethodInvoker</code> methods, service methods, properties of all the <code>IActions</code>, etc.
	 * <p>Available only inside a <code>MessageHandlers</code> tag.</p>
	 *
	 * @see com.asfusion.mate.actionLists.MessageHandlers
	 * @see com.asfusion.mate.core.SmartObject
	 */
	public static const message:SmartObject = new SmartObject(ScopeProperties.MESSAGE);

	/**
	 * Every <code>IActionList</code> contains a placeholder object called <code>data</code>.
	 * This object can be used to store temporary data that many tags in the <code>IActionList</code> can share.
	 *
	 * @see com.asfusion.mate.core.SmartObject
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
	 * @see com.asfusion.mate.core.SmartObject
	 */
	public static const scope:SmartObject = new SmartObject(ScopeProperties.SCOPE);
}
}