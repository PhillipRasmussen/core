<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/reporting/statsGoogle.cfm,v 1.5 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Displays summary stats for google referers$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iStatsTab eq 1>
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qGoogle = application.factory.oStats.getGoogleStats(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	
	<cfif qGoogle.recordcount>

				<form method="post" class="f-wrap-1 f-bg-short" action="">
				<fieldset>

					<h3>#application.adminBundle[session.dmProfile.locale].googleKeyWords#</h3>
					
					<label for="dateRange">
					<!--- drop down for date --->
					<b>#application.adminBundle[session.dmProfile.locale].Date#</b>
					<select name="dateRange" id="dateRange">
						<option value="all" <cfif form.dateRange eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allDates#</option>
						<option value="d" <cfif form.dateRange eq "d">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].today#</option>
						<option value="ww" <cfif form.dateRange eq "ww">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#</option>
						<option value="m" <cfif form.dateRange eq "m">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#</option>
						<option value="q" <cfif form.dateRange eq "q">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#</option>
						<option value="yyyy" <cfif form.dateRange eq "yyyy">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#</option>
					</select><br />
					</label>
					
					<label for="maxRows">
					<!--- drop down for max rows --->
					<b>#application.adminBundle[session.dmProfile.locale].rows#</b>
					<select name="maxRows" id="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#</option>
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
						</cfloop>
					</select><br />
					<label>
					
					<div class="f-submit-wrap">
					<input type="submit" value="#application.adminBundle[session.dmProfile.locale].update#" class="f-submit" />
					</div>
					
				</fieldset>
				</form>

				
				<table class="table-3" cellspacing="0">
				<tr>
					<th>#application.adminBundle[session.dmProfile.locale].keyWords#</th>
					<th>#application.adminBundle[session.dmProfile.locale].Referals#</th>
				</tr>
				
				<!--- show stats with links to search page --->
				<cfloop query="qGoogle">
					<tr class="#IIF(qGoogle.currentRow MOD 2, de(""), de("alt"))#">
						<td><a href="#referer#" class="referer">#keywords#</a></td>
						<td>#referals#</td>				
					</tr>
				</cfloop>
				
				</table>

	<cfelse>
		<h3>#application.adminBundle[session.dmProfile.locale].noSearchesNow#</h3>
	</cfif>
	</cfoutput>
	
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">