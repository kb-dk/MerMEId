xquery version "3.0";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";
dbutil:find-by-mimetype(xs:anyURI("/db"), "application/xquery", function
($resource) {
    sm:chmod($resource, "rwxr-xr-x")
}),
dbutil:scan-collections(xs:anyURI("/db"), function($collection) {
    sm:chmod($collection, "rwxr-xr-x")
})
