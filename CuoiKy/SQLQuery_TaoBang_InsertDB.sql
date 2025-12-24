create database CuoiKy
-- 1. Bảng Khoa
CREATE TABLE Khoa (
    MaKhoa VARCHAR(10) PRIMARY KEY,
    TenKhoa NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15)
);

-- 2. Bảng Bác sĩ (Thuộc Khoa)
CREATE TABLE BacSi (
    MaBS VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    ChuyenMon NVARCHAR(100),
    MaKhoa VARCHAR(10) FOREIGN KEY REFERENCES Khoa(MaKhoa)
);

-- 3. Bảng Bệnh nhân
CREATE TABLE BenhNhan (
    MaBN VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(5),
    DiaChi NVARCHAR(200),
    SoDienThoai VARCHAR(15)
);

-- 4. Bảng Phòng bệnh (Thuộc Khoa)
CREATE TABLE PhongBenh (
    MaPhong VARCHAR(10) PRIMARY KEY,
    TenPhong NVARCHAR(50),
    LoaiPhong NVARCHAR(50), -- Ví dụ: VIP, Thường
    GiaPhong DECIMAL(18, 2),
    SucChua int default 4,
    MaKhoa VARCHAR(10) FOREIGN KEY REFERENCES Khoa(MaKhoa)
);

-- 5. Bảng Thuốc
CREATE TABLE Thuoc (
    MaThuoc VARCHAR(10) PRIMARY KEY,
    TenThuoc NVARCHAR(100) NOT NULL,
    DonViTinh NVARCHAR(20),
    GiaThuoc DECIMAL(18, 2),
    SoLuongTon INT
);

-- 6. Bảng Phiếu Khám (Kết nối BN và BS)
CREATE TABLE PhieuKham (
    MaPK VARCHAR(10) PRIMARY KEY,
    MaBN VARCHAR(10) FOREIGN KEY REFERENCES BenhNhan(MaBN),
    MaBS VARCHAR(10) FOREIGN KEY REFERENCES BacSi(MaBS),
    NgayKham DATETIME DEFAULT GETDATE(),
    ChuanDoan NVARCHAR(250),
    PhiKham DECIMAL(18, 2) DEFAULT 150000 -- Phí khám mặc định
);

-- 7. Bảng Chi tiết đơn thuốc (Dựa trên Phiếu khám)
CREATE TABLE ChiTietDonThuoc (
    MaPK VARCHAR(10) FOREIGN KEY REFERENCES PhieuKham(MaPK),
    MaThuoc VARCHAR(10) FOREIGN KEY REFERENCES Thuoc(MaThuoc),
    SoLuong INT,
    LieuDung NVARCHAR(200),
    PRIMARY KEY (MaPK, MaThuoc)
);

-- 8. Bảng Nhập viện (Theo dõi BN ở phòng nào)
CREATE TABLE NhapVien (
    MaNVien VARCHAR(10) PRIMARY KEY,
    MaBN VARCHAR(10) FOREIGN KEY REFERENCES BenhNhan(MaBN),
    MaPhong VARCHAR(10) FOREIGN KEY REFERENCES PhongBenh(MaPhong),
    NgayNhap DATETIME,
    NgayRa DATETIME NULL
);

-- 9. Bảng Hóa đơn
CREATE TABLE HoaDon (
    MaHD VARCHAR(10) PRIMARY KEY,
    MaPK VARCHAR(10) FOREIGN KEY REFERENCES PhieuKham(MaPK),
    NgayLap DATETIME,
    TongTien DECIMAL(18, 2),
    TrangThai NVARCHAR(50) -- Đã thanh toán / Chưa thanh toán
);

-- 10. Bảng Nhật ký hệ thống (Để làm Trigger ghi log)
CREATE TABLE HệThống_Log (
    LogID INT IDENTITY PRIMARY KEY,
    NoiDung NVARCHAR(MAX),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- 1. Khoa
INSERT INTO Khoa (MaKhoa, TenKhoa, SoDienThoai) VALUES 
('K01', N'Khoa Nội', '0243111222'),
('K02', N'Khoa Ngoại', '0243222333'),
('K03', N'Khoa Nhi', '0243333444'),
('K04', N'Khoa Hồi sức cấp cứu', '0243444555');

-- 2. Bác sĩ
INSERT INTO BacSi (MaBS, HoTen, ChuyenMon, MaKhoa) VALUES 
('BS01', N'Nguyễn Văn An', N'Tim mạch', 'K01'),
('BS02', N'Trần Thị Bình', N'Chấn thương chỉnh hình', 'K02'),
('BS03', N'Lê Văn Cường', N'Nhi khoa', 'K03'),
('BS04', N'Phạm Minh Đức', N'Hồi sức', 'K04'),
('BS05', N'Hoàng Lan Anh', N'Tiêu hóa', 'K01');

-- 3. Bệnh nhân
INSERT INTO BenhNhan (MaBN, HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai) VALUES 
('BN01', N'Nguyễn Văn Tùng', '1990-01-01', N'Nam', N'Hà Nội', '0912345678'),
('BN02', N'Lê Thị Mai', '1985-05-12', N'Nữ', N'Hải Phòng', '0987654321'),
('BN03', N'Trần Tuấn Anh', '2010-10-20', N'Nam', N'Nam Định', '0901112223'),
('BN04', N'Phạm Thu Hà', '1970-03-15', N'Nữ', N'Hà Nam', '0944555666'),
('BN05', N'Đỗ Hùng Dũng', '1995-12-30', N'Nam', N'Thanh Hóa', '0922333444');

-- 4. Phòng bệnh (Lưu ý SucChua để test Transaction)
INSERT INTO PhongBenh (MaPhong, TenPhong, LoaiPhong, GiaPhong, MaKhoa, SucChua) VALUES 
('P101', N'Phòng 101', N'VIP', 1000000, 'K01', 2),    -- Chỉ 2 người
('P102', N'Phòng 102', N'Thường', 300000, 'K01', 4),
('P201', N'Phòng 201', N'Thường', 300000, 'K02', 4),
('P301', N'Phòng 301', N'Dịch vụ', 600000, 'K03', 3);

-- 5. Thuốc (Lưu ý SoLuongTon)
INSERT INTO Thuoc (MaThuoc, TenThuoc, DonViTinh, GiaThuoc, SoLuongTon) VALUES 
('T01', N'Paracetamol 500mg', N'Viên', 2000, 1000),
('T02', N'Amoxicillin', N'Viên', 5000, 10),           -- Thuốc này sắp hết để test lỗi
('T03', N'Vitamin C', N'Viên', 1000, 2000),
('T04', N'Panadol Extra', N'Vỉ', 15000, 100),
('T05', N'Berberin', N'Lọ', 25000, 50);

-- 6. Phiếu Khám
INSERT INTO PhieuKham (MaPK, MaBN, MaBS, NgayKham, ChuanDoan, PhiKham) VALUES 
('PK01', 'BN01', 'BS01', '2023-10-01 08:30:00', N'Đau ngực nhẹ', 150000),
('PK02', 'BN02', 'BS02', '2023-10-01 09:15:00', N'Gãy xương cẳng chân', 200000),
('PK03', 'BN03', 'BS03', '2023-10-02 14:00:00', N'Sốt phát ban', 150000),
('PK04', 'BN04', 'BS01', '2023-10-02 15:30:00', N'Rối loạn nhịp tim', 150000);

-- 7. Chi tiết đơn thuốc
INSERT INTO ChiTietDonThuoc (MaPK, MaThuoc, SoLuong, LieuDung) VALUES 
('PK01', 'T01', 10, N'Ngày uống 2 lần, mỗi lần 1 viên'),
('PK01', 'T03', 5, N'Ngày uống 1 lần sau ăn'),
('PK02', 'T02', 2, N'Uống sáng tối'),
('PK03', 'T01', 10, N'Uống khi sốt trên 38.5 độ');

-- 8. Nhập viện (Test sức chứa)
-- Giả sử BN01 và BN04 cùng vào phòng P101 (Phòng VIP chỉ có 2 chỗ)
INSERT INTO NhapVien (MaNVien, MaBN, MaPhong, NgayNhap) VALUES 
('NV01', 'BN01', 'P101', '2023-10-01 10:00:00'),
('NV02', 'BN04', 'P101', '2023-10-02 16:00:00'); -- Lúc này P101 đã hết chỗ