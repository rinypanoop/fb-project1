<!DOCTYPE html>


<html>
<head>
<title>FB-AI Companion</title>
<meta charset="UTF-8">

<link
	href="https://code.jquery.com/ui/1.10.4/themes/ui-lightness/jquery-ui.css"
	rel="stylesheet">
<script src="https://code.jquery.com/jquery-1.10.2.js"></script>
<script src="https://code.jquery.com/ui/1.10.4/jquery-ui.js"></script>



<style>
html, body {
	height: 100%;
	margin: 0;
}

.full-height {
	height: 100%;
	width: 100%;
	border-collapse: collapse;
}

.header {
  background-color:  #E5E7E9;
  padding: 30px;
  text-align: center;
  padding: 0px;
}

.sidebar {
  background-color: #f1f1f1;
  height: 100%;
  overflow: auto;
}

.content {
  height: 100%;
  width: 100%;
  overflow: auto;
}

.sidebar a {
  display: block;
  color: black;
  padding: 16px;
  text-decoration: none;
}
 
.sidebar a.active {
  background-color: #4CAF50;
  color: white;
}

.sidebar a:hover:not(.active) {
  background-color: #555;
  color: white;
}

</style>


<script>
	$(function() {
		var date = new Date();
		var currentMonth = date.getMonth();
		var currentDate = date.getDate();
		var currentYear = date.getFullYear();
		$("#datepicker-1").datepicker();
		$("#datepicker-1").datepicker("setDate", new Date(currentYear, currentMonth-1, currentDate));
		$("#datepicker-2").datepicker();
		$("#datepicker-2").datepicker().datepicker('setDate', date);
	});
	
	function getImages(){
		$.ajax({
			  url: "/images",
			  type: "get", //send it through get method
			  data: { 
			    fromDate: document.getElementById("datepicker-1").value, 
			    toDate: document.getElementById("datepicker-2").value,
			    access_token:  document.getElementById("access_token").value,
			    user_id:  document.getElementById("user_id").value
			  },
			  success: function(response) {
			    console.log(response);
			    drawImages(response);
			  },
			  error: function(xhr) {
			    //Do Something to handle error
			  }
			});
	}
	
	function drawImages(response){
		
		var html = "";
		response.imageDataResponse.images.forEach(obj => {
	        
	        console.log(obj);
	        
	      html = html + '<img src="'+obj.url+'" height = "200px" width ="300px;"> </img><br>';
	        
	        
	    });
		document.getElementById("div_content").innerHTML=html;
	}
	
</script>


</head>
<body>
	<table class="full-height" >

		<tr style="height: 10%">
			<td style="align-items: center;" colspan="2">
				<div class="header" id="div_header">
					<table style="width: 100%; height: 100%; padding: 0px;">
						<tr>
							<td width="35%">
								<table>
									<tr>
										<td>
											<p>
												From: <input type="text" id="datepicker-1">
											</p>
										</td>
										<td>
											<p>
												To: <input type="text" id="datepicker-2">
											</p>
										</td>
										<td><input type="button" value="search" id="search" onclick="getImages()">
										</td>
									</tr>
								</table>
							</td>
							<td width="45%" align="center">FB-AI Companion</td>
							<td width="20%" align="right"><%=request.getAttribute("user_name")%></td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<tr style="height: 85%">
			<td width="15%">
				<div class="sidebar" id="div_sidebar">
				 	<a class="active" href="#home">Home</a>
					<a href="#news">News</a>
					<a href="#contact">Contact</a>
					<a href="#about">About</a>
				</div>
			</td>
			<td width="85%">
				<div id="div_content" class="content">Content
				Content
				</div>
			</td>
		</tr>
		<tr style="height: 5%">
			<td align="center" colspan="2">Copyright &copy; CSU WEB 2020</td>
		</tr>
	</table>


	<form id="form_home" action="/home" method="post">
	 <input type="hidden" name="access_token" id="access_token" value="<%=request.getAttribute("access_token")%>">
	 <input type="hidden" name="user_name"  id="user_name"  value="<%=request.getAttribute("user_name")%>"> 
	  <input type="hidden" name="user_id"  id="user_id" value="<%=request.getAttribute("user_id")%>">
	</form>


		</body>
</html>