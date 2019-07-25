<?php
$received = file_get_contents('php://input');
$fileToWrite = "tmp/upload".time().".jpg";
file_put_contents($fileToWrite, $received);
?>
