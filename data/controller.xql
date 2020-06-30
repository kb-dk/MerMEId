xquery version "3.0";

import module namespace config="https://github.com/edirom/mermeid/config" at "../modules/config.xqm";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

import module namespace console="http://exist-db.org/xquery/console";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(console:log('/data Controller'),
if (ends-with($exist:resource, ".xml")) then
    (console:log('/data Controller: XML data'),
    switch (request:get-method())
    case 'GET' return
    (console:log('/data Controller: GET: dispatching to transform.xq'),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
       <forward url="/{$exist:controller}/../modules/transform.xq" method="{request:get-method()}">
            <set-attribute name="transform.stylesheet" value="../filter/xsl/filter_get.xsl"/>
            <set-attribute name="transform.doc" value="/db{$exist:prefix}{$exist:controller}{$exist:path}"/>
        </forward>
        <cache-control cache="no"/>
    </dispatch>)
    case 'PUT' return try {
    let $log := console:log('/data Controller: PUT: filter_put.xsl'),
(:        $logHeaders := console:log(for $headerName in request:get-header-names() return $headerName||': '||request:get-header($headerName)||'&#x0a;'),:)
(:        $logAttributes := console:log(for $attrName in request:attribute-names() return $attrName||': '||request:get-attribute($attrName)||'&#x0a;'),:)
(:        $logParameters := console:log(for $paramName in request:get-parameter-names() return $paramName||': '||request:get-parameter($paramName, '')||'&#x0a;'),:)
(:        $logCookieVals := console:log(for $cookieVal in request:get-cookie-names() return $cookieVal||': '||request:get-cookie-value($cookieVal)||'&#x0a;'),:)
        $filtered := transform:transform(request:get-data(), doc('../filter/xsl/filter_put.xsl'), <parameters>
                <param name="xslt.resources-endpoint" value="{config:get-property('exist_endpoint')}/resources"/>
                <param name="xslt.exist-endpoint-seen-from-orbeon" value="{$config:exist-endpoint-seen-from-orbeon}"/>
                <param name="xslt.orbeon-endpoint" value="{$config:orbeon-endpoint}"/>
                <param name="xslt.server-name" value="{config:get-property('exist_endpoint')}"/>
                <param name="xslt.exist-dir" value="/"/>
                <param name="xslt.document-root" value="/data/"/>
                <param name="exist:stop-on-warn" value="no"/>
                <param name="exist:stop-on-error" value="no"/>
</parameters>, <attributes></attributes>, "method=xml media-type=application/xml"),
        $saved := xmldb:store("/db"||$exist:prefix||$exist:controller||string-join(tokenize($exist:path, '/')[position() != last()], '/'), $exist:resource, $filtered)
    return doc($saved)
    } catch * {
        response:set-status-code(500),
        <error>
            <code>{$err:code}</code>
            <value>{$err:value}</value>
            <description>{$err:description}</description>
        </error>
    }
    default return (response:set-status-code(405), <_/>)
    )
else
(: everything else is passed through :)
   (console:log('/data Controller: passthrough'),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
        <set-attribute name="$exist:root" value="{$exist:root}"/>
    </dispatch>)
)
