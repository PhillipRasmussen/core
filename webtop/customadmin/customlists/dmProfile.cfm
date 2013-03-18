<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| DESCRIPTION ||
$Description: Permission administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:processform action="Change password">
	<cfset stProfile = createobject("component",application.stCOAPI.dmProfile.packagepath).getData(form.selectedobjectid) />
	
	<cfif stProfile.userdirectory eq "CLIENTUD">
		<cfset userID = application.factory.oUtils.listSlice(stProfile.username,1,-2,"_") />
		<cfset stUser = createobject("component",application.stCOAPI.farUser.packagepath).getByUserID(userID) />
		
		<cfif structIsEmpty(stUser)>
			<skin:bubble title="Error" message="This profile does not have a valid user attached. Please edit this profile to create a username/password." tags="security,error" />
		<cfelse>
			<cflocation url="#application.url.webtop#/conjuror/invocation.cfm?objectid=#stUser.objectid#&typename=farUser&method=editPassword&ref=typeadmin&module=customlists/dmProfile.cfm" />
		</cfif>
		
	<cfelse>
		<skin:bubble title="Error" message="'Change password' only applies to CLIENTUD users." tags="security,error" />
	</cfif>
</ft:processform>

<!--- set up page header --->
<admin:header title="User Admin" />


<!--- ONLY ALLOW DELETE BUTTON FOR PERMISSION NAME dmProfileDelete --->
<cfif application.fapi.checkTypePermission(typename="dmProfile", permission="dmProfileDelete")>
	<cfset lButtons = "Add,Delete,Properties,Unlock" />
<cfelse>
	<cfset lButtons = "Add,Properties,Unlock" />
</cfif>

<ft:objectadmin
	typename="dmProfile"
	title="User Administration"
	columnList="username,userdirectory,firstname,lastname" 
	sortableColumns="userid,userstatus"
	lFilterFields="username"
	sqlorderby="username asc" 
	lCustomActions="Change password"
	lButtons="#lButtons#"
 />

<admin:footer />