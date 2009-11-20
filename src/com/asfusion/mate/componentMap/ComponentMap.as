package com.asfusion.mate.componentMap
{
import org.flyti.util.HashMap;
import org.flyti.util.Map;

[DefaultProperty("components")]
public class ComponentMap
{
	private static const map:Map/*<Class,Component>*/ = new HashMap(true);

	/**
	 * Мы разрешаем иметь в качестве role конкретный класс, а не интерфейс, и не указывать implementation
	 */
	public function set components(value:Vector.<Component>):void
	{
		for each (var component:Component in value)
		{
			if (component.implementation == null)
			{
				component.implementation = component.role;
			}

			if (map.containsKey(component.role))
			{
				var existingComponent:Component = Component(map.get(component.role));
				existingComponent.implementation = component.implementation;
				if (component.requirements != null)
				{
					existingComponent.requirements = component.requirements;
				}
			}
			else
			{
				map.put(component.role, component);
			}
		}
	}

	public static function has(role:Class):Boolean
	{
		return map.containsKey(role);
	}

	public static function get(role:Class):Component
	{
		return Component(map.get(role));
	}
}
}