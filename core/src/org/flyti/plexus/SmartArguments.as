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
 * SmartArguments is a helper class that parses the arguments with ISmartObject
 * and returns an Array with simple Objects
 */
public class SmartArguments {
  /**
   * Parses the arguments and removes all ISmartObjects.
   * It returns an array with the actual objects.
   */
  public static function getRealArguments(scope:IScope, parameters:*):Array {
    var realArguments:Array;
    if (parameters is Array) {
      realArguments = parameters;
      if (scope != null) {
        var copied:Boolean = false;
        for (var i:int = 0, n:int = parameters.length; i < n; i++) {
          var argument:Object = parameters[i];
          if (argument is ISmartObject) {
            if (!copied) {
              copied = true;
              realArguments = parameters.slice();
            }
            realArguments[i] = ISmartObject(argument).getValue(scope);
          }
        }
      }
    }
    else if (parameters !== undefined) {
      realArguments = [(scope != null && parameters is ISmartObject) ? ISmartObject(parameters).getValue(scope) : parameters];
    }

    return realArguments;
  }
}
}