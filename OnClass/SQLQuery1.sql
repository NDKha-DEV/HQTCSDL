-- 1. Tạo Database
CREATE DATABASE QLSV;
GO

USE QLSV;
GO

-- 2. Tạo bảng SINHVIEN
CREATE TABLE SINHVIEN (
    MaSV CHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    DiemTB FLOAT
);

-- 3. Tạo bảng MONHOC
CREATE TABLE MONHOC (
    MaMH CHAR(10) PRIMARY KEY,
    TenMH NVARCHAR(100) NOT NULL
);

-- 4. Tạo bảng DIEMTHI (Lưu chi tiết điểm thi của SV cho từng môn)
CREATE TABLE DIEMTHI (
    MaSV CHAR(10) FOREIGN KEY REFERENCES SINHVIEN(MaSV),
    MaMH CHAR(10) FOREIGN KEY REFERENCES MONHOC(MaMH),
    LanThi INT NOT NULL,
    Diem FLOAT NOT NULL,
    PRIMARY KEY (MaSV, MaMH, LanThi)
);
GO

-- 5. Chèn dữ liệu mẫu
-- SINHVIEN
INSERT INTO SINHVIEN (MaSV, HoTen, DiemTB) VALUES
('SV001', N'Nguyễn Văn A', 8.5),
('SV002', N'Trần Thị B', 9.2),
('SV003', N'Lê Văn C', 7.8),
('SV004', N'Phạm Thị D', 9.5),
('SV005', N'Hoàng Văn E', 8.9);

-- MONHOC
INSERT INTO MONHOC (MaMH, TenMH) VALUES
('CSDL', N'Cơ Sở Dữ Liệu'),
('TRR', N'Toán Rời Rạc'),
('LTW', N'Lập Trình Web');

-- DIEMTHI (Điểm thi)
INSERT INTO DIEMTHI (MaSV, MaMH, LanThi, Diem) VALUES
-- SV001
('SV001', 'CSDL', 1, 8.0),
('SV001', 'TRR', 1, 7.5),
('SV001', 'LTW', 1, 9.0),
-- SV002
('SV002', 'CSDL', 1, 9.5),
('SV002', 'TRR', 1, 8.8),
('SV002', 'TRR', 2, 9.0), -- Lần 2 cao hơn
('SV002', 'LTW', 1, 9.8),
-- SV004
('SV004', 'CSDL', 1, 9.0),
('SV004', 'CSDL', 2, 9.5), -- Lần 2 cao hơn
('SV004', 'TRR', 1, 9.5),
('SV004', 'LTW', 1, 9.2);

-- Cập nhật lại DiemTB (Điểm trung bình) cho SV004 để chắc chắn SV004 có điểm cao nhất
UPDATE SINHVIEN SET DiemTB = 9.8 WHERE MaSV = 'SV004';
GO