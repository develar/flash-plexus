package org.flyti.plexus.actions {
import flash.events.IEventDispatcher;

import org.flyti.plexus.ISmartObject;
import org.flyti.plexus.Uninjectable;
import org.flyti.plexus.actionLists.IScope;
import org.flyti.plexus.events.InjectorEvent;

/**
 * PropertyInjector sets a value from an object (source) to a destination (target).
 * If the source key is bindable, the PropertyInjector will bind
 * the source to the targetKey. Otherwise, it will only set the property once.
 */
public class PropertyInjector extends AbstractAction implements IAction {
  private var _targetKey:String;
  /**
   * The name of the property that the injector will set in the target object
   */
  public function set targetKey(value:String):void {
    _targetKey = value;
  }
  
  private var _target:Class;
  public function set target(value:Class):void {
    _target = value;
  }

  private var _targetId:String;
  /**
   * This tag will run if any of the following statements is true:
   * If the targetId is null.
   * If the id of the target matches the targetId.
   *
   * Note:Target is the instance of the target class.
   */
  public function set targetId(value:String):void {
    _targetId = value;
  }

  private var _source:Object;
  /**
   * An object that contains the data that the injector will use to set the target object
   * */
  public function set source(value:Object):void {
    _source = value;
  }

  private var _sourceKey:String;
  /**
   * The name of the property on the source object that the injector will use to read and set on the target object
   */
  public function set sourceKey(value:String):void {
    _sourceKey = value;
  }

  private var _changeEventType:String;
  public function set changeEventType(value:String):void {
    _changeEventType = value;
  }

  override protected function prepare(scope:IScope):void {
    if (_targetId == null || _targetId == InjectorEvent(scope.event).uid) {
      if (_source is Class) {
        currentInstance = scope.eventMap.container.lookup(Class(_source));
      }
      else {
        if (_source is ISmartObject) {
          currentInstance = ISmartObject(_source).getValue(scope);
        }
        else if (_source == null) {
          assert(_target != null);
          currentInstance = InjectorEvent(scope.event).instance;
        }
        else {
          currentInstance = _source;
        }
      }
    }
  }

  override protected function run(scope:IScope):void {
    var event:InjectorEvent = InjectorEvent(scope.event);
    if (_targetId != null && _targetId != event.uid) {
      return;
    }
    
    var targetKey:String = _targetKey == null ? _sourceKey : _targetKey;
    var target:Object = _target == null ? event.instance : scope.eventMap.container.lookup(_target);
    if (_sourceKey == null) {
      target[targetKey] = currentInstance;
    }
    else if (currentInstance is IEventDispatcher) {
      var sourceKeys:Array = _sourceKey.split(".");
      if (_targetKey == null) {
        targetKey = sourceKeys[sourceKeys.length - 1];
      }
      
      var watcher:ChangeWatcher = ChangeWatcher.watch(IEventDispatcher(currentInstance), sourceKeys, target, targetKey, _changeEventType);
      if (target is Uninjectable) {
        Uninjectable(target).addWatcher(watcher);
      }
    }
    else {
      target[targetKey] = currentInstance[_sourceKey];
    }
  }
}
}