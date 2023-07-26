ARG BASE_OS=centos:7

FROM ${BASE_OS}

RUN yum install -y tar xz wget \
    findutils make gcc gcc-c++ \
    openssl-devel bzip2-devel libffi-devel libuuid-devel sqlite-devel gdbm-devel expat-devel ncurses-devel xz-devel readline-devel tk-devel && \
    yum clean all

ENV PYTHON_VERSION            3.8.17
ENV PYTHON_VERSION            3.9.17
ENV PYTHON_PIP_VERSION        23.2.1
ENV PYTHON_SETUPTOOLS_VERSION 68.0.0

RUN set -eux; \
    url="https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
	wget -O "Python-${PYTHON_VERSION}.tar.xz" "$url"; \
    tar xf "Python-${PYTHON_VERSION}.tar.xz" && cd "/Python-${PYTHON_VERSION}" && ./configure \
    --enable-loadable-sqlite-extensions \
    --enable-optimizations \
    --enable-option-checking=fatal \
    --enable-shared \
    --with-lto \
    --with-system-expat \
    --without-ensurepip && \
    make -j && \
    make install && \
    find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
        \) -exec rm -rf '{}' + \
    ; \
    \
    rm -rf /Python* && \
    echo '/usr/local/lib' >> /etc/ld.so.conf && ldconfig && \
    python3 --version; \
    \
    for src in idle3 pydoc3 python3 python3-config; do \
        dst="$(echo "$src" | tr -d 3)"; \
        [ -s "/usr/local/bin/$src" ]; \
        [ ! -e "/usr/local/bin/$dst" ]; \
        ln -svT "$src" "/usr/local/bin/$dst"; \
    done; \
    \
    curl -LfsSo /get-pip.py https://bootstrap.pypa.io/get-pip.py; \
    python3 get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        --no-compile \
        "pip==$PYTHON_PIP_VERSION" \
        "setuptools==$PYTHON_SETUPTOOLS_VERSION" \
    ; \
    rm -f get-pip.py; \
    \
    pip --version

CMD ["python3"]
