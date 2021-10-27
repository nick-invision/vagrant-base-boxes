monterey-package:
	cd monterey && \
		vagant package

monterey-publish:
	./scripts/publish-box.sh monterey

monterey-provision:
	cd monterey && \
		vagant provision --provision-with setup

monterey-ssh:
	cd monterey && \
		vagrant ssh