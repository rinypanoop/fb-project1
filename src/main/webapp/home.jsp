<!DOCTYPE html>
<%@ page import="java.io.IOException"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.SimpleTimeZone"%>
<%@ page import="javax.servlet.annotation.WebServlet"%>
<%@ page import="javax.servlet.http.HttpServlet"%>
<%@ page import="javax.servlet.http.HttpServletRequest"%>
<%@ page import="javax.servlet.http.HttpServletResponse"%>
<%@ page import="java.util.TimeZone"%>

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
	border-collapse: collapse;
}

.header {
  background-color:  #333;
  padding: 30px;
  text-align: center;
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

</head>
<body>



	<table class="full-height" >

		<tr style="height: 10%">
			<td style="align-items: center;" colspan="2">
				<div class="header" id="div_header"></div>
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
	 <input type="hidden" name="access_token" id="access_token">
	 <input type="hidden" name="user_name"  id="user_name"> 
	  <input type="hidden" name="user_id"  id="user_id">
	</form>


		</body>
</html>