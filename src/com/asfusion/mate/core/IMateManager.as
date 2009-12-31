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
package com.asfusion.mate.core
{
import com.asfusion.mate.utils.debug.IMateLogger;

import flash.events.IEventDispatcher;

import mx.logging.ILoggingTarget;

import org.flyti.plexus.PlexusContainerProvider;

public interface IMateManager extends IEventDispatcher, PlexusContainerProvider
{
	/**
	 * An <code>ILoggingTarget</code> used by debugging purpose.
	 */
	function set debugger(value:ILoggingTarget):void;

	function get debugger():ILoggingTarget;

	/**
	 * An <code>IMateLogger</code> used to log errors.
	 * Similar to Flex <code>ILogger</code>
	 */
	function getLogger(active:Boolean):IMateLogger;
}
}