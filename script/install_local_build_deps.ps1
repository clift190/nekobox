# Optional: install minimal tools for LOCAL build (still need Qt + vcpkg manually).
# Run PowerShell AS ADMINISTRATOR:
#   Set-ExecutionPolicy -Scope Process Bypass
#   .\script\install_local_build_deps.ps1

$ErrorActionPreference = "Stop"

Write-Host "Установка базовых инструментов через winget..." -ForegroundColor Cyan
Write-Host "Потребуются права администратора и несколько ГБ места."
Write-Host ""

$packages = @(
    @{ Id = "GitHub.cli"; Name = "GitHub CLI" },
    @{ Id = "Kitware.CMake"; Name = "CMake" },
    @{ Id = "Ninja-build.Ninja"; Name = "Ninja" },
    @{ Id = "Microsoft.VisualStudio.2022.BuildTools"; Name = "VS 2022 Build Tools" }
)

foreach ($pkg in $packages) {
    Write-Host "-> $($pkg.Name)" -ForegroundColor Yellow
    if ($pkg.Id -eq "Microsoft.VisualStudio.2022.BuildTools") {
        winget install --id $pkg.Id -e --accept-package-agreements --accept-source-agreements `
            --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
    } else {
        winget install --id $pkg.Id -e --accept-package-agreements --accept-source-agreements
    }
}

Write-Host ""
Write-Host "Готово. Перезапустите терминал." -ForegroundColor Green
Write-Host ""
Write-Host "ВАЖНО: для полной локальной сборки NekoBox ещё нужны Qt 6 и vcpkg-зависимости."
Write-Host "Для обычного пользователя проще: .\script\publish_and_build.ps1 (сборка в GitHub)."
