# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = source
BUILDDIR      = build
DESTDIR       = ../docs
PKGDIR		  = ..

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help html Makefile pkg

html:
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@rm -rf "${DESTDIR}"
	@mv "$(BUILDDIR)/html" "${DESTDIR}"
	@test -f "${DESTDIR}/.nojekyll" || touch "${DESTDIR}/.nojekyll"

pkg:
	@echo -n "Creando paquete de copia en el directorio padre... "
	@tar -acf "${PKGDIR}/linux.tar.gz" "${SOURCEDIR}"
	@echo "Hecho."

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
