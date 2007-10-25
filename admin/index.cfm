<cfsetting enablecfoutputonly="true">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/index.cfm,v 1.102.2.1 2006/04/09 02:43:35 geoff Exp $
$Author: geoff $
$Date: 2006/04/09 02:43:35 $
$Name: milestone_3-0-1 $
$Revision: 1.102.2.1 $

|| DESCRIPTION || 
$Description: FarCry Admin Central Index. 
Notes:
section url param loads default iFrames

Nav tabs load from XML

Vars:
<title></title>
<body id="var">

pseudo logic:
check active section from url
is sec valid and permitted
is sub valid and permitted
load default iframes
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
$Developer: Pete Ottery (pot@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8" />

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<!--- Get sections --->
<cfset stSections = application.factory.oWebtop.getItem() />

<!--- Default selected section is the first in the list --->
<cfparam name="url.sec" default="#listfirst(stSections.childorder)#" />

<!--- Default selected subsection is the first in the list --->
<cfparam name="url.sub" default="#listfirst(stSections.children[url.sec].childorder)#" />

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<title>#application.config.general.sitetitle# - FarCry Admin</title>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
<script type="text/javascript" src="#application.url.farcry#/js/prototype.js"></script>
</head>
<body id="sec-#url.sec#">

	<div id="header">
	
		<div id="site-name">

			<h1>#application.config.general.sitetitle#</h1>
			<h2>#application.config.general.sitetagline#</h2>
		
		</div>
		
		<div id="admin-tools">
			<div id="powered-by"><img src="images/powered_by_farcry.gif" alt="farcry" /></div>
			<p>Logged in: <cfif StructKeyExists(session.dmProfile,"firstname")><strong>#session.dmProfile.firstname#</strong></cfif><br />
			(<a href="#application.url.farcry#/index.cfm?logout=1" target="_top">Logout</a><!---  | Help ---> | <a href="#application.url.conjurer#" target="_blank">View</a>)
			</p>
		</div>
		
		<div id="nav">
			<ul>
</cfoutput>

<admin:loopwebtop parent="#stSections#" item="section" class="class">
	<!--- Output the menu link --->
	<cfoutput><li id="nav-#section.id#" class="#class#<cfif url.sec eq section.id> active</cfif>"><a href="index.cfm?sec=#section.id#">#trim(section.label)#</a></li></cfoutput>
</admin:loopwebtop>

<cfoutput> </ul>
		</div>
	
		<div class="clear"></div>
		
	</div>
	<div id="content-wrap">

		<div id="sidebar">
			<iframe src="#application.factory.oWebtop.getAttributeURL('#url.sec#.#url.sub#','sidebar',url)#" name="sidebar" scrolling="auto" frameborder="0" id="iframe-sidebar"></iframe>
		</div>
		
		<div id="content">
			<iframe src="#application.factory.oWebtop.getAttributeURL('#url.sec#.#url.sub#','content',url)#" name="content" scrolling="auto" frameborder="0" id="iframe-content"></iframe>
		</div>
		
		<div class="clear"></div>

	</div>
	
	<div id="footer">
		<p>Copyright &copy; Daemon 1997-#year(now())#, #createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</p>
	</div>
</cfoutput>

<!--- expander widget for sidebar/content iframes --->
<cfset altexpansion = stSections.children[url.sec].altexpansion />
<cfif altexpansion eq "none">
	<!--- No expand / contract buttons --->
<cfelseif altexpansion gt 200>
	<!--- Alternate size is greater than the default size --->
	<cfoutput>
		<a href="##" onclick="$('sidebar').style.width = '#altexpansion#px'; $('iframe-sidebar').style.width = '#altexpansion#px'; $('tree-button-max').style.display = 'none'; $('tree-button-min').style.display = 'block'; $('content-wrap').style.backgroundPosition = '#altexpansion-201#px 0'; $('content').style.marginLeft = '#altexpansion+32#px'; $('sec-#url.sec#').style.backgroundPosition='#altexpansion-605#px 0'; return false;" id="tree-button-max"><span>Expand Sidebar</span></a>
		<a href="##" onclick="$('sidebar').style.width = '200px'; $('iframe-sidebar').style.width = '200px'; $('tree-button-max').style.display = 'block'; $('tree-button-min').style.display = 'none'; $('content-wrap').style.backgroundPosition = '0 0'; $('content').style.marginLeft = '232px'; $('sec-#url.sec#').style.backgroundPosition = '-404px 0'; return false;" id="tree-button-min"><span>Default Sidebar</span></a>
	</cfoutput>
<cfelseif altexpansion lt 200>
	<!--- Alternate size is smaller than the default size --->
	<cfoutput>
		<a href="##" onclick="$('sidebar').style.width = '#altexpansion#px'; $('iframe-sidebar').style.width = '#altexpansion#px'; $('content-button-max').style.display = 'none'; $('content-button-min').style.display = 'block'; $('content-wrap').style.backgroundPosition = '#altexpansion-201#px 0'; $('content').style.marginLeft = '#altexpansion+32#px'; $('sec-#url.sec#').style.backgroundPosition='#altexpansion-605#px 0'; return false;" id="content-button-max"><span>Expand Sidebar</span></a>
		<a href="##" onclick="$('sidebar').style.width = '200px'; $('iframe-sidebar').style.width = '200px'; $('content-button-max').style.display = 'block'; $('content-button-min').style.display = 'none'; $('content-wrap').style.backgroundPosition = '0 0'; $('content').style.marginLeft = '232px'; $('sec-#url.sec#').style.backgroundPosition = '-404px 0'; return false;" id="content-button-min"><span>Default Sidebar</span></a>
	</cfoutput>
</cfif>

<!--- <cfswitch expression="#stSections[url.sec].altexpansion#">
	<cfcase value="home">
	<!--- do nothing for overview page --->
	</cfcase>
	<cfcase value="site">
	<!--- expands tree iframe for access to nested content --->
	<cfoutput>
	<a href="##" onclick="$('sidebar').style.width = '500px'; $('iframe-sidebar').style.width = '500px'; $('tree-button-max').style.display = 'none'; $('tree-button-min').style.display = 'block'; $('content-wrap').style.backgroundPosition = '300px 0'; $('content').style.marginLeft = '532px'; $('sec-#secid#').style.backgroundPosition = '-104px 0'; return false;" id="tree-button-max"><span>Maximise Tree</span></a>
	<a href="##" onclick="$('sidebar').style.width = '200px'; $('iframe-sidebar').style.width = '200px'; $('tree-button-max').style.display = 'block'; $('tree-button-min').style.display = 'none'; $('content-wrap').style.backgroundPosition = '0 0'; $('content').style.marginLeft = '232px'; $('sec-#secid#').style.backgroundPosition = '-404px 0'; return false;" id="tree-button-min"><span>Default Tree Width</span></a>
	</cfoutput>
	</cfcase>
	<cfdefaultcase>
	<!--- contracts menu iframe to enable larger content editing area --->
	<cfoutput>
	<a href="##" onclick="$('sidebar').style.width = '0'; $('iframe-sidebar').style.width = '0'; $('content-button-max').style.display = 'none'; $('content-button-min').style.display = 'block'; $('content-wrap').style.backgroundPosition = '-201px 0'; $('content').style.marginLeft = '35px'; $('sec-#secid#').style.backgroundPosition = '-605px 0'; return false;" id="content-button-max"><span>Maximise Content Width</span></a>
	<a href="##" onclick="$('sidebar').style.width = '200px'; $('iframe-sidebar').style.width = '200px'; $('content-button-max').style.display = 'block'; $('content-button-min').style.display = 'none'; $('content-wrap').style.backgroundPosition = '0 0'; $('content').style.marginLeft = '236px'; $('sec-#secid#').style.backgroundPosition = '-404px 0'; return false;" id="content-button-min"><span>Default Content Width</span></a>
	</cfoutput>
	</cfdefaultcase>
</cfswitch> --->

<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">