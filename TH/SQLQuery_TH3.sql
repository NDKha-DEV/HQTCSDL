CREATE TABLE LoaiHang (
    IDLoaiHang INT PRIMARY KEY,
    TenLoaiHang NVARCHAR(50),
    MoTa NVARCHAR(MAX)
);
CREATE TABLE NhaCungCap (
    IDNhaCungCap INT PRIMARY KEY,
    TenCongTy NVARCHAR(100),
    DiaChi NVARCHAR(255),
    SoDienThoai VARCHAR(20),
    Website VARCHAR(100),
    ConGiaoDich BIT -- 1 (True) nếu còn giao dịch, 0 (False) nếu không
);
CREATE TABLE SanPham (
    IDSP INT PRIMARY KEY,
    TenSP NVARCHAR(100),
    IDNhaCungCap INT,
    IDLoaiHang INT,
    DonGiaNhap DECIMAL(18, 2),
    SoLuongCon INT,
    SoLuongChoCungCap INT,
    MoTa NVARCHAR(MAX),
    NgungBan BIT, -- 1 (True) nếu ngừng bán, 0 (False) nếu còn bán
    
    FOREIGN KEY (IDNhaCungCap) REFERENCES NhaCungCap(IDNhaCungCap),
    FOREIGN KEY (IDLoaiHang) REFERENCES LoaiHang(IDLoaiHang)
);
CREATE TABLE CtyGiaoHang (
    IDCty INT PRIMARY KEY,
    TenCongTy NVARCHAR(100),
    SoDienThoai VARCHAR(20),
    DiaChi NVARCHAR(255)
);
CREATE TABLE KhachHang (
    IDKhachHang INT PRIMARY KEY,
    HoTen NVARCHAR(100),
    GioiTinh NVARCHAR(10), -- Ví dụ: 'Nam', 'Nữ', 'Khác'
    DiaChi NVARCHAR(255),
    Email VARCHAR(100),
    SoDienThoai VARCHAR(20)
);
CREATE TABLE NhanVien (
    IDNhanVien INT PRIMARY KEY,
    HoTen NVARCHAR(100),
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    NgayBatDauLam DATE,
    DiaChi NVARCHAR(255),
    Email VARCHAR(100),
    SoDienThoai VARCHAR(20)
);
CREATE TABLE DonHang (
    IDDonHang INT PRIMARY KEY,
    IDKhachHang INT,
    IDNhanVien INT,
    NgayDatHang DATE,
    NgayGiaoHang DATE,
    NgayYeuCauChuyen DATE,
    IDCtyGiaoHang INT,
    DiaChiGiaoHang NVARCHAR(255),
    
    FOREIGN KEY (IDKhachHang) REFERENCES KhachHang(IDKhachHang),
    FOREIGN KEY (IDNhanVien) REFERENCES NhanVien(IDNhanVien),
    FOREIGN KEY (IDCtyGiaoHang) REFERENCES CtyGiaoHang(IDCty)
);
CREATE TABLE SP_DonHang (
    IDDonHang INT,
    IDSanPham INT,
    SoLuong INT,
    DonGiaBan DECIMAL(18, 2),
    TyLeGiamGia DECIMAL(5, 2), -- Ví dụ: 0.10 cho 10% giảm giá
    
    PRIMARY KEY (IDDonHang, IDSanPham),
    FOREIGN KEY (IDDonHang) REFERENCES DonHang(IDDonHang),
    FOREIGN KEY (IDSanPham) REFERENCES SanPham(IDSP)
);

---- INSERT DL
INSERT INTO LoaiHang (IDLoaiHang, TenLoaiHang, MoTa) VALUES
(1, N'Điện Tử', N'Các sản phẩm công nghệ, thiết bị điện tử.'),
(2, N'Thời Trang', N'Quần áo, giày dép, phụ kiện cá nhân.'),
(3, N'Đồ Gia Dụng', N'Thiết bị phục vụ sinh hoạt gia đình.');
INSERT INTO NhaCungCap (IDNhaCungCap, TenCongTy, DiaChi, SoDienThoai, Website, ConGiaoDich) VALUES
(101, N'Công ty A', N'100 Đường Nguyễn Trãi, Hà Nội', '0901234567', 'ctya.com', 1),
(102, N'Công ty B', N'50 Lê Lợi, TP.HCM', '0987654321', 'ctyb.com', 1);
INSERT INTO KhachHang (IDKhachHang, HoTen, GioiTinh, DiaChi, Email, SoDienThoai) VALUES
(1, N'Trần Văn An', N'Nam', N'123 Phan Đình Phùng, Đà Nẵng', 'vantran@email.com', '0331112222'),
(2, N'Lê Thị Bình', N'Nữ', N'456 Hai Bà Trưng, Hà Nội', 'thibinh@email.com', '0912345678');
INSERT INTO NhanVien (IDNhanVien, HoTen, NgaySinh, GioiTinh, NgayBatDauLam, DiaChi, Email, SoDienThoai) VALUES
(10, N'Phạm Quang Minh', '1995-05-15', N'Nam', '2020-01-10', N'789 Trường Chinh, TP.HCM', 'minh.pq@cty.com', '0900112233');
INSERT INTO CtyGiaoHang (IDCty, TenCongTy, SoDienThoai, DiaChi) VALUES
(1, N'Giao Hàng Nhanh', '1900112233', N'Trung tâm Logistics, Hà Nội'),
(2, N'Viettel Post', '1900445566', N'Kho chính, TP.HCM');
INSERT INTO SanPham (IDSP, TenSP, IDNhaCungCap, IDLoaiHang, DonGiaNhap, SoLuongCon, SoLuongChoCungCap, MoTa, NgungBan) VALUES
(1001, N'Laptop ABC', 101, 1, 15000000.00, 50, 20, N'Laptop hiệu năng cao', 0),
(1002, N'Áo Thun Nam', 102, 2, 80000.00, 200, 50, N'Áo thun cotton co giãn', 0);
INSERT INTO DonHang (IDDonHang, IDKhachHang, IDNhanVien, NgayDatHang, NgayGiaoHang, NgayYeuCauChuyen, IDCtyGiaoHang, DiaChiGiaoHang) VALUES
(100, 1, 10, '2025-12-01', '2025-12-03', '2025-12-02', 1, N'123 Phan Đình Phùng, Đà Nẵng'),
(101, 2, 10, '2025-12-05', '2025-12-07', '2025-12-06', 2, N'456 Hai Bà Trưng, Hà Nội');
INSERT INTO SP_DonHang (IDDonHang, IDSanPham, SoLuong, DonGiaBan, TyLeGiamGia) VALUES
(100, 1001, 1, 18000000.00, 0.00), -- Khách 1 mua 1 Laptop
(100, 1002, 2, 120000.00, 0.10), -- Khách 1 mua 2 Áo Thun, giảm 10%
(101, 1002, 5, 120000.00, 0.05); -- Khách 2 mua 5 Áo Thun, giảm 5%

-- Câu 1. Viết một hàm f_ThanhTien trả về thành tiền của một sản phầm trong đơn hàng 
--(bảng SP_DonHang) với ThanhTien = SoLuong * DonGiaBan * (1-TyLeGiamGia) với 
--IDDonHang và IDSanPham là hai tham số đầu vào.
drop function if exists f_ThanhTien
CREATE FUNCTION f_ThanhTien (
    @IDDonHang INT,
    @IDSanPham INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @ThanhTien DECIMAL(18, 2);

    SELECT @ThanhTien = SoLuong * DonGiaBan * (1 - TyLeGiamGia)
    FROM SP_DonHang
    WHERE IDDonHang = @IDDonHang AND IDSanPham = @IDSanPham;

    -- Trả về 0 nếu không tìm thấy sản phẩm trong đơn hàng
    RETURN ISNULL(@ThanhTien, 0);
END;
SELECT dbo.f_ThanhTien(100, 1001) AS ThanhTienSP1_DH100;
-- Kết quả sẽ là: 18000000.00 (1 * 18000000 * (1-0))

-- Câu 2. Viết một hàm f_TongTien trả về tổng tiền của một hóa đơn với tổng tiền hóa 
-- đơn bằng tổng thành tiền của tất cả các sản phẩm trong đơn hàng với IDDonHang là tham số đầu vào. 
drop function if exists f_TongTien
CREATE FUNCTION f_TongTien (
    @IDDonHang INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(18, 2);

    SELECT @TongTien = SUM(SoLuong * DonGiaBan * (1 - TyLeGiamGia))
    FROM SP_DonHang
    WHERE IDDonHang = @IDDonHang;

    -- Trả về 0 nếu đơn hàng không có sản phẩm nào
    RETURN ISNULL(@TongTien, 0);
END;
SELECT dbo.f_TongTien(100) AS TongTienDH100;
-- Kết quả sẽ là: 18000000.00 + (2 * 120000 * (1-0.10)) = 18000000 + 216000 = 18216000.00

-- Câu 3. Viết một hàm f_SP_DonHang trả về một bảng chi tiết các sản phẩm trong một 
-- đơn hàng với IDDonHang là tham số đầu vào. Bảng trả về bao gồm các cột IDSanPham, 
-- TenSanPham, TenLoaiHang, TenCongTyCungCap, SoLuong, DonGiaBan, TyLeGiamGia, ThanhTien.  
drop function if exists f_SP_DonHang
CREATE FUNCTION f_SP_DonHang (
    @IDDonHang INT
)
RETURNS @ChiTietDonHang TABLE (
    IDSanPham INT,
    TenSanPham NVARCHAR(100),
    TenLoaiHang NVARCHAR(50),
    TenCongTyCungCap NVARCHAR(100),
    SoLuong INT,
    DonGiaBan DECIMAL(18, 2),
    TyLeGiamGia DECIMAL(5, 2),
    ThanhTien DECIMAL(18, 2)
)
AS
BEGIN
    INSERT INTO @ChiTietDonHang
    SELECT
        SPDH.IDSanPham,
        SP.TenSP AS TenSanPham,
        LH.TenLoaiHang,
        NCC.TenCongTy AS TenCongTyCungCap,
        SPDH.SoLuong,
        SPDH.DonGiaBan,
        SPDH.TyLeGiamGia,
        SPDH.SoLuong * SPDH.DonGiaBan * (1 - SPDH.TyLeGiamGia) AS ThanhTien
    FROM
        SP_DonHang SPDH
    INNER JOIN
        SanPham SP ON SPDH.IDSanPham = SP.IDSP
    INNER JOIN
        LoaiHang LH ON SP.IDLoaiHang = LH.IDLoaiHang
    INNER JOIN
        NhaCungCap NCC ON SP.IDNhaCungCap = NCC.IDNhaCungCap
    WHERE
        SPDH.IDDonHang = @IDDonHang;

    RETURN;
END;
-- Truy vấn chi tiết các sản phẩm trong Đơn hàng số 100
SELECT *
FROM dbo.f_SP_DonHang(100);

-- Câu 4. Tạo view v_ChiTietDonHang để hiển thị chi tiết thông tin các mặt hàng trong 
-- đơn hàng bao gồm IDDonHang, IDSanPham, TenSanPham, TenLoaiHang, TenCongTyCungCap, SoLuongBan, DonGiaNhap, DonGiaBan, TyLeGiamGia, 
-- ThanhTienBan, TienLai 
-- với:ThanhTienBan là tổng tiền bán được sản phẩm đó trong đơn hàng (đã trừ giảm giá) 
-- TienLai là tiền lãi thu được từ sản phẩm đó trong hóa đơn (bằng ThanhTienBan trừ đi tổng tiền nhập) 
drop view if exists v_ChiTietDonHang
CREATE VIEW v_ChiTietDonHang AS
SELECT
    DH.IDDonHang,
    SPDH.IDSanPham,
    SP.TenSP AS TenSanPham,
    LH.TenLoaiHang,
    NCC.TenCongTy AS TenCongTyCungCap,
    SPDH.SoLuong AS SoLuongBan,
    SP.DonGiaNhap,
    SPDH.DonGiaBan,
    SPDH.TyLeGiamGia,
    -- Thành tiền bán = SoLuong * DonGiaBan * (1 - TyLeGiamGia)
    SPDH.SoLuong * SPDH.DonGiaBan * (1 - SPDH.TyLeGiamGia) AS ThanhTienBan,
    -- Tiền lãi = ThanhTienBan - (SoLuong * DonGiaNhap)
    (SPDH.SoLuong * SPDH.DonGiaBan * (1 - SPDH.TyLeGiamGia)) - (SPDH.SoLuong * SP.DonGiaNhap) AS TienLai
FROM
    SP_DonHang SPDH
INNER JOIN
    DonHang DH ON SPDH.IDDonHang = DH.IDDonHang
INNER JOIN
    SanPham SP ON SPDH.IDSanPham = SP.IDSP
INNER JOIN
    LoaiHang LH ON SP.IDLoaiHang = LH.IDLoaiHang
INNER JOIN
    NhaCungCap NCC ON SP.IDNhaCungCap = NCC.IDNhaCungCap;


-- Câu 5. Tạo view v_TongKetDonHang để hiển thị thông tin tổng kết các đơn hàng bao 
-- gồm IDDonHang, IDKhachHang, HoTenKhachHang, GioiTinhKhachHang, IDNhanVien, HoTenNhanVien, NgayDatHang, NgayGiaoHang, NgayYeuCauChuyen, 
-- IDCongTyGiaoHang, TenCongTyGiaoHang, SoMatHang, TongTienHoaDon, TongTienLai 
-- với: SoMatHang là số mặt hàng trong đơn hàng (chú ý: một sản phẩm với số lượng là n>1 cũng chỉ được tính là 1 mặt hàng) 
-- TongTienHoaDon là tổng tiền thu được từ các mặt hàng trong hóa đơn  
-- TongLai là tổng tiền lãi thu được từ các mặt hàng trong hóa đơn 
drop view if exists v_TongKetDonHang
CREATE VIEW v_TongKetDonHang AS
SELECT
    DH.IDDonHang,
    DH.IDKhachHang,
    KH.HoTen AS HoTenKhachHang,
    KH.GioiTinh AS GioiTinhKhachHang,
    DH.IDNhanVien,
    NV.HoTen AS HoTenNhanVien,
    DH.NgayDatHang,
    DH.NgayGiaoHang,
    DH.NgayYeuCauChuyen,
    DH.IDCtyGiaoHang,
    CGH.TenCongTy AS TenCongTyGiaoHang,
    -- SoMatHang: Đếm số lượng sản phẩm (IDSanPham) khác nhau trong đơn hàng
    COUNT(SPDH.IDSanPham) AS SoMatHang,
    -- TongTienHoaDon: Tổng ThanhTienBan của tất cả mặt hàng
    SUM(VCDH.ThanhTienBan) AS TongTienHoaDon,
    -- TongTienLai: Tổng Tiền lãi của tất cả mặt hàng
    SUM(VCDH.TienLai) AS TongTienLai
FROM
    DonHang DH
INNER JOIN
    KhachHang KH ON DH.IDKhachHang = KH.IDKhachHang
INNER JOIN
    NhanVien NV ON DH.IDNhanVien = NV.IDNhanVien
INNER JOIN
    CtyGiaoHang CGH ON DH.IDCtyGiaoHang = CGH.IDCty
INNER JOIN
    SP_DonHang SPDH ON DH.IDDonHang = SPDH.IDDonHang
INNER JOIN
    v_ChiTietDonHang VCDH ON DH.IDDonHang = VCDH.IDDonHang
GROUP BY
    DH.IDDonHang, DH.IDKhachHang, KH.HoTen, KH.GioiTinh, DH.IDNhanVien, NV.HoTen, 
    DH.NgayDatHang, DH.NgayGiaoHang, DH.NgayYeuCauChuyen, DH.IDCtyGiaoHang, CGH.TenCongTy;


-- Câu 6. Thực hiện truy vấn trong các view v_ChiTietDonHang, v_TongKetDonHang đã tạo và các bảng cần thiết để thực hiện các yêu cầu sau: 
-- a. Tìm nhân viên bán được nhiều đơn hàng nhất 
SELECT TOP 1
    IDNhanVien,
    HoTenNhanVien,
    COUNT(IDDonHang) AS SoDonHangBanDuoc
FROM
    v_TongKetDonHang
GROUP BY
    IDNhanVien, HoTenNhanVien
ORDER BY
    SoDonHangBanDuoc DESC;
-- b. Đưa ra danh sách các nhân viên theo thứ tự giảm dần của số đơn hàng bán được 
SELECT
    IDNhanVien,
    HoTenNhanVien,
    COUNT(IDDonHang) AS SoDonHangBanDuoc
FROM
    v_TongKetDonHang
GROUP BY
    IDNhanVien, HoTenNhanVien
ORDER BY
    SoDonHangBanDuoc DESC;
-- c. Đưa ra danh sách các công ty đã từng giao hàng trễ 
SELECT DISTINCT
    IDCtyGiaoHang,
    TenCongTyGiaoHang
FROM
    v_TongKetDonHang
WHERE
    NgayGiaoHang > NgayYeuCauChuyen;
-- d. Đưa ra danh sách các mặt hàng theo thứ tự giảm dần tổng số tiền lãi thu được 
SELECT
    IDSanPham,
    TenSanPham,
    TenLoaiHang,
    SUM(TienLai) AS TongTienLai
FROM
    v_ChiTietDonHang
GROUP BY
    IDSanPham, TenSanPham, TenLoaiHang
ORDER BY
    TongTienLai DESC;
-- e. Đưa ra loại mặt hàng có số lượng bán được nhiều nhất 
SELECT TOP 1
    TenLoaiHang,
    SUM(SoLuongBan) AS TongSoLuongBan
FROM
    v_ChiTietDonHang
GROUP BY
    TenLoaiHang
ORDER BY
    TongSoLuongBan DESC;

-- Câu 7. Tạo Trigger để đảm bảo rằng khi thêm một loại mặt hàng vào bảng LoaiHang thì tên loại mặt hàng thêm vào phải chưa có trong bảng. 
-- Nếu người dùng nhập một tên loại mặt hàng đã có trong danh sách thì báo lỗi. 
-- Thử thêm một loại mặt hàng vào trong bảng 
-- Câu 7: Trigger kiểm tra trùng lặp Tên Loại Hàng khi INSERT
drop trigger if exists trg_LoaiHang_Insert
CREATE TRIGGER trg_LoaiHang_Insert
ON LoaiHang
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN LoaiHang lh ON i.TenLoaiHang = lh.TenLoaiHang
        WHERE i.IDLoaiHang <> lh.IDLoaiHang -- Loại bỏ trường hợp đang tự so sánh với chính nó (mặc dù là AFTER INSERT)
    )
    BEGIN
        -- Báo lỗi và hoàn tác giao dịch nếu tên loại hàng đã tồn tại
        RAISERROR(N'Lỗi: Tên loại mặt hàng vừa thêm đã tồn tại trong danh sách.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END;

-- Thêm thành công: IDLoaiHang tiếp theo (ví dụ 4) và tên mới
INSERT INTO LoaiHang (IDLoaiHang, TenLoaiHang, MoTa) VALUES
(4, N'Mỹ Phẩm', N'Các sản phẩm chăm sóc sắc đẹp và cá nhân.'); 
-- Sau lệnh này, kiểm tra: SELECT * FROM LoaiHang
-- Thêm thất bại: Tên 'Điện Tử' đã có (ID 1)
INSERT INTO LoaiHang (IDLoaiHang, TenLoaiHang, MoTa) VALUES
(5, N'Điện Tử', N'Các sản phẩm công nghệ.'); 
-- Lệnh này sẽ bị ROLLBACK và báo lỗi.

-- Câu 8. Tạo Trigger để đảm bảo rằng khi sửa một loại mặt hàng trong bảng LoaiHang 
-- thì tên loại mặt hàng sau khi sửa phải khác tên loai mặt hàng trước khi sửa và tên loại 
-- mặt hàng sau khi sửa không trùng với tên các loại hàng đã có trong bảng. Nếu vi phạm thì thông báo lỗi. 
-- Câu 8: Trigger kiểm tra trùng lặp và thay đổi Tên Loại Hàng khi UPDATE
drop trigger if exists trg_LoaiHang_Update
CREATE TRIGGER trg_LoaiHang_Update
ON LoaiHang
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra 1: Tên loại hàng sau khi sửa có khác tên loại hàng trước khi sửa không
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN inserted i ON d.IDLoaiHang = i.IDLoaiHang
        WHERE d.TenLoaiHang = i.TenLoaiHang
    )
    BEGIN
        RAISERROR(N'Lỗi: Tên loại mặt hàng sau khi sửa phải khác tên loại hàng ban đầu.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Kiểm tra 2: Tên loại hàng sau khi sửa có bị trùng với loại hàng khác không
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN LoaiHang lh ON i.TenLoaiHang = lh.TenLoaiHang
        WHERE i.IDLoaiHang <> lh.IDLoaiHang -- Đảm bảo không so sánh với chính bản ghi đang sửa
    )
    BEGIN
        RAISERROR(N'Lỗi: Tên loại mặt hàng sau khi sửa đã trùng với tên loại hàng khác.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END;

-- Giả sử ID 4 là 'Mỹ Phẩm'
-- 1. Sửa thất bại (Tên không thay đổi):
UPDATE LoaiHang SET TenLoaiHang = N'Mỹ Phẩm' WHERE IDLoaiHang = 4;
-- Lệnh này sẽ bị ROLLBACK và báo lỗi (Kiểm tra 1).

-- 2. Sửa thất bại (Tên trùng với ID 1 'Điện Tử'):
UPDATE LoaiHang SET TenLoaiHang = N'Điện Tử' WHERE IDLoaiHang = 4;
-- Lệnh này sẽ bị ROLLBACK và báo lỗi (Kiểm tra 2).

-- 3. Sửa thành công (Tên mới và duy nhất):
UPDATE LoaiHang SET TenLoaiHang = N'Thực Phẩm Chức Năng' WHERE IDLoaiHang = 4;
-- Lệnh này sẽ chạy thành công.
-- Câu 9. Tạo Trigger để khi xóa một nhà cung cấp trong bảng NhaCungCap thì thay vì xóa nhà cung cấp đó sẽ 
-- thực hiện cập nhật trường ConGiaoDich = 0 đối với nhà cung cấp đó 
-- và cập nhật bảng SanPham để thiết lập NgungBan = 1 với tất cả các sản phẩm của nhà cung cấp bị xóa đi.
-- Câu 9: Trigger thay thế thao tác DELETE bằng cập nhật trạng thái (Soft Delete)
drop trigger if exists trg_NhaCungCap_SoftDelete
CREATE TRIGGER trg_NhaCungCap_SoftDelete
ON NhaCungCap
INSTEAD OF DELETE
AS
BEGIN
    -- 1. Cập nhật trạng thái ConGiaoDich = 0 cho các nhà cung cấp bị "xóa"
    UPDATE NhaCungCap
    SET ConGiaoDich = 0
    FROM NhaCungCap ncc
    INNER JOIN deleted d ON ncc.IDNhaCungCap = d.IDNhaCungCap
    
    -- 2. Cập nhật trạng thái NgungBan = 1 cho tất cả sản phẩm của nhà cung cấp đó
    UPDATE SanPham
    SET NgungBan = 1
    FROM SanPham sp
    INNER JOIN deleted d ON sp.IDNhaCungCap = d.IDNhaCungCap;
    
    -- Thông báo thay vì xóa
    RAISERROR(N'Nhà cung cấp đã được chuyển trạng thái sang Ngừng Giao Dịch và tất cả sản phẩm liên quan đã được Ngừng Bán.', 10, 1)
END;

-- Khi bạn chạy lệnh DELETE dưới đây:
DELETE FROM NhaCungCap WHERE IDNhaCungCap = 101; 
-- (Giả sử Công ty A là ID 101)

-- Điều sẽ xảy ra:
-- 1. Lệnh DELETE bị chặn bởi trigger.
-- 2. Dòng có IDNhaCungCap = 101 trong NhaCungCap sẽ được cập nhật ConGiaoDich = 0.
-- 3. Các sản phẩm có IDNhaCungCap = 101 trong SanPham (ví dụ: Laptop ABC) sẽ được cập nhật NgungBan = 1.