# MySQLBackup

![banne](https://user-images.githubusercontent.com/26009394/93550452-cadea200-f941-11ea-83d5-03bf3740dec4.png)


## O que é 

É um script para automação de backups do banco de dados(MySQL), ele gera um arquivo de backup para cada DATABASE separada, contendo no nome do arquivo a data de geração, ele também gera um único arquivo de backup completo que contém todas as DATABASE do banco de dados(MySQL), logo em seguida todos os arquivos gerados são compactados em um únco arquivo em formato RAR.

## Instalação e uso

Clonar o Repositório 

```
git clone https://github.com/fernandocalheirox/MySQLbackup.git
```

Para executar um Backup de todas as DATABASES do MySQL:

```
powershell -f mysql-backup.ps1 -alldatabases
```

Para executar um Backup de uma DATABASE especifica do MySQL:

```
powershell -f mysql-backup.ps1 -database <DATABASE>
```

## Diretório de saida

__C:\Backup-MySQL__
