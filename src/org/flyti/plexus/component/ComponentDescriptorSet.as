package org.flyti.plexus.component {
import org.flyti.plexus.PlexusManager;

[DefaultProperty("components")]
public class ComponentDescriptorSet {
  public function set components(value:Vector.<ComponentDescriptor>):void {
    PlexusManager.instance.componentDescriptorRegistry.add(value);
  }
}
}