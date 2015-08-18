
function add_publish(formid,inputid,checkboxid)
{
    var formdiv   = document.getElementById('publish');
    var localform = document.getElementById(formid);
    var input     = document.getElementById(inputid);
    var checkbox  = document.getElementById(checkboxid);

    setTimeout(function() {
	if(checkbox.checked == false) {
            localform.insertBefore(input,getFirstChild(localform));
	} else {
	    formdiv.appendChild(input);
	}
    },0);
}

function check_all()
{
    var inputs = new Array();  
    inputs = document.getElementsByTagName("input");  

    for(var i = 0; i < inputs.length ; i++) {
        var input = inputs[i];
        if(input.type=="checkbox" && input.title=="publish") 
	{
            if(input.checked==false) 
	    {
		input.click();
                input.checked=true;
	    }
	} 
    }
}

function un_check_all()
{
    var inputs = new Array();  
    inputs = document.getElementsByTagName("input");  

    for(var i = 0; i < inputs.length ; i++) 
    {
	var input = inputs[i];
	if(input.type=="checkbox" && input.title=="publish") 
	{
	    if(input.checked==true) 
	    {
		input.click();
	        input.checked=false;
	    }
	} 
    }
}


function getFirstChild(parent)
{
    for(var i = 0; i < parent.childNodes.length; i++ ) 
    {
	if( parent.childNodes[i].nodeName == 'INPUT' ) 
	{
	    return  parent.childNodes[i];
	} 
    }
    return null;
}
