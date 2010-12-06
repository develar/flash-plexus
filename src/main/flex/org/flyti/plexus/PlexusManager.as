package org.flyti.plexus {
import mx.logging.ILoggingTarget;

import org.flyti.plexus.component.ComponentDescriptorRegistry;
import org.flyti.plexus.debug.IMateLogger;
import org.flyti.plexus.debug.Logger;

public final class PlexusManager {
  private static var _instance:PlexusManager;

  public function PlexusManager() {
    _componentDescriptorRegistry = new ComponentDescriptorRegistry();
    _container = new DefaultPlexusContainer(GlobalDispatcher.createIfApplicable(), _componentDescriptorRegistry);
  }

  public static function get instance():PlexusManager {
    if (_instance == null) {
      _instance = new PlexusManager();
    }

    return _instance;
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
}