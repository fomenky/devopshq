<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE HTML>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<title>aPersona - Help Desk Management</title>
	<link rel="stylesheet" type="text/css"
		href="${pageContext.request.contextPath}/css/fusion.css">
	<link rel="stylesheet" type="text/css"
		href="${pageContext.request.contextPath}/css/style.css">
	<link rel="stylesheet" type="text/css"
		href="${pageContext.request.contextPath}/css/ap_style.css">
<link rel="stylesheet" 
	href="${pageContext.request.contextPath}/css/jquery-ui.css" />
	
		<link rel="icon" 
      type="image/png" 
      href="${pageContext.request.contextPath}/images/favicon.png">
	<link rel="shortcut icon" 
      type="image/png" 
      href="${pageContext.request.contextPath}/images/favicon.png">
	
	
<script src="${pageContext.request.contextPath}/js/jquery-1.9.1.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery-ui.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery.min.js"></script>

</head>
<body class="nof-centerBody">
<div style="height:100%; min-height:100%; position:relative;">
	<c:set var="selMenu" scope="request" value="helpDeskMgmt"/>
	<jsp:include page="header.jsp" />

	<div class="nof-centerContent">

      <div class="nof-clearfix nof-positioning ">
        <div id="Text140" class="nof-positioning TextObject" style="float: left; display:inline; width: 19px;">
          <p style="text-align: right; margin-bottom: 0px;">&nbsp;</p>
        </div>
        <div id="Text129" class="nof-positioning TextObject" style="float: left; display: inline; width: 1000px; margin-top: 9px; margin-left: 0px; ">
          <p style="margin-bottom: 0px;"><b><span style="font-size: 16px; font-weight: bold;">Help Desk	 Management</span></b></p>
		  <br/>
          <p>Welcome to the aPersona Adaptive Security Manger. Please use below section to select clients.</p>
        </div>
      </div>
	  
	  <c:if test="${USER_NOT_HELP_DESK == 'USER_NOT_HELP_DESK'}">
      <div class="nof-positioning" style="width: 100%; margin-left: 8px; ">
	      <br/>	      
	      <div class="boxLayout" style="width:100%;">
	      	<h2>Access Denied</h2>
			<br/>
			<h3>You are not authorized to access this page!</h3>
	  	  </div>
	  </div>	  
	  </c:if>
	  
	  <c:if test="${USER_NOT_HELP_DESK != 'USER_NOT_HELP_DESK'}">
      <div class="nof-positioning" style="width: 100%; margin-left: 8px; ">
	      <br/>	      

	      <div class="boxLayout" style="width:100%;">
	      <div class="boxLayout" style="width:100%;">
	      	<h2>Help Desk Management</h2>
			<br/>
	        <h3>Please select the client to access support pages for client.</h3>
	        <form name="selProvider" method="post" action="continueToProvider.ap">
	        
	        	<p width="98%" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Client Name:</b>&nbsp;&nbsp;&nbsp;&nbsp; 
	            <select name="selectedProviderId">
					<c:forEach var="kvProvider" items="${KV_PROVIDERS}" varStatus="loop">
						<option value="${kvProvider.providerId}">${kvProvider.providerName}</option>
					</c:forEach>	          
	          </select>
	          &nbsp;&nbsp;&nbsp;&nbsp;
	          <input type="submit" class="buttonStyle" value="Continue" />
	          </p>
	        </form>
	   </div>
	   </c:if>
	</div>
	<br/>		
</div>
<%@include file="footer.html" %>
</body>
</html>