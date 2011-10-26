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
package org.flyti.plexus.actions
{
import org.flyti.plexus.ISmartObject;
import org.flyti.plexus.actionLists.IScope;

/**
 * The DataSaver tag allows you to save values into some object. A possible storage is the "data" object available while the <code>IActionList</code> is running.
 * <p>The DataSaver tags is a handy tag to quickly save values into some storage.
 * You can use the <code>IActionList</code> "data" as a temporary storage from where action that follow in the <code>IActionList</code> can read values.
 * You can also use some other external variable as the storage.</p>
 */
public class DataCopier extends AbstractAction implements IAction
{
	private var _destinationKey:String;
	/**
	 *  If you want to set the value of a property of the destination object, instead of the destination itself,
	 * you need to specify this attribute.
	 */
	public function get destinationKey():String
	{
		return _destinationKey;
	}

	public function set destinationKey(value:String):void
	{
		_destinationKey = value;
	}

	private var _sourceKey:String;
	/**
	 *  If you need a property from the source instead of the source itself, you need to specify this attribute.
	 */
	public function get sourceKey():String
	{
		return _sourceKey;
	}

	public function set sourceKey(value:String):void
	{
		_sourceKey = value;
	}

	private var _destination:Object;
	/**
	 *  The destination attribute specifies where to store the data coming from the source. It can be one of this options:
	 * event, data, result, or another object.
	 */
	public function get destination():Object
	{
		return _destination;
	}

	[Inspectable(enumeration="event,data,result")]
	public function set destination(value:Object):void
	{
		_destination = value;
	}

	private var _source:Object;
	/**
	 *  The source attribute specifies where to get the data to copy from. It can be one of this options:
	 * event, data, result, fault, lastReturn, message, scope, or another object.
	 */
	public function get source():Object
	{
		return _source;
	}

	[Inspectable(enumeration="event,data,result,fault,lastReturn,message,scope")]
	public function set source(value:Object):void
	{
		_source = value;
	}

	override protected function run(scope:IScope):void
	{
		var realSource:Object = getRealObject(source, scope);
		var realDestination:Object = getRealObject(destination, scope);

		if (destinationKey != null)
		{
			realDestination[destinationKey] = sourceKey != null ? realSource[sourceKey] : realSource;
		}
		else
		{
			realDestination = sourceKey != null ? realSource[sourceKey] : realSource;
		}

		scope.lastReturn = null;
	}

	/**
	 *  Helper function to get the source or destination objects
	 * from either a String value, a SmartObject or other.
	 */
	protected function getRealObject(object:Object, scope:IScope):Object
	{
		if (object is Function)
		{
			object = (object as Function)();
		}

		if (object is Class)
		{
			return scope.eventMap.container.lookup((Class(object)));
		}
		else if (object is ISmartObject)
		{
			return ISmartObject(object).getValue(scope);
		}
		else if (object is String)
		{
			return scope[object];
		}
		else
		{
			return object;
		}
	}
}
}
