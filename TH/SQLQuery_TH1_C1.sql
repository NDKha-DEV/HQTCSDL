

-- Xóa các bảng nếu đã tồn tại (để dễ rerun)
IF OBJECT_ID('dbo.SP_DonHang','U') IS NOT NULL DROP TABLE dbo.SP_DonHang;
IF OBJECT_ID('dbo.DonHang','U') IS NOT NULL DROP TABLE dbo.DonHang;
IF OBJECT_ID('dbo.SanPham','U') IS NOT NULL DROP TABLE dbo.SanPham;
IF OBJECT_ID('dbo.KhachHang','U') IS NOT NULL DROP TABLE dbo.KhachHang;

-- 1) Tạo bảng KhachHang với Identity, UNIQUE Email, CHECK GioiTinh, CHECK có '@' trong email
CREATE TABLE KhachHang (
    IDKhachHang INT IDENTITY(1,1) PRIMARY KEY,
    HoTen NVARCHAR(200) NOT NULL,
    GioiTinh NVARCHAR(10) NOT NULL,
    DiaChi NVARCHAR(300),
    Email NVARCHAR(200) UNIQUE,
    SoDienThoai NVARCHAR(50),
    CONSTRAINT CHK_KH_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    CONSTRAINT CHK_KH_Email_CheckAt CHECK (Email IS NULL OR CHARINDEX('@', Email) > 0)
);


-- 2) Tạo bảng SanPham
CREATE TABLE SanPham (
    IdSanPham INT IDENTITY(1,1) PRIMARY KEY,
    TenSP NVARCHAR(200) NOT NULL,
    MoTa NVARCHAR(1000),
    DonGia DECIMAL(18,2) NOT NULL
);


-- 3) Tạo bảng DonHang
CREATE TABLE DonHang (
    IDDonHang INT IDENTITY(1,1) PRIMARY KEY,
    IDKhachHang INT NOT NULL,
    NgayDatHang DATETIME NOT NULL DEFAULT GETDATE(),
    TongTien DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_DonHang_KhachHang FOREIGN KEY (IDKhachHang)
        REFERENCES KhachHang(IDKhachHang)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);


-- 4) Tạo bảng SP_DonHang (chi tiết đơn hàng) với khóa ngoại đến DonHang và SanPham
CREATE TABLE SP_DonHang (
    IDDonHang INT NOT NULL,
    IDSanPham INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    ThanhTien DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_SP_DonHang PRIMARY KEY (IDDonHang, IDSanPham),
    CONSTRAINT FK_SP_DonHang_DonHang FOREIGN KEY (IDDonHang) REFERENCES DonHang(IDDonHang),
    CONSTRAINT FK_SP_DonHang_SanPham FOREIGN KEY (IDSanPham) REFERENCES SanPham(IdSanPham)
);


-------------------------------------------------------------------------------
-- 5) Chèn dữ liệu mẫu (mỗi bảng ít nhất 5 bản ghi, SP_DonHang >= 10 bản ghi)
-------------------------------------------------------------------------------

-- KhachHang: ít nhất 5 bản ghi
INSERT INTO KhachHang (HoTen, GioiTinh, DiaChi, Email, SoDienThoai) VALUES
(N'Nguyễn Văn A', N'Nam', N'Hà Nội', 'nguyenvana@example.com', '0901000111'),
(N'Lê Thị B', N'Nữ', N'TP HCM', 'lethib@example.com', '0902000222'),
(N'Phạm Văn C', N'Nam', N'Đà Nẵng', 'phamc@example.com', '0903000333'),
(N'Trần Thị D', N'Nữ', N'Hải Phòng', 'trand@example.com', '0904000444'),
(N'Hoàng E', N'Nam', N'Bình Dương', 'hoange@example.com', '0905000555');


-- SanPham: ít nhất 5 sản phẩm
INSERT INTO SanPham (TenSP, MoTa, DonGia) VALUES
(N'Lập trình Java', N'Sách hướng dẫn Java từ cơ bản đến nâng cao', 450000),
(N'Python cơ bản', N'Sách Python cho người mới', 350000),
(N'Kinh tế vĩ mô', N'Giáo trình Kinh tế vĩ mô', 250000),
(N'Lập trình C#', N'Sách C# căn bản', 300000),
(N'Truyện thiếu nhi', N'Truyện cho trẻ em', 120000);


-- DonHang: tạo ≥5 đơn hàng (lúc tạo để TongTien = 0, sẽ cập nhật sau)
INSERT INTO DonHang (IDKhachHang, NgayDatHang) VALUES
(1, '2025-11-01'), -- đơn của Nguyễn Văn A
(2, '2025-11-02'),
(1, '2025-11-03'), -- đơn khác của Nguyễn Văn A
(3, '2025-11-04'),
(4, '2025-11-05');


-- SP_DonHang: ít nhất 10 bản ghi (liên kết đơn hàng và sp)
-- Sử dụng các IDDonHang 1..5 và IdSanPham 1..5
INSERT INTO SP_DonHang (IDDonHang, IDSanPham, SoLuong) VALUES
(1,1,1),
(1,2,2),
(1,5,1),
(2,3,1),
(2,5,3),
(3,1,1),
(3,4,1),
(3,2,1),
(4,3,2),
(4,4,1),
(5,5,5);  -- đây là 11 bản ghi

INSERT INTO SanPham (TenSP, MoTa, DonGia) VALUES
(N'Lập trình Go', N'Sách học ngôn ngữ lập trình Go', 380000),
(N'Cấu trúc dữ liệu & Giải thuật', N'Sách thuật toán chuyên sâu', 500000),
(N'Sách Machine Learning', N'Nhập môn Machine Learning', 650000);
select * from DonHang;