package org.flyti.plexus.component
{
import org.flyti.lang.Enum;

[DefaultProperty("requirements")]
public class ComponentDescriptor
{
	public var role:Class;
	public var roleHint:Enum = RoleHint.DEFAULT;
	
	public var implementation:Class;

	public var requirements:Vector.<ComponentRequirement>;

	public var instantiationStrategy:InstantiationStrategy = InstantiationStrategy.KEEP_ALIVE;

//	public var configurationKey:String;
}
}