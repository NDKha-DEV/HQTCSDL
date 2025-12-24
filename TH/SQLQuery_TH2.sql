--- Câu 1 :Viết một stored procedure đặt tên là sp_ThanhTien để cập nhật trường ThanhTien 
--- cho bảng SP_DonHang sao cho ThanhTien = SoLuong * DonGia
create proc sp_ThanhTien
as begin
	update spdh
	set spdh.ThanhTien = spdh.SoLuong * sp.DonGia
	from SP_DonHang spdh
	join SanPham sp on spdh.IDSanPham = sp.IdSanPham
end
--- Câu 2. Viết một stored procedure đặt tên là sp_TongTien để cập nhật trường TongTien cho 
--- bảng DonHang bằng tổng ThanhTien của tất cả các sản phẩm trong đơn hàng
create proc sp_TongTien
as begin
	update dh
	set dh.TongTien = (select sum(spdh.ThanhTien) from SP_DonHang spdh where spdh.IDDonHang = dh.IDDonHang)
	from DonHang dh
end
--- Câu 3. Viết một stored procedure đặt tên là sp_ThuNhap để tính thu nhập của của hàng 
--- trong một khoảng thời gian nào đó với ngày đầu và ngày cuối là tham số đầu vào của thủ 
--- tục. Viết một đoạn mã T-SQL thực hiện gọi thủ tục sp_ThuNhap hai lần với hai khoảng 
--- thời gian khác nhau và thực hiện in ra màn hình khoảng thời gian đạt được thu nhập lớn hơn. 
DROP PROCEDURE IF EXISTS sp_ThuNhap;
create proc sp_ThuNhap
	@Ngaydau date, @Ngaycuoi date,
	@ThuNhap money out
as begin
	select @ThuNhap = sum(TongTien)
	from DonHang
	where NgayDatHang between @Ngaydau and @Ngaycuoi;
end
--- in ra
declare @t1 Money, @t2 Money;
exec sp_ThuNhap '2025-11-01' , '2025-11-03', @t1 out;

exec sp_ThuNhap '2025-11-04' , '2025-11-05', @t2 out;

if @t1 > @t2
	print N'Khoảng thời gian 1 thu nhập lớn hơn ktg2';
else
	print N'Khoảng thời gian 2 thu nhập lớn hơn ktg1';

--- Câu 4. Viết một hàm func_SLSP trả về số lượng đã bán của một sản phẩm với tên sản phẩm là tham số đưa vào. 
create function func_SLSP(@TenSP nvarchar(100))
returns int
as begin
	declare @sl int;
	select @sl = sum(spdh.SoLuong)	
	from SP_DonHang spdh
	join SanPham sp on spdh.IDSanPham = sp.IdSanPham
	where sp.TenSP = @TenSP;
	return @sl;
end
--- a. Gọi hàm trên để đưa ra số lượng đã bán của ‘sữa TH’ 
	SELECT dbo.func_SLSP(N'Lập trình Java') AS SoLuongBan;
--- b. Gọi hàm trên để đưa ra tên những sản phẩm có số lượng bán ít nhất 
	SELECT TenSP
FROM SanPham
WHERE dbo.func_SLSP(TenSP) = (
    SELECT MIN(dbo.func_SLSP(TenSP)) FROM SanPham
);
--- c. Gọi hàm trên để cập nhật lại giá bán giảm đi 10% của những sản phẩm có số lượng bán <100
UPDATE SanPham
SET DonGia = DonGia * 0.9
WHERE dbo.func_SLSP(TenSP) < 100;

--- Câu 5: Viết 1 hàm trả về tổng tiền của 1 hóa đơn bất kỳ 
create function func_TongTienHD(@IDDonHang int)
returns int
as begin
	return(
	select sum(ThanhTien) 
	from SP_DonHang
	where IDDonHang = @IDDonHang
	);
end
--- a. Gọi hàm trên để đưa ra tổng tiền của mỗi hóa đơn mà khách hàng KH1 đã mua 
select dh.IDDonHang,
	dbo.func_TongTienHD(dh.IDDonHang) as TongTienHD
from DonHang dh
where dh.IDKhachHang = '1';	
--- b. Gọi hàm trên để đưa ra tổng tiền của tất cả các hóa đơn mà KH1 đã mua 
select sum(dbo.func_TongTienHD(dh.IDDonHang)) as TongTienDaMua
from DonHang dh
where dh.IDKhachHang = '1';

--- Câu 6. Viết một thủ tục sp_ThongKe để thống kê và in ra màn hình số lượng hóa đơn theo 
--- ngày trong tuần. Ví dụ: Thứ hai: 0 hóa đơn Thứ ba: 1 hóa đơn …. Ví dụ: đối với Thứ Hai, 
--- đây là số lượng hóa đơn của tất cả các ngày thứ 2, chứ không phải số lượng hóa đơn của 
--- một ngày thứ 2 của một tuần nào đó. Cuối cùng, in ra màn hình xem ngày nào trong tuần thường có nhiều người mua hàng nhất.
DROP PROCEDURE IF EXISTS sp_ThongKe;
create proc sp_ThongKe
as begin
	set DateFirst 2;

	declare @ThongKe table (
		Thu int,
		SoLuong int
	);

	insert into @ThongKe(Thu, SoLuong)
	select DATEPART(WEEKDAY, NgayDatHang) as Thu,
	count (*) as SoLuong
	from DonHang
	group by DATEPART(WEEKDAY, NgayDatHang);

	declare @Thu int, @SL int;
	declare cur cursor for
	select Thu, SoLuong from @ThongKe order by Thu;

	open cur;
	fetch next from cur into @Thu,@SL;
	while @@FETCH_STATUS = 0
	begin 
		print 
		CASE @Thu
            WHEN 1 THEN N'Thứ Hai: ' 
            WHEN 2 THEN N'Thứ Ba: '
            WHEN 3 THEN N'Thứ Tư: '
            WHEN 4 THEN N'Thứ Năm: '
            WHEN 5 THEN N'Thứ Sáu: '
            WHEN 6 THEN N'Thứ Bảy: '
            WHEN 7 THEN N'Chủ Nhật: '
		end
		+ cast(@SL as Nvarchar(10)) + N' hóa đơn';
		fetch next from cur into @Thu, @SL;
	end

	close cur;
	deallocate cur;

	declare @MaxThu int, @MaxSL int;

	select top 1 @MaxThu = Thu, @MaxSL = SoLuong
	from @ThongKe
	order by SoLuong DESC;

	PRINT '-------------------------------';
    PRINT 
    N'Ngày có nhiều hóa đơn nhất: ' +
    CASE @MaxThu
        WHEN 1 THEN N'Thứ Hai'
        WHEN 2 THEN N'Thứ Ba'
        WHEN 3 THEN N'Thứ Tư'
        WHEN 4 THEN N'Thứ Năm'
        WHEN 5 THEN N'Thứ Sáu'
        WHEN 6 THEN N'Thứ Bảy'
        WHEN 7 THEN N'Chủ Nhật'
    END
    + N' với ' + CAST(@MaxSL AS NVARCHAR(10)) + N' hóa đơn';
END

exec sp_ThongKe;

--- Câu 7. Viết một thủ tục sp_SPCao đưa ra danh sách các sản phẩm có số lượng bán nhiều 
--- hơn một giá trị x, với x là tham số đưa vào. Danh sách sản phẩm được đưa ra dưới dạng 
--- con trỏ. Đọc nội dung con trỏ và hiển thị ra màn hình danh sách sản phẩm thu được.  
create proc sp_SPCao
	@x int
as begin 
	declare sp_cur cursor for
	select sp.TenSP, sum(spdh.SoLuong) as TongSL
	from SP_DonHang spdh
	join SanPham sp on spdh.IDSanPham = sp.IdSanPham
	group by sp.TenSP
	having sum(spdh.SoLuong) > @x;

	declare @TenSP nvarchar(100), @TongSL int;
	open sp_cur;
	fetch next from sp_cur into @TenSP, @TongSL;

	print N'Danh sách sản phẩm có số lượng bán > ' + cast(@x as nvarchar(10));

	while @@FETCH_STATUS = 0
	begin
		print @TenSP + ' - ' + cast(@TongSL as Nvarchar(10)) + N' sản phẩm';
		fetch next from sp_cur into @TenSP,@TongSL;
	end

	close sp_cur;
	deallocate sp_cur;
end

exec sp_SPCao 2;

--- Câu 8. Viết một thủ tục sp_KH_DonHang có tham số đầu ra là một danh sách IDKhachHang, HoTen, SoDonHang, SoTien và SoSanPham của tất cả các khách hàng 
--- trong hệ thống. Với SoDonHang là tổng số đơn hàng của khách hàng đó, SoTien là tổng số tiền khách hàng đó đã trả cho các hóa đơn, 
--- và SoSanPham là tổng số sản phẩm khách hàng đó đã mua trên tất cả các hóa đơn. Đọc nội dung con trỏ và in ra màn hình thông tin 
--- của từng khách hàng. Với khách hàng chưa từng đặt hàng lần nào, hiển thị là Khách hàng…. chưa từng giao dịch
DROP PROCEDURE IF EXISTS sp_KH_DonHang;
create proc sp_KH_DonHang
as begin
	declare kh_cur cursor for 
	select IDKhachHang, Hoten
	from KhachHang;
	
	declare @IDKhachHang int,
		@HoTen nvarchar(100),
		@SoDonHang int,
		@SoTien money,
		@SoSanPham int;
	open kh_cur;
	fetch next from kh_cur into @IDKhachHang, @Hoten;

	while @@FETCH_STATUS = 0
	begin
		select @SoDonHang = count(*)
		from DonHang
		where IDKhachHang = @IDKhachHang;

		if @SoDonHang = 0
			print N'Khách hàng ' + @HoTen + N' chưa từng giao dịch';
		else 
			begin
			select @SoTien = sum(TongTien)
			from DonHang
			where IDKhachHang = @IDKhachHang;

			select @SoSanPham = sum(spdh.SoLuong)
			from DonHang dh
			join SP_DonHang spdh on dh.IDDonHang = spdh.IDDonHang
			where dh.IDKhachHang = @IDKhachHang;

			PRINT 'Khách hàng: ' + @HoTen;
            PRINT '    ID: ' + CAST(@IDKhachHang AS VARCHAR(10));
            PRINT '    Số đơn hàng: ' + CAST(@SoDonHang AS VARCHAR(10));
            PRINT '    Tổng số tiền: ' + CAST(@SoTien AS VARCHAR(20));
            PRINT '    Tổng sản phẩm đã mua: ' + CAST(@SoSanPham AS VARCHAR(10));
            PRINT '--------------------------------------------------';
			end
		fetch next from kh_cur into @IDKhachHang,@HoTen;
	end
	close kh_cur;
	deallocate kh_cur;
end

exec sp_KH_DonHang;