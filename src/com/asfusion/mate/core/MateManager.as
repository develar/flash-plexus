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
package com.asfusion.mate.core {
public final class MateManager {
  private static var _instance:IMateManager;
  public static function get instance():IMateManager {
    if (_instance == null) {
      _instance = new MateManagerInstance();
    }

    return _instance;
  }
}
}

import com.asfusion.mate.core.GlobalDispatcher;
import com.asfusion.mate.core.IMateManager;
import com.asfusion.mate.utils.debug.IMateLogger;
import com.asfusion.mate.utils.debug.Logger;

import mx.logging.ILoggingTarget;

import org.flyti.plexus.DefaultPlexusContainer;
import org.flyti.plexus.PlexusContainer;
import org.flyti.plexus.component.ComponentDescriptorRegistry;

class MateManagerInstance implements IMateManager {
  public function MateManagerInstance() {
    _componentDescriptorRegistry = new ComponentDescriptorRegistry();
    _container = new DefaultPlexusContainer(new GlobalDispatcher(), _componentDescriptorRegistry);
  }

  private var _componentDescriptorRegistry:ComponentDescriptorRegistry;
  public function get componentDescriptorRegistry():ComponentDescriptorRegistry {
    return _componentDescriptorRegistry;
  }

  private var _container:PlexusContainer;
  public function get container():PlexusContainer {
    return _container;
  }

  private var _loggerClass:Class = Logger;
  public function get loggerClass():Class {
    return _loggerClass;
  }

  public function set loggerClass(value:Class):void {
    _loggerClass = value;
  }

  private var _debugger:ILoggingTarget;
  public function get debugger():ILoggingTarget {
    return _debugger;
  }

  public function set debugger(value:ILoggingTarget):void {
    _debugger = value;
  }

  public function getLogger(active:Boolean):IMateLogger {
    var logger:IMateLogger;
    if (debugger != null) {
      logger = new loggerClass(active);
      debugger.addLogger(logger);
    }
    else {
      logger = new loggerClass(false);
    }
    return logger;
  }
}