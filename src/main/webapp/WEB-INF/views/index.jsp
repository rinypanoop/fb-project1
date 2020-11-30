<!DOCTYPE html>


<html>
<head>
<title>FB-AI Companion</title>
<meta charset="UTF-8">

<style>
html, body {
	height: 100%;
	margin: 0;
}

.full-height {
	height: 100%;
	width: 100%;
}
</style>

</head>
<body>
	<script>
		function statusChangeCallback(response) { // Called with the results from FB.getLoginStatus().
			console.log('statusChangeCallback');
			console.log(response); // The current login status of the person.
			if (response.status === 'connected') { // Logged into your webpage and Facebook.
				document.getElementById("access_token").value = response.authResponse.accessToken;
				loadFormData();
			} else { 
				//document.getElementById('status').innerHTML = 'Please log into this webpage.';
				console.log("Login failed");
			}
		}

		function checkLoginState() { // Called when a person is finished with the Login Button.
			FB.getLoginStatus(function(response) { // See the onlogin handler
				statusChangeCallback(response);
			});
		}

		window.fbAsyncInit = function() {
			FB.init({
				appId : '1313560575659850',
				cookie : true, // Enable cookies to allow the server to access the session.
				xfbml : true, // Parse social plugins on this webpage.
				version : 'v8.0' // Use this Graph API version for this call.
			});

			FB.getLoginStatus(function(response) { // Called after the JS SDK has been initialized.
				statusChangeCallback(response); // Returns the login status.
			});
		};

		function loadFormData() { 
			console.log('Welcome!  Fetching your information.... ');
			FB
					.api(
							'/me?fields=name',
							function(response) {
								console.log('Successful login for: ' + response.name);
								console.log(response);
								document.getElementById('user_id').value = response.id;
								document.getElementById('user_name').value = response.name;
								document.getElementById("form_home").submit();
								
							});
		}
		
	</script>


	<div id="fb-root"></div>
	<script async defer crossorigin="anonymous"
		src="https://connect.facebook.net/en_US/sdk.js#xfbml=1&version=v8.0&appId=850289965708113&autoLogAppEvents=1"
		nonce="QbbBu1Cw"></script>



	<table class="full-height">

		<tr style="height: 5%">
			<td style="align-items: center;">
				<div id="status"></div>
			</td>
		</tr>
		<tr style="height: 20%">
			<td align="center">
				<div id=""><p style="font-weight: bold;font-size: 50px; color: #1fa694"> FB AI Companion</p></div>
			</td>
		</tr>
		<tr style="height: 30%">

			<td align="center"><fb:login-button scope="user_photos"
					onlogin="checkLoginState();" size="xlarge">Login with Facebook</fb:login-button>
			</td>

		</tr>

		<tr style="height: 20%">
			<td align="center" >
				<div id=""><p style="font-size: 30Px; color: #f27c05;"> Run analytics on your FB Photos </p></div>
			</td>
		</tr>
		<tr style="height: 5%">
			<td align="center">Copyright &copy; CSU WEB 2020</td>
		</tr>
	</table>


	<form id="form_home" action="/home" method="post">
	 <input type="hidden" name="access_token" id="access_token">
	 <input type="hidden" name="user_name"  id="user_name"> 
	  <input type="hidden" name="user_id"  id="user_id">
	</form>

	<!-- Load the JS SDK asynchronously -->
			<script async defer crossorigin="anonymous"
				src="https://connect.facebook.net/en_US/sdk.js"></script>

		</body>
</html>