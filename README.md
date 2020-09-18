# MySQLBackup

![image](https://user-images.githubusercontent.com/26009394/93598735-7fed7a80-f993-11ea-8938-19e699e241a4.png)


## O que é 

É um script para automação de backups do banco de dados(MySQL), após realizar os backups ele compacta os arquivos gerados pelo MySQLDump em um unico arquivo RAR.

## Instalação e uso

Clonar o Repositório 

```
git clone https://github.com/fernandocalheirox/MySQLbackup.git
```

Para ver os possíveis parâmetros:

```
powershell -f mysql-backup.ps1 -help
```

## Valores Padrões

### Usuario padrão

```
root
```

### Senha padrão

```
toor
```

### Servidor padrão

```
localhost
```

### Path de saida dos backups padrão

```
C:\Backup-MySQL
```

### Local do arquivo MySqlDump.exe no MySQL Server 8.0

```
C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe
```

### Local do arquivo MySql.Data.dll

```
MySQLbackup/dll/MySql.Data.dll
```
