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
	
	
	var currentLabelDisplay;
	var currentLabelA;
	function drawImages(response){
		var content_div = document.getElementById("div_content");
		var sidebar_div = document.getElementById("div_sidebar");
		
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
	    	  label_div.appendChild(document.createElement("br"));
	      })
	       
	    });
		
	}
	
	function changeDisplay(){
		alert(1)
	}
	
	function createImageElement(image_url){
		var img = document.createElement("img");
		img.setAttribute("src", image_url);
		return img;
	}
	
	function test(){
		
		var para = document.createElement("p");
		var node = document.createTextNode("Tutorix is the best e-learning platform");
		para.appendChild(node);
		
		
		img.setAttribute("src", "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-0/p130x130/127153288_129374702305580_3499307895933272858_n.jpg?_nc_cat=111&ccb=2&_nc_sid=0be424&_nc_ohc=_L80X1TVZacAX_j3qpD&_nc_ht=scontent-sjc3-1.xx&tp=6&oh=302ff57bd73d0a956b556f2e2095f118&oe=5FE59217");
		
		//https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-0/p130x130/127153288_129374702305580_3499307895933272858_n.jpg?_nc_cat=111&ccb=2&_nc_sid=0be424&_nc_ohc=_L80X1TVZacAX_j3qpD&_nc_ht=scontent-sjc3-1.xx&tp=6&oh=302ff57bd73d0a956b556f2e2095f118&oe=5FE59217
		
		  document.getElementById("div_content").appendChild(img);
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
										<input type="button" value="test" id="search" onclick="test()">
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

				</div>
			</td>
			<td width="85%">
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