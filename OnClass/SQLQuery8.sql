-- Bài 1: sử dụng con trỏ để in ra danh sách sinh viên đạt học bổng
-- nếu điểm trung bình lần 1 >=8.5 và <=9 thì đạt 1 triệu
-- nếu điểm trung bình lần 1 >9 thì sv đạt học bổng 2 triệu

DECLARE cursor_dtb CURSOR
DYNAMIC SCROLL
FOR
	SELECT SV.Masv, (SV.Hosv + ' ' + SV.Tensv), AVG(D.Diem) as diemtb 
	from SINHVIEN SV, DIEMSV D where SV.Masv = D.Masv and D.Lan = '1' group by SV.Masv, SV.Hosv, SV.Tensv Having AVG(D.Diem) >=8.5;

Open cursor_dtb;
DECLARE @MaSV char(10), @HoTen nvarchar(50), @DiemTB float;
FETCH NEXT FROM cursor_dtb INTO @MaSV, @HoTen, @DiemTB;

PRINT N'Danh sách sinh viên đạt học bổng:';
WHILE @@FETCH_STATUS = 0
BEGIN
	if(@DiemTB>=8.5 AND @DiemTB<=9)
		print N'Sinh viên ' + @Hoten + N' đạt học bổng 1 triệu';
	else if (@DiemTB > 9)
		print N'Sinh viên ' + @Hoten + N' đạt học bổng 2 triệu';

	FETCH NEXT FROM cursor_dtb INTO @MaSV, @HoTen, @DiemTB;
END
CLOSE cursor_dtb;
DEALLOCATE cursor_dtb;