--------------- function -------------------

--- viết 1 hàm trả về số lượng sinh viên thi qua 1 môn học bất kỳ (nếu 1 trong các lần thi điểm > 4 là thi qua)

create function func1 (@mamh nvarchar(5))
returns int as
begin
	declare @x int;
	select count(t.masv) from (
	select masv, mamh, max(diem) as DiemCaoNhat from DIEMTHI 
	group by masv, MaMH 
	having max(diem) > 4
	) as t
	where mamh = @mamh;
	return @x;
end

select dbo.func1('CSDL');

select distinct mamh, dbo.func1(mamh) as SoLuongSVQuaMon from DIEMTHI;

create function func2(@malop nvarchar(5)) 
returns table 
as return (select * from SINHVIEN where MaLop = @malop);

select * from func2('A');

---- B1: viết hàm tính độ tuổi trung bình của sinh viên trong bảng sinh viên
ALTER TABLE SinhVien ADD NgaySinh DATE;
UPDATE SinhVien SET NgaySinh = '2003-01-15' WHERE MaSV = 'SV001';
UPDATE SinhVien SET NgaySinh = '2004-03-20' WHERE MaSV = 'SV002';
UPDATE SinhVien SET NgaySinh = '2003-07-10' WHERE MaSV = 'SV003';
UPDATE SinhVien SET NgaySinh = '2004-11-05' WHERE MaSV = 'SV004';
UPDATE SinhVien SET NgaySinh = '2003-05-25' WHERE MaSV = 'SV005';
alter table sinhvien add tuoi as 
(
DATEDIFF(year, NgaySinh, GETDATE()) 
    - CASE 
        -- Trừ đi 1 năm nếu chưa đến sinh nhật
        WHEN MONTH(NgaySinh) > MONTH(GETDATE()) 
        OR (MONTH(NgaySinh) = MONTH(GETDATE()) AND DAY(NgaySinh) > DAY(GETDATE())) 
        THEN 1 
        ELSE 0 
      END
)
create function func_TinhTuoiTB()
returns decimal (5,2) as
begin
	declare @TuoiTB decimal(5,2);
	select @TuoiTB = avg(cast(tuoi as decimal(5,2)))
	from SINHVIEN 
	return @TuoiTB;
end

SELECT dbo.func_TinhTuoiTB() AS N'Độ Tuổi Trung Bình của Sinh Viên';


