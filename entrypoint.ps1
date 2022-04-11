<#
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Profile
)

$ErrorActionPreference = "Stop"
. ./ps-cibootstrap/bootstrap.ps1

########
# Capture version information
$version = @($Env:GITHUB_REF, "v0.1.0") | Select-ValidVersions -First -Required

Write-Information "Version:"
$version

########
# Determine docker tags
$dockerTags = @()

if ($version.FullVersion -ne "0.1.0")
{
    $dockerTags += $version.FullVersion

    # Add additional tags, if not prerelease
    if (!$version.IsPrerelease)
    {
        $dockerTags += ("{0}" -f $version.Major)
        $dockerTags += ("{0}.{1}" -f $version.Major, $version.Minor)
        $dockerTags += ("{0}.{1}.{2}" -f $version.Major, $version.Minor, $version.Patch)
    }

    $dockerTags += "latest"
}

Write-Information "Docker Tags:"
$dockerTags | ConvertTo-Json

$dockerImageName = "archmachina/devenv"

########
# Build stage
Invoke-CIProfile -Name $Profile -Steps @{

    lint = @{
        Script = {
            Use-PowershellGallery
            Install-Module PSScriptAnalyzer -Scope CurrentUser
            Import-Module PSScriptAnalyzer
            $results = Invoke-ScriptAnalyzer -IncludeDefaultRules -Recurse .
            if ($null -ne $results)
            {
                $results
                Write-Error "Linting failure"
            }
        }
    }

    build = @{
        Script = {
            # Docker build
            Write-Information ("Building for {0}" -f $dockerImageName)
            Invoke-Native "docker" "build", "-f", "./source/Dockerfile", "-q", "-t", $dockerImageName, "./source"
        }
    }

    pr = @{
        Dependencies = $("lint", "build")
    }

    latest = @{
        Dependencies = $("lint", "build")
    }

    release = @{
        Dependencies = $("build")
        Script = {
            $owner = "archmachina"
            $repo = "devenv"

            $releaseParams = @{
                Owner = $owner
                Repo = $repo
                Name = ("Release " + $version.Tag)
                TagName = $version.Tag
                Draft = $false
                Prerelease = $version.IsPrerelease
                Token = $Env:GITHUB_TOKEN
            }

            Write-Information "Creating release"
            New-GithubRelease @releaseParams

            # Attempt login to docker registry
            Write-Information "Attempting login for docker registry"
            Invoke-Native -Script { $Env:DOCKER_HUB_TOKEN | docker login --password-stdin -u archmachina docker.io }

            # Push docker images
            Write-Information "Pushing docker tags"
            $dockerTags | Select-Object -Unique | ForEach-Object {
                $tag = $_
                $path = ("{0}:{1}" -f $dockerImageName, $_)

                # Docker tag
                Write-Information ("Tagging build for {0}" -f $tag)
                Invoke-Native "docker" "tag", $dockerImageName, $path

                # Docker push
                Write-Information ("Docker push for for {0}" -f $path)
                Invoke-Native "docker" "push", $path
            }
        }
    }
}
