# FastContext + LM Studio (Docker)

Roda o [microsoft/fastcontext](https://github.com/microsoft/fastcontext) num container,
usando o LM Studio do host como backend (endpoint compatível com OpenAI).

## Arquivos

- `Dockerfile` — Python 3.12 + uv + **ripgrep** (obrigatório p/ Glob/Grep), clona e instala o `fastcontext`.
- `docker-compose.yml` — monta o repo em `/workspace` (RO) e aponta para o LM Studio via `host.docker.internal`.
- `entrypoint.sh` — joga a trajetória em `/out` (já que o repo é read-only).
- `.env.example` — modelo de configuração.

## Uso

```bash
cp .env.example .env
# edite .env: REPO_PATH (repo a explorar) e MODEL (id no LM Studio)

docker compose build

docker compose run --rm fastcontext \
  -q "Encontre onde a autenticacao e implementada e onde alterar" \
  --max-turns 6

# So o bloco de citacoes <final_answer>:
docker compose run --rm fastcontext -q "Localize a validacao de request" --citation
```

As trajetórias ficam em `./out/`.

## Pré-requisitos / armadilhas

1. **LM Studio em rede local.** Em *Developer > Server*, ligue **"Serve on Local Network"**
   (bind `0.0.0.0`). Com bind apenas em `localhost`, o container não alcança o host.
2. **`host.docker.internal`** — funciona no Docker Desktop (Windows/Mac). O `extra_hosts:
   host-gateway` cobre Docker Engine nativo / WSL2. Se o LM Studio roda no Windows e o
   Docker no WSL2 (Docker Desktop), o nome resolve pro host Windows — que é onde o LM Studio está.
3. **Tool calling obrigatório.** O modelo carregado precisa suportar function calling;
   FastContext só age via Read/Glob/Grep. Qwen3.5-4B suporta.
4. **`MODEL`** deve ser o id exato exposto pelo LM Studio.
5. **Repo read-only.** Se preferir, troque `:ro` por leitura/escrita no compose — mas o
   FastContext não modifica fontes, só lê.

## Verificar a conexão com o LM Studio

```bash
# do host:
curl http://localhost:1234/v1/models

# de dentro do container:
docker compose run --rm --entrypoint sh fastcontext -c \
  'apt-get install -y curl >/dev/null 2>&1; curl -s "$BASE_URL/models"'
```
