package org.flyti.plexus.configuration.events
{
import flash.events.Event;

public class ApplicationConfigurationEvent extends Event
{
	public static const LOAD:String = "mate_loadApplicationConfiguration";
	public static const LOADED:String = "mate_applicationConfigurationLoaded";

	public function ApplicationConfigurationEvent(type:String, data:XML = null)
	{
		_data = data;

		super(type);
	}

	private var _data:XML;
	public function get data():XML
	{
		return _data;
	}
}
}