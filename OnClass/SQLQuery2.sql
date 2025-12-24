USE QLSV;
GO

DECLARE @HoTen NVARCHAR(100);


--  tất cả SV có DiemTB > 8
DECLARE SV_DiemCao_Cursor CURSOR FOR
SELECT HoTen
FROM SINHVIEN
WHERE DiemTB > 8.0;

OPEN SV_DiemCao_Cursor;

PRINT '--- DANH SÁCH SINH VIÊN CÓ ĐIỂM TRUNG BÌNH > 8 ---';

-- Lấy dòng đầu tiên
FETCH NEXT FROM SV_DiemCao_Cursor INTO @HoTen;

-- Lặp qua các dòng cho đến khi hết
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @HoTen;
    -- Lấy dòng tiếp theo
    FETCH NEXT FROM SV_DiemCao_Cursor INTO @HoTen;
END

-- Đóng và giải phóng con trỏ
CLOSE SV_DiemCao_Cursor;
DEALLOCATE SV_DiemCao_Cursor;
GO