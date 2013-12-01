<?php

/*
MySQL Table:

CREATE TABLE `HighscoreTable` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Points` int(10) unsigned NOT NULL,
  `Day` date NOT NULL,
  PRIMARY KEY (`ID`)
);

*/

header("Access-Control-Allow-Origin: http://hitchh1k3r.github.io");

$dayRank = 0;
$topRank = 0;
$dayTotal = 0;
$topTotal = 0;
$score = 0;

if(isset($_GET["score"]))
{
    date_default_timezone_set("GMT");
    $mysql = mysqli_connect("<server>", "<user>", "<password>", "<database>");
    $table = "<table>";

    $score = floor($_GET["score"]);

    if($score >= 0)
    {
        $date = date("Y-m-d");

        $sql = "INSERT INTO `games`.`".$table."` (`ID`,`Points`,`Day`) VALUES (NULL, ".$score.", CURRENT_DATE());";
        $mysql->query($sql);

        $id = mysqli_insert_id($mysql);

        $sql = "SELECT Rank FROM
                (SELECT list.ID,
                        list.Points,
                        list.Day,
                        @curRow := @curRow + 1 AS Rank
                  FROM  `".$table."` list
                  JOIN  (SELECT @curRow := 0) q
                  WHERE Day = '".$date."'
                  ORDER BY Points DESC) as target
                  WHERE   target.ID = ".$id.";";
        $r = $mysql->query($sql);
        if($row = @mysqli_fetch_array($r))
            $dayRank = $row["Rank"];

        $sql = "SELECT Rank FROM
                (SELECT list.ID,
                        list.Points,
                        list.Day,
                        @curRow := @curRow + 1 AS Rank
                  FROM  `".$table."` list
                  JOIN  (SELECT @curRow := 0) q
                  ORDER BY Points DESC) as target
                  WHERE   target.ID = ".$id.";";
        $r = $mysql->query($sql);
        if($row = @mysqli_fetch_array($r))
            $topRank = $row["Rank"];

        $sql = "SELECT COUNT(*)
                  FROM  `".$table."`
                  WHERE Day = '".$date."';";
        $r = $mysql->query($sql);
        if($row = @mysqli_fetch_array($r))
            $dayTotal = $row["COUNT(*)"];

        $sql = "SELECT COUNT(*)
                  FROM  `".$table."`;";
        $r = $mysql->query($sql);
        if($row = @mysqli_fetch_array($r))
            $topTotal = $row["COUNT(*)"];
    }
}

if($dayRank > 0 && $topRank > 0 && $dayTotal > 0 && $topTotal > 0)
{
    echo "scored ".$score."! Ranking ".$dayRank." out of ".$dayTotal." for today, and ".$topRank." out of ".$topTotal." for all time.";
}
else
{
    echo "ERROR";
}

?>