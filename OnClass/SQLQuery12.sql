DECLARE @MaSV CHAR(10);
DECLARE @HoTen NVARCHAR(100);
DECLARE @TenMH NVARCHAR(100);

DECLARE SV_ThiLai_Cursor CURSOR FOR
SELECT DISTINCT
    S.MaSV,
    S.HoTen,
    MH.TenMH
FROM
    DIEMTHI D
JOIN
    SINHVIEN S ON D.MaSV = S.MaSV
JOIN
    MONHOC MH ON D.MaMH = MH.MaMH
WHERE
    D.Diem < 4.0 
ORDER BY
    S.MaSV, MH.TenMH;

OPEN SV_ThiLai_Cursor;

PRINT '----------------------------------------------------------------------';
PRINT N'DANH SÁCH SINH VIÊN PHẢI THI LẠI (< 4.0)';
PRINT '----------------------------------------------------------------------';
PRINT N'Mã SV | Họ Tên | Môn Học Cần Thi Lại';
PRINT '----------------------------------------------------------------------';

FETCH NEXT FROM SV_ThiLai_Cursor INTO @MaSV, @HoTen, @TenMH;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT(@MaSV, ' | ', @HoTen, N' | ', @TenMH);
    
    FETCH NEXT FROM SV_ThiLai_Cursor INTO @MaSV, @HoTen, @TenMH;
END

CLOSE SV_ThiLai_Cursor;
DEALLOCATE SV_ThiLai_Cursor;