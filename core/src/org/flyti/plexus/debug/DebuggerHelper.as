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
package org.flyti.plexus.debug {
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.logging.LogEvent;
import mx.utils.DescribeTypeCache;
import mx.utils.DescribeTypeCacheRecord;

import org.flyti.plexus.ISmartObject;
import org.flyti.plexus.actionLists.IScope;
import org.flyti.plexus.actionLists.Scope;
import org.flyti.plexus.events.MateLogEvent;

[ExcludeClass]
public class DebuggerHelper implements IDebuggerHelper {
  protected var helperFunctions:Dictionary;

  public function DebuggerHelper() {
    createHelperFunctions();
  }

  public function getMessage(event:LogEvent):String {
    var message:String;
    if (event is MateLogEvent) {
      message = helperFunctions[event.message](event as MateLogEvent);
    }
    else {
      message = event.message;
    }
    return message;
  }

  public static function getClassName(object:Object, name:String = null):String {
    if (!name) {
      name = getQualifiedClassName(object);
    }

    // If there is a package name, strip it off.
    var index:int = name.indexOf("::");
    if (index != -1) {
      name = name.substr(index + 2);
    }

    return name;
  }

  /*-----------------------------------------------------------------------------------------------------------
   *                                          Protected methods
   -------------------------------------------------------------------------------------------------------------*/

  /*-.........................................getDynamicProperties..........................................*/
  protected static function getDynamicProperties(obj:Object, scope:Scope):String {
    var message:String = '';
    for (var prop:String in obj) {
      try {
        message += "   " + prop + '="' + formatValue(obj[prop], scope) + '"';
      }
      catch (e:Error) {
        // do nothing for now
      }
    }
    return message;
  }

  /*-.........................................formatValue..........................................*/
  protected static function formatValue(value:Object, loggerProvider:ILoggerProvider):String {
    var stringValue:String;
    var smartValue:Object;

    if (value is ISmartObject && loggerProvider is IScope) {
      smartValue = ISmartObject(value).getValue(IScope(loggerProvider), true);
      stringValue = ( smartValue != null ) ? smartValue.toString() : 'null';
    }
    else if (value is Array) {
      var arr:Array = value as Array;
      stringValue = "[ ";
      for each(var item:Object in arr) {
        if (item is ISmartObject && loggerProvider is IScope) {
          smartValue = ISmartObject(item).getValue(IScope(loggerProvider), true);
          stringValue += ( smartValue != null ) ? smartValue.toString() : "null";
        }
        else {
          stringValue += ( item != null ) ? item.toString() : "null";
        }

        if (item != arr[arr.length - 1]) {
          stringValue += ", ";
        }
      }
      stringValue += " ]";
    }
    else if (value == null) {
      stringValue = "null";
    }
    else {
      stringValue = value.toString();
    }
    return stringValue;
  }

  /*-.........................................getAttributes..........................................*/
  protected static function getAttributes(target:Object, scope:IScope, omit:Object = null):String {
    var attributes:String = "";
    var attribute:String = "";
    var describe:DescribeTypeCacheRecord = DescribeTypeCache.describeType(target);
    var description:XML = describe.typeDescription;

    for each (var prop:XML in description.accessor) {
      var tempAttribute:XMLList = prop..@name;
      attribute = tempAttribute[0].toString();
      if (target.hasOwnProperty(attribute) && target[attribute] != null && (!omit || !omit.hasOwnProperty(attribute))) {
        var formatedValue:String = formatValue(target[attribute], scope);
        if (formatedValue != "") {
          attributes += "   " + attribute + '="' + formatedValue + '"';
        }
      }
    }
    return attributes;
  }

  /*-.........................................getEventType..........................................*/
  protected function getEventType(event:Event):String {
    var eventName:String = '"' + event.type + '"';
    var eventClass:Class = Class(getDefinitionByName(getQualifiedClassName(event)));
    var description:XML = describeType(eventClass);
    for each (var cons:XML in description.constant..@name) {
      if (eventClass[cons] == event.type) {
        eventName = '"' + getClassName(event) + "." + cons + '" (' + event.type + ')';
      }
    }
    return eventName;
  }

  protected function createHelperFunctions():void {
    helperFunctions = new Dictionary();

    helperFunctions[LogTypes.SEQUENCE_END] = actionListEnd;
    helperFunctions[LogTypes.SEQUENCE_START] = actionListStart;
    helperFunctions[LogTypes.SEQUENCE_TRIGGER] = actionListTrigger;
  }

  /*-.........................................actionListStart..........................................*/
  protected function actionListStart(event:MateLogEvent):String {
    var info:LogInfo = event.parameters[0];
    var message:String = event.message;
    if (info.loggerProvider is Scope) {
      var scope:Scope = Scope(info.loggerProvider);

      message = '';
      message += "<" + getClassName(scope.owner) + " (started) ";
      if (Object(scope.owner).hasOwnProperty('type')) {
        message += "   type=" + getEventType(scope.currentEvent) + "   phase=" + scope.currentEvent.eventPhase + " target=" +
                   scope.currentEvent.target + " currentTarget=" + scope.currentEvent.currentTarget;
      }
      message += getAttributes(scope.owner, scope, {actions:true, faultHandlers:true, type:true, MXMLrequest:true, debug:true});
      message += ">";
    }
    return message;
  }

  /*-.........................................actionListTrigger..........................................*/
  protected function actionListTrigger(event:MateLogEvent):String {
    var info:LogInfo = event.parameters[0];
    var message:String = event.message;

    if (info.loggerProvider is Scope) {
      var scope:Scope = Scope(info.loggerProvider);
      message = '';
      message += "    <" + getClassName(info.target);
      message += getAttributes(info.target, scope, {resultHandlers:true, faultHandlers:true, MXMLrequest:true, properties:true});

      if (info.target.hasOwnProperty('properties') && info.target['properties']) {
        message += ">\n";
        message += "        <Properties" + getDynamicProperties(info.target['properties'], scope) + "/>\n";
        message += "    </" + getClassName(info.target) + ">";
      }
      else {
        message += "/>";
      }
    }
    return message;
  }

  /*-.........................................actionListEnd..........................................*/
  protected function actionListEnd(event:MateLogEvent):String {
    var info:LogInfo = event.parameters[0];
    var message:String = event.message;
    if (info.loggerProvider is Scope) {
      var scope:Scope = Scope(info.loggerProvider);
      message = '';
      message += "</" + getClassName(scope.owner) + " (end) ";
      if (Object(scope.owner).hasOwnProperty('type')) message += "   type=" + getEventType(scope.currentEvent);
      if (Object(scope.owner).hasOwnProperty('target')) message += "   target=" + scope.owner["target"];
      message += ">";
    }

    return message;
  }
}
}