# MySQLBackup

![image](https://user-images.githubusercontent.com/26009394/93598735-7fed7a80-f993-11ea-8938-19e699e241a4.png)


## O que é 

É um script para automação de backups do banco de dados(MySQL), ele gera um arquivo de backup para cada DATABASE separada, contendo no nome do arquivo a data de geração, ele também gera um único arquivo de backup completo que contém todas as DATABASE do banco de dados(MySQL), logo em seguida todos os arquivos gerados são compactados em um únco arquivo em formato RAR.

## Instalação e uso

Clonar o Repositório 

```
git clone https://github.com/fernandocalheirox/MySQLbackup.git
```

Para ver os possíveis parâmetros:

```
powershell -f mysql-backup.ps1 -help
```


## Diretório de saida

__C:\Backup-MySQL__
