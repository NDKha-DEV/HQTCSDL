USE QLSV;
GO

DECLARE @HoTenSVMax NVARCHAR(100);

-- SV có DiemTB = MAX(DiemTB)
DECLARE SV_MaxDiem_Cursor CURSOR FOR
SELECT TOP 1 HoTen
FROM SINHVIEN
ORDER BY DiemTB DESC; -- Sắp xếp giảm dần và lấy 1 người đầu tiên

-- Mở con trỏ
OPEN SV_MaxDiem_Cursor;

PRINT '';
PRINT N'--- SINH VIÊN CÓ ĐIỂM TRUNG BÌNH CAO NHẤT ---';

-- Lấy dòng đầu tiên (và duy nhất)
FETCH NEXT FROM SV_MaxDiem_Cursor INTO @HoTenSVMax;

-- Lặp (chỉ chạy 1 lần nếu chỉ có 1 SV cao nhất)
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @HoTenSVMax;
    FETCH NEXT FROM SV_MaxDiem_Cursor INTO @HoTenSVMax;
END

CLOSE SV_MaxDiem_Cursor;
DEALLOCATE SV_MaxDiem_Cursor;
GO