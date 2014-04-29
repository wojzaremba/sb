PARTS=sb.tex 


all: clean sb.pdf 

sb.pdf: $(PARTS) bibliography.bib 
	pdflatex -shell-escape sb.tex
	pdflatex -shell-escape sb.tex
	pdflatex -shell-escape sb.tex
	bibtex sb
	bibtex sb
	pdflatex -shell-escape sb.tex
	pdflatex -shell-escape sb.tex

pdfcrop:
	pdfcrop img/linear_arity_3-eps-converted-to.pdf
	pdfcrop img/linear_arity_5-eps-converted-to.pdf
	pdfcrop img/random_arity_3-eps-converted-to.pdf
	pdfcrop img/random_arity_5-eps-converted-to.pdf
	pdfcrop img/independence_surface-eps-converted-to.pdf

clean:
	rm -f sb.log sb.blg sb.aux sb.bbl sb.pdf sb.4tc sb.xref sb.tmp sb.dvi sb.bbl 
	rm -rf ~*
	rm -rf *.tmp
	rm -rf *.4om
	rm -rf *~
