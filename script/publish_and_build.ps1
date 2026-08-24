# Builds NekoBox with your local changes via GitHub Actions (recommended for Windows).
# Usage (PowerShell):
#   cd e:\goProjects\nekobox
#   Set-ExecutionPolicy -Scope Process Bypass
#   .\script\publish_and_build.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RepoRoot

Write-Host ""
Write-Host "=== NekoBox: сборка через GitHub Actions ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Локальная сборка на Windows требует Visual Studio, Qt 6, vcpkg и ~10+ ГБ."
Write-Host "Проще: запушить ваши правки в СВОЙ форк и собрать в облаке GitHub (бесплатно)."
Write-Host ""

$status = git status --porcelain
if ($status) {
    Write-Host "Незакоммиченные изменения:" -ForegroundColor Yellow
    git status -sb
    Write-Host ""
}

$username = Read-Host "Ваш GitHub username (логин, не email)"
if ([string]::IsNullOrWhiteSpace($username)) {
    throw "Username обязателен."
}

$forkUrl = "https://github.com/$username/nekobox.git"
Write-Host ""
Write-Host "1) Если форка ещё нет, откройте в браузере:" -ForegroundColor Green
Write-Host "   https://github.com/qr243vbi/nekobox/fork"
Write-Host "   Нажмите Create fork и дождитесь создания."
Write-Host ""
Read-Host "Нажмите Enter когда форк готов"

if ($status) {
    $doCommit = Read-Host "Закоммитить текущие изменения перед push? (y/n)"
    if ($doCommit -match '^[yY]') {
        git add -A
        $msg = Read-Host "Сообщение коммита (Enter = default)"
        if ([string]::IsNullOrWhiteSpace($msg)) {
            $msg = "Add log error filter and quick route add from log"
        }
        git commit -m $msg
        Write-Host "Коммит создан." -ForegroundColor Green
    } else {
        Write-Host "Push без нового коммита — на GitHub останутся старые файлы!" -ForegroundColor Yellow
    }
}

$remotes = git remote
if ($remotes -notcontains "fork") {
    git remote add fork $forkUrl
    Write-Host "Добавлен remote 'fork' -> $forkUrl"
} else {
    git remote set-url fork $forkUrl
    Write-Host "Обновлён remote 'fork' -> $forkUrl"
}

Write-Host ""
Write-Host "2) Отправка в ваш форк (может запросить логин GitHub)..." -ForegroundColor Green
git push -u fork HEAD:main
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Push не удался. Частые причины:" -ForegroundColor Red
    Write-Host "  - не создан форк"
    Write-Host "  - нет доступа (нужен Personal Access Token вместо пароля)"
    Write-Host "  - в форке уже другая история (попробуйте: git pull fork main --rebase)"
    exit 1
}

$actionsUrl = "https://github.com/$username/nekobox/actions/workflows/build.yml"
Write-Host ""
Write-Host "3) Запуск сборки:" -ForegroundColor Green
Write-Host "   $actionsUrl"
Write-Host ""
Write-Host "   - Run workflow -> Run workflow"
Write-Host "   - publish: false (чтобы не публиковать релиз)"
Write-Host "   - build_windows_x64: true, остальные Windows по желанию"
Write-Host "   - Дождитесь зелёной галочки (~30-60 мин)"
Write-Host ""
Write-Host "4) Скачайте артеfact 'nekobox-...-windows-2022-x64...'"
Write-Host "   Внутри ZIP/portable — nekobox.exe с вашими правками."
Write-Host ""

Start-Process $actionsUrl
Write-Host "Страница Actions открыта в браузере." -ForegroundColor Cyan
