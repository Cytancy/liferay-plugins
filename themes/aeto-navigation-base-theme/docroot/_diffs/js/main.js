AUI().ready(
	'liferay-hudcrumbs', 'liferay-navigation-interaction', 'liferay-sign-in-modal',
	function(A) {
		var navigation = A.one('#navigation');

		if (navigation) {
			navigation.plug(Liferay.NavigationInteraction);
		}

		var siteBreadcrumbs = A.one('#breadcrumbs');

		if (siteBreadcrumbs) {
			siteBreadcrumbs.plug(A.Hudcrumbs);
		}

		var signIn = A.one('li.sign-in a');

		if (signIn && signIn.getData('redirect') !== 'true') {
			signIn.plug(Liferay.SignInModal);
		}

		var loginNode = A.one('.login-frontside');

		if (!Liferay.ThemeDisplay.isSignedIn() && loginNode.getData('redirect') != 'true') {
			loginNode.setAttribute('href', A.one('li.sign-in a').getAttribute('href'));
			loginNode.plug(Liferay.SignInModal);
		}
	}
);


AUI().ready(
	'liferay-sign-in-modal',
	function(A) {
		var menuItems = A.all('.aeto-pages .lfr-nav-item');
			leftHoverBar = A.one('.aeto-hover-bar-container .left-hover-bar-container'),
			rightHoverBar = A.one('.aeto-hover-bar-container .right-hover-bar-container'),
			hoverMarginOffset = 10,
			bodyNode = A.one('body'),
			win = A.one(window),
			width = parseInt(bodyNode.get("winWidth")),
			height = parseInt(bodyNode.get("winHeight")),
			crystalNode = A.one('.aeto-bar .logo-icon'), //colorswapped
			colorArrowNode = A.one('.aeto-bar .aeto-logo-container .color-arrow'),
			hoverBarNodes = A.all('.aeto-hover-bar-container .inner-bar'),
			hoverArrowNodes = A.all('.aeto-hover-bar-container .color-arrow'),
			colorCounter = 0,
			loginContainerNode = A.one('.aeto-login-container');
			loginNode = loginContainerNode.one('.login-frontside'),
			loginContentNode = loginContainerNode.one('.login-content'),
			loginOpen = false,
			logoBoxNode = A.one('.aeto-bar .logo-box'),
			mainArrowNode = A.one('.aeto-bar .main-arrow'),
			mainWhiteArrowNode = A.one('.aeto-bar .white-arrow'),
			mainColorArrowNode = A.one('.aeto-bar .color-arrow'),
			mainShadowArrowNode = A.one('.aeto-bar .background-arrow'),
			arrowWidth = parseInt(A.one('.menu-arrow-edge .main-arrow').getStyle('borderLeftWidth')),
			firstRun = true;

		win.on(
			'resize',
			A.debounce(function() {
				width = parseInt(bodyNode.get("winWidth"));
				height = parseInt(bodyNode.get("winHeight"));
			}, 100)
		);

		// Color Swap System
		function colorSwap() {
			var lightness = 40;
			var maxLightness = 80;

			if (colorCounter < 62)
				lightness = maxLightness - colorCounter/62 * (maxLightness - lightness);
			else if (colorCounter > 175)
				lightness += (colorCounter - 175)/185 * maxLightness;

			if (lightness > maxLightness) lightness = maxLightness;

			var hslaVal = 'hsla(' + colorCounter + ', 100%, ' + lightness + '%, 0.9)';
			
			crystalNode.setStyle('background', hslaVal);
			colorArrowNode.setStyle('borderLeftColor', 'hsla(' + colorCounter + ', 100%, ' + lightness + '%, 0.45)');

			hoverArrowNodes.item(0).setStyle('borderLeftColor', hslaVal);
			hoverArrowNodes.item(1).setStyle('borderRightColor', hslaVal);
			hoverBarNodes.item(0).setStyle('backgroundColor', hslaVal);
			hoverBarNodes.item(1).setStyle('backgroundColor', hslaVal);

			colorCounter++;

			if(colorCounter > 360) colorCounter = 1;

			setTimeout(colorSwap, 80);
		}

		setTimeout(function() {
			colorSwap();
			menuItems.each(
				function(thisNode) {
					thisNode.on('hover', function() {
						leftHoverBar.setStyle('left',  parseInt(thisNode.getComputedStyle("width")) - width + hoverMarginOffset - parseInt(thisNode.one('a').getComputedStyle("width")));
						rightHoverBar.setStyle('right', -1 * parseInt(thisNode.getComputedStyle("width")) + hoverMarginOffset);
						thisNode.one('.background-arrow').setStyle('opacity', 0);
					},
					function () {
						thisNode.one('.background-arrow').setStyle('opacity', '');
						leftHoverBar.setStyle('left', '');
						rightHoverBar.setStyle('right', '');
					})
				}
			);
		}, 800);

		// Login System

		function loginHoverOn() {
			if (!loginOpen) {
				loginContainerNode.setStyle('marginLeft', -25);

				loginContainerNode.one('.background-arrow').setStyle('borderRightWidth', 40);
			}
		}

		function loginHoverOff() {
			if (!loginOpen) {
				loginContainerNode.setStyle('marginLeft', 0);

				loginContainerNode.one('.background-arrow').setStyle('borderRightWidth', '');
			}
		}

		loginNode.on('hover', loginHoverOn, loginHoverOff);
		loginNode.on('click', function() {
			checkSignIn();
		});

		function checkSignIn() {
			var signInNode = A.one('#signinmodal');
			if (signInNode == null) setTimeout(checkSignIn, 100);
			else {
				var logoNodeWidth = (parseInt(logoBoxNode.getStyle('width')) * -1);

				if (firstRun) {
					A.one('#signinmodal .control-group:first-of-type .field').setAttribute('placeholder', "Username");
					A.one('#signinmodal .control-group:last-of-type .field').setAttribute('placeholder', "Password");

					signInNode.set('className', '');
					loginContainerNode.append(signInNode.one('.modal-content'));
					
					loginNode.setAttribute('href', 'javaScript:void(0);');
					loginNode.detach();
					loginNode.on('click', function() {checkSignIn();});
					loginNode.on('hover', loginHoverOn, loginHoverOff);

					firstRun = false;
				}
				
				loginOpen = true;

				loginContentNode.addClass('reverse-double-arrows');

				loginContainerNode.setStyle('marginLeft', 'calc(' + (parseInt(loginNode.getStyle('width')) - 1) + 'px - 100%)');
				
				setTimeout(function() {
					logoBoxNode.setStyle('left', logoNodeWidth);
					mainArrowNode.setStyle('left', logoNodeWidth - arrowWidth - 5);

					setTimeout(function() {
						mainWhiteArrowNode.setStyle('left', logoNodeWidth - arrowWidth - 30);

						setTimeout(function() {
							mainColorArrowNode.setStyle('left', -120);

							setTimeout(function() {
								mainShadowArrowNode.setStyle('left', -120);
							}, 150);
						}, 150);
					}, 200);
				}, 100);
				

				loginContainerNode.one('.checkbox').on('click', function() {
					loginOpen = false;
					loginContentNode.removeClass('reverse-double-arrows');

					loginContainerNode.setStyle('marginLeft', '');

					setTimeout(function() {
						mainShadowArrowNode.setStyle('left', '');

						setTimeout(function() {
							mainColorArrowNode.setStyle('left', '');

							setTimeout(function() {
								mainWhiteArrowNode.setStyle('left', '');

								setTimeout(function() {
									logoBoxNode.setStyle('left', '');
									mainArrowNode.setStyle('left', '');
								}, 200);
							}, 200);
						}, 100);
					}, 100);
				});

				// -120
				//console.log();
			}
		}
	}
);
