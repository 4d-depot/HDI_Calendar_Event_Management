document.addEventListener("DOMContentLoaded", function() {
    const urlwss="ws://127.0.0.1:8080/";
    const loginBtn=document.querySelector('#login');
    let ws;
    function WSinit(){
        if (ws){
            ws.close();
        }
        ws = new WebSocket(urlwss);
        ws.addEventListener('message',function message({data}){
            response=JSON.parse(data)
            switch(response.type){
                case "connectionStarted":
                    console.log(response.type);
                    ws.send(JSON.stringify({type: "redirectURI"}));
                    break;
                case "redirectURI":
                    console.log(response.type+": "+response.data);
                    ws.send(JSON.stringify({type: "getLabels"}));
                    window.open(response.data,"_blank","popup,width=500,heigh=600");
                    break;
                case "getLabels":
                    console.log(response.type+": ",response.data);
                    displaylabels(response.data);
                    break;
                
                case "getMails":
                    console.log(response.type+": ",response.data);
                    displayEmails(response.data);
                    break;

                case "getToken":
                    console.log(response.type+": ",response.data);
                    break;
                default:
                    console.log(response.type+": ",response.data);
            }
        }); 
        ws.addEventListener('close',function close(arg){
            console.log("Websocket closed",arg );
            ws=null;
        });
        loginBtn.onclick=function(){
            ws.send(JSON.stringify({type: "redirectURI"}));
        }
    }


    WSinit();

// Function to fill the sidebar with labels
function displaylabels(labels) {
    const sidebar = document.getElementById('sidebar');
    sidebar.innerHTML="";
    for (const [key, value] of Object.entries(labels)) {
        const folderElement = document.createElement('div');
        const folderId = value.Id;
        folderElement.classList.add('folder');
        folderElement.textContent = key;
        folderElement.addEventListener("click", createFolderClickHandler(folderId));
        sidebar.appendChild(folderElement);
    }
}

// Gestionnaire d'événements pour les clics sur les dossiers
function createFolderClickHandler(id) {
    return function(event) {
        const selectedFolder = document.querySelector('.folder.selected');
        if (selectedFolder) {
            selectedFolder.classList.remove('selected');
        }
        event.currentTarget.classList.add('selected');
         ws.send(JSON.stringify({type: "getMails", data: id}));
    };
}
// Afficher la liste des courriels
function displayEmails(mails) {
    const mailList = document.getElementById('mailList');
    mailList.innerHTML = ""; // Effacer la liste existante

    mails.forEach(mail => {
        if (mail.from!==undefined){
            const mailElement = document.createElement('div');
            mailElement.classList.add('mail');
            const titleElement = document.createElement('div');
            titleElement.classList.add('mail-title');
            titleElement.textContent = mail.subject;
            const senderElement = document.createElement('div');
            senderElement.classList.add('mail-sender');
            senderElement.textContent = mail.from.email;
            const contentElement = document.createElement('div');
            contentElement.classList.add('mail-content');
            contentElement.textContent = mail.preview;
            mailElement.appendChild(titleElement);
            mailElement.appendChild(senderElement);
            mailElement.appendChild(contentElement);
            mailList.appendChild(mailElement);
        }
    });
}
// Fonction pour remplir la liste de mails
function fillMailList() {
    const mailList = document.getElementById('mailList');
    mails.forEach(mail => {
        if (mail.hasAttribute("from")){
            const mailElement = document.createElement('div');
            mailElement.classList.add('mail');
            const titleElement = document.createElement('div');
            titleElement.classList.add('mail-title');
            titleElement.textContent = mail.title;
            const senderElement = document.createElement('div');
            senderElement.classList.add('mail-sender');
            senderElement.textContent = mail.sender;
            const contentElement = document.createElement('div');
            contentElement.classList.add('mail-content');
            contentElement.textContent = mail.content;
            mailElement.appendChild(titleElement);
            mailElement.appendChild(senderElement);
            mailElement.appendChild(contentElement);
            mailList.appendChild(mailElement);
        }
    });
}

});