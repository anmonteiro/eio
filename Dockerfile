FROM ocaml/opam:debian-11-ocaml-5.0
# Make sure we're using opam-2.1:
RUN sudo ln -sf /usr/bin/opam-2.1 /usr/bin/opam
# Add the alpha repository with some required preview versions of dependencies:
RUN opam remote add alpha git+https://github.com/kit-ty-kate/opam-alpha-repository.git
# Ensure opam-repository is up-to-date:
RUN cd opam-repository && git pull origin 42a177d7ac37cd347aab366a90d20469203fc926 && opam update
# Install utop for interactive use:
RUN opam install utop fmt
# Install Eio's dependencies (adding just the opam files first to help with caching):
RUN mkdir eio
WORKDIR eio
COPY *.opam ./
RUN opam install --deps-only .
# Build Eio:
COPY . ./
RUN opam install .
