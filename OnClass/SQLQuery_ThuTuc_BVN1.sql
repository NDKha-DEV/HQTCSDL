
-- Bước 2: Tạo Bảng SinhVien
CREATE TABLE SinhVien (
    MaSV CHAR(10) PRIMARY KEY,
    TenSV NVARCHAR(50) NOT NULL,
    GioiTinh NVARCHAR(3) CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    NgaySinh DATE,
    DiaChi NVARCHAR(100)
);


-- Bước 3: Tạo Bảng MonHoc
CREATE TABLE MonHoc (
    MaMH CHAR(10) PRIMARY KEY,
    TenMH NVARCHAR(50) NOT NULL UNIQUE
);


-- Bước 4: Tạo Bảng KetQua (Điểm số)
CREATE TABLE KetQua (
    MaSV CHAR(10),
    MaMH CHAR(10),
    DiemSo DECIMAL(4, 2) CHECK (DiemSo >= 0 AND DiemSo <= 10),
    PRIMARY KEY (MaSV, MaMH),
    FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV),
    FOREIGN KEY (MaMH) REFERENCES MonHoc(MaMH)
);

-- Chèn dữ liệu mẫu cho SinhVien
INSERT INTO SinhVien (MaSV, TenSV, GioiTinh, NgaySinh, DiaChi) VALUES
('SV001', N'Nguyễn Văn A', N'Nam', '2003-01-15', N'Hà Nội'),
('SV002', N'Trần Thị B', N'Nữ', '2004-03-20', N'TP. HCM'),
('SV003', N'Lê Văn C', N'Nam', '2003-07-10', N'Đà Nẵng'),
('SV004', N'Phạm Thu D', N'Nữ', '2004-11-05', N'Cần Thơ'),
('SV005', N'Hoàng Anh E', N'Nam', '2003-05-25', N'Hải Phòng');


-- Chèn dữ liệu mẫu cho MonHoc
INSERT INTO MonHoc (MaMH, TenMH) VALUES
('MH001', N'Cơ sở dữ liệu'),
('MH002', N'Lập trình Web'),
('MH003', N'Toán cao cấp');


-- Chèn dữ liệu mẫu cho KetQua
-- (SV001 - Nam, SV002 - Nữ, SV003 - Nam, SV004 - Nữ, SV005 - Nam)

-- Môn Cơ sở dữ liệu (MH001)
INSERT INTO KetQua (MaSV, MaMH, DiemSo) VALUES
('SV001', 'MH001', 8.5), -- Nam
('SV002', 'MH001', 9.0), -- Nữ
('SV003', 'MH001', 7.0), -- Nam
('SV004', 'MH001', 9.5), -- Nữ
('SV005', 'MH001', 7.5); -- Nam

-- Môn Lập trình Web (MH002)
INSERT INTO KetQua (MaSV, MaMH, DiemSo) VALUES
('SV001', 'MH002', 6.0), -- Nam
('SV002', 'MH002', 7.0), -- Nữ
('SV003', 'MH002', 8.0), -- Nam
('SV004', 'MH002', 8.5), -- Nữ
('SV005', 'MH002', 7.5); -- Nam

---- B1
CREATE PROCEDURE Sp_Update_SV
    @MaSV CHAR(10),
    @TenSV NVARCHAR(50),
    @GioiTinh NVARCHAR(3), -- Ví dụ: 'Nam', 'Nữ'
    @NgaySinh DATE,
    @DiaChi NVARCHAR(100)
AS
BEGIN
    -- Kiểm tra xem MaSV đã tồn tại chưa
    IF EXISTS (SELECT 1 FROM SinhVien WHERE MaSV = @MaSV)
    BEGIN
        -- **Nếu là SV cũ:** Thực hiện UPDATE
        UPDATE SinhVien
        SET
            TenSV = @TenSV,
            GioiTinh = @GioiTinh,
            NgaySinh = @NgaySinh,
            DiaChi = @DiaChi
        WHERE MaSV = @MaSV;

        SELECT N'Cập nhật thành công sinh viên có Mã: ' + @MaSV AS Result;
    END
    ELSE
    BEGIN
        -- **Nếu là SV mới:** Thực hiện INSERT
        INSERT INTO SinhVien (MaSV, TenSV, GioiTinh, NgaySinh, DiaChi)
        VALUES (@MaSV, @TenSV, @GioiTinh, @NgaySinh, @DiaChi);

        SELECT N'Thêm mới thành công sinh viên có Mã: ' + @MaSV AS Result;
    END
END


-- **Cách sử dụng:**
-- 1. Cập nhật SV cũ:
EXEC Sp_Update_SV 'SV001', N'Nguyễn Văn An', N'Nam', '2003-05-15', N'Hà Nội';

-- 2. Thêm SV mới:
-- EXEC Sp_Update_SV 'SV999', N'Trần Thị Bích', N'Nữ', '2004-11-20', N'TP. HCM';

------B2
CREATE PROCEDURE Sp_Get_DiemTB_Theo_GioiTinh
    @TenMH NVARCHAR(50)
AS
BEGIN
    -- Lấy MaMH từ TenMH
    DECLARE @MaMH CHAR(10);
    SELECT @MaMH = MaMH FROM MonHoc WHERE TenMH = @TenMH;

    -- Kiểm tra xem môn học có tồn tại không
    IF @MaMH IS NULL
    BEGIN
        SELECT N'Môn học không tồn tại.' AS ErrorMessage;
        RETURN;
    END

    -- Tính điểm trung bình (sử dụng AVG)
    SELECT
        @TenMH AS N'Tên Môn Học',
        AVG(CASE WHEN S.GioiTinh IS NOT NULL THEN KQ.DiemSo END) AS N'Điểm TB Cả Lớp',
        AVG(CASE WHEN S.GioiTinh = N'Nam' THEN KQ.DiemSo END) AS N'Điểm TB Nam',
        AVG(CASE WHEN S.GioiTinh = N'Nữ' THEN KQ.DiemSo END) AS N'Điểm TB Nữ'
    FROM
        KetQua KQ
    JOIN
        SinhVien S ON KQ.MaSV = S.MaSV
    WHERE
        KQ.MaMH = @MaMH;

END
GO

-- **Cách sử dụng:**
-- EXEC Sp_Get_DiemTB_Theo_GioiTinh N'Cơ sở dữ liệu';

------B3
-- Định nghĩa kiểu bảng để chứa kết quả con trỏ
CREATE TYPE Type_DiemTB_GioiTinh AS TABLE
(
    TenMH NVARCHAR(50),
    DiemTB_Nam DECIMAL(4, 2),
    DiemTB_Nu DECIMAL(4, 2),
    NhanXet NVARCHAR(50)
);
GO

CREATE PROCEDURE Sp_ThongKe_DiemTB_MonHoc
    -- Tham số OUTPUT là con trỏ
    @Cursor_ThongKe CURSOR VARYING OUTPUT
AS
BEGIN
    -- Khai báo con trỏ
    SET @Cursor_ThongKe = CURSOR FOR
    SELECT
        MH.TenMH,
        ISNULL(AVG(CASE WHEN S.GioiTinh = N'Nam' THEN KQ.DiemSo END), 0) AS DiemTB_Nam,
        ISNULL(AVG(CASE WHEN S.GioiTinh = N'Nữ' THEN KQ.DiemSo END), 0) AS DiemTB_Nu,
        CASE
            WHEN ISNULL(AVG(CASE WHEN S.GioiTinh = N'Nam' THEN KQ.DiemSo END), 0) > ISNULL(AVG(CASE WHEN S.GioiTinh = N'Nữ' THEN KQ.DiemSo END), 0)
            THEN N'Nam học tốt hơn'
            WHEN ISNULL(AVG(CASE WHEN S.GioiTinh = N'Nam' THEN KQ.DiemSo END), 0) < ISNULL(AVG(CASE WHEN S.GioiTinh = N'Nữ' THEN KQ.DiemSo END), 0)
            THEN N'Nữ học tốt hơn'
            ELSE N'Nam và Nữ học ngang nhau'
        END AS NhanXet
    FROM
        MonHoc MH
    LEFT JOIN
        KetQua KQ ON MH.MaMH = KQ.MaMH
    LEFT JOIN
        SinhVien S ON KQ.MaSV = S.MaSV
    GROUP BY
        MH.TenMH;

    -- Mở con trỏ
    OPEN @Cursor_ThongKe;
END
GO

-- **Cách sử dụng:**
-- Khai báo một biến con trỏ để hứng kết quả
DECLARE @MyCursor CURSOR;
DECLARE @TenMH_Out NVARCHAR(50), @DiemTB_Nam_Out DECIMAL(4, 2), @DiemTB_Nu_Out DECIMAL(4, 2), @NhanXet_Out NVARCHAR(50);

-- Thực thi thủ tục
EXEC Sp_ThongKe_DiemTB_MonHoc @Cursor_ThongKe = @MyCursor OUTPUT;

-- Duyệt qua con trỏ và in kết quả (Fetch)
FETCH NEXT FROM @MyCursor INTO @TenMH_Out, @DiemTB_Nam_Out, @DiemTB_Nu_Out, @NhanXet_Out;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @TenMH_Out AS N'Môn Học', @DiemTB_Nam_Out AS N'TB Nam', @DiemTB_Nu_Out AS N'TB Nữ', @NhanXet_Out AS N'Nhận Xét';
    FETCH NEXT FROM @MyCursor INTO @TenMH_Out, @DiemTB_Nam_Out, @DiemTB_Nu_Out, @NhanXet_Out;
END

-- Đóng và giải phóng con trỏ
CLOSE @MyCursor;
DEALLOCATE @MyCursor;
