# Esegue un file di query (o una query) in sola lettura su uno dei DB definiti in .env
# e salva i risultati in TSV. Con -OutDir ogni sezione "-- @nome" finisce in <nome>.tsv.
# Uso: esegui-query.ps1 -Db test|prod -File query.sql [-OutDir cartella]   oppure   -Sql "SELECT ..."
# Il file .env (escluso da git) contiene DB_SERVER, DB_USER, DB_PASSWORD, DB_TEST, DB_PROD.
param(
    [ValidateSet('test','prod','master')][string]$Db = 'test',
    [string]$File,
    [string]$Sql,
    [string]$Out,
    [string]$OutDir,
    [int]$Timeout = 600
)
$envFile = Join-Path $PSScriptRoot '..\.env'
$cfg = @{}
Get-Content $envFile | Where-Object { $_ -match '^\s*([^#=]+)=(.*)$' } | ForEach-Object { $cfg[$Matches[1].Trim()] = $Matches[2] }
$dbName = switch ($Db) { 'test' { $cfg.DB_TEST } 'prod' { $cfg.DB_PROD } 'master' { 'master' } }
if ($File) { $Sql = Get-Content -Raw -Encoding UTF8 $File }

$cs = "Server=$($cfg.DB_SERVER);Database=$dbName;User ID=$($cfg.DB_USER);Password=$($cfg.DB_PASSWORD);Application Name=galileo-analisi;ApplicationIntent=ReadOnly;Connect Timeout=15"
$conn = New-Object System.Data.SqlClient.SqlConnection $cs
$conn.Open()
try {
    $sb = New-Object System.Text.StringBuilder
    if ($OutDir) { New-Item -ItemType Directory -Force $OutDir | Out-Null }
    # i batch sono separati da GO, come in SSMS
    foreach ($batch in ($Sql -split '(?im)^\s*GO\s*$')) {
        if ($batch.Trim() -eq '') { continue }
        $nome = if ($batch -match '--\s*@(\w+)') { $Matches[1] } else { $null }
        if ($OutDir -and $nome) { $sb = New-Object System.Text.StringBuilder }
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $batch
        $cmd.CommandTimeout = $Timeout
        try { $rd = $cmd.ExecuteReader() }
        catch { [void]$sb.AppendLine("ERRORE`t$($_.Exception.InnerException.Message)"); if ($OutDir -and $nome) { [IO.File]::WriteAllText((Join-Path $OutDir "$nome.tsv"), $sb.ToString(), (New-Object Text.UTF8Encoding $false)); "ERRORE in $nome" }; continue }
        do {
            if ($rd.FieldCount -gt 0) {
                $names = for ($i = 0; $i -lt $rd.FieldCount; $i++) { $rd.GetName($i) }
                [void]$sb.AppendLine(($names -join "`t"))
                while ($rd.Read()) {
                    $vals = for ($i = 0; $i -lt $rd.FieldCount; $i++) {
                        $v = $rd.GetValue($i)
                        if ($v -is [DBNull]) { 'NULL' }
                        elseif ($v -is [datetime]) { $v.ToString('yyyy-MM-dd HH:mm:ss') }
                        else { ([string]$v) -replace "[`t`r`n]+", ' ' }
                    }
                    [void]$sb.AppendLine(($vals -join "`t"))
                }
                [void]$sb.AppendLine()
            }
        } while ($rd.NextResult())
        $rd.Close()
        if ($OutDir -and $nome) { [IO.File]::WriteAllText((Join-Path $OutDir "$nome.tsv"), $sb.ToString(), (New-Object Text.UTF8Encoding $false)); "ok $nome" }
    }
    if ($OutDir) { return }
    if ($Out) { [IO.File]::WriteAllText($Out, $sb.ToString(), (New-Object Text.UTF8Encoding $false)) ; "scritto $Out" }
    else { $sb.ToString() }
}
finally { $conn.Close() }
