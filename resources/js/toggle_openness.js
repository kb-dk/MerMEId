var openness = new Array();

function toggle(id) {
    var img  = document.getElementById("img" + id);
    var para = document.getElementById("p"   + id);
    if(id in openness && openness[id]) {
	para.title = "Click to open";
	img.alt = "+";
	img.src = "../resources/images/plus.png";
	hide(id);
	openness[id] = false;
    } else if(id in openness && !openness[id]) {
	para.title = "Click to close";
	img.alt = "-";
	img.src = "../resources/images/minus.png";
	show(id);
	openness[id] = true;
    } else {
	para.title = "Click to open";
	img.alt = "+";
	img.src = "../resources/images/plus.png";
	show(id);
	openness[id] = true;
    }
}

function show(id) {
    var e = document.getElementById(id);
    e.style.display = 'block';
}

function hide(id) {
    var e = document.getElementById(id);
    e.style.display = 'none';
}

function loadcssfile(filename){
    var fileref=document.createElement("link");
    fileref.setAttribute("rel", "stylesheet");
    fileref.setAttribute("type", "text/css");
    fileref.setAttribute("href", filename);
    if (typeof fileref!="undefined") document.getElementsByTagName("head")[0].appendChild(fileref);
}

function removecssfile(filename){
    var allsuspects=document.getElementsByTagName("link");
    for (var i=allsuspects.length; i>=0; i--){ //search backwards within nodelist for matching elements to remove
  	if (allsuspects[i] && allsuspects[i].getAttribute("href")!=null && allsuspects[i].getAttribute("href").indexOf(filename)!=-1)
	    allsuspects[i].parentNode.removeChild(allsuspects[i]) //remove element by calling parentNode.removeChild()
    }
}

