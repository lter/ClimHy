#!c:\\Perl\\bin\\perl.exe -w
$url = "http://$ENV\{SERVER_NAME\}$ENV\{URL\}";
#$url = "http://localhost";
$ip = "localhost";
system('java -cp "c:\fop-0.20.5\build\fop.jar;c:\fop-0.20.5\lib\xml-apis.jar;c:\fop-0.20.5\lib\xercesImpl-2.2.1.jar;c:\fop-0.20.5\lib\xalan-2.4.1.jar;c:\fop-0.20.5\lib\batik.jar;c:\fop-0.20.5\lib\avalon-framework-cvs-20020806.jar;c:\fop-0.20.5\lib\jimi-1.0.jar;c:\fop-0.20.5\lib\jai_core.jar;c:\fop-0.20.5\lib\jai_codec.jar" org.apache.fop.apps.Fop -xsl C:\Inetpub\climhy\bin\LTERmeta2fo.xsl -xml C:\Inetpub\climhy\temp\LTERmetadata.xml -pdf C:\Inetpub\climhy\temp\JRN.pdf');

print <<ENDOFTEXT;
HTTP/1.0 200 OK
Content-Type: text/html


<HTML>
<HEAD>
<TITLE>Hello World!</TITLE>
</HEAD>
<BODY> <H4>Hello World!</H4> <P>You have reached <a href="$url">$url</a></P> <P>Your IP Address is $ip</P> <H5>Have a nice day!</H5>
</BODY>
</HTML>

ENDOFTEXT

exit(0);
 
