try{
chrome.contextMenus.create({
    id: "1",
    title: "Add to TagRef",
    contexts: ["image"],
})
} catch (error) {
}


let port = null;
chrome.contextMenus.onClicked.addListener(function(info, tab) {
fetch("http://localhost:33728", {
  method: 'POST',
  body: "aWxvdmV0YWdyZWY" + info.srcUrl
})
})