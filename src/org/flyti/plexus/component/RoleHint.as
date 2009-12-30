package org.flyti.plexus.component
{
import org.flyti.lang.Enum;

public final class RoleHint extends Enum
{
	public static const DEFAULT:RoleHint = new RoleHint("default");

	public function RoleHint(name:String)
	{
		super(name);
	}
}
}