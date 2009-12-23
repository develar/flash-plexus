package org.flyti.plexus
{
import org.flyti.lang.Enum;

public class Requirement
{
	public var role:Class;
	public var roleHint:Enum = RoleHint.DEFAULT;

	public var field:String;
}
}