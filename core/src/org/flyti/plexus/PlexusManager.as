package org.flyti.plexus {
import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;

import org.flyti.plexus.component.ComponentDescriptorRegistry;

public final class PlexusManager {
  private static var _instance:PlexusManager;

  public function PlexusManager() {
    _componentDescriptorRegistry = new ComponentDescriptorRegistry();
    _container = new DefaultPlexusContainer(createIfApplicable(), _componentDescriptorRegistry);
  }

  private static function createIfApplicable():IEventDispatcher {
    var applicationDomain:ApplicationDomain = ApplicationDomain.currentDomain;
    if (!applicationDomain.hasDefinition("mx.managers.SystemManagerGlobals")) {
      return null;
    }

    var systemManager:Object = applicationDomain.getDefinition("mx.managers.SystemManagerGlobals").topLevelSystemManagers[0];
    if (applicationDomain.hasDefinition("mx.managers.SystemManager") && systemManager is Class(applicationDomain.getDefinition("mx.managers.SystemManager"))) {
      return new (applicationDomain.getDefinition("org.flyti.plexus.GlobalDispatcher"))(systemManager);
    }
    else {
      return null;
    }
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
}
}