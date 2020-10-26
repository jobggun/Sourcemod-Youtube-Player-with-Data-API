<?php

if(isset($_GET["q"]))
{
	$API_URL = "https://www.googleapis.com/youtube/v3/search?";
	
	$QUERY_ARRAY = [
		"key" => "[YOUTUBE DATA API V3 KEY]",
		"q" => "default search string",
		"maxResults" => "1",
	];
	
	$QUERY_ARRAY["q"] = $_GET["q"];
	
	$url = $API_URL . http_build_query($QUERY_ARRAY);

	$ch = curl_init();
	
	curl_setopt($ch, CURLOPT_URL, $url);
	
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE); 
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0); 
	
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	
	curl_setopt($ch, CURLOPT_HEADER, 0);
	
	$data = curl_exec($ch);
	
	if (curl_error($ch))  
	{
		exit('CURL Error('.curl_errno( $ch ).') '. curl_error($ch)); 
	} 
	curl_close($ch);
	
	$RESPONSE_ARRAY = json_decode($data, true);
	
	header("Location: /youtube/?videoId=" . $RESPONSE_ARRAY["items"][0]["id"]["videoId"]);
	
}
else if(isset($_GET["videoId"]))
{
?>
<!DOCTYPE html>
<html>
	<body>
		<iframe width="100%" height="360" src="https://www.youtube.com/embed/<?php echo($_GET["videoId"]) ?>?autoplay=1&loop=1" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
	</body>
</html>
<?	
}
?>