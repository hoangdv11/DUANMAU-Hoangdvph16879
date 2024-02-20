
package com.edusyspro.entity;


public class HocVien {
    private String MaHV;
    private String MaKH;
    private String MaNH;
    private double Diem;

    public HocVien() {
    }

    public HocVien(String MaHV, String MaKH, String MaNH, double Diem) {
        this.MaHV = MaHV;
        this.MaKH = MaKH;
        this.MaNH = MaNH; 
        this.Diem = Diem;
    }

    public String getMaHV() {
        return MaHV;
    }

    public void setMaHV(String MaHV) {
        this.MaHV = MaHV;
    }

    public String getMaKH() {
        return MaKH;
    }

    public void setMaKH(String MaKH) {
        this.MaKH = MaKH;
    }

    public String getMaNH() {
        return MaNH;
    }

    public void setMaNH(String MaNH) {
        this.MaNH = MaNH;
    }

    public double getDiem() {
        return Diem;
    }

    public void setDiem(double Diem) {
        this.Diem = Diem;
    }
    
    public static String xepLoai(double diem) {
        if (diem < 0) {
            return "Chưa nhập";
        }
        if (diem < 5) {
            return "Chưa đạt";
        } else if (diem < 7) {
            return "Đạt";
        } else if (diem < 8) {
            return "Khá";
        } else if (diem < 9) {
            return "Giỏi";
        }
        return "Xuất sắc";
    }
}
