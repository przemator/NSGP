<?
	// This variable stores how long it takes for a server to timeout.
	$timeoutDelay = 10*60; // 10 minutes.
	$timeoutDelay2 = 10*60; // 10 minutes.
	
	// Connect to the database.
	$connection = mysql_connect("localhost", "newst10_gary", "yellows1986") or die("error 1");
	mysql_select_db("newst10_serverlistnsgp") or die("error 1");

	// Make sure we have been given an action.
	if (isset($_GET['action']))
	{
		// Process the action.
		switch ($_GET['action'])
		{
			case 'ip':
			
				die($_SERVER['REMOTE_ADDR']);
				break;

		
			case 'listservers':
				
				// Kill off any servers that haven't refreshed themselfs in a long time.
				mysql_query("DELETE FROM servers120 WHERE timeouttimer <= " . time());
				
				// Grab server list.
				$result = mysql_query("SELECT * FROM servers120");
				
				if ($result)
				{
					// Emit all the servers.
					while ($row = mysql_fetch_assoc($result)) 
					{
						echo $row['ip'] . '|' . $row['hostname'] . '|' . $row['track'] . '|' . $row['settings'] . '|' . $row['racers'] . '|' . $row['status'] . "\n";
					}
				}
				
				break;
				
			case 'addserver':
				
				// Check correct arguments have been passed.
				if (!isset($_GET['hostname'])) die("error 2");
				
				// Get required arguemnts and clean them up.
				$hostName = $_GET['hostname'];
				$track = $_GET['track'];
				$settings = $_GET['settings'];
				$racers = $_GET['racers'];
				$status = $_GET['status'];
								
				// Remove this server based on its ip.
				mysql_query("DELETE FROM servers120 WHERE ip='" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "'");
				
				// Insert it into the database.
				mysql_query("INSERT INTO servers120(ip, hostname, timeouttimer, track, settings, racers, status) VALUES('" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "','" . mysql_escape_string($hostName) . "'," . (time() + $timeoutDelay) . ",'" . mysql_escape_string($track) . "','" . mysql_escape_string($settings) . "', " . mysql_escape_string($racers) . ", '" . mysql_escape_string($status) . "')");

				break;
				
			case 'removeserver':
			
				// Remove this server based on its ip.
				mysql_query("DELETE FROM servers120 WHERE ip='" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "'");
			
				break;

			case 'refreshserver':
			
				// Refersh the servers timeout timer.
				mysql_query("UPDATE servers120 SET timeouttimer='" . (time() + $timeoutDelay) . "' WHERE ip='" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "'");
				break;
			
			
			// -------
			// PLAYERS
			// -------
			
			case 'addplayer':
				
				// Check correct arguments have been passed.
				if (!isset($_GET['playername'])) die("error 2");
				
				// Get required arguemnts and clean them up.
				$playername = $_GET['playername'];
				$license = $_GET['license'];
				$room = $_GET['room'];
								
				// Remove this server based on its ip.
				mysql_query("DELETE FROM players120 WHERE ip='" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "'");
				
				// Insert it into the database.
				mysql_query("INSERT INTO players120(ip, name, license, timeouttimer, room) VALUES('" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "','" . mysql_escape_string($playername) . "','" . mysql_escape_string($license) . "'," . (time() + $timeoutDelay2) . ", '" . mysql_escape_string($room) . "')");

				break;
			
			case 'refreshplayer':
			
				// Refersh the player room
				$room = $_GET['room'];

				mysql_query("UPDATE players120 SET timeouttimer='" . (time() + $timeoutDelay2) . "', room = '" . mysql_escape_string($room) . "' WHERE ip='" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "'");

				break;
				
			case 'listplayers':
				
				// Kill off any servers that haven't refreshed themselfs in a long time.
				mysql_query("DELETE FROM players120 WHERE timeouttimer <= " . time());
				
				// Grab server list.
				$result = mysql_query("SELECT * FROM players120");
				
				if ($result)
				{
					// Emit all the servers.
					while ($row = mysql_fetch_assoc($result)) 
					{
						echo $row['name'] . '|' . $row['room'] . "\n";
					}
				}
				
				break;
		}
	}
	else
	{
		die("error 2");
	}

	// Close database connection.
	mysql_close($connection);

?>