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
$Header: /cvs/farcry/core/tags/navajo/objectStatus.cfm,v 1.47.2.5 2006/01/23 22:30:32 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:30:32 $
$Name:  $
$Revision: 1.47.2.5 $

|| DESCRIPTION || 
$Description: changes status of tree item $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
 
<cfparam name="url.objectId">
<cfparam name="url.status" default="0">
<cfparam name="attributes.lObjectIDs" default="#url.objectId#">


<cfset changestatus = true>

<!--- set up page header --->
<skin:view typename="dmHTML" webskin="webtopHeaderModal" />

<!--- show comment form --->
<cfif not isdefined("form.commentLog")>
	<cfset stApprovers = "*" />
	<cfset astObj = arraynew(1) />
	<cfset oWorkflow = createobject("component","#application.packagepath#.farcry.workflow") />
	<cfloop list="#attributes.lObjectIDs#" index="thisobjectid">
		<!--- Get object --->
		<q4:contentobjectget objectid="#thisobjectid#" r_stobject="stObj">
		<cfset arrayappend(astObj,stObj) />
		
		<cfif url.status eq "requestApproval">
			<!--- get list of approvers for this object --->
			<cfset stApproversThisObject = oWorkflow.getObjectApprovers(objectID=thisobjectid) />
			<cfif isstruct(stApprovers)>
				<!--- Update stApprovers as the intersection of stApprovers and stApproversThisObject --->
				<cfloop collection="#stApprovers#" item="approver">
					<cfif not structkeyexists(stApproversThisObject,approver)>
						<cfset structdelete(stApprovers,approver) />
					</cfif>
				</cfloop>
			<cfelse>
				<!--- The intersection of one set is that set :) --->
				<cfset stApprovers = duplicate(stApproversThisObject) />
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- This code assumes all objects passed in are the same type, and therfore that the first item is representative of them all --->
	<cfif structkeyexists(astObj[1],"status")>
		<cfoutput>
		<script type="text/javascript">	
		function deSelectAll(allapprovers)
		{
			if(allapprovers.checked = true){
				$j('input[name=lApprovers]').each(function(index){
					if (index>0) this.checked = false;
				});
			}
			return true;
		}
		</script>
		<ft:form>
			<h1>
				<cfif isDefined("URL.draftObjectID")>
					#application.rb.getResource("workflow.messages.objStatusRequest@text","Set content item status for underlying draft content item to 'request'")#
				<cfelse>
					#application.rb.formatRBString("workflow.messages.setObjStatus@text",url.status,"Set content item status to {1}")#
				</cfif>
			</h1>
			<ft:fieldset>
				<ft:field label="#application.rb.getResource("workflow.fields.addComments@label","Add your comments:")#">
					<textarea cols="80" rows="10"  name="commentLog" class="textareaInput"></textarea>
				</ft:field>
				
				<cfif url.status eq "requestApproval" and structcount(stApprovers)>
					<ft:field label="Notify Approvers" bMultiField="true">
						<input type="checkbox" onclick="if(this.checked)deSelectAll(this);" name="lApprovers" value="all" checked="checked" id="allapprovers"> #application.rb.getResource("workflow.fields.requestApprovalFrom@allApprovers","All approvers")#<br />
						<!--- loop over approvers and display ones that have email profiles --->
						<cfloop collection="#stApprovers#" item="item">
						    <cfif stApprovers[item].emailAddress neq "" AND stApprovers[item].bReceiveEmail and stApprovers[item].userName neq application.security.getCurrentUserId()>
								<input type="checkbox" name="lApprovers" onclick="if(this.checked) $j('input[name=lApprovers]')[0].checked = false;" value="#stApprovers[item].userName#"><cfif len(stApprovers[item].firstName) gt 0> #encodeForHTML(stApprovers[item].firstName)# #encodeForHTML(stApprovers[item].lastName)#<cfelse>#encodeForHTML(stApprovers[item].userName)#</cfif><br />
							</cfif>
						</cfloop>
						
						<ft:fieldHint>
							Select the approvers that you would like to be notified by email about your approval request.
						</ft:fieldHint>
					</ft:field>
				<cfelseif url.status eq "requestApproval">
					<p class="error">There are no users that have permission to approve all items. Request approval for items one at a time or manually notify potential approvers.</p>
				</cfif>
			</ft:fieldset>
			
			<ft:buttonPanel>
				<ft:button value="Submit" text="Change Status" />
				<ft:button value="Cancel" text="Cancel" />
			</ft:buttonPanel>
		
			<!--- display existing comments --->
			<nj:showcomments objectid="#astObj[1].objectid#" typename="#astObj[1].typename#" />
		</ft:form>
		</cfoutput>
		<cfset changestatus = false>
	</cfif>
</cfif>

<cfif changestatus eq true>
	<ft:processForm action="Submit">
		<cfloop index="attributes.objectID" list="#attributes.lObjectIDs#">
			<cfset stObj = application.fapi.getContentObject(objectid=attributes.objectid) />
			<cfset stRules = application.factory.oVersioning.getVersioningRules(objectid=stObj.objectid,typename=stObj.typename) />

			<cfif not structkeyexists(stObj, "status")>
				<cfoutput>
				<script type="text/javascript">
					alert("#application.rb.getResource('workflow.messages.objNoApprovalProcess@text','This content item type has no approval process attached to it.')#");
					window.close();
				</script>
				</cfoutput>
				<cfabort>
			</cfif>
			
			<!--- get the navigation root navigation of this object to check permissions on it --->
			<nj:getNavigation objectId="#stObj.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="objectId">
	
			<cfif url.status eq "approved">
				<cfset status = "approved">
				<cfset permission = "approve,canApproveOwnContent">
				<cfset active = 1>
				<!--- send out emails informing object has been approved --->
				<cfset application.factory.oVersioning.approveEmail_approved(objectid=stObj.objectid,comment=form.commentlog) />
			<cfelseif url.status eq "draft">
				<cfset status = 'draft'>
				<cfset permission = "approve,canApproveOwnContent">
				<!--- send out emails informing object has been sent back to draft --->
				<cfset application.factory.oVersioning.approveEmail_draft(objectid=stObj.objectid,comment=form.commentlog) />
				<cfset active = 0>
			<cfelseif url.status eq "requestApproval">
				<cfset status = "pending">
				<cfset permission = "requestApproval">
				<cfset active = 0>
				<!--- checkk if underlying draft obejct --->
				<cfif isDefined("URL.draftObjectID")>
					<cfset pendingObject = "#URL.draftObjectID#"/>
				<cfelse>
					<cfset pendingObject = "#stObj.objectID#"/>
				</cfif>
				<!--- send out emails informing object needs approval --->
				<cfif not isdefined("form.lApprovers") or not len(form.lApprovers) or listfindnocase(form.lApprovers,"all")>
					<cfset form.lApprovers = "all" />
				</cfif>
				<cfset application.factory.oVersioning.approveEmail_pending(objectid=pendingObject,comment=form.commentLog,lApprovers=form.lApprovers) />
			<cfelse>
				<cfoutput><b>#application.rb.formatRBString("workflow.messages.unknownStatusPassed@text",url.status,"Unknown status passed. ({1})")#<b><br></cfoutput><cfabort>
			</cfif>
			<cfif isstruct(stNav)>
				<cfscript>
					for(x = 1;x LTE listLen(permission);x=x+1)
					{
						iState = application.security.checkPermission(permission=listGetAt(permission,x),object=stNav.objectId);	
						if(listGetAt(permission,x) IS "canApproveOwnContent" AND iState EQ 1 AND NOT stObj.lastUpdatedBy IS application.security.getCurrentUserID())
							iState = 0;
						if(iState EQ 1)
							break;
					}	
				</cfscript>
				<cfif iState neq 1><cfoutput>
					<script type="text/javascript">						
						<cfset defaultText="You don't have approval permission on the subnode {1}" />
						alert("#application.rb.formatRBString('security.messages.nosubNodeApprovalPermission@text',stNav.title,'#defaultText#')#");
						window.close();
					</script></cfoutput><cfabort>
				</cfif>
			</cfif>
			
			<cfif url.status eq "approve">
				<cfscript>
					iState = application.security.checkPermission(permission="CanApproveOwnContent",object=stNav.objectId);	
				</cfscript>
			
				<cfif iState neq 1>
					<cfif request.bLoggedIn>
						<cfif session.security.userid eq stObj.attr_lastUpdatedBy><cfoutput>
							<script type="text/javascript">
								<cfset defaultText="You don't have permission to approve your own content on {1}" />
								alert("#application.rb.formatRBString('security.messages.canApproveOwnContent@text',stNav.title,'#defaultText#')#");
								window.close();
							</script></cfoutput><cfabort>
						</cfif>
					<cfelse><cfoutput>
						<script type="text/javascript">
							<cfset defaultText="You aren't logged in" />
							alert("#application.rb.getResource('security.messages.notLoggedIn@text','#defaultText#')#");
							window.close();
						</script></cfoutput><cfabort>
					</cfif>
				</cfif>
			</cfif>
			<!--- Call this to get all descendants of this node --->
	
			<!--- If we are approving the whole branch - then we will be wanting all objectIDS --->
			<cfif isDefined("URL.approveBranch")>
				<cfset keyList = attributes.objectID>
				<cfif stObj.typename EQ "dmNavigation">
					<cfif isArray(stObj.aObjectIds)>
						<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
					</cfif>
				</cfif>
				<cfscript>
					qGetDescendants = application.factory.oTree.getDescendants(objectid=attributes.objectID);
				</cfscript>
							
				<cfset keyList = listAppend(keyList,valueList(qGetDescendants.objectId))>
				<cfloop query="qGetDescendants">
					<q4:contentobjectget objectId="#qGetDescendants.objectId#" r_stObject="stThisObj">
					<cfif stObj.typename EQ "dmNavigation">
						<cfif isArray(stThisObj.aObjectIds)>
							<cfset keyList = listAppend(keyList,arrayToList(stThisObj.aObjectIds))>
						</cfif>	
					</cfif>
				</cfloop>
			<cfelse>  <!--- else - just get the objectIDS in this nodes aObjects array --->
				<cfif isDefined("URL.draftObjectID")>
					<cfset keyList = URL.draftObjectID>
				<cfelse>	
					<cfset keyList = attributes.objectID>
				</cfif>	
				<cfif stObj.typename EQ "dmNavigation">
					<cfif isdefined("stObj.aObjectIds") and isArray(stObj.aObjectIds)>
						<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
					</cfif>
				</cfif>
			</cfif>
									
			<cfoutput><h1>Changing status…</h1></cfoutput>
			
			<!--- update the structure data for object update --->
			<cfloop list="#keyList#" index="key">
				<cfset stObj = application.fapi.getContentObject(objectid=key) />
				
				<cfif NOT structIsEmpty(stObj)>
					<cfif structKeyExists(stobj, "status") AND stObj.label NEQ "(incomplete)"> <!--- incompletet items check .: dont send incomplete items live --->
						
						<cfset stRules = application.factory.oVersioning.getVersioningRules(objectid=key,typename=stObj.typename) />
						
						<!--- If the user is trying to approve or request approval an approved object, we will assume they are trying to change the status the draft object if there is one. --->
						<cfif (url.status eq "approved" OR url.status eq "requestApproval") AND stobj.status EQ "approved" and stRules.bDraftVersionExists AND len(stRules.draftobjectID)>
							<cfset stObj = application.fapi.getContentObject(objectid=stRules.draftobjectID) />
							<cfset stRules = application.factory.oVersioning.getVersioningRules(objectid=stObj.objectid,typename=stObj.typename) />
						</cfif>
						
						<!--- prepare date fields --->
						<cfloop collection="#stObj#" item="field">
							<cfif StructKeyExists(application.types[stObj.typeName].stProps, field) AND application.types[stObj.typeName].stProps[field].metaData.type EQ "date">
								<cfif IsDate(stObj[field])>
									<cfset stObj[field] = CreateODBCDateTime(stObj[field])>
									<!--- G.S commented out this, i dont why it is here but defaults expiry date to a date that will never let the content render --->
								<!--- <cfelse>
									<cfset tempdate = CreateDate(year(Now()),month(Now()),day(Now()))>
									<cfset stObj[field] = CreateODBCDateTime(tempdate)> --->
								</cfif>
							</cfif>
						</cfloop>
						
						<cfset stObj.datetimelastupdated = createODBCDateTime(now()) />
			
						<cfset stObj.status = status />
						

						<cfif stRules.bLiveVersionExists and url.status eq "approved">
							<!--- Then we want to swap live/draft and archive current live --->
							<cfset stRules = application.factory.oVersioning.sendObjectLive(objectid=stObj.objectid,stDraftObject=stObj) />
							<cfparam name="returnObjectID" default="#stObj.objectid#">
														
						<cfelse>
							
							<cfif stRules.bDraftVersionExists and url.status eq "draft">
								<!--- sending a live object to draft, draft object already exists --->
								<q4:contentobjectdelete objectid="#stRules.draftObjectID#">
							</cfif>
							
							<cfscript>
								oType = createobject("component", application.types[stObj.typename].typePath);
								oType.setData(stProperties=stObj,bAudit=false);
							</cfscript>
							
							<cfif stObj.typename neq "dmImage" and stObj.typename neq "dmFile">
								<cfparam name="returnObjectID" default="#attributes.lObjectIDs#">
							</cfif>
							
						</cfif>
						
						<skin:bubble title="#stObj.label#" message="Status changed to #status#" tags="type,#stObj.typename#,workflow,info" />
						<farcry:logevent object="#stObj.objectid#" type="types" event="to#status#" note="#form.commentLog#" />
						
					</cfif> <!--- // incomplete items check  --->
					
				</cfif>
			</cfloop>
		</cfloop>

	</ft:processForm>

	<cfif listlen(url.objectid) gt 1 and not find(cgi.SCRIPT_NAME,cgi.http_referer)>
		<cfparam name="returnObjectId" default="#attributes.lObjectIDs#"><cfoutput>
		<script type="text/javascript">
		if(top == self)
			window.close();
		else{
			location.href = "#cgi.http_referer#";
		}
		</script></cfoutput>
	<cfelseif listlen(url.objectid) gt 1>
		<cfoutput><p class="success">Objects updated: #listlen(url.objectid)#</p></cfoutput>
	<cfelse>
		<cfparam name="returnObjectId" default="#listFirst(attributes.lObjectIDs)#"><cfoutput>
		<script type="text/javascript">
		if(top == self) {
			window.close();
		} else{
			location.href = "#application.url.farcry#/edittabOverview.cfm?objectid=#returnObjectId#";
		}
		</script></cfoutput>
	</cfif>
	
</cfif>                                                                                

<!--- setup footer --->
<skin:view typename="dmHTML" webskin="webtopFooterModal" />

<cfsetting enablecfoutputonly="No">