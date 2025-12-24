-------------------------------------------------------------------------------
-- 6) Câu 2.a: Cập nhật ThanhTien cho SP_DonHang = SoLuong * DonGia (dùng JOIN)
-------------------------------------------------------------------------------
UPDATE sd
SET sd.ThanhTien = sd.SoLuong * sp.DonGia
FROM SP_DonHang sd
JOIN SanPham sp ON sd.IDSanPham = sp.IdSanPham;
GO

-- Kiểm tra
SELECT * FROM SP_DonHang;


-------------------------------------------------------------------------------
-- 6b) Cập nhật TongTien trong DonHang = SUM(ThanhTien) theo từng đơn
-------------------------------------------------------------------------------
UPDATE dh
SET dh.TongTien = ISNULL(t.TotalThanhTien,0)
FROM DonHang dh
LEFT JOIN (
    SELECT IDDonHang, SUM(ThanhTien) AS TotalThanhTien
    FROM SP_DonHang
    GROUP BY IDDonHang
) t ON dh.IDDonHang = t.IDDonHang;


-- Kiểm tra
SELECT * FROM DonHang;


-------------------------------------------------------------------------------
-- 6c) Trích ra phần tên khách hàng từ trường HoTen
-- Cách phổ biến: lấy token cuối sau dấu cách (tên gọi)
-------------------------------------------------------------------------------
-- Ví dụ trích phần tên (tên gọi cuối cùng) cho tất cả khách hàng
SELECT IDKhachHang, HoTen,
       -- Lấy phần sau khoảng trắng cuối cùng
       RIGHT(HoTen, CHARINDEX(' ', REVERSE(HoTen)) - 1) AS Ten
FROM KhachHang;


-- Nếu muốn xử lý trường hợp không có khoảng trắng (1 tên), dùng COALESCE:
SELECT IDKhachHang, HoTen,
       CASE
         WHEN CHARINDEX(' ', HoTen) = 0 THEN HoTen
         ELSE RIGHT(HoTen, CHARINDEX(' ', REVERSE(HoTen)) - 1)
       END AS Ten
FROM KhachHang;


-------------------------------------------------------------------------------
-- 6d) Sử dụng con trỏ để in ra thông tin các đơn hàng (IDDonHang, NgayDatHang, TongTien)
-- của khách hàng có tên là 'Nguyễn Văn A'
-------------------------------------------------------------------------------
DECLARE @KH_ID INT;

-- Lấy IDKhachHang của khách 'Nguyễn Văn A' (nếu có nhiều, lấy tất cả theo cursor sau)
-- Ở đây giả sử tên chính xác 'Nguyễn Văn A'
-- Nếu có nhiều khách cùng tên, ta sẽ lặp qua từng ID
DECLARE curKH CURSOR LOCAL FAST_FORWARD FOR
    SELECT IDKhachHang FROM KhachHang WHERE HoTen = N'Nguyễn Văn A';

OPEN curKH;
FETCH NEXT FROM curKH INTO @KH_ID;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '--------------------------------------------------';
    PRINT 'Đơn hàng của Khách hàng ID = ' + CAST(@KH_ID AS NVARCHAR(20)) + ' (Nguyễn Văn A):';
    -- Cursor để lặp trên các đơn hàng của khách hàng này
    DECLARE @IDDon INT;
    DECLARE @Ngay DATETIME;
    DECLARE @Tong DECIMAL(18,2);

    DECLARE curDon CURSOR LOCAL FOR
        SELECT IDDonHang, NgayDatHang, TongTien FROM DonHang WHERE IDKhachHang = @KH_ID;

    OPEN curDon;
    FETCH NEXT FROM curDon INTO @IDDon, @Ngay, @Tong;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'IDDonHang: ' + CAST(@IDDon AS NVARCHAR(20))
            + ' | NgayDat: ' + CONVERT(VARCHAR(20), @Ngay, 120)
            + ' | TongTien: ' + CAST(@Tong AS NVARCHAR(50));
        FETCH NEXT FROM curDon INTO @IDDon, @Ngay, @Tong;
    END

    CLOSE curDon;
    DEALLOCATE curDon;

    FETCH NEXT FROM curKH INTO @KH_ID;
END

CLOSE curKH;
DEALLOCATE curKH;


-------------------------------------------------------------------------------
-- 6e) Sử dụng con trỏ để in ra tổng số tiền mà khách hàng 'Nguyễn Văn A' đã trả
-- cho tất cả các đơn hàng
-------------------------------------------------------------------------------
DECLARE @KH INT;
DECLARE curKH2 CURSOR LOCAL FAST_FORWARD FOR
    SELECT IDKhachHang FROM KhachHang WHERE HoTen = N'Nguyễn Văn A';

OPEN curKH2;
FETCH NEXT FROM curKH2 INTO @KH;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @TotalForKH DECIMAL(18,2) = 0;

    DECLARE curSumDon CURSOR LOCAL FOR
        SELECT TongTien FROM DonHang WHERE IDKhachHang = @KH;

    DECLARE @t DECIMAL(18,2);

    OPEN curSumDon;
    FETCH NEXT FROM curSumDon INTO @t;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @TotalForKH = ISNULL(@TotalForKH,0) + ISNULL(@t,0);
        FETCH NEXT FROM curSumDon INTO @t;
    END

    CLOSE curSumDon;
    DEALLOCATE curSumDon;

    PRINT '--------------------------------------------';
    PRINT 'Tổng số tiền Khách hàng ID ' + CAST(@KH AS NVARCHAR(20)) + ' (Nguyễn Văn A) đã trả: ' + CAST(@TotalForKH AS NVARCHAR(50));
    FETCH NEXT FROM curKH2 INTO @KH;
END

CLOSE curKH2;
DEALLOCATE curKH2;


-------------------------------------------------------------------------------
-- 6f) Viết 1 thủ tục để in ra doanh thu trong mỗi ngày của cửa hàng
-------------------------------------------------------------------------------
IF OBJECT_ID('sp_DoanhThuTheoNgay_All','P') IS NOT NULL
    DROP PROCEDURE sp_DoanhThuTheoNgay_All;
GO

CREATE PROCEDURE sp_DoanhThuTheoNgay_All
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CONVERT(date, NgayDatHang) AS [Ngay],
           SUM(TongTien) AS DoanhThuTrongNgay,
           COUNT(IDDonHang) AS SoDonTrongNgay
    FROM DonHang
    GROUP BY CONVERT(date, NgayDatHang)
    ORDER BY CONVERT(date, NgayDatHang);
END


-- Thử chạy
EXEC sp_DoanhThuTheoNgay_All;


-------------------------------------------------------------------------------
-- 6g) Viết 1 thủ tục để in ra doanh thu của cửa hàng trong 1 ngày bất kỳ (tham số vào là ngày)
-------------------------------------------------------------------------------
IF OBJECT_ID('sp_DoanhThuTheoNgay','P') IS NOT NULL
    DROP PROCEDURE sp_DoanhThuTheoNgay;
GO

CREATE PROCEDURE sp_DoanhThuTheoNgay
    @Ngay DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Ngay AS [Ngay],
           ISNULL(SUM(TongTien),0) AS DoanhThuTrongNgay,
           COUNT(IDDonHang) AS SoDonTrongNgay
    FROM DonHang
    WHERE CONVERT(date, NgayDatHang) = @Ngay;
END
GO

-- Ví dụ chạy cho 2025-11-01
EXEC sp_DoanhThuTheoNgay '2025-11-01';
GO

-------------------------------------------------------------------------------
-- 6h) Viết 1 thủ tục in ra tổng số tiền mà 1 khách hàng đã chi tiêu (tham số vào: @IDKhachHang)
-------------------------------------------------------------------------------
IF OBJECT_ID('sp_TongTienKhachHang','P') IS NOT NULL
    DROP PROCEDURE sp_TongTienKhachHang;
GO

CREATE PROCEDURE sp_TongTienKhachHang
    @IDKhachHang INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @IDKhachHang AS IDKhachHang,
           ISNULL(SUM(TongTien),0) AS TongTienDaChi
    FROM DonHang
    WHERE IDKhachHang = @IDKhachHang;
END
GO

-- VD: khách hàng ID=1 (Nguyễn Văn A)
EXEC sp_TongTienKhachHang 1;
GO

-------------------------------------------------------------------------------
-- 6i) Viết thủ tục A để trả về tổng tiền của 1 đơn hàng bất kỳ.
-- Sử dụng OUTPUT parameter để trả về tổng (hoặc SELECT)
-------------------------------------------------------------------------------
IF OBJECT_ID('sp_TongTienDonHang','P') IS NOT NULL
    DROP PROCEDURE sp_TongTienDonHang;
GO

CREATE PROCEDURE sp_TongTienDonHang
    @IDDonHang INT,
    @TotalMoney DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @TotalMoney = ISNULL(SUM(ThanhTien),0)
    FROM SP_DonHang
    WHERE IDDonHang = @IDDonHang;
    -- Ngoài ra có thể cập nhật DonHang.TongTien nếu muốn
END
GO

-- Ví dụ gọi thủ tục và lấy giá trị OUTPUT
DECLARE @T DECIMAL(18,2);
EXEC sp_TongTienDonHang @IDDonHang = 1, @TotalMoney = @T OUTPUT;
PRINT 'Tổng tiền đơn hàng 1 = ' + CAST(@T AS NVARCHAR(50));
GO

-------------------------------------------------------------------------------
-- KẾT THÚC SCRIPT
-------------------------------------------------------------------------------
