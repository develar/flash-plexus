package org.flyti.plexus
{
import com.asfusion.mate.actions.ChangeWatcher;

public interface Uninjectable
{
	function unwatch():void;

	function addWatcher(watcher:ChangeWatcher):void;
}
}