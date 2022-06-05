
function OpenGLDetected {
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [switch] $Enbale,
        [Parameter(Position = 0, ParameterSetName = "")]
        [switch] $Disbale
    )
    $SetttingPath = $([Environment]::GetFolderPath('LocalApplicationData')) + "\LINE\Data\plugin\LineMediaPlayer\setting.ini"
    $Content = (Get-Content $SetttingPath)

    if ($Enbale) {
        if ( $Content.IndexOf("SupportedOpenGLDetected=false") -ne -1 ) {
            (Invoke-RestMethod 'raw.githubusercontent.com/hunandy14/cvEncode/master/cvEncoding.ps1') | Invoke-Expression;
            $Content = $Content.Replace("SupportedOpenGLDetected=false", "SupportedOpenGLDetected=true")
            $Content | WriteContent $SetttingPath
        } Write-Host "啟用 OpenGL 完成"
    } elseif ($Disbale) {
        if ( $Content.IndexOf("SupportedOpenGLDetected=true") -ne -1 ) {
            (Invoke-RestMethod 'raw.githubusercontent.com/hunandy14/cvEncode/master/cvEncoding.ps1') | Invoke-Expression;
            $Content = $Content.Replace("SupportedOpenGLDetected=true", "SupportedOpenGLDetected=false")
            $Content | WriteContent $SetttingPath
        } Write-Host "禁用 OpenGL 完成"
    } else {
        Write-Host "當前狀態："$Content[1]
    }
} # OpenGLDetected
