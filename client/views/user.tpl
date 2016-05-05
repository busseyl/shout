{{#if users.length}}
<div class="count">
	<input class="search" placeholder="{{users users.length}}">
</div>
{{/if}}
<div class="names">
	<div class="inner">
		{{#diff "reset"}}{{/diff}}
		{{#each users}}
			{{#diff mode}}
			{{#unless @first}}
				</div>
			{{/unless}}
			<div class="user-mode {{modes mode}}">
			{{/diff}}
			<button class="user" style="color: #{{stringcolor name}}">{{mode}}{{name}}</button>
		{{/each}}
		</div>
	</div>
	
	<div class="kazoo-dialer" id="kazoo-dialer">
		<div id="loginForm" class="demo-block" style="display: none;">
			<form>
				Private Identity: <input type="text" id="privateIdentity" value="user_sel656"><br>
				Public Identity: <input type="text" id="publicIdentity" value="sip:user_sel656@webdev.realm"><br>
				Password: <input type="text" id="password" value="adoe8aurmjex"><br>
				<!-- Private Identity: <input type="text" id="privateIdentity" value="user_9hgggnp4dp"><br>
				Public Identity: <input type="text" id="publicIdentity" value="sip:user_9hgggnp4dp@webdev.realm"><br>
				Password: <input type="text" id="password" value="3pgje9y2br9u"><br> -->
				<!-- Private Identity: <input type="text" id="privateIdentity" value="user_s6chaxxdu8"><br>
				Public Identity: <input type="text" id="publicIdentity" value="sip:user_s6chaxxdu8@webdev.realm"><br>
				Password: <input type="text" id="password" value="v8pcb2bg27hb"><br> -->
				Realm: <input type="text" id="realm" value="webdev.realm"><br>
				<button id="btnLogin" type="button" onClick="login()">Login</button>
				<button id="btnLogout" type="button" onClick="logout()" style="display: none;">Log out</button>
			</form>
		</div>

		<div id="divLoggedIn" class="demo-block" style="display: none;">
			Logged In
			<div>
				<input type="text" id="destination" placeholder="sip:2222@webdev.realm" value="sip:9009@webdev.realm"></input>
				<button id="call" onClick="call()">Call</button>
			</div>
		</div>

		<div id="divCalling" class="demo-block" style="display: none;">
			<h3>Call in progress...</h3>

			<button id="btnHangup" type="button" onClick="hangup()">Hangup</button>
			<button id="btnMute" type="button" onClick="mute()" data-state="unmuted">Mute</button>

			<div id="dialpad">
				<table>
					<tr>
						<td><input type="button" value="1" onClick="sendDTMF('1')"/></td>
						<td><input type="button" value="2" onClick="sendDTMF('2')"/></td>
						<td><input type="button" value="3" onClick="sendDTMF('3')"/></td>
					</tr>
					<tr>
						<td><input type="button" value="4" onClick="sendDTMF('4')"/></td>
						<td><input type="button" value="5" onClick="sendDTMF('5')"/></td>
						<td><input type="button" value="6" onClick="sendDTMF('6')"/></td>
					</tr>
					<tr>
						<td><input type="button" value="7" onClick="sendDTMF('7')"/></td>
						<td><input type="button" value="8" onClick="sendDTMF('8')"/></td>
						<td><input type="button" value="9" onClick="sendDTMF('9')"/></td>
					</tr>
					<tr>
						<td><input type="button" value="*" onClick="sendDTMF('*')"/></td>
						<td><input type="button" value="0" onClick="sendDTMF('0')"/></td>
						<td><input type="button" value="#" onClick="sendDTMF('#')"/></td>
					</tr>
				</table>
			</div>

			<div id="transferDiv">
				<input type="text" id="transferDestination" placeholder="sip:2222@webdev.realm"></input>
				<button id="transfer" onClick="transfer()">Transfer</button>
			</div>
		</div>

		<div id="toast" onClick="clearToast()" onMouseOver="clearTimeout(toastTimer)" onMouseOut="clearToast(3000)"></div>

		<div id="popupOverlay"></div>
		<div id="popup">
			<div id="popupHeader"></div>
			<div id="popupContent"></div>
			<div id="popupActions">
				<button id="popupOkBtn">OK</button>
				<button id="popupCancelBtn">Cancel</button>
			</div>
		</div>

		<div id="flash_div">
		</div>

		<script>
			var paramsInit = {
				forceRTMP: false,
				flashContainer: 'flash_div',
				onLoaded: function() {
					document.getElementById('loginForm').style.display = "block";
				},
				onFlashMissing: function(container) {
					container.innerHTML = 'This content requires the Adobe Flash Player. <a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
					container.className = 'demo-flash-error';
				}
			};
			kazoo.init(paramsInit);
			function login(){
				var kazooParams = {
					wsUrl: 'ws://10.26.0.41:8080',
					rtmpUrl: 'rtmp://10.26.0.41/sip',
					realm: document.getElementById('realm').value,
					privateIdentity: document.getElementById('privateIdentity').value,
					publicIdentity: document.getElementById('publicIdentity').value,
					password: document.getElementById('password').value,
					onAccepted: onAccepted,
					onConnected: onConnected,
					onHangup: onHangup,
					onCancel: onCancel,
					onIncoming: onIncoming,
					onConnecting: onConnecting,
					onTransfer: onTransfer,
					onNotified: onNotified,
					onError: onError,
					reconnectMaxAttempts: 3, // Unlimited autoreconnect attempts
					reconnectDelay: 5000 // New autoreconnect attempt every 5 seconds
				};
				kazoo.register(kazooParams);
			}
			function onTransfer() {
				document.getElementById('divCalling').style.display = "none";
			}
			function onIncoming(call) {
				console.log('onIncoming', call);
				var caller = call.callerName + (call.callerNumber ? ' ('+call.callerNumber+')' : '');
				confirmPopup(caller + ' is calling you! Pick up the call?', call.accept, call.reject);
			}
			function onConnecting() {
				console.log('Connecting...');
			}
			function onHangup() {
				document.getElementById('divCalling').style.display = "none";
			}
			function onCancel(status) {
				var msg = 'Your call has been canceled';
				if(status && status.message) { msg += ': ' + status.message; }
				if(status && status.code) { msg += ' (' + status.code + ')'; }
				toast('info', msg);
				closePopup();
			}
			function onAccepted() {
				document.getElementById('divCalling').style.display = "block";
			}
			function onConnected() {
				document.getElementById('divLoggedIn').style.display = "block";
				document.getElementById('btnLogin').style.display = "none";
				document.getElementById('btnLogout').style.display = "block";
			}
			function onNotified(notification) {
				switch(notification.key) {
					case 'replaced_registration': {
						if(document.getElementById('btnLogin').style.display === "none") { //Check to ignore double notifications
							logout();
							toast('error', notification.message);
						}
						break;
					}
					case 'transfer_notification':
					case 'overriding_registration': {
						toast('info', notification.message);
						break;
					}
					case 'connectivity_notification': {
						if(notification.status === 'offline') {
							toast('warning', notification.message);
						} else {
							toast('info', notification.message);
						}
						break;
					}
					case 'reconnecting_notification': {
						toast('info', notification.message + '('+notification.attempt+')');
						break;
					}
					default: {
						console.log(notification.message);
					}
				}
			}
			function onError(error) {
				toast('error', 'ERROR: ' + error.message);
				closePopup();
				if(error.key === 'disconnected') {
					document.getElementById('divLoggedIn').style.display = "none";
					document.getElementById('divCalling').style.display = "none";
					document.getElementById('btnLogin').style.display = "block";
					document.getElementById('btnLogout').style.display = "none";
				}
			}
			/* UI Binding */
			function transfer() {
				var destination = document.getElementById('transferDestination').value;
				kazoo.transfer(destination);
			};
			function call() {
				var destination = document.getElementById('destination').value;
				kazoo.connect(destination);
			}
			function hangup() {
				kazoo.hangup();
			}
			function mute(e) {
				var muteBtn = document.getElementById('btnMute');
				if(muteBtn.getAttribute('data-state') === 'unmuted') {
					kazoo.muteMicrophone(true, function() {
						muteBtn.setAttribute('data-state', 'muted');
						muteBtn.innerHTML = 'Unmute';
					});
				} else {
					kazoo.muteMicrophone(false, function() {
						muteBtn.setAttribute('data-state', 'unmuted');
						muteBtn.innerHTML = 'Mute';
					});
				}
			}
			function logout() {
				kazoo.logout();
				document.getElementById('divLoggedIn').style.display = "none";
				document.getElementById('divCalling').style.display = "none";
				document.getElementById('btnLogin').style.display = "block";
				document.getElementById('btnLogout').style.display = "none";
				closePopup();
			}
			function sendDTMF(dtmf) {
				kazoo.sendDTMF(dtmf);
			}
			var toastTimer;
			function toast(type, content, timer) {
				clearTimeout(toastTimer);
				var toast = document.getElementById('toast');
				toast.className = type;
				toast.innerHTML = content;
				toast.style.display = 'block';
				toastTimer = setTimeout(function() {
					toast.style.display = 'none';
				}, timer || 5000);
			}
			function clearToast(delay) {
				clearTimeout(toastTimer);
				toastTimer = setTimeout(function() {
					document.getElementById('toast').style.display = 'none';
				}, delay || 0);
			}
			function confirmPopup(message, okCallback, cancelCallback, type) {
				var popupHeader = document.getElementById('popupHeader');
				document.getElementById('popupContent').innerHTML = message || "Confirm?";
				document.getElementById('popupOverlay').style.display = 'block';
				document.getElementById('popup').style.display = 'block';
				popupHeader.className = type || 'info';
				popupHeader.innerHTML = 'Confirm';
				document.getElementById('popupOkBtn').onclick = function() {
					closePopup();
					okCallback && okCallback();
				};
				document.getElementById('popupCancelBtn').onclick = function() {
					closePopup();
					cancelCallback && cancelCallback();
				};
			}
			function closePopup() {
				document.getElementById('popupOverlay').style.display = 'none';
				document.getElementById('popup').style.display = 'none';
				document.getElementById('popupContent').innerHTML = '';
				document.getElementById('popupOkBtn').onclick = function() {};
				document.getElementById('popupCancelBtn').onclick = function() {};
			}
		</script>
	</div>
</div>
