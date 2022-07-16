console.log(document)
let port = null;
document.getElementById("btn").addEventListener('click', () => {
    let xhr = new XMLHttpRequest();
    xhr.open("POST", "http://localhost:33728");

    xhr.send("aWxvdmV0YWdyZWYhttps://stackoverflow.com/questions/247483/http-get-request-in-javascript");
});

