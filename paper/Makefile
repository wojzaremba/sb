PARTS=sb.tex 


all: clean sb.pdf 

sb.pdf: $(PARTS) bibliography.bib 
	pdflatex -shell-escape sb.tex
	bibtex sb
	pdflatex -shell-escape sb.tex
	pdflatex -shell-escape sb.tex
	pdflatex -shell-escape sb.tex
	open sb.pdf

clean:
	rm -f sb.log sb.blg sb.aux sb.bbl sb.pdf sb.4tc sb.xref sb.tmp sb.dvi sb.bbl 
	rm -rf ~*
	rm -rf *.tmp
	rm -rf *.4om
	rm -rf *~
