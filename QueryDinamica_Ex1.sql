Create Database QueryDinamica_Ex1
go
use QueryDinamica_Ex1
go
Create table Produto(
codigo int not null,
nome varchar(100) not null,
valor decimal(7,2) not null,
Primary Key(codigo)
)
go
Create table Entrada (
codigo_transacao int not null,
codigo_produto int not null,
quantidade int not null,
valor_total decimal(7,2) not null
Primary key(codigo_transacao)
Foreign Key (codigo_produto) References Produto(codigo)
)
go
Create table saida (
codigo_transacao int not null,
codigo_produto int not null,
quantidade int not null,
valor_total decimal(7,2) not null
Primary key(codigo_transacao)
Foreign Key (codigo_produto) References Produto(codigo)
)
go

-- Procedure
Create procedure sp_insereTransacao @op char(1),@codigoTransacao int , @codigoProduto int, @quantidade int, @saida varchar(100) output
As

Declare @query varchar(200),
		@tabela varchar(20),
		@valorUnitario decimal(7,2),
		@valorTotal decimal(7,2),
		@cod int

set @cod = (select codigo from Produto where codigo = @codigoProduto)
If(@cod is null) begin
	Raiserror('Produto inexistente',16,1)
end
Else Begin
	set @valorUnitario = (select valor from Produto where codigo = @codigoProduto)
	set @valorTotal = @valorUnitario * @quantidade

If (@op = 'e') Begin
	set @tabela = 'Entrada'
End
Else Begin
	set @tabela = 'Saida'
End

If(@op = 'e' or @op = 's') Begin
Begin Try
	set @query = 'Insert Into ' + @tabela +' Values (' +CAST(@codigoTransacao as varchar(5)) + ',' + 
	CAST(@codigoProduto as varchar(5)) + ',' + CAST(@quantidade as varchar(5)) + ',' + CAST(@valorTotal as varchar(10)) + ')'
	print @query
	exec (@query)
	set @saida = 'Transacao inserida com sucesso'
End Try
Begin Catch
	declare @erro varchar(200)
	set @erro = ERROR_MESSAGE()

	if(@erro like '%primary%') Begin
		set @erro = 'Codigo da transacao duplicada'
	End
	if(@erro like '%FK%') Begin
		set @erro = 'Erro no codigo do produto'
	End
	RaisError(@erro, 16, 1)
End Catch
End 
Else begin
	RaisError('Operacao Invalida', 16, 1)
End
End

go
-- Inserido Produto
INSERT INTO produto (codigo, nome, valor)
VALUES
    (1, 'Camiseta', 29.99),
    (2, 'Calça Jeans', 49.90),
    (3, 'Tênis', 79.99),
    (4, 'Moletom', 39.99);

go
-- teste
Declare @out varchar(100)
Exec sp_insereTransacao 's', 2,4,4, @out output
print @out

Select * from saida
Select * from entrada

Insert into saida Values(5,7,1,20)
