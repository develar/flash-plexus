package org.flyti.plexus {
import flash.events.IEventDispatcher;

import org.flyti.lang.Enum;
import org.flyti.plexus.actionLists.Injectors;
import org.flyti.plexus.component.ComponentDescriptor;
import org.flyti.plexus.events.InjectorEvent;

public interface PlexusContainer {
  function get dispatcher():IEventDispatcher;

  function set dispatcher(value:IEventDispatcher):void;

  function get injectors():Vector.<Injectors>;

  function get parentContainer():PlexusContainer;

  function set parentContainer(value:PlexusContainer):void;

  function getComponentDescriptor(role:Class, roleHint:Enum):ComponentDescriptor;

  function checkInjectors(injectorEvent:InjectorEvent):void;

  function lookup(role:Class, roleHint:Enum = null, constructorArguments:Array = null):Object;

  /**
   * Диалоговое окно создается до момента создания его локальной event map, а в ней может быть настройка компонента диалогового окна — requirements.
   * Только в текущем контейнере.
   */
  function composeComponent(instance:Object, role:Class = null, roleHint:Enum = null):void;
}
}