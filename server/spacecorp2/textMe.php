<?php
	preg_match('/^(\d{2,3}\.\d{1,3}\.\d{1,3}\.)/', $_SERVER['SERVER_ADDR'], $myself);
	preg_match('/^(\d{2,3}\.\d{1,3}\.\d{1,3}\.)/', $_SERVER['REMOTE_ADDR'], $yourself);
	if ($myself[0] !== $yourself[0]) {
		echo "Mostly not a match. Sry.";
		exit;
	}
	$to      = '6464643484@tmomail.net';
	$subject = 'Spacecorp';
	$message = 'HIGH SEVERITY / COLLISION (x100) DETECTED';
	$headers = 'From: ErrorRecorder@ilankleiman.com' . "\r\n" .
	    'Reply-To: 6464643484@tmomail.net' . "\r\n" .
	    'X-Mailer: PHP/' . phpversion();

	mail($to, $subject, $message, $headers);
	echo "Sent successfully<br/>\n";

?>