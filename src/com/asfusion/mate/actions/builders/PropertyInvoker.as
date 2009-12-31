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

/**
	* When placed inside a <code>IActionList</code> tag and the list is executed, 
	* <code>PropertyInvoker</code> will create an object of the class specified in the <code>generator</code> attribute.
	* It will then call the getter specified in the <code>property</code> attribute on the newly created object.
	* Unless you specify cache="none", this <code>MethodInvoker</code> instance will be "cached" and not instantiated again.
	* 
    * 
	* @mxml
 	* <p>The <code>&lt;PropertyInvoker&gt;</code> tag has the following tag attributes:</p>
 	* <pre>
	* &lt;PropertyInvoker
 	* <b>Properties</b>
	* generator="Class"
	* constructorArgs="Object|Array"
	* properties="Properties"
	* property="String"
	* cache="local|global|inherit|none"
 	* /&gt;
	* </pre>
	* 
	* @see com.asfusion.mate.actionLists.EventHandlers
	*/
	public class PropertyInvoker extends ObjectBuilder
	{

		/*-----------------------------------------------------------------------------------------------------------
		*                                         Public Getters and Setters
		-------------------------------------------------------------------------------------------------------------*/
		
		/*-.........................................property..........................................*/
		private var _property:String;
		/**
		 * The function to call on the created object.
		 *
		 *  @default null
		 */
		public function get property():String
		{
			return _property;
		}
		
		public function set property(value:String):void
		{
			_property = value;
		}
		
		
		
		/*-----------------------------------------------------------------------------------------------------------
		*                                          Override protected methods
		-------------------------------------------------------------------------------------------------------------*/
		
		/*-.........................................run..........................................*/
		/**
		 * @inheritDoc
		 */
		override protected function run(scope:IScope):void
		{
			if(property != null)
			{
				scope.lastReturn = currentInstance[property];
			}
			else
			{
//				var logInfo:LogInfo = new LogInfo( scope, currentInstance, null, null, this.arguments);
//				scope.getLogger().error(LogTypes.METHOD_UNDEFINED, logInfo);
			}
		}
	}
}