package org.flyti.plexus.configuration {
import cocoa.util.ObjectUtil;
import cocoa.util.StringUtil;

import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;

import mx.utils.DescribeTypeCache;

import org.flyti.plexus.plexus;
import org.flyti.util.HashMap;
import org.flyti.util.Map;

use namespace plexus;

public class ConfigurationManager {
  private var configuration:Dictionary;

  public function setConfiguration(data:XML):void {
    configuration = new Dictionary();
    for each (var object:XML in data.object) {
      configuration[String(object.@type)] = object;
    }
  }

  public function configurate(instance:Configurable, role:Class):void {
    var className:String = ObjectUtil.getClassName(role);
    var data:XML = configuration[className];
    if (data != null) {
      createObject2(instance, data);
    }
    else {
      trace("Configuration not found for " + className);
    }
  }

  private function createObject(clazz:Class, data:XML):Object {
    var object:Object = new clazz();
    createObject2(object, data);
    return object;
  }

  private function createObject2(parentObject:Object, data:XML):void {
    for each (var child:XML in data.children()) {
      const propertyName:String = String(child.name());
      if (child.hasSimpleContent()) {
        parentObject[propertyName] = child;
      }
      else {
        var typeDescription:XML = DescribeTypeCache.describeType(parentObject).typeDescription;
        var propertyClassName:String = typeDescription.variable.(@name == propertyName).@type;
        if (propertyClassName == "") {
          propertyClassName = typeDescription.accessor.(@name == propertyName).@type;
        }

        const propertyClass:Class = Class(getDefinitionByName(propertyClassName));
        var valueClass:Class;
        if (StringUtil.startsWith(propertyClassName, "__AS3__.vec::")) {
          valueClass = Class(getDefinitionByName(propertyClassName.slice(propertyClassName.indexOf("<") + 1, -1)));
          parentObject[propertyName] = mapVector(valueClass, Class(getDefinitionByName(propertyClassName)), child);
        }
        else if (propertyClass == Map) {
          var parentObjectClass:Class = Class(parentObject.constructor);
          parentObject[propertyName] = mapMap(getClass(parentObjectClass, propertyName + "ValueType"), child);
        }
        else {
          parentObject[propertyName] = createObject(propertyClass, child);
        }
      }
    }
  }

  /**
   * in или hasOwnProperties не работают для статических сеттеров, поэтому мы просто берем по имени и сравниваем с undefined
   */
  private function getClass(parentClass:Class, name:String):Class {
    return parentClass[name] === undefined ? String : parentClass[name];
  }

  private function mapMap(valueClass:Class, data:XML):Map {
    var dictionary:Dictionary = new Dictionary();
    var entry:XML;
    var entries:XMLList = data.children();
    if (entries[0].hasSimpleContent()) {
      for each (entry in entries) {
        dictionary[entry.name().toString()] = entry.toString();
      }
    }
    else {
      for each (entry in entries) {
        dictionary[entry.name().toString()] = createObject(valueClass, entry);
      }
    }

    return new HashMap(false, dictionary, entries.length());
  }

  private function mapVector(valueClass:Class, vectorClass:Class, data:XML):Object {
    var elements:XMLList = data.children();
    const n:int = elements.length();
    var vector:Object = new vectorClass(n, true);
    var i:int = 0;
    if (elements[i].hasSimpleContent()) {
      for (; i < n; i++) {
        vector[i] = elements[i].toString();
      }
    }
    else {
      for (; i < n; i++) {
        vector[i] = createObject(valueClass, elements[i]);
      }
    }

    return vector;
  }
}
}