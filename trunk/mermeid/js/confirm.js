function show_confirm(formid,text)
{
    var r=confirm("Do you really want to delete the file '" + text +"'?" );
    if (r==true) {
    	var form = document.getElementById(formid);
    	form.submit();
    } else {
    }
}

function filename_prompt(formid,text)
{
    var name = prompt("Rename '" + text +"' to " );
    if (name!=null && name!="") {
    	var form = document.getElementById(formid);
    	form.name.value = name;
    	form.submit();
    } else {
    }
}

