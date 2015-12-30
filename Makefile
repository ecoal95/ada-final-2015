BUNDLE_NAME := bundle
OBJECTS := $(filter-out obj/.keep, $(wildcard obj/*))

.PHONY: all
all:
	gnatmake -gnatwa -P final

.PHONY: test
test:
	bash test.sh 15 50 --no-prompt

.PHONY: test-long
test-long: test
	bash test.sh 30 100 --no-prompt
	bash test.sh 60 200 --no-prompt

.PHONY: bundle
bundle:
	git archive HEAD . -o $(BUNDLE_NAME).tar.gz
	git archive HEAD . -o $(BUNDLE_NAME).zip

.PHONY: clean-bundle
clean-bundle:
	$(RM) $(BUNDLE_NAME).tar.gz $(BUNDLE_NAME).zip

clean: clean-bundle
	$(RM) -r $(OBJECTS)
