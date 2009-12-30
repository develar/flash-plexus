package org.flyti.plexus
{
import flash.utils.Dictionary;

import org.flyti.lang.Enum;
import org.flyti.plexus.component.ComponentDescriptor;

[DefaultProperty("components")]
public class ComponentDescriptorRegistry
{
	private static const map:Dictionary/*<Enum role hint, Dictionary of ComponentDescriptor>*/ = new Dictionary();

	/**
	 * Мы разрешаем иметь в качестве role конкретный класс, а не интерфейс, и не указывать implementation
	 */
	public function set components(value:Vector.<ComponentDescriptor>):void
	{
		for each (var componentDescriptor:ComponentDescriptor in value)
		{
			if (componentDescriptor.implementation == null)
			{
				componentDescriptor.implementation = componentDescriptor.role;
			}

			var descriptorMap:Object;
			if (componentDescriptor.roleHint in map)
			{
				descriptorMap = map[componentDescriptor.roleHint];
			}
			else
			{
				descriptorMap = new Dictionary();
				map[componentDescriptor.roleHint] = descriptorMap;
			}

			if (componentDescriptor.role in descriptorMap)
			{
				var existingComponent:ComponentDescriptor = get(componentDescriptor.role, componentDescriptor.roleHint);
				existingComponent.implementation = componentDescriptor.implementation;
				if (componentDescriptor.requirements != null)
				{
					existingComponent.requirements = componentDescriptor.requirements;
				}
			}
			else
			{
				descriptorMap[componentDescriptor.role] = componentDescriptor;
			}
		}
	}

	public static function get(role:Class, roleHint:Enum):ComponentDescriptor
	{
		var descriptorMap:Dictionary = map[roleHint];
		if (descriptorMap == null)
		{
			return null;
		}
		else
		{
			return descriptorMap[role];
		}
	}
}
}