all: kaldi kaldi_python
.PHONY: kaldi_python kaldi kaldi_github

kaldi: kaldi_github
	cp -r kaldi_github kaldi
	cd kaldi/tools; ./extras/check_dependencies.sh; $(MAKE) all -j 4
	cd kaldi/src; ./configure --shared --use-cuda; $(MAKE) depend -j 4; $(MAKE) all -j 4
	
kaldi_github:
	git clone https://github.com/kaldi-asr/kaldi.git kaldi_github

#Python wrappers for Kaldi data
kaldi_python: kaldi
	git clone https://github.com/janchorowski/kaldi-python.git kaldi_python
	cd kaldi_python; $(MAKE) all KALDI_ROOT=$(CURDIR)/kaldi

clean:
	rm -rf kaldi_python kaldi_github kaldi
