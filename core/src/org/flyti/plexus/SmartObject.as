package org.flyti.plexus {
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import org.flyti.plexus.actionLists.IScope;
import org.flyti.plexus.actionLists.ScopeProperties;

/**
 * The Smart Objects can be used within the <code>IActionList</code>.
 * These objects expose temporary data such as the current event,
 * the value returned by a <code>MethodInvoker</code> or the result of a server call.
 */
public dynamic final class SmartObject extends Proxy implements ISmartObject {
  /**
   * A list of properties that has been accessed using the dot operator.
   * For example, if you a access an inner property like this:
   * myObject.property1.property2, the chain is equivalent to an array
   * with 2 items [property1,property2]
   */
  private var chain:Vector.<String>;

  /**
   * This is a string that refer to the name of the source that will be used in
   * the method <code>getValue</code>.
   * The possible values are:
   * <ul>
   * <li>event</li>
   * <li>currentEvent</li>
   * <li>result</li>
   * <li>fault</li>
   * <li>lastReturn</li>
   * <li>scope</li>
   * <li>message</li>
   * <li>data</li>
   * </ul>
   */
  private var source:String;

  public function SmartObject(source:String = null, chain:Vector.<String> = null):void {
    this.source = source;
    this.chain = chain;
  }

  /**
   * Returns the string representation of the specified object.
   */
  public function toString():String {
    return chain == null ? source : source + "." + chain.join(".");
  }

  public function valueOf():Object {
    return this;
  }

  /**
   * Overrides any request for a property's value. If the property can't be found,
   * the method returns undefined. For more information on this behavior,
   * see the ECMA-262 Language Specification, 3rd Edition, section 8.6.2.1.
   */
  override flash_proxy function getProperty(name:*):* {
    var n:int = chain == null ? 0 : chain.length;
    var newChain:Vector.<String> = new Vector.<String>(n + 1, true);
    for (var i:int = 0; i < n; i++) {
      newChain[i] = chain[i];
    }
    newChain[n] = name is QName ? QName(name).localName : name;

    return new SmartObject(source, newChain);
  }

  public final function getValue(scope:IScope, debugCall:Boolean = false):Object {
    var realSource:Object = source != ScopeProperties.SCOPE ? scope[source] : scope;
    if (realSource != null) {
      if (chain == null) {
        return realSource;
      }
      else {
        var currentSource:Object = realSource;
        for each (var property:String in chain) {
          if (currentSource == null) {
            break;
          }

          currentSource = currentSource[property];
        }
        return currentSource;
      }
    }
    else if (!debugCall) {
      throw new ReferenceError("source null");
    }
    else {
      return null;
    }
  }
}
}