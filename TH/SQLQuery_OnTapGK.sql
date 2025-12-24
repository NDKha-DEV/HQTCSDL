--create database QuanLySinhVien

-- MaSV, MaLop, MaKhoa, MaMH, SoCanBo, SoTinChi có kiểu dữ liệu số nguyên
-- NgaySinh có kiểu dữ liệu ngày tháng
-- HocBong, DiemThi có kiểu dữ liệu float
-- Các trường khác có kiểu xâu ký tự
-- Các trường MaSV, MaLop, MaKhoa, MaMH đặt thuộc tính tự tăng trưởng bắt đầu từ 1 và bướctăng là 1
-- Thiết lập ràng buộc CHECK kiểm tra giá trị nhập vào của trường giới tính chỉ có thể là 'Nam' hoặc 'Nữ'
create table Khoa(
	MaKhoa int primary key identity(1,1),
	TenKhoa nvarchar(100) not null,
	SoCanBo int
);
create table Lop(
	MaLop int primary key identity(1,1) ,
	TenLop nvarchar(50) not null,
	MaKhoa int not null,
	constraint FK_Lop_Khoa foreign key (MaKhoa) references Khoa(MaKhoa)
);
create table SinhVien(
	MaSV int primary key identity(1,1),
	HoTen nvarchar(100) not null,
	GioiTinh nvarchar(20) not null,
	NgaySinh Date ,
	MaLop int not null,
	HocBong float,
	Tinh nvarchar(50),
	constraint FK_SinhVien_Lop foreign key (MaLop) references Lop(MaLop),
	constraint CHK_SV_GioiTinh check (GioiTinh in (N'Nam',N'Nữ'))
);
create table MonHoc(
	MaMH int primary key identity(1,1),
	TenMH nvarchar(50) not null,
	SoTinChi int not null
);
create table KetQua(
	MaSV int not null,
	MaMH int not null,
	DiemThi float
	constraint FK_KetQua_SinhVien foreign key (MaSV) references SinhVien(MaSV),
	constraint FK_KetQua_MonHoc foreign key (MaMH) references MonHoc(MaMH)
);
alter table KetQua add constraint PK_KetQua primary key (MaSV,MaMH);
-- thêm dữ liệu
INSERT INTO Khoa (TenKhoa, SoCanBo) VALUES
(N'Công nghệ Thông tin', 35),
(N'Kinh tế', 40),
(N'Ngoại ngữ', 25);
INSERT INTO Lop (TenLop, MaKhoa) VALUES
(N'CNTT01', 1), -- Khoa CNTT
(N'KT02', 2),    -- Khoa Kinh tế
(N'NN01', 3),    -- Khoa Ngoại ngữ
(N'CNTT02', 1);  -- Khoa CNTT
INSERT INTO SinhVien (HoTen, GioiTinh, NgaySinh, MaLop, HocBong, Tinh) VALUES
(N'Nguyễn Văn A', N'Nam', '2003-01-15', 1, 200000.00, N'Hà Nội'), -- Lớp CNTT01
(N'Lê Thị B', N'Nữ', '2002-05-20', 2, 350000.00, N'Hải Phòng'),    -- Lớp KT02
(N'Trần Văn C', N'Nam', '2003-11-10', 1, NULL, N'Đà Nẵng'),        -- Lớp CNTT01
(N'Phạm Thị D', N'Nữ', '2004-03-25', 3, 200000.00, N'Hồ Chí Minh');-- Lớp NN01
INSERT INTO MonHoc (TenMH, SoTinChi) VALUES
(N'Cơ sở Dữ liệu', 3),
(N'Tiếng Anh 1', 2),
(N'Lập trình C', 4),
(N'Kinh tế Vi mô', 3);
INSERT INTO KetQua (MaSV, MaMH, DiemThi) VALUES
(1, 1, 8.5), -- SV A, MH CSDL
(1, 3, 7.0), -- SV A, MH Lập trình C
(2, 2, 9.0), -- SV B, MH Tiếng Anh 1
(2, 4, 6.5), -- SV B, MH Kinh tế Vi mô
(3, 1, 5.5); -- SV C, MH CSDL

select MaSV, HoTen, datediff(yy, NgaySinh, getdate()),datediff(mm, NgaySinh, getdate())/12 
from SinhVien

declare @SoLuongChuyen int;
update SinhVien
set MaLop = (Select MaLop from Lop where TenLop = N'57TH04')
where MaLop = (Select MaLop from Lop where TenLop = N'57TH03')
	and HoTen Like N'%Anh%';
set @SoLuongChuyen = @@ROWCOUNT; 
print    N'Có ' + CAST(@SoLuongChuyen AS NVARCHAR) + N' bạn chuyển từ lớp 57TH03 sang lớp 57TH04' ;
select * from SinhVien
-- thủ tục lưu trữ hiển thị danh sách sinh viên của 1 lớp nào đó
drop proc if exists pr_showlistsv
create proc pr_showlistsv
	@TenLop nvarchar(50)
as begin
	select sv.MaSV,sv.HoTen,sv.GioiTinh,sv.NgaySinh,l.TenLop,sv.Tinh
	from SinhVien sv
	join Lop l on sv.MaLop = l.MaLop
	where l.TenLop = @TenLop;
end
-- Thủ tục đếm sinh viên theo khoa
drop proc if exists pr_DemSVTheoKhoa
create proc pr_DemSVTheoKhoa
	@TenKhoa nvarchar(100),
	@TongSoSV int out
as begin
	select @TongSoSV = count(sv.MaSV)
	from Khoa k
	join Lop l on k.MaKhoa = l.MaKhoa
	join SinhVien sv on l.MaLop = sv.MaLop
	where k.TenKhoa = @TenKhoa;
end
declare @SoSV int;
exec pr_DemSVTheoKhoa N'Công nghệ Thông tin', @TongSoSV = @SoSV out;
print N'khoa cntt có: '+ cast(@SoSV as nvarchar);
select * from Khoa
-- hàm trả về điểm tb của 1 sv
drop function if exists func_DTB
create function func_DTB(@MaSV int)
returns float 
as begin
	declare @DiemTB float;
	select @DiemTB =  sum(kq.DiemThi * mh.SoTinChi) / cast(sum(mh.SoTinChi) as float )
	from KetQua kq
	join MonHoc mh on KQ.MaMh = mh.MaMH
	where kq.MaSV = @MaSV;
	return isnull(@DiemTB,0.0);
end
DECLARE @MaSVCanTinh INT = 1;
SELECT
    SV.HoTen AS N'Họ Tên Sinh Viên',
    dbo.func_DTB(@MaSVCanTinh) AS N'Điểm Trung Bình'
FROM
    SinhVien SV
WHERE
    SV.MaSV = @MaSVCanTinh;
select HoTen,dbo.func_DTB(1) as 'DTB'
from SinhVien 
where MaSV = 1;
select * from KetQua
-- thủ tục hiển thị danh sách sinh viên dưới dạng con trỏ
create proc pr_DSSV_cur
	@cur_DSSV cursor varying out
as begin
	set @cur_DSSV = cursor for	
	select sv.MaSV, sv.HoTen, sv.Tinh, dbo.func_DTB(sv.MaSV) as DTB
	from SinhVien sv
	order by sv.MaSV
	open @cur_DSSV;
end
declare @y cursor
declare @MaSV int
declare @HoTen nvarchar(100)
declare @Tinh nvarchar(100)
declare @DTB float
exec pr_DSSV_cur @cur_DSSV = @y out;
fetch next from @y into @MaSV,@HoTen,@Tinh,@DTB
while @@FETCH_STATUS = 0
begin
	if @DTB >= 8.0
	begin
		update SinhVien
		set HocBong = 200000.00
		where MaSV = @MaSV;
		print '>8.0';
	end
	else if @DTB >= 8.0 and @Tinh != N'Hà Nội'
	begin
		update SinhVien
		set HocBong = 300000.00
		where MaSV = @MaSV;
		print '>8.0 and != HN';
	end
	else
	begin
		update SinhVien
		set HocBong = 00000.00
		where MaSV = @MaSV;
		print '>8.0 and != HN';
	end
	fetch next from @y into @MaSV,@HoTen,@Tinh,@DTB
end
close @y;
deallocate @y;
-- Hàm 18
CREATE FUNCTION FN_DanhSachSVTheoKhoa
(
    @TenKhoa NVARCHAR(100) -- Tham số đầu vào: Tên Khoa
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        SV.MaSV,
        SV.HoTen,
        SV.NgaySinh,
        L.TenLop
    FROM
        Khoa K
    INNER JOIN
        Lop L ON K.MaKhoa = L.MaKhoa
    INNER JOIN
        SinhVien SV ON L.MaLop = SV.MaLop
    WHERE
        K.TenKhoa = @TenKhoa
);
GO

-- Ví dụ gọi hàm:
SELECT * FROM dbo.FN_DanhSachSVTheoKhoa(N'Công nghệ thông tin');
-- view
CREATE VIEW VW_SinhVienChiTietDiemTB
AS
SELECT
    K.MaKhoa,
    K.TenKhoa,
    K.SoCanBo,
    L.MaLop,
    L.TenLop,
    SV.MaSV,
    SV.HoTen AS TenSV,
    -- Gọi hàm tính điểm trung bình
    dbo.FN_TinhDiemTrungBinh(SV.MaSV) AS DiemTB
FROM
    Khoa K
INNER JOIN
    Lop L ON K.MaKhoa = L.MaKhoa
INNER JOIN
    SinhVien SV ON L.MaLop = SV.MaLop;
GO

-- Ví dụ gọi View:
SELECT * FROM VW_SinhVienChiTietDiemTB;
-- tính dtb
SELECT
    TenSV AS N'Tên Sinh Viên',
    TenLop AS N'Tên Lớp',
    DiemTB AS N'Điểm Trung Bình (Hệ 10)'
FROM
    VW_SinhVienChiTietDiemTB
WHERE
    TenKhoa = N'Công nghệ thông tin'
ORDER BY
    DiemTB DESC;