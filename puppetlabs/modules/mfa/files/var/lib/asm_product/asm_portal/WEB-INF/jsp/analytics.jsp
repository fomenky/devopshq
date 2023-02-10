<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%
	Calendar cal = Calendar.getInstance();
    cal.add(Calendar.DATE, -7);
    Date priorDt = cal.getTime();
%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>aPersona - Analytics</title>
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/fusion.css">
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/ap_style.css">
<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/jquery-ui.css" />
<link href="${pageContext.request.contextPath}/css/theme.default.css" rel="stylesheet" type="text/css">
	<link rel="icon" 
      type="image/png" 
      href="${pageContext.request.contextPath}/images/favicon.png">
	<link rel="shortcut icon" 
      type="image/png" 
      href="${pageContext.request.contextPath}/images/favicon.png">

<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-1.9.1.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-ui.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.tablesorter.min.js"></script>
    
    <script>
        $(function(){
          $( "#fromDateId" ).datepicker();
          $( "#toDateId" ).datepicker();
        });
    </script>

<!--
<script type="text/javascript" src="//www.google.com/jsapi"></script>
<script type="text/javascript">
google.load('visualization', '1', {packages: ['corechart']});
</script>
-->

<script type="text/javascript" src="${pageContext.request.contextPath}/js/jsapi.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/uds_api_contents.js"></script>

<style>
	table.fixed { table-layout:auto;}
	.shadowBorder {
			  -moz-box-shadow:    0px 0px 3px 3px #92a0b3;
			  -webkit-box-shadow: 0px 0px 3px 3px #92a0b3;
			  box-shadow:         0px 0px 3px 3px #92a0b3;
			  width: 99%; 
			  height: 250px;
	}
	p.chartText {
		color:grey;font-family:'Arial'; font-size:15px;font-weight: bold;
		margin-left:35px; padding-top:35px;
	}
	
.loader {
   width: 100%;
   height: 100%;
   top: 0;
   left: 0;
   opacity: 0.8;
/*   background-color: #fff;  */
   z-index: 99;
   text-align: center;
   font-size:30px;
}

</style>
</head>
<body class="nof-centerBody" onLoad="javascript:onLoadFunction();">
	<div style="height: 100%; min-height: 100%; position: relative;">
		<c:set var="selMenu" scope="request" value="analytics" />
		<jsp:include page="header.jsp" />

		<div class="nof-centerContent">
			<!--
			<div class="nof-clearfix nof-positioning ">
				<div class="nof-positioning TextObject"
					style="float: left; display: inline; width: 19px;">
					<p style="text-align: right; margin-bottom: 0px;">&nbsp;</p>
				</div>
				<div id="Text129" class="nof-positioning TextObject"
					style="float: left; display: inline; margin-top: 9px; margin-left: 19px;">
					<p style="margin-bottom: 0px;">
						<b><span style="font-size: 16px; font-weight: bold;">
								aPersona Analytics
					</p>
				</div> 
			</div>-->

			<div class="nof-positioning" style="width:100%;">
				<br />
				<div class="boxLayout" style="width:100%;">
				    <c:if test="${ANALYTICS_LAST_SYNC_TIME_GMT == null}">
						<h2>Analytics</h2>
					</c:if>
					<c:if test="${ANALYTICS_LAST_SYNC_TIME_GMT != null}">
						<h2>Analytics  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Last Sync Time:(GMT) <span id="syncTimeGmt">${ANALYTICS_LAST_SYNC_TIME_GMT}</span> &nbsp;&nbsp;&nbsp; (Local ASM Svr Time) <span id="syncTimeLocal">${ANALYTICS_LAST_SYNC_TIME_LOCAL}</span></h2>
					</c:if>
					
					<table style="border:1px single black">
						<tr>
							<td width ="200px" style="background:#ded9c3;" valign="top">
								<form id="viewAnalyticsReport" method="get" action="javascript:generateReport(true);">
								<table width="100%">
									<tr>
									<br/>
										<td colspan="2">
											<b>Report Type:</b>
											<br/>											
											<select name="asmReportType" style="width:205px;">
												<option value="daily" ${ANALYTIC_PARAMS['SESS-asmReportType']=='daily' ? 'selected' : ''}>ASM Summary - Daily</option>
<!-- 												<option value="weekly">ASM Summary - Weekly</option>
 -->												<option value="monthly" ${ANALYTIC_PARAMS['SESS-asmReportType']=='monthly' ? 'selected' : ''}>ASM Summary - Monthly</option>
											</select>
											<br/>
											<br/>
											<hr/>										
										</td>
									</tr>
									<tr>
										<td>
											<c:set var="now" value="<%=new java.util.Date()%>" />
											<c:set var="oneWeekback" value="<%=priorDt%>" />
											
											<b>From Date:</b>
											<br/>
											<fmt:formatDate value="${oneWeekback}" type="date" pattern="MM/dd/yyyy" 
													var="fromDateIdFmt" />									
								            <input required type="text" id="fromDateId" value="${ANALYTIC_PARAMS['SESS-fromDateId']==null? fromDateIdFmt : ANALYTIC_PARAMS['SESS-fromDateId']}"
													name="fromDateId" size="9" maxlength="13"
													placeholder="mm/dd/yyyy" />
										</td>
										<td>
											<b>To Date:</b>
											<br/>
											
											<fmt:formatDate value="${now}" type="date" pattern="MM/dd/yyyy" 
													var="toDateIdFmt" />									
								            <input required type="text" id="toDateId" value="${ANALYTIC_PARAMS['SESS-toDateId']==null? toDateIdFmt : ANALYTIC_PARAMS['SESS-toDateId']}"
													name="toDateId" size="9" maxlength="13"
													placeholder="mm/dd/yyyy" />
										</td>
									</tr>
									<tr>
										<td colspan="2">
											<br/>
											<b>Client Name:</b>
											<br/>
											<fmt:parseNumber var="SESS_providerId" type="number" value="${ANALYTIC_PARAMS['SESS-selectedProviderId']}" />
											<input type="hidden" name="sess-providerId" id="sess-providerId" value="${ANALYTIC_PARAMS['SESS-selectedProviderId']}"/>
											<input type="hidden" name="sess-serverId" id="sess-serverId" value="${ANALYTIC_PARAMS['SESS-selectedServerId']}"/>
											
								            <select name="selectedProviderId" id="selectedProviderId" style="width:200px;" onchange="javascript:getSecPolicy(this);">
								             	<!-- <option value="-99">All</option> -->
												<c:forEach var="kvProvider" items="${KV_PROVIDERS}" varStatus="loop">
													<option value="${kvProvider.providerId}">${kvProvider.providerName}</option>
												</c:forEach>	          
								          	</select>											
										</td>
									</tr>
									<tr>
										<td colspan="2">
										<br/>
											<b>Security Policy:</b>
											<br/>
								            <select name="selectedServerId" id="selectedServerId" style="width:200px;">
													<option value="-99">All</option>
								          	</select>											
										</td>
									</tr>
<%-- 									<tr>
										<td>
										<br/>
											<b>Forensic Low:</b>
											<br>
											<select name="forensicLevelLow" style="width:95px;">
		                                        <option value="LEVEL_1" ${forensicLevelLow == 'LEVEL_1' ? 'selected' : ''}>
		                                        							Level 1</option>
		                                        <option value="LEVEL_2" ${forensicLevelLow == 'LEVEL_2' ? 'selected' : ''}>
		                                        							Level 2</option>
		                                        <option value="LEVEL_3" ${forensicLevelLow == 'LEVEL_3' ? 'selected' : ''}>
		                                        							Level 3</option>
		                                        <option value="LEVEL_4" ${forensicLevelLow == 'LEVEL_4' ? 'selected' : ''}>
		                                        							Level 4</option>
		                                        <option value="LEVEL_5" ${forensicLevelLow == 'LEVEL_5' ? 'selected' : ''}>
		                                        							Level 5</option>
		                                        <option value="LEVEL_6" ${forensicLevelLow == 'LEVEL_6' ? 'selected' : ''}>
		                                        							Level 6</option>
		                                        <option value="LEVEL_7" ${forensicLevelLow == 'LEVEL_7' ? 'selected' : ''}>
		                                        							Force Confirmation</option>
											</select>
										</td>
										<td>
										<br/>
											<b>Forensic High:</b>
											<br>
											<select name="forensicLevelHigh" style="width:95px;">
		                                        <option value="LEVEL_1" ${forensicLevelHigh == 'LEVEL_1' ? 'selected' : ''}>
		                                        							Level 1</option>
		                                        <option value="LEVEL_2" ${forensicLevelHigh == 'LEVEL_2' ? 'selected' : ''}>
		                                        							Level 2</option>
		                                        <option value="LEVEL_3" ${forensicLevelHigh == 'LEVEL_3' ? 'selected' : ''}>
		                                        							Level 3</option>
		                                        <option value="LEVEL_4" ${forensicLevelHigh == 'LEVEL_4' ? 'selected' : ''}>
		                                        							Level 4</option>
		                                        <option value="LEVEL_5" ${forensicLevelHigh == 'LEVEL_5' ? 'selected' : ''}>
		                                        							Level 5</option>
		                                        <option value="LEVEL_6" ${forensicLevelHigh == 'LEVEL_6' ? 'selected' : ''}>
		                                        							Level 6</option>
		                                        <option value="LEVEL_7" ${forensicLevelHigh == 'LEVEL_7' ? 'selected' : ''}>
		                                        							Force Confirmation</option>
											</select>										
										</td>
									</tr>	
 --%>									<tr>
										<td colspan="2">
										<br/>
										<b>User:</b>
										<br/>
										<input type="text" style="width:196px;" name="userSearch" value="${ANALYTIC_PARAMS['SESS-userSearch']}" />
										</td>
									</tr>						
								</table>
								<br/>
								<input class="buttonStyle" type="Submit" value="View Report / Refresh" />
								<br/><br/>
								 <input class="buttonStyle" type="button" value="View Report Source Data" onclick="javascript:downloadReport();"/>
								 <!-- <div id="toolbar_div">Place holder</div> -->
							</form>
							<br/>
							<br/>
							<br/>
								<div id="allTxnChart" style="width:200px">
										<p class="chartText">All Evaluated Transactions</p>
								</div>
								<!-- <div id="allTxnChartToolbar"></div> -->
							</td>
							<td style="background:#c6d9f1;" width="90%">
							<div id="chartsLoadingDivId" class="loader" style="display: block">
								Loading data...
							</div>
							<div id="chartsDivId" style="display: none">
							<table cellspacing="3" width="100%">
								<tr>
									<td><div class="shadowBorder" id="totalTxnChart">
										<p class="chartText">All Evaluated Transactions</p>
									</div></td>
									<td><div class="shadowBorder" id="successByForensicChart">
										<p class="chartText">Successful Transactions By Level</p>
									</div></td>				
								</tr>
								<tr>
									<td><div class="shadowBorder" id="challengedByForensicChart">
										<p class="chartText">Challenged Transactions By Level</p>
									</div></td>
									<td><div class="shadowBorder" id="failedChallengedChart">
										<p class="chartText">Failed Transactions</p>
									</div></td>								
								</tr>
								<tr>
									<td><div class="shadowBorder" id="autoRegisterChart">
										<p class="chartText">Automatic Registrations (Invisible)</p>
									</div></td>
									<td><div class="shadowBorder" id="autoConfChart">
										<p class="chartText">Automatic Learning (Invisible)</p>
									</div></td>						
								</tr>
								<tr>
									<td><div class="shadowBorder" id="monitoredChart">
										<p class="chartText">Monitored (would have challenged) Transactions</p>
									</div></td>
									<td><div class="shadowBorder" id="notEvalTxnChart">
										<p class="chartText">Automatic Learning (Invisible)</p>
									</div></td>						
								</tr>								
							</table>
							</div>
							</td>
						</tr>
					</table>
				</div>
				
	</div>
	</div>
	</div>
<%@include file="footer.html" %>	

<script>
var allcompletedCharts = new Array();
var allChartsData = new Array();
var payLoadMap;

function clearCharts(){
	if(allcompletedCharts.length > 0){
		for (var index = 0; index < allcompletedCharts.length; index++) {
			var chart = allcompletedCharts[index];
			if(chart){
				chart.clearChart();
			}
		}
		allcompletedCharts = new Array();
	}
	allChartsData = new Array();
	
	$("#allTxnChart").html("<p class='chartText'>All Evaluated Transactions</p>");
	$("#totalTxnChart").html("<p class='chartText'>All Evaluated Transactions</p>");
	$("#successByForensicChart").html("<p class='chartText'>Invisible Transactions Validated</p>");
	$("#challengedByForensicChart").html("<p class='chartText'>Challenged Transactions By Level</p>");
	$("#failedChallengedChart").html("<p class='chartText'>Failed Transactions</p>");
	$("#autoRegisterChart").html("<p class='chartText'>Automatic Registrations (Invisible)</p>");
	$("#autoConfChart").html("<p class='chartText'>Automatic Learning (Invisible)</p>");
	$("#monitoredChart").html("<p class='chartText'>Monitored (would have challenged) Transactions</p>");
	$("#notEvalTxnChart").html("<p class='chartText'>Non-Evaluated Transactions</p>");
}

function onLoadFunction(){
	
	try{
		// populate providerId and serverId if they are already in session
		var sessProviderId = $("#sess-providerId").val();
		if(!sessProviderId || sessProviderId==null){
			sessProviderId = $('#selectedProviderId').val();
		}
//		alert("sessProviderId:"+sessProviderId);
		if($.isNumeric(sessProviderId) && sessProviderId != "-99"){
			// provider Id is selected
			$('#selectedProviderId').val(sessProviderId);
			
// 			$('#selectedProviderId').change();
			
			// selecting the securityPolicy
			var sessServerId = $("#sess-serverId").val();
//			alert("sessServerId:"+sessServerId);
			getSecPolicy(document.getElementById("selectedProviderId"), sessServerId);
/* 			if($.isNumeric(sessServerId) && sessServerId != "-99"){
				alert("before updating sessServerId:"+sessServerId);
				//$('#selectedServerId').val(sessServerId);
				
			} */
		}
	}catch(error){
		// error in 
	}
	generateReport(false);	
}

function generateReport(isRefreshReq) {
	$("#chartsDivId").hide();
	$("#chartsLoadingDivId").show(); 
		
	clearCharts();
	if(isRefreshReq && navigator.userAgent.indexOf("Firefox") > 0 ){
		$.ajax({
			   url: 'analyticsReportSetSession.ap',
			   type: 'GET',
			   data: $("#viewAnalyticsReport").serialize(),
			   error: function(error) {
			     /*  alert("ERROR in processing data.. error:"+error); */
			   },
			   dataType: 'json',
			   success: function(data) {
				// for mozilla browser, reload the page after setting new filters
				location.reload();
			   }
			});
		location.reload();
		   return;
	}else{
		$.ajax({
			   url: 'analyticsReport.ap',
			   type: 'GET',
			   data: $("#viewAnalyticsReport").serialize(),
			   error: function(error) {
			      alert("ERROR in processing data.. error:"+error);
			   },
			   dataType: 'json',
			   success: function(data) {
			    //  alert("RECEIVED Response:"+JSON.stringify(data));
			      payLoadMap = eval(data);
				  	$("#chartsLoadingDivId").hide();
					$("#chartsDivId").show();
			      printChartsFromPayLoad(payLoadMap);
			   }
			   
			});		
	}

    // Create and populate the data table.
/*     var data = google.visualization.arrayToDataTable([
      ['Day', 'OTP Time-out', { role: 'annotation' },'OTP Retry', { role: 'annotation' }],
      ['2/25/14',  25,'25',  12,'12'],
      ['2/26/14',  62,'62',  27,'27'],
      ['2/27/14',   15,'15' ,  18,'18'],
      ['2/28/14',  13,'13',  9 ,'9'],
      ['3/1/14',   19,'19',  26,'26'],
      ['3/2/14',   27,'27',  14,'14']
    ]);
  
    // Create and draw the visualization.
    new google.visualization.ColumnChart(document.getElementById('failedLoginsChart')).
        draw(data,
             {title:"Failed Challenged Transactions",  titleTextStyle: {color: '#6E6666',fontName: 'Arial', fontSize: 18, bold: true   },
              series: {0:{color: '#AE120E', visibleInLegend: true},1:{color: '#E22722', visibleInLegend: true}},
              width:515, height:300,
              isStacked: true,
              legend: { position: 'bottom', maxLines: 1 },
              bar: { groupWidth: '75%' },
            }
        );
    alert("after generate report"); */
    return false;
  }
  
  function printChartsFromPayLoad(payLoadMap){
	  
	// (0) All Evaluated Transactions pie chart
      var allTxnPayLoad=payLoadMap["ALL_TXN_FOR_PERIOD"];
      if(allTxnPayLoad != null && allTxnPayLoad.length >0){
      var allTxnDataArray=getAllTxnDataArray(allTxnPayLoad);
       drawPieChart("allTxnChart", "All Evaluated Transactions", 
    		  allTxnDataArray);
       }
      
 	//(1) Get Total Transactions - TOTAL_TXN_DATA
      var totalTxnPayLoad=payLoadMap["TOTAL_TXN_DATA"];
      if(totalTxnPayLoad != null && totalTxnPayLoad.length >0){
      var totTxnDataArrayAndTotal=getTotalTxnDataArray(totalTxnPayLoad);
      drawChart("totalTxnChart", "All Evaluated Transactions", 
    		  totTxnDataArrayAndTotal[0], totTxnDataArrayAndTotal[1], totTxnDataArrayAndTotal[2]);
      }
      
     //(2) Successful transactions by forensic level - SUCCESS_TXN_BY_FORENSIC
      var successByForensicPayLoad=payLoadMap["SUCCESS_TXN_BY_FORENSIC"];
      if(successByForensicPayLoad != null && successByForensicPayLoad.length >0){
      var successByForensicDataArrayAndTotal=getForensicDataArray(successByForensicPayLoad);
      drawChart("successByForensicChart", "Invisible Transactions Validated", 
    		  successByForensicDataArrayAndTotal[0], successByForensicDataArrayAndTotal[1]);
      }
    // TODO : exclude failure transactions
    //(3) challenged transactions by forensic level - CHALLENGED_TXN_BY_FORENSIC (have same columns as SuccessByForensic)
      var challengedByForensicPayLoad=payLoadMap["CHALLENGED_TXN_BY_FORENSIC"];
      if(challengedByForensicPayLoad != null && challengedByForensicPayLoad.length >0){
      var challengedByForensicDataArrayAndTotal=getForensicDataArray(challengedByForensicPayLoad);
      drawChart("challengedByForensicChart", "Challenged Transactions By Level", 
    		  challengedByForensicDataArrayAndTotal[0], challengedByForensicDataArrayAndTotal[1]);
      }
      
    //(4) Get Failed challenges by type - FAILED_CHALLENGE_DATA
      var failureLoginsPayLoad=payLoadMap["FAILED_CHALLENGE_DATA"];
      if(failureLoginsPayLoad != null && failureLoginsPayLoad.length >0){
      var failedChallengeDataArrayAndTotal=getFailedChallengeDataArray(failureLoginsPayLoad);
      drawChart("failedChallengedChart", "Failed Transactions", 
    		  failedChallengeDataArrayAndTotal[0], failedChallengeDataArrayAndTotal[1]);
      }
      
    //(5) Get Auto Registration stats - AUTO_REG_DATA
        var autoRegPayLoad=payLoadMap["AUTO_REG_DATA"];
        if(autoRegPayLoad != null && autoRegPayLoad.length >0){
            var autoRegDataArrayAndTotal=getTotalPerDateDataArray(autoRegPayLoad);
            drawChart("autoRegisterChart", "Automatic Registrations (Invisible)", 
            		autoRegDataArrayAndTotal[0], autoRegDataArrayAndTotal[1]);        	
        }

        //(5.1) Get Auto Confirmation stats - AUTO_CONF_DATA
        var autoConfPayLoad=payLoadMap["AUTO_CONF_DATA"];
        if(autoConfPayLoad != null && autoConfPayLoad.length >0){
            var autoConfDataArrayAndTotal=getTotalPerDateDataArray(autoConfPayLoad);
            drawChart("autoConfChart", "Automatic Learning (Invisible)", 
            		autoConfDataArrayAndTotal[0], autoConfDataArrayAndTotal[1]);        	
        }
      	 //(6) Get Monitored stats - MONITORED_DATA
         var monitoredTxnPayLoad=payLoadMap["MONITORED_DATA"];
         if(monitoredTxnPayLoad != null && monitoredTxnPayLoad.length >0){
	         var monitoredTxnDataArrayAndTotal=getForensicDataArray(monitoredTxnPayLoad);
	         drawChart("monitoredChart", "Monitored (would have challenged) Transactions", 
	        		 monitoredTxnDataArrayAndTotal[0], monitoredTxnDataArrayAndTotal[1]);
  		 }
         
      	 //(6) Non-Evaluated Transactions - NOT_EVAL_TXN_DATA
         var notEvalTxnPayLoad=payLoadMap["NOT_EVAL_TXN_DATA"];
         if(notEvalTxnPayLoad != null && notEvalTxnPayLoad.length >0){
	         var notEvalTxnDataArrayAndTotal=getNotEvalDataArray(notEvalTxnPayLoad);
	         drawChart("notEvalTxnChart", "Non-Evaluated Transactions", 
	        		 notEvalTxnDataArrayAndTotal[0], notEvalTxnDataArrayAndTotal[1]);
  		 }
         // alert("payLoadMap:"+JSON.stringify(payLoadMap));
         var lastSyncTime = payLoadMap["ANALYTICS_LAST_SYNC_TIME_LOCAL"];
         var lastSyncTimeGmt = payLoadMap["ANALYTICS_LAST_SYNC_TIME_GMT"];
         $("#syncTimeLocal").text(lastSyncTime);
         $("#syncTimeGmt").text(lastSyncTimeGmt);
   }

  function getTotalTxnDataArray(payLoad){
	    var dataArray = new Array();
	    dataArray[0] = ['Day', 'Succ (Inv)', { role: 'annotation' },'Succ (Chal)', { role: 'annotation' },
	                    'Failed', { role: 'annotation' }];
	    var colors = ['green','#FF9900','red'];
	    var total=0;
	    if(payLoad != null){
		    //totalTxn will be in format: [date, Success, Challenged, Others]
		    for(var idx=0; idx<payLoad.length; idx++){
		    	dataArray[idx+1] = [payLoad[idx][0], payLoad[idx][1], payLoad[idx][1],
		    	                    payLoad[idx][2], payLoad[idx][2], payLoad[idx][3], payLoad[idx][3]];
		    	total = total + payLoad[idx][1] + payLoad[idx][2] + payLoad[idx][3];
		    }	    	
	    }
	    return [dataArray, total, colors];
  }

  function getAllTxnDataArray(payLoad){
	    var dataArray = new Array();
	    dataArray[0] = ['Transactions', 'Count'];
	    if(payLoad != null){
		    //totalTxn will be in format: [success, otp, failed]
	    	dataArray[1] = ['Succ (Inv)', payLoad[0]];
	    	dataArray[2] = ['Succ (Chal)',  payLoad[1]];
	    	dataArray[3] = ['Failed', payLoad[2]];
	    
	    }
	    return dataArray;
}
  function getTotalPerDateDataArray(payLoad){
	    var dataArray = new Array();
	    dataArray[0] = ['Day', 'Total', { role: 'annotation' }];
	    
	    //totalTxn will be in format: [date, Total]
	    var total=0;
	    if(payLoad != null){
	    for(var idx=0; idx<payLoad.length; idx++){
	    	dataArray[idx+1] = [payLoad[idx][0], payLoad[idx][1], payLoad[idx][1]];
	    	total = total + payLoad[idx][1];
	    }
	    }
	    return [dataArray, total];
}
  
  function getForensicDataArray(payLoad){
	    var dataArray = new Array();
	    dataArray[0] = ['Day', 'Level1', { role: 'annotation' },'Level2', { role: 'annotation' },
	                    'Level3', { role: 'annotation' },'Level4', { role: 'annotation' },
	                    'Level5', { role: 'annotation' },'Level6', { role: 'annotation' },
	                    'Level7', { role: 'annotation' },'Others', { role: 'annotation' }];
	    
	    //totalTxn will be in format: [date, Success, Challenged, Others]
	    var total=0;
	    if(payLoad != null){
		    for(var idx=0; idx<payLoad.length; idx++){
		    	dataArray[idx+1] = [payLoad[idx][0], payLoad[idx][1], payLoad[idx][1],
		    	                    payLoad[idx][2], payLoad[idx][2], payLoad[idx][3], payLoad[idx][3],
		    	                    payLoad[idx][4], payLoad[idx][4], payLoad[idx][5], payLoad[idx][5],
		    	                    payLoad[idx][6], payLoad[idx][6], payLoad[idx][7], payLoad[idx][7],
		    	                    payLoad[idx][8], payLoad[idx][8]];
		    	total = total + payLoad[idx][1] + payLoad[idx][2] + payLoad[idx][3]
					    	+ payLoad[idx][4] + payLoad[idx][5] + payLoad[idx][6]
					    	+ payLoad[idx][7] + payLoad[idx][8];
		    }
	    }
	    return [dataArray, total];
  }
  
  function getNotEvalDataArray(payLoad){
	    var dataArray = new Array();
	    dataArray[0] = ['Day', 'Invalid email', { role: 'annotation' },'Bad request', { role: 'annotation' },
	                    'Invalid aPersona ASM License', { role: 'annotation' },'Invalid Svr IP', { role: 'annotation' },
	                    'User not registered', { role: 'annotation' },'Transaction failure', { role: 'annotation' }];
	    
	    var total=0;
	    if(payLoad != null){
		    for(var idx=0; idx<payLoad.length; idx++){
		    	dataArray[idx+1] = [payLoad[idx][0], payLoad[idx][1], payLoad[idx][1],
		    	                    payLoad[idx][2], payLoad[idx][2], payLoad[idx][3], payLoad[idx][3],
		    	                    payLoad[idx][4], payLoad[idx][4], payLoad[idx][5], payLoad[idx][5],
		    	                    payLoad[idx][6], payLoad[idx][6]];
		    	total = total + payLoad[idx][1] + payLoad[idx][2] + payLoad[idx][3]
					    	+ payLoad[idx][4] + payLoad[idx][5] + payLoad[idx][6];
		    }
	    }
	    return [dataArray, total];
  }
  
  function getFailedChallengeDataArray(payLoad){
	    var dataArray = new Array();
	    dataArray[0] = ['Day', 'OTP Time-out', { role: 'annotation' },'Invalid OTP', { role: 'annotation' },'MITM', { role: 'annotation' }
	    	,'Invalid Transaction ID', { role: 'annotation' }, 'Country Not Allowed', { role: 'annotation' }, 'Threat Actor', { role: 'annotation' }];
	    
	    //failureLoginsPayLoad will be in format: [date, OTP Timeout count, Invalid OTP count]
	    var total=0;
	    if(payLoad != null){
	    	for(var idx=0; idx<payLoad.length; idx++){
	    		dataArray[idx+1] = [payLoad[idx][0], payLoad[idx][1], payLoad[idx][1],
	    	                    payLoad[idx][2], payLoad[idx][2],
	    	                    payLoad[idx][3], payLoad[idx][3], payLoad[idx][4], payLoad[idx][4],
	    	                    payLoad[idx][5], payLoad[idx][5], payLoad[idx][6], payLoad[idx][6]];
	    		total = total + payLoad[idx][1] + payLoad[idx][2]+ payLoad[idx][3]+ payLoad[idx][4]+ payLoad[idx][5]+ payLoad[idx][6];
	    	}
	    }
	    return [dataArray, total];
  }
  
    function drawPieChart(divId, title, dataArray ){
	    var chart_div = document.getElementById(divId); 
	    // Create and populate the data table.
	     var data = google.visualization.arrayToDataTable(dataArray);
	    
	      // Create and draw the visualization.
	      var chart = new google.visualization.PieChart(chart_div)
	          chart.draw(data,
	               {title:title,  titleTextStyle: {color: '#6E6666',fontName: 'Arial', fontSize: 13},
                 width:205, height:220,
 					chartArea: {'width': '90%','height': '70%'},
	                isStacked: true,
	                legend: { position: 'bottom', maxLines: 1 },
	                bar: { groupWidth: '50%' },
	                colors:['green','#FF9900','red']
	              }
	          );
	      
/* 	      var components = [{type: 'csv', datasource:data}];
	      var container = document.getElementById('allTxnChartToolbar');
	      google.visualization.drawToolbar(container, components); */
	      
	      allcompletedCharts.push(chart);
  	  }
      
	  function drawChart(divId, title, dataArray, total, colorsArr ){
	  	    var chart_div = document.getElementById(divId); 
	  	    // Create and populate the data table.
	  	     var data = google.visualization.arrayToDataTable(dataArray);
	  	    
	  	      // Create and draw the visualization.
	  	      var chart = new google.visualization.ColumnChart(chart_div);
	  	    var chartwidth = ($("body").innerWidth()*.4582)-86;
	  	          chart.draw(data,
	  	               {
	  	        	  	title:title+"\nTotal: "+ total,  
	  	        	  	titleTextStyle: {color: '#6E6666',fontName: 'Arial', fontSize: 13}, 
	  	        	  	allowHtml: true,
	  /*  	                series: {0:{color: '#AE120E', visibleInLegend: true},1:{color: '#E22722', visibleInLegend: true}},
	   */	            width:chartwidth, height:250,
	   					chartArea: {'width':chartwidth,'height': '70%'},
	  	                isStacked: true,
	  	                legend: { position: 'bottom', maxLines: 1 },
	  	                bar: { groupWidth: '50%' },
	  	                colors: colorsArr
	  	              }
	  	          );
	  	      allcompletedCharts.push(chart);
	  	      allChartsData.push([title, dataArray])
	  	      
	  	      var heading = chart_div.getElementsByTagName('g')[0];
	  	      if (heading){
	  	        var title = heading.getElementsByTagName('text')[1];
	  	        if (title){
	  	          title.setAttribute('font-size', '12');
	  	        }
	  	      }
/* 	  	    if(divId == "challengedByForensicChart"){
		  	    var components = [
		  	    				{ type: 'html', datasource: data },
		  	    				{ type: 'csv', datasource: data }
		  	    				];
		  	    	  	  	var container = document.getElementById('toolbar_div');
		  	    	  		google.visualization.drawToolbar(container, components);	  	    	
	  	    } */

	    }	 
	  
	  function getSecPolicy(clientSelObj, selectedServerId){
		  if(clientSelObj){
			  var clientId = clientSelObj.options[clientSelObj.selectedIndex].value;
			  // alert(clientId);
			  var secPolicySelObj = document.getElementById("selectedServerId");
			  //alert("secPolicySelObj  " + secPolicySelObj);
			  secPolicySelObj.options.length=0;
			  secPolicySelObj.options[0]=new Option("All","-99");
			  
			  //alert("About to make call:"+'getSecPolicyForClient.ap?providerId='+clientId);
			  if(clientId == -99){
				  // do nothing
			  }else{
				$.ajax({
					   url: 'getSecPolicyForClient.ap?providerId='+clientId,
					   type: 'GET',
					   async: true,
					   error: function(error) {
					      //alert("ERROR in processing data.. error:"+error);
					   },
					   dataType: 'json',
					   success: function(data) {
					      //alert("RECEIVED Response:"+JSON.stringify(data));
					      if(data != null){
					    	  var secPoliciesMap = eval(data);
					    	  var idx = 1;
					    	  for( var secId in secPoliciesMap){
					    		  var newItem = new Option(secPoliciesMap[secId], secId);
					    		  if(selectedServerId && (secId == selectedServerId)){
					    			  newItem = new Option(secPoliciesMap[secId], secId, false, true);
					    		  }
					    		  secPolicySelObj.options[idx++]=newItem;
					    	  }
					      }
					   }
					});
			  }
		  }
	  }
	  
	  function downloadReport(){
		  //alert("Inside downlaod report."+ JSON.stringify(payLoadMap));
		  //alert(allChartsData);
		  var response = "";
		  if(!allChartsData || allChartsData.length==0){
			  alert("No data available for download, please increase date range or modify filters to increase scope of analytics.");
			  return false;
		  }
		  for(var idx=0; idx<allChartsData.length; idx++){
			  response = response+ "<br/>Chart Name:"+allChartsData[idx][0]+"<br/>";
			  response = response+ skipAnnotationsData(allChartsData[idx][1][0])+"<br/>";
			  for (var row=1; row<allChartsData[idx][1].length; row++){
				  response = response+ skipAnnotationsData(allChartsData[idx][1][row])+"<br/>";
			  }
		  }
		  
		  //alert(response);
		  // open popup with data
		    popupWin = window.open('','Analytics Report',"menubar=no,location=no,resizable=yes,scrollbars=yes,status=yes,width=600,height=600");
		    popupWin.document.writeln('<html><head><title>Analytics Report</title></head><body><p style="font-family:arial;font-size:11px;" id="dataId">'
		    +'You can save below data in csv file and open in Excel.<br/><br>'+ response+'</p</body></html>');
	  }
	  
	  function skipAnnotationsData(rowData){
		  var result = new Array();
		  if(!rowData || rowData.length==0){
			  return result;
		  }
		  result.push(rowData[0]);
		  for (var idx=1; idx<rowData.length; idx++){
			  if (idx % 2 != 0){
				  // skip all annotation columns
				  result.push(rowData[idx]);
			  }
		  }
		  return result;
	  }
</script>	
</body>
</html>



