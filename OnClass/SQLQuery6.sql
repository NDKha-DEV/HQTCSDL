-- sử dụng con trỏ để in ra danh sách sinhv iên đạt học bổng nếu điểm trung bình lần 1 >= 8.5 và <=9 in ra sinh viên đạt học
-- bổng 1 triệu nếu >9 thì sinh viên đạt học bổng 2 triệu ... họ tên ...
-- thêm trường điểm tổng kết và sử dụng con trỏ để in ra (điểm tổng kết = avg(điểm thi cao nhất trong các lần thi))
-- sử dụng con trỏ để in ra sinh viên nào thi lại môn học nào (thi lại nếu điểm các lần thi < 4)

DECLARE @MaSV VARCHAR(10)
DECLARE @HoTen NVARCHAR(100);
DECLARE @DiemTB FLOAT;
DECLARE @HocBong NVARCHAR(200); 

DECLARE SV_HocBong_Cursor CURSOR FOR
SELECT sv.MaSV,sv.HoTen, avg(d.Diem) as dtb
FROM SINHVIEN sv, DIEMTHI d
WHERE sv.MaSV = d.MaSV and d.LanThi= '1'
GROUP BY sv.MaSV,sv.HoTen
ORDER BY dtb DESC;


OPEN SV_HocBong_Cursor;

PRINT '------------------------------------------------';
PRINT N'BẢNG XÉT DUYỆT HỌC BỔNG';
PRINT '------------------------------------------------';
PRINT N'HỌ TÊN | ĐIỂM TRUNG BÌNH | MỨC HỌC BỔNG';
PRINT '------------------------------------------------';

FETCH NEXT FROM SV_HocBong_Cursor INTO @MaSV,@HoTen, @DiemTB;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @HocBong = N'Không Đạt'; 
    
    IF @DiemTB > 9.0
    BEGIN
        SET @HocBong = N'Học bổng 2 Triệu ';
    END
    ELSE IF @DiemTB >= 8.5 AND @DiemTB <= 9.0
    BEGIN
        SET @HocBong = N'Học bổng 1 Triệu ';
    END
    ELSE
    BEGIN
        SET @HocBong = N'Không Đạt Học Bổng';
    END

    PRINT CONCAT(@HoTen, N' | ', CAST(Round(@DiemTB,2) AS VARCHAR(10)), N' | ', @HocBong);
    
    FETCH NEXT FROM SV_HocBong_Cursor INTO @MaSV,@HoTen, @DiemTB;
END

CLOSE SV_HocBong_Cursor;
DEALLOCATE SV_HocBong_Cursor;

--ALTER TABLE SINHVIEN
--ADD DTK FLOAT;

DECLARE @DiemTongKet float;

DECLARE SV_TongKet_Cursor CURSOR FOR
SELECT MaSV, HoTen
FROM SINHVIEN
ORDER BY MaSV;

OPEN SV_TongKet_Cursor;

PRINT '------------------------------------------------';
PRINT N'DANH SÁCH ĐIỂM TỔNG KẾT (AVG của MAX điểm từng môn)';
PRINT '------------------------------------------------';
PRINT N'Mã SV | Họ Tên | Điểm Tổng Kết';
PRINT '------------------------------------------------';

FETCH NEXT FROM SV_TongKet_Cursor INTO @MaSV, @HoTen;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @DiemTongKet = AVG(T.MaxDiem)
    FROM (
        SELECT MAX(Diem) AS MaxDiem
        FROM DIEMTHI
        WHERE MaSV = @MaSV
        GROUP BY MaMH
    ) AS T;

    PRINT CONCAT(@MaSV, ' | ', @HoTen, N' | ', CAST(ROUND(@DiemTongKet, 2) AS VARCHAR(10)));
    
    --UPDATE SINHVIEN
    --SET DTK = @DiemTongKet
    --WHERE MaSV = @MaSV;

    FETCH NEXT FROM SV_TongKet_Cursor INTO @MaSV, @HoTen;
END

CLOSE SV_TongKet_Cursor;
DEALLOCATE SV_TongKet_Cursor; 

INSERT INTO DIEMTHI (MaSV, MaMH, LanThi, Diem) VALUES
('SV003', 'CSDL', 1, 3.5),  
('SV005', 'LTW', 1, 3.8),   
('SV005', 'LTW', 2, 4.5);