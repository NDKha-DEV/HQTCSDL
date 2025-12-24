-- uncommitted 
-- read committed ngăn chặn được load update nhưng không ngăn được
-- repeattable read 
--t2
-- read committed
begin tran
	set tran isolation level read committed 
	select * from test
	commit tran
-- repeatable read ví dụ không ngăn được
begin tran
set tran isolation level read committed 
	select * from test
	waitfor delay '00:00:10'
	select * from test
	commit tran
-- repeatable read -ngăn không cho vào cho đến khi xong
begin tran
	set tran isolation level repeatable read
	select * from test
	waitfor delay '00:00:10'
	select * from test
	commit tran