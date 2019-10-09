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
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{$exist:root}{$exist:controller}/../filter/xsl/filter_get.xsl"/>
                <set-attribute name="xslt.resources-endpoint" value="{config:get-property('exist_endpoint')}/resources"/>
                <set-attribute name="xslt.exist-endpoint-seen-from-orbeon" value="{$config:exist-endpoint-seen-from-orbeon}"/>
                <set-attribute name="xslt.orbeon-endpoint" value="{$config:orbeon-endpoint}"/>
                <set-attribute name="xslt.server-name" value="{config:get-property('exist_endpoint')}"/>
                <set-attribute name="xslt.exist-dir" value="/"/>
                <set-attribute name="xslt.document-root" value="/data/"/>
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
