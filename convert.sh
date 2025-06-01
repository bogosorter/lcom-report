pandoc README.md -o readme.html --template=template.html --self-contained
wkhtmltopdf readme.html readme.pdf

