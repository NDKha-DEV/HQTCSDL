-- câu 1:Hệ thống Chốt Đơn Hàng (Xử lý Dirty Read)
-- SESSION 2 : UNCOMMITTED
set tran isolation level read uncommitted;
select * from kho where IDSP = 1;
-- SESSION 2 : COMMITTED
set tran isolation level read committed;
select * from kho where IDSP = 1;

-- câu 2: Hệ thống Báo cáo Doanh thu (Xử lý Non-repeatable Read)
-- SESSION 2
begin tran
    update kho
    set stock = stock + 100
    where idsp = 2;
commit
-- câu 3: Hệ thống Đăng ký Mã định danh (Xử lý Phantom Read)
-- SESSION 2
delete from kho where IDSP = 4
begin tran
    insert into kho values (4, N'iPhone 17',8);
commit
