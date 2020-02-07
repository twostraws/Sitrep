install:
	swift build -c release
	install .build/release/sitrep /usr/local/bin/sitrep
