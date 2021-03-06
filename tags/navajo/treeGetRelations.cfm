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
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/treeGetRelations.cfm,v 1.19.2.1 2006/02/21 02:13:05 tlucas Exp $
$Author: tlucas $
$Date: 2006/02/21 02:13:05 $
$Name: milestone_3-0-1 $
$Revision: 1.19.2.1 $

|| DESCRIPTION || 

$Description: Takes an object and gets it relations. Relies upon the deployment of NTM stored procs and #application.packagepath#.farcry.tree component $



Relies upon the deployment of NTM stored procs and #application.packagepath#.farcry.tree component

|| USAGE ||
<nj:treeGetRelations
	objectId="0"
	get="Children"
	r_lObjectIds="lObjectIds"
	bInclusive="1">

|| DEVELOPER ||
$Developer: Matt Dawson (mad@daemon.com.au)$

|| ATTRIBUTES ||
$in: [attributes.objectId]: objectId to work from$
$in: [attributes.get]: what type of relationship to get [ ancestors, children, descendants ] :$
$in: [attributes.typename] typename for tree$
$in: [attributes.bInclusive]: whether to include the current node$
$out:[attributes.r_stObjects]: Objects found as structure$
$out:[attributes.r_lObjectIds]: Objects found as list of ids$
--->

<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<cfparam name="attributes.objectId" default="">
<cfparam name="attributes.lobjectIds" default="#attributes.objectId#">
<cfparam name="attributes.get">
<cfparam name="attributes.typename" default="dmNavigation">
<cfparam name="attributes.bInclusive">
<cfparam name="attributes.bIncludeObjects" default="1">
<cfparam name="attributes.lStatus" default="">
<cfparam name="attributes.lTypeIds" default="">
<cfparam name="attributes.nodetype" default="dmNavigation">


<cfparam name="attributes.r_stObjects" default="">
<cfparam name="attributes.r_stObject" default="">
<cfparam name="attributes.r_lObjectIds" default="">
<cfparam name="attributes.r_ObjectId" default="">

<cfif attributes.bInclusive>
	<cfset lObjectIds=attributes.objectId>
<cfelse>
	<cfset lObjectIds="">
</cfif>


<!--- internal structures to generate
lobjectids
stObjects
stObject
 --->

<cfif attributes.get eq "root">
	<cfscript>
		qRoot = application.factory.oTree.getRootNode(typename="#attributes.typename#");
	</cfscript>
	<cfset lObjectIds = qRoot.ObjectID>
</cfif>

<cfif attributes.get eq "children">
<!--- 
TODO
not too elegant
need to call tag or fourq function that has status as an option somehow
--->
<cfif attributes.typename eq "">
	<cfset attributes.typename = "dmNavigation">
</cfif>
<cfif attributes.typename is attributes.nodetype>
	<cfset qChildren = application.factory.oTree.getChildren(objectid=attributes.objectid)>
<cfelse>	
<!--- only relate to aObjectids if one exists --->
	<cfif StructKeyExists(application.types[attributes.typename].stProps,"aObjectIDs")>
		<cfquery name="qChildren" datasource="#application.dsn#">
		SELECT a.data AS objectID, b.title AS objectname from #application.dbowner##attributes.typename#_aObjectIDs a
		JOIN #application.dbowner##attributes.typename# b ON a.data = b.objectID
		WHERE a.parentID =  '#attributes.objectID#'
		</cfquery>
	<cfelse>
		<cfset qChildren = QueryNew("objectid")>
	</cfif>
</cfif>
<!--- 
get data from COAPI
TODO
this should be a COAPI call and *not* a straight SQL shortcut 
--->

<cfset lObjectIDs = "" />
<cfif qChildren.recordCount GT 0>
	<cfset lObjectIDs = valueList(qChildren.objectid) />
</cfif>
<cfif attributes.bInclusive>
	<cfset lObjectIDs = listAppend(lObjectIDs, attributes.objectid) />
</cfif>

<cfquery datasource="#application.dsn#" name="qObjects">
	SELECT objectid FROM #application.dbowner##attributes.typename#
	WHERE 1=1
	<cfif listLen(lObjectIDs)>
		AND objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lObjectIDs#" />)
	</cfif>
	<cfif len(attributes.lstatus)>
		AND status = '#attributes.lstatus#'
	</cfif>
</cfquery>

<cfset lobjectIDs="#ValueList(qObjects.objectid)#">

</cfif>



<cfloop index="attributes.objectId" list="#attributes.lobjectIds#">

	<!--- children --->
	<cfif attributes.get eq "children">
	
	<!--- do nothing	 --->
	
	<cfelseif attributes.get eq "ancestors">
	<!--- 	
	TODO
	if its a dmNavigation object we can go straight to the tree table
	Otherwise we have to look up the parent somehow.
	The parent could be either a dmNavigation or dmHTML object
	 --->	
 	<cfscript>
		qAncestors = application.factory.oTree.getAncestors(objectid=attributes.objectid,typename=attributes.nodetype);
	</cfscript>
	
	<cfset lobjectIDs="#ValueList(qAncestors.objectid)#">


	<cfelseif attributes.get eq "descendants">
	<!--- descendants --->
	<!--- loop while get children, non ordered list/stobjects --->
		<cfscript>
			getDescendantsRet = application.factory.oTree.getDescendants(objectid=attributes.objectID);
		</cfscript>
		<cfset lObjectIds = valueList(getDescendantsRet.objectID)>
	<cfelseif attributes.get eq "parents">
	<cfif attributes.typename is attributes.nodetype>
		<cfquery name="qGetParent" datasource="#application.dsn#">
			select  parentid from #application.dbowner#nested_tree_objects 
		    where objectid  = '#attributes.objectid#'
		</cfquery>	
	<cfelse>	
		<!--- TODO - MAJOR hack here.  --->
		<!--- This is the list of #typename#_aObjectIDs tables that we look
		 for the parent. This list is in ascending search order --->
		<cfset searchList = "#attributes.nodetype#,dmHTML">
		<cfset loop = true>
		<cfset listIndex = 1>
		<cfloop condition="loop">
				
			<cfquery name="qGetParent" datasource="#application.dsn#">
				SELECT parentID FROM #application.dbowner##listGetAt(searchlist,listIndex)#_aObjectIDs 
				WHERE data = '#attributes.objectID#'	
			</cfquery>	
			<cfif qGetParent.recordCount GT 0>
				<cfset loop = false>
			</cfif>
			<cfif listIndex IS listLen(searchList)>
				<cfset loop = false>
			</cfif> 
			<cfset listIndex = listIndex + 1>
		</cfloop>
	</cfif>	
		<!--- TODO - err must devise strategy to get parents of non dmNavigation Nodes --->
			


 	<!--- throw spaz if more than one parent, ordered by level--->
	<!--- <cfif qGetParent.recordCount gt 1>
		<cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Object has more than one parent, objectId='#attributes.objectId#'.">
	</cfif> --->
	
	<cfset lObjectIds=qGetParent.parentid>
	
	<cfelse>
	<cfthrow errorcode="navajo" detail="nj2TreeGetRelations:: Unknown attribute value passed, get='#attributes.get#'.">
	
	</cfif>

</cfloop>

<!--------------------------------------------------------------------
Build return result structures
--------------------------------------------------------------------->
<cfif len(attributes.r_ObjectID)>
	<cfset "caller.#attributes.r_ObjectId#" =  listgetat(lObjectIds,1)>
</cfif>

<cfif len(attributes.r_lObjectIds)>
	<cfset "caller.#attributes.r_lObjectIds#" = lObjectIds>
</cfif>

<cfif len(attributes.r_stObjects)>
	<q4:contentobjectGetMultiple lObjectIds="#lObjectIds#" r_stObjects="stObjects" typename="#application.types[attributes.typename].typePath#" bshallow="true">
	<cfset "caller.#attributes.r_stObjects#" = stObjects>
</cfif>

<cfif len(attributes.r_stObject)>
	<cfif listlen(lObjectIds)>
		<q4:contentobjectGet ObjectId="#listgetat(lObjectIds,1)#" r_stObject="stObject">
	<cfelse>
		<cfset stObject=structnew()>
	</cfif>
	<cfset "caller.#attributes.r_stObject#" = stObject>
</cfif>

<cfsetting enablecfoutputonly="No">