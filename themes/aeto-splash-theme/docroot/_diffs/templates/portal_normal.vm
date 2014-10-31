//Globals
var isTablet = false,
isPhone = false,
lineWidths = 500,
resized = false,
width = 0,
height = 0;


AUI().ready(
	'liferay-hudcrumbs', 'liferay-navigation-interaction', 'liferay-sign-in-modal', 'liferay-dialog-window',
	function(A) {
		var navigation = A.one('#navigation'),
			rotation = -3,
			rotationRate = 0,
			loginKeyRate = null, 
			acceleration = 1.5,
			deceleration = .985,
			buttonNode = null,
			buttonHolderNode = null,
			borderNode = null,
			loginButtonSetter = null,
			formNodes = null,
			pwEntered = false,
			idEntered = false,
			loginVisible = false,
			origHeightBtn = -1;

		if (navigation) {
			navigation.plug(Liferay.NavigationInteraction);
		}

		var siteBreadcrumbs = A.one('#breadcrumbs');

		if (siteBreadcrumbs) {
			siteBreadcrumbs.plug(A.Hudcrumbs);
		}

		var loginNode = A.one('.item .five a');

		if (Liferay.ThemeDisplay.isSignedIn()) {
			loginNode.setHTML("LOGOUT");
		}
		else if (loginNode.getData('redirect') != 'true') {
			var percent = 0,
				circleMasks = null,
				canvasNode = A.one('.particle-content'),			
				crystalNode = A.one('.crystal-content'),
				modalZ = 0,
				signInOpen = false,
				signInNode = null,
				onceOpened = false,
				lockExpand = false,
				dotSteps = 1;

			var errorNode = A.one('.columns-max');

			if(errorNode) {
				if (errorNode.one('.alert-error')) {
					errorNode.remove();
					errorNode = A.Node.create("<div class='error-box-container'><div class='error-box'><div class='error-icon'></div><div class='error-message'>Sorry! We couldn't process your login information, are you sure you entered it correctly?</div></div></div>");
				
					setTimeout(function() {
						A.one('#wrapper').prepend(errorNode);

						errorNode = errorNode.one('.error-box');
						errorNode.on('hover', function() {
							errorNode.setStyle('opacity', 0)
							errorNode.setStyle('transform', 'scale(0)');
						})
					}, 1700);
				}
				else {
					errorNode.remove();
				}
			}

			loginNode.setAttribute('href', A.one('li.sign-in a').getAttribute('href'));
			loginNode.plug(Liferay.SignInModal);

			loginNode.on('click', function(e) {
				checkSignIn();
			});

			function checkSignIn() {
				if (A.one('#signinmodal') == null) setTimeout(checkSignIn, 100);
				else {
					signInOpen = true;

					if (!onceOpened) {
						onceOpened = true;
						signInNode = A.one('#signinmodal');

						A.one('#signinmodal .modal-content').prepend(A.Node.create('<div class="radial-progress"><div class="rotate-line"></div><div class="circle"><div class="mask full"><div class="fill"></div></div><div class="mask half"><div class="fill"></div><div class="fill fix"></div></div><div class="shadow"></div></div><div class="inset"></div></div>'));
						circleMasks = [A.one('.circle .mask.full'), A.one('.circle .fill'), A.all('.circle .fill').item(1), A.one('.fill.fix')];
						
						signInNode.one('.btn.close').on('click', checkCloseSignIn);
						A.one('.aui').on('key', checkCloseSignIn, 'esc');	
					}

					idEntered = false;
					pwEntered = false;		
					
					// Crystal + Canvas Overlay & Animation Setup
					crystalNode.addClass('notransition');
					crystalNode.setStyle('opacity', 0);
					canvasNode.addClass('notransition');
					canvasNode.setStyle('opacity', 0);
				
					setTimeout(function() {
						modalZ = parseInt(signInNode.getStyle('zIndex'));	

						crystalNode.removeClass('notransition');
						canvasNode.removeClass('notransition');

						canvasNode.setStyle('bottom', 0);
						canvasNode.setStyle('top', canvasNode.get('clientHeight') * -.85);
						canvasNode.setStyle('zIndex', modalZ + 5);
						crystalNode.setStyle('bottom', 0);
						crystalNode.setStyle('top', -210);
						crystalNode.setStyle('zIndex', modalZ + 4);

						setTimeout(function() {
							canvasNode.setStyle('opacity', '');
							crystalNode.setStyle('opacity', '');
						}, 400);	
					}, 100);

					// Accel/Decel Circle & Sign-In Button Animation
					requestAnimationFrame(loginRotation);

					setTimeout(function () {
						buttonHolderNode = A.one('#signinmodal .button-holder');
						buttonNode = buttonHolderNode.one('.btn');
						borderNode = A.one('.border-circle');
						formNodes = A.all('.sign-in-form .control-group .field');

						buttonHolderNode.on('hover', function() {
							idEntered = true;
							pwEntered = true;
							setLoginVisible();
						});

						formNodes.item(0).on('keypress', function() {idEntered = true;});
						formNodes.item(1).on('keypress', function() {pwEntered = true;});
						formNodes.item(0).on('keypress', rotationAccelerate);
						formNodes.item(1).on('keypress', rotationAccelerate);

						buttonNode.on('hover', rotateCircleMask, unrotateCircleMask);

						setLoginVisible();

						formNodes.item(0).on('keypress', setLoginVisible);
						formNodes.item(1).on('keypress', setLoginVisible);
						
						if (!isPhone) {downDots();}

						A.one('#signinmodal .control-group:first-of-type .field').setAttribute('placeholder', "Username");
						A.one('#signinmodal .control-group:last-of-type .field').setAttribute('placeholder', "Password");
					}, 200)
					
					percentIncrease();

					if (isPhone) {
						setTimeout(function() {
							buttonHolderNode = A.one('#signinmodal .button-holder');
							buttonNode = buttonHolderNode.one('.btn');
							idEntered = true;
							pwEntered = true;
							setLoginVisible();
						}, 200);
					}
				}
			}

			function downDots() {
				var distance = 25;

				if (!idEntered && !pwEntered && !loginVisible) {
					if (dotSteps == 1) {
						origHeightBtn = parseInt(buttonNode.getStyle('marginTop'));
						buttonHolderNode.addClass('before-set');
						dotSteps++;
					}
					
					setTimeout(function() {
						if (dotSteps == 2) {
							buttonNode.setStyle('marginTop', origHeightBtn + distance);
							buttonNode.setStyle('opacity', 0);
							dotSteps++;
						}

						setTimeout(function() {
							if (dotSteps == 3) {
								buttonHolderNode.addClass('after-set');
								dotSteps++;
							}
						}, 200)
					}, 200)

					setTimeout(function() {
						if (dotSteps == 4) {
							buttonNode.setStyle('marginTop', origHeightBtn - distance);
							buttonHolderNode.addClass('before-reset');
							buttonHolderNode.addClass('after-reset');
							dotSteps++;
						}
					}, 1000);
					
					setTimeout(upDots, 1500);
				}
			}

			function upDots() {
				var bottom = 25;


				if (signInOpen) {
					if (dotSteps == 5) {
						buttonHolderNode.removeClass('before-set');
						buttonHolderNode.removeClass('before-reset');
						dotSteps++;
					}
					setTimeout(function() {
						if (dotSteps == 6) {
							buttonNode.setStyle('marginTop', '');
							buttonNode.setStyle('opacity', '');
							dotSteps++;
						}

						setTimeout(function() {
							if (dotSteps == 7) {
								buttonHolderNode.removeClass('after-set');
								buttonHolderNode.removeClass('after-reset');
								dotSteps = 1;
							}
						}, 200)
					}, 200)
					
					setTimeout(function() {
						downDots();
					}, 2000);
				}
			}

			function setLoginVisible() {
				console.log("run");
				if ((idEntered && pwEntered) || loginVisible) {
					console.log("run?");
					buttonHolderNode = A.one('#signinmodal .button-holder');
					buttonNode = buttonHolderNode.one('.btn');

					loginVisible = true;
					buttonNode.setStyle('borderRadius', '0');
					buttonNode.setStyle('width', 80);
					buttonNode.setStyle('height', 20);
					buttonNode.setStyle('backfieldground', 'none');
					buttonNode.setStyle('marginLeft', -40);
					buttonNode.setStyle('fontSize', '20px');
					buttonNode.setStyle('top', 161);
					buttonNode.setStyle('background', 'none');
					buttonNode.setStyle('marginTop', '');
					buttonNode.setStyle('opacity', '');

					buttonHolderNode.addClass('login-before login-after');
					buttonHolderNode.removeClass('before-set');
					buttonHolderNode.removeClass('before-reset');
					buttonHolderNode.removeClass('after-set');
					buttonHolderNode.removeClass('after-reset');
				}		
			}

			function rotateCircleMask() {
				if (!isPhone) {
					circleMasks[0].setStyle('transform', 'rotate(180deg)');
					circleMasks[1].setStyle('transform', 'rotate(180deg)');
					circleMasks[2].setStyle('transform', 'rotate(180deg)');
					circleMasks[3].setStyle('transform', 'rotate(360deg)');

					setTimeout(function() {
						if (!lockExpand) {
							A.one('.radial-progress').setStyle('display', 'none');
							borderNode.setStyle('opacity', '1');

							//borderNode.setStyle('margin-top', -1 * parseInt(signInNode.getStyle('top')) + parseInt(A.one('.radial-progress').getStyle('height')) / 2 - 30 - width * .5);
							//borderNode.setStyle('margin-left', -1 * parseInt(signInNode.getStyle('left')) + parseInt(A.one('.radial-progress').getStyle('width')) / 2 - 30 - width * .25);
							borderNode.setStyle('height', width * 1.5);
							borderNode.setStyle('width', width * 1.5);
						}
					}, 500);
				}
			}

			function unrotateCircleMask() {
				if (!isPhone && ! lockExpand) {
					lockExpand = true;
					borderNode.setStyle('height', '');
					borderNode.setStyle('width', ''); 
					
					setTimeout(function() {
						A.one('.radial-progress').setStyle('display', '');
						borderNode.setStyle('opacity', '');
					}, 300);
			
					setTimeout(function() {
						A.one('.radial-progress').setStyle('display', '');
						circleMasks[0].setStyle('transform', '');
						circleMasks[1].setStyle('transform', '');
						circleMasks[2].setStyle('transform', '');
						circleMasks[3].setStyle('transform', '');

						lockExpand = false;
					}, 500);
				}
			}

			function rotationAccelerate() {
				if (rotationRate < .05) rotationRate = .1;
				else if (rotationRate < 500) rotationRate *= acceleration;
			}

			function loginRotation() {
				var rotateNode = A.one('#signinmodal .rotate-line');

				if (rotateNode) {
					if (rotationRate != 0) {				
						rotation += rotationRate;

						if (rotation >= 360) rotation = rotation % 360;
						rotateNode.setStyle('transform', 'rotate(' + rotation + 'deg)');

						rotationRate *= deceleration;
						//if (rotationRate < .01) rotationRate = 0;
					}
					requestAnimationFrame(loginRotation);	
				}
			}

			function checkCloseSignIn() {
				canvasNode.addClass('notransition');
				canvasNode.setStyle('opacity', 0);
				crystalNode.addClass('notransition');
				crystalNode.setStyle('opacity', 0);

				setTimeout(function() {
					crystalNode.removeClass('notransition');
					canvasNode.removeClass('notransition');
					canvasNode.setStyle('zIndex', '');
					crystalNode.setStyle('zIndex', '');

					setTimeout(function(){
						canvasNode.setStyle('bottom', '');
						canvasNode.setStyle('top', '');
						crystalNode.setStyle('bottom', '');
						crystalNode.setStyle('top', '');
						
						setTimeout(function() {
							crystalNode.setStyle('opacity', '');
							canvasNode.setStyle('opacity', '');
						}, 400)
					}, 200)
				}, 50)
				

				if(signInNode.hasClass('modal-hidden')) {
					signInOpen = false;
				}

				if(signInOpen == true) setTimeout(checkCloseSignIn, 200);
			}

			function percentIncrease() {
				percent = 100;

				if (percent < 100) setTimeout(percentIncrease, 200);
			}

			A.one('.nav-account-controls').remove();
		}

		//hover
		var topLineNode = A.one('.top-line');
		var bottomLineNode = A.one('.bottom-line');

	    function over() {
	    	if (!isTablet && !isPhone) {
	    		topLineNode.setStyle('width', 850); //needs to be calculated
		        bottomLineNode.setStyle('width', 850);
		        
		        A.one('.left-grad').setStyle('left', -180);
		        A.one('.right-grad').setStyle('right', -180);
		        A.one('.left-grad').setStyle('opacity', .3);
		        A.one('.right-grad').setStyle('opacity', .3);

		        A.one('.menu-items .item .one').setStyle('opacity', 1);
		        A.one('.menu-items .item .five').setStyle('opacity', 1);
	    	}
	    }

	    function out() {
	    	if (!isTablet && !isPhone) {
		        topLineNode.setStyle('width', 500);
		        bottomLineNode.setStyle('width', 500);

		        A.one('.left-grad').setStyle('left', '');
		        A.one('.right-grad').setStyle('right', '');
		        A.one('.left-grad').setStyle('opacity', '');
		        A.one('.right-grad').setStyle('opacity', '');

		        A.one('.menu-items .item .one').setStyle('opacity', 0);
		        A.one('.menu-items .item .five').setStyle('opacity', 0);
		    }
	    }
	   
	    A.one('.splash-menu').on('hover', over, out);
		//on 'scroll' delete bottom bar
	}
);

// Transition In

AUI().ready(
	function(A) {
		var node = A.one("body"),
			bodyNode = node,
			win = A.one(window),
			nodes = [];

		width = bodyNode.get("winWidth");
		height = bodyNode.get("winHeight");

		var diagonal = Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2)),
			containerNode = A.one('.transition-container'),
			angle = -90 + Math.atan(width / height) * (180 / Math.PI),
			nodeCt = 0,
			spaceCt = 0, //0-100% amount of screen space used
			minWidth = 2, //2
			maxWidth = 5, //5
			curWidth = 0,
			bgCss = "",
			menuItems = [A.one('.item .one'), A.one('.item .two'), A.one('.item .three'), A.one('.item .four'), A.one('.item .five')],
			topLineNode = A.one('.top-line'),
			bottomLineNode = A.one('.bottom-line'),
			nodesMaxLength = 0, //number of stripes at maximum generated by RNG
			nodesPercentAnimate = 0.01; //at what % of stripes to begin other animations

		win.on(
			['resize', 'load'],
			A.debounce(checkWidth, 100)
		);

		function checkWidth() {
			width = bodyNode.get("winWidth");
			height = bodyNode.get("winHeight");
			isTablet = (width <= 979);
			isPhone = (width <= 767);

			if (isPhone)
				A.one('.splash-menu-content').setStyle('top', 'calc(34% - -' + (40 + 130 * (width / 767)) + 'px)');
			else {
				A.one('.splash-menu-content').setStyle('top', 'calc(34% - -170px)');
			}

			if (isTablet || isPhone) {
				minWidth *= 4;
				maxWidth *= 4;
			}
		}

		win.on(
			['resize'],
			A.debounce(widthChanges, 100)
		);

		checkWidth();

		// Responsive Width
		function widthChanges() {
			resized = true;

			if (isTablet || isPhone) {
				menuItems[0].setStyle('opacity', 1);
	        	menuItems[4].setStyle('opacity', 1);
			}
			else {
				menuItems[0].setStyle('opacity', '');
	        	menuItems[4].setStyle('opacity', '');
			}

			setLineWidths();
		}

		function setLineWidths() {
			if (isTablet) {
				topLineNode.setStyle('width', lineWidths - 100);
        		bottomLineNode.setStyle('width', lineWidths - 100);
			}
			if (isPhone) {
        		topLineNode.setStyle('width', width * .6);
        		bottomLineNode.setStyle('width', width * .6);
        	}
        	else {
        		topLineNode.setStyle('width', lineWidths);
        		bottomLineNode.setStyle('width', lineWidths);
        	}
		}

		// =================

		containerNode.setStyle('-webkit-transform', "rotate(" + angle + "deg)");
		containerNode.setStyle('-moz-transform', "rotate(" + angle + "deg)");
		containerNode.setStyle('-ms-transform', "rotate(" + angle + "deg)");	
		containerNode.setStyle('-o-transform', "rotate(" + angle + "deg)");
		containerNode.setStyle('transform', "rotate(" + angle + "deg)");
		containerNode.setStyle('height', diagonal);
		containerNode.setStyle('marginBottom', width * -0.5 + "px");
		containerNode.setStyle('marginLeft', height * 0.5 + "px");		

		while (spaceCt < 100) {
			curWidth =  Math.random() * (maxWidth - minWidth) + minWidth;
			if (curWidth + spaceCt > 100) curWidth = 100 - spaceCt;
			spaceCt += curWidth;

			nodes.push(A.Node.create("<div class='transition-stripe'></div>"));
			nodes[nodeCt].setStyle('width', diagonal * 2);
			nodes[nodeCt].setStyle('height', curWidth + "%");
			nodes[nodeCt].setStyle('marginLeft', diagonal * -1 + "px");
			//node.setStyle('margin-left', diagonal);	
			//nodes[nodeCt].setStyle('background-color', "rgb(" + Math.round(Math.random() * 255) + ", 0 , 0)");
			containerNode.append(nodes[nodeCt]);

			var randColor = Math.round(Math.random() * 360);

			if (bgCss == "") {
				bgCss = nodes[nodeCt].getStyle('backgroundImage');
				bgCss = bgCss.substr(0, bgCss.indexOf('('));
			}

			if(bgCss != "-webkit-gradient") {
				nodes[nodeCt].setStyle("backgroundImage", bgCss + "(left, hsla(" + randColor + ", 67%, 36%, 0) 0%, hsla(" + randColor + ", 35%, 75%, 1) 32%, #ffffff 54%)");
			}
			else {
				nodes[nodeCt].setStyle("backgroundImage", bgCss + "(linear, 0% 50%, 100% 50%, color-stop(0%, hsla(" + randColor + ", 67%, 36%, 0)), color-stop(32%, hsla(" + randColor + ", 35%, 75%, 1)), color-stop(54%, #ffffff)");
			}
		
			nodeCt++;
		}

		A.one('.loadpaper').remove();
		nodesMaxLength = nodes.length;

		function transitionComplete(){
			containerNode.remove();
		}

		function wipeStripe() {
			if (nodes.length > 0) {
				var idx = Math.round(Math.random() * (nodes.length - 1));

				nodes[idx].setStyle('marginLeft', diagonal * 2 + "px");
				nodes.splice(idx, 1);
			} 
			else {
				clearInterval(stripeWiper);
				setTimeout(transitionComplete, 1700);
				secondaryAnimations();
			}
		}

		function secondaryAnimations() {
			setTimeout(function() {
				A.one('.aeto-logo').setStyle('opacity', 1);

				setTimeout(function() {
					setLineWidths();

					topLineNode.setStyle('opacity', 1);
					bottomLineNode.setStyle('opacity', 0.8);

					setTimeout(function() {
						topLineNode.setStyle('transitionDuration', "0.45s");
						bottomLineNode.setStyle('transitionDuration', "0.45s");

						menuItems[1].setStyle('opacity', 1);
						menuItems[1].setStyle('top', 0);

						setTimeout(function() {
							menuItems[2].setStyle('opacity', 1);
							menuItems[2].setStyle('top', 0);

							setTimeout(function() {
								menuItems[3].setStyle('opacity', 1);
								menuItems[3].setStyle('top', 0);

								setTimeout(function() {
									
									menuItems[0].setStyle('left', 0);
									
									menuItems[4].setStyle('right', 0);

									if (isTablet || isPhone) {
										menuItems[0].setStyle('opacity', 1);
										menuItems[4].setStyle('opacity', 1);
									}
								}
								, 200);
							}
							, 200);
						}
						, 200);
					}
					, 850);
				}
				, 400);
			}
			, 850);

		}

		var stripeWiper = setInterval(wipeStripe, 50);
	}
);

// Hover event

// SFX

AUI().ready(
	function(A) {
		// ====================== Crystal Color Cycling ======================
		var idx = 0;
		var colorCycle = [
			"rgba(255, 0, 0,",
			"rgba(0, 230, 0,",
			"rgba(0, 0, 255,",
		];

		myTimer();
		setInterval(myTimer, 3000);

		function myTimer() {
			if(idx > colorCycle.length) idx = 0;
			A.one('.aeto-crystal ').setStyle('backgroundColor', colorCycle[idx] + " 0.8)");
			if (A.one('.radial-progress ')) A.one('.radial-progress ').setStyle('backgroundColor', colorCycle[idx] + " 0.8)");
			if (isPhone && A.one('#signinmodal')) A.one('#signinmodal').setStyle('boxShadow', '0px -10px 0px 1px ' + colorCycle[idx] + " 0.4)");
			else if (A.one('#signinmodal')) A.one('#signinmodal').setStyle('boxShadow', '');
			idx++;
		}

		// ====================== Particle Generation ======================

		var maxParticles = 70,
		particleSize = 2,
		emissionRate = 0.10,
		emissionCount = 1,
		emissionPermit = 0,
		objectSize = 2,
		fadeTime = 100, // drawSize of emitter/field
		blankTime = 80, //0
		fadeIn = 100, //0
		fadeStill = 20, //200
		maxOpacity = .400, //1
		colorCt = 0,
		colorSpd = .3
		activeEmitter = 0;

		var canvas = document.querySelector('canvas');
		var ctx = canvas.getContext('2d');

		canvas.width = A.one('canvas').get('clientWidth');
		canvas.height = A.one('canvas').get('clientHeight');

		function Particle(point, velocity, acceleration) {
			this.position = point || new Vector(0, 0);
			this.velocity = velocity || new Vector(0, 0);
			this.acceleration = acceleration || new Vector(0, 0);
			this.fadeProgress = 0;
		}

		Particle.prototype.submitToFields = function (fields) {
			// our starting acceleration this frame
			var totalAccelerationX = 0;
			var totalAccelerationY = 0;

			// for each passed field
			for (var i = 0; i < fields.length; i++) {
				var field = fields[i];

				// find the distance between the particle and the field
				var vectorX = field.position.x - this.position.x;
				var vectorY = field.position.y - this.position.y;

				// calculate the force via MAGIC and HIGH SCHOOL SCIENCE!
				var force = field.mass / Math.pow(vectorX*vectorX+vectorY*vectorY,1.5);

				// add to the total acceleration the force adjusted by distance
				totalAccelerationX += vectorX * force;
				totalAccelerationY += vectorY * force;
			}

			// update our particle's acceleration
			this.acceleration = new Vector(totalAccelerationX, totalAccelerationY);
		};

		Particle.prototype.move = function () {
			this.velocity.add(this.acceleration);
			this.position.add(this.velocity);
		};

		function Field(point, mass) {
			this.position = point;
			this.setMass(mass);
		}

		Field.prototype.setMass = function(mass) {
			this.mass = mass || 100;
			this.drawColor = mass < 0 ? "#f00" : "#0f0";
		}

		function Vector(x, y) {
			this.x = x || 0;
			this.y = y || 0;
		}

		Vector.prototype.add = function(vector) {
			this.x += vector.x;
			this.y += vector.y;
		}

		Vector.prototype.getMagnitude = function () {
			return Math.sqrt(this.x * this.x + this.y * this.y);
		};

		Vector.prototype.getAngle = function () {
			return Math.atan2(this.y,this.x);
		};

		Vector.fromAngle = function (angle, magnitude) {
			return new Vector(magnitude * Math.cos(angle), magnitude * Math.sin(angle));
		};

		function Emitter(point, velocity, spread) {
			this.position = point; // Vector
			this.velocity = velocity; // Vector
			this.spread = spread || Math.PI / 32; // possible angles = velocity +/- spread
			this.drawColor = "#999"; // So we can tell them apart from Fields later
		}

		Emitter.prototype.emitParticle = function() {
			// Use an angle randomized over the spread so we have more of a "spray"
			var angle = this.velocity.getAngle() + this.spread - (Math.random() * this.spread * 2);
			var magnitude = this.velocity.getMagnitude();
			var position = new Vector(this.position.x, this.position.y);
			var velocity = Vector.fromAngle(angle, magnitude);

			return new Particle(position,velocity);
		};

		function addNewParticles() {
			// stop emitting at max
			if (particles.length > maxParticles) return;


			emissionPermit += emissionRate;

			//console.log(Math.round(Math.random() * (emitters.length - 1)));
			if (emissionPermit >= 1.0) {
				for (var i = 0; i < emissionCount; i++) {
					particles.push(emitters[activeEmitter].emitParticle());
				}
				emissionPermit = 0;
			}
		}

		function plotParticles(boundsX, boundsY) {
			// a new array to hold particles within our bounds
			var currentParticles = [];

			for (var i = 0; i < particles.length; i++) {
				var particle = particles[i];
				var pos = particle.position;

				// If we're out of bounds, drop this particle and move on to the next
				if (pos.x < 0 || pos.x > boundsX || pos.y < 0 || pos.y > boundsY || i > maxParticles) continue;

				// Update velocities and accelerations to account for the fields
				particle.submitToFields(fields);
				particle.move();
				currentParticles.push(particle);
			}

			// Update our global particles reference
			particles = currentParticles;
		}

		function drawParticles() {
			colorCt += colorSpd; 
				if (colorCt > 360) {
					colorCt = 0;
				}
			
			for (var i = 0; i < particles.length; i++) {
				if (particles[i].fadeProgress < blankTime + fadeIn + fadeStill + fadeTime) {
					particles[i].fadeProgress += 1;
				}

				

				if (particles[i].fadeProgress > blankTime) {
					if (particles[i].fadeProgress < fadeIn + blankTime) {
						ctx.fillStyle = 'hsla(' + colorCt + ', 80%, 60%, ' + (particles[i].fadeProgress - blankTime) / fadeIn * maxOpacity + ')';
					}
					else if (particles[i].fadeProgress < fadeIn + fadeStill + blankTime) {
						ctx.fillStyle = 'hsla(' + colorCt + ', 80%, 60%, ' + maxOpacity + ')';
					}
					else {
						ctx.fillStyle = 'hsla(' + colorCt + ', 80%, 60%, ' + (fadeTime - (particles[i].fadeProgress - fadeIn - fadeStill - blankTime)) / fadeTime * maxOpacity + ')';
					}

					var position = particles[i].position;

					ctx.beginPath();
					ctx.arc(position.x, position.y, particleSize, 0, Math.PI * 2);
					ctx.closePath();
					ctx.fill();
					ctx.shadowColor = 'hsla(' + colorCt + ', 80%, 75%,  1)';
				    ctx.shadowBlur = 4;
				    ctx.shadowOffsetX = 0;
				    ctx.shadowOffsetY = 0;
				}
			}
		}

		function drawCircle(object) {
			ctx.fillStyle = object.drawColor;
			ctx.beginPath();
			ctx.arc(object.position.x, object.position.y, objectSize, 0, Math.PI * 2);
			ctx.closePath();
			ctx.fill();
		}
		 
		var particles = []; 

		var midX = canvas.width / 2;
		var midY = canvas.height / 2; 

		var emitters = [
			//new Emitter(new Vector(midX, midY), Vector.fromAngle(-2.5, 2.5))
			new Emitter(new Vector(midX, canvas.height - 50), Vector.fromAngle(20.42, 1)),
			new Emitter(new Vector(midX + 45, canvas.height - 190), Vector.fromAngle(100, 4))
		];

		var fields = [
			new Field(new Vector(midX, canvas.height - 20), -8),
			new Field(new Vector(midX, 0), 0)
		];

		function loop() {
			clear();
			update();
			draw();
			queue();
		}

		function clear() {
			ctx.clearRect(0, 0, canvas.width, canvas.height);
		}

		function update() {
			addNewParticles();
			plotParticles(canvas.width, canvas.height);
		}

		function draw() {
			drawParticles();
			//fields.forEach(drawCircle);
			//emitters.forEach(drawCircle);
		}

		function queue() {
			window.requestAnimationFrame(loop);
		}

		loop();

		function getMousePos(canvas, evt) {
			var rect = canvas.getBoundingClientRect();
			return {
				x: evt.clientX - rect.left,
				y: evt.clientY - rect.top
			};
		}

		canvas.addEventListener('mousemove', function(evt) {
			var mousePos = getMousePos(canvas, evt);
			var message = 'Mouse position: ' + mousePos.x + ',' + mousePos.y;
			fields[1].position.x = mousePos.x ;
			fields[1].position.y = mousePos.y ;
		}, false);

		canvas.addEventListener('mouseover', function(evt) {
			fields[1].setMass(400);
		}, true);

		canvas.addEventListener('mouseout', function(evt) {
			fields[1].setMass(0);
			fields[1].position.x = canvas.width / 2;;
			fields[1].position.y = 0;
		}, true);

		var maxParticlesO = maxParticles;
		var emissionRateO = emissionRate;
		var blankTimeO = blankTime;
		var emissionCountO = emissionCount;
		var activeEmitterO = activeEmitter;

		function overItem () {
			maxParticles = 300;
			emissionRate = 1.60;
			blankTime = 0;
			emissionCount = 4;
			activeEmitter = 1;
			fields.push(new Field(new Vector(midX - 80, canvas.height - 100), 6000));
			fields.push(new Field(new Vector(midX + 20, canvas.height - 100), 1000));
		}

		function offItem () {
			maxParticles = maxParticlesO;
			emissionRate = emissionRateO;
			blankTime = blankTimeO;
			emissionCount = emissionCountO;
			activeEmitter = activeEmitterO;
			fields.splice(2, 2);
		}

		A.all(".item").each(
			function(thisNode) {
				thisNode.on("hover", overItem, offItem);
			}
		);
	}
);


AUI().ready(
	'aui-popover',
	'widget-anim',
	function(A) {
		var menuItems = A.all('.splash-menu .menu-items .item');
		var defaultVisible = false;

		var pop1 = new A.Popover({
			align: {
				node: menuItems.item(0),
				points:[A.WidgetPositionAlign.TL, A.WidgetPositionAlign.BL]
			},
			headerContent: 'Not yet availabe.',
			plugins: [A.Plugin.WidgetAnim],
			position: 'bottom',
			visible: defaultVisible
		}).render();

		var pop2 = new A.Popover({
			align: {
				node: menuItems.item(1),
				points:[A.WidgetPositionAlign.TL, A.WidgetPositionAlign.BL]
			},
			headerContent: 'Not yet availabe.',
			plugins: [A.Plugin.WidgetAnim],
			position: 'bottom',
			visible: defaultVisible
		}).render();

		var pop3 = new A.Popover({
			align: {
				node: menuItems.item(2),
				points:[A.WidgetPositionAlign.TL, A.WidgetPositionAlign.BL]
			},
			headerContent: 'Not yet availabe.',
			plugins: [A.Plugin.WidgetAnim],
			position: 'bottom',
			visible: defaultVisible
		}).render();

		var pop4 = new A.Popover({
			align: {
				node: menuItems.item(3),
				points:[A.WidgetPositionAlign.TL, A.WidgetPositionAlign.BL]
			},
			headerContent: 'Not yet availabe.',
			plugins: [A.Plugin.WidgetAnim],
			position: 'bottom',
			visible: defaultVisible
		}).render();

		menuItems.item(0).on(
			'hover',
			function() {
				pop1.set('visible', !pop1.get('visible'));
			},
			function() {
				pop1.set('visible', !pop1.get('visible'));
			}
		);

		menuItems.item(1).on(
			'hover',
			function() {
				pop2.set('visible', !pop2.get('visible'));
			},
			function() {
				pop2.set('visible', !pop2.get('visible'));
			}
		);

		menuItems.item(2).on(
			'hover',
			function() {
				pop3.set('visible', !pop3.get('visible'));
			},
			function() {
				pop3.set('visible', !pop3.get('visible'));
			}
		);

		menuItems.item(3).on(
			'hover',
			function() {
				pop4.set('visible', !pop4.get('visible'));
			},
			function() {
				pop4.set('visible', !pop4.get('visible'));
			}
		);

	}
);