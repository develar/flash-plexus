package org.flyti.plexus
{
import org.flyti.plexus.actions.ChangeWatcher;

public interface Uninjectable
{
	function unwatch():void;

	function addWatcher(watcher:ChangeWatcher):void;
}
}