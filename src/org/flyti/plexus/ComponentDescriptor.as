package org.flyti.plexus
{
import com.asfusion.mate.componentMap.*;

[DefaultProperty("requirements")]
public class ComponentDescriptor
{
	public var role:Class;
	public var implementation:Class;

	public var requirements:Vector.<Requirement>;
}
}