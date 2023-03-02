all: index.html

clean:
	rm -f index.html

force:
	pipenv run bikeshed -f spec ./index.src.html

index.html: index.src.html
	pipenv run bikeshed spec ./index.src.html

publish:
	git push origin main
