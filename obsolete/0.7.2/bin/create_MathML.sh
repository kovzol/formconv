echo "To view it you need the following files in the output's directory:"
echo "  ctop.xsl, mathml.xsl pmathml.xsl"
echo "Usage: create_MathML.sh from_file to_file_without_xml"

../formconv -i $1 -o $2.xml --input-content boolean-expression -O mathml --prefix "<p>" --suffix "</p>" --header "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"mathml.xsl\"?>
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
<title>mathmlout.xml</title>
</head>
<body>" --footer "</body>
</html>" --allowed-letters "abcdefghijklmnopqrstuvwxyz"
