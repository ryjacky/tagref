console.log(document)
let port = null;
document.getElementById("btn").addEventListener('click', () => {
    port = chrome.runtime.connectNative('com.tagref.tagref');

    port.postMessage("https://pbs.twimg.com/media/FUvfh8BaIAA2aFK?format=jpg&name=900x900");

    port.onMessage.addListener((response) => {
        alert("Received: " + response);
      });
});

