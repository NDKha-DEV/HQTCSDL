-- Hàm tính tổng tiền thuốc của một Phiếu Khám
CREATE FUNCTION fn_TinhTienThuoc (@MaPK VARCHAR(10))
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongTienThuoc DECIMAL(18, 2);

    SELECT @TongTienThuoc = SUM(ct.SoLuong * t.GiaThuoc)
    FROM ChiTietDonThuoc ct
    JOIN Thuoc t ON ct.MaThuoc = t.MaThuoc
    WHERE ct.MaPK = @MaPK;

    -- Nếu phiếu khám không có thuốc, trả về 0 thay vì NULL
    RETURN ISNULL(@TongTienThuoc, 0);
END;


-- Thủ tục lập Hóa đơn (Giao dịch đa người dùng)
CREATE PROCEDURE sp_LapHoaDon
    @MaHD VARCHAR(10),
    @MaPK VARCHAR(10)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Kiểm tra xem Phiếu khám này đã có hóa đơn chưa
        IF EXISTS (SELECT 1 FROM HoaDon WHERE MaPK = @MaPK)
        BEGIN
            PRINT N'Lỗi: Phiếu khám này đã được lập hóa đơn trước đó.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Khai báo các biến tính toán
        DECLARE @TienThuoc DECIMAL(18, 2);
        DECLARE @PhiKham DECIMAL(18, 2);
        DECLARE @TongThanhToan DECIMAL(18, 2);

        -- GỌI HÀM (Function) của SV đã viết ở trên
        SET @TienThuoc = dbo.fn_TinhTienThuoc(@MaPK);

        -- Lấy phí khám từ bảng PhieuKham
        SELECT @PhiKham = PhiKham FROM PhieuKham WHERE MaPK = @MaPK;

        -- Tính tổng
        SET @TongThanhToan = @TienThuoc + @PhiKham;

        -- 3. Chèn vào bảng HoaDon
        INSERT INTO HoaDon (MaHD, MaPK, NgayLap, TongTien, TrangThai)
        VALUES (@MaHD, @MaPK, GETDATE(), @TongThanhToan, N'Chưa thanh toán');

        PRINT N'Lập hóa đơn thành công cho phiếu khám ' + @MaPK;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi khi lập hóa đơn: ' + ERROR_MESSAGE();
    END CATCH
END;


-- Chạy thử và Kiểm tra (Demo)
-- Bước 1: Kiểm tra tiền thuốc của phiếu PK01 (Đã có dữ liệu mẫu trước đó)
SELECT dbo.fn_TinhTienThuoc('PK01') AS TienThuoc_PK01;
-- Kết quả sẽ là: (10 viên T01 * 2000) + (5 viên T03 * 1000) = 25,000.

-- Bước 2: Chạy thủ tục lập hóa đơn
EXEC sp_LapHoaDon 'HD01', 'PK01';

-- Bước 3: Kiểm tra bảng HoaDon
SELECT * FROM HoaDon WHERE MaHD = 'HD01';
-- Tổng tiền sẽ là: 25,000 (thuốc) + 150,000 (phí khám) = 175,000.

-- 4. Giải thích để ghi vào báo cáo (Ghi điểm cộng)
-- Tính module hóa: Thay vì viết một đoạn code dài, nhóm chia ra thành Hàm (chuyên tính toán) 
-- và Thủ tục (chuyên thực thi ghi dữ liệu). Điều này giúp code dễ bảo trì và tái sử dụng (ví dụ: Hàm tính tiền thuốc có thể dùng lại ở View báo cáo).

-- Tính toàn vẹn (Transaction): Việc sử dụng BEGIN TRANSACTION giúp ngăn chặn tình trạng hóa đơn bị tạo lỗi 
-- hoặc tạo trùng lặp khi có nhiều nhân viên kế toán cùng thao tác một lúc.

-- Xử lý lỗi: TRY...CATCH đảm bảo rằng nếu có bất kỳ sự cố nào (như sai kiểu dữ liệu, mất kết nối), 
-- hệ thống sẽ không bị treo mà sẽ tự động quay lại trạng thái an toàn (ROLLBACK).



-- Code Trigger trừ kho thuốc (Dành cho SV làm Trigger)
CREATE TRIGGER trg_TruKhoThuoc
ON ChiTietDonThuoc
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Kiểm tra xem số lượng tồn có đủ để bán không
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN Thuoc t ON i.MaThuoc = t.MaThuoc
            WHERE t.SoLuongTon < i.SoLuong
        )
        BEGIN
            -- Nếu có bất kỳ loại thuốc nào không đủ số lượng, báo lỗi và hủy giao dịch
            RAISERROR (N'Lỗi: Số lượng thuốc trong kho không đủ để kê đơn!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Nếu đủ điều kiện, tiến hành cập nhật trừ kho
        UPDATE Thuoc
        SET SoLuongTon = t.SoLuongTon - i.SoLuong
        FROM Thuoc t
        JOIN inserted i ON t.MaThuoc = i.MaThuoc;

        PRINT N'Trigger: Đã cập nhật trừ kho thuốc thành công.';
    END TRY
    BEGIN CATCH
        -- Xử lý các lỗi phát sinh khác
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
    END CATCH
END;

-- Kịch bản Kiểm tra (Test Case) cho Trigger
--Trường hợp 1: Kê đơn thành công (Số lượng tồn đủ)
-- Kiểm tra số lượng thuốc T05 hiện tại (đang có 50)
SELECT MaThuoc, TenThuoc, SoLuongTon FROM Thuoc WHERE MaThuoc = 'T05';

-- Kê đơn 10 vỉ cho phiếu khám PK04
INSERT INTO ChiTietDonThuoc (MaPK, MaThuoc, SoLuong, LieuDung) 
VALUES ('PK04', 'T05', 10, N'Uống sau ăn');

-- Kiểm tra lại: T05 sẽ chỉ còn 40
SELECT MaThuoc, TenThuoc, SoLuongTon FROM Thuoc WHERE MaThuoc = 'T05';

-- Trường hợp 2: Kê đơn thất bại (Số lượng tồn không đủ - Test tính toàn vẹn)
-- Thuốc T02 hiện tại chỉ còn 10 viên (xem ở dữ liệu mẫu trước đó)
-- Thử kê đơn 20 viên cho phiếu PK04
INSERT INTO ChiTietDonThuoc (MaPK, MaThuoc, SoLuong, LieuDung) 
VALUES ('PK04', 'T02', 20, N'Test lỗi thiếu hàng');

-- Kết quả mong đợi: SQL sẽ báo lỗi "Số lượng thuốc trong kho không đủ" 
-- và lệnh INSERT bị hủy (Rollback).

-- 3. Giải thích logic để đưa vào báo cáo
-- Sử dụng bảng inserted: Đây là bảng tạm của SQL Server chứa dữ liệu vừa được đẩy vào. 
-- Trigger dùng bảng này để biết cần trừ bao nhiêu và trừ loại thuốc nào.

-- Tính toàn vẹn (Data Integrity): Trigger đóng vai trò như một "chốt chặn cuối cùng". 
-- Dù lập trình viên có quên kiểm tra ở phía giao diện phần mềm thì CSDL cũng không cho phép số lượng tồn kho bị âm.

-- Sự kết hợp với Transaction: Khi ROLLBACK TRANSACTION được gọi trong Trigger, toàn bộ lệnh INSERT gây ra nó sẽ bị hủy bỏ hoàn toàn. 
-- Điều này cực kỳ quan trọng trong môi trường đa người dùng.




-- View 1: Danh sách bệnh nhân đang nội trú và số ngày đã ở
CREATE VIEW v_DanhSachNoiTru AS
SELECT 
    bn.MaBN, 
    bn.HoTen, 
    pb.TenPhong, 
    pb.MaKhoa,
    nv.NgayNhap,
    DATEDIFF(DAY, nv.NgayNhap, GETDATE()) AS SoNgayDaO,
    pb.GiaPhong,
    DATEDIFF(DAY, nv.NgayNhap, GETDATE()) * pb.GiaPhong AS TienPhongTamTinh
FROM BenhNhan bn
JOIN NhapVien nv ON bn.MaBN = nv.MaBN
JOIN PhongBenh pb ON nv.MaPhong = pb.MaPhong
WHERE nv.NgayRa IS NULL; -- Chỉ những người chưa xuất viện


-- View 2: Thống kê doanh thu theo khoa
CREATE VIEW v_DoanhThuTheoKhoa AS
SELECT 
    k.TenKhoa,
    COUNT(hd.MaHD) AS SoLuongHoaDon,
    SUM(hd.TongTien) AS TongDoanhThu
FROM Khoa k
JOIN BacSi bs ON k.MaKhoa = bs.MaKhoa
JOIN PhieuKham pk ON bs.MaBS = pk.MaBS
JOIN HoaDon hd ON pk.MaPK = hd.MaPK
WHERE hd.TrangThai = N'Đã thanh toán'
GROUP BY k.TenKhoa;






-- Cursor (Con trỏ)
-- Kịch bản: Duyệt danh sách các hóa đơn "Chưa thanh toán" để in ra thông báo nhắc nợ chi tiết cho từng bệnh nhân.
CREATE PROCEDURE sp_NhacNoVienPhi
AS
BEGIN
    -- Khai báo các biến để chứa dữ liệu từ Cursor
    DECLARE @MaHD VARCHAR(10);
    DECLARE @TenBN NVARCHAR(100);
    DECLARE @TongTien DECIMAL(18,2);
    DECLARE @NgayLap DATETIME;

    -- 1. Khai báo Cursor
    DECLARE cur_HoaDonTre CURSOR FOR 
    SELECT hd.MaHD, bn.HoTen, hd.TongTien, hd.NgayLap
    FROM HoaDon hd
    JOIN PhieuKham pk ON hd.MaPK = pk.MaPK
    JOIN BenhNhan bn ON pk.MaBN = bn.MaBN
    WHERE hd.TrangThai = N'Chưa thanh toán';

    -- 2. Mở Cursor
    OPEN cur_HoaDonTre;

    -- 3. Lấy dòng dữ liệu đầu tiên
    FETCH NEXT FROM cur_HoaDonTre INTO @MaHD, @TenBN, @TongTien, @NgayLap;

    PRINT '---------- DANH SÁCH NHẮC NỢ VIỆN PHÍ ----------';

    -- 4. Vòng lặp duyệt dữ liệu
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT N'Hóa đơn: ' + @MaHD + 
              N' | Bệnh nhân: ' + @TenBN + 
              N' | Số tiền: ' + CAST(@TongTien AS NVARCHAR(20)) +
              N' | Ngày lập: ' + CAST(@NgayLap AS NVARCHAR(20));
        
        -- Ở đây có thể thêm logic cập nhật hoặc gửi thông báo...

        -- Lấy dòng tiếp theo
        FETCH NEXT FROM cur_HoaDonTre INTO @MaHD, @TenBN, @TongTien, @NgayLap;
    END

    -- 5. Đóng và giải phóng Cursor
    CLOSE cur_HoaDonTre;
    DEALLOCATE cur_HoaDonTre;
END;


-- công cụ test
-- view
SELECT * FROM v_DanhSachNoiTru;
-- cursor
EXEC sp_NhacNoVienPhi;