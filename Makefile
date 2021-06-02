all: index.html

clean:
	rm -f index.html

force:
	bikeshed -f spec ./index.src.html

index.html: index.src.html
	bikeshed spec ./index.src.html

publish:
	git push origin main
