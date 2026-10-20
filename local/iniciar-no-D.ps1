# Execute no PowerShell do Windows. Nao requer administrador.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        throw 'Este inicializador precisa ser executado no seu PC com Windows.'
    }
    if (-not (Test-Path -LiteralPath 'D:\' -PathType Container)) {
        throw 'A unidade D: nao esta disponivel. Nada sera instalado em outra unidade.'
    }

    $localBase = 'D:\CodexLocal'
    $editorPath = Join-Path $localBase 'vscode'
    $projectPath = Join-Path $localBase 'projeto'
    $downloadPath = Join-Path $localBase 'downloads'
    $tempPath = Join-Path $localBase 'temporarios'
    $codexPath = Join-Path $localBase 'codex'
    foreach ($folder in @($localBase, $projectPath, $downloadPath, $tempPath, $codexPath)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }

    # Configuracao apenas deste processo e dos aplicativos que ele abrir.
    $env:TEMP = $tempPath
    $env:TMP = $tempPath
    $env:CODEX_HOME = $codexPath
    $env:npm_config_cache = Join-Path $localBase 'cache-npm'
    $env:PIP_CACHE_DIR = Join-Path $localBase 'cache-pip'
    $env:HF_HOME = Join-Path $localBase 'modelos'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $editorExe = Join-Path $editorPath 'Code.exe'
    if (-not (Test-Path -LiteralPath $editorExe -PathType Leaf)) {
        $processorKind = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITEW6432')
        if (-not $processorKind) { $processorKind = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE') }
        $archiveKind = if ($processorKind -eq 'ARM64') { 'win32-arm64-archive' } elseif ($processorKind -eq 'AMD64') { 'win32-x64-archive' } else { throw 'Este inicializador exige Windows de 64 bits.' }
        $archivePath = Join-Path $downloadPath 'vscode-portatil.zip'
        Write-Host 'Baixando VS Code oficial para D:...'
        Invoke-WebRequest -UseBasicParsing -Uri "https://update.code.visualstudio.com/latest/$archiveKind/stable" -OutFile $archivePath
        Write-Host 'Extraindo VS Code em D:...'
        Expand-Archive -LiteralPath $archivePath -DestinationPath $editorPath -Force
        if (-not (Test-Path -LiteralPath $editorExe -PathType Leaf)) {
            throw 'O download nao produziu uma instalacao valida do VS Code.'
        }
    }

    # O modo portatil mantem dados e extensoes dentro da instalacao no D:.
    $portableData = Join-Path $editorPath 'data'
    New-Item -ItemType Directory -Path (Join-Path $portableData 'tmp') -Force | Out-Null

    $taskText = @'
# Continuar a decupagem no PC

Esta pasta e local: D:\CodexLocal\projeto.

1. Abra o Codex na barra lateral do VS Code (se nao aparecer, procure Codex no menu de extensoes).
2. Entre na sua conta OpenAI/ChatGPT. Trabalhe na sessao local desta pasta.
3. Envie ao Codex o pedido abaixo. Se o video estiver em outra unidade, copie-o para D: antes.

## Pedido para o Codex local

Decupe o video IMG_6300.MOV usando Remotion e entregue um MP4 realmente editado.
Localize o arquivo no D:. Se nao o encontrar, peca o caminho exato; nao use outro video.
Informe qual arquivo foi localizado e prossiga com a edicao. Preserve o original.

Confira o audio, transcreva as falas com precisao e selecione os takes corretos.
Corte instrucoes de gravacao, erros, falsos comecos, repeticoes e pausas excessivas.
Preserve o sentido, a continuidade das frases e respiracoes naturais.
Nao remova trechos so por terem silencio; avalie o conteudo das falas.
Nao invente palavras nem substitua o audio original por voz sintetica.
Use Remotion para montar e renderizar o video final; pode usar FFmpeg para preparar os arquivos.
Nao entregue apenas marcadores, lista de cortes ou transcricao.

Todos os arquivos criados ou baixados para esta tarefa, projetos, dependencias,
temporarios, modelos e exportacoes devem ficar em D:\CodexLocal ou em outra pasta no D:.
Se precisar instalar ferramentas, prefira versoes portateis dentro do D:.
Nao altere instalacoes existentes nem apague o video original.
Valide o MP4 final, principalmente as falas e as emendas, antes de entregar.

O video anterior 6423 foi outro trabalho. Nao aplique automaticamente seus
efeitos, materiais ou velocidade 1,20 a este novo video sem pedido do usuario.
Esta sessao local nao recebeu o historico completo da conversa na nuvem.

## Abrir novamente

Use D:\CodexLocal\Iniciar-Codex-Local.cmd para manter os caminhos no D:.
'@
    $rulesText = @'
# Regras desta pasta local

- Esta tarefa e a decupagem real de IMG_6300.MOV usando Remotion.
- Leia COMECE_AQUI.md para o pedido e os criterios de qualidade.
- Grave todos os arquivos da tarefa no D:, inclusive downloads, caches,
  modelos, dependencias, temporarios, projetos e exportacoes.
- Preserve os arquivos originais. Nao publique videos nem credenciais.
- Use as falas reais e selecione os takes pelo conteudo, nao apenas pelo silencio.
- Renderize e confira um MP4 editado. Marcadores sozinhos nao concluem a tarefa.
'@
    # Nao substitui instrucoes que o usuario ja tenha editado numa segunda execucao.
    $taskPath = Join-Path $projectPath 'COMECE_AQUI.md'
    $rulesPath = Join-Path $projectPath 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $taskPath)) { Set-Content -LiteralPath $taskPath -Value $taskText -Encoding UTF8 }
    if (-not (Test-Path -LiteralPath $rulesPath)) { Set-Content -LiteralPath $rulesPath -Value $rulesText -Encoding UTF8 }

    $launcherText = @'
@echo off
setlocal
set "TEMP=D:\CodexLocal\temporarios"
set "TMP=D:\CodexLocal\temporarios"
set "CODEX_HOME=D:\CodexLocal\codex"
set "npm_config_cache=D:\CodexLocal\cache-npm"
set "PIP_CACHE_DIR=D:\CodexLocal\cache-pip"
set "HF_HOME=D:\CodexLocal\modelos"
start "" "D:\CodexLocal\vscode\Code.exe" --new-window "D:\CodexLocal\projeto" "D:\CodexLocal\projeto\COMECE_AQUI.md"
endlocal
'@
    $launcherPath = Join-Path $localBase 'Iniciar-Codex-Local.cmd'
    Set-Content -LiteralPath $launcherPath -Value $launcherText -Encoding ASCII

    Write-Host 'Instalando a extensao oficial Codex (OpenAI)...'
    $editorCli = Join-Path $editorPath 'bin\code.cmd'
    & $editorCli --install-extension 'openai.chatgpt' --force
    if ($LASTEXITCODE -ne 0) {
        throw 'Nao foi possivel instalar a extensao Codex. Execute este arquivo novamente para tentar de novo.'
    }
    Write-Host 'Abrindo o VS Code local. Abra o Codex na lateral e entre na sua conta.'
    Start-Process -FilePath $editorExe -ArgumentList @('--new-window', $projectPath, $taskPath) -WorkingDirectory $projectPath
    Write-Host "Para abrir novamente: $launcherPath"
    Write-Host 'A conversa na nuvem continua separada desta nova sessao local.'
}
catch {
    Write-Host "Falha: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
