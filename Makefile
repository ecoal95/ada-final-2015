BUNDLE_NAME := bundle

.PHONY: all
all: final
	@echo > /dev/null

.PHONY: test
test:
	bash test.sh 15 50 --no-prompt

final: nuclear_central.o

.PHONY: bundle
bundle:
	git archive HEAD . -o $(BUNDLE_NAME).tar.gz
	git archive HEAD . -o $(BUNDLE_NAME).zip

%.o: %.adb %.ads
	gnatmake -gnatwa $<

%.o: %.adb
	gnatmake -gnatwa $<

%: %.adb
	gnatmake -gnatwa $<

.PHONY: clean-bundle
clean-bundle:
	$(RM) $(BUNDLE_NAME).tar.gz

.PHONY: clean-ada-files
clean-ada-files:
	find . -type f -name '*.o' -delete
	find . -type f -name '*.ali' -delete

clean: clean-ada-files clean-bundle
	rm -f final
