create database QuanLyGiaoDich
create table taikhoan(
	idtk int primary key identity(1,1),
	sodu decimal(18,2) default 0.0
);
-- viết 1 thủ tục để chuyển tiền giữa 2 tài khoản
drop proc if exists pr_CT;
create proc pr_CT
@id_gui char(5),
@id_nhan char(5),
@tien money 
as begin 
begin tran -- khai báo bắt đầu giao dịch
	if not exists (select * from taikhoan where idtk = @id_nhan)
	or not exists (select * from taikhoan where idtk = @id_gui)
	or (select sodu from taikhoan where idtk = @id_gui) < @tien
		begin
			print '....'
			rollback tran;
		end
	else begin
		update taikhoan 
		set sodu = sodu - @tien
		where idtk = @id_gui;
		update taikhoan
		set sodu = sodu + @tien
		where idtk = @id_nhan;
	commit tran -- ghi nhận giao dịch
	end
end

-- ACID: tính chất
 -- ATOMICITY (Nguyên tố) hoặc là tất cả thực thi thành công hoặc toàn bộ hủy bỏ (system)
 -- CONSISTENCY (Nhất quán) đảm bảo khi thực hiện giao dịch thì dữ liệu phải đúng (đảm bảo tính toàn vẹn dữ liệu) (coder)
 -- ISOLATION (Cô lập):  (coder)
 -- DURABILITY (Bền vững): sau khi lỗi thì sẽ được khôi phục dữ liệu (system)

--vd1: viết 1 thủ tục đóng gói trong giao dịch để khi thêm sv vào 1 lớp thì đảm bảo số lượng sv của 1 lớp <=70

create proc pr_themsv
@slsv int, @malop nvarchar(20)
as begin
	select @slsv = count(malop) from sinhvien where malop = @malop
	begin tran
		if @slsv >= 70
			begin
				print 'Lop da du'
				rollback tran
			end
		else
			begin
				insert into sinhvien(masv, malop) values ( 
	end
end
--vd2: viết 1 thủ tục để trả lương cho 