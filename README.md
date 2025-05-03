# Banco Central Fabio — Container Docker com MySQL

Este repositório contém a configuração Docker e o script SQL para criar um banco de dados MySQL (`banco_central_fabio`) com tabelas de clientes e contas, além de procedures para operações transacionais (inserção, depósito, saque e transferência).

---

## Pré-requisitos

- Docker (versão ≥ 20.10)
- Docker Compose (versão ≥ 1.27)
- Postman ou cliente MySQL (opcional, para testes manuais)

---

## Estrutura do projeto

```text
.
├── docker-compose.yml      # Define o serviço MySQL e monta o script de inicialização
├── init.sql                # Script SQL executado na primeira inicialização do container
└── README.md               # Este arquivo de documentação
````

---

## Como rodar localmente

1. Clone este repositório:

   ```bash
   git clone git@github.com:fabiobrasileiroo/banco_central_sql_exercicio3.git
   cd banco_central_sql_exercicio3
   ```

2. Inicie o container Docker:

   ```bash
   docker-compose up -d
   ```

   * O MySQL ficará disponível em `localhost:3306`.
   * Usuário: `root`
   * Senha: definida no `docker-compose.yml` (ex: `root`).

3. Verifique os logs (opcional):

   ```bash
   docker-compose logs -f mysql
   ```

4. Acesse o banco de dados:

   ```bash
   docker exec -it mysql_banco_central mysql -uroot -proot banco_central_fabio
   ```

---

## O que o `init.sql` faz

1. **Criação das tabelas**

   * `clientes` (id, nome, email)
   * `contas` (id, nome, saldo)

2. **Popula dados iniciais**

   * Clientes: Han Solo, Katy Perry, Bob Marley, Lady Gaga, Luke Skywalker, Leia Organa
   * Contas correspondentes com saldos iniciais

3. **Cria procedures**

   * `add_conta(nome, saldo)`
   * `deposito_conta(id, valor)`
   * `saque_conta(id, valor)`
   * `transferencia_conta(origem, destino, valor)`

4. **Exemplos de uso**

   * Chamadas de procedures para depositar, sacar e transferir

---

## Exemplos de comandos SQL

Após entrar no MySQL:

```sql
-- Ver todas as tabelas
SHOW TABLES;

-- Ver dados de clientes
SELECT * FROM clientes;

-- Ver dados de contas
SELECT * FROM contas ORDER BY saldo_conta DESC;

-- Testar depósito
CALL deposito_conta(1, 150.00);

-- Testar saque
CALL saque_conta(2, 50.00);

-- Testar transferência
CALL transferencia_conta(3, 4, 200.00);
```

---

## Parar e remover containers

```bash
docker-compose down
```

Isso irá parar e remover o container `mysql_banco_central`, mas preservará o volume de dados caso queira reiniciar depois.

---

## Contribuindo

1. Abra uma *issue* para sugerir melhorias ou relatar bugs.
2. Faça um *fork* e crie uma *branch* para sua feature.
3. Envie um *pull request* detalhando suas alterações.

---

## Licença

MIT License © 2025 Fabio
