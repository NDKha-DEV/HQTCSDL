-- THỦ TỤC -- 
-- viết để có thể sử dụng lại nhiều lần
-- vd1: tạo 1 thủ tục 
create proc PR1
as begin
select HoTen from SINHVIEN
end

-- thực thi thủ tục
EXEC PR1;

-- vd2: PROC có INPUT hiển thị học tên sinh viên của 1 lớp bất kỳ
alter table SINHVIEN add MaLop varchar(10)
create proc pr2
@MaLop varchar(5)
as begin
if exists (select * from SINHVIEN where MaLop = @MaLop)
select HoTen from SINHVIEN
where MaLop = @MaLop;
else print 'ko co lop do';
end
exec pr2 @MaLop = 'TH1';

-- viết thủ tục danh sách điểm thi của 1 lớp trong 1 môn học
create proc PR3
@MaLop varchar(10), @MaMH varchar(10)
as begin
if exists (select sv.MaSV,sv.HoTen,Diem from SINHVIEN sv, DIEMTHI dt where sv.MaSV= dt.MaSV and MaLop = @MaLop and MaMH = @MaMH)
select sv.MaSV,sv.HoTen,Diem from SINHVIEN sv, DIEMTHI dt where sv.MaSV= dt.MaSV and MaLop = @MaLop and MaMH = @MaMH
else print 'K co lop do'
end
exec pr3 @MaLop = 'A', @MaMH = 'CSDL';

-- Trả về số lượng sinh viên của 1 lớp
-- @y là thủ tục trả về output
create proc pr4
@x varchar(10), @y int out
as begin
select @y = count(MaSV) from SINHVIEN where MaLop = @x;
end
-- thuc thi-- khai báo biến trung gian để chứa y khi nó ra khỏi thực thi
declare @SoSV int;
exec pr4 'A', @SoSV out;
print @SoSV;

select MaLop from SINHVIEN
group by MaLop having count (MaSV) >= @SoSV;

-- thủ tục có output là con trỏ
-- trả về 1 con trỏ chứa họ tên sv của 1 lớp bất kỳ
create proc pr5
@MaLop varchar(10),
@y cursor varying out
as begin
set @y = cursor
for select HoTen from SINHVIEN 
where MaLop = @MaLop;
open @y;
end;
--
declare @MyCur cursor 
exec pr5 'A', @y = @MyCur out

--declare @HoTen nvarchar(50);
fetch next from @MyCur
while @@FETCH_STATUS = 0
fetch next from @MyCur
close @MyCur
deallocate @MyCur

-- viết thủ tục trả về con trỏ cho biết số lượng sinh viên thi lại của mỗi môn học
-- ( điểm nhỏ hơn 4 trong tất cả các lần thi) sử dụng kết quả trả về để in ra những môn học có số sv thi lại nhiều nhất
create proc pr6
@x cursor varying out
as begin
set @x = cursor for
	select mh.MaMH,mh.TenMH, count(distinct dt.MaSV) as SSVTL from MONHOC mh
	join DIEMTHI dt on mh.MaMH = dt.MaMH
	group by mh.MaMH,mh.TenMH
	having min(dt.Diem) < 4 and max(dt.Diem) < 4;
open @x;
end
--
declare @y cursor 
declare @MaMH nvarchar(10), @TenMH nvarchar(50), @SoSV int;

exec pr6 @x = @y out;

declare @MaxSSVTL int = -1;
declare @Mon nvarchar(50) = N'';

fetch next from @y into @MaMH,@TenMH,@SoSV;
while @@FETCH_STATUS = 0
begin
	print N'Môn: ' + @TenMH + N' So sv thi lai: ' + convert(nvarchar(20),@SoSV);
	if @SoSV > @MaxSSVTL
	begin 
		set @MaxSSVTL = @SoSV;
		set @Mon = @TenMH;
	end
fetch next from @y into @MaMH,@TenMH,@SoSV;
end
close @y;
deallocate @y;

print N'Mon co so sv thi lai nhieu nhat: ' + @Mon + N' (' + convert(nvarchar(20),@SoSV) + N' sinh viên)';
close @y;
deallocate @y;

-----------------------------------------------------------1/12/2025------------------------------------------
---- viết thủ tục trả về con trỏ danh sách sinh viên bị cảnh báo học tập của mỗi lớp nếu avg < 4 (avg được tính từ điểm thi cao nhất trong số các lần thi)
create proc pr7
@x cursor varying out
as begin 
set @x = cursor for 
	select sv.MaSV, sv.HoTen, sv.MaLop , avg(t.DiemCaoNhat) as DiemTB, N'Canh bao hoc tap' as NhanXet from SINHVIEN sv
	join (
	select dt.MaSV, dt.MaMH, max(dt.Diem) as DiemCaoNhat from DIEMTHI dt
	group by dt.MaSV, dt.MaMH
	) as t on sv.MaSV = t.MaSV 
	group by sv.MaSV, sv.HoTen, sv.MaLop
	having avg(t.DiemCaoNhat) < 4.0
	order by sv.MaLop, DiemTB DESC
	open @x;
end

declare @y cursor;

declare @Masv nvarchar(10), @Hoten nvarchar(10),@Malop nvarchar(10), @DiemTB decimal (4,2), @Nhanxet nvarchar(50);

exec pr7 @x = @y output;

fetch next from @y into @Masv, @Hoten,@Malop , @DiemTB, @Nhanxet;
while @@FETCH_STATUS = 0
begin 
	print N'Mã sinh viên: ' + @Masv;
	print N'Họ tên: ' + @Hoten;
	print N'Mã lớp: ' + @Malop;
	print N'Điểm TB: ' + convert(nvarchar(10),@DiemTB);
	print N'Nhận xét: ' + @Nhanxet;

	fetch next from @y into @Masv, @Hoten,@Malop, @DiemTB, @Nhanxet;
end

close @y;
deallocate @y;


