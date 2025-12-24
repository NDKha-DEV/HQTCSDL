create database TH5
CREATE TABLE KHO (
    IDSP INT PRIMARY KEY,
    TenSP NVARCHAR(50),
    Stock INT
);
INSERT INTO KHO VALUES (1, N'iPhone 15', 10);
INSERT INTO KHO VALUES (2, N'Samsung S23', 20);

-- câu 1:Hệ thống Chốt Đơn Hàng (Xử lý Dirty Read)
-- SESSION 1
set transaction isolation level read committed;
begin tran
    update kho
    set Stock = 0
    where IDSP = 1;
    waitfor delay '00:00:10';
    rollback;

-- câu 2: Hệ thống Báo cáo Doanh thu (Xử lý Non-repeatable Read)
-- SESSION 1 : committed
set transaction isolation level read committed;
begin tran
    select sum(Stock) as TongLan1 from kho;
    waitfor delay '00:00:10';
    select sum(Stock) as TongLan2 from kho;
commit
-- SESSION 1 : repeatable read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION
    SELECT SUM(Stock) AS TongLan1 FROM KHO;

    WAITFOR DELAY '00:00:10';

    SELECT SUM(Stock) AS TongLan2 FROM KHO;
COMMIT;
set transaction isolation level repeatable read;
begin tran
    select sum(Stock) as TongLan1 from kho;
    waitfor delay '00:00:10';
    select sum(Stock) as TongLan2 from kho;
commit
-- câu 3: Hệ thống Đăng ký Mã định danh (Xử lý Phantom Read)
-- SESSION 1
set transaction isolation level repeatable read;
begin tran
    if not exists (
        select 1 from kho where TenSP = N'iPhone 16'
    )
    begin
        waitfor delay '00:00:10';
        insert into kho values (3, N'iPhone 16',5);
    end
commit;
-- SESSION 1 isolation
set tran isolation level serializable;
begin tran
    if not exists(
        select 1 from kho where TenSP = N'iPhone 17'
    )
    begin
        waitfor delay '00:00:10';
        insert into kho values (5, N'iPhone 17',5);
    end
commit;
select * from kho

-- câu 4: Viết lại thủ tục chuyển tiền, 
--chọn mức độ cô lập phù hợp nhất để đảm bảo tính toàn vẹn cho dữ liệu trong mô trường đa người dùng
CREATE TABLE TaiKhoan (
    AccountID INT PRIMARY KEY,
    TenChuTK NVARCHAR(100),
    Balance MONEY CHECK (Balance >= 0)
);
INSERT INTO TaiKhoan VALUES (1, N'Nguyễn Văn A', 1000000);
INSERT INTO TaiKhoan VALUES (2, N'Trần Thị B', 500000);
INSERT INTO TaiKhoan VALUES (3, N'Lê Văn C', 200000);

drop proc if exists sp_ChuyenTien
create proc sp_ChuyenTien
    @tkc int,
    @tkn int,
    @sotien money
as begin
    set tran isolation level serializable;
    begin tran
        declare @sodu money;
        select @sodu = balance
        from taikhoan
        where accountID = @tkc;
        if @sodu < @sotien
        begin
            rollback tran
            print N'khong du so du';
            return
        end
        update taikhoan
        set balance = balance - @sotien
        where accountID = @tkc;
        update taikhoan
        set balance = balance + @sotien
        where accountID = @tkn;
    commit
end

exec sp_ChuyenTien 1,2,500000;


