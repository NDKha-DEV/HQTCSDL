-- viết 1 trigger để khi thêm 1 lớp mới vào thì trigger sẽ được kích hoạt để print ra 'Bạn đã thêm lớp thành công'
create trigger trigger_themlop
on Lop for insert
as print N'Bạn đã thêm lớp thành công'

create table Lop(
	MaLop varchar(10) primary key not null,
	TenLop nvarchar(50) not null
)
insert into Lop values
('A',N'Lớp A'),
('B',N'Lớp B'),
('C',N'Lớp C');
insert into Lop values ('E',N'lớp E');
drop trigger if exists trigger_xoalop 
create trigger trigger_xoalop
on lop for delete
as print N'Bạn đã xóa lớp thành công'
create trigger trigger_capnhatlop
on lop for update
as print N'Bạn đã cập nhật lớp thành công'

update lop set TenLop = 'Lop A' where MaLop = 'A';
delete from lop where MaLop = 'D';


alter trigger trigger_themlop 
on lop for insert
as 
begin
	declare @x varchar(10);
	declare cur_themlop cursor for
	select MaLop from inserted
	open cur_themlop;
	fetch next from cur_themlop into @x;
	while @@FETCH_STATUS = 0
	begin
		print 'Ban da them lop ' + @x + ' thanh cong'
		fetch next from cur_themlop into @x;
	end
	close cur_themlop;
	deallocate cur_themlop;
end
select * from Lop
delete from Lop where MaLop = 'G'
delete from Lop where MaLop = 'H'
delete from Lop where MaLop = 'K'
insert into Lop values
('G',N'Lớp G'),
('H',N'Lớp H'),
('K',N'Lớp K');

-- viết trigger để gộp 3 insert,update,delete và thông báo riêng từng cái
create trigger trig_x
on lop for insert,update,delete
as
begin
	IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        PRINT 'SUCCESS: Da them lop moi thanh cong!';
    END
    
    -- 2. UPDATE
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        -- Chỉ thông báo nếu có dữ liệu thực sự thay đổi (tùy chọn)
        IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON i.malop = d.malop AND i.tenlop <> d.tenlop)
        BEGIN
            PRINT 'SUCCESS: Da cap nhat lop thanh cong!';
        END
        ELSE
        BEGIN
            PRINT 'INFO: Cap nhat du lieu lop nhung khong co thay doi!';
        END
    END
    
    -- 3. DELETE
    ELSE IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        PRINT 'SUCCESS: Da xoa lop thanh cong!';
    END
end

-- viết 1 trigger đảm bảo rằng khi sửa đổi dữ liệu thì số lượng sinh viên trong 1 lớp luôn <= 80
drop trigger if exists trig_update
create trigger trig_update
on sinhvien for insert , update 
as 
begin
    --declare @x int;
    --select @x = count(MaSV) from sinhvien where MaLop = (select MaLop from inserted)
    --if @x > 3
    --begin
     --   print N'Không được quá <= 80'
      --  rollback transaction
    --end
    if exists(
    select 1 
    from inserted i
    join (
    select s.MaLop, count(s.MaSV) as soluongsv
    from sinhvien s
    where s.MaLop in (select distinct MaLop from inserted)
    group by s.MaLop
    ) as t on i.MaLop = t.MaLop
    where t.soluongsv > 80 
    )
    begin 
        print N'khong duoc vi pham';
        rollback transaction
        return;
    end
end

insert into sinhvien(MaSV,HoTen,DiemTB,MaLop) values ('SV008',N'Nguyễn Đình A',9,'A');
update sinhvien set MaLop = 'C'
where MaSV = 'SV007'
-- viết 1 trigger để tự động tính cập nhật giá trị của cột điểm tk khi có sự thay đổi về điểm của sv đ
drop trigger if 