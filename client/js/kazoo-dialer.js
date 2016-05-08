var paramsInit = {
    forceRTMP: false,
    flashContainer: 'flash_div',
    onLoaded: function() {
        login();
    },
    onFlashMissing: function(container) {
        container.innerHTML = 'This content requires the Adobe Flash Player. <a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
        container.className = 'demo-flash-error';
    }
};
kazoo.init(paramsInit);
function login(){
    var kazooParams = {
        wsUrl: 'wss://fs01.teamofmonkeys.net:7443',
        rtmpUrl: 'rtmp://fs01.teamofmonkeys.net/sip',
        realm: 'fs01.teamofmonkeys.net',
        privateIdentity: '1000',
        publicIdentity: 'sip:1000@fs01.teamofmonkeys.net',
        password: '1234',
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
    console.log('Hangup');
}
function onCancel(status) {
    var msg = 'Your call has been canceled';
    if(status && status.message) { msg += ': ' + status.message; }
    if(status && status.code) { msg += ' (' + status.code + ')'; }
    console.log('info', msg);
    closePopup();
}
function onAccepted() {
}
function onConnected() {
}
function onNotified(notification) {
    switch(notification.key) {
        case 'replaced_registration': {
            if(document.getElementById('btnLogin').style.display === "none") { //Check to ignore double notifications
                logout();
                console.log('error', notification.message);
            }
            break;
        }
        case 'transfer_notification':
        case 'overriding_registration': {
            console.log('info', notification.message);
            break;
        }
        case 'connectivity_notification': {
            if(notification.status === 'offline') {
                console.log('warning', notification.message);
            } else {
                console.log('info', notification.message);
            }
            break;
        }
        case 'reconnecting_notification': {
            console.log('info', notification.message + '('+notification.attempt+')');
            break;
        }
        default: {
            console.log(notification.message);
        }
    }
}
function onError(error) {
    console.log('error', 'ERROR: ' + error.message);
    closePopup();
    if(error.key === 'disconnected') {
        console.log('Disconnected: ', error);
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
function logout() {
    kazoo.logout();
}
function sendDTMF(dtmf) {
    kazoo.sendDTMF(dtmf);
}
