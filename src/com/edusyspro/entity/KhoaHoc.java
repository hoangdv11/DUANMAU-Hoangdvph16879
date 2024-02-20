package com.edusyspro.entity;

import java.util.Date;

public class KhoaHoc {

    private String MaKH, TenKH;
    private String MaCD;
    private int ThoiLuong;
    private double HocPhi;
    private Date NgayKG;
    private String GhiChu;
    private String MaNV;
    private Date NgayTao;

    public KhoaHoc() {
    }

    public KhoaHoc(String MaKH, String TenKH, String MaCD, int ThoiLuong, double HocPhi, Date NgayKG, String GhiChu, String MaNV, Date NgayTao) {
        this.MaKH = MaKH;
        this.TenKH = TenKH;
        this.MaCD = MaCD;
        this.ThoiLuong = ThoiLuong;
        this.HocPhi = HocPhi;
        this.NgayKG = NgayKG;
        this.GhiChu = GhiChu;
        this.MaNV = MaNV;
        this.NgayTao = NgayTao;
    }

    public String getMaKH() {
        return MaKH;
    }

    public void setMaKH(String MaKH) {
        this.MaKH = MaKH;
    }

    public String getTenKH() {
        return TenKH;
    }

    public void setTenKH(String TenKH) {
        this.TenKH = TenKH;
    }

    public String getMaCD() {
        return MaCD;
    }

    public void setMaCD(String MaCD) {
        this.MaCD = MaCD;
    }

    public int getThoiLuong() {
        return ThoiLuong;
    }

    public void setThoiLuong(int ThoiLuong) {
        this.ThoiLuong = ThoiLuong;
    }

    public double getHocPhi() {
        return HocPhi;
    }

    public void setHocPhi(double HocPhi) {
        this.HocPhi = HocPhi;
    }

    public Date getNgayKG() {
        return NgayKG;
    }

    public void setNgayKG(Date NgayKG) {
        this.NgayKG = NgayKG;
    }

    public String getGhiChu() {
        return GhiChu;
    }

    public void setGhiChu(String GhiChu) {
        this.GhiChu = GhiChu;
    }

    public String getMaNV() {
        return MaNV;
    }

    public void setMaNV(String MaNV) {
        this.MaNV = MaNV;
    }

    public Date getNgayTao() {
        return NgayTao;
    }

    public void setNgayTao(Date NgayTao) {
        this.NgayTao = NgayTao;
    }

    @Override
    public String toString() {
        return TenKH + " (" + NgayKG + ")";
    }
}
