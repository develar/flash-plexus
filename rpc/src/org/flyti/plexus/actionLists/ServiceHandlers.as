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
package org.flyti.plexus.actionLists {
import flash.events.Event;
import flash.events.UncaughtErrorEvent;

import mx.rpc.AsyncToken;
import mx.rpc.events.AbstractEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
 * A inner-action-list to run when the server call returns a result.
 * Inside this <code>IActionList</code>, you can use the same tags you would in the main
 * body of a &lt;IActionList&gt;, including other service calls.
 * <p>This inner-action-list is used by the ServiceInvoker</p>
 */
public class ServiceHandlers extends EventHandlers implements IActionList {
  private var _token:AsyncToken;
  /**
   * Generated when making asynchronous RPC operations.
   * The same object is available in the <code>result</code> and <code>fault</code> events in the <code>token</code> property.
   */
  public function get token():AsyncToken {
    return _token;
  }

  public function set token(value:AsyncToken):void {
    _token = value;
  }

  public function ServiceHandlers(inheritedScope:IScope = null) {
    super();
    this.inheritedScope = inheritedScope;
  }

  override public function errorString():String {
    var eType:String;
    try {
      var inheritedEvent:Event = inheritedScope.event;
      eType = inheritedEvent.type;
    }
    catch(e:Error) {
      eType = type;
    }
    return "EventType:" + eType + ". Error was found in a ServiceHandlers list in " + map;
  }

  override protected function fireEvent(event:Event):void {
    if (AbstractEvent(event).token == token) {
      if (actions != null && actions.length > 0) {
        var currentScope:ServiceScope = new ServiceScope(inheritedScope.event, inheritedScope);
        currentScope.owner = this;

        if (event is FaultEvent) {
          currentScope.fault = FaultEvent(event).fault;
        }
        if (event is ResultEvent) {
          currentScope.result = ResultEvent(event).result;
        }


        setScope(currentScope);
        runSequence(currentScope, actions);
      }
      else if (event is FaultEvent) {
        inheritedScope.dispatcher.dispatchEvent(new UncaughtErrorEvent(UncaughtErrorEvent.UNCAUGHT_ERROR, true, true, event));
      }
    }
  }
}
}