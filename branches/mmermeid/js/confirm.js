function show_confirm(formid,text)
{
    var r=confirm("Do you really want to delete the file '" + text +"'?" );
    if (r==true) {
	var form = document.getElementById(formid);
	form.submit();
    } else {
    }
}

