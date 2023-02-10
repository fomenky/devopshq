<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE HTML>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<title>aPersona - Policy Editor</title>
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

<script>
	$(function() {
		$( "#tabs" ).tabs();
		
		$( "#autoConfirmEndDate" ).datepicker();
	});
</script>

</head>
<body class="nof-centerBody">
<div style="height:100%; min-height:100%; position:relative;">
	<c:set var="selMenu" scope="request" value="apiSrvMgmt"/>
	<jsp:include page="header.jsp" />

	<div class="nof-centerContent">

      <div class="nof-clearfix nof-positioning ">
        <div class="nof-positioning TextObject" style="float: left; display:inline; width: 10px; ">
          <p style="text-align: right; margin-bottom: 0px;">&nbsp;</p>
        </div>
        <div id="Text129" class="nof-positioning TextObject" style="float: left; display: inline; width: 100%; margin-top: 9px; margin-left: 19px; ">
          <p style="margin-bottom: 0px;"><b><span style="font-size: 16px; font-weight: bold;">
          		aP-ASM - New Security Policy</span></b></p>
		  <br/>
          <p>Please fill in the form below to setup a security policy. The Policy Name and Key information is Required; all the other tabs are optional settings.</p>
        </div>
      </div>

      <div class="nof-positioning" style="width: 100%; margin-left: 8px; ">
	      <div class="boxLayout" style="width:100%;">
	      	<h2>Security Policy Name and Settings</h2>
				<form name="serverEditForm" id="serverEditForm" method="post" action="apiServerEdit.ap">
				<input type="hidden" name="serverId" value="${serverId}"/>
				<input type="hidden" name="providerId" value="${providerId}"/>
				
				<div class="nof-positioning logoCenter">
				<p><b><span style="color:#455e86; font-size: 14px; font-weight: bold;"><c:out value="${server.serverLabel}"/></span></b></p>
				</div>		
				<input type="button" class="buttonStyle" style="margin-left: 5px;" value=" Save " onclick="javascript:updServerIp();"/>				
				<input type="button" class="clearButtonStyle" style="margin-left: 28px;" value="Cancel" onclick="javascript:cancelEdit();"/>
				<c:if test="${IS_PRIMARY == 'N'}">
					<br/>
					<br/>
					<p style="margin-left: 28px;">
					<b>NOTE: This Server is a part of a security group. Please select the master server in the security group in order to modify the optional settings.</b></p>
				</c:if>
				<br/><br/>
               		<c:if test="${SEC_POLICY_EDIT_FAILED_MSG != null}">
                 		&nbsp;&nbsp;&nbsp;<span class="ap_error">${SEC_POLICY_EDIT_FAILED_MSG}</span>
					</c:if>
				<div id="tabs">
           			<ul>
						<li><a href="#serverNameKey">Policy Name &amp; Key</a></li>
						<c:if test="${IS_PRIMARY != 'N'}">						
							<li><a href="#countryFiltering">Country Based Filtering</a></li>
							<li><a href="#ipBlacklistFiltering">Threat Actor IP Blacklist Filtering</a></li>							
							<li><a href="#confirmMethod">Confirmation Method</a></li>
							<li><a href="#loginForensic">Policy Forensics</a></li>
						</c:if>
						<li><a href="#passcodeVerify">Passcode Verification Settings</a></li>
						<li><a href="#retryTimeout">Confirmation Retry &amp; Time-Out Settings</a></li>
               		</ul>  

               		<div id="serverNameKey" style="display:none;">
                 		<span class="ap_error">*</span>&nbsp;<b>Required Settings</b>
                 		
                		<br/><br/>
                 		<table class="ap_table  server_edit" width="100%" align="center">
                 			<tr class="ap_table_tr_odd" >
                 				<td>Policy Label:&nbsp;<span class="ap_error">*</span></td>
                 				<td><input type="text" required name="srvrLabel" id="srvrLabel" value="${server.serverLabel}" placeholder="ex: Websr#1 (PHP)"></td>
                 				<td>Policy Label (Internal Use)</td>
                 			</tr>
                 			<tr class="ap_table_tr_odd">
                 				<td>Service Name:&nbsp;<span class="ap_error">*</span></td>
                 				<td><input required type="text" name="svrServiceName" id="svrServiceName" value="${server.svrServiceName}"
                 						placeholder="ex: MyCompany Web Portal"></td>
                 				<td>Service Name for ID Verifications</td>
                 			</tr>
                 			<tr class="ap_table_tr_odd">
                 				<td>Application Server IP Validation:&nbsp;<span class="ap_error">*</span></td>
                 				<td>
                 				<textarea required name="serverPublicNatIp" id="serverPublicNatIp" 
                 					rows="4"
                 					cols="24"><c:out value="${server.serverPublicNatIp}"/></textarea>
                 				<td>Transactions will only be accepted from your application servers from the listed IPs.<br/>
                 					Enter the Public (NAT) IP and/or Private IP (One per row).<br/>
                 					Example:<br/>
                 					&nbsp;&nbsp;95.34.25.37<br/>
                 					&nbsp;&nbsp;10.5.1.*<br/>
							&nbsp;&nbsp;.*    [Will allow transactions from any server. It's OK for testing but not recommended for production.]<br/>
                 				    </td>
                 			</tr>
<%--                  			<tr class="ap_table_tr_even">
                 				<td>Private IP:&nbsp;<span class="ap_error">*</span></td>
                 				<td><input required type="text" name="serverPrivateIp" value="${server.serverPrivateIp}" 
                 						placeholder="x.x.x.x"></td>
                 				<td>Enter the Private IP Address of this server. </td>
                 			</tr>
 --%>
<%--                  			<tr class="ap_table_tr_odd">
                 				<td>Server Time Zone:</td>
                 				<td><select name="serverTimeZone" style="height: 24px;">
                                              <option value="EDT" ${server.serverTimeZone == 'EDT' ? 'selected' : ''}>(UTC-05:00) Eastern Time (US & Canada)</option>
                                              <option value="CDT" ${server.serverTimeZone == 'CDT' ? 'selected' : ''}>(UTC-06:00) Central Time (US & Canada)</option>
                                              <option value="MDT" ${server.serverTimeZone == 'MDT' ? 'selected' : ''}>(UTC-07:00) Mountain Time (US & Canada)</option>
                                              <option value="PDT" ${server.serverTimeZone == 'PDT' ? 'selected' : ''}>(UTC-08:00) Pacific Time (US & Canada)</option>
                                            </select>
                 				</td>
                 				<td>This time zone will be used when logging any failed transaction confirmations for this policy.</td>
                 			</tr>
 --%>                 			<tr class="ap_table_tr_odd">
                 				<td>Policy API Key:&nbsp;<span class="ap_error">*</span></td>
                 				<td><input required type="text" name="apiKey" id="apiKey" value="${server.apiKey}" 
                 						placeholder="Create a security policy key" pattern="[a-zA-Z0-9-]+"
                 						title="Please use only alpha numeric and/or dashes"></td>
                 				<td>Create a strong API Security Policy Key. (Alpha, Numeric & '-' only. No special characters)</td>
                 			</tr>
                 		</table>
               		</div>               		
 
            		<div id="countryFiltering" style="display:none; padding:0">
            			<b>Optional Settings:&nbsp;Country Filter Settings</b>
            			<br/> <br/>
						<table class="ap_table leftAlignTable" width="100%" align="center">

							<tr class="ap_table_tr_odd">
								<td width="10%"><b>Country Filter:</b></td>
								<td width="25%">
									<select name="countryBypassFilter" style="height: 24px;">
										<option value="Off"  ${server.isCountryFilter == 'Off' ? 'selected' : ''} >Off</option>
										<option value="On"  ${server.isCountryFilter == 'On' ? 'selected' : ''} >On</option>
									</select>
								</td>
								<td width="65%" style="font-size: 10px;">
									If Country Filter is set to Off, no filtering will take place. If On, then the filter will be active.</td>
							</tr>
							<tr class="ap_table_tr_odd">
								<td width="10%"><b>Blacklist Country Bypass Options:</b></td>
								<td width="25%">
									<select name="countryBypassOption" style="height: 24px;">
										<option value="allowForTime"  ${server.blacklistCountryBypassOption == 'allowForTime' ? 'selected' : ''} >Allow Bypass for a User for a Time Period</option>
										<option value="allowWithChallenge"  ${server.blacklistCountryBypassOption == 'allowWithChallenge' ? 'selected' : ''} >Allow Bypass for a User for a Time Period With Challenge</option>
										<option value="neverAllow"  ${server.blacklistCountryBypassOption == 'neverAllow' ? 'selected' : ''} >Do not Allow Bypass of Blacklisted Countries</option>
									</select>
									<br/>
									<br/>
									<span class="ap_error"><i>NOTE: Blocked Countries cannot be Bypassed.</i></span>
								</td>
								<td width="65%" style="font-size: 10px;">
								
								<ul style="list-style-position: inside; padding-left:0;">
									<li><b>Allow Bypass for a User for a Time Period (Default):</b>ASM will return Code: "203-Country location blocked" unless the specified Blacklisted country is Bypassed for a time period by ASM Support via User Management. If the Blacklisted Country is Bypassed for a specific User, ASM will allow the transaction to continue through the Country FIlter "unchallenged" to the next step in the Security Policy. If Blacklisted Country is not Bypassed for a specific user, ASM will return: "203-Country location blocked". In this case your Application should push the user to a Help/Info message/page, that instructs them to contact help desk to obtain a temporary pass, so that ASM Support can decide if a Bypass of the specific Blacklisted country is warranted for a period of time.<br/><br/></li>
									
									<li><b>Allow Bypass for a User for a Time Period With Challenge:</b> This mode is the same as the mode above, except ASM will return Code: "202 (OPT Challenge)" every time the Blacklisted Country is Bypassed for a specific user via ASM User Management.<br/><br/></li>
									<li><b>Do not Allow Bypass of Blacklisted Countries:</b> ASM will return Code: "203-Country location blocked." Application should return user to the login page or other Help/Info page. <span class="ap_error"><i>(This Option cannot be Bypassed via the ASM User Management! It effectively makes all Blacklisted Countries "Blocked".)</i></span></li>
								</ul>
								<i>Note: All Blocked Countries will cause ASM to return Code: "203-Country location blocked." Application should return user to the login page or other Help/Info page.</i>
								</td>
							</tr>
						</table>
						<table class="ap_table leftAlignTable" width="100%" align="left">
							<tr class="ap_table_tr_grey">
								<td width="13%"><b>Country Settings:</b></td>
								<td width="25%">
									<input id="greenHeader" type="radio" style="display:none" checked="checked"/> <label id="green">&nbsp;&nbsp;&nbsp;</label>Whitelisted
									<input id="yellowHeader" type="radio" style="display:none" checked="checked"/> <label id="yellow">&nbsp;&nbsp;&nbsp;</label>Blacklisted
									<input id="redHeader" type="radio" style="display:none" checked="checked"/> <label id="red">&nbsp;&nbsp;&nbsp;</label>Blocked
								</td>
								<td width="62%" valign="middle">Select radio button by each country corresponding to the color chart. Example, to Whitelist United States 									
									<input type="radio" style="display:none" checked="checked"/><label id="green"></label>
									<input type="radio" style="display:none" /><label id="yellow"></label>
									<input type="radio" style="display:none" /><label id="red"></label>
								</td>
							</tr>
							<tr class="ap_table_tr_odd">
								<td colspan="3">
									<br/>
									Quick Edits:
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<input type="button" name="allWhitelisted" value="Make all countries Whitelisted"  class="greenButtonStyle" onclick="javascript:autoCheckAllCountries('green');"/>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<input type="button" name="allBlacklisted" value="Make all countries Blacklisted" class="yellowButtonStyle" onclick="javascript:autoCheckAllCountries('yellow');"/>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<input type="button" name="allBlocked" value="Make all countries Blocked" class="redButtonStyle" onclick="javascript:autoCheckAllCountries('red');"/>
								</td>
							</tr>
						</table>
						<!--  Countries list -->
						<table class="ap_table leftAlignTable" width="100%" align="left">
<%-- 							<c:forEach var="country" items="${countryBypassList}" varStatus="loop">
								<tr class="ap_table_tr_odd">
									<td><span style="width:200px">
										<input id="greenId_${country.code2}" type="radio" style="display:none" name="nm_${country.code2}" value="WHITE"/> <label id="green" for="greenId_${country.code2}">&nbsp;&nbsp;&nbsp;</label>
										<input id="yellowId_${country.code2}" type="radio" style="display:none" checked="checked" name="nm_${country.code2}" value="BLACK"/> <label id="yellow" for="yellowId_${country.code2}">&nbsp;&nbsp;&nbsp;</label>
										<input id="redId_${country.code2}" type="radio" style="display:none" name="nm_${country.code2}" value="BLOCK"/> <label id="red" for="redId_${country.code2}">&nbsp;&nbsp;&nbsp;</label>								
									</span>
									${country.countryName}</td>
								</tr>
							</c:forEach> --%>
							<c:forEach begin="0" end="${(fn:length(countryBypassList)-1)/3}" varStatus="outer">
								<tr class="ap_table_tr_odd">
									<c:forEach begin="1" end="3" varStatus="inner">
									<c:set var="country" value="${countryBypassList[((outer.count-1)*3 + inner.count) -1]}" />	
										<td  style="font-size:9px;">
											<input id="greenId_${country.code2}" type="radio" style="display:none" ${country.bypassSetting == 'WHITE' ? 'checked' : ''}  name="ctrySetting_${country.code2}" value="WHITE"/> <label id="green" for="greenId_${country.code2}">&nbsp;&nbsp;&nbsp;</label>
											<input id="yellowId_${country.code2}" type="radio" style="display:none" name="ctrySetting_${country.code2}" value="BLACK" ${country.bypassSetting == 'BLACK' ? 'checked' : ''}/> <label id="yellow" for="yellowId_${country.code2}">&nbsp;&nbsp;&nbsp;</label>
											<input id="redId_${country.code2}" type="radio" style="display:none" name="ctrySetting_${country.code2}" value="BLOCK" ${country.bypassSetting == 'BLOCK' ? 'checked' : ''}/> <label id="red" for="redId_${country.code2}">&nbsp;&nbsp;&nbsp;</label>								
											<span style="display:inline; margin-left:15px; word-wrap:break-word;">${country.countryName}</span>
										</td>
									</c:forEach>
								</tr>
							</c:forEach>
						</table>
					</div>

               		<div id="ipBlacklistFiltering" style="display:none;">
                 		<b>Optional Settings:&nbsp;Threat Actor IP Blacklist Settings</b>
                 		<br/> <br/>
						<table class="ap_table leftAlignTable" width="100%" align="center">
							<tr class="ap_table_tr_odd">
								<td width="10%"><b>Threat Actor IP Blacklist Filter:</b></td>
								<td width="25%">
									<select name="ipBlacklistFilter" style="height: 24px;">
										<option value="Off"  ${server.isIpBlacklistFilter == 'Off' ? 'selected' : ''} >Off</option>
										<option value="On"  ${server.isIpBlacklistFilter == 'On' ? 'selected' : ''} >On</option>
									</select>
								</td>
								<td width="65%" style="font-size: 10px;">
									If Threat Actor IP Blacklist Filter is set to Off, no filtering will take place. If On, then the filter will be active.</td>
							</tr>
							<tr class="ap_table_tr_odd">
								<td width="10%"><b>Support Bypass Options:</b></td>
								<td width="25%">
									<select name="ipBlacklistBypassOption" style="height: 24px;">
										<option value="neverAllow"  ${server.ipBlacklistBypassOption == 'neverAllow' ? 'selected' : ''} >Do not Allow Bypass of Threat Actor IP Blacklisted Filter</option>
										<option value="allowForTime"  ${server.ipBlacklistBypassOption == 'allowForTime' ? 'selected' : ''} >Allow Bypass for a User for a Time Period</option>
										<option value="allowWithChallenge"  ${server.ipBlacklistBypassOption == 'allowWithChallenge' ? 'selected' : ''} >Allow Bypass for a User for a Time Period With Challenge</option>
									</select>
								</td>
								<td width="65%" style="font-size: 10px;">								
								<ul style="list-style-position: inside; padding-left:0;">
									<li><b>Allow Bypass for a User for a Time Period (NOT RECOMMENDED):</b>ASM will return Code: "203-IP Blocked" unless the Threat Actor IP Blacklist Filter is Bypassed for a time period by ASM Support via User Management. If the Threat Actor IP Blacklist Filter is Bypassed for a specific User, ASM will allow the transaction to continue through the Country FIlter "unchallenged" to the next step in the Security Policy. If Threat Actot IP Blacklist Filter is not Bypassed for a specific user, ASM will return: "203-IP blocked". In this case your Application should push the user to a Help/Info message/page, that instructs them to contact help desk to obtain a temporary pass, so that ASM Support can decide if a Bypass of the Threat Actor IP Blacklist Filter is warranted for a period of time.<br/><br/></li>
									<li><b>Allow Bypass for a User for a Time Period With Challenge:</b> This mode is the same as the mode above, except ASM will return Code: "202 (OPT Challenge)" every time the Threat Actor IP Blacklist Filter is Bypassed for a specific user via ASM User Management.<br/><br/></li>
									<li><b>Do not Allow Bypass of Threat Actor IP Blacklist Filter (Default- RECOMMENDED):</b> ASM will return Code: "203-IP Blocked". Application should return user to the login page or other Help/Info page. <span class="ap_error"><i>(This Option cannot be Bypassed via the ASM User Management!)</i></span></li>
								</ul>
								</td>
							</tr>
						</table>        		           
               		</div>
               		
               		<div id="confirmMethod" style="display:none;">
                 		<b>Optional Settings:&nbsp;Policy Mode (Select One)</b>
                 		<br/> <br/>
                 		<table class="ap_table  server_edit confirmationLabel" width="100%" align="center" style="text-align:left;">
                 			<tr class="${(server.confirmMethod == 'DEFAULT_LOGIN' || server.confirmMethod == null) ? 'selectedVal' : 'ap_table_tr_odd'}">
                 				<td align="left"><b>Active Forensic Mode:</b></td>
                 				<td align="left"><input type="radio" style="margin:0;width:50px;" name="loginConfirmMethod" 
                 								${(server.confirmMethod == 'DEFAULT_LOGIN' || server.confirmMethod == null) ? 'checked' : ''} value="DEFAULT_LOGIN" /> 
                 						<i>This is the Default mode. All transactions will immediately route to Policy Forensics.
                  						&nbsp;&nbsp;
                 						<input type="checkbox" name=apiLearnOverride value="1" style="margin:0;width:20px;" ${server.learnOverride == '1' ? 'checked' : ''}/>Allow API driven One Time Learning.
                  						</i>
                 						</td>
                 			</tr>
                 			<tr class="${(server.confirmMethod == 'FORENSIC_AFTER_N') ? 'selectedVal' : 'ap_table_tr_odd'}">
                 				<td align="left"><b>Learning Mode - Auto Confirm:</b></td>
                 				<td align="left"><input type="radio" style="margin:0;width:50px;" name="loginConfirmMethod" 
                 								${(server.confirmMethod == 'FORENSIC_AFTER_N') ? 'checked' : ''} value="FORENSIC_AFTER_N"/>
                 					
                 					<select name="autoConfirmType" id="autoConfirmType" style="height: 24px;">
                                              <option value="UNTIL" ${server.autoConfType == 'UNTIL' ? 'selected' : ''} >Until</option>
                                              <option value="FOREVER" ${server.autoConfType == 'FOREVER' ? 'selected' : ''}>Forever</option>
                                  	</select>
                                  	<fmt:formatDate 
                                  		value="${server.autoConfEndDate}"  
						                type="date" 
						                pattern="MM/dd/yyyy"
						                var="autoConfFmtDate" />
                                  	<input type="name" id="autoConfirmEndDate" 
                                  			name="autoConfirmEndDate" size="6" maxlength="12" 
                                  			value="${autoConfFmtDate}" 
                                  			placeholder="mm/dd/yyyy" style="width: 100px;" >
                 				<i>Re-engage Active Mode after this # of User transactions:</i>
                 				<select name="forensicConfirmAfterLogingNum" style="height: 24px;">
                                              <option value="1" ${server.autoConfLogins == '1' ? 'selected' : ''}>1</option>
                                              <option value="2" ${server.autoConfLogins == '2' ? 'selected' : ''}>2</option>
                                              <option value="3" ${server.autoConfLogins == '3' ? 'selected' : ''}>3</option>
                                              <option value="4" ${server.autoConfLogins == '4' ? 'selected' : ''}>4</option>
                                              <option value="5" ${server.autoConfLogins == '5' ? 'selected' : ''}>5</option>
                                              <option value="10" ${server.autoConfLogins == '10' ? 'selected' : ''}>10</option>
                                              <option value="15" ${server.autoConfLogins == '15' ? 'selected' : ''}>15</option>
                                              <option value="20" ${server.autoConfLogins == '20' ? 'selected' : ''}>20</option>
                                              <option value="0" ${(server.autoConfLogins == null || server.autoConfLogins == '0') ? 'selected' : ''}>N/A</option>
                                            </select>
                 				</td>
                 			</tr>
<%--                  			<tr class="${(server.confirmMethod == 'FORCE_FORENSIC') ? 'selectedVal' : 'ap_table_tr_odd'}">
                 				<td><b>Force Forensic Confirmation Always:</b></td>
                 				<td><input type="radio" style="margin:0;width:50px;" name="loginConfirmMethod" 
                 							${(server.confirmMethod == 'FORCE_FORENSIC') ? 'checked' : ''} value="FORCE_FORENSIC"/>
                 				<i>This setting will force a One Time Passcode to be sent to the User for all transactions for this Policy.</i></td>
                 			</tr> --%>
                 			<tr class="${(server.confirmMethod == 'MAINTENANCE_MODE') ? 'selectedVal' : 'ap_table_tr_odd'}">
                 				<td><b>Maintenance Mode - No Confirmations:</b></td>
                 				<td><input type="radio" style="margin:0;width:50px;" name="loginConfirmMethod" 
                 							${(server.confirmMethod == 'MAINTENANCE_MODE') ? 'checked' : ''} value="MAINTENANCE_MODE"/>
                 				<i>Warning, this setting disables this Policy.</i></td>
                 			</tr>
                 		</table>                 		                 		           
               		</div>
               		<div id="loginForensic" style="display:none; overflow-y: scroll; height:400px;">
               			<b>Optional Settings:&nbsp;</b>
                 		<br/><br/>                 		
                 		<table class="ap_table leftAlignTable" width="100%" align="center">
<!--                  			<tr class="ap_table_tr_odd">
                 				<td><b>Login Forensic Key Security Domain:</b></td>
                 				<td colspan="2">
									<select name="compareForensicType" style="height: 24px;">
                                             <option value="COMPARE_ALL_SERVERS" ${server.forensicDomain == 'COMPARE_ALL_SERVERS' ? 'selected' : ''}>
                                             							Compare Forensics across all Servers</option>
                                             <option value="COMPARE_THIS_SERVER_ONLY" ${server.forensicDomain == 'COMPARE_THIS_SERVER_ONLY' ? 'selected' : ''}>
                                             							Compare Foresics for THIS SERVER ONLY</option>
                                             <option value="COMPARE_SERVER_GROUP" ${server.forensicDomain == 'COMPARE_SERVER_GROUP' ? 'selected' : ''}>
                                             							Compare Forensics from a Group of Servers</option>
                                    </select>
								</td>

 							</tr>
 -->                 		
<!--  							<tr class="ap_table_tr_odd">
                 				<td  style="margin: 0px; padding: 0px;" colspan="3"><hr/></td>
                 			</tr>
 -->                 			<tr class="ap_table_tr_odd">
                 				<td width="10%"><b>MITM Checking:</b></td>
                 				<td width="50%">
                 					<select name="mitmChecking" style="height: 24px;">
                                        <option value="Off" ${server.mitmChecking == 'Off' ? 'selected' : ''}>Off</option>
                                        <option value="On"  ${server.mitmChecking == 'On' ? 'selected' : ''}>On</option>
                                        <option value="Monitor" ${server.mitmChecking == 'Monitor' ? 'selected' : ''}>Monitor</option>
                                    </select>
                 				</td>
                 				<td width="40%" style="font-size: 10px; font-style: italic;">
                 				If set to On, the aPersona ASM will send API response code 203 in an IP Conflict/MITM situation. If set to Off, then IP Conflict/MITM situations will be ignored.
                 				</td>                 				
							</tr>


<!--  							<tr class="ap_table_tr_odd">
                 				<td  style="margin: 0px; padding: 0px;" colspan="3"><hr/></td>
                 			</tr>
 -->                 			<tr class="ap_table_tr_odd">
                 				<td><b>Policy Forensic Level:</b></td>
                 				<td>
                 				    <b>Browser Clients (PC & Mobile) / Standard API</b>
                 				    <br/>
                 				    <div style="margin-top: 5px;">
									<select name="loginForensicMethod" style="height: 24px;">
									<option value="LEVEL_1" ${server.forensicMethod == 'LEVEL_1' ? 'selected' : ''}>
									Level 1 (DevKey1 "OR" NAT-IP "OR" OTTKey)</option>
									<option value="LEVEL_2" ${server.forensicMethod == 'LEVEL_2' ? 'selected' : ''}>
									Level 2 (DevKey1 "AND" ISPGeo) "OR" (NAT-IP) "OR" (OTTKey)</option>
									<option value="LEVEL_3" ${server.forensicMethod == 'LEVEL_3' ? 'selected' : ''}>
									Level 3 (DevKey1 "AND" NAT-IP) "OR" (OTTKey)</option>
									<option value="LEVEL_4" ${server.forensicMethod == 'LEVEL_4' ? 'selected' : ''}>
									Level 4 (DevKey2 "AND" NAT-IP) "OR" (ISPGeo "AND" OTTKey)</option>
									<option value="LEVEL_5" ${server.forensicMethod == 'LEVEL_5' ? 'selected' : ''}>
									Level 5 (DevKey2 "AND" NAT-IP) "OR" (NAT-IP "AND" OTTKey)</option>
									<option value="LEVEL_6" ${server.forensicMethod == 'LEVEL_6' ? 'selected' : ''}>
									Level 6 (DevKey2 "AND" NAT-IP "AND" OTTKey)</option>
									<option value="LEVEL_7" ${server.forensicMethod == 'LEVEL_7' ? 'selected' : ''}>
									Level 7 (Force Confirmation Always)</option>	
									</select>
                                    </div>
                                    <br/>
                                    <br/>
									<b>Mobile (Native aPersona SDK API) Application Clients</b>
									<br/>
									<div style="margin-top: 5px;">
									<input type="checkbox" value="Y" name="restrictJailBroken"
                                    	${server.restrictJailBroken == 'Y' ? 'checked' : ''}/>
                                    	&nbsp;&nbsp;Challenge user with "Jail-Broken" device
                                    <br/>
                 					<select name="mobileForensicMethod" style="height: 24px;">
                                        <option value="LEVEL_1" ${server.mobForensicLevel == 'LEVEL_1' ? 'selected' : ''}>
                                        							Level 1 (DevKey "OR" NAT-IP "OR" OTTKey "OR" IoTKey)</option>
                                        <option value="LEVEL_2" ${server.mobForensicLevel == 'LEVEL_2' ? 'selected' : ''}>
                                        							Level 2 (DevKey "AND" ISPGeo) "OR" (OTTKey) "OR" (IoTKey "AND" ISPGeo)</option>
                                        <option value="LEVEL_3" ${server.mobForensicLevel == 'LEVEL_3' ? 'selected' : ''}>
                                        							Level 3 (DevKey "AND" OTTKey) "OR" (IoTKey "AND" OTTKey) "OR" (DevKey "AND" IoTKey)</option>
                                        <option value="LEVEL_7" ${server.mobForensicLevel == 'LEVEL_7' ? 'selected' : ''}>
                                        							Force Confirmation Always</option>                                        							
                                    </select>
                                    </div>
									<br/>
                                    <div style="margin-top: 5px;">
<%--                                      <input type="checkbox" value="Y" name="forceForencicCheckBox"
                                    	${server.forceEnhanced == 'Y' ? 'checked' : ''}/>&nbsp;
 --%>
<%--                                      	Force Level 2 from here:
	                                    <input type="text" name="forceForencicIpList" size="50" value="${server.forceEnhCidr}" 
	                                    placeholder="Enter IP's separated by commas. e.g. 10.5.1.*, 95.34.45.3"/>
 --%>                                    	 
 
 <hr/>
 <br/>
 IPv4 NAT IP Mask:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 <select id="natIpMask" name="natIpMask">
 	<option value="4" ${server.natIpMask == '4' ? 'selected' : ''}>[ *.*.*.* ]</option>
 	<option value="3" ${server.natIpMask == '3' ? 'selected' : ''}>[ *.*.*._ ]</option>
 </select>
<br/>
<br/>
 IPv4 ISP Geo Mask:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 <select id="ispGeoMask" name="ispGeoMask">
 	<option value="3" ${server.ispGeoMask == '3' ? 'selected' : ''}>[ *.*.*._ ]</option>
 	<option value="2" ${server.ispGeoMask == '2' ? 'selected' : ''}>[ *.*._._ ]</option>
 </select>
 <br/>
 <br/>
 <b><u>NOTE:</u></b> Changing IP Mask settings resets forensic! Increased user challenge rates may occur until learned.
 <br/>
  <hr/>
  
 									<br/>IP Bypass Filter:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	                                    
	                                    <div>
	                                    
	                                    <input type="text" name="bypassIps" size="50" value="${server.bypass}" 
	                                    	placeholder="Enter IP's separated by commas. e.g. 10.5.1.*, 95.34.45.3"/>
										<br/>
										<select name=bypassIpLevel style="height: 24px;">
											<option value="-1" ${server.bypassIpLevel == '-1' ? 'selected' : ''}>Do not challenge</option>
	                                        <option value="LEVEL_1" ${server.bypassIpLevel == 'LEVEL_1' ? 'selected' : ''}>
	                                        							Level 1</option>
	                                        <option value="LEVEL_2" ${server.bypassIpLevel == 'LEVEL_2' ? 'selected' : ''}>
	                                        							Level 2</option>
	                                        <option value="LEVEL_3" ${server.bypassIpLevel == 'LEVEL_3' ? 'selected' : ''}>
	                                        							Level 3</option>
	                                        <option value="LEVEL_4" ${server.bypassIpLevel == 'LEVEL_4' ? 'selected' : ''}>
	                                        							Level 4</option>
	                                        <option value="LEVEL_5" ${server.bypassIpLevel == 'LEVEL_5' ? 'selected' : ''}>
	                                        							Level 5</option>
	                                        <option value="LEVEL_6" ${server.bypassIpLevel == 'LEVEL_6' ? 'selected' : ''}>
	                                        							Level 6</option>
	                                        <option value="LEVEL_7" ${server.bypassIpLevel == 'LEVEL_7' ? 'selected' : ''}>
	                                        							Force Confirmation Always</option>	
                                    	</select>
                                    </div>
                                    </div>
                                    <br/>
                 				</td>
                 				<td width="35%" style="font-size: 10px;">
                 				Policy Forensic Levels are provided for different Client types because the specific factors may be stronger for one device type than another and different clients have different factors available for evaluation.
<br/><br/>
For example:<br/>
The Mobile (Native SDK) Device factor is encrypted and protected on the Mobile Device which makes it a stronger factor than the Browser Client Device factor.
<br/><br/>The Mobile (Native) SDK includes Internet of Things (IoT) factors that are not available on the Browser Clients.
<br/><br/>The default IPv4 NAT IP Mask is to evaluate the entire IP (*.*.*.*). Using the entire IP defines a single global location. You may make the IP evalution a litte less strong by using the first three parts (*.*.*._). Using three parts creates on average a global location of approximately 10 miles in diameter that is managed by a single ISP.
<br/><br/>The default IPv4 ISP Geo Mask is to evaluate the first three parts of the IP (*.*.*._). Using three parts creates on average a global location of approximately 10 miles in diameter that is managed by a single ISP.. You may make the IP evalution a litte less strong by using the first two parts (*.*._._). Using two parts creates on average a global location of approximately 20 miles in diameter that is managed by a single ISP.

                 				</td>                 				
                 			</tr>	
<!--                  			<tr class="ap_table_tr_odd">
                 				<td  style="margin: 0px; padding: 0px;" colspan="3"><hr/></td>
                 			</tr>
 -->
 
                  			<tr class="ap_table_tr_odd">
                 				<td><b>Application Defined Fields:</b></td>
                 				<td colspan="1">
                 				<p align="center">
                 				<b>Policy Forensic Level</b>
                 				<br/>
                 				<br/>
                 				<select style="align:center;" name="addForensicLevelCond" style="height: 24px;">
                                        <option value="OR" ${server.addForensicLevelCond == 'OR' ? 'selected' : ''}>
                                        							"OR"</option>
                                        <option value="AND" ${server.addForensicLevelCond == 'AND' ? 'selected' : ''}>
                                        							"AND"</option>
                                    </select>
                                    <hr/>

                                     <input type="checkbox" value="Y" name="applField1Sel"
                                    	${server.applField1Sel == 'Y' ? 'checked' : ''}/>
                                    	&nbsp;&nbsp;
                                    	Application Defined Field 1:   
                                    	&nbsp;&nbsp;&nbsp;&nbsp;
                                    	
                                    	<select style="align:center;" id="applField1Operator" name="applField1Operator" style="height: 24px;" onchange="javascript:appFieldChange(this)">
	                                        <option value="=" ${server.applField1Operator == '=' ? 'selected' : ''}>&nbsp;&nbsp;  =  &nbsp;&nbsp;</option>
	                                        <option value=">" ${server.applField1Operator == '>' ? 'selected' : ''}>&nbsp;&nbsp;  &gt;  &nbsp;&nbsp;</option>
											<option value="<" ${server.applField1Operator == '<' ? 'selected' : ''}>&nbsp;&nbsp;  &lt;  &nbsp;&nbsp;</option>
											<option value="Contains" ${server.applField1Operator == 'Contains' ? 'selected' : ''}>Contains</option>
 											<option value="Cognitive" ${server.applField1Operator == 'Cognitive' ? 'selected' : ''}>Cognitive Appl' Behavior</option>
                                    	</select>
										&nbsp;&nbsp;&nbsp;&nbsp;
	                                    <input type="text" id="applField1Value" name="applField1Value" size="20" value="${server.applField1Value}" 
	                                    placeholder="Value here"/>
	                                    
			                 			<div align="center">
			                 			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -->
			                 			<select style="align:center;" name="applFieldsCondition" style="height: 24px;">
			                                        <option value="OR" ${server.applFieldsCondition == 'OR' ? 'selected' : ''}>
			                                        							"OR"</option>
			                                        <option value="AND" ${server.applFieldsCondition == 'AND' ? 'selected' : ''}>
			                                        							"AND"</option>
			                                    </select>
			                            </div>
			                                    
                                     <input type="checkbox" value="Y" name="applField2Sel"
                                    	${server.applField2Sel == 'Y' ? 'checked' : ''}/>
                                    	&nbsp;&nbsp;
                                    	Application Defined Field 2:   
                                    	&nbsp;&nbsp;&nbsp;&nbsp;
                                    	
                                    	<select style="align:center;" id="applField2Operator" name="applField2Operator" style="height: 24px;" onchange="javascript:appFieldChange(this);">
	                                        <option value="=" ${server.applField2Operator == '=' ? 'selected' : ''}>&nbsp;&nbsp;  =  &nbsp;&nbsp;</option>
	                                        <option value=">" ${server.applField2Operator == '>' ? 'selected' : ''}>&nbsp;&nbsp;  &gt;  &nbsp;&nbsp;</option>
											<option value="<" ${server.applField2Operator == '<' ? 'selected' : ''}>&nbsp;&nbsp;  &lt;  &nbsp;&nbsp;</option>
											<option value="Contains" ${server.applField2Operator == 'Contains' ? 'selected' : ''}>Contains</option>
 											<option value="Cognitive" ${server.applField2Operator == 'Cognitive' ? 'selected' : ''}>Cognitive Appl' Behavior</option>										
                                     	</select>
										&nbsp;&nbsp;&nbsp;&nbsp;
	                                    <input type="text" id="applField2Value" name="applField2Value" size="20" value="${server.applField2Value}" 
	                                    placeholder="Value here"/>
	                                    </p>
	                           </td>
                 				<td>"OR" below "Policy Forensic Level" will make the policy less restrictive, "AND" will make the policy more restrictive.
<br/>
NOTES: IF af1 OR af2 are null or missing, ASM WILL ACT AS IF THE APPLICATION DEFINED FIELD IS UNCHECKED. THIS ENABLES A SINGLE SECURITY POLICY TO BE USED FOR BOTH LOGIN AND POST LOGIN (HIGHER RISK) VALIDATIONS. Simply leave af1 & af2 blank at login; include af1 &/or af2 post login.
<br/><br/> The Cognitive Application Behavior setting will accept any set/string of application specific data. For lower risk transactions send fewer sets, for higher risk, send more strings.
<br/><br/> For example: If a banking wire transfer is low risk, send "Wire/FromAccount". As the transaction risk increases, include more details: "Wire/FromAccount/BnkRtng/ToAccount", and so on.
<br/><br/> Strings for Application Cognitive Behavior are one-way hashed/encrypted. The actual data sent is not stored in ASM.
                 				</td>
                 			</tr>	

                  			<tr class="ap_table_tr_odd">
                 				<td><b>Policy &#8220;Time to Live (TTL)&#8221;:</b></td>
                 				<td>
                 				
                 				<table  style="margin:0px; padding:0px; border-collapse: collapse; border-style: hidden">
                 					<tr>
                 						<td colspan="2">
                 							<input type="radio" name="forensicTtlAutoLearn" value="Y"
                 							   ${server.ttlAutoLearn != 'N' ? 'checked' : ''} />&nbsp;&nbsp;&nbsp;<b>Auto Learning TTL</b>
                 						</td>
                 						<td>
                 							<table style="margin:0px; padding:0px; border-collapse: collapse; border-style: hidden">
                 							   <tr style="border-collapse: collapse; border-style: hidden">
			                 						<td style="text-align:left;">TTL Maximum (days)</td>
			                 						<td><input type="text" name="forensicTtlAutoStart" 
			                 								size="4" maxlength="10"	value="${server.ttlAutoMax==null ? '120' : server.ttlAutoMax}"></td>
			                 					</tr>
			                 					<tr style="border-collapse: collapse; border-style: hidden">
			                 						<td style="text-align:left;">TTL Minimum (days)</td>
			                 						<td><input type="text" name="forensicTtlAutoMin" 
			                 								size="4" maxlength="10"	value="${server.ttlAutoMin==null ? '5' : server.ttlAutoMin}"></td>
			                 					</tr>                 					
			                 					<tr style="border-collapse: collapse; border-style: hidden">
			                 						<td style="text-align:left;">TTL Grace (days)</td>
			                 						<td><input type="text" name="forensicTtlAutoPadding" 
			                 								size="4" maxlength="10"	value="${server.ttlAutoPadding==null ? '2' : server.ttlAutoPadding}"></td>
			                 					</tr>
                 							</table>
                 						</td>
                 					</tr>
                 					<tr>
                 						<td colspan="2">
                 							<input type="radio" name="forensicTtlAutoLearn" value="N"
                 							   ${server.ttlAutoLearn=='N' ? 'checked' : ''}/>&nbsp;&nbsp;&nbsp;<b>Days between Trans.</b>
                 						</td>
                 						<td>
                 				<table class="innerTable" style="margin:0px; padding:0px; border-collapse: collapse; border-style: hidden">
                 						<tr style="border-collapse: collapse; border-style: hidden">
                 							<td></td>
                 							<td>1st</td>
                 							<td>2nd</td>
                 							<td>3rd-Nth</td>
                 							<td></td>                 							
                 						</tr>
                 						<tr style="border-collapse: collapse; border-style: hidden">
                 							<td style="text-align:left;">Browser: PC & Mobile</td>
                 							<td><input type="text" name="forensicTimeLivePcFirst" 
                 								size="4" maxlength="10"	value="${server.pcTimeout1==null ? '120' : server.pcTimeout1}"></td>
                 							<td><input type="text" name="forensicTimeLivePcSecond" 
                 								size="4" maxlength="10"	value="${server.pcTimeout2==null ? '120' : server.pcTimeout2}"></td>
                 							<td><input type="text" name="forensicTimeLivePcThird" 
                 								size="4" maxlength="10"	value="${server.pcTimeout3==null ? '120' : server.pcTimeout3}"></td>
                 							<td><a style="color:blue;" href="javascript:setPcTimeoutDefaults();">defaults</a>	
                 						</tr>
										<tr style="border-collapse: collapse; border-style: hidden">
											<td style="text-align:left;">Mobile Native SDK:</td>
                 							<td><input type="text" name="forensicTimeLiveMobileFirst" 
                 								size="4" maxlength="10"	value="${server.mobileTimeout1==null ? '120' : server.mobileTimeout1}"></td>
                 							<td><input type="text" name="forensicTimeLiveMobileSecond" 
                 								size="4" maxlength="10"	value="${server.mobileTimeout2==null ? '120' : server.mobileTimeout2}"></td>
                 							<td><input type="text" name="forensicTimeLiveMobileThird" 
                 								size="4" maxlength="10"	value="${server.mobileTimeout3==null ? '120' : server.mobileTimeout3}"></td>
                 							<td><a style="color:blue;" href="javascript:setMobileTimeoutDefaults();">defaults</a>									
										</tr>                 						
                 					</table>
                 						</td>
                 					</tr>
                 					
                 				</table>

                 				</td>
								
                 				<td style="font-size: 10px;">
                 				<table style="margin:0px; padding:0px; border-collapse: collapse; border-style: hidden">
                 					<tr><td>
                 					&nbsp;The Auto Learning TTL mode enables aPersona ASM to dynamically learn and set the TTL for each user's device based on the typical time-frames the device is used against this policy. The TTL Max (days) sets the upper limit. TTL Minimum (days) sets the lower limit. The TTL Grace (days) provides a buffer of extra days that will be added to the calculated average TTL of a device.
Auto Learning TTL does not recalculate a new average TTL of a device if it used again within a 24 hr period. This prevents multiple logins within any given day from artificially driving down a device TTL Average.
                 					</td></tr>
                 					<tr><td>
                 					&nbsp;In Days between Trans. mode if the numbers entered are 15,30, 45, then: After the first detection of a new Device and/or Network, the Poplicy Forensics will be kept for 15 days. If the User logs in a 2nd time from the same Device and/or Network within 15 days, then the Policy Forensics will be kept for 30 days, and so on. Settings are provided for both PC and Mobile type devices.
                 					</td></tr>
                 					
                 				</table>
                 				</td>
                 			</tr>

                 			</tr>
                 		</table>                 		                 	
               		</div>
               		
               		<div id="passcodeVerify" style="display:none;">
               		<b>Optional Settings:&nbsp;</b>
               		<br/><br/>
	               		<table class="ap_table leftAlignTable" width="100%">
	               			<tr class="ap_table_tr_odd">
	               				<td><b>One Time Passcode Length:</b></td>
	               				<td>
	               					<select name="otpLength" style="height: 24px;">
                                         <option value="4" ${server.otpLength == '4' ? 'selected' : ''}>4</option>
                                         <option value="5" ${server.otpLength == '5' ? 'selected' : ''}>5</option>
                                         <option value="6" ${server.otpLength == '6' ? 'selected' : ''}>6</option>
                                         <option value="7" ${server.otpLength == '7' ? 'selected' : ''}>7</option>
                                         <option value="8" ${server.otpLength == '8' ? 'selected' : ''}>8</option>                                         
                                    </select>                                    
	               				</td>
	               				<td colspan="2">Select the length of the One Time Passcode. Default value is '4'.
	               				</td>
	               			</tr>

	               			<tr class="ap_table_tr_odd">
	               				<td><b>End User OTP Verification Method Priority:</b></td>
	               				<td colspan="2">
	               					<select name="passwdVerifyFirstMethod" style="height: 24px;">
                                         <option value="EMAIL" ${server.otpVerifyMethod1 == 'EMAIL' ? 'selected' : ''}>User Email Address</option>
                                         <option value="AUTO_ACCEPT" ${server.otpVerifyMethod1 == 'AUTO_ACCEPT' ? 'selected' : ''}>Monitor Mode/OTP Accept</option>
                                    </select>                                    
	               				</td>
	               				<td>Select the delivery methods for One-Time-Passcodes.</td>			               				
	               			</tr>
	               			<tr class="ap_table_tr_odd">
	               				<td><b>Template text for Email OTP ID Verification:</b></td>
	               				<td colspan="3">
	               					<table class="ap_table_inner">
	               						<tr>
	               							<td style="border: 0px;"><b>Subject:</b></td>
	               							<td style="border: 0px;">
		               							<input type="text" name="passwdVerifySubject" 
		               								size="77" value="${(server.otpVerifySubject == null || server.otpVerifySubject == '') ? 'ID Code for [ServiceName]: [OTPCode]' : server.otpVerifySubject}"/>
	               							</td>
	               						</tr>
	               						<tr>
	               							<td style="border: 0px;"><b>Body:</b></td>
	               							<td style="border: 0px;">
												<p style="margin-bottom: 0px;">
												<!-- TODO -->
												<input type="hidden" name="passwdVerifyBodyText" />
												<c:set var="defaultBody" value='Enter your ID Code: <b><span style="color:white; background:green;">[OTPCode]</span></b> to verify your access.
<p>This transaction originated from: [IPGEO].<br/>(If you are not accessing [ServiceName], you should reset your password immediately.)</p>'/>
												<textarea name="passwdVerifyBodyTextArea" rows="5" cols="75" style="font-size: 11px;"><c:out value="${(server.otpVerifyBody != null && server.otpVerifyBody != '') ?server.otpVerifyBody : defaultBody}"/></textarea>
	               							</td>
	               							<td colspan="2"><br/></td>
	               						</tr>
			               		</table>
			               	</td></tr>
	               			<tr class="ap_table_tr_odd">
	               				<td><b>Template text for Mobile OTP ID Verification:</b></td>
	               				<td colspan="3">
	               					<table class="ap_table_inner">
	               						<tr>
	               							<td style="border: 0px;"><b>SMS Message:</b></td>
	               							<td style="border: 0px;">
		               							<input type="text" name="otpMobileSms" 
		               								size="77" value="${(server.otpMobileSms == null || server.otpMobileSms == '') ? '[OTPCode] is your verification code for [ServiceName]' : server.otpMobileSms}"/>
	               							</td>
	               						</tr>
	               					</table>
	               				</td>
	               			</tr>
	               			<tr class="ap_table_tr_odd">
	               				<td><b>Template text for Mobile Voice Verification:</b></td>
	               				<td colspan="3">
	               					<table class="ap_table_inner">
	               						<tr>
	               							<td style="border: 0px;"><b>Voice Message:</b></td>
	               							<td style="border: 0px;">
		               							<input type="text" name="otpVoiceMsg" 
		               								size="77" value="${(server.otpVoiceMsg == null || server.otpVoiceMsg == '') ? 'Your one time passcode for [ServiceName] is, [OTPCode], Again, the passcode is [OTPCode].' : server.otpVoiceMsg}"/>
	               							</td>
	               						</tr>
	               					</table>
	               				</td>
	               			</tr>	               			
						</table>
               		</div>
               		<div id="retryTimeout" style="display:none;">
                 		<b>Optional Settings:&nbsp;</b>
                 		<br/><br/>
	               		<table class="ap_table leftAlignTable" style="border-spacing:0;" width="100%" cellpadding="0" cellspacing="1">
	               			<tr class="ap_table_tr_odd">
	               				<td style="border-spacing:0;"><b>Trans. Confirmation Retry Limit:</b></td>
	               				<td><select name="loginConfirmRetryTimes" style="height: 24px;">
                                                  <option value="1" ${server.otpConfRetry == '1' ? 'selected' : ''}>1</option>
                                                  <option value="2" ${server.otpConfRetry == '2' ? 'selected' : ''}>2</option>
                                                  <option value="3" ${(server.otpConfRetry == '3' || server.otpConfRetry == null) ? 'selected' : ''}>3</option>
                                                </select>
                                      (Times)                         
	               				</td>
	               				<td><b>On Failure to Confirm:</b>
										<select name="loginRetryFailureToConfirm" style="height: 24px;">
                                             <option value="LOG_FAIL_KVDB" ${server.otpConfRetryNotify == 'LOG_FAIL_KVDB' ? 'selected' : ''}>Log in aP-ASM DB</option>
                                             <option value="LOG_FAIL_KVDB_ADMIN" ${server.otpConfRetryNotify == 'LOG_FAIL_KVDB_ADMIN' ? 'selected' : ''}>Log in aP-ASM DB &amp; Notify Admin/Support</option>
                                             <option value="LOG_FAIL_KVDB_ADMIN_USER" ${server.otpConfRetryNotify == 'LOG_FAIL_KVDB_ADMIN_USER' ? 'selected' : ''}>Log in aP-ASM DB &amp; Notify Admin/Support &amp; User</option>
                                        </select>
	               				</td>
	               				<td><b>Support Email:</b> <input type="email" name="otpConfRetryEmail" value="${server.otpConfRetryEmail}"/></td>
	               			</tr>

  	               			<tr class="ap_table_tr_odd">
	               				<td><b>Trans. Confirmation Time-Out:</b></td>
	               				<td><input type="number" name="loginConfirmTimeoutLimit" 
	               							style="width:50px" value="${(server.otpConfTimeout == null) ? '300' : server.otpConfTimeout}">(Seconds)                                                
	               				</td>
	               				<td><b>On Failure to Confirm:</b>
										<select name="loginRetryTimoutToConfirm" style="height: 24px;">
                                             <option value="LOG_FAIL_KVDB" ${server.otpConfTimeoutNotify == 'LOG_FAIL_KVDB' ? 'selected' : ''}>Log in aP-ASM DB</option>
                                             <option value="LOG_FAIL_KVDB_ADMIN" ${server.otpConfTimeoutNotify == 'LOG_FAIL_KVDB_ADMIN' ? 'selected' : ''}>Log in aP-ASM DB &amp; Notify Admin/Support</option>
                                             <option value="LOG_FAIL_KVDB_ADMIN_USER" ${server.otpConfTimeoutNotify == 'LOG_FAIL_KVDB_ADMIN_USER' ? 'selected' : ''}>Log in aP-ASM DB &amp; Notify Admin/Support &amp; User</option>
                                        </select>
	               				</td>
	               				<td><b>Support Email:</b> <input type="email" name="otpConfTimeoutEmail" value="${server.otpConfTimeoutEmail}"/></td>
	               			</tr>
 	               			<tr class="ap_table_tr_odd">
	               				<td><b>Template text for Notification:</b></td>
	               				<td colspan="3">
	               					<table>
	               						<tr>
	               							<td  style="border: 0px;"><b>Subject:</b></td>
	               							<td  style="border: 0px;">
		               							<input type="text" name="failedLoginSubject" 
		               								size="77" value="${(server.otpConfSubject == null || server.otpConfSubject == '') ? 'Failed Verification for [ServiceName]' : server.otpConfSubject}"/>
	               							</td>
	               						</tr>
	               						<tr>
	               							<td  style="border: 0px;"><b>Body:</b></td>
	               							<td  style="border: 0px;">
												<p style="margin-bottom: 0px;">
												<input type="hidden" name="failedLoginBodyText" />
												<c:set var="defaultBodyFailedLogin" value='There was a failed transaction attempt for user: [UserEmail]<br/>
Service Name: [ServiceName]<br/>
Application Server IP: [AppSvrIP]<br/>
Transaction Failure Reason: [Reason]<br/>
User transaction originated from [IPGEO]<br/>
Action may be needed.'/>

<textarea name="failedLoginBodyTextArea" rows="4" cols="75" style="font-size: 11px;"><c:out value="${(server.otpConfBody != null && server.otpConfBody != '') ? server.otpConfBody :defaultBodyFailedLogin}"/></textarea></p>
											</td>	               						
	               						</tr>
	               					</table>
	               				</td>
	               			</tr>
	               		</table>                 		
               		</div>               		
				</div>
				</form>
				</div>							
          </div>
      </div>
      
    </div>
</div>
<%@include file="footer.html" %>
<script>
	function setPcTimeoutDefaults(){
		serverEditForm.forensicTimeLivePcFirst.value="120";
		serverEditForm.forensicTimeLivePcSecond.value="120";
		serverEditForm.forensicTimeLivePcThird.value="120";		
	}

	function setMobileTimeoutDefaults(){
		serverEditForm.forensicTimeLiveMobileFirst.value="120";
		serverEditForm.forensicTimeLiveMobileSecond.value="120";
		serverEditForm.forensicTimeLiveMobileThird.value="120";		
	}
	
	function cancelEdit(){
		window.location.href = "apiServerMgmt.ap";
	}
	
// Required Fields Checking for Security Policy 
function updServerIp(){

		var serverLabelVal = $(srvrLabel).val();
  		if(serverLabelVal == null || serverLabelVal == "") {
 			alert("Policy Label field is required. Please fill in this field.");
 			return false;
 			}

 		var svrServiceNameVal = $(svrServiceName).val();
 		if(svrServiceNameVal == null || svrServiceNameVal == "") {
 			alert("Service Name field is required. Please fill in this field.");
 			return false;
 			}

		var serverPubIpVal = $(serverPublicNatIp).val();
 		if(serverPubIpVal == null || serverPubIpVal == "") {
 			alert("Application Server IP Validation field is required. Please fill in this field.");
 			return false;
 			}

		if(serverPubIpVal){
			if(serverPubIpVal.indexOf("127.0.0.1") != -1){
				alert("Transactions will not be allowed from restricted IP 127.0.0.1");
				// $(serverPublicNatIp).val(serverPubIpVal.replace("127.0.0.1",""));
				return false;
			}
			if(serverPubIpVal.indexOf("localhost") != -1 || serverPubIpVal.indexOf("localdomain") != -1){
				alert("Transactions will not be allowed from generic hostnames containing localhost or localdomain.");
				return false;
			}

 		var apiKeyVal = $(apiKey).val();
 		if(apiKeyVal == null || apiKeyVal == "") {
 			alert("Policy API Key field is required. Please fill in this field.");
 			return false;
 			}

		}
		// check that autoConfirmEndDate is populated for Learning mode
        var loginConfirmMethodVal = $('[name=loginConfirmMethod]:checked').val();		
		var autoConfirmTypeVal = $(autoConfirmType).val();
		if("FORENSIC_AFTER_N" == loginConfirmMethodVal && autoConfirmTypeVal == "UNTIL"){
			var autoConfirmEndDateVal = $(autoConfirmEndDate).val();
			if(!autoConfirmEndDateVal || autoConfirmEndDateVal.length ==0){
				alert("Please select end date for Learning Mode in Confirmation Method section.");
				return false;
			}
		}
		$('#serverEditForm').submit();
	}
	
 	function appFieldChange(ele){
 		var eleId = ele.id;
		var eleVal = $('#' + eleId).val();
		// alert(eleId+" : "+eleVal);
		
 		if(eleId == "applField1Operator"){
 			if(eleVal == "Cognitive"){
 				$('#applField1Value').val("");
 				$('#applField1Value').hide();
 			}else{
 				$('#applField1Value').show();
 			}
 		} else if(eleId == "applField2Operator"){
			if(eleVal == "Cognitive"){
 				$('#applField2Value').val("");
				$('#applField2Value').hide();
 			}else{
 				$('#applField2Value').show();
 			}
		}
	}
 	
 	$( document ).ready(function() {
 		appFieldChange(document.getElementById("applField1Operator"));
 		appFieldChange(document.getElementById("applField2Operator"));
 	});
 	
 	function autoCheckAllCountries(type){
 		$('[id^='+type+'Id_]').prop('checked', true);
 	}
</script>
</body>
</html>