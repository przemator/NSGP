<?
$trackno = $_GET['trackno'];
$service = "localhost";
$username = "newst10_gary";
$password = "yellows1986";
$database = "newst10_nsgp";

mysql_connect($service, $username, $password);
@mysql_select_db($database) or die( "Unable to select database");

$query = "SELECT name, laptime, team, handling, acceleration, topspeed, country FROM laprecords120 WHERE trackno = $trackno ORDER BY laptime ASC LIMIT 250";
$result = mysql_query($query);
$num = mysql_numrows($result);

$loopindex = 0;
while ($loopindex < $num) {

	$thisname = mysql_result($result, $loopindex, "name");
	$thislaptime = mysql_result($result, $loopindex, "laptime");
	$thisteam = mysql_result($result, $loopindex, "team");
	$thishandling = mysql_result($result, $loopindex, "handling");
	$thisacceleration = mysql_result($result, $loopindex, "acceleration");
	$thistopspeed = mysql_result($result, $loopindex, "topspeed");
	$thiscountry = mysql_result($result, $loopindex, "country");
	$thispos = $loopindex+1;

	echo("$thisname,$thislaptime,$thisteam,$thishandling,$thisacceleration,$thistopspeed,$thiscountry,");
	
	$loopindex++;
}

?>