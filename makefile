sitrep:
	@swift build -c release
	@echo \\nBuild complete! The Sitrep binary is in .build/release/sitrep.
	@echo Run \`sudo make install\` to copy the binary to /usr/local/bin/sitrep,
	@echo or copy it there by hand.
	@echo

install:
	@install .build/release/sitrep /usr/local/bin/sitrep || (echo \\n\*\*\* \`make install\` failed – please check your permissions.\\n)

clean:
	@rm -rf .build
	@echo "All build files removed."
	@echo