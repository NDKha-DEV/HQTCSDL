------------------------------- View --------------------------------------
--- Khung nhìn(view) là:
--- đối tượng thuộc CSDL
--- là 1 bảng ảo có cấu trúc như 1 bảng: bao gồm dòng và cột
--- Khung nhìn không lưu trữ dữ liệu mà chỉ giúp quan sát dữ liệu được truy vấn từ các bảng thông qua câu lệnh truy vấn dữ liệu SELECT
--- Người dùng có thể áp dụng ngôn ngữ thao tác dữ liệu trên các View giống như trên các Table
--- cú pháp: 
-- CREATE VIEW tên_khung_nhìn [danh sách tên cột]
-- AS
-- Câu_lệnh_SELECT

-- sử dụng view lấy ra sinh viên nào học môn học nào (đưa ra tên sinh viên, tên môn học)
drop view if exists V1;
create view V1
as
select sv.MaSV,sv.TenSV, mh.TenMH 
from SINHVIEN sv
join KETQUA dt on sv.MaSV = dt.MaSV 
join MONHOC mh on dt.MaMH = mh.MaMH

select * from V1

INSERT INTO V1 (MaSV, TenSV)
values ('SV006',N'Nguyễn Thu F');

delete from V1 where MaSV = 'SV006';

drop view if exists ViewSinhVien;
create view ViewSinhVien(MaSV, HoTen, Tuoi)
as 
select MaSV, TenSV, DATEDIFF(yyyy, NgaySinh, getDate()) 
from SINHVIEN

select * from ViewSinhVien;

--- Câu 1: Tạo view chứa danh sách các sv thi qua tất cả các môn ở ngay lần 1 sử dụng view trên để lấy ra sv thi qua tất cả 
--- các môn ở ngay lần 1. sử dụng view trên để lấy ra ds sv thi qua tất cả các môn ở ngay lần 1 của lớp 'TH1'
alter table KetQua add column Lan;
drop view if exists ;
create view View_DSSV
as
	select sv.MaSV, sv.TenSV
	from SinhVien sv
	join KetQua kq on sv.MaSV = kq.MaSV
	where kq.DiemSo > 4 and kq.Lan = '1' and sv.MaLop = 'TH1'
	group by sv.MaSV,sv.TenSV
	having count(kq.MaMH) = (select count(*) from KetQua where kq.MaSV = sv.MaSV);

	select * from View_DSSV;

--- Câu 2: Viết 1 view để lấy ra danh sách sv được thi tôt nghiệp(tuổi <=25, điểm tb của các lần thi cao nhất >=6.5)
--- view gồm msv, họ tên, tuổi, điểm tb.
create view dssvTN
as
	select sv.MaSV, sv.TenSV, year(sv.NgaySinh) as tuoi, t.avgd
	from SinhVien sv
	join (select t1.MaSV, avg(t1.tbmax) as avgd from
	(select MaSV, max(KetQua.DiemSo) as tbmax
	from KetQua group by MaSV) as t1
	group by t1.MaSV) as t
	on t.MaSV = sv.MaSV 
	where year(sv.NgaySinh) <= 25 and t.avgd >= 6.5
	
select * from dssvTN;
--- sử dụng view trên để lấy ra ds sv được làm tốt nghiệp của lớp 'TH1'
--- Câu 3: Viết 1 view để lấy ra ds sv nhận học bổng của LVK của mỗi khoa. Mỗi khoa 2 sv đạt DTB thi lần 1 cao nhất
create view 
