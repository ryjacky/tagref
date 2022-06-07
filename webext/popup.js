let port = null;
document.getElementById("btn").addEventListener('click', () => {
    port = chrome.runtime.connectNative('com.tagref.tagref');
});