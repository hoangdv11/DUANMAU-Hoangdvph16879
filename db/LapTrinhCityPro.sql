USE [master]
GO
/****** Object:  Database [LapTrinhCityPro]    Script Date: 19/10/2021 3:31:31 CH ******/
CREATE DATABASE [LapTrinhCityPro]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LapTrinhCityPro', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LapTrinhCityPro.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'LapTrinhCityPro_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LapTrinhCityPro_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [LapTrinhCityPro] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LapTrinhCityPro].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LapTrinhCityPro] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET ARITHABORT OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [LapTrinhCityPro] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LapTrinhCityPro] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LapTrinhCityPro] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET  DISABLE_BROKER 
GO
ALTER DATABASE [LapTrinhCityPro] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LapTrinhCityPro] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [LapTrinhCityPro] SET  MULTI_USER 
GO
ALTER DATABASE [LapTrinhCityPro] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LapTrinhCityPro] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LapTrinhCityPro] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [LapTrinhCityPro] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [LapTrinhCityPro]
GO
/****** Object:  StoredProcedure [dbo].[SP_BangDiem]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_BangDiem](@MaKH int)
AS
BEGIN
	SELECT nh.MaNH, nh.HoTen, Diem
	FROM HocVien hv join NguoiHoc nh on hv.MaNH = nh.MaNH
	where hv.MaKH = @MaKH
	order by Diem desc
END

GO
/****** Object:  StoredProcedure [dbo].[SP_DangNhap]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DangNhap]
    @MaNV varchar(10),
    @MatKhau varchar(50),
	@ok bit OUTPUT,
    @responseMessage NVARCHAR(250)='' OUTPUT
AS
BEGIN

    SET NOCOUNT ON

    IF EXISTS (SELECT TOP 1 MaNV FROM NhanVien WHERE MaNV=@MaNV)
    BEGIN
       IF((SELECT MaNV FROM NhanVien WHERE MaNV=@MaNV AND MatKhau=HASHBYTES('SHA2_512', @MatKhau+CAST(Salt AS NVARCHAR(36)))) IS NULL)
			BEGIN
			   SET @responseMessage=N'Mật khẩu không hợp lệ'
			   SET @ok = 0
			END
       ELSE 
		   BEGIN
			   SET @responseMessage=N'Đăng nhập thành công'
			   SET @ok = 1
			END
    END
    ELSE
		BEGIN
		   SET @responseMessage=N'Tên đăng nhập không hợp lệ'
		   SET @ok = 0
	   END

END

GO
/****** Object:  StoredProcedure [dbo].[SP_DiemChuyenDe]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DiemChuyenDe]
AS
BEGIN
	SELECT TenCD ChuyenDe, COUNT(MaHV) SoHocVien, MAX(Diem) DiemCaoNhat,
	MIN(Diem) DiemThapNhat, AVG(Diem) DiemTrungBinh
	FROM ChuyenDe cd join KhoaHoc kh on cd.MaCD = kh.MaCD
					join HocVien hv on kh.MaKH = hv.MaKH
	group by TenCD
END

GO
/****** Object:  StoredProcedure [dbo].[SP_DoanhThu]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DoanhThu] @Year int
AS
BEGIN
	SELECT TenCD ChuyenDe, COUNT(DISTINCT kh.MaKH) SoKhoaHoc, COUNT(hv.MaHV) SoHocVien,
			SUM(kh.HocPhi) DoanhThu,
			MAX(kh.HocPhi) HocPhiCaoNhat,
			MIN(kh.HocPhi) HocPhiThapNhat, AVG(kh.HocPhi) HocPhiTrungBinh
	FROM ChuyenDe cd join KhoaHoc kh on cd.MaCD = kh.MaCD
					join HocVien hv on hv.MaKH = kh.MaKH
	where YEAR(NgayKG) = @Year
	group by TenCD
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DoanhThuLoiNhuan]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DoanhThuLoiNhuan] @Year int
AS
BEGIN
	declare @luongNV float, @luongND float
	select @luongNV = (select SUM(Luong) from NhanVien)
	select @luongND = (select SUM(Luong) from NguoiDay)
	select SUM(HocPhi) DoanhThu, (@luongND + @luongNV) ChiPhi, (SUM(HocPhi) - (@luongND + @luongNV)) LoiNhuan
	from KhoaHoc kh join HocVien hv on hv.MaKH = kh.MaKH
	where YEAR(NgayKG) = @Year
END


GO
/****** Object:  StoredProcedure [dbo].[SP_DoiMatKhau]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DoiMatKhau] 
	@MaNV varchar(10),
    @MatKhau varchar(50),
	@MatKhauMoi varchar(50),
	@XacNhanMKMoi varchar(50),
	@ok bit OUTPUT,
    @responseMessage NVARCHAR(250)='' OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

       IF((SELECT MaNV FROM NhanVien WHERE MaNV=@MaNV AND MatKhau=HASHBYTES('SHA2_512', @MatKhau+CAST(Salt AS NVARCHAR(36)))) IS NULL)
			BEGIN
			   SET @responseMessage=N'Mật khẩu hiện tại không hợp lệ'
			   SET @ok = 0
			END
       ELSE 
			IF(@MatKhauMoi = @XacNhanMKMoi)
		   BEGIN
				DECLARE @Salt UNIQUEIDENTIFIER = NEWID()
				UPDATE NhanVien
				SET MatKhau=HASHBYTES('SHA2_512', @MatKhauMoi+CAST(@Salt AS NVARCHAR(36))), Salt = @Salt
				WHERE MaNV=@MaNV
			   SET @responseMessage=N'Đổi mật khẩu thành công'
			   SET @ok = 1
			END
			ELSE
				BEGIN
					SET @responseMessage=N'Xác nhận mật khẩu không hợp lệ'
					SET @ok = 0
				END
END

GO
/****** Object:  StoredProcedure [dbo].[SP_LuongNguoiHoc]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_LuongNguoiHoc]
AS
BEGIN
	SELECT YEAR(NgayDK) Nam, COUNT(*) SoLuong,
			MIN(NgayDK) DangKySomNhat, MAX(NgayDK) DangKyMuonNhat
	from NguoiHoc
	group by YEAR(NgayDK)
END

GO
/****** Object:  StoredProcedure [dbo].[SP_ThemNhanVien]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ThemNhanVien]
	-- Add the parameters for the stored procedure here
	@MaNV varchar(10),
    @MatKhau varchar(50),
    @HoTen nvarchar(50),
    @VaiTro bit,
    @Luong float
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Salt UNIQUEIDENTIFIER = NEWID()

	INSERT INTO NhanVien (MaNV,MatKhau,HoTen,VaiTro,Luong,Salt)
	values (@MaNV,HASHBYTES('SHA2_512', @MatKhau+CAST(@Salt as nvarchar(36))), @HoTen,@VaiTro,@Luong,@Salt)
END
GO
/****** Object:  StoredProcedure [dbo].[SP_TopChuyenDe]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_TopChuyenDe]
AS
BEGIN
	declare @maxCD nvarchar(50), @minCD nvarchar(50), @maxKH nvarchar(50), @minKH nvarchar(50)
	select @maxCD = (select top 1 TenCD
						from ChuyenDe cd join KhoaHoc kh on cd.MaCD = kh.MaCD
										join HocVien hv on hv.MaKH = kh.MaKH
						group by TenCD
						order by COUNT(MaHV) desc)
	select @maxKH = (select top 1 TenKH
						from KhoaHoc kh join HocVien hv on hv.MaKH = kh.MaKH
						group by TenKH
						order by COUNT(MaHV) desc)
	select @minCD = (select top 1 TenCD
						from ChuyenDe cd join KhoaHoc kh on cd.MaCD = kh.MaCD
										join HocVien hv on hv.MaKH = kh.MaKH
						group by TenCD
						order by COUNT(MaHV))
	select @minKH = (select top 1 TenKH
						from KhoaHoc kh join HocVien hv on hv.MaKH = kh.MaKH
						group by TenKH
						order by COUNT(MaHV))
	select @maxCD maxCD, @maxKH maxKH, @minCD minCD, @minKH minKH
END
GO
/****** Object:  Table [dbo].[ChuyenDe]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChuyenDe](
	[MaCD] [varchar](10) NOT NULL,
	[TenCD] [nvarchar](50) NOT NULL,
	[HocPhi] [float] NOT NULL,
	[ThoiLuong] [int] NOT NULL CONSTRAINT [DF_ChuyenDe_ThoiLuong]  DEFAULT ((36)),
	[Hinh] [varchar](50) NOT NULL,
	[MoTa] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_ChuyenDe] PRIMARY KEY CLUSTERED 
(
	[MaCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GiangVien]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GiangVien](
	[MaGV] [int] IDENTITY(1,1) NOT NULL,
	[MaND] [varchar](10) NOT NULL,
	[MaKH] [int] NOT NULL,
	[GhiChu] [nvarchar](500) NULL,
 CONSTRAINT [PK_GiangVien] PRIMARY KEY CLUSTERED 
(
	[MaGV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HocVien]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HocVien](
	[MaHV] [int] IDENTITY(1,1) NOT NULL,
	[MaKH] [int] NOT NULL,
	[MaNH] [varchar](10) NOT NULL,
	[Diem] [float] NOT NULL,
 CONSTRAINT [PK_HocVien] PRIMARY KEY CLUSTERED 
(
	[MaHV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[KhoaHoc]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KhoaHoc](
	[MaKH] [int] IDENTITY(1,1) NOT NULL,
	[TenKH] [nvarchar](50) NOT NULL,
	[MaCD] [varchar](10) NOT NULL,
	[HocPhi] [float] NOT NULL,
	[ThoiLuong] [int] NOT NULL CONSTRAINT [DF_KhoaHoc_ThoiLuong]  DEFAULT ((36)),
	[NgayKG] [date] NOT NULL,
	[GhiChu] [nvarchar](500) NULL,
	[MaNV] [varchar](10) NOT NULL,
	[NgayTao] [date] NOT NULL CONSTRAINT [DF_KhoaHoc_NgayTao]  DEFAULT (getdate()),
 CONSTRAINT [PK_KhoaHoc] PRIMARY KEY CLUSTERED 
(
	[MaKH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NguoiDay]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NguoiDay](
	[MaND] [varchar](10) NOT NULL,
	[HoTen] [nvarchar](50) NOT NULL,
	[NgaySinh] [date] NOT NULL,
	[GioiTinh] [bit] NOT NULL CONSTRAINT [DF_NguoiDay_GioiTinh]  DEFAULT ((1)),
	[DienThoai] [varchar](15) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[Luong] [float] NOT NULL,
	[MaNV] [varchar](10) NOT NULL,
	[NgayDK] [date] NOT NULL CONSTRAINT [DF_NguoiDay_NgayDK]  DEFAULT (getdate()),
	[GhiChu] [nvarchar](500) NULL,
 CONSTRAINT [PK_NguoiDay] PRIMARY KEY CLUSTERED 
(
	[MaND] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NguoiHoc]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NguoiHoc](
	[MaNH] [varchar](10) NOT NULL,
	[HoTen] [nvarchar](50) NOT NULL,
	[GioiTinh] [bit] NOT NULL CONSTRAINT [DF_NguoiHoc_GioiTinh]  DEFAULT ((1)),
	[NgaySinh] [date] NOT NULL,
	[DienThoai] [varchar](15) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[GhiChu] [nvarchar](500) NULL,
	[MaNV] [varchar](10) NOT NULL,
	[NgayDK] [date] NOT NULL CONSTRAINT [DF_NguoiHoc_NgayDK]  DEFAULT (getdate()),
 CONSTRAINT [PK_NguoiHoc] PRIMARY KEY CLUSTERED 
(
	[MaNH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 19/10/2021 3:31:31 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NhanVien](
	[MaNV] [varchar](10) NOT NULL,
	[MatKhau] [binary](64) NOT NULL,
	[HoTen] [nvarchar](50) NOT NULL,
	[VaiTro] [bit] NOT NULL CONSTRAINT [DF_NhanVien_VaiTro]  DEFAULT ((0)),
	[Luong] [float] NOT NULL,
	[Salt] [uniqueidentifier] NULL,
	[TrangThai] [bit] NOT NULL CONSTRAINT [DF_NhanVien_TrangThai]  DEFAULT ((1)),
 CONSTRAINT [PK_NhanVien] PRIMARY KEY CLUSTERED 
(
	[MaNV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'CCPP', N'Lập trình với C/C++', 350, 72, N'c.png', N'Nhập môn')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'CS', N'Lập trình với C#', 2150, 108, N'c#.png', N'Back-end')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'DB', N'Lập trình cơ sở dữ liệu', 750, 72, N'csdl.png', N'Back-end')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'DSML', N'Khoa học dữ liệu và Học máy', 6300, 378, N'dsml.jpg', N'Mở rộng')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'INFO', N'Tin học văn phòng', 450, 72, N'mos.jpg', N'Cơ bản')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'IOS', N'Lập trình IOS', 1400, 36, N'ios.png', N'Mở rộng')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'JAV', N'Lập trình với Java', 1950, 108, N'java.png', N'Back-end')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'MATH', N'Toán cho lập trình', 550, 144, N'math.jpg', N'Bổ trợ')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'RENA', N'Lập trình React Native', 1600, 108, N'reactnative.png', N'Mở rộng')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'WEB', N'Thiết kế Website', 4200, 342, N'web.jpg', N'Full-stack')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'ZAZA', N'demo1', 1, 1, N'PolyBee.png', N'None')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'ZIZI', N'demo2', 1, 1, N'PolyBee.png', N'None')
GO
INSERT [dbo].[ChuyenDe] ([MaCD], [TenCD], [HocPhi], [ThoiLuong], [Hinh], [MoTa]) VALUES (N'ZOZO', N'demo3', 1, 1, N'PolyBee.png', N'None')
GO
SET IDENTITY_INSERT [dbo].[GiangVien] ON 

GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (1, N'ND08', 1, N'Java')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (4, N'ND10', 2, N'C#')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (5, N'ND08', 3, N'Java')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (6, N'ND10', 4, N'C#')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (7, N'ND07', 5, N'Web')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (8, N'ND07', 7, N'Web')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (9, N'ND07', 8, N'Web')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (10, N'ND07', 9, N'Web')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (12, N'ND11', 11, N'Web')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (13, N'ND11', 12, N'Web')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (14, N'ND11', 13, N'Web')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (15, N'ND06', 14, N'C/C++')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (16, N'ND06', 15, N'C/C++')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (17, N'ND09', 16, N'CSDL')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (18, N'ND09', 17, N'CSDL')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (19, N'ND04', 18, N'Infomatics')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (20, N'ND04', 19, N'Infomatics')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (21, N'ND03', 20, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (22, N'ND03', 21, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (23, N'ND03', 22, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (24, N'ND03', 23, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (25, N'ND12', 24, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (27, N'ND12', 25, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (28, N'ND12', 26, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (29, N'ND01', 27, N'IOS')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (30, N'ND01', 28, N'IOS')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (31, N'ND05', 29, N'React Native')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (32, N'ND05', 30, N'React Native')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (34, N'ND02', 32, N'Math')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (35, N'ND02', 33, N'Math')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (36, N'ND02', 34, N'Math')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (37, N'ND02', 35, N'Math')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (54, N'ND03', 41, N'DSML')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (61, N'ND06', 36, N'C')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (62, N'ND06', 37, N'C++')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (63, N'ND06', 46, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (64, N'ND06', 47, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (65, N'ND10', 38, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (66, N'ND10', 39, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (67, N'ND04', 50, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (68, N'ND04', 51, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (69, N'ND10', 75, N'C#')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (70, N'ND10', 76, N'C#')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (71, N'ND09', 44, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (72, N'ND09', 45, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (73, N'ND03', 69, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (74, N'ND03', 70, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (75, N'ND03', 71, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (76, N'ND12', 72, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (77, N'ND12', 73, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (78, N'ND12', 74, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (79, N'ND01', 63, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (80, N'ND12', 64, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (81, N'ND01', 64, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (82, N'ND08', 59, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (83, N'ND08', 60, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (84, N'ND08', 61, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (85, N'ND08', 62, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (86, N'ND05', 65, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (87, N'ND05', 66, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (88, N'ND05', 67, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (89, N'ND05', 68, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (90, N'ND07', 52, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (91, N'ND07', 53, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (92, N'ND07', 54, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (93, N'ND07', 55, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (94, N'ND11', 56, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (95, N'ND11', 57, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (96, N'ND11', 58, N'')
GO
INSERT [dbo].[GiangVien] ([MaGV], [MaND], [MaKH], [GhiChu]) VALUES (104, N'ND05', 82, N'Ca 4')
GO
SET IDENTITY_INSERT [dbo].[GiangVien] OFF
GO
SET IDENTITY_INSERT [dbo].[HocVien] ON 

GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (2, 1, N'NH01', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (6, 2, N'NH01', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (9, 4, N'NH02', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (10, 2, N'NH02', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (11, 4, N'NH01', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (12, 1, N'NH02', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (253, 20, N'NH01', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (254, 20, N'NH03', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (255, 20, N'NH05', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (256, 20, N'NH06', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (257, 20, N'NH08', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (258, 20, N'NH10', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (259, 20, N'NH14', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (260, 20, N'NH16', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (261, 20, N'NH20', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (262, 20, N'NH21', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (263, 20, N'NH24', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (264, 20, N'NH28', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (265, 20, N'NH30', 1.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (266, 20, N'NH34', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (267, 20, N'NH37', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (268, 20, N'NH39', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (269, 20, N'NH41', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (270, 20, N'NH43', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (271, 20, N'NH45', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (272, 20, N'NH49', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (273, 21, N'NH02', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (274, 21, N'NH04', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (275, 21, N'NH07', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (276, 21, N'NH10', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (277, 21, N'NH12', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (278, 21, N'NH14', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (279, 21, N'NH17', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (280, 21, N'NH22', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (281, 21, N'NH26', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (282, 21, N'NH30', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (283, 21, N'NH34', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (284, 21, N'NH37', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (285, 21, N'NH39', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (286, 21, N'NH43', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (287, 21, N'NH45', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (288, 21, N'NH49', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (289, 22, N'NH02', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (290, 22, N'NH03', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (291, 22, N'NH06', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (292, 22, N'NH09', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (293, 22, N'NH14', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (294, 22, N'NH20', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (295, 22, N'NH24', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (296, 22, N'NH30', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (297, 22, N'NH34', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (298, 22, N'NH38', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (299, 22, N'NH44', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (300, 22, N'NH49', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (301, 23, N'NH03', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (302, 23, N'NH06', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (303, 23, N'NH12', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (304, 23, N'NH20', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (305, 23, N'NH23', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (306, 23, N'NH26', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (307, 23, N'NH31', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (308, 23, N'NH33', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (309, 23, N'NH39', 0.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (310, 23, N'NH42', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (311, 23, N'NH47', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (312, 23, N'NH50', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (313, 24, N'NH02', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (314, 24, N'NH06', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (315, 24, N'NH09', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (316, 24, N'NH12', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (317, 24, N'NH17', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (318, 24, N'NH18', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (319, 24, N'NH22', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (320, 24, N'NH25', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (321, 24, N'NH31', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (322, 24, N'NH36', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (323, 24, N'NH40', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (324, 24, N'NH45', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (325, 24, N'NH49', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (326, 25, N'NH04', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (327, 25, N'NH10', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (328, 25, N'NH14', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (329, 25, N'NH16', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (330, 25, N'NH19', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (331, 25, N'NH23', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (332, 25, N'NH24', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (333, 25, N'NH29', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (334, 25, N'NH30', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (335, 25, N'NH35', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (336, 25, N'NH38', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (337, 25, N'NH42', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (338, 25, N'NH45', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (339, 25, N'NH50', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (340, 26, N'NH01', 0.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (341, 26, N'NH05', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (342, 26, N'NH08', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (343, 26, N'NH11', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (344, 26, N'NH14', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (345, 26, N'NH19', 1.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (346, 26, N'NH23', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (347, 26, N'NH25', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (348, 26, N'NH27', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (349, 26, N'NH32', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (350, 26, N'NH37', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (351, 26, N'NH42', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (352, 26, N'NH47', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (353, 26, N'NH50', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (354, 26, N'NH06', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (360, 41, N'NH01', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (361, 41, N'NH05', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (362, 41, N'NH10', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (363, 41, N'NH12', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (364, 41, N'NH17', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (365, 41, N'NH21', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (366, 41, N'NH24', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (367, 41, N'NH29', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (368, 41, N'NH36', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (369, 41, N'NH40', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (370, 41, N'NH43', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (371, 41, N'NH46', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (372, 41, N'NH49', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (373, 41, N'NH15', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (374, 41, N'NH18', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (375, 41, N'NH23', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (376, 41, N'NH26', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (377, 41, N'NH31', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (378, 41, N'NH32', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (379, 41, N'NH38', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (381, 69, N'NH01', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (382, 69, N'NH03', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (383, 69, N'NH06', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (384, 69, N'NH10', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (385, 69, N'NH14', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (386, 69, N'NH16', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (387, 69, N'NH21', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (388, 69, N'NH39', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (389, 69, N'NH42', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (390, 69, N'NH46', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (391, 69, N'NH50', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (392, 70, N'NH03', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (393, 70, N'NH06', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (394, 70, N'NH10', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (395, 70, N'NH14', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (396, 70, N'NH16', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (397, 70, N'NH19', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (398, 70, N'NH23', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (399, 70, N'NH27', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (400, 70, N'NH29', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (401, 70, N'NH33', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (402, 70, N'NH36', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (403, 70, N'NH42', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (404, 70, N'NH46', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (405, 70, N'NH49', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (406, 71, N'NH03', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (407, 71, N'NH07', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (408, 71, N'NH11', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (409, 71, N'NH15', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (410, 71, N'NH22', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (411, 71, N'NH26', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (412, 71, N'NH37', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (413, 71, N'NH41', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (414, 71, N'NH46', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (415, 71, N'NH49', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (416, 72, N'NH03', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (417, 72, N'NH07', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (418, 72, N'NH11', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (419, 72, N'NH15', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (420, 72, N'NH19', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (421, 72, N'NH25', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (422, 72, N'NH27', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (423, 72, N'NH30', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (424, 72, N'NH35', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (425, 72, N'NH40', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (426, 72, N'NH44', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (427, 72, N'NH49', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (428, 73, N'NH03', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (429, 73, N'NH08', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (430, 73, N'NH12', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (431, 73, N'NH15', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (432, 73, N'NH19', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (433, 73, N'NH22', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (434, 73, N'NH24', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (435, 73, N'NH30', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (436, 73, N'NH38', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (437, 73, N'NH42', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (438, 73, N'NH45', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (439, 73, N'NH49', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (440, 74, N'NH03', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (441, 74, N'NH04', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (442, 74, N'NH09', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (443, 74, N'NH13', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (444, 74, N'NH16', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (445, 74, N'NH20', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (446, 74, N'NH24', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (447, 74, N'NH27', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (448, 74, N'NH32', 0.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (449, 74, N'NH34', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (450, 74, N'NH40', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (451, 74, N'NH44', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (452, 74, N'NH47', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (453, 74, N'NH50', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (454, 14, N'NH01', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (455, 14, N'NH02', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (456, 14, N'NH06', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (457, 14, N'NH10', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (458, 14, N'NH15', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (459, 14, N'NH23', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (460, 14, N'NH26', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (461, 14, N'NH31', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (462, 14, N'NH38', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (463, 14, N'NH42', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (464, 14, N'NH46', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (465, 14, N'NH50', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (466, 14, N'NH09', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (467, 14, N'NH13', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (468, 14, N'NH18', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (469, 15, N'NH03', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (470, 15, N'NH06', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (471, 15, N'NH10', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (472, 15, N'NH12', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (473, 15, N'NH13', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (474, 15, N'NH21', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (475, 15, N'NH26', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (476, 15, N'NH31', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (477, 15, N'NH36', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (478, 15, N'NH40', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (479, 15, N'NH45', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (480, 15, N'NH49', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (481, 15, N'NH09', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (482, 15, N'NH19', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (483, 15, N'NH25', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (484, 36, N'NH04', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (485, 36, N'NH09', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (486, 36, N'NH13', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (487, 36, N'NH14', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (488, 36, N'NH19', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (489, 36, N'NH22', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (490, 36, N'NH24', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (491, 36, N'NH29', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (492, 36, N'NH37', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (493, 36, N'NH40', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (494, 36, N'NH43', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (495, 36, N'NH49', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (496, 36, N'NH10', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (497, 36, N'NH18', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (498, 36, N'NH05', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (499, 37, N'NH03', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (500, 37, N'NH06', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (501, 37, N'NH10', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (502, 37, N'NH13', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (503, 37, N'NH18', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (504, 37, N'NH24', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (505, 37, N'NH29', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (506, 37, N'NH31', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (507, 37, N'NH34', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (508, 37, N'NH37', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (509, 37, N'NH40', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (510, 37, N'NH44', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (511, 37, N'NH48', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (512, 37, N'NH35', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (513, 37, N'NH46', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (514, 46, N'NH02', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (515, 46, N'NH05', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (516, 46, N'NH08', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (517, 46, N'NH10', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (518, 46, N'NH14', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (519, 46, N'NH18', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (520, 46, N'NH21', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (521, 46, N'NH24', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (522, 46, N'NH26', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (523, 46, N'NH29', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (524, 46, N'NH31', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (525, 46, N'NH35', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (526, 46, N'NH39', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (527, 46, N'NH40', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (528, 46, N'NH47', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (530, 47, N'NH03', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (531, 47, N'NH08', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (532, 47, N'NH10', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (533, 47, N'NH15', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (534, 47, N'NH17', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (535, 47, N'NH22', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (536, 47, N'NH24', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (537, 47, N'NH28', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (538, 47, N'NH30', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (539, 47, N'NH31', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (540, 47, N'NH35', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (541, 47, N'NH39', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (542, 47, N'NH43', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (543, 47, N'NH46', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (544, 47, N'NH50', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (545, 2, N'NH05', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (546, 2, N'NH07', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (547, 2, N'NH09', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (548, 2, N'NH12', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (549, 2, N'NH16', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (550, 2, N'NH19', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (551, 2, N'NH23', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (552, 2, N'NH27', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (553, 2, N'NH30', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (554, 2, N'NH34', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (555, 2, N'NH36', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (556, 2, N'NH39', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (557, 2, N'NH41', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (560, 4, N'NH07', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (561, 4, N'NH11', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (562, 4, N'NH15', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (563, 4, N'NH19', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (564, 4, N'NH22', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (565, 4, N'NH24', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (566, 4, N'NH28', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (567, 4, N'NH37', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (568, 4, N'NH40', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (569, 4, N'NH44', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (570, 4, N'NH46', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (571, 4, N'NH47', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (572, 4, N'NH49', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (573, 38, N'NH02', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (574, 38, N'NH05', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (575, 38, N'NH08', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (576, 38, N'NH10', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (577, 38, N'NH13', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (578, 38, N'NH16', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (579, 38, N'NH20', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (580, 38, N'NH23', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (581, 38, N'NH26', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (582, 38, N'NH31', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (583, 38, N'NH34', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (584, 38, N'NH36', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (585, 38, N'NH40', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (586, 38, N'NH43', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (587, 38, N'NH46', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (589, 39, N'NH01', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (590, 39, N'NH04', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (591, 39, N'NH07', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (592, 39, N'NH11', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (593, 39, N'NH13', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (594, 39, N'NH23', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (595, 39, N'NH26', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (596, 39, N'NH30', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (597, 39, N'NH31', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (598, 39, N'NH34', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (599, 39, N'NH37', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (600, 39, N'NH42', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (601, 39, N'NH46', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (602, 39, N'NH50', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (603, 39, N'NH20', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (604, 75, N'NH01', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (605, 75, N'NH04', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (606, 75, N'NH07', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (607, 75, N'NH10', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (608, 75, N'NH13', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (609, 75, N'NH15', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (610, 75, N'NH17', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (611, 75, N'NH20', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (612, 75, N'NH22', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (613, 75, N'NH25', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (614, 75, N'NH29', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (615, 75, N'NH34', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (616, 75, N'NH37', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (617, 75, N'NH39', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (618, 75, N'NH42', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (621, 16, N'NH20', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (622, 16, N'NH23', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (623, 16, N'NH24', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (624, 16, N'NH28', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (625, 16, N'NH30', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (626, 16, N'NH33', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (627, 16, N'NH37', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (628, 16, N'NH39', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (629, 16, N'NH41', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (630, 16, N'NH46', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (631, 16, N'NH47', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (632, 16, N'NH48', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (633, 16, N'NH25', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (634, 16, N'NH31', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (635, 16, N'NH35', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (636, 17, N'NH01', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (637, 17, N'NH02', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (638, 17, N'NH06', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (639, 17, N'NH10', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (640, 17, N'NH14', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (641, 17, N'NH20', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (642, 17, N'NH24', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (643, 17, N'NH27', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (644, 17, N'NH31', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (645, 17, N'NH37', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (646, 17, N'NH41', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (647, 17, N'NH45', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (648, 17, N'NH50', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (649, 17, N'NH07', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (650, 17, N'NH15', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (651, 44, N'NH01', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (652, 44, N'NH02', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (653, 44, N'NH05', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (654, 44, N'NH10', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (655, 44, N'NH14', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (656, 44, N'NH17', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (657, 44, N'NH20', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (658, 44, N'NH24', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (659, 44, N'NH28', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (660, 44, N'NH31', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (661, 44, N'NH33', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (662, 44, N'NH40', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (663, 44, N'NH42', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (664, 44, N'NH45', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (666, 44, N'NH50', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (667, 45, N'NH02', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (668, 45, N'NH06', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (669, 45, N'NH09', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (670, 45, N'NH11', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (671, 45, N'NH16', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (672, 45, N'NH20', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (673, 45, N'NH23', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (674, 45, N'NH28', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (675, 45, N'NH39', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (676, 45, N'NH41', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (677, 45, N'NH46', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (678, 45, N'NH49', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (679, 45, N'NH08', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (680, 45, N'NH17', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (681, 45, N'NH44', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (682, 18, N'NH01', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (683, 18, N'NH05', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (684, 18, N'NH08', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (685, 18, N'NH11', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (686, 18, N'NH13', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (687, 18, N'NH17', 0.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (688, 18, N'NH19', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (689, 18, N'NH23', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (690, 18, N'NH27', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (691, 18, N'NH30', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (692, 18, N'NH34', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (693, 18, N'NH38', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (694, 18, N'NH42', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (695, 18, N'NH46', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (696, 18, N'NH50', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (697, 18, N'NH04', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (698, 18, N'NH16', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (699, 18, N'NH32', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (700, 18, N'NH40', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (701, 18, N'NH48', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (702, 19, N'NH01', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (703, 19, N'NH04', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (704, 19, N'NH07', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (705, 19, N'NH09', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (706, 19, N'NH12', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (707, 19, N'NH15', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (708, 19, N'NH22', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (709, 19, N'NH26', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (710, 19, N'NH30', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (711, 19, N'NH39', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (712, 19, N'NH45', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (713, 19, N'NH50', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (714, 50, N'NH03', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (715, 50, N'NH05', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (716, 50, N'NH07', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (717, 50, N'NH11', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (718, 50, N'NH13', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (719, 50, N'NH15', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (720, 50, N'NH18', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (721, 50, N'NH19', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (722, 50, N'NH22', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (723, 50, N'NH25', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (724, 50, N'NH28', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (725, 50, N'NH31', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (726, 50, N'NH36', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (727, 50, N'NH40', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (728, 50, N'NH44', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (729, 50, N'NH47', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (730, 50, N'NH49', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (731, 50, N'NH04', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (732, 50, N'NH14', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (733, 50, N'NH24', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (734, 51, N'NH04', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (735, 51, N'NH06', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (736, 51, N'NH09', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (737, 51, N'NH11', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (738, 51, N'NH13', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (739, 51, N'NH17', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (740, 51, N'NH22', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (741, 51, N'NH27', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (742, 51, N'NH28', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (743, 51, N'NH31', 0.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (744, 51, N'NH34', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (745, 51, N'NH37', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (746, 51, N'NH40', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (747, 51, N'NH43', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (748, 51, N'NH45', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (749, 51, N'NH48', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (750, 27, N'NH03', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (751, 27, N'NH08', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (752, 27, N'NH12', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (753, 27, N'NH17', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (754, 27, N'NH22', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (755, 27, N'NH25', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (756, 27, N'NH29', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (757, 27, N'NH31', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (758, 27, N'NH39', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (759, 27, N'NH40', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (760, 27, N'NH43', 1.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (761, 27, N'NH46', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (762, 27, N'NH49', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (763, 27, N'NH11', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (764, 27, N'NH18', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (765, 28, N'NH02', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (766, 28, N'NH03', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (767, 28, N'NH05', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (768, 28, N'NH09', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (769, 28, N'NH12', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (770, 28, N'NH17', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (771, 28, N'NH25', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (772, 28, N'NH30', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (773, 28, N'NH33', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (774, 28, N'NH35', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (775, 28, N'NH38', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (776, 28, N'NH40', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (777, 28, N'NH42', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (778, 28, N'NH46', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (779, 28, N'NH49', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (780, 63, N'NH01', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (781, 63, N'NH03', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (782, 63, N'NH10', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (783, 63, N'NH14', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (784, 63, N'NH16', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (785, 63, N'NH20', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (786, 63, N'NH25', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (787, 63, N'NH28', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (788, 63, N'NH32', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (789, 63, N'NH34', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (790, 63, N'NH38', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (791, 63, N'NH42', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (792, 63, N'NH45', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (793, 63, N'NH50', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (794, 63, N'NH17', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (795, 64, N'NH01', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (796, 64, N'NH04', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (797, 64, N'NH08', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (798, 64, N'NH12', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (799, 64, N'NH16', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (800, 64, N'NH20', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (801, 64, N'NH24', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (802, 64, N'NH30', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (803, 64, N'NH32', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (804, 64, N'NH40', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (805, 64, N'NH42', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (806, 64, N'NH46', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (807, 64, N'NH50', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (808, 1, N'NH03', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (809, 1, N'NH07', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (810, 1, N'NH10', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (811, 1, N'NH13', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (812, 1, N'NH16', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (813, 1, N'NH18', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (814, 1, N'NH22', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (815, 1, N'NH25', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (816, 1, N'NH29', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (817, 1, N'NH33', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (818, 1, N'NH36', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (819, 1, N'NH38', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (820, 1, N'NH40', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (821, 1, N'NH43', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (822, 1, N'NH46', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (823, 1, N'NH48', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (824, 1, N'NH05', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (825, 1, N'NH08', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (826, 1, N'NH14', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (827, 1, N'NH17', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (828, 1, N'NH23', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (829, 1, N'NH28', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (830, 1, N'NH32', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (831, 1, N'NH39', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (832, 1, N'NH44', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (833, 1, N'NH49', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (834, 1, N'NH12', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (836, 3, N'NH01', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (837, 3, N'NH04', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (838, 3, N'NH05', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (839, 3, N'NH07', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (840, 3, N'NH10', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (841, 3, N'NH12', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (842, 3, N'NH14', 1.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (843, 3, N'NH18', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (844, 3, N'NH21', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (845, 3, N'NH28', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (846, 3, N'NH32', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (847, 3, N'NH34', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (848, 3, N'NH37', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (849, 3, N'NH41', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (850, 3, N'NH44', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (851, 3, N'NH46', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (852, 3, N'NH50', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (853, 1, N'NH50', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (854, 59, N'NH02', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (855, 59, N'NH05', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (856, 59, N'NH08', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (857, 59, N'NH09', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (858, 59, N'NH12', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (859, 59, N'NH14', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (860, 59, N'NH15', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (861, 59, N'NH19', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (862, 59, N'NH23', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (863, 59, N'NH27', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (864, 59, N'NH30', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (865, 59, N'NH34', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (866, 59, N'NH36', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (867, 59, N'NH40', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (868, 59, N'NH43', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (869, 59, N'NH46', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (870, 59, N'NH48', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (871, 59, N'NH04', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (872, 59, N'NH10', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (873, 59, N'NH17', 1.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (874, 59, N'NH18', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (875, 59, N'NH22', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (876, 59, N'NH26', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (877, 59, N'NH31', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (878, 59, N'NH35', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (879, 59, N'NH41', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (880, 59, N'NH49', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (881, 59, N'NH13', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (882, 59, N'NH28', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (883, 59, N'NH47', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (884, 60, N'NH04', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (885, 60, N'NH07', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (886, 60, N'NH09', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (887, 60, N'NH13', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (888, 60, N'NH20', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (889, 60, N'NH25', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (890, 60, N'NH28', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (891, 60, N'NH31', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (892, 60, N'NH38', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (893, 60, N'NH40', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (894, 60, N'NH44', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (895, 60, N'NH47', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (896, 60, N'NH48', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (897, 60, N'NH33', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (898, 60, N'NH36', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (899, 60, N'NH39', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (900, 60, N'NH43', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (901, 60, N'NH49', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (902, 60, N'NH27', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (903, 60, N'NH42', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (904, 61, N'NH02', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (905, 61, N'NH06', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (906, 61, N'NH09', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (907, 61, N'NH11', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (908, 61, N'NH13', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (909, 61, N'NH15', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (910, 61, N'NH19', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (911, 61, N'NH23', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (912, 61, N'NH26', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (913, 61, N'NH29', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (914, 61, N'NH31', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (915, 61, N'NH35', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (916, 61, N'NH37', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (917, 61, N'NH40', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (918, 61, N'NH43', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (919, 61, N'NH49', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (920, 61, N'NH05', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (921, 61, N'NH12', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (922, 61, N'NH20', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (923, 61, N'NH34', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (924, 61, N'NH41', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (925, 61, N'NH47', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (926, 61, N'NH04', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (927, 61, N'NH10', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (928, 61, N'NH18', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (929, 61, N'NH25', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (930, 61, N'NH08', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (931, 61, N'NH17', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (932, 61, N'NH28', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (933, 61, N'NH44', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (934, 62, N'NH03', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (935, 62, N'NH06', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (936, 62, N'NH10', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (937, 62, N'NH12', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (938, 62, N'NH16', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (939, 62, N'NH20', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (940, 62, N'NH24', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (941, 62, N'NH28', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (942, 62, N'NH31', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (943, 62, N'NH33', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (944, 62, N'NH37', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (945, 62, N'NH40', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (946, 62, N'NH45', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (947, 62, N'NH47', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (948, 62, N'NH04', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (949, 62, N'NH09', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (950, 62, N'NH19', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (951, 62, N'NH32', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (952, 62, N'NH36', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (953, 62, N'NH48', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (954, 32, N'NH01', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (955, 32, N'NH04', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (956, 32, N'NH07', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (957, 32, N'NH11', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (958, 32, N'NH15', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (959, 32, N'NH17', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (960, 32, N'NH21', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (961, 32, N'NH25', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (962, 32, N'NH28', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (963, 32, N'NH32', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (964, 32, N'NH34', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (965, 32, N'NH38', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (966, 32, N'NH40', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (967, 32, N'NH45', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (968, 32, N'NH48', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (969, 32, N'NH23', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (970, 32, N'NH24', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (971, 32, N'NH06', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (972, 32, N'NH09', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (973, 32, N'NH14', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (974, 32, N'NH18', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (975, 32, N'NH19', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (976, 32, N'NH22', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (977, 32, N'NH29', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (978, 32, N'NH30', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (979, 32, N'NH35', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (980, 32, N'NH39', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (981, 32, N'NH44', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (982, 32, N'NH49', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (983, 32, N'NH33', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (984, 33, N'NH03', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (985, 33, N'NH05', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (986, 33, N'NH08', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (987, 33, N'NH11', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (988, 33, N'NH13', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (989, 33, N'NH17', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (990, 33, N'NH24', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (991, 33, N'NH25', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (992, 33, N'NH26', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (993, 33, N'NH27', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (994, 33, N'NH28', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (995, 33, N'NH29', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (996, 33, N'NH30', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (997, 33, N'NH31', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (998, 33, N'NH32', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (999, 33, N'NH39', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1000, 33, N'NH42', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1001, 33, N'NH44', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1002, 33, N'NH47', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1003, 33, N'NH48', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1004, 33, N'NH02', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1005, 33, N'NH07', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1006, 33, N'NH12', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1007, 33, N'NH18', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1008, 33, N'NH33', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1009, 33, N'NH35', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1010, 33, N'NH40', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1011, 33, N'NH43', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1012, 33, N'NH46', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1013, 33, N'NH19', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1014, 34, N'NH01', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1015, 34, N'NH03', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1016, 34, N'NH09', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1017, 34, N'NH20', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1018, 34, N'NH23', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1019, 34, N'NH24', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1020, 34, N'NH25', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1021, 34, N'NH27', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1022, 34, N'NH28', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1023, 34, N'NH29', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1024, 34, N'NH30', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1025, 34, N'NH31', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1026, 34, N'NH37', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1027, 34, N'NH38', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1028, 34, N'NH39', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1029, 34, N'NH40', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1030, 34, N'NH41', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1031, 34, N'NH42', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1032, 34, N'NH43', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1033, 34, N'NH44', 0.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1034, 34, N'NH45', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1035, 34, N'NH50', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1036, 34, N'NH04', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1037, 34, N'NH11', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1038, 34, N'NH14', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1039, 34, N'NH18', 0.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1040, 34, N'NH32', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1041, 34, N'NH35', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1042, 34, N'NH46', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1043, 34, N'NH17', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1044, 35, N'NH02', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1045, 35, N'NH06', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1046, 35, N'NH08', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1047, 35, N'NH12', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1048, 35, N'NH15', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1049, 35, N'NH22', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1050, 35, N'NH24', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1051, 35, N'NH28', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1052, 35, N'NH31', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1053, 35, N'NH33', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1054, 35, N'NH36', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1055, 35, N'NH39', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1056, 35, N'NH44', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1057, 35, N'NH47', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1058, 35, N'NH35', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1059, 35, N'NH37', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1060, 35, N'NH38', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1061, 35, N'NH40', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1062, 35, N'NH41', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1063, 35, N'NH42', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1064, 35, N'NH43', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1065, 35, N'NH45', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1066, 35, N'NH46', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1067, 35, N'NH48', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1068, 35, N'NH49', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1069, 35, N'NH50', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1070, 35, N'NH16', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1071, 35, N'NH19', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1072, 35, N'NH26', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1073, 35, N'NH30', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1074, 29, N'NH01', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1075, 29, N'NH05', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1076, 29, N'NH06', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1077, 29, N'NH07', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1078, 29, N'NH08', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1079, 29, N'NH09', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1080, 29, N'NH10', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1081, 29, N'NH11', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1082, 29, N'NH35', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1083, 29, N'NH36', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1084, 29, N'NH37', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1085, 29, N'NH38', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1086, 29, N'NH39', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1087, 29, N'NH40', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1088, 29, N'NH41', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1089, 29, N'NH42', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1090, 29, N'NH43', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1091, 29, N'NH44', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1092, 29, N'NH45', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1093, 29, N'NH50', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1094, 30, N'NH01', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1095, 30, N'NH02', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1096, 30, N'NH03', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1097, 30, N'NH04', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1098, 30, N'NH05', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1099, 30, N'NH06', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1100, 30, N'NH07', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1101, 30, N'NH08', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1102, 30, N'NH09', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1103, 30, N'NH19', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1104, 30, N'NH25', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1105, 30, N'NH29', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1110, 30, N'NH43', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1111, 30, N'NH44', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1112, 30, N'NH45', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1113, 30, N'NH46', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1114, 30, N'NH47', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1115, 30, N'NH48', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1116, 30, N'NH49', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1117, 30, N'NH50', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1118, 65, N'NH03', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1119, 65, N'NH04', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1120, 65, N'NH05', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1121, 65, N'NH06', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1122, 65, N'NH07', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1123, 65, N'NH08', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1124, 65, N'NH09', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1125, 65, N'NH10', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1126, 65, N'NH15', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1127, 65, N'NH16', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1128, 65, N'NH17', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1129, 65, N'NH18', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1130, 65, N'NH19', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1131, 65, N'NH20', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1132, 65, N'NH21', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1141, 65, N'NH43', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1142, 65, N'NH44', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1143, 65, N'NH45', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1144, 65, N'NH46', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1145, 65, N'NH47', 0.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1146, 66, N'NH04', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1147, 66, N'NH05', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1148, 66, N'NH06', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1149, 66, N'NH07', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1150, 66, N'NH08', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1151, 66, N'NH09', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1152, 66, N'NH10', 0.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1153, 66, N'NH11', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1154, 66, N'NH12', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1155, 66, N'NH13', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1156, 66, N'NH21', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1157, 66, N'NH22', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1158, 66, N'NH23', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1159, 66, N'NH24', 1.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1160, 66, N'NH25', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1161, 66, N'NH26', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1162, 66, N'NH27', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1163, 66, N'NH28', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1164, 66, N'NH29', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1165, 66, N'NH30', 6.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1178, 67, N'NH07', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1179, 67, N'NH08', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1180, 67, N'NH09', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1181, 67, N'NH10', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1182, 67, N'NH11', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1183, 67, N'NH12', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1184, 67, N'NH13', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1185, 67, N'NH14', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1186, 67, N'NH15', 0.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1187, 67, N'NH16', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1188, 67, N'NH17', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1189, 67, N'NH23', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1190, 67, N'NH24', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1191, 67, N'NH25', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1192, 67, N'NH26', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1193, 67, N'NH27', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1194, 67, N'NH28', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1195, 67, N'NH29', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1196, 67, N'NH34', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1197, 67, N'NH35', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1209, 68, N'NH09', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1210, 68, N'NH10', 0.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1211, 68, N'NH11', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1212, 68, N'NH12', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1213, 68, N'NH13', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1214, 68, N'NH14', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1215, 68, N'NH15', 3.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1216, 68, N'NH16', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1217, 68, N'NH17', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1218, 68, N'NH27', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1219, 68, N'NH28', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1220, 68, N'NH29', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1221, 68, N'NH30', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1222, 68, N'NH31', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1223, 68, N'NH32', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1224, 68, N'NH33', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1225, 68, N'NH34', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1226, 68, N'NH35', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1227, 68, N'NH36', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1228, 68, N'NH43', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1232, 5, N'NH01', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1233, 5, N'NH02', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1234, 5, N'NH03', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1235, 5, N'NH05', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1236, 5, N'NH06', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1237, 5, N'NH08', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1238, 5, N'NH09', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1239, 5, N'NH10', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1240, 5, N'NH11', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1241, 5, N'NH12', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1242, 5, N'NH14', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1243, 5, N'NH15', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1244, 5, N'NH16', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1245, 5, N'NH17', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1246, 5, N'NH18', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1247, 5, N'NH19', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1248, 5, N'NH21', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1249, 5, N'NH22', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1250, 5, N'NH23', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1251, 5, N'NH25', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1252, 5, N'NH26', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1253, 5, N'NH27', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1254, 5, N'NH29', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1255, 5, N'NH30', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1256, 5, N'NH32', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1257, 5, N'NH33', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1258, 5, N'NH34', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1259, 5, N'NH35', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1260, 5, N'NH36', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1261, 5, N'NH37', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1262, 5, N'NH38', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1263, 5, N'NH40', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1264, 5, N'NH41', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1265, 5, N'NH42', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1266, 5, N'NH43', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1267, 5, N'NH45', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1268, 5, N'NH46', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1269, 5, N'NH48', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1270, 5, N'NH49', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1271, 5, N'NH50', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1272, 7, N'NH02', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1273, 7, N'NH04', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1274, 7, N'NH06', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1275, 7, N'NH08', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1276, 7, N'NH11', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1277, 7, N'NH14', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1278, 7, N'NH18', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1279, 7, N'NH21', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1280, 7, N'NH24', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1281, 7, N'NH30', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1282, 7, N'NH33', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1283, 7, N'NH36', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1284, 7, N'NH38', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1285, 7, N'NH40', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1286, 7, N'NH45', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1287, 7, N'NH48', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1288, 7, N'NH49', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1289, 7, N'NH09', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1292, 8, N'NH01', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1293, 8, N'NH02', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1294, 8, N'NH06', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1295, 8, N'NH08', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1296, 8, N'NH10', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1297, 8, N'NH12', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1298, 8, N'NH14', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1299, 8, N'NH19', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1300, 8, N'NH21', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1301, 8, N'NH24', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1302, 8, N'NH30', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1303, 8, N'NH38', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1304, 8, N'NH43', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1305, 8, N'NH45', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1306, 8, N'NH50', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1307, 7, N'NH01', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1308, 7, N'NH50', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1309, 9, N'NH01', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1310, 9, N'NH04', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1311, 9, N'NH09', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1312, 9, N'NH14', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1313, 9, N'NH17', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1314, 9, N'NH19', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1315, 9, N'NH24', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1316, 9, N'NH25', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1317, 9, N'NH29', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1318, 9, N'NH32', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1319, 9, N'NH34', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1320, 9, N'NH39', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1321, 9, N'NH43', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1323, 9, N'NH48', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1324, 9, N'NH50', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1325, 11, N'NH01', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1326, 11, N'NH04', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1327, 11, N'NH06', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1328, 11, N'NH10', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1329, 11, N'NH11', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1330, 11, N'NH14', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1331, 11, N'NH21', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1332, 11, N'NH29', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1333, 11, N'NH38', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1334, 11, N'NH42', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1335, 11, N'NH43', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1336, 11, N'NH44', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1337, 11, N'NH49', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1338, 11, N'NH50', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1339, 11, N'NH46', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1340, 12, N'NH01', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1341, 12, N'NH02', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1342, 12, N'NH03', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1343, 12, N'NH04', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1344, 12, N'NH06', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1345, 12, N'NH07', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1346, 12, N'NH09', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1347, 12, N'NH10', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1348, 12, N'NH11', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1349, 12, N'NH13', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1350, 12, N'NH15', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1351, 12, N'NH16', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1352, 12, N'NH18', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1353, 12, N'NH20', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1354, 12, N'NH21', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1355, 12, N'NH22', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1356, 12, N'NH24', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1357, 12, N'NH26', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1358, 12, N'NH28', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1359, 12, N'NH29', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1360, 12, N'NH30', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1361, 12, N'NH32', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1362, 12, N'NH33', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1363, 12, N'NH35', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1364, 12, N'NH36', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1365, 12, N'NH37', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1366, 12, N'NH39', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1367, 12, N'NH40', 2.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1368, 12, N'NH42', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1369, 12, N'NH44', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1370, 12, N'NH45', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1371, 12, N'NH46', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1372, 12, N'NH48', 6.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1373, 12, N'NH49', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1374, 12, N'NH50', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1375, 13, N'NH01', 7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1376, 13, N'NH03', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1377, 13, N'NH04', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1378, 13, N'NH05', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1379, 13, N'NH08', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1380, 13, N'NH09', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1381, 13, N'NH11', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1382, 13, N'NH12', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1383, 13, N'NH14', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1384, 13, N'NH16', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1385, 13, N'NH17', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1386, 13, N'NH18', 1.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1387, 13, N'NH21', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1388, 13, N'NH22', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1389, 13, N'NH24', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1390, 13, N'NH26', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1391, 13, N'NH27', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1397, 13, N'NH39', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1398, 13, N'NH41', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1399, 13, N'NH43', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1400, 13, N'NH44', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1401, 13, N'NH46', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1402, 13, N'NH47', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1403, 13, N'NH49', 8.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1404, 13, N'NH50', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1405, 52, N'NH02', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1406, 52, N'NH03', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1407, 52, N'NH04', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1408, 52, N'NH06', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1409, 52, N'NH07', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1410, 52, N'NH08', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1411, 52, N'NH10', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1412, 52, N'NH11', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1413, 52, N'NH12', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1414, 52, N'NH14', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1415, 52, N'NH15', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1416, 52, N'NH16', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1417, 52, N'NH17', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1418, 52, N'NH19', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1419, 52, N'NH20', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1420, 52, N'NH21', 3.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1421, 52, N'NH22', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1422, 52, N'NH24', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1423, 52, N'NH26', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1424, 52, N'NH27', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1425, 52, N'NH29', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1426, 52, N'NH30', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1427, 52, N'NH32', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1428, 52, N'NH33', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1429, 52, N'NH34', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1430, 52, N'NH35', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1431, 52, N'NH36', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1432, 52, N'NH37', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1433, 52, N'NH38', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1434, 52, N'NH39', 6.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1435, 52, N'NH40', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1436, 52, N'NH41', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1437, 52, N'NH42', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1438, 52, N'NH43', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1439, 52, N'NH44', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1440, 52, N'NH45', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1441, 52, N'NH46', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1442, 52, N'NH47', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1443, 52, N'NH48', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1444, 52, N'NH49', 4.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1445, 53, N'NH03', 5.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1446, 53, N'NH04', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1447, 53, N'NH05', 9.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1448, 53, N'NH06', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1449, 53, N'NH07', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1450, 53, N'NH08', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1451, 53, N'NH09', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1452, 53, N'NH10', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1453, 53, N'NH11', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1454, 53, N'NH12', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1455, 53, N'NH27', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1456, 53, N'NH28', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1457, 53, N'NH29', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1458, 53, N'NH30', 6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1459, 53, N'NH31', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1460, 53, N'NH32', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1461, 53, N'NH33', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1462, 53, N'NH34', 0.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1463, 53, N'NH35', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1464, 53, N'NH41', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1465, 53, N'NH42', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1466, 53, N'NH43', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1467, 53, N'NH44', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1468, 53, N'NH45', 9.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1469, 53, N'NH46', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1470, 53, N'NH47', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1471, 54, N'NH13', 0.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1472, 54, N'NH14', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1473, 54, N'NH15', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1474, 54, N'NH16', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1475, 54, N'NH17', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1476, 54, N'NH18', 8.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1477, 54, N'NH19', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1478, 54, N'NH27', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1479, 54, N'NH28', 7.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1480, 54, N'NH29', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1481, 54, N'NH30', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1482, 54, N'NH31', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1483, 54, N'NH39', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1484, 54, N'NH40', 3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1485, 54, N'NH41', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1486, 54, N'NH42', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1487, 54, N'NH43', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1488, 54, N'NH44', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1489, 54, N'NH45', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1490, 54, N'NH46', 10)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1491, 54, N'NH47', 8.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1492, 55, N'NH03', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1493, 55, N'NH04', 2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1494, 55, N'NH05', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1495, 55, N'NH06', 5.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1496, 55, N'NH07', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1497, 55, N'NH08', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1498, 55, N'NH09', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1499, 55, N'NH10', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1500, 55, N'NH11', 5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1501, 55, N'NH12', 8.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1502, 55, N'NH18', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1503, 55, N'NH19', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1504, 55, N'NH20', 3.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1505, 55, N'NH21', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1506, 55, N'NH22', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1507, 55, N'NH23', 3.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1508, 55, N'NH24', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1509, 55, N'NH25', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1510, 55, N'NH39', 4.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1511, 55, N'NH40', 4.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1512, 55, N'NH41', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1513, 55, N'NH42', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1514, 55, N'NH43', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1515, 55, N'NH44', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1516, 55, N'NH45', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1517, 55, N'NH46', 9.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1518, 56, N'NH05', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1519, 56, N'NH06', 5.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1520, 56, N'NH07', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1521, 56, N'NH08', 4.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1522, 56, N'NH09', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1523, 56, N'NH10', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1524, 56, N'NH11', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1525, 56, N'NH12', 6.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1526, 56, N'NH25', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1527, 56, N'NH26', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1528, 56, N'NH27', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1529, 56, N'NH28', 7.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1530, 56, N'NH29', 9.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1531, 56, N'NH30', 1.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1532, 56, N'NH31', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1533, 56, N'NH32', 2.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1534, 56, N'NH38', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1535, 56, N'NH39', 0.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1536, 56, N'NH40', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1537, 56, N'NH41', 0.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1538, 56, N'NH42', 0.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1539, 56, N'NH43', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1540, 56, N'NH44', 0.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1541, 56, N'NH45', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1542, 56, N'NH46', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1543, 56, N'NH47', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1544, 56, N'NH48', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1545, 57, N'NH03', 3.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1546, 57, N'NH04', 7.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1547, 57, N'NH05', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1548, 57, N'NH06', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1549, 57, N'NH07', 4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1550, 57, N'NH08', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1551, 57, N'NH09', 7.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1552, 57, N'NH10', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1553, 57, N'NH11', 9.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1554, 57, N'NH12', 8.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1555, 57, N'NH25', 0.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1556, 57, N'NH26', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1557, 57, N'NH27', 1.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1558, 57, N'NH28', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1559, 57, N'NH29', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1560, 57, N'NH30', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1561, 57, N'NH31', 3.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1562, 57, N'NH32', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1563, 57, N'NH33', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1564, 57, N'NH38', 9.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1565, 57, N'NH39', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1566, 57, N'NH40', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1567, 57, N'NH41', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1568, 57, N'NH42', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1569, 57, N'NH43', 8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1570, 57, N'NH44', 4.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1571, 57, N'NH45', 8.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1572, 57, N'NH46', 1.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1573, 57, N'NH47', 7.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1574, 57, N'NH48', 7.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1575, 57, N'NH49', 0.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1576, 57, N'NH17', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1577, 57, N'NH21', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1578, 57, N'NH34', 6.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1579, 57, N'NH37', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1580, 58, N'NH03', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1581, 58, N'NH04', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1582, 58, N'NH05', 4.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1583, 58, N'NH06', 2.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1584, 58, N'NH07', 5.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1585, 58, N'NH08', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1586, 58, N'NH09', 2.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1587, 58, N'NH10', 8.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1588, 58, N'NH11', 8.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1589, 58, N'NH12', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1590, 58, N'NH27', 5.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1591, 58, N'NH28', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1592, 58, N'NH29', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1593, 58, N'NH30', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1594, 58, N'NH31', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1595, 58, N'NH32', 6.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1596, 58, N'NH33', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1597, 58, N'NH34', 1.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1598, 58, N'NH35', 5.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1599, 58, N'NH39', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1600, 58, N'NH40', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1601, 58, N'NH41', 1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1602, 58, N'NH42', 1.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1603, 58, N'NH43', 1.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1604, 58, N'NH44', 7.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1605, 58, N'NH45', 4.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1606, 58, N'NH46', 2.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1607, 58, N'NH47', 0.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1608, 76, N'NH02', 6.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1609, 76, N'NH06', 3.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1610, 76, N'NH08', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1611, 76, N'NH13', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1612, 76, N'NH16', 0.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1613, 76, N'NH18', 5.3)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1614, 76, N'NH22', 9.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1615, 76, N'NH26', 2.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1616, 76, N'NH29', 9.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1617, 76, N'NH33', 6.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1618, 76, N'NH36', 4.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1619, 76, N'NH40', 9.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1620, 76, N'NH43', 5.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1621, 76, N'NH46', 2.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1622, 76, N'NH49', 8.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1623, 82, N'NH02', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1624, 82, N'NH03', 7.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1625, 82, N'NH04', 6.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1626, 82, N'NH05', 2.1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1627, 82, N'NH06', 7.4)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1628, 82, N'NH07', 5.9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1629, 82, N'NH08', 1.2)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1630, 82, N'NH09', 1.6)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1631, 82, N'NH10', 3.5)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1632, 82, N'NH11', 2.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1633, 82, N'NH12', 3.8)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (1634, 82, N'NH13', 4.7)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (2623, 82, N'NH15', 9)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (2624, 82, N'NH16', -1)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (2625, 82, N'NH17', 0)
GO
INSERT [dbo].[HocVien] ([MaHV], [MaKH], [MaNH], [Diem]) VALUES (2626, 82, N'NH20', -1)
GO
SET IDENTITY_INSERT [dbo].[HocVien] OFF
GO
SET IDENTITY_INSERT [dbo].[KhoaHoc] ON 

GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (1, N'Lập trình Java cơ bản', N'JAV', 450, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV02', CAST(N'2021-09-26' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (2, N'Lập trình C# cơ bản', N'CS', 450, 36, CAST(N'2021-10-13' AS Date), N'', N'NV04', CAST(N'2021-09-26' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (3, N'Lập trình Java nâng cao', N'JAV', 1500, 72, CAST(N'2021-10-13' AS Date), NULL, N'NV02', CAST(N'2021-09-27' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (4, N'Lập trình C# nâng cao', N'CS', 1700, 72, CAST(N'2021-10-13' AS Date), N'', N'NV04', CAST(N'2021-09-27' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (5, N'Lập trình HTML&CSS và Photoshop', N'WEB', 500, 72, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (7, N'Lập trình JavaScript và jQuery', N'WEB', 400, 54, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (8, N'Lập trình với Boostrap và Responsive Design', N'WEB', 300, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (9, N'Lập trình với SASS/SCSS', N'WEB', 100, 18, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (11, N'Git/GitHub và Agile/Scrum', N'WEB', 100, 18, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (12, N'Lập trình ReactJS', N'WEB', 1500, 72, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (13, N'Lập trình NodeJS', N'WEB', 1300, 72, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (14, N'Lập trình C', N'CCPP', 150, 36, CAST(N'2021-10-11' AS Date), N'', N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (15, N'Lập trình C++', N'CCPP', 200, 36, CAST(N'2021-10-11' AS Date), N'', N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (16, N'Cơ sở dữ liệu cơ bản', N'DB', 350, 36, CAST(N'2021-10-13' AS Date), N'', N'NV02', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (17, N'Cơ sở dữ liệu nâng cao', N'DB', 400, 36, CAST(N'2021-10-13' AS Date), N'', N'NV02', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (18, N'Tin học văn phòng cơ bản', N'INFO', 200, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (19, N'Tin học văn phòng nâng cao', N'INFO', 250, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (20, N'Lập trình Python', N'DSML', 750, 54, CAST(N'2021-10-13' AS Date), N'', N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (21, N'Nhập môn Khoa học dữ liệu', N'DSML', 800, 54, CAST(N'2021-10-13' AS Date), N'', N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (22, N'Cơ sở, tiền xử lý và phân tích dữ liệu', N'DSML', 1500, 72, CAST(N'2021-10-13' AS Date), N'', N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (23, N'Máy học với Python', N'DSML', 900, 54, CAST(N'2021-10-13' AS Date), NULL, N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (24, N'Lập trình R', N'DSML', 450, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (25, N'Dữ liệu lớn trong máy học', N'DSML', 950, 54, CAST(N'2021-10-13' AS Date), NULL, N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (26, N'Học sâu với Python', N'DSML', 950, 54, CAST(N'2021-10-13' AS Date), NULL, N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (27, N'Lập trình IOS cơ bản', N'IOS', 400, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (28, N'Lập trình IOS nâng cao', N'IOS', 1000, 72, CAST(N'2021-10-13' AS Date), NULL, N'NV03', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (29, N'Lập trình React Native cơ bản', N'RENA', 400, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (30, N'Lập trình React Native nâng cao', N'RENA', 1200, 72, CAST(N'2021-10-13' AS Date), NULL, N'NV04', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (32, N'Đại số tuyến tính', N'MATH', 100, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (33, N'Giải tích', N'MATH', 100, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (34, N'Xác suất thống kế', N'MATH', 150, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (35, N'Toán rời rạc', N'MATH', 200, 36, CAST(N'2021-10-13' AS Date), NULL, N'NV01', CAST(N'2021-10-08' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (36, N'Lập trình C', N'CCPP', 150, 36, CAST(N'2021-10-13' AS Date), N'', N'NV02', CAST(N'2021-10-11' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (37, N'Lập trình C++', N'CCPP', 200, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (38, N'Lập trình C# cơ bản', N'CS', 450, 36, CAST(N'2021-10-13' AS Date), N'', N'NV01', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (39, N'Lập trình C# nâng cao', N'CS', 1700, 72, CAST(N'2021-10-13' AS Date), N'', N'NV04', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (41, N'Lập trình Python', N'DSML', 750, 54, CAST(N'2021-10-13' AS Date), NULL, N'NV01', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (44, N'Cơ sở dữ liệu cơ bản', N'DB', 350, 36, CAST(N'2021-10-13' AS Date), N'None', N'NV01', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (45, N'Cơ sở dữ liệu nâng cao', N'DB', 400, 36, CAST(N'2021-10-13' AS Date), N'None', N'NV01', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (46, N'Lập trình C', N'CCPP', 150, 36, CAST(N'2021-10-13' AS Date), N'None', N'NV02', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (47, N'Lập trình C++', N'CCPP', 200, 36, CAST(N'2021-10-13' AS Date), N'None', N'NV02', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (50, N'Tin học văn phòng cơ bản', N'INFO', 200, 36, CAST(N'2021-10-13' AS Date), N'None', N'NV01', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (51, N'Tin học văn phòng nâng cao', N'INFO', 250, 36, CAST(N'2021-10-13' AS Date), N'None', N'NV01', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (52, N'Lập trình HTML&CSS và Photoshop', N'WEB', 500, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (53, N'Lập trình JavaScript và jQuery', N'WEB', 400, 54, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (54, N'Lập trình với Boostrap và Responsive Design', N'WEB', 300, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (55, N'Lập trình với SASS/SCSS', N'WEB', 100, 18, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (56, N'Git/GitHub và Agile/Scrum', N'WEB', 100, 18, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (57, N'Lập trình ReactJS', N'WEB', 1500, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (58, N'Lập trình NodeJS', N'WEB', 1300, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (59, N'Lập trình Java cơ bản', N'JAV', 450, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (60, N'Lập trình Java nâng cao', N'JAV', 1500, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (61, N'Lập trình Java cơ bản', N'JAV', 450, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (62, N'Lập trình Java nâng cao', N'JAV', 1500, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (63, N'Lập trình IOS cơ bản', N'IOS', 400, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (64, N'Lập trình IOS nâng cao', N'IOS', 1000, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (65, N'Lập trình React Native cơ bản', N'RENA', 400, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (66, N'Lập trình React Native nâng cao', N'RENA', 1200, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (67, N'Lập trình React Native cơ bản', N'RENA', 400, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (68, N'Lập trình React Native nâng cao', N'RENA', 1200, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (69, N'Nhập môn Khoa học dữ liệu', N'DSML', 800, 54, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (70, N'Cơ sở, tiền xử lý và phân tích dữ liệu', N'DSML', 1500, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (71, N'Máy học với Python', N'DSML', 900, 54, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (72, N'Lập trình R', N'DSML', 450, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (73, N'Dữ liệu lớn trong máy học', N'DSML', 950, 54, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (74, N'Học sâu với Python', N'DSML', 950, 54, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (75, N'Lập trình C# cơ bản', N'CS', 450, 36, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (76, N'Lập trình C# nâng cao', N'CS', 1700, 72, CAST(N'2021-10-13' AS Date), N'', N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (80, N'Lập trình Java cơ bản', N'JAV', 450, 36, CAST(N'2020-10-13' AS Date), N'', N'NV03', CAST(N'2020-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (81, N'Lập trình Java nâng cao', N'JAV', 1500, 72, CAST(N'2020-10-13' AS Date), N'', N'NV03', CAST(N'2020-10-12' AS Date))
GO
INSERT [dbo].[KhoaHoc] ([MaKH], [TenKH], [MaCD], [HocPhi], [ThoiLuong], [NgayKG], [GhiChu], [MaNV], [NgayTao]) VALUES (82, N'Lập trình C++', N'CCPP', 200, 36, CAST(N'2021-11-17' AS Date), N'', N'NV01', CAST(N'2021-10-18' AS Date))
GO
SET IDENTITY_INSERT [dbo].[KhoaHoc] OFF
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND01', N'Tim Cook', CAST(N'1990-01-24' AS Date), 1, N'0986280001', N'timcook@gmail.com', 13000, N'NV01', CAST(N'2021-09-29' AS Date), N'IOS')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND02', N'Mary', CAST(N'1992-06-03' AS Date), 0, N'0986280002', N'mary@gmail.com', 10000, N'NV02', CAST(N'2021-09-29' AS Date), N'Math')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND03', N'Bill Gates', CAST(N'1989-05-13' AS Date), 1, N'0986280003', N'billgates@gmail.com', 24000, N'NV03', CAST(N'2021-09-29' AS Date), N'DSML')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND04', N'Sophia', CAST(N'1988-06-14' AS Date), 0, N'0986280004', N'sophia@gmail.com', 11000, N'NV01', CAST(N'2021-09-29' AS Date), N'Infomatics')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND05', N'Mark Zuckerberg', CAST(N'1987-07-15' AS Date), 1, N'0986280005', N'mark@gmail.com', 14000, N'NV02', CAST(N'2021-09-29' AS Date), N'React Native')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND06', N'Jenny', CAST(N'1986-08-16' AS Date), 0, N'0986280006', N'jenny@gmail.com', 10000, N'NV03', CAST(N'2021-09-29' AS Date), N'C/C++')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND07', N'Jeff Bezos', CAST(N'1985-09-17' AS Date), 1, N'0986280007', N'jeff@gmail.com', 20000, N'NV01', CAST(N'2021-09-29' AS Date), N'Web')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND08', N'Lily', CAST(N'1984-10-18' AS Date), 0, N'0986280008', N'lily@gmail.com', 16000, N'NV02', CAST(N'2021-09-29' AS Date), N'Java')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND09', N'Elon Musk', CAST(N'1983-11-19' AS Date), 1, N'0986280009', N'elon@gmail.com', 12000, N'NV03', CAST(N'2021-09-29' AS Date), N'CSDL')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND10', N'Carolina', CAST(N'1982-12-20' AS Date), 0, N'0986280010', N'carolina@gmail.com', 17000, N'NV01', CAST(N'2021-09-29' AS Date), N'C#')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND11', N'Jack Ma', CAST(N'1981-01-21' AS Date), 1, N'0986280011', N'jackma@gmail.com', 18000, N'NV02', CAST(N'2021-09-29' AS Date), N'Web')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND12', N'Larry Page', CAST(N'1989-05-13' AS Date), 1, N'0986280003', N'larrypage@gmail.com', 22000, N'NV03', CAST(N'2021-08-10' AS Date), N'DSML')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND13', N'hihi', CAST(N'1985-10-18' AS Date), 1, N'0123', N'hihi@gmail.com', 0, N'NV01', CAST(N'2021-10-10' AS Date), N'')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND14', N'haha', CAST(N'1994-10-13' AS Date), 0, N'0123', N'haha@gmail.com', 0, N'NV02', CAST(N'2021-10-10' AS Date), N'')
GO
INSERT [dbo].[NguoiDay] ([MaND], [HoTen], [NgaySinh], [GioiTinh], [DienThoai], [Email], [Luong], [MaNV], [NgayDK], [GhiChu]) VALUES (N'ND15', N'hoho', CAST(N'1982-10-11' AS Date), 0, N'01234', N'hoho@gmail.com', 0, N'NV03', CAST(N'2021-10-10' AS Date), N'')
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH01', N'John', 1, CAST(N'2002-06-13' AS Date), N'0352195000', N'john@gmail.com', NULL, N'NV02', CAST(N'2021-09-26' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH02', N'Linda', 0, CAST(N'2004-09-19' AS Date), N'0352195001', N'linda@gmail.com', NULL, N'NV01', CAST(N'2021-09-26' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH03', N'Baron', 1, CAST(N'2000-03-04' AS Date), N'0352195002', N'baron@gmail.com', NULL, N'NV03', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH04', N'Sharon', 0, CAST(N'1999-08-21' AS Date), N'0352195003', N'sharon@gmail.com', N'Null', N'NV04', CAST(N'2021-10-12' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH05', N'Bin', 1, CAST(N'2003-04-11' AS Date), N'0352195004', N'bin@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH06', N'Shasha', 0, CAST(N'2001-04-01' AS Date), N'0352195005', N'shasha@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH07', N'Lucas', 1, CAST(N'1998-02-07' AS Date), N'0352195006', N'lucas@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH08', N'Hillary', 0, CAST(N'1997-03-06' AS Date), N'0352195007', N'hillary@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH09', N'Johnson', 1, CAST(N'1996-04-13' AS Date), N'0352195008', N'johnson@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH10', N'Athena', 0, CAST(N'1994-09-07' AS Date), N'0352195009', N'athena@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH11', N'Dominic', 1, CAST(N'1993-10-07' AS Date), N'0352195010', N'dominic@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH12', N'Sharah', 0, CAST(N'1992-08-05' AS Date), N'0352195011', N'sharah@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH13', N'Otis', 1, CAST(N'1991-06-03' AS Date), N'0352195012', N'otis@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH14', N'Issac', 1, CAST(N'1990-03-12' AS Date), N'0352195013', N'issac@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH15', N'Jacob', 1, CAST(N'2004-06-17' AS Date), N'0352195014', N'jacob@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH16', N'Emily', 0, CAST(N'2005-05-22' AS Date), N'0352195015', N'emily@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH17', N'Nathan', 1, CAST(N'2006-10-14' AS Date), N'0352195015', N'nathan@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH18', N'Elysia', 0, CAST(N'2007-12-02' AS Date), N'0352195016', N'elysia@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH19', N'Michael', 1, CAST(N'2008-07-01' AS Date), N'0352195017', N'michael@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH20', N'Margaret', 0, CAST(N'2009-08-02' AS Date), N'0352195018', N'margaret@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH21', N'Daniel', 1, CAST(N'2010-04-20' AS Date), N'0352195019', N'daniel@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH22', N'Dorothy', 0, CAST(N'2011-11-27' AS Date), N'0352195020', N'dorothy@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH23', N'Matthew', 1, CAST(N'2012-07-07' AS Date), N'0352195021', N'matthew@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH24', N'Helen', 0, CAST(N'2013-02-27' AS Date), N'0352195022', N'helen@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH25', N'Harry', 1, CAST(N'2014-09-07' AS Date), N'0352195023', N'harry@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH26', N'William', 1, CAST(N'2006-10-07' AS Date), N'0352195015', N'william@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH27', N'Alexandra', 0, CAST(N'2007-10-07' AS Date), N'0352195016', N'alexandra@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH28', N'Alan', 1, CAST(N'2008-10-07' AS Date), N'0352195017', N'alan@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH29', N'Louisa', 0, CAST(N'2009-10-07' AS Date), N'0352195018', N'lousia@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH30', N'Richard', 1, CAST(N'2010-10-07' AS Date), N'0352195019', N'richard@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH31', N'Ciara', 0, CAST(N'2011-10-07' AS Date), N'0352195020', N'ciara@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH32', N'Leonard', 1, CAST(N'2012-10-07' AS Date), N'0352195021', N'leonard@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH33', N'Aurora', 0, CAST(N'2013-10-07' AS Date), N'0352195022', N'aurora@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH34', N'Darius', 1, CAST(N'1991-06-03' AS Date), N'0352195015', N'darius@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH35', N'Almira', 0, CAST(N'1997-03-06' AS Date), N'0352195016', N'almira@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH36', N'Edward', 1, CAST(N'2001-04-01' AS Date), N'0352195017', N'edward@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH37', N'Olwen', 0, CAST(N'2002-06-13' AS Date), N'0352195018', N'olwen@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH38', N'Edric', 1, CAST(N'1997-03-06' AS Date), N'0352195019', N'edric@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH39', N'Xavia', 0, CAST(N'2000-03-04' AS Date), N'0352195020', N'xavia@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH40', N'Andrew', 1, CAST(N'2003-04-11' AS Date), N'0352195021', N'andrew@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH41', N'Diamond', 0, CAST(N'2013-02-27' AS Date), N'0352195022', N'diamond@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH42', N'Victor', 1, CAST(N'1991-06-03' AS Date), N'0352195023', N'victor@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH43', N'Maris', 0, CAST(N'1997-03-06' AS Date), N'0352195024', N'maris@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH44', N'Orborne', 1, CAST(N'2001-04-01' AS Date), N'0352195025', N'orborne@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH45', N'Layla', 0, CAST(N'2002-06-13' AS Date), N'0352195026', N'layla@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH46', N'Paul', 1, CAST(N'1997-03-06' AS Date), N'0352195027', N'paul@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH47', N'Elain', 0, CAST(N'2000-03-04' AS Date), N'0352195028', N'elain@gmail.com', NULL, N'NV03', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH48', N'Felix', 1, CAST(N'2003-04-11' AS Date), N'0352195029', N'felix@gmail.com', NULL, N'NV04', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH49', N'Rosa', 0, CAST(N'2013-02-27' AS Date), N'0352195030', N'rosa@gmail.com', NULL, N'NV01', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NguoiHoc] ([MaNH], [HoTen], [GioiTinh], [NgaySinh], [DienThoai], [Email], [GhiChu], [MaNV], [NgayDK]) VALUES (N'NH50', N'Conal', 1, CAST(N'1991-06-03' AS Date), N'0352195033', N'conal@gmail.com', NULL, N'NV02', CAST(N'2021-10-14' AS Date))
GO
INSERT [dbo].[NhanVien] ([MaNV], [MatKhau], [HoTen], [VaiTro], [Luong], [Salt], [TrangThai]) VALUES (N'NV01', 0x2688C5D9019DE7E2B72568C9918424C92D5BF845C3A735D7C1435CEC759365EF0C6A88B412F8C4CFF42C6797A7E5666C2CFD0B4B8588FE7A0C73A95C0439379E, N'Nguyễn Ngọc Đại', 1, 20000, N'ee6acf52-8309-40c0-b73d-d4854a02e113', 1)
GO
INSERT [dbo].[NhanVien] ([MaNV], [MatKhau], [HoTen], [VaiTro], [Luong], [Salt], [TrangThai]) VALUES (N'NV02', 0x2ED8067B4901D0A47B14B1E5EE1F98A2FB56CD406B995D69EA11F3BE3B205F8E040E308ECE7C5A0EC893542586A8A88B0FA57E22991F24AD639D5A6931AC2435, N'Võ Hữu Thông', 0, 16000, N'e57b637f-c044-489a-a040-fbd2f282725d', 1)
GO
INSERT [dbo].[NhanVien] ([MaNV], [MatKhau], [HoTen], [VaiTro], [Luong], [Salt], [TrangThai]) VALUES (N'NV03', 0x1F1EDD1FB2D326EA892FC21E4F8E6831242E537A2C9F87DF7A0B30572A2AED2DC504063357CA2F0E0D18782A2B126A59EDDD30466DF3B166B2D98063AB988512, N'Trần Việt Hoàng', 0, 14000, N'680a0f6e-d1a1-422b-829e-17515f63f600', 1)
GO
INSERT [dbo].[NhanVien] ([MaNV], [MatKhau], [HoTen], [VaiTro], [Luong], [Salt], [TrangThai]) VALUES (N'NV04', 0xD7261B37740321F1B99989A7256EDB3EA2E5F32A46ABA6B99188E31B5723A20B1B56346C30D3CF968961C2BB7B7DC53BA70CEC0429D6D06E41D116C5157E0442, N'Lê Văn Lưu', 0, 12000, N'54710c05-b61d-431f-9f19-dba0dfbe5e24', 1)
GO
INSERT [dbo].[NhanVien] ([MaNV], [MatKhau], [HoTen], [VaiTro], [Luong], [Salt], [TrangThai]) VALUES (N'NV05', 0x54D5F1D93CAB49FEE50C118D920F8AE1426A5352894619688E1F96F719BC3DA812F645E51A0678951F33BD39BCC508793011EDF7E5FCC78550193707001B940E, N'demo1', 0, 0, N'425e7247-aab1-400a-8fd4-38f5c5af0063', 0)
GO
INSERT [dbo].[NhanVien] ([MaNV], [MatKhau], [HoTen], [VaiTro], [Luong], [Salt], [TrangThai]) VALUES (N'NV06', 0x018A86E6D194E9ED96285D64D7040FA37D7EC16B913DBF8EE9FB3F7B979BC626DB88FA26116147834586A58119A15DF99707ECE473D2B9E9267D906345D54C4E, N'demo2', 0, 0, N'1b28b377-b0e0-40fe-bb53-252e609d6a07', 0)
GO
INSERT [dbo].[NhanVien] ([MaNV], [MatKhau], [HoTen], [VaiTro], [Luong], [Salt], [TrangThai]) VALUES (N'NV07', 0xE320EAFB6B879E297DCC19CDE15E0EA9B7483BF03E7C35ED3488640A8A89AAABE649EAA06E22BF540D0250582E230735F944BE50624A5F0882A6F869C8E921B3, N'demo2', 0, 0, N'd4d19689-f2eb-4bbb-8b95-2ed535bef634', 0)
GO
ALTER TABLE [dbo].[GiangVien]  WITH CHECK ADD  CONSTRAINT [FK_GiangVien_KhoaHoc] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KhoaHoc] ([MaKH])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GiangVien] CHECK CONSTRAINT [FK_GiangVien_KhoaHoc]
GO
ALTER TABLE [dbo].[GiangVien]  WITH CHECK ADD  CONSTRAINT [FK_GiangVien_NguoiDay] FOREIGN KEY([MaND])
REFERENCES [dbo].[NguoiDay] ([MaND])
GO
ALTER TABLE [dbo].[GiangVien] CHECK CONSTRAINT [FK_GiangVien_NguoiDay]
GO
ALTER TABLE [dbo].[HocVien]  WITH CHECK ADD  CONSTRAINT [FK_HocVien_KhoaHoc] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KhoaHoc] ([MaKH])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HocVien] CHECK CONSTRAINT [FK_HocVien_KhoaHoc]
GO
ALTER TABLE [dbo].[HocVien]  WITH CHECK ADD  CONSTRAINT [FK_HocVien_NguoiHoc] FOREIGN KEY([MaNH])
REFERENCES [dbo].[NguoiHoc] ([MaNH])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[HocVien] CHECK CONSTRAINT [FK_HocVien_NguoiHoc]
GO
ALTER TABLE [dbo].[KhoaHoc]  WITH CHECK ADD  CONSTRAINT [FK_KhoaHoc_ChuyenDe] FOREIGN KEY([MaCD])
REFERENCES [dbo].[ChuyenDe] ([MaCD])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[KhoaHoc] CHECK CONSTRAINT [FK_KhoaHoc_ChuyenDe]
GO
ALTER TABLE [dbo].[KhoaHoc]  WITH CHECK ADD  CONSTRAINT [FK_KhoaHoc_NhanVien] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NhanVien] ([MaNV])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[KhoaHoc] CHECK CONSTRAINT [FK_KhoaHoc_NhanVien]
GO
ALTER TABLE [dbo].[NguoiDay]  WITH CHECK ADD  CONSTRAINT [FK_NguoiDay_NhanVien] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NhanVien] ([MaNV])
GO
ALTER TABLE [dbo].[NguoiDay] CHECK CONSTRAINT [FK_NguoiDay_NhanVien]
GO
ALTER TABLE [dbo].[NguoiHoc]  WITH CHECK ADD  CONSTRAINT [FK_NguoiHoc_NhanVien] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NhanVien] ([MaNV])
GO
ALTER TABLE [dbo].[NguoiHoc] CHECK CONSTRAINT [FK_NguoiHoc_NhanVien]
GO
ALTER TABLE [dbo].[NguoiDay]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDay] CHECK  (([NgaySinh]<getdate()))
GO
ALTER TABLE [dbo].[NguoiDay] CHECK CONSTRAINT [CK_NguoiDay]
GO
ALTER TABLE [dbo].[NguoiDay]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDay_1] CHECK  (([Luong]>=(0)))
GO
ALTER TABLE [dbo].[NguoiDay] CHECK CONSTRAINT [CK_NguoiDay_1]
GO
ALTER TABLE [dbo].[NguoiHoc]  WITH CHECK ADD  CONSTRAINT [CK_NguoiHoc] CHECK  (([NgaySinh]<getdate()))
GO
ALTER TABLE [dbo].[NguoiHoc] CHECK CONSTRAINT [CK_NguoiHoc]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien] CHECK  (([Luong]>=(0)))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien]
GO
USE [master]
GO
ALTER DATABASE [LapTrinhCityPro] SET  READ_WRITE 
GO
