# syntax=docker/dockerfile:1
FROM python:3.12-slim

# uv: gerenciador de pacotes/ambiente usado pelo FastContext
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Dependências de sistema:
#  - git           -> clonar o repositório do FastContext no build
#  - ripgrep       -> OBRIGATÓRIO: as tools Glob e Grep chamam `rg` via subprocess
#  - ca-certificates -> TLS
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ripgrep ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Pinne um commit/tag para builds reproduzíveis e auditáveis.
ARG FASTCONTEXT_REPO=https://github.com/microsoft/fastcontext.git
ARG FASTCONTEXT_REF=main

WORKDIR /opt
RUN git clone "${FASTCONTEXT_REPO}" fastcontext \
    && git -C fastcontext checkout "${FASTCONTEXT_REF}"

# Instala o CLI `fastcontext` no PATH
ENV UV_TOOL_BIN_DIR=/usr/local/bin
RUN cd /opt/fastcontext && uv tool install .

# Wrapper: direciona a trajetória para /out (volume gravável),
# já que /workspace é montado como somente-leitura.
COPY entrypoint.sh /usr/local/bin/fc-entrypoint
# Normaliza CRLF -> LF (caso o arquivo tenha sido salvo no Windows) e torna executavel.
RUN sed -i 's/\r$//' /usr/local/bin/fc-entrypoint \
    && chmod +x /usr/local/bin/fc-entrypoint

WORKDIR /workspace
ENTRYPOINT ["fc-entrypoint"]