# Codex local no Windows, no D:

Este inicializador baixa o VS Code portatil do site oficial da Microsoft,
instala a extensao oficial `openai.chatgpt` e abre uma pasta local com o pedido
de decupagem de `IMG_6300.MOV`. Nao transfere a conversa nem o video da nuvem.

Execute no PowerShell do seu PC, sem administrador:

```powershell
New-Item -ItemType Directory -Path D:\CodexLocal -Force | Out-Null
Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/marciacavalcante154/remotion1/main/local/iniciar-no-D.ps1' -OutFile D:\CodexLocal\iniciar-no-D.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File D:\CodexLocal\iniciar-no-D.ps1
```

O VS Code abrira `D:\CodexLocal\projeto\COMECE_AQUI.md`. Abra o Codex na
barra lateral, entre na conta e envie o pedido desse arquivo. Use uma tarefa
local, com a pasta do D: aberta. Se necessario, informe onde esta o video no D:.

Para reabrir, execute `D:\CodexLocal\Iniciar-Codex-Local.cmd`.

Os arquivos controlados por esta configuracao ficam em `D:\CodexLocal`:
editor portatil e extensoes, dados do Codex, projeto, downloads e temporarios.
Os caminhos de cache de npm, pip e modelos Hugging Face tambem apontam para D:.
As variaveis de ambiente so valem para os processos iniciados pelo inicializador;
nao modificam o PATH ou configuracoes globais do Windows. O Windows e o navegador
podem manter seus proprios registros em suas unidades de sistema.

Requisitos: Windows de 64 bits, unidade D: gravavel, internet para os sites da
Microsoft/OpenAI e espaco para o editor, video, ferramentas e renderizacao.
O script nao instala Node, Remotion ou FFmpeg; o Codex local pode prepara-los
no D: quando iniciar a edicao. O login e a execucao no PC dependem do usuario.

Validacao: script analisado com o parser do PowerShell. A instalacao completa
em Windows precisa ser executada no PC; o ambiente de desenvolvimento atual e Linux.

Referencias oficiais: [modo portatil do VS Code](https://code.visualstudio.com/docs/setup/portable),
[Codex no VS Code](https://marketplace.visualstudio.com/items?itemName=openai.chatgpt).
