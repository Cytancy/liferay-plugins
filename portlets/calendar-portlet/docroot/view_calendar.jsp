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
String activeView = ParamUtil.getString(request, "activeView", sessionClicksDefaultView);
long date = ParamUtil.getLong(request, "date", System.currentTimeMillis());

List<Calendar> groupCalendars = null;

if (groupCalendarResource != null) {
	groupCalendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, new long[] {groupCalendarResource.getCalendarResourceId()}, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);
}

List<Calendar> userCalendars = null;

if (userCalendarResource != null) {
	userCalendars = CalendarServiceUtil.search(themeDisplay.getCompanyId(), null, new long[] {userCalendarResource.getCalendarResourceId()}, null, true, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);
}

List<Calendar> otherCalendars = new ArrayList<Calendar>();

long[] calendarIds = StringUtil.split(SessionClicks.get(request, "calendar-portlet-other-calendars", StringPool.BLANK), 0L);

for (long calendarId : calendarIds) {
	Calendar calendar = CalendarServiceUtil.fetchCalendar(calendarId);

	if (calendar != null) {
		CalendarResource calendarResource = calendar.getCalendarResource();

		if (calendarResource.isActive()) {
			otherCalendars.add(calendar);
		}
	}
}

Calendar defaultCalendar = null;

List<Calendar> defaultCalendars = Collections.emptyList();

if ((groupCalendars != null) && (groupCalendars.size() > 0)) {
	defaultCalendars = groupCalendars;
}
else if (userCalendars != null) {
	defaultCalendars = userCalendars;
}

for (Calendar calendar : defaultCalendars) {
	if (calendar.isDefaultCalendar()) {
		defaultCalendar = calendar;

		break;
	}
}

JSONArray groupCalendarsJSONArray = CalendarUtil.toCalendarsJSONArray(themeDisplay, groupCalendars);
JSONArray userCalendarsJSONArray = CalendarUtil.toCalendarsJSONArray(themeDisplay, userCalendars);
JSONArray otherCalendarsJSONArray = CalendarUtil.toCalendarsJSONArray(themeDisplay, otherCalendars);

boolean columnOptionsVisible = GetterUtil.getBoolean(SessionClicks.get(request, "calendar-portlet-column-options-visible", "true"));
%>

<!-- Dropdown view menu implementation. -->

<!-- Uses a taglib where the message is set to the current view. -->
<liferay-ui:icon-menu cssClass="calendar-dropdown-view-menu" direction="down" icon="<%= StringPool.BLANK %>" localizeMessage="<%= true %>" message='<%= _getCurrentView(request, sessionClicksDefaultView) %>'>

	<!-- Hard codes the four views due to limitations preventing the acquisition -->
	<!-- of the views server side. -->

	<!-- Each icon options makes a javascript call sending the requested view. -->
	<liferay-ui:icon
		iconCssClass="<%= StringPool.BLANK %>"
		message="day"
		onClick="setView('day');"
		url="javascript:;"
	/>

	<liferay-ui:icon
		iconCssClass="<%= StringPool.BLANK %>"
		localizeMessage="<%= true %>"
		message="week"
		onClick="setView('week');"
		url="javascript:;"
	/>

	<liferay-ui:icon
		iconCssClass="<%= StringPool.BLANK %>"
		localizeMessage="<%= true %>"
		message="month"
		onClick="setView('month');"
		url="javascript:;"
	/>

	<liferay-ui:icon
		iconCssClass="<%= StringPool.BLANK %>"
		localizeMessage="<%= true %>"
		message="agenda"
		onClick="setView('agenda');"
		url="javascript:;"
	/>
</liferay-ui:icon-menu>

<%!
	private String _getCurrentView(HttpServletRequest request, String sessionClicksDefaultView) {
		String test = ParamUtil.getString(request, "activeView", sessionClicksDefaultView);
		return  test;
	}
%>

<!-- Changed from an AUI container taglib to a basic div. -->
<!-- The styling from the taglib was unnecessary. -->
<div class="calendar-portlet-column-parent">
	<aui:row>
		<aui:col cssClass='<%= "calendar-portlet-column-options " + (columnOptionsVisible ? StringPool.BLANK : "hide") %>' id="columnOptions" span="<%= 3 %>">

			<!-- Other components moved down and reorganized below a new header that -->
			<!-- contains the text 'Visible Calendars' to be displayed -->
			<!-- in mobile views. -->

			<!-- Reorganization is for layout purposes. -->

			<div class="calendar-options-container">
				<div class="calendar-mobile-header"><span class="header-content"><liferay-ui:message key="visible-calendars" /></span></div>


				<div class="calendar-portlet-mini-calendar" id="<portlet:namespace />miniCalendarContainer"></div>

				<div class="calendar-list-display" id="<portlet:namespace />calendarListContainer">
					<c:if test="<%= themeDisplay.isSignedIn() %>">
						<!-- Class set to collapsed so that 'Visible Calendar' dropdowns -->
						<!-- default as collapsed. -->
						<div class="calendar-portlet-list-header toggler-header-collapsed">
							<span class="calendar-portlet-list-arrow"></span>

							<span class="calendar-portlet-list-text"><liferay-ui:message key="my-calendars" /></span>

							<c:if test="<%= userCalendarResource != null %>">
								<span class="calendar-list-item-arrow" data-calendarResourceId="<%= userCalendarResource.getCalendarResourceId() %>" tabindex="0"><i class="icon-caret-down"></i></span>
							</c:if>
						</div>

						<!-- Content classes have a collapsed tag added for the same -->
						<!-- reason as listed above. -->
						<div class="calendar-portlet-calendar-list toggler-content-collapsed" id="<portlet:namespace />myCalendarList"></div>
					</c:if>

					<c:if test="<%= groupCalendarResource != null %>">
						<div class="calendar-portlet-list-header toggler-header-collapsed">
							<span class="calendar-portlet-list-arrow"></span>

							<span class="calendar-portlet-list-text"><liferay-ui:message key="current-site-calendars" /></span>

							<c:if test="<%= CalendarResourcePermission.contains(permissionChecker, groupCalendarResource, ActionKeys.ADD_CALENDAR) %>">
								<span class="calendar-list-item-arrow" data-calendarResourceId="<%= groupCalendarResource.getCalendarResourceId() %>" tabindex="0"><i class="icon-caret-down"></i></span>
							</c:if>
						</div>

						<div class="calendar-portlet-calendar-list toggler-content-collapsed" id="<portlet:namespace />siteCalendarList"></div>
					</c:if>

					<c:if test="<%= themeDisplay.isSignedIn() %>">
						<div class="calendar-portlet-list-header toggler-header-collapsed">
							<span class="calendar-portlet-list-arrow"></span>

							<span class="calendar-portlet-list-text"><liferay-ui:message key="other-calendars" /></span>
						</div>

						<div class="calendar-portlet-calendar-list toggler-content-collapsed" id="<portlet:namespace />otherCalendarList">
							<input class="calendar-portlet-add-calendars-input" id="<portlet:namespace />addOtherCalendar" placeholder="<liferay-ui:message key="add-other-calendars" />" type="text" />
						</div>
						</c:if>
				</div>

				<div id="<portlet:namespace />message"></div>
			</div>
		</aui:col>

		<aui:col cssClass="calendar-portlet-column-grid" id="columnGrid" span="<%= columnOptionsVisible ? 9 : 12 %>">
			<div class="calendar-portlet-column-toggler" id="<portlet:namespace />columnToggler">
				<i class="<%= columnOptionsVisible ? "icon-caret-left" : "icon-caret-right" %>" id="<portlet:namespace />columnTogglerIcon"></i>
			</div>

			<liferay-util:include page="/scheduler.jsp" servletContext="<%= application %>">
				<liferay-util:param name="activeView" value="<%= activeView %>" />
				<liferay-util:param name="date" value="<%= String.valueOf(date) %>" />

				<portlet:renderURL var="editCalendarBookingURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
					<portlet:param name="mvcPath" value="/edit_calendar_booking.jsp" />
					<portlet:param name="activeView" value="{activeView}" />
					<portlet:param name="allDay" value="{allDay}" />
					<portlet:param name="calendarBookingId" value="{calendarBookingId}" />
					<portlet:param name="calendarId" value="{calendarId}" />
					<portlet:param name="date" value="{date}" />
					<portlet:param name="endTimeDay" value="{endTimeDay}" />
					<portlet:param name="endTimeHour" value="{endTimeHour}" />
					<portlet:param name="endTimeMinute" value="{endTimeMinute}" />
					<portlet:param name="endTimeMonth" value="{endTimeMonth}" />
					<portlet:param name="endTimeYear" value="{endTimeYear}" />
					<portlet:param name="instanceIndex" value="{instanceIndex}" />
					<portlet:param name="startTimeDay" value="{startTimeDay}" />
					<portlet:param name="startTimeHour" value="{startTimeHour}" />
					<portlet:param name="startTimeMinute" value="{startTimeMinute}" />
					<portlet:param name="startTimeMonth" value="{startTimeMonth}" />
					<portlet:param name="startTimeYear" value="{startTimeYear}" />
					<portlet:param name="titleCurrentValue" value="{titleCurrentValue}" />
				</portlet:renderURL>

				<liferay-util:param name="editCalendarBookingURL" value="<%= editCalendarBookingURL %>" />

				<liferay-util:param name="readOnly" value="<%= String.valueOf(false) %>" />

				<liferay-security:permissionsURL
					modelResource="<%= CalendarBooking.class.getName() %>"
					modelResourceDescription="{modelResourceDescription}"
					resourceGroupId="{resourceGroupId}"
					resourcePrimKey="{resourcePrimKey}"
					var="permissionsCalendarBookingURL"
					windowState="<%= LiferayWindowState.POP_UP.toString() %>"
				/>

				<liferay-util:param name="permissionsCalendarBookingURL" value="<%= permissionsCalendarBookingURL %>" />

				<liferay-util:param name="showAddEventBtn" value="<%= String.valueOf((userDefaultCalendar != null) && CalendarPermission.contains(permissionChecker, userDefaultCalendar, ActionKeys.MANAGE_BOOKINGS)) %>" />

				<portlet:renderURL var="viewCalendarBookingURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
					<portlet:param name="mvcPath" value="/view_calendar_booking.jsp" />
					<portlet:param name="calendarBookingId" value="{calendarBookingId}" />
					<portlet:param name="instanceIndex" value="{instanceIndex}" />
				</portlet:renderURL>

				<liferay-util:param name="viewCalendarBookingURL" value="<%= viewCalendarBookingURL %>" />
			</liferay-util:include>
		</aui:col>
	</aui:row>
</div>

<%@ include file="/view_calendar_menus.jspf" %>

<!-- Script functions that are placed in this scope that they can be called  -->
<!-- by the dropdown view buttons. -->

<aui:script>
	var setView = function(viewName) {
		<!-- Sets the view using the scheduler 'set' function. -->
		<portlet:namespace />scheduler.set('activeView',<portlet:namespace />scheduler.getViewByName(viewName));

		<!-- Sets the text displayed by the dropdown menu to be the current active veiw.  -->

		document.getElementById("p_p_id<portlet:namespace/>").getElementsByClassName("calendar-dropdown-view-menu")[0].getElementsByClassName("lfr-icon-menu-text")[0].innerHTML = <portlet:namespace />scheduler.get('strings')[<portlet:namespace />scheduler.get('activeView').get('name')];
	};

	var getViewNodes = function() {
		return (<portlet:namespace />scheduler.get('viewsNode')._node.childNodes);
	};
</aui:script>

<aui:script use="aui-toggler,liferay-calendar-list,liferay-scheduler,liferay-store,json">
	Liferay.CalendarUtil.USER_CLASS_NAME_ID = <%= PortalUtil.getClassNameId(User.class) %>;

	<c:if test="<%= defaultCalendar != null %>">
		Liferay.CalendarUtil.DEFAULT_USER_CALENDAR_ID = <%= defaultCalendar.getCalendarId() %>;
	</c:if>

	var syncCalendarsMap = function() {
		var calendarLists = [];

		<c:if test="<%= themeDisplay.isSignedIn() || (groupCalendarResource != null) %>">
			calendarLists.push(window.<portlet:namespace />myCalendarList);
		</c:if>

		<c:if test="<%= themeDisplay.isSignedIn() %>">
			calendarLists.push(window.<portlet:namespace />otherCalendarList);
		</c:if>

		<c:if test="<%= groupCalendarResource != null %>">
			calendarLists.push(window.<portlet:namespace />siteCalendarList);
		</c:if>

		Liferay.CalendarUtil.syncCalendarsMap(calendarLists);
	}

	<!-- Javascript functions and variables used for functionality and  -->
	<!-- layout purposes. -->

	<!-- The site window node. -->
	var win = A.getWin();
	<!-- The calendar portlet node. -->
	var calendarPortlet = A.one('#p_p_id<portlet:namespace/>');
	<!-- The node representing the toggler button. -->
	var togglerNode = calendarPortlet.one('.calendar-portlet-column-toggler');
	<!-- The node representing the container that holds tabs at the top of  -->
	<!-- the portlet. -->
	var topBarNode = calendarPortlet.one('.calendar-tab-bar');
	<!-- The node representing the tabs at the top of the portlet. -->
	var tabsNode = topBarNode.one('.nav-tabs');
	<!-- The node that will be used to represent the caret inside the toggler button.  -->
	var caretNode = null;
	<!-- The node that represents the 'Visible Calendars' pane. -->
	var calendarOptionsNode = calendarPortlet.one('.calendar-portlet-column-options');
	<!-- The node that represents the block element that holds the calendar's -->
	<!-- navigation controls (e.g. 'Add Event', 'Today, '<', '>', Month, Day, etc.). -->
	var schedulerControlsNode = calendarPortlet.one('.scheduler-base-controls');
	<!-- Condition representing whether or not the portlet has been in mobile view. -->
	var stateMobile = false;
	<!-- Strange offset value that seems to differ from actual page width. -->
	var widthOffset = 17;

	<!-- Function that is run on load for organization purposes. -->
	var <portlet:namespace />loadOrganizer = function() {
		<!-- Places the calendar controls outside of the scheduler component. -->
		<!-- This allows the 'Viewable Calendars' side-pane to not squish -->
		<!-- these controls in desktop view. -->
		topBarNode.insert(schedulerControlsNode, 'after');

		<!-- Inserts the dropdown taglib into the calendar controls. -->
		<!-- Must be done this way because the controls live in the JS side -->
		<!-- whereas taglibs must be generated on the server side. -->
		schedulerControlsNode.one('.btn-group').insert(calendarPortlet.one('.calendar-dropdown-view-menu'), 'before');
	}

	<!-- Function that runs on load and resize for organization purposes. -->
	var <portlet:namespace />viewOrganizer = function() {
		var winWidth = win.width() + widthOffset;

		<!-- On condition [Tablet/Mobile View] -->
		if (winWidth < 992) {
			<!-- Changes caret direction from vertical to horizontal to match -->
			<!-- the new location and function of the toggler button. -->
			caretNode = togglerNode.one('.icon-caret-right');
			if (caretNode) caretNode.replaceClass('icon-caret-right', 'icon-caret-down');

			caretNode = togglerNode.one('.icon-caret-left');
			if (caretNode) caretNode.replaceClass('icon-caret-left', 'icon-caret-up');

			<!-- Places the calendar controls after the 'Visible Calendars' pane. -->
			<!-- This is so that the 'Visible Calendars' pane appears directly below -->
			<!-- the toggle button. -->
			<!-- Remove this line of code for a better understanding of what it does. -->
			calendarOptionsNode.insert(schedulerControlsNode, 'after');

			<!-- Gives the toggler button-styling when it becomes a button -->
			<!-- in mobile view. -->
			togglerNode.addClass('btn btn-default');

			<!-- Moves the toggler button to the same container as the tabs -->
			<!-- so that they occupy the same space. -->
			tabsNode.appendChild(togglerNode);

			stateMobile = true;
		}
		<!-- On condition [Was in Tablet/Mobile View] -->
		<!-- Exists for the case when the user stretches -->
		<!-- the window in and our without reloading. -->
		else if (stateMobile) {
			<!-- Returns caret direction from horizontal to vertical to match -->
			<!-- the old location and function of the toggler button. -->
			caretNode = togglerNode.one('.icon-caret-down');
			if (caretNode) caretNode.replaceClass('icon-caret-down', 'icon-caret-right');

			caretNode = togglerNode.one('.icon-caret-up');
			if (caretNode) caretNode.replaceClass('icon-caret-up', 'icon-caret-left');

			<!-- Returns the scheduler controls to its previous location. -->
			topBarNode.insert(schedulerControlsNode, 'after');

			<!-- Removes the button classes since they no longer apply. -->
			togglerNode.removeClass('btn btn-default');

			<!-- Returns the toggler button to its original location. -->
			calendarPortlet.one('.calendar-portlet-wrapper').insert(togglerNode, 'before');

			stateMobile = false;
		}
	};

	<!-- Temporary "bug fix" since glyphicons don't appear to work. -->
	<!-- When glyphicons are fixed, the CSS counterparts also need to be changed -->
	<!-- the have the 'glyphicon-' prefix. -->
	calendarPortlet.all('.glyphicon-chevron-left').replaceClass('glyphicon-chevron-left', 'icon-chevron-left')
	calendarPortlet.all('.glyphicon-chevron-right').replaceClass('glyphicon-chevron-right', 'icon-chevron-right')

	<!-- Calls the above two functions. -->
	win.on(
		'load', <portlet:namespace />loadOrganizer
	);

	win.on(
		['resize', 'load'],
		A.debounce(<portlet:namespace />viewOrganizer, 100)
	);


	window.<portlet:namespace />syncCalendarsMap = syncCalendarsMap;

	window.<portlet:namespace />calendarLists = {};

	<c:if test="<%= themeDisplay.isSignedIn() || (groupCalendarResource != null) %>">
		window.<portlet:namespace />myCalendarList = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: syncCalendarsMap,
					'scheduler-calendar:visibleChange': function(event) {
						syncCalendarsMap();

						<portlet:namespace />refreshVisibleCalendarRenderingRules();
					}
				},
				boundingBox: '#<portlet:namespace />myCalendarList',

				<%
				updateCalendarsJSONArray(request, userCalendarsJSONArray);
				%>

				calendars: <%= userCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: window.<portlet:namespace />calendarsMenu,
				visible: <%= themeDisplay.isSignedIn() %>
			}
		).render();

		window.<portlet:namespace />calendarLists['<%= userCalendarResource.getCalendarResourceId() %>'] = window.<portlet:namespace />myCalendarList;
	</c:if>

	<c:if test="<%= themeDisplay.isSignedIn() %>">
		window.<portlet:namespace />otherCalendarList = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: function(event) {
						syncCalendarsMap();

						<portlet:namespace />scheduler.load();

						var calendarIds = A.Array.invoke(event.newVal, 'get', 'calendarId');

						Liferay.Store('calendar-portlet-other-calendars', calendarIds.join());
					},
					'scheduler-calendar:visibleChange': function(event) {
						syncCalendarsMap();

						<portlet:namespace />refreshVisibleCalendarRenderingRules();
					}
				},
				boundingBox: '#<portlet:namespace />otherCalendarList',

				<%
				updateCalendarsJSONArray(request, otherCalendarsJSONArray);
				%>

				calendars: <%= otherCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: window.<portlet:namespace />calendarsMenu
			}
		).render();
	</c:if>

	<c:if test="<%= groupCalendarResource != null %>">
		window.<portlet:namespace />siteCalendarList = new Liferay.CalendarList(
			{
				after: {
					calendarsChange: syncCalendarsMap,
					'scheduler-calendar:visibleChange': function(event) {
						syncCalendarsMap();

						<portlet:namespace />refreshVisibleCalendarRenderingRules();
					}
				},
				boundingBox: '#<portlet:namespace />siteCalendarList',

				<%
				updateCalendarsJSONArray(request, groupCalendarsJSONArray);
				%>

				calendars: <%= groupCalendarsJSONArray %>,
				scheduler: <portlet:namespace />scheduler,
				simpleMenu: window.<portlet:namespace />calendarsMenu
			}
		).render();

		window.<portlet:namespace />calendarLists['<%= groupCalendarResource.getCalendarResourceId() %>'] = window.<portlet:namespace />siteCalendarList;
	</c:if>

	syncCalendarsMap();

	A.each(
		Liferay.CalendarUtil.availableCalendars,
		function(item, index) {
			item.on(
				{
					'visibleChange': function(event) {
						var instance = this;

						var calendar = event.currentTarget;

						Liferay.Store('calendar-portlet-calendar-' + calendar.get('calendarId') + '-visible', event.newVal);
					}
				}
			);
		}
	);

	window.<portlet:namespace />toggler = new A.TogglerDelegate(
		{
			animated: true,
			container: '#<portlet:namespace />calendarListContainer',
			content: '.calendar-portlet-calendar-list',
			<!-- Changes the toggler to be collapsed by default. -->
			expanded: false,
			header: '.calendar-portlet-list-header'
		}
	);

	<c:if test="<%= themeDisplay.isSignedIn() %>">
		var addOtherCalendarInput = A.one('#<portlet:namespace />addOtherCalendar');

		<liferay-portlet:resourceURL copyCurrentRenderParameters="<%= false %>" id="calendarResources" var="calendarResourcesURL" />

		Liferay.CalendarUtil.createCalendarsAutoComplete(
			'<%= calendarResourcesURL %>',
			addOtherCalendarInput,
			function(event) {
				window.<portlet:namespace />otherCalendarList.add(event.result.raw);

				<portlet:namespace />refreshVisibleCalendarRenderingRules();

				addOtherCalendarInput.val('');
			}
		);
	</c:if>

	A.one('#<portlet:namespace />columnToggler').on(
		'click',
		function(event) {
			var columnGrid = A.one('#<portlet:namespace />columnGrid');
			var columnOptions = A.one('#<portlet:namespace />columnOptions');
			var columnTogglerIcon = A.one('#<portlet:namespace />columnTogglerIcon');

			Liferay.Store('calendar-portlet-column-options-visible', columnOptions.hasClass('hide'));

			columnGrid.toggleClass('col-md-9').toggleClass('col-md-12');

			columnOptions.toggleClass('hide');

			if (columnTogglerIcon.hasClass('icon-caret-left') || columnTogglerIcon.hasClass('icon-caret-right')) {
				columnTogglerIcon.toggleClass('icon-caret-left').toggleClass('icon-caret-right');
			}

			if (columnTogglerIcon.hasClass('icon-caret-up') || columnTogglerIcon.hasClass('icon-caret-down')) {
				columnTogglerIcon.toggleClass('icon-caret-up').toggleClass('icon-caret-down');
			}
		}
	);
</aui:script>

<aui:script use="aui-base,aui-datatype,calendar">
	var DateMath = A.DataType.DateMath;

	window.<portlet:namespace />refreshMiniCalendarSelectedDates = function() {
		<portlet:namespace />miniCalendar._clearSelection();

		var activeView = <portlet:namespace />scheduler.get('activeView');
		var viewDate = <portlet:namespace />scheduler.get('viewDate');

		var viewName = activeView.get('name');

		var total = 1;

		if (viewName == 'month') {
			total = A.Date.daysInMonth(viewDate);
		}
		else if (viewName == 'week') {
			total = 7;
		}

		var selectedDates = Liferay.CalendarUtil.getDatesList(viewDate, total);

		<portlet:namespace />miniCalendar.selectDates(selectedDates);

		<portlet:namespace />miniCalendar.set('date', viewDate);
	};

	window.<portlet:namespace />refreshVisibleCalendarRenderingRules = function() {
		var miniCalendarStartDate = DateMath.subtract(DateMath.toMidnight(window.<portlet:namespace />miniCalendar.get('date')), DateMath.WEEK, 1);

		var miniCalendarEndDate = DateMath.add(DateMath.add(miniCalendarStartDate, DateMath.MONTH, 1), DateMath.WEEK, 1);

		miniCalendarEndDate.setHours(23, 59, 59, 999);

		Liferay.CalendarUtil.getCalendarRenderingRules(
			A.Object.keys(Liferay.CalendarUtil.visibleCalendars),
			Liferay.CalendarUtil.toUTC(miniCalendarStartDate),
			Liferay.CalendarUtil.toUTC(miniCalendarEndDate),
			'busy',
			function(rulesDefinition) {
				window.<portlet:namespace />miniCalendar.set(
					'customRenderer',
					{
						filterFunction: function(date, node, rules) {
							node.addClass('lfr-busy-day');

							var selectedDates = this._getSelectedDatesList();

							DateMath.toMidnight(date);

							var selected = (selectedDates.length > 0) && A.Date.isInRange(date, selectedDates[0], selectedDates[selectedDates.length - 1]);

							if (A.DataType.DateMath.isToday(date)) {
								node.addClass('lfr-current-day');
							}

							node.toggleClass('yui3-calendar-day-selected', selected);
						},
						rules: rulesDefinition
					}
				);
			}
		);
	};

	window.<portlet:namespace />miniCalendar = new A.Calendar(
		{
			after: {
				dateChange: <portlet:namespace />refreshVisibleCalendarRenderingRules,
				dateClick: function(event) {
					<portlet:namespace />scheduler.setAttrs(
						{
							activeView: <portlet:namespace />dayView,
							date: event.date
						}
					);
				}
			},
			date: new Date(<%= String.valueOf(date) %>),
			locale: 'en',
			'strings.first_weekday': <%= weekStartsOn %>
		}
	).render('#<portlet:namespace />miniCalendarContainer');

	<portlet:namespace />scheduler.after(
		['*:add', '*:change', '*:load', '*:remove', '*:reset'],
		A.debounce(<portlet:namespace />refreshVisibleCalendarRenderingRules, 100)
	);

	<portlet:namespace />scheduler.after(
		['activeViewChange', 'dateChange'],
		<portlet:namespace />refreshMiniCalendarSelectedDates
	);

	<portlet:namespace />refreshVisibleCalendarRenderingRules();
	<portlet:namespace />refreshMiniCalendarSelectedDates();

	<portlet:namespace />scheduler.load();
</aui:script>

<%!
protected void updateCalendarsJSONArray(HttpServletRequest request, JSONArray calendarsJSONArray) {
	for (int i = 0; i < calendarsJSONArray.length(); i++) {
		JSONObject jsonObject = calendarsJSONArray.getJSONObject(i);

		long calendarId = jsonObject.getLong("calendarId");

		jsonObject.put("color", GetterUtil.getString(SessionClicks.get(request, "calendar-portlet-calendar-" + calendarId + "-color", jsonObject.getString("color"))));
		jsonObject.put("visible", GetterUtil.getBoolean(SessionClicks.get(request, "calendar-portlet-calendar-" + calendarId + "-visible", "true")));
	}
}
%>