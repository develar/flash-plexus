package org.flyti.plexus
{
import org.flyti.lang.Enum;

[DefaultProperty("requirements")]
public class ComponentDescriptor
{
	public var role:Class;
	public var roleHint:Enum = RoleHint.DEFAULT;
	
	public var implementation:Class;

	public var requirements:Vector.<Requirement>;
}
}