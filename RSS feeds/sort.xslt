<!--
Source - https://stackoverflow.com/a/69633914
Posted by Jobin Jacob Kavalam, modified by community. See post 'Timeline' for change history
Retrieved 2026-11-27, License - CC BY-SA 4.0
-->

<!--
Online Transform - https://xslttest.appspot.com
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="*">
        <!-- copy this node (but this does not copy the attributes ...) -->
        <xsl:copy>
            <!-- so, copy the attributes as well -->
            <xsl:copy-of select="@*"/>
            <!-- recurse on sorted (by tag name) list of child nodes -->
            <xsl:apply-templates>
                <xsl:sort select="name()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>