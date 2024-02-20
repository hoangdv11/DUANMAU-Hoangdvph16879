/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.entity;

/**
 *
 * @author ADMIN
 */
public class NhanVien {
    
    private String MaNV;
    private byte[] MatKhau;
    private String HoTen;
    private boolean VaiTro;
    private double Luong;
    private byte[] Salt;
    private boolean TrangThai;

    public NhanVien() {
    }

    public NhanVien(String MaNV, byte[] MatKhau, String HoTen, boolean VaiTro, double Luong, byte[] Salt) {
        this.MaNV = MaNV;
        this.MatKhau = MatKhau;
        this.HoTen = HoTen;
        this.VaiTro = VaiTro;
        this.Luong = Luong;
        this.Salt = Salt;
    }

    public String getMaNV() {
        return MaNV;
    }

    public void setMaNV(String MaNV) {
        this.MaNV = MaNV;
    }

    public byte[] getMatKhau() {
        return MatKhau;
    }

    public void setMatKhau(byte[] MatKhau) {
        this.MatKhau = MatKhau;
    }

    public String getHoTen() {
        return HoTen;
    }

    public void setHoTen(String HoTen) {
        this.HoTen = HoTen;
    }

    public boolean isVaiTro() {
        return VaiTro;
    }

    public void setVaiTro(boolean VaiTro) {
        this.VaiTro = VaiTro;
    }

    public double getLuong() {
        return Luong;
    }

    public void setLuong(double Luong) {
        this.Luong = Luong;
    }

    public byte[] getSalt() {
        return Salt;
    }

    public void setSalt(byte[] Salt) {
        this.Salt = Salt;
    }

    public boolean isTrangThai() {
        return TrangThai;
    }

    public void setTrangThai(boolean TrangThai) {
        this.TrangThai = TrangThai;
    }
}
