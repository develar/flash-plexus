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
import org.flyti.plexus.IProperty;
import org.flyti.plexus.actionLists.IScope;

[DefaultProperty("properties")]
/**
 * BaseAction is the base class for all the <code>IAction</code>s that have Properties
 */
public class BaseAction extends AbstractAction
{
	private var _properties:Vector.<IProperty>;
	/**
	 *  <code>Properties</code> allows you to add properties to the <code>currentInstance</code>.
	 *  These properties will be set before performing any action
	 *  so you can be sure that those properties will be available when an action is performed.
	 *  These properties must be public.
	 *	 <p>The <code>Properties</code> property is usually specified by using the <em>Properties</em> tag.</p>
	 */
	public function get properties():Vector.<IProperty>
	{
		return _properties;
	}

	public function set properties(value:Vector.<IProperty>):void
	{
		_properties = value;
	}

	override protected function setProperties(scope:IScope):void
	{
		super.setProperties(scope);

		for each (var propertySetter:IProperty in properties)
		{
			propertySetter.setProperties(currentInstance, scope);
		}
	}
}
}
