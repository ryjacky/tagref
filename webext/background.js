chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
    if (request.action == "show") {
        let port = null;
        port = chrome.runtime.connectNative('com.tagref.tagref');

        port.postMessage(request.url);
    }

});