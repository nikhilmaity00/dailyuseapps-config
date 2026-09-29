#Requires -RunAsAdministrator

$BrowserPolicies = @(
    @{
        Name = "Chrome"
        Path = "HKLM:\SOFTWARE\Policies\Google\Chrome"
    },
    @{
        Name = "Edge"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    },
    @{
        Name = "Brave"
        Path = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
    }
)

foreach ($Browser in $BrowserPolicies) {

    Write-Host "Configuring $($Browser.Name) policies..." -ForegroundColor Cyan

    if (-not (Test-Path $Browser.Path)) {
        New-Item -Path $Browser.Path -Force | Out-Null
    }

    New-ItemProperty `
        -Path $Browser.Path `
        -Name "DefaultSearchProviderEnabled" `
        -Value 1 `
        -PropertyType DWord `
        -Force | Out-Null

    New-ItemProperty `
        -Path $Browser.Path `
        -Name "DefaultSearchProviderName" `
        -Value "Google (Web Only)" `
        -PropertyType String `
        -Force | Out-Null

    New-ItemProperty `
        -Path $Browser.Path `
        -Name "DefaultSearchProviderSearchURL" `
        -Value "https://www.google.com/search?q={searchTerms}&udm=14" `
        -PropertyType String `
        -Force | Out-Null

    New-ItemProperty `
        -Path $Browser.Path `
        -Name "DefaultSearchProviderSuggestURL" `
        -Value "https://www.google.com/complete/search?client=chrome&q={searchTerms}" `
        -PropertyType String `
        -Force | Out-Null

    Write-Host "Applied policies to $($Browser.Name)" -ForegroundColor Green
}

Write-Host "Done! Restart the browser and verify policies." -ForegroundColor Green