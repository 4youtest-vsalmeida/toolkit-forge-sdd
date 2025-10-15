# Toolkit Forge CLI

Command line utility that seeds a workspace with the Forge Specification-Driven Development (SDD) toolkit. The CLI copies the GitHub Copilot prompt and instruction packs, automation scripts, and document templates into the correct directories so a new project is ready for use in VS Code with Copilot Chat.

## Installation

-```bash
pip install .
```

### Rodando direto com `uvx`

Assim que o repositório estiver publicado, é possível executar o CLI sem instalá-lo
permanentemente usando o [`uvx`](https://docs.astral.sh/uv/guides/tools/#running-tools-with-uvx):

```bash
uvx gh:<owner>/<repo>@<ref> toolkit-forge init
```

Substitua `<owner>`, `<repo>` e `<ref>` pela organização, nome do repositório e branch/tag
respectivamente (por exemplo `gh:acme/toolkit-forge-cli@main`). Se o projeto estiver dentro de um
subdiretório do repositório, acrescente `#subdirectory=toolkit-cli` ao final da referência:

```bash
uvx --from "git+https://github.com/<owner>/<repo>.git@<ref>#subdirectory=toolkit-cli" toolkit-forge init
```

Esses comandos criam um ambiente temporário, disponibilizam o executável `toolkit-forge` e já
disparam o `init` na pasta corrente.

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
