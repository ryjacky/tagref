// chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
//     if (request.action == "show") {
//         let port = null;
//         port = chrome.runtime.connectNative('com.tagref.tagref');

//         console.log(request.url);
//         port.postMessage(request.url);
//     }

// });

// port.onMessage.addListener((response) => {
//     alert("Received: " + response);
//   });

chrome.contextMenus.create({
    id: "1",
    title: "Test",
    contexts: ["image"],
})

let port = null;
chrome.contextMenus.onClicked.addListener(function(info, tab) {
    port = chrome.runtime.connectNative('com.tagref.tagref');

    port.postMessage(info.srcUrl);
})