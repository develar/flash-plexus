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
package com.asfusion.mate.actionLists {
import com.asfusion.mate.actions.IAction;
import com.asfusion.mate.core.IEventMap;
import com.asfusion.mate.events.ActionListEvent;
import com.asfusion.mate.events.DispatcherEvent;
import com.asfusion.mate.utils.debug.IMateLogger;
import com.asfusion.mate.utils.debug.LogInfo;
import com.asfusion.mate.utils.debug.LogTypes;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.ui.Keyboard;

import mx.core.IMXMLObject;

import org.flyti.plexus.PlexusContainer;

[DefaultProperty("actions")]
[Exclude(name="activate", kind="event")]
[Exclude(name="deactivate", kind="event")]

/**
 *  This event is dispatched right before the list of IActions are called,
 *  when the IActionList starts execution.
 *
 *  @eventType com.asfusion.mate.events.ActionListEvent.START
 */
[Event(name="start", type="com.asfusion.mate.events.ActionListEvent")]


/**
 *  This event is dispatched right after all the IActions have been called,
 *  when the IActionList ends execution (although this event might be dispatched before asynchronous calls have returned).
 *
 *  @eventType com.asfusion.mate.events.ActionListEvent.END
 */
[Event(name="end", type="com.asfusion.mate.events.ActionListEvent")]

/**
 * AbstractHandlers is a base class for all the IActionList implementations.
 */
public class AbstractHandlers extends EventDispatcher implements IMXMLObject, IActionList {
  /**
   * Internal instance of <code>IEventMap</code>.
   */
  protected var map:IEventMap;

  /**
   * Parent scope that is passed to the IActionList when it is a sub-ActionList.
   */
  protected var inheritedScope:IScope;

  private var _actions:Vector.<IAction>;
  public function get actions():Vector.<IAction> {
    return _actions;
  }

  public function set actions(value:Vector.<IAction>):void {
    _actions = value;
    _actions.fixed = true;
  }

  private var _scope:IScope;
  [Bindable(event="scopeChange")]
  public function get scope():IScope {
    return _scope;
  }

  private var _debug:Boolean;
  public function get debug():Boolean {
    return Keyboard.capsLock ? true : _debug;
  }

  public function set debug(value:Boolean):void {
    _debug = value;
  }

  private var _dispatcher:IEventDispatcher;
  /**
   *  The IActionList registers itself as an event listener of the dispatcher specified in this property
   */
  protected function get dispatcher():IEventDispatcher {
    return _dispatcher;
  }

  protected function set dispatcher(value:IEventDispatcher):void {
    if (_dispatcher != value) {
      _dispatcher = value;
    }
  }

  public function setDispatcher(value:IEventDispatcher):void {
    if (value == dispatcher) {
      return;
    }

    dispatcher = value;
    validateNow();
  }

  private var needsInvalidation:Boolean;

  public function invalidateProperties():void {
    if (!isInitialized) {
      needsInvalidation = true;
    }
    else {
      commitProperties();
    }
  }

  public function setInheritedScope(inheritedScope:IScope):void {
    this.inheritedScope = inheritedScope;
  }

  public function validateNow():void {
    commitProperties();
  }

  public function errorString():String {
    return "Error was found in a Handlers in " + map;
  }

  /**
   * Internal storage for a group id.
   */
  private var _groupId:int = -1;

  public function getGroupId():int {
    return _groupId;
  }

  public function setGroupId(id:int):void {
    _groupId = id;
  }

  public function clearReferences():void {
    // this method is abstract it will be implemented by children
  }

  /**
   * Goes over all the listeners (<code>IAction</code>s)
   * and calls the method <code>trigger</code> on them, passing the scope as an argument.
   * It also dispatches the <code>start</code> and <code>end</code> sequence events.
   */
  protected function runSequence(scope:IScope, actionList:Vector.<IAction>):void {
    var logger:IMateLogger = scope.logger;
    const loggerActive:Boolean = logger.active;
    if (loggerActive) {
      logger.info(LogTypes.SEQUENCE_START, new LogInfo(scope));
    }
    dispatchEvent(new ActionListEvent(ActionListEvent.START, scope.event));

    for each (var action:IAction in actionList) {
      if (scope.isRunning()) {
        scope.currentTarget = action;
        if (loggerActive) {
          logger.info(LogTypes.SEQUENCE_TRIGGER, new LogInfo(scope));
        }
        action.trigger(scope);
      }
    }

    dispatchEvent(new ActionListEvent(ActionListEvent.END));
    if (loggerActive) {
      logger.debug(LogTypes.SEQUENCE_END, new LogInfo(scope));
    }
    _scope = null;
  }

  /**
   * Processes the properties set on the component.
   */
  protected function commitProperties():void {
    // this method is abstract it will be implemented by children
  }

  /**
   * Set the scope on this IActionList.
   */
  protected function setScope(scope:IScope):void {
    _scope = scope;
    dispatchEvent(new ActionListEvent(ActionListEvent.SCOPE_CHANGE));
  }

  /**
   * A handler for the mate dispatcher changed.
   * This method is called by <code>IMateManager</code> when the dispatcher changes.
   */
  protected function dispatcherChangeHandler(event:DispatcherEvent):void {
    setDispatcher(event.newDispatcher);
  }

  public function getDocument():Object {
    return map;
  }

  private var isInitialized:Boolean;

  public function initialized(document:Object, id:String):void {
    map = IEventMap(document);
    // service can set dispatcher for inner handlers
    if (dispatcher == null) {
      var container:PlexusContainer = map.container;
      if (container == null) {
        map.addEventListener(DispatcherEvent.CHANGE, dispatcherChangeHandler);
      }
      else {
        setDispatcher(container.dispatcher);
      }
    }

    if (needsInvalidation) {
      commitProperties();
      needsInvalidation = false;
    }

    isInitialized = true;
  }
}
}