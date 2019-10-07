xquery version "3.1";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="https://github.com/edirom/mermeid/config";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

(: 
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $config:data-root := $config:app-root || "/data";
declare variable $config:data-public-root := $config:app-root || "/data-public";

declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;

declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

declare variable $config:version := 'v. 2019 (13-08-2019) for MEI 4.0.0';

declare variable $config:orbeon-endpoint := 'http://localhost:9090/orbeon/xforms-jsp/mei-form/index.jsp';

declare variable $config:exist-endpoint-seen-from-orbeon := 'http://172.17.0.2:8080/exist/apps/mermeid';

declare function config:link-to-app($relLink as xs:string?) as xs:string {
    string-join((request:get-context-path(), request:get-attribute("$exist:prefix"), request:get-attribute("$exist:controller"), $relLink), "/")
    => replace('/+', '/')
};

declare function config:link-to-app-from-orbeon($relLink as xs:string?) as xs:string {
    $config:exist-endpoint-seen-from-orbeon || $relLink
};

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};
