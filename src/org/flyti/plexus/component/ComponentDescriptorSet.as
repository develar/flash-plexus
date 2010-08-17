package org.flyti.plexus.component {
import org.flyti.plexus.MateManager;

[DefaultProperty("components")]
public class ComponentDescriptorSet {
  public function set components(value:Vector.<ComponentDescriptor>):void {
    MateManager.instance.componentDescriptorRegistry.add(value);
  }
}
}