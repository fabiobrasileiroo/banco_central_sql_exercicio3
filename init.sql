-- exercicio 3 - bd6 
select * 
from clientes
where nome_cliente='Han Solo';

-- inicio de atv 3
-- 1 create databse  

-- desativar safe mode
set @@sql_safe_updates = 0;
select @@sql_safe_updates;

set @@autocommit = off;
select @@autocommit;

create database banco_central_fabio;
use banco_central_fabio;
create table contas(
    id_conta int auto_increment primary key,
    nome_conta varchar(100),
    saldo_conta decimal(10,2)
);

-- inserir dados pela procedure 

delimiter $$
create procedure add_conta(
    in nome_conta_value  varchar(100),
    in saldo_conta_value decimal(10,2)
)
begin
insert into contas(
    nome_conta,
    saldo_conta
) values(
    nome_conta_value,
    saldo_conta_value
);
end $$ 
delimiter ;
-- adicionando o dado de clientes fictícios
call banco_central_fabio.add_conta('Lady Gaga', 250);
call add_conta('Han Solo',      500.00);
call add_conta('Katy Perry',    800.00);
call add_conta('Bob Marley',    300.00);
call add_conta('Lady Gaga',     250.00);
call add_conta('Luke Skywalker',1200.50);
call add_conta('Leia Organa',   950.75);

-- 2 automatizando o deposito na conta
drop procedure if exists deposito_conta;
drop procedure if exists saque_conta;

delimiter $$
create procedure deposito_conta(
    in id_conta_value int,
    in valor_depositado decimal(10,2)
)
begin
declare erro_sql tinyint default false;
-- variável de controle para possíveis erros
declare continue handler for sqlexception set erro_sql = true;
start transaction;
    update contas 
        set saldo_conta = saldo_conta + valor_depositado
        where saldo_conta > 0 and id_conta = id_conta_value;
    -- possível erro para teste 
    if erro_sql = false then
        commit;
        select 'Deposito efetivado com sucesso.' as Resultado;
    else
        rollback;
        select 'Erro na Deposito' as Resultado;
    end if;
end $$
delimiter ;
-- procedimento de saque de conta
delimiter $$

create procedure saque_conta(
    in id_conta_value int,
    in valor_saque decimal(10,2)
)
begin
    declare erro_sql tinyint default false;
    declare saldo_atual decimal(10,2);

    -- Handler para erro
    declare continue handler for sqlexception set erro_sql = true;

    -- Buscar saldo atual
    select saldo_conta into saldo_atual
    from contas
    where id_conta = id_conta_value;

    -- Verificar se o saldo é suficiente
    if saldo_atual is null then
        select 'Conta não encontrada.' as Resultado;
    elseif saldo_atual < valor_saque then
        select 'Saldo insuficiente para saque.' as Resultado;
    else
        start transaction;

        update contas 
            set saldo_conta = saldo_conta - valor_saque
            where id_conta = id_conta_value;

        if erro_sql = false then
            commit;
            select 'Saque efetivado com sucesso.' as Resultado;
        else
            rollback;
            select 'Erro no saque.' as Resultado;
        end if;
    end if;
end $$

delimiter ;


-- chama rotina da procedure ( procedimento)
call deposito_conta(1, 1000.00);
call saque_conta(1, 250.50);
select * from contas;




-- 3. Transferência entre contas (fazer start da transação e executar)
-- • O cliente Katy Perry transferiu R$ 300 para Bob Marley. Faça essa operação
-- usando uma transação

drop procedure if exists transferencia_conta;

delimiter $$

create procedure transferencia_conta(
    in id_origem int,
    in id_destino int,
    in valor_transferido decimal(10,2)
)
begin
    declare erro_sql tinyint default false;
    declare saldo_origem decimal(10,2);
    declare nome_origem varchar(100);
    declare nome_destino varchar(100);

    -- Handler para erros SQL
    declare continue handler for sqlexception set erro_sql = true;

    -- Buscar saldo e nome da conta de origem
    select saldo_conta, nome_conta into saldo_origem, nome_origem
    from contas
    where id_conta = id_origem;

    -- Buscar nome da conta de destino
    select nome_conta into nome_destino -- adiocionar a variável nome_destino
    from contas
    where id_conta = id_destino;
    
    -- 4 Cancelar uma operação (fazer start da transação e recuperar) 
    
    -- Validações
    if nome_origem is null then
        select concat('Conta de origem com ID ', id_origem, ' não encontrada.') as Resultado;
    elseif nome_destino is null then
        select concat('Conta de destino com ID ', id_destino, ' não encontrada.') as Resultado;
    elseif saldo_origem < valor_transferido then
        select concat('Saldo insuficiente na conta de ', nome_origem, '.') as Resultado;
    elseif id_origem = id_destino then
        select 'Transferência para a mesma conta não é permitida.' as Resultado;
    else
        start transaction;

        -- Debita da origem
        update contas
            set saldo_conta = saldo_conta - valor_transferido
            where id_conta = id_origem;

        -- Credita na destino
        update contas
            set saldo_conta = saldo_conta + valor_transferido
            where id_conta = id_destino;

        -- Finaliza transação
        if erro_sql = false then
            commit;
            select concat('Transferência de R$ ', valor_transferido, ' realizada com sucesso de ', nome_origem, ' para ', nome_destino, '.') as Resultado;
        else
            rollback;
            select 'Erro ao realizar a transferência.' as Resultado;
        end if;
    end if;
end $$

delimiter ;

select * from contas;

call transferencia_conta(1,2, 100);


delete from contas where nome_conta = 'Bob Marley';

select * from contas
where saldo_conta > 1000
order by saldo_conta desc;

select * from contas
order by saldo_conta desc;