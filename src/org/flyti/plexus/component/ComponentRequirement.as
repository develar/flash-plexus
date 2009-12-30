package org.flyti.plexus.component
{
import org.flyti.plexus.*;
import org.flyti.lang.Enum;

public class ComponentRequirement
{
	public var role:Class;
	public var roleHint:Enum = RoleHint.DEFAULT;

	public var field:String;
}
}