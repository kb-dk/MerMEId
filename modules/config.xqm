xquery version "3.1";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="https://github.com/edirom/mermeid/config";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace expath="http://expath.org/ns/pkg";
declare namespace dcm="http://www.kb.dk/dcm";

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

declare variable $config:properties := doc(concat($config:app-root, "/properties.xml"))/dcm:properties;

declare variable $config:version := 'v. 2019 (13-08-2019) for MEI 4.0.0';

(:~
 : properties read from the properties.xml file
 : can be altered manualy or set dynamically via config:set-property()
 :)
declare variable $config:orbeon-endpoint := config:get-property('orbeon_endpoint');
declare variable $config:exist-endpoint := config:get-property('exist_endpoint');
declare variable $config:exist-endpoint-seen-from-orbeon := config:get-property('exist_endpoint_seen_from_orbeon');

(:~
 : Return the requested property value from the properties file 
 :  
 : @param $key the element to look for in the properties file
 : @return xs:string the option value as string identified by the key otherwise the empty sequence
 :)
declare function config:get-property($key as xs:string?) as xs:string? {
    let $result := $config:properties/dcm:*[local-name() = $key] ! normalize-space(.)
    return
        if($result) then $result
        else util:log-system-out('config:get-property(): unable to retrieve the key "' || $key || '"')
};

(:~
 :  Set or add a property for the MerMEId
 :  This can be used by a trigger to inject options on startup or to change options dynamically during runtime
 :  NB: You have to be logged in as admin to be able to update preferences!
 : 
 :  @param $key the key to update or insert 
 :  @param $value the value for $key
 :  @return the new value if successful, the empty sequence otherwise
~:)
declare function config:set-property($key as xs:string, $value as xs:string) as xs:string? {
    let $old := $config:properties/dcm:*[local-name() = $key]
    return
        if($old) then try {(
            update value $old with $value,
            util:log-system-out('set preference "' || $key || '" to "' || $value || '"'),
            $value
            )}
            catch * { util:log-system-out('failed to set property "' || $key || '" to "' || $value || '". Error was ' || string-join(($err:code, $err:description), ' ;; ')) }
        else try {( 
            update insert element {$key} {$value} into $config:properties,
            util:log-system-out('added preference "' || $key || '" with value "' || $value || '"'),
            $value
            )}
            catch * { util:log-system-out('failed to add preference "' || $key || '" with value "' || $value || '". Error was ' || string-join(($err:code, $err:description), ' ;; ')) }
};

(:~
 : Return an absolute URL to the current MerMEId app for a given (relative) path 
 :  
 : @param $relLink the relative path within the app, e.g. "/data/incipit_demo.xml"
 : @return xs:string 
 :)
declare function config:link-to-app($relLink as xs:string?) as xs:string {
    $config:exist-endpoint || replace(normalize-space($relLink), '^/*', '/')
};

(:~
 : Return an absolute URL to the current MerMEId app – as seen by the orbeon sidekick – for a given (relative) path 
 :  
 : @param $relLink the relative path within the app, e.g. "/data/incipit_demo.xml"
 : @return xs:string 
 :)
declare function config:link-to-app-from-orbeon($relLink as xs:string?) as xs:string {
    $config:exist-endpoint-seen-from-orbeon || replace(normalize-space($relLink), '^/*', '/')
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
