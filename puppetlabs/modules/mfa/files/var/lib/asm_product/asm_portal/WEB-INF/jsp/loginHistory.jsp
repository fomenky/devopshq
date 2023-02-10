<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>aPersona - Transaction History</title>
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/fusion.css">
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/ap_style.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/jquery-ui.css" />
<link href="${pageContext.request.contextPath}/css/theme.default.css" rel="stylesheet">
		<link rel="icon" 
      type="image/png" 
      href="${pageContext.request.contextPath}/images/favicon.png">
	<link rel="shortcut icon" 
      type="image/png" 
      href="${pageContext.request.contextPath}/images/favicon.png">

<script src="${pageContext.request.contextPath}/js/jquery-1.9.1.js"></script>
<script src="${pageContext.request.contextPath}/js/jquery-ui.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.tablesorter.min.js"></script>

    <script>
        $(function(){
        	$( "#tabs" ).tabs();
        	$( "#failedLoginsToDtId" ).datepicker();
            $( "#failedLoginsFromDtId" ).datepicker();
            $( "#reqRespFromDtId").datepicker();
            $( "#reqRespToDtId").datepicker();
        	$("#tabs").tabs({active: document.tabsName.currentTab.value});
        	
          $("#failedLoginTable").tablesorter({widgets: ['zebra']});
          $("#reqRespLogTable").tablesorter({widgets: ['zebra']});    
        
        });
    </script>

<style>
	table.fixed { table-layout:fixed;}
</style>
</head>
<body class="nof-centerBody">
	<div style="height: 100%; min-height: 100%; position: relative;">
		<c:set var="selMenu" scope="request" value="loginHist" />
		<jsp:include page="header.jsp" />

		<div class="nof-centerContent">
			<div class="nof-clearfix nof-positioning ">
				<div class="nof-positioning TextObject"
					style="float: left; display: inline; width: 19px;">
					<p style="text-align: right; margin-bottom: 0px;">&nbsp;</p>
				</div>
				<div id="Text129" class="nof-positioning TextObject" style="float: left; display: inline; width: 100%; margin-top: 9px; margin-left: 19px; ">
					<p style="margin-bottom: 0px;">
						<b><span style="font-size: 16px; font-weight: bold;">
								End User Transaction History & Reporting
					</p>
					<br />
					<p>On this tab you can see all failed transactions and a full request/response log of all transactions.</p>
				</div>
			</div>

			<div class="nof-positioning" style="width:100%; margin-left: 8px;">
				<br />
				<div class="boxLayout" style="width: 100%;">
					<h2>Transaction History</h2>
					<br />

					<div class="nof-positioning"
						style="width: 95%; margin-top: 13px; margin-left: 28px;">
					<form name="tabsName">
						<input type="hidden" name="currentTab" value="${SEL_TAB=='REQ_RESP' ? '1' : '0'}"/>
					</form>						
						
						<div id="tabs">
							<ul>
								<li><a href="#failedUserLogins">Failed Transactions</a>
								</li>
								<li><a href="#reqRespLog">Request Response Log </a>
								</li>
							</ul>
							<div id="failedUserLogins">
								<br />
								<form name="failedUserLogins" method="get" action="loginHist.ap">								                								                
									User Email: <input type="text" name="failedLoginsUserSearchKey" size="25"
										value="${failedLoginsUserSearchKey}"
										placeholder="User Email Address" />
										
<%-- 								<fmt:formatDate 
		                                  		value="${failedLoginsFromDt}"  
								                type="date" 
								                pattern="MM/dd/yyyy"
								                var="failedLoginsFromDtFmt" />
								<fmt:formatDate 
		                                  		value="${failedLoginsToDt}"  
								                type="date" 
								                pattern="MM/dd/yyyy"
								                var="failedLoginsToDtFmt" /> --%>										
										
									From Date: <fmt:formatDate value="${failedLoginsFromDt}"            type="date" 
						                pattern="MM/dd/yyyy"
						                var="failedLoginsFromDtFmt" />									
									</b>&nbsp;&nbsp;&nbsp;
								                <input type="text" id="failedLoginsFromDtId" value="${failedLoginsFromDtFmt}"
													name="failedLoginsFromDt" size="12" maxlength="13"
													placeholder="mm/dd/yyyy" />
									To Date:   <fmt:formatDate value="${failedLoginsToDt}"            type="date" 
						                pattern="MM/dd/yyyy"
						                var="failedLoginsToDtFmt" />								
									</b>&nbsp;&nbsp;&nbsp;
												<input type="text" id="failedLoginsToDtId" value="${failedLoginsToDtFmt}"
												name="failedLoginsToDt" size="12" maxlength="13"
										placeholder="mm/dd/yyyy" />

									<input type="hidden" name="reqRespUserSearchKey"/>
									<input type="hidden" name="reqRespFromDt"/>
									<input type="hidden" name="reqRespToDt"/>
									<input type="hidden" name="responseSearch"/>
									<input type="hidden" name="recCount"/>									
									<input type="hidden" name="SEL_TAB" value="FAILED_LOGINS"/>
									
									<input type="Submit" class="buttonStyle" value="Search/Refresh" onclick="javascript:failedLoginsSubmit();"/>
								</form>
								<br />
								<h3>
									<b>Search Results</b>
								</h3>
															
							<p style="font-weight:normal; font-style:italic;">(*) All Times Shown are Local aP-ASM System Time Zone</p>
						     <table style="width:100%;font-weight:normal;" id="failedLoginTable" class="tablesorter ap_table" border="0" cellpadding="0" cellspacing="1">
						      <thead>
						        <tr>
						          <th>Detected At (*)</th>
						          <th>Security Policy Name</th>     
						          <th>Server IP/Domain</th>
						          <th>Email Address</th>
						          <th>Failed Transaction Reason</th>
						        </tr>
						      </thead>
						      <tbody>
								<c:forEach var="failedLogin" items="${FAILED_USER_LOGINS}" varStatus="loop">
								<tr>
						          <td>${failedLogin[0]}</td>
						          <td>${failedLogin[1]}</td>
						          <td>${failedLogin[2]}</td>
						          <td>${failedLogin[3]}</td>
						          <td>${failedLogin[4]}</td>
						        </tr>
									
								</c:forEach>
						        </tbody>
						        </table>   
							</div>

							<div id="reqRespLog" style="overflow:auto; height: 500px;">
								<br />
<%-- 								<fmt:formatDate 
		                                  		value="${reqRespFromDt}"  
								                type="date" 
								                pattern="MM/dd/yyyy"
								                var="reqRespFromDtFmt" />
								<fmt:formatDate 
		                                  		value="${reqRespToDt}"  
								                type="date" 
								                pattern="MM/dd/yyyy"
								                var="reqRespToDtFmt" /> --%>

								<form name="reqRespHist" method="get" action="loginHist.ap">								                								                
									User Email: <input type="text" name="reqRespUserSearchKey" size="15"
										value="${reqRespUserSearchKey}"
										placeholder="User Email" />
<%-- 									&nbsp;&nbsp;From Date: 

									    <fmt:formatDate value="${reqRespFromDt}" type="date" pattern="MM/dd/yyyy" var="reqRespFromDtFmt"/>									
										</b>
								        <input type="text" id="reqRespFromDtId" value="${reqRespFromDtFmt}"
													name="reqRespFromDt" size="12" maxlength="10"
													placeholder="mm/dd/yyyy" />
									&nbsp;&nbsp;&nbsp;To Date: 
									        <fmt:formatDate value="${reqRespToDt}"            type="date" 
						                pattern="MM/dd/yyyy"
						                var="reqRespToDtFmt" />
												<input type="text" id="reqRespToDtId" value="${reqRespToDtFmt}"
												name="reqRespToDt" size="12" maxlength="10"
										placeholder="mm/dd/yyyy" />
						                									
									</b>
 --%>									
									
									From Date: <fmt:formatDate value="${reqRespFromDt}" type="date" 
						                pattern="MM/dd/yyyy" var="reqRespFromDtFmt" />									
									</b> 
								                <input type="text" id="reqRespFromDtId" value="${reqRespFromDtFmt}"
													name="reqRespFromDt" size="12" maxlength="13"
													placeholder="mm/dd/yyyy" />
													
									To Date:   <fmt:formatDate value="${reqRespToDt}"            type="date" 
						                pattern="MM/dd/yyyy" var="reqRespToDtFmt" />								
									</b>
												<input type="text" id="reqRespToDtId" value="${reqRespToDtFmt}"
												name="reqRespToDt" size="12" maxlength="13"
										placeholder="mm/dd/yyyy" />
									</b>
									
									
																		&nbsp;&nbsp;
<%-- 									Response:<input type="text" name="responseSearch" value="${responseSearch}" size="8"/>
 --%>
 Response:<select id="responseSearch" name="responseSearch">
        <option value="" ${responseSearch == '' ? 'selected' : ''}>All transactions</option>
        <option value="200" ${responseSearch == '200' ? 'selected' : ''}>200 (all)</option>
        <option value="200 - OK" ${responseSearch == '200 - OK' ? 'selected' : ''}>200 - OK</option>
        <option value="200 - Auto Learning" ${responseSearch == '200 - Auto Learning' ? 'selected' : ''}>200 - Auto Learning</option>
        <option value="200 - Auto Accept OTP" ${responseSearch == '200 - Auto Accept OTP' ? 'selected' : ''}>200 - Auto Accept OTP</option>
        <option value="200 - Exceeds Allowed Users" ${responseSearch == '200 - Exceeds Allowed Users' ? 'selected' : ''}>200 - Exceeds Allowed Users</option>
        <option value="200 - Bypassed IP" ${responseSearch == '200 - Bypassed IP' ? 'selected' : ''}>200 - Bypassed IP</option>
        <option value="200 - Maintenance" ${responseSearch == '200 - Maintenance' ? 'selected' : ''}>200 - Maintenance</option>
        <option value="202" ${responseSearch == '202' ? 'selected' : ''}>202 (all)</option>
        <option value="202 - OTP Sent - Email" ${responseSearch == '202 - OTP Sent - Email' ? 'selected' : ''}>202 - OTP Sent - Email</option>
        <option value="202 - OTP Sent - SMS" ${responseSearch == '202 - OTP Sent - SMS' ? 'selected' : ''}>202 - OTP Sent - SMS</option>
        <option value="202 - OTP Sent - Voice" ${responseSearch == '202 - OTP Sent - Voice' ? 'selected' : ''}>202 - OTP Sent - Voice</option>
        <option value="202 - Invalid OTP" ${responseSearch == '202 - Invalid OTP' ? 'selected' : ''}>202 - Invalid OTP</option>    
		<option value="202 - No Mobile Route for OTP" ${responseSearch == '202 - No Mobile Route for OTP' ? 'selected' : ''}>202 - No Mobile Route for OTP</option>
		<option value="202 - Missing Mobile Settings" ${responseSearch == '202 - Missing Mobile Settings' ? 'selected' : ''}>202 - Missing Mobile Settings</option>
		<option value="202 - Invalid Alternate Email" ${responseSearch == '202 - Invalid Alternate Email' ? 'selected' : ''}>202 - Invalid Alternate Email</option>
		<option value="203" ${responseSearch == '203' ? 'selected' : ''}>203 (all)</option>
		<option value="203 - Country location blocked" ${responseSearch == '203 - Country location blocked' ? 'selected' : ''}>203 - Country location blocked</option>
		<option value="203 - Threat Actor-IP Blocked" ${responseSearch == '203 - Threat Actor-IP Blocked' ? 'selected' : ''}>203 - Threat Actor-IP Blocked</option>
        <option value="203 - Conflict in IP" ${responseSearch == '203 - Conflict in IP' ? 'selected' : ''}>203 - Conflict in IP</option>
        <option value="401" ${responseSearch == '401' ? 'selected' : ''}>401 (all)</option>
        <option value="401 - Exceeded attempts" ${responseSearch == '401 - Exceeded attempts' ? 'selected' : ''}>401 - Exceeded attempts</option>
        <option value="401 - OTP time out" ${responseSearch == '401 - OTP time out' ? 'selected' : ''}>401 - OTP time out</option>
        <option value="401 - Invalid Transaction ID" ${responseSearch == '401 - Invalid Transaction ID' ? 'selected' : ''}>401 - Invalid Transaction ID</option>
        <option value="401 - OTP no longer valid, please login again" ${responseSearch == '401 - OTP no longer valid, please login again' ? 'selected' : ''}>401 - OTP no longer valid, please login again</option>
        <option value="403" ${responseSearch == '403' ? 'selected' : ''}>403 - Invalid API Server IP</option>
        <option value="404" ${responseSearch == '404' ? 'selected' : ''}>404 - User format/reg issues</option>
</select>
 
 
 									&nbsp;&nbsp;
									Results:<select id="recCount" name="recCount">
										<option value="50" ${recCount == '50' ? 'selected' : ''}>50</option>
										<option value="100" ${recCount == '100' ? 'selected' : ''}>100</option>
										<option value="500" ${recCount == '500' ? 'selected' : ''}>500</option>
										<option value="1000" ${recCount == '1000' ? 'selected' : ''}>1000</option>
									</select>
									<input type="hidden" name="failedLoginsUserSearchKey"/>
									<input type="hidden" name="failedLoginsFromDt"/>
									<input type="hidden" name="failedLoginsToDt"/>
									<input type="hidden" name="SEL_TAB" value="REQ_RESP"/>
									
									<input type="Submit" class="buttonStyle" value="Search/Refresh" onclick="javascript:reqRespSubmit();"/>
								</form>
								<br />
								<h3>
									<b>Search Results</b>
								</h3>								
							<p style="font-weight:normal; font-style:italic;">(*) All Times Shown are Local aP-ASM System Time Zone</p>	
						     <table style="width:100%;font-weight:normal;" id="reqRespLogTable" class="fixed ap_table tablesorter" border="0" cellpadding="0" cellspacing="1">
							    <col width="15px" />
							    <col width="20px" />
							    <col width="20px" />
							    <col width="50px" />
							    <col width="13px" />
							    <col width="72px" />
							    
						      <thead>
						        <tr>
						          <th>Time (*)</th>
						          <th>Email Address</th>
						          <th>Security Policy Name</th>    
								  <th>Request</th>
						          <th>Resp.</th>
						          <th>Details</th>
						        </tr>
						      </thead>
						      <tbody>
								<c:forEach var="reqResp" items="${REQ_RESP_LOG}" varStatus="loop">
								<fmt:formatDate 
                                  		value="${reqResp.processedAt}"  
						                type="date" 
						                pattern="yyyy-MM-dd HH:mm:ss"
						                var="processAt" />
								
								<tr>
						          <td style="font-size: 9px;text-align:left; width:20px;">${processAt}</td>
						          <td style="font-size: 9px;text-align:left; word-break:break-all; width:20px;">${reqResp.email}</td>
						          <td style="font-size: 9px;text-align:left; word-break:break-all; width:20px;">${reqResp.serverName}</td>
						          <td style="font-size: 9px;text-align:left; word-break:break-all;">${reqResp.request}</td>
						          <td style="font-size: 9px;text-align:left; width:20px;">${reqResp.response}</td>
						          <td style="font-size: 9px; text-align:left; word-break:break-all;">${reqResp.details}</td>
						        </tr>
									
								</c:forEach>
						        </tbody>
						        </table>        
							</div>
							
						</div>
					</div>
				</div>
	</div>
	</div></div>
<%@include file="footer.html" %>	

<script>
	function reqRespSubmit(){
		document.reqRespHist.failedLoginsUserSearchKey.value = document.failedUserLogins.failedLoginsUserSearchKey.value;
		document.reqRespHist.failedLoginsFromDt.value = document.failedUserLogins.failedLoginsFromDt.value;
		document.reqRespHist.failedLoginsToDt.value = document.failedUserLogins.failedLoginsToDt.value;
		return true;
	}
	
	function failedLoginsSubmit(){
		document.failedUserLogins.reqRespUserSearchKey.value = document.reqRespHist.reqRespUserSearchKey.value;
		document.failedUserLogins.reqRespFromDt.value = document.reqRespHist.reqRespFromDt.value;
		document.failedUserLogins.reqRespToDt.value = document.reqRespHist.reqRespToDt.value;
		document.failedUserLogins.responseSearch.value = document.reqRespHist.responseSearch.value;
		document.failedUserLogins.recCount.value = $('#recCount').val();		
		return true;
	}
	
</script>	
</body>
</html>
