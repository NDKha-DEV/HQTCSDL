-- Câu 7. Tạo Trigger để đảm bảo rằng khi thêm một loại mặt hàng vào bảng LoaiHang thì tên loại mặt hàng thêm vào phải chưa có trong bảng. 
-- Nếu người dùng nhập một tên loại mặt hàng đã có trong danh sách thì báo lỗi. 
-- Thử thêm một loại mặt hàng vào trong bảng 
-- Câu 7: Trigger kiểm tra trùng lặp Tên Loại Hàng khi INSERT
drop trigger if exists trg_LoaiHang_Insert
create trigger trg_LoaiHang_Insert
on LoaiHang
after insert
as
begin
    if exists (select 1 from inserted i
    join LoaiHang lh on i.TenLoaiHang = lh.TenLoaiHang
    where i.IDLoaiHang != lh.IDLoaiHang 
    )
    begin
        print N'Lỗi: Tên loại mặt hàng vừa thêm đã tồn tại trong danh sách'
        rollback tran
        return
    end
end

INSERT INTO LoaiHang (IDLoaiHang, TenLoaiHang, MoTa) VALUES
(6, N'Mỹ Phẩm', N'Các sản phẩm chăm sóc sắc đẹp và cá nhân.'); 
INSERT INTO LoaiHang (IDLoaiHang, TenLoaiHang, MoTa) VALUES
(5, N'Điện Tử', N'Các sản phẩm công nghệ.'); 

select * from LoaiHang
-- update của câu 7: insert nhiều loại cùng lúc và thêm những loại được và thông báo loại không được
-- cách 1: thử dùng instead of
drop trigger if exists trg_LoaiHang_Insert_insteadOf
create trigger trg_LoaiHang_Insert_insteadOf
on LoaiHang 
instead of insert
as 
begin
    select N'Loi: Ten mat hang da ton tai: ' + i.TenLoaiHang
    from inserted i
    join LoaiHang lh on i.TenLoaiHang = lh.TenLoaiHang

    insert into LoaiHang(IDLoaiHang,TenLoaiHang,MoTa)
    select i.IDLoaiHang,i.TenLoaiHang, i.MoTa
    from inserted i
    where not exists (
        select * from LoaiHang lh 
        where lh.TenLoaiHang = i.TenLoaiHang
        );
end

INSERT INTO LoaiHang (IDLoaiHang, TenLoaiHang, MoTa) VALUES
(5, N'Điện Tử', N'Các sản phẩm công nghệ.'),
(6, N'Mỹ Phẩm', N'Các sản phẩm chăm sóc sắc đẹp và cá nhân.'),
(7, N'Quần áo',N'Các sản phẩm để mặc'); 
delete from LoaiHang where IDLoaiHang = 7;
select * from LoaiHang



-- Câu 8. Tạo Trigger để đảm bảo rằng khi sửa một loại mặt hàng trong bảng LoaiHang 
-- thì tên loại mặt hàng sau khi sửa phải khác tên loai mặt hàng trước khi sửa và tên loại 
-- mặt hàng sau khi sửa không trùng với tên các loại hàng đã có trong bảng. Nếu vi phạm thì thông báo lỗi. 
drop trigger if exists trg_LoaiHang_Update
create trigger trg_LoaiHang_Update
on LoaiHang
after update 
as 
begin
    if exists(
        select 1 from deleted d
        join inserted i on d.IDLoaiHang = i.IDLoaiHang
        where d.TenLoaiHang = i.TenLoaiHang
    )
    begin 
        print N'Lỗi: Tên loại mặt hàng sau khi sửa phải khác tên loại hàng ban đầu.'
        rollback tran
        return
    end
    if exists (
        select 1 from inserted i
        join LoaiHang lh on i.TenLoaiHang = lh.TenLoaiHang
        where i.IDLoaiHang != lh.IDLoaiHang
    )
    begin
        print N'Lỗi: Tên loại mặt hàng sau khi sửa đã trùng với tên loại hàng khác.'
        rollback tran
        return
    end
end
UPDATE LoaiHang SET TenLoaiHang = N'Mỹ Phẩm' WHERE IDLoaiHang = 4;

