xquery version "3.0";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

<div xmlns="http://www.w3.org/1999/xhtml">
<h1>I hope your scripts are executable now</h1>
{
dbutil:find-by-mimetype(xs:anyURI("/db"), "application/xquery", function
($resource) {
    sm:chmod($resource, "rwxr-xr-x")
}),
dbutil:scan-collections(xs:anyURI("/db"), function($collection) {
    sm:chmod($collection, "rwxr-xr-x")
})
}
</div>