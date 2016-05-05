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
        wsUrl: 'wss://'+document.getElementById('proxy').value+':8443',
        rtmpUrl: 'rtmp://'+document.getElementById('proxy').value+'/sip',
        realm: document.getElementById('realm').value,
        privateIdentity: document.getElementById('privateIdentity').value,
        publicIdentity: 'sip:'+document.getElementById('privateIdentity').value+'@'+document.getElementById('realm').value,
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