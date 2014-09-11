<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<%
String tabs1 = ParamUtil.getString(request, "tabs1", "calendar");

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("tabs1", tabs1);
%>

<div id="<portlet:namespace />alert"></div>

<!-- Additional class added for styling and organization purposes. -->
<div class="calendar-tab-bar">
	<!-- Conditional modified such that the tab bar will always be displayed. -->
	<!-- This is for the sake of maintaining space for the dropdown toggler button -->
	<!-- when the user is logged out. -->
	<c:choose>
		<c:when test="<%= themeDisplay.isSignedIn() %>">
			<liferay-ui:tabs
				names="calendar,resources"
				url="<%= portletURL.toString() %>"
			/>
		</c:when>

		<c:otherwise>
			<liferay-ui:tabs
				names="calendar"
				url="<%= portletURL.toString() %>"
			/>
		</c:otherwise>
	</c:choose>
</div>

<c:choose>
	<c:when test='<%= tabs1.equals("calendar") %>'>
		<liferay-util:include page="/view_calendar.jsp" servletContext="<%= application %>" />
	</c:when>
	<c:when test='<%= tabs1.equals("resources") %>'>
		<liferay-util:include page="/view_calendar_resources.jsp" servletContext="<%= application %>" />
	</c:when>
</c:choose>