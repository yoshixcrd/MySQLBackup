############################################################################
#                                                                          #
# Nome Script: MySQLBackup                                                 #
# Autor: Fernando                                                          #
# Contato: nando.calheirosx@gmail.com                                      #
# GitHub: https://github.com/fernandocalheirox/MySQLbackup                 #
#                                                                          #
############################################################################

param($database = $null, [switch]$alldatabases = $true, $server = "localhost", $user = "root", $password = " ", $path_backup = "C:\Backup-MySQL\", [switch]$help = $false);


$banner = @"
`n __  __       ____   ___  _     ____             _                
|  \/  |_   _/ ___| / _ \| |   | __ )  __ _  ___| | ___   _ _ __  
| |\/| | | | \___ \| | | | |   |  _ \ / _`  |/ __| |/ / | | | '_ \ 
| |  | | |_| |___) | |_| | |___| |_) | (_| | (__|   <| |_| | |_) |
|_|  |_|\__, |____/ \__\_\_____|____/ \__,_|\___|_|\_\\__,_| .__/ 
        |___/                                              |_|    

contato: nando.calheirosx@gmail.com
"@

Write-Host $banner;

$helpOptions = @" 
`n
[+] Uso: mysql-backup.ps1 -alldatabases
         mysql-backup.ps1 -database <DATABASE>
         mysql-backup.ps1 -server <SERVER> -user <USER> -password <PASSWORD> [-database <DATABASE> or -alldatabase]
         mysql-backup.ps1 -server <SERVER> -user <USER> -password <PASSWORD> -path_backup <PATH-BACKUP> -database <DATABASE>

[+] Ajuda: mysql-backup.ps1 -help 
`n
"@;


if($help) {
    Write-Host $helpOptions;
    exit(0);
}


# Pega a hora atual do sistema
$timestamp = Get-Date -format "yyyy-MM-dd"

# Local do arquivo MySqlDump.exe no MySQL Server 8.0
$mysqldump = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"

# Server Configs
$mysql_server = $server;
$mysql_user = $user;
$mysql_password = $password;

# Path aonde o backup sera gerado
$PathBackup = $path_backup + $timestamp + "\";
# Caso o diretório/subdiretórios não exista, é criado
if (!(Test-Path -Path $PathBackup)) {
    New-Item -Path $PathBackup -ItemType Directory | Out-Null;
}


if (($database -eq $null) -and ($alldatabases -eq $null)) {
    Write-Host $helpOptions;
    exit(0);
}


# Pega o local atual onde o script está sendo executado.
$Localizao = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition);

# Path onde esta o MySQL.Data.dll
$PathMySQLData = $Localizao + "\dll\MySql.Data.dll"

# Necessário para se conectar ao MySQL
[void][system.reflection.Assembly]::LoadFrom($PathMySQLData);
[void][system.reflection.assembly]::LoadWithPartialName("MySql.Data");

# Cria a conexão com a Database 'information_schema' do MySQL
$conexao = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection;
$conexao.ConnectionString = "SERVER=$mysql_server;DATABASE=information_schema;UID=$mysql_user;PWD=$mysql_password";
$conexao.Open()
    


# Consulta para obter os nomes dos DATABASES em ordem ascendente 
$command = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand;

# Query SQL
$query = "SELECT DISTINCT CONVERT(SCHEMA_NAME USING UTF8) AS databaseName, CONVERT(NOW() USING UTF8) AS dtStamp FROM SCHEMATA ORDER BY databaseName ASC"
$command.Connection =   $conexao;
$command.CommandText = $query;

# Executa a query
$dr = $command.ExecuteReader();


if(!($database -eq $null)) {

    Write-Host "[+] Gerando Backup da DATABASE passada como paramêtro !"
        # Gera um arquivo .sql para a DATABASE passada como parametro
    while ($dr.Read()) {

            # Armazena o nome do Database retornada pela query
        $dbname = [string]$dr.GetString(0);
        if($dbname -match $database){
                # Verifica se a database existe no banco de dados
            Write-Host "[+] Backup database: " $dr.GetString(0);
        
                    # Define o nome do arquivo de BACKUP
            $backupFilename = $timestamp + "-" + $dr.GetString(0) + ".sql";
            $backupPathFile = $PathBackup + $backupFilename;
        
                    # Verifica se o arquivo/Path já existe, caso exista remove
            if (Test-Path($backupPathFile)) {
                Write-host "`n O arquivo de Backup " $backupFilename " ja existe";
                Write-Host "Deletando o arquivo localizado em " $backupPathFile;
                Remove-Item $backupPathFile;
            }
        
                    # Gera o arquivo Backup
            cmd /c " `"$mysqldump`" -h $mysql_server -u $mysql_user -p$mysql_password $dbname > $backupPathFile ";
        
                    # Verifica se o arquivo de BACKUP foi gerado 
            if (Test-Path($backupPathFile)) {
                Write-Host "`n[+] Backup criado em: " $backupPathFile;
            }
        }
        Write-Host " ";
    }

    # Fecha conexão com o banco de dados.
    $conexao.close();
        
}

elseif (!($alldatabases -eq $false)) {

    Write-Host "`nGerando Backup de todas as DATABASES do MySQL`n"
    # Gera um arquivo .sql para cada DATABASE do BD
    while ($dr.Read()) {

        # Armazena o nome do Database retornada pela query
        $dbname = [string]$dr.GetString(0);
        # Verifica se a database existe no banco de dados
        Write-Host "[+] Backup database: " + $dr.GetString(0) + "`n";

            # Define o nome do arquivo de BACKUP
        $backupFilename = $timestamp + "-" + $dr.GetString(0) + ".sql";
        $backupPathFile = $PathBackup + $backupFilename;

            # Verifica se o arquivo/Path já existe, caso exista remove
        if (Test-Path($backupPathFile)) {
            Write-host "`n O arquivo de Backup " $backupFilename " ja existe";
            Write-Host "Deletando o arquivo localizado em " $backupPathFile;
            Remove-Item $backupPathFile;
        }

            # Gera o arquivo Backup
        cmd /c " `"$mysqldump`" -h $mysql_server -u $mysql_user -p$mysql_password $dbname > $backupPathFile ";

            # Verifica se o arquivo de BACKUP foi gerado 
        if (Test-Path($backupPathFile)) {
            Write-Host "`n[+] Backup criado em: " $backupPathFile;
        }

        Write-Host " ";
    }

    # Gera um Backup Full
    $backupFullName = $timestamp + "-backup-full.sql";
    $PathBackupFull = $PathBackup + $backupFullName;

    Write-Host "`n[+] Gerando o Backup Completo"
    # Verifica se o arquivo de backup completo ja existe, caso exista deleta
    if ((Test-Path($PathBackupFull))) {
        Write-Host "`nO arquivo de Backup Completo " $backupFullName;
        Write-Host "Deletando o arquivo localizado em " $PathBackupFull;
        Remove-Item $PathBackupFull;
    }

    # Gera o BackupFull
    cmd /c " `"$mysqldump`" -h $mysql_server -u $mysql_user -p$mysql_password > $PathBackupFull ";

    # Verifica se o Backup Completo foi gerado
    if(Test-Path($PathBackupFull)) {
        Write-Host "`nBackup Completo criado em: " $PathBackupFull;
    }

    # Fecha conexão com o banco de dados.
    $conexao.close();
}

else {
    Write-Host $helpOptions;
    exit(0);
}



# Gera um arquivo compactado contendo todas as DATABASES do MySQL

if (!($database -eq $null)){

    Write-Host "`n`n[+] Gerando arquivo de backup compactado"
    $backupCompactName = $timestamp +"-backup.rar"

    # Gera o Path do Arquivo Backup Compactado em RAR
    $BackupCompactPath = $path_backup  + $backupCompactName;

    # Verifica se o arquivo RAR já existe, caso exista o deleta
    if(Test-Path($BackupCompactPath)) {
        Write-Host "`nO Arquivo de Backup Compactado " + $backupCompactName + " já existe.";
        Write-Host "`nDeletando o arquivo localizado em " $BackupCompactPath;
        Remove-Item $BackupCompactPath |  Out-Null;
    }

    # Compacta a pasta criada em RAR
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem');
    [void][System.IO.Compression.ZipFile]::CreateFromDirectory($PathBackup, $BackupCompactPath);

    if(Test-Path($BackupCompactPath)) {

        Write-Host "`nBackup Compactado gerado em: " $BackupCompactPath;
    }

    Write-Host "`n[ Removendo o Diretorio ]";
    Write-Host "Removendo o diretorio "  $PathBackup  " gerado anteriormente.`n";


    # Remove a pasta gerada anteriormente
    if(Test-Path($PathBackup)) {
        Remove-Item -Recurse $PathBackup |  Out-Null;
    }
}

elseif (!($alldatabases -eq $false)) {

    Write-Host "`n`n[+] Gerando arquivo de backup compactado"
    $backupCompactName = $timestamp + "-backup-full.rar"

    # Gera o Path do Arquivo Backup Compactado em RAR
    $BackupCompactPath = $path_backup + $backupCompactName;

    # Verifica se o arquivo RAR já existe, caso exista o deleta
    if(Test-Path($BackupCompactPath)) {
        Write-Host "`nO Arquivo de Backup Compactado" $backupCompactName "ja existe.";
        Write-Host "`nDeletando o arquivo localizado em" $BackupCompactPath;
        Remove-Item $BackupCompactPath |  Out-Null;
    }

    # Compacta a pasta criada em RAR
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem');
    [void][System.IO.Compression.ZipFile]::CreateFromDirectory($PathBackup, $BackupCompactPath);

    if(Test-Path($BackupCompactPath)) {

        Write-Host "`nBackup Compactado gerado em:" $BackupCompactPath;
    }

    Write-Host "`n[ Removendo o Diretorio ]";
    Write-Host "Removendo o diretorio"  $PathBackup  "gerado anteriormente.`n";


    # Remove a pasta gerada anteriormente
    if(Test-Path($PathBackup)) {
        Remove-Item -Recurse $PathBackup |  Out-Null;
    }


}

else {
    Write-Host $helpOptions;
    exit(0);
}