xquery version "3.0";

import module namespace config="https://github.com/edirom/mermeid/config" at "../modules/config.xqm";
            
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(: everything is passed through :)
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{replace($exist:controller, '-xml', '')}{$exist:path}"/>
        <!-- here by default the XML from $exist:path is fetched and all XInclude directives are resolved
             the result is provided to the code used in view as if it were a POST request with the XML in the body. -->
        <view>
            <forward url="/{$exist:controller}/../modules/transform.xq">
                <set-attribute name="transform.stylesheet" value="../filter/xsl/filter_get.xsl"/>
            </forward>
        </view>
    <cache-control cache="no"/>
</dispatch>