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
<script src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>



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

.loader {
  border: 16px solid #f3f3f3;
  border-radius: 50%;
  border-top: 16px solid #3498db;
  width: 30px;
  height: 30px;
  -webkit-animation: spin 2s linear infinite; /* Safari */
  animation: spin 2s linear infinite;
}

/* Safari */
@-webkit-keyframes spin {
  0% { -webkit-transform: rotate(0deg); }
  100% { -webkit-transform: rotate(360deg); }
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
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
		
		clearData();
		
		document.getElementById("loader").style.display = "block";
		
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
				  document.getElementById("loader").style.display="none";
			    //Do Something to handle error
			  }
			});
	}
	
	function clearData(){
		var content_div = document.getElementById("div_content");
		while (content_div.firstChild) {
			content_div.removeChild(content_div.lastChild);
		  }
		var sidebar_div = document.getElementById("div_sidebar");
		while (sidebar_div.firstChild) {
			sidebar_div.removeChild(sidebar_div.lastChild);
		  }
	}
	
	
	var currentLabelDisplay;
	var currentLabelA;
	function drawImages(response){
		var content_div = document.getElementById("div_content");
		var sidebar_div = document.getElementById("div_sidebar");
		
		content_div.appendChild(document.createElement("br"));
		content_div.appendChild(document.createElement("br"));
		 
		var isFirst=true;
		response.imageDataResponse.lables.forEach(label => {
		
		var label_div = document.createElement("div");
		label_div.setAttribute("id",label);
		
		var label_a = document.createElement("a");
		label_a.setAttribute("href","#"+label);
		label_a.setAttribute("id","a_"+label);	
		label_a.text=label;
		label_a.addEventListener("click", function(event) {
			var current_display_id = event.target.text;
			document.getElementById(current_display_id).style.display="block";
			//twttr.widgets.load();
			currentLabelDisplay.style.display="none";
			currentLabelDisplay = document.getElementById(current_display_id);
			
			event.target.style.backgroundColor= "#4CAF50";
			event.target.style.color= "white";
			
			currentLabelA.style.backgroundColor= "#f1f1f1";
			currentLabelA.style.color= "black";
			
			currentLabelA = document.getElementById("a_"+current_display_id);
			
			});
		
		if(isFirst){
			label_div.style.display = "block";
			currentLabelDisplay=label_div;
			label_a.setAttribute("class","active");
			currentLabelA= label_a;
		}else{
			label_div.style.display = "none";
		}
		
		 content_div.appendChild(label_div);
		 
		 
		 sidebar_div.appendChild(label_a);
		 isFirst=false;
		 
		});
		 

		response.imageDataResponse.images.forEach(obj => {
	        
	      console.log(obj);
	      obj.labels.forEach(label => {
	    	  var label_div = document.getElementById(label);
	    	  label_div.appendChild(createImageElement(obj.url));
	    	  var p_space = document.createElement("p");
	    	  p_space.text="&#32";
	    	  label_div.appendChild(p_space);
	    	  label_div.appendChild(createTwitterButton(obj.url));
	    	  label_div.appendChild(document.createElement("br"));
	    	  label_div.appendChild(document.createElement("br"));
	    	  label_div.appendChild(document.createElement("br"));
	    	  label_div.appendChild(document.createElement("br"));
	      })
	       
	    });
		
		//twttr.widgets.load();
		document.getElementById("loader").style.display="none";
	}
	
	function changeDisplay(){
		alert(1)
	}
	
	function createImageElement(image_url){
		var img = document.createElement("img");
		img.setAttribute("src", image_url);
		img.style.height="175px";
		img.style.width="200px";
		return img;
	}
	
	function createTwitterButton(image_url){
		var url = "https://twitter.com/intent/tweet?text=" + encodeURIComponent(image_url);
		var tweet_a = document.createElement("a");
		tweet_a.setAttribute("href",url);
		tweet_a.setAttribute("class","twitter-share-button");
		tweet_a.setAttribute("data-lang","en");
		tweet_a.setAttribute("data-show-count","false");	
		tweet_a.text="tweet";
		return tweet_a;
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
							<td width="45%" align="center"><p style="font-weight: bold;font-size: 25px; color: #1fa694">FB-AI Companion</p></td>
							<td width="20%" align="right"><%=request.getAttribute("user_name")%></td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<tr style="height: 85%">
			<td width="15%">
				<div class="sidebar" id="div_sidebar">

				</div>
			</td>
			<td width="85%" align="center">
				<div class="loader" id="loader" style="display:none"></div>
				<div id="div_content" class="content">
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