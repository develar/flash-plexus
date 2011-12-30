package org.flyti.plexus.actionLists {
import org.flyti.plexus.events.InjectorEvent;

/**
 * An <code>Injectors</code> defined in the <code>EventMap</code> will run whenever an instance of the
 * class specified in the <code>Injectors</code>'s "target" argument is created.
 */
public class Injectors extends AbstractHandlers {
  public var target:Class;
  public var targetId:String;

  public function fire(injectorEvent:InjectorEvent):void {
    var currentScope:Scope = new Scope(injectorEvent, map, inheritedScope);
    currentScope.owner = this;
    setScope(currentScope);
    runSequence(currentScope, actions);
  }
}
}