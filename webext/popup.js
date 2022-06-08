console.log(document)
let port = null;
document.getElementById("btn").addEventListener('click', () => {
    port = chrome.runtime.connectNative('com.tagref.tagref');

    port.postMessage("https://www.biospace.com/article/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/2020-tailwinds-usher-in-a-post-pandemic-biotech-revolution-/");
});

