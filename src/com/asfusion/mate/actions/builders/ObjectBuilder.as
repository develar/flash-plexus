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
import com.asfusion.mate.actions.BaseAction;
import com.asfusion.mate.actions.IAction;
import com.asfusion.mate.core.mate;

import org.flyti.plexus.component.ComponentCachePolicy;
import org.flyti.plexus.component.RoleHint;

use namespace mate;

/**
 * ObjectBuilder is the base class for all the classes that use the <code>generator</code> property
 * to create instances. The <code>generator</code> is the class template to use to instantiate new objects.
 */
public class ObjectBuilder extends BaseAction implements IAction, IBuilder
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

	protected var _constructorArguments:Array;
	/**
	 *  The constructorArgs allows you to pass an Object or an Array of objects to the contructor
	 *  when the instance is created.
	 *  <p>You can use an array to pass multiple arguments or use a simple Object if your
	 * signature has only one parameter.</p>
	 */
	public function set constructorArguments(value:Array):void
	{
		_constructorArguments = value;
	}

	private var _cache:String = ComponentCachePolicy.INHERIT;
	/**
	 * The cache attribute lets you specify whether this newly created object should be kept live
	 * so that the next time an instance of this class is requested, this already created object
	 * is returned instead.
	 */
	[Inspectable(enumeration="local,global,inherit,none")]
	public function set cache(value:String):void
	{
		_cache = value;
	}

	private var _registerTarget:Boolean = true;
	/**
	 * Registers the newly created object as an injector target. If true, this allows this object to be injected
	 * with properties using the <code>Injectors</code> tags.
	 */
	public function get registerTarget():Boolean
	{
		return _registerTarget;
	}

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
		if (_cache == ComponentCachePolicy.NONE)
		{
			currentInstance = new role();
		}
		else
		{
			currentInstance = scope.eventMap.container.lookup(role, RoleHint.DEFAULT, _constructorArguments == null ? null : getRealArguments(scope, _constructorArguments));
		}

		return currentInstance;
	}

	override protected function prepare(scope:IScope):void
	{
		createInstance(scope);
	}

	override protected function run(scope:IScope):void
	{
		scope.lastReturn = currentInstance;
	}
}
}
