/*
 Copyright 2008 Nahuel Foronda/AsFusion

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. Y
 ou may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, s
 oftware distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and limitations under the License

 Author: Nahuel Foronda, Principal Architect
 nahuel at asfusion dot com

 @ignore
 */
package org.flyti.plexus
{
import org.flyti.plexus.actionLists.IScope;
import org.flyti.plexus.actions.builders.Request;

/**
 * <code>Properties</code> tag allows you to add properties to an object.
 * <p>These properties can be a mix of SmartObject and normal Objects.
 * All the <code>SmartObject</code>s will be parsed before the properties are set.
 * These properties must be public.</p>
 */
public dynamic class Properties implements IProperty
{
	/**
	 *  If you need to specify a property that is called "id", you need
	 * to use <code>_id</code> instead because Flex will normally use the <code>id</code>
	 * property as the identifier for this tag.
	 */
	public var _id:Object;

	/**
	 * This method will parse all the SmartObjects and set the real values in the
	 * <code>target</code> Object
	 */
	public static function smartCopy(source:Object, target:Object, scope:IScope):Object
	{
		for (var propertyName:String in source)
		{
			var realValue:Object = source[propertyName];
			if (realValue is ISmartObject)
			{
				realValue = ISmartObject(realValue).getValue(scope);
			}
			target[propertyName] = realValue;
		}

		if (source is Request)
		{
			var sourceRequest:Request = Request(source);
			if (sourceRequest._id != null)
			{
				target['id'] = sourceRequest._id;
			}
		}

		return target;
	}

	/**
	 * Similar to <code>smartCopy</code> this method will copy the properties
	 * to the target object.
	 * The difference is that it will copy its own properties to the target.
	 */
	public function setProperties(target:Object, scope:IScope):Object
	{
		return smartCopy(this, target, scope);
	}
}
}
