
var SEQUENCE = 10001;
var HandBridge ={
    
postMessage:function(messageparams){
    
    SEQUENCE = SEQUENCE + 1;
    if(typeof messageparams == "string")    {
        messageparams = JSON.parse(messageparams);
    }
    
    var message;
    var className = null ;
    var nativeMethodName = null ;
    var params = null ;
    var callBack = null ;
    var callBackID = null ;
    var failBack = null;
    var failBackID = null;
    
    var timestamp1 = Date.parse( new Date());
    if(messageparams["className"]){
        className = messageparams["className"];
    }
    if(messageparams["function"]){
        nativeMethodName = messageparams["function"];
    }
    if(messageparams["params"]){
        params = messageparams["params"];
    }
    if(messageparams["successCallBack"]) {
        callBack = messageparams["successCallBack"];
        
        if(typeof callBack == "string"){
            
            callBack = window[callBack];
        }
    }
    if(callBack){
        callBackID = messageparams["className"] + messageparams["function"]+"successcallback"+timestamp1 + SEQUENCE;
    }
    
    if(messageparams["failCallBack"]){
        failBack = messageparams["failCallBack"];
        if(typeof failBack == "string"){
            failBack = window[failBack];
        }
    }
    
    if(failBack){
        failBackID = messageparams["className"] + messageparams["function"]+"failCallBack"+timestamp1 + SEQUENCE;
        
    }
    
    
    message = {'className':className,'methodName':nativeMethodName,'params':params,'callBackID':callBackID,'failBackID':failBackID};
    if(!HLYWEBEVENT._listeners[callBackID]){
        HLYWEBEVENT.addEvent(callBackID, function(data){
                             
                             callBack(data);
                             
                             });
    }
    if(!HLYWEBEVENT._listeners[failBackID]){
        HLYWEBEVENT.addEvent(failBackID, function(data){
                             
                             failBack(data);
                             
                             });
    }
    window.webkit.messageHandlers.HandBridge.postMessage(message);
    
},
    
callBack:function(callBackID,data){
    HLYWEBEVENT.fireEvent(callBackID,data);
},
    
removeAllCallBacks:function(data) {
    HLYWEBEVENT._listeners ={};
}
    
};


var HLYWEBEVENT = {
    
_listeners: {},
    
    
addEvent: function(type, fn) {
    if (typeof this._listeners[type] === "undefined") {
        this._listeners[type] = [];
    }
    if (typeof fn === "function") {
        this._listeners[type].push(fn);
    }
    
    return this;
},
    
    
fireEvent: function(type,param) {
    
    var arrayEvent = this._listeners[type];
    
    if (arrayEvent instanceof Array) {
        
        for (var i=0, length=arrayEvent.length; i<length; i+=1) {
            
            if (typeof arrayEvent[i] === "function") {
                arrayEvent[i](param);
            }
        }
    }
    
    return this;
},
    
removeEvent: function(type, fn) {
    var arrayEvent = this._listeners[type];
    if (typeof type === "string" && arrayEvent instanceof Array) {
        if (typeof fn === "function") {
            for (var i=0, length=arrayEvent.length; i<length; i+=1){
                if (arrayEvent[i] === fn){
                    this._listeners[type].splice(i, 1);
                    break;
                }
            }
        } else {
            delete this._listeners[type];
        }
    }
    
    return this;
}
};


