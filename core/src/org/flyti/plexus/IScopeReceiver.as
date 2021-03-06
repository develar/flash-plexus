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

/**
	 * An interface that allows implementors to receive the <code>scope</code> property from the <code>IActionList</code>
	 */
	public interface IScopeReceiver
	{
		/**
		 * scope that is set by the <code>IActionList</code>
		 */
		function get scope():IScope;
		function set scope(value:IScope):void;
	}
}