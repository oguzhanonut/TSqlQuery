create proc proc_KitapBilgi
@isbn int
as
select isbn,kitap_adi,sayfa_sayisi  from tbl_kitaplar where isbn=@isbn

exec proc_KitapBilgi 123456784 ;

-----------------------------------------

create proc proc_kitapsayisi
@k_isim varchar(50)
as
select yazar_adi,yazar_soyadi,
	(select sum(adet) from tbl_kitap_yazar,tbl_kitap_kutuphane
	where yazar_no=tbl_yazarlar.yazar_no
	and tbl_kitap_kutuphane.isbn=tbl_kitap_yazar.isbn
	and kutuphane_no=(select kutuphane_no from tbl_kutuphane where kutuphane_ismi=@k_isim)
	) as "kitap sayisi"
	
from tbl_yazarlar order by yazar_adi;


exec proc_kitapsayisi 'turhal'


-----------------------------------------------
create proc proc_emanet
@uye_no int
as
select emanet_no,isbn,u.uye_no,emanet_tarihi,teslim_tarihi,kutuphane_ismi,aciklama,a.sehir,a.mahalle,a.cadde,a.bina_no   from tbl_emanet  e
inner join tbl_kutuphane k on k.kutuphane_no=e.kutuphane_no
inner join tbl_uyeler u on u.uye_no=e.uye_no
inner join tbl_adresler a on a.adres_no=u.adres_no
where u.uye_no=@uye_no

exec proc_emanet 3

-------------------------------------------------
create proc sp_adres_guncelle
@adresno as tinyint,
@cadde as varchar(max),
@mahalle as varchar(max),
@binano as varchar(max),
@sehir as varchar(max),
@postakodu as varchar(max),
@ulke as varchar(max)
as
begin
	update tbl_adresler
	set cadde=@cadde, mahalle=@mahalle, bina_no=@binano, sehir=@sehir, posta_kodu=@postakodu, ulke=@ulke
	where adres_no=@adresno
end

exec sp_adres_guncelle 1,'cumhuriyet','barýþ','9','karabük','78000','Türkiye'

----------------------------------------------------
alter proc sp_yazar_ekle
@yazar_adi as varchar(max),
@yazar_soyadi as varchar(max)
as

begin
	insert into tbl_yazarlar
	(yazar_adi,yazar_soyadi)
	values
	(@yazar_adi,@yazar_soyadi)

end

exec sp_yazar_ekle 'Sinan','Ateþ'

----------------------------------------
create proc sp_uye_sil
@uye_adi as varchar(max),
@uye_soyadi as varchar(max)
as
begin
	delete from tbl_uyeler where uye_adi=@uye_adi and uye_soyadi=@uye_soyadi
	print('sildim !!!')


end

exec sp_uye_sil 'turgut','özseven'

----------------------------------------
create trigger tgr_uyekalýntýsil
on tbl_emanet
after delete
as
begin

	declare @uyeno as int
	select uye_no=@uyeno from deleted
	delete from tbl_emanet where uye_no=@uyeno


end
--------------------------------------
create trigger tgr_kitapEmanet
on tbl_kitaplar
after insert
as
update tbl_emanet
set emanet_tarihi=GETDATE() where emanet_tarihi is null;

----------------------------------------------
create nonclustered index i_uyeler
on tbl_uyeler(telefon) 

select telefon from tbl_uyeler

create nonclustered index i_yazar
on tbl_yazarlar(yazar_adi)


select yazar_adi from tbl_yazarlar

create nonclustered index i_kitap
on tbl_kitaplar(kitap_adi)


select kitap_adi from tbl_kitaplar

-------------------------------------------------------
create function dbo.kitapsayisi(@kutupad as varchar(max))
returns table
as
return
(
select k.kutuphane_ismi,k.aciklama,sum(kk.adet) as [Toplam Kitap Sayýsý] from tbl_kitap_kutuphane kk
inner join tbl_kutuphane k on k.kutuphane_no=kk.kutuphane_no
where k.kutuphane_ismi=@kutupad
group by k.kutuphane_ismi,k.aciklama

)

select * from dbo.kitapsayisi('zile')

