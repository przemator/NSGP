<?

$name = $_GET['name'];
$trackno = $_GET['trackno'];
$laptime = $_GET['laptime'];
$country = $_GET['country'];
$team = $_GET['team'];
$handling = $_GET['handling'];
$acceleration = $_GET['acceleration'];
$topspeed = $_GET['topspeed'];
$license = $_GET['license'];

$receivedmdfive = $_GET['mdfive'];
$computedmdfive = md5($name . $trackno . $laptime . $country . $team . $handling . $acceleration . $topspeed . $license . "superlaser");

$service = "localhost";
$username = "newst10_gary";
$password = "yellows1986";
$database = "newst10_nsgp";

mysql_connect($service, $username, $password);
@mysql_select_db($database) or die( "Unable to select database");

if (($trackno > 0) && ($laptime > 0)) 
{
	if (strcmp($receivedmdfive, $computedmdfive) == 0) 
	{
		$query = "SELECT laptime FROM laprecords120 WHERE trackno = $trackno ORDER BY laptime ASC LIMIT 250";
		$result = mysql_query($query);
		$num = mysql_numrows($result);
		$loopindex = 0;
		$lowest = 999999;
		$highest = 0;
		while ($loopindex < $num) {
			$thislaptime = mysql_result($result, $loopindex, "laptime");
			if($thislaptime < $lowest)	{$lowest = $thislaptime;}
			if($thislaptime > $highest)	{$highest = $thislaptime;}
			$loopindex++;
		}
		
		$submitok = 1;
		// Cannot check low time cheating properly until leaderboards have normalized. For now just check under 20 seconds.
		// if($lowest < 999999 && $laptime <= $lowest-2500)	{echo("Cheat! Time: $laptime"); $submitok = 0;}
		if($laptime <= 20000)	{echo("Cheat! Time: $laptime"); $submitok = 0;}
		if($loopindex >= 250 && $laptime >= $highest)		{echo("Too slow! Highest:$highest  Your Time: $laptime"); $submitok = 0;}

		if($submitok == 1)
		{
			$query="DELETE FROM laprecords120 WHERE name = '$name' AND trackno = $trackno AND license = '$license' AND laptime >= $laptime";
			$result=mysql_query($query);
		
			$query="INSERT INTO laprecords120 VALUES (NULL, '$name', '$trackno', '$laptime', '$team', '$handling', '$acceleration', '$topspeed', '$country', CURRENT_TIMESTAMP, '$license')";
			$result=mysql_query($query);
			echo("INSERT INTO laprecords120 VALUES (NULL, '$name', '$trackno', '$laptime', '$team', '$handling', '$acceleration', '$topspeed', '$country', CURRENT_TIMESTAMP, '$license')");
			echo("Time submitted! Name: $name, Time: $laptime");
		}
	}
	else 
	{
		echo("Incorrect hash!");
	}

}
else 
{
	echo("Score was not submitted from: $license");
}

?>
