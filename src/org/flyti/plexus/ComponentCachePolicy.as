package org.flyti.plexus
{
public class ComponentCachePolicy
{
	/**
	 * Does not use cache.
	 * */
	public static const NONE:String = "none";

	/**
	 * Local cache, it is the one that lives in the EventMap
	 */
	public static const LOCAL:String = "local";

	/**
	 * Global cache
	 */
	public static const GLOBAL:String = "global";

	/**
	 * Use same cache type that is defined in the EventMap.
	 * Can be either local or global
	 */
	public static const INHERIT:String = "inherit";
}
}