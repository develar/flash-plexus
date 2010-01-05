package org.flyti.plexus.component
{
import flash.utils.Dictionary;

import org.flyti.lang.Enum;

/**
 * Мы разрешаем иметь в качестве role конкретный класс, а не интерфейс, и не указывать implementation.
 * Если будет добавлен дескриптор с теми же координатами — role&roleHint, то: если у добавляемого есть requirements, то они заменят requirements существующего, если же их нету, то будут оставлены те, что уже есть.
 */
public class ComponentDescriptorRegistry
{
	private const map:Dictionary/*<Enum role hint, Dictionary of ComponentDescriptor>*/ = new Dictionary();

	public function add(componentDescriptors:Vector.<ComponentDescriptor>):void
	{
		for each (var componentDescriptor:ComponentDescriptor in componentDescriptors)
		{
			if (componentDescriptor.implementation == null)
			{
				componentDescriptor.implementation = componentDescriptor.role;
			}

			var descriptorMap:Dictionary;
			if (componentDescriptor.roleHint in map)
			{
				descriptorMap = map[componentDescriptor.roleHint];
			}
			else
			{
				descriptorMap = new Dictionary();
				map[componentDescriptor.roleHint] = descriptorMap;
			}

			var existingComponent:ComponentDescriptor = descriptorMap[componentDescriptor.role];
			if (existingComponent != null)
			{
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

	public function get(role:Class, roleHint:Enum):ComponentDescriptor
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