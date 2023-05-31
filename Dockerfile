FROM jupyter/scipy-notebook:latest

USER root

RUN apt-get update --yes
RUN apt-get install --yes build-essential

# Python: add numpy
RUN mamba install --yes \
    'numpy' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install Go
# https://go.dev/dl/go1.20.4.linux-arm64.tar.gz
ARG go_tarball=go1.20.4.linux-arm64.tar.gz
RUN echo "start: install gonb" \
    && wget https://go.dev/dl/${go_tarball} \
    && rm -rf /usr/local/go && tar -C /usr/local -xzf ${go_tarball} \
    && echo "end: install gonb"

# gonb - https://github.com/janpfeifer/gonb
USER ${NB_UID}
ENV GOPATH=$HOME/go
RUN mkdir -p $GOPATH
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

RUN echo "start: install gonb" \
    && go install github.com/janpfeifer/gonb@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install golang.org/x/tools/gopls@latest \
    && gonb --install \
    && echo "end: install gonb"

RUN mkdir -p $HOME/work && chmod -R 766 $HOME/work
WORKDIR $HOME/work
CMD ["jupyter", "lab"]
