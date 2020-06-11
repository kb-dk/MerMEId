xquery version "3.0";

declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace config="https://github.com/edirom/mermeid/config" at "../modules/config.xqm";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(: all XForms get preprocessed :)
if (ends-with($exist:resource, ".xml")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!-- here by default the XML from $exist:path is fetched and all XInclude directives are resolved
             the result is provided to the code used in view as if it were a POST request with the XML in the body. -->
        <view>
            <forward url="/{$exist:controller}/../modules/transform.xq">
                <set-attribute name="transform.stylesheet" value="../filter/xsl/filter_get.xsl"/>
            </forward>
        </view>
        <cache-control cache="no"/>
    </dispatch>
else
(: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
        <set-attribute name="$exist:root" value="{$exist:root}"/>
    </dispatch>
