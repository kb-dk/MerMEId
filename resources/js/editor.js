function next(elem) {
    do {
        elem = elem.nextSibling;
    }
    while (elem && elem.nodeType != 1);
    return elem;
}

function setPageTitle() {
    if(document.title) {
        if(document.getElementById('work_identifier≡≡c').innerHTML != '') {
            document.title = 'MerMEId - '+document.getElementById('work_identifier≡≡c').innerHTML;
        }
    }
}
                             
function getInternetExplorerVersion()
// Returns the version of Internet Explorer or a -1
// (indicating the use of another browser).
{
  var rv = -1; // Return value assumes failure.
  if (navigator.appName == 'Microsoft Internet Explorer')
  {
    var ua = navigator.userAgent;
    var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
    if (re.exec(ua) != null)
      rv = parseFloat( RegExp.$1 );
  }
  return rv;
}

// Bugfix: turn off stuck loading indicator 
function turnOffLoadingIndicator(msg) {
	var x = document.getElementsByClassName("xforms-loading-loading");
	var i;
	for (i = 0; i < x.length; i++) {
	// The alert is necessary to delay the style change... sorry!
	if (msg!='') {
	   alert(msg);
	}
	x[i].style.visibility = "";
	}
}

function initialize() {
    setPageTitle();
}


