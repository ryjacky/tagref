var observer = new MutationObserver(updateImgEle);
observer.observe(document, { attributes: false, childList: true, characterData: false, subtree: true });

function updateImgEle() {
    observer.disconnect();
    var allImg = document.getElementsByTagName("img")

    for (let element of allImg) {
        if (element.parentNode.id == "tagrefContainer") {
            continue;
        }
        if (element.width > 150 && element.height > 150) {
            var parent = element.parentNode;
            var wrapper = document.createElement('div');
            wrapper.id = "tagrefContainer";

            // set the wrapper as child (instead of the element)
            parent.replaceChild(wrapper, element);
            // set element as child of wrapper

            var addTRBtn = document.createElement('button');
            addTRBtn.addEventListener('click', () => {
                chrome.runtime.sendMessage({
                    action: "show",
                    url: element.src
                });
            });
            addTRBtn.textContent = 'Add to TagRef';
            wrapper.appendChild(addTRBtn);
            wrapper.appendChild(element);
        }
    }
    setTimeout(() => {
        observer.observe(document, { attributes: false, childList: true, characterData: false, subtree: true });
    }, 1000);
}