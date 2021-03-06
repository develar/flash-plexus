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
package org.flyti.plexus {
import org.flyti.plexus.actionLists.IScope;

/**
 * MethodCaller has the ability to call a method on any object.
 * If an error ocurrs, it will send it to the logger.
 */
public final class MethodCaller {
  /**
   * The function used to call methods on objects.
   * It can also call methods that have arguments if they are provided.
   */
  public static function call(scope:IScope, instance:Object, method:String, args:*, parseArguments:Boolean = true):Object {
    var parameters:Array = parseArguments ? SmartArguments.getRealArguments(scope, args) : args as Array;
    if (parameters == null) {
      return instance[method]();
    }
    else {
      return (instance[method] as Function).apply(instance, parameters);
    }
  }
}
}