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
	
	/**
	 * <code>MateManager</code> is in charge of returning an instance of the
	 * <code>IMateManager</code> that is one of the core classes of Mate.
	 */
	public class MateManager
	{
		
		//-----------------------------------------------------------------------------------------------------------
        //                                          Public setters and Getters
        //-----------------------------------------------------------------------------------------------------------
        //.........................................instance..........................................
		private static var _instance:IMateManager;
		/**
		 * Returns a single <code>IMateManager</code> instance. 
		 */
		public static function get instance():IMateManager
		{
			return (!_instance)? createInstance():_instance;
		}
		
        //-----------------------------------------------------------------------------------------------------------
        //                                         Static Private Methods
        //-----------------------------------------------------------------------------------------------------------
        //.........................................createInstance........................................
        /**
        * Creates the <code>IMateManager</code> instance.
        */
        protected static function createInstance():IMateManager
        {
        	_instance = new MateManagerInstance();
        	return _instance;
        }
	}
}

/******************************************************************************************************************
*                                         Inner Class MateManagerInstance
*******************************************************************************************************************/

import com.asfusion.mate.actionLists.Injectors;
import com.asfusion.mate.core.Creator;
import com.asfusion.mate.core.GlobalDispatcher;
import com.asfusion.mate.core.IMateManager;
import com.asfusion.mate.events.DispatcherEvent;
import com.asfusion.mate.events.InjectorSettingsEvent;
import com.asfusion.mate.utils.debug.IMateLogger;
import com.asfusion.mate.utils.debug.Logger;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

import mx.events.FlexEvent;
import mx.logging.ILoggingTarget;

class MateManagerInstance extends EventDispatcher implements IMateManager
{
	public function MateManagerInstance()
	{
		_instantiator = new Creator();
	}

//	private var listenerProxies:Dictionary = new Dictionary(true);

    private var _cache:Dictionary = new Dictionary();
	public function get cacheCollection():Dictionary
	{
		return _cache;
	}

	private var _instantiator:Creator;
	public function get instantiator():Creator
	{
		return _instantiator;
	}
	
	//.........................................loggerClass........................................
	private var _loggerClass:Class = Logger;
	public function get loggerClass():Class
	{
		return _loggerClass;
	}
	public function set loggerClass(value:Class):void
	{
		_loggerClass = value;
	}
	
	
	//.........................................listenerProxyType........................................
	private var _listenerProxyType:String = FlexEvent.PREINITIALIZE;
	public function get listenerProxyType():String
	{
		return _listenerProxyType;
	}
	public function set listenerProxyType(value:String):void
	{
		var oldValue:String = _listenerProxyType;
		if(oldValue !== value)
		{
			_listenerProxyType = value;
			var event:InjectorSettingsEvent = new InjectorSettingsEvent(InjectorSettingsEvent.TYPE_CHANGE);
			event.globalType = value;
			dispatchEvent(event);
		}
		
	}
	
	
	//.........................................debugger........................................
	private  var _debugger:ILoggingTarget;
	public function get debugger():ILoggingTarget
	{
		return _debugger;
	}
	public function set debugger(value:ILoggingTarget):void
	{
		_debugger = value;
	}
	
	
	//.........................................dispatcher........................................
	private  var _dispatcher:IEventDispatcher = new GlobalDispatcher();
	public function get dispatcher():IEventDispatcher
	{
		return _dispatcher;
	}
	public function set dispatcher(value:IEventDispatcher):void
	{
		var oldDispatcher:IEventDispatcher = _dispatcher;
		if(oldDispatcher !== value)
		{
			_dispatcher = value;
			var event:DispatcherEvent = new DispatcherEvent(DispatcherEvent.CHANGE);
			event.oldDispatcher = oldDispatcher;
			event.newDispatcher = _dispatcher;
			dispatchEvent(event);
		}
	}
	
	
	//.........................................responseDispatcher........................................
	private var _responseDispatcher:IEventDispatcher = new EventDispatcher();
	public function get responseDispatcher():IEventDispatcher
	{
		return _responseDispatcher;
	}
	//-----------------------------------------------------------------------------------------------------------
    //                                          Public Methods
    //-----------------------------------------------------------------------------------------------------------
	
    //.........................................getLogger........................................
    public function getLogger(active:Boolean):IMateLogger
    {
    	var logger:IMateLogger;
    	if(debugger)
    	{
    		logger = new loggerClass(active);
    		debugger.addLogger(logger);
    	}
    	else
    	{
    		logger = new loggerClass(false);
    	}
    	return logger;
    }
    
    //.........................................addListenerProxy........................................
//	public function addListenerProxy(eventDispatcher:IEventDispatcher, type:String = null):ListenerProxy
//	{
//		var listenerProxy:ListenerProxy = listenerProxies[eventDispatcher];
//
//		if (listenerProxy == null)
//		{
//			listenerProxy = new ListenerProxy(eventDispatcher);
//			listenerProxies[eventDispatcher] = listenerProxy;
//		}
//
//		if (type == null)
//		{
//			listenerProxy.addListener(listenerProxyType, this);
//		}
//		else
//		{
//			listenerProxy.addListener(type);
//		}
//		return listenerProxy;
//	}

	private var _injectors:Vector.<Injectors> = new Vector.<Injectors>();
	public function get injectors():Vector.<Injectors>
	{
		return _injectors;
	}
}