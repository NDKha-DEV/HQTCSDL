-- sử dụng con trỏ để in ra doanh thu theo mỗi ngày
declare @NgayBan datetime, @DoanhThu decimal(18,2);

declare curDoanhThu cursor dynamic scroll for 
	select NgayDatHang, sum(TongTien) as DoanhThu
	from DonHang
	group by NgayDatHang

open curDoanhThu;
fetch next from curDoanhThu into @NgayBan, @DoanhThu;
while @@FETCH_STATUS = 0
begin 
	print N'Ngay: ' + convert(varchar(20), @NgayBan) + N' co doanh thu: ' + convert(varchar(20),@DoanhThu);
	
	fetch next from curDoanhThu into @NgayBan, @DoanhThu;
end
 close curDoanhThu;
 deallocate curDoanhThu;

 -- sử dụng con trỏ để in ra tên khách hàng và số lần mua hàng của khách hàng
 declare @TenKH nvarchar(50), @SoLanMua int;

 declare curSLM cursor dynamic scroll for
	select kh.HoTen, count(dh.IDDonHang) as SoLanMua from KhachHang kh
	left join DonHang dh on kh.IDKhachHang = dh.IDKhachHang
	group by kh.HoTen;
open curSLM;
fetch next from curSLM into @TenKH,@SoLanMua;

while @@FETCH_STATUS = 0
begin
	print N'ten khach hang: ' + @TenKH
	+ N' so lan mua: ' + convert(nvarchar(20),@SoLanMua);
	fetch next from curSLM into @TenKH,@SoLanMua;
end
close curSLM;
deallocate curSLM;
-- tổng số lượng sản phẩm đã bán của từng sản phẩm
-- sử dụng con trỏ để cập nhật lại đơn giá bán giảm 10% cho những sản phẩm chưa từng được mua
declare @IDSP int, @DonGia decimal(18,2);

declare cur_GiamGia cursor dynamic scroll for
	select sp.IdSanPham, sp.DonGia from SanPham sp
	left join SP_DonHang spdh on sp.IdSanPham = spdh.IDSanPham
	where spdh.IDDonHang is null;
open cur_GiamGia;
fetch next from cur_GiamGia into @IDSP,@DonGia;

while @@FETCH_STATUS = 0
begin
	update SanPham
	set DonGia = @DonGia*0.9
	where IdSanPham = @IDSP;

	print N'Giam gia 10% cho san pham co ID: ' + convert(nvarchar(50),@IDSP);
	fetch next from cur_GiamGia into @IDSP,@DonGia;
end
close cur_GiamGia;
deallocate cur_GiamGia;
-- sử dụng con trỏ để cập nhật trường ghi chú thành chưa từng mua hàng đối với khách hàng chưa bao giờ mua hàng
ALTER TABLE KhachHang ADD GhiChu NVARCHAR(200) NULL;

declare @IDKH int, @Hoten nvarchar(100);

declare cur_KH_CM cursor dynamic scroll for
	select IDKhachHang, HoTen from KhachHang kh
	where not exists (
		select 1 from DonHang dh 
		where dh.IDKhachHang = kh.IDKhachHang);
open cur_KH_CM;
fetch next from cur_KH_CM into @IDKH, @HoTen;
while @@FETCH_STATUS = 0
begin 
	update KhachHang
	set GhiChu = N'Chua tung mua hang'
	where IDKhachHang = @IDKH;

	print N'Cap nhat khach hang: ' + @HoTen + N'ID = ' + convert(nvarchar(20),@IDKH) + N')';
	fetch next from cur_KH_CM into @IDKH, @HoTen;
end
close cur_KH_CM;
deallocate cur_KH_CM;