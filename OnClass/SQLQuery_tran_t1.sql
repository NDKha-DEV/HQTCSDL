-- t1
create database trans
create table test(
	ID int primary key identity(1,1),
	Name varchar(200)
);
insert into test(Name) values ('A'),('B'),('C');
-- read committed
begin tran
	set tran isolation level read committed 
	update test set Name = 'x' where ID = 3
	waitfor delay '00:00:10'
	rollback tran
-- repeatable read ví dụ không ngăn được
begin tran
	set tran isolation level read committed 
	update test set Name = 'x' where ID = 3
	commit tran

--repeatable read
begin tran
	update test set Name = 'x' where ID = 3
	commit tran