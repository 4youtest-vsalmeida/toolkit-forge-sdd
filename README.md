# Toolkit Forge CLI

Command line utility that seeds a workspace with the Forge Specification-Driven Development (SDD) toolkit. The CLI copies the GitHub Copilot prompt and instruction packs, automation scripts, and document templates into the correct directories so a new project is ready for use in VS Code with Copilot Chat.

## Installation

```bash
pip install .
```

### Rodando direto com `uvx`

Como o pacote Python está na raiz do repositório, dá para executar sem instalar usando o
[`uvx`](https://docs.astral.sh/uv/guides/tools/#running-tools-with-uvx):

```bash
uvx --from gh:<owner>/<repo>@<ref> toolkit-forge init
```

Exemplo usando este repositório público:

```bash
uvx --from gh:4youtest-vsalmeida/toolkit-forge-sdd@v0.1.2 toolkit-forge init
```

O `uvx` cria um ambiente temporário, expõe o comando `toolkit-forge` e já executa o `init` na pasta atual.

Sempre que um novo tag `v*` for criado, o GitHub Actions gera os pacotes (`wheel` e `sdist`) e anexa aos releases, permitindo que o `uvx` baixe os artefatos diretamente.

## Usage

From any empty or existing Forge app workspace, run:

```bash
toolkit-forge init
```

This command creates or updates:

- `.github/` with the orchestrator prompts and instruction packs
- `.toolkit-forge-sdd/` containing scripts, templates, and reference docs
- `toolkit-forge-docs/` as an empty working area for generated cycle artifacts

Pass `--force` to overwrite existing files instead of skipping them.
