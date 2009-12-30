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

package com.asfusion.mate.actions.builders
{
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.actions.AbstractServiceInvoker;

/**
 * This base <code>ServiceInvokerBuilder</code> class is very similar
 * to <code>AbstractServiceInvoker</code> with the difference that it
 * also supports the <code>IBuilder</code> interface that will allow
 * creating an object using a <code>generator</code> class.
 */
public class ServiceInvokerBuilder extends AbstractServiceInvoker implements IBuilder
{
	private var _role:Class;
	public function get role():Class
	{
		return _role;
	}
	public function set role(value:Class):void
	{
		_role = value;
	}

	private var _constructorArguments:Array;
	/**
	 *  The constructorArgs allows you to pass an Object or an Array of objects to the contructor
	 *  when the instance is created.
	 */
	public function set constructorArguments(value:Array):void
	{
		_constructorArguments = value;
	}

	private var _registerTarget:Boolean = true;
	/**
	 * Registers the newly created object as an injector target. If true, this allows this object to be injected
	 * with properties using the <code>Injectors</code> tags.
	 */
	[Inspectable(enumeration="true,false")]
	public function set registerTarget(value:Boolean):void
	{
		_registerTarget = value;
	}

	/**
	 * Where the currentInstance is created using the
	 * <code>generator</code> class as the template, passing arguments to the constructor
	 * as specified by the <code>constructorArgs</code> (if any).
	 */
	protected function createInstance(scope:IScope):Object
	{
		currentInstance = scope.eventMap.container.lookup(role, null, _constructorArguments);

		return currentInstance;
	}

	override protected function prepare(scope:IScope):void
	{
		super.prepare(scope);
		createInstance(scope);
	}

	override protected function run(scope:IScope):void
	{
		scope.lastReturn = currentInstance;
	}
}
}