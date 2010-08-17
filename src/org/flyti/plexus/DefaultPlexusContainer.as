package org.flyti.plexus {
import flash.errors.IllegalOperationError;
import flash.events.IEventDispatcher;

import org.flyti.lang.Enum;
import org.flyti.plexus.actionLists.Injectors;
import org.flyti.plexus.component.ComponentDescriptor;
import org.flyti.plexus.component.ComponentDescriptorRegistry;
import org.flyti.plexus.component.ComponentRequirement;
import org.flyti.plexus.component.InstantiationStrategy;
import org.flyti.plexus.component.RoleHint;
import org.flyti.plexus.configuration.Configurable;
import org.flyti.plexus.configuration.ConfigurationManager;
import org.flyti.plexus.events.InjectorEvent;

use namespace plexus;

/**
 * Компонент кешируется там, где его дескриптор (http://juick.com/develar/450898)
 * Так как на данный момент для компонента может отсутствовать дескриптор (он тупо как роль в EventMap),
 * то если мы не нашли дескриптор для него ни у себя, ни в родительских контейнерах — кешируем его у себя
 */
public class DefaultPlexusContainer implements PlexusContainer {
  private var componentDescriptorRegistry:ComponentDescriptorRegistry;
  private var cache:ComponentCache = new ComponentCache();

  private var _parentContainer:PlexusContainer;
  public function get parentContainer():PlexusContainer {
    return _parentContainer;
  }

  public function set parentContainer(value:PlexusContainer):void {
    _parentContainer = value;
  }

  public function DefaultPlexusContainer(dispatcher:IEventDispatcher, componentDescriptorRegistry:ComponentDescriptorRegistry = null, injectors:Vector.<Injectors> = null) {
    if (dispatcher != null) {
      this.dispatcher = dispatcher;
    }
    this.componentDescriptorRegistry = componentDescriptorRegistry;

    _injectors = injectors == null ? new Vector.<Injectors>() : injectors;
  }

  private function injectHandler(event:InjectorEvent):void {
    checkInjectors(event);
  }

  private var _dispatcher:IEventDispatcher;
  public function get dispatcher():IEventDispatcher {
    return _dispatcher;
  }

  public function set dispatcher(value:IEventDispatcher):void {
    if (_dispatcher != null) {
      throw new IllegalOperationError("already set");
    }

    _dispatcher = value;
    _dispatcher.addEventListener(InjectorEvent.INJECT, injectHandler);
  }

  private var _injectors:Vector.<Injectors>;
  public function get injectors():Vector.<Injectors> {
    return _injectors;
  }

  public function getComponentDescriptor(role:Class, roleHint:Enum):ComponentDescriptor {
    return componentDescriptorRegistry == null ? null : componentDescriptorRegistry.get(role, roleHint);
  }

  public function lookup(role:Class, roleHint:Enum = null, constructorArguments:Array = null):Object {
    if (roleHint == null) {
      roleHint = RoleHint.DEFAULT;
    }

    var componentDescriptor:ComponentDescriptor = getComponentDescriptor(role, roleHint);
    if (componentDescriptor == null) {
      var currentContainer:PlexusContainer = _parentContainer;
      while (currentContainer != null) {
        componentDescriptor = currentContainer.getComponentDescriptor(role, roleHint);
        if (componentDescriptor != null) {
          return currentContainer.lookup(role, roleHint);
        }
        else {
          currentContainer = currentContainer.parentContainer;
        }
      }
    }

    var instance:Object = cache.get(role, roleHint);
    if (instance != null) {
      return instance;
    }

    var requirement:ComponentRequirement;
    var requiredComponent:Object;
    var useSetterInjection:Boolean;
    var implementation:Class;
    if (componentDescriptor == null) {
      implementation = role;
    }
    else {
      implementation = componentDescriptor.implementation;
      // компонент может использовать только или setter, или constructor injection — но не оба разом
      if (componentDescriptor.requirements != null) {
        useSetterInjection = componentDescriptor.requirements[0].field == null;
        if (!useSetterInjection) {
          assert(constructorArguments == null);
          const n:int = componentDescriptor.requirements.length;
          constructorArguments = new Array(n);
          for (var i:int = 0; i < n; i++) {
            requirement = componentDescriptor.requirements[i];
            requiredComponent = cache.get(requirement.role, requirement.roleHint);
            if (requiredComponent == null) {
              requiredComponent = lookup(requirement.role, requirement.roleHint);
            }
            constructorArguments[i] = requiredComponent;
          }
        }
      }
    }

    instance = createInstance(implementation, constructorArguments);
    const perLookup:Boolean = componentDescriptor != null && componentDescriptor.instantiationStrategy == InstantiationStrategy.PER_LOOKUP;
    if (!perLookup) {
      cache.put(role, roleHint, instance);
    }

    if (instance is PlexusContainerRecipient) {
      PlexusContainerRecipient(instance).container = this;
    }

    if (useSetterInjection) {
      for each (requirement in componentDescriptor.requirements) {
        requiredComponent = cache.get(requirement.role, requirement.roleHint);
        if (requiredComponent == null) {
          requiredComponent = lookup(requirement.role, requirement.roleHint);
        }
        instance[requirement.field] = requiredComponent;
      }
    }

    if (!perLookup && instance is Injectable) {
      var injectorEvent:InjectorEvent = new InjectorEvent(instance);
      checkInjectors(injectorEvent);
    }

    if (instance is Configurable) {
      var globalContainer:PlexusContainer = _parentContainer == null ? this : _parentContainer;
      var configurationManager:ConfigurationManager = ConfigurationManager(globalContainer.lookup(ConfigurationManager));
      configurationManager.configurate(Configurable(instance), role);
    }

    return instance;
  }

  public function composeComponent(instance:Object, role:Class = null, roleHint:Enum = null):void {
    if (role == null) {
      role = instance.constructor;
    }
    if (roleHint == null) {
      roleHint = RoleHint.DEFAULT;
    }

    var componentDescriptor:ComponentDescriptor = getComponentDescriptor(role, roleHint);
    if (componentDescriptor != null && componentDescriptor.requirements != null) {
      composeComponent2(instance, componentDescriptor);
    }
  }

  public function composeComponent2(instance:Object, componentDescriptor:ComponentDescriptor):void {
    for each (var requirement:ComponentRequirement in componentDescriptor.requirements) {
      var requiredComponent:Object = cache.get(requirement.role, requirement.roleHint);
      if (requiredComponent == null) {
        requiredComponent = lookup(requirement.role, requirement.roleHint);
      }
      instance[requirement.field] = requiredComponent;
    }
  }

  public function checkInjectors(injectorEvent:InjectorEvent):void {
    for each (var injector:Injectors in injectors) {
      if ((injector.targetId == null || injectorEvent.uid == injector.targetId) && injectorEvent.instance is injector.target) {
        injector.fire(injectorEvent);
      }
    }

    /* концепция такова, что каждый контейнер слушает некий объект в display list, и получает InjectorEvent посредством баблинга
     должен ли контейнер, первым поймавший InjectorEvent событие, полагаться на этот механизм, или же удобнее если дальше событие идет по его иерархии?
     нам на данный момент удобно второе — первый контейнер поймавший InjectorEvent, останавливает событие и обрабатывает по своей иерархии
     (к тому же у нас два, еще не разделенных типа injector target — компонент (может быть вне display list)) и display object. */
    injectorEvent.stopImmediatePropagation();
    if (_parentContainer != null) {
      _parentContainer.checkInjectors(injectorEvent);
    }
  }

  private function createInstance(template:Class, p:Array):Object {
    if (p == null || p.length == 0) {
      return new template();
    }
    else {
      switch (p.length) {
        case 1: return new template(p[0]);
        case 2: return new template(p[0], p[1]);
        case 3: return new template(p[0], p[1], p[2]);
        case 4: return new template(p[0], p[1], p[2], p[3]);
        case 5: return new template(p[0], p[1], p[2], p[3], p[4]);
      }

      throw new ArgumentError("constructorArguments is too long");
    }
  }
}
}