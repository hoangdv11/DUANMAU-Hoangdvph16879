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
public class GiangVien {

    private int MaGV;
    private String MaND;
    private int MaKH;
    private String GhiChu;

    public GiangVien() {
    }

    public GiangVien(int MaGV, String MaND, int MaKH, String GhiChu) {
        this.MaGV = MaGV;
        this.MaND = MaND;
        this.MaKH = MaKH;
        this.GhiChu = GhiChu;
    }

    public int getMaGV() {
        return MaGV;
    }

    public void setMaGV(int MaGV) {
        this.MaGV = MaGV;
    }

    public String getMaND() {
        return MaND;
    }

    public void setMaND(String MaND) {
        this.MaND = MaND;
    }

    public int getMaKH() {
        return MaKH;
    }

    public void setMaKH(int MaKH) {
        this.MaKH = MaKH;
    }

    public String getGhiChu() {
        return GhiChu;
    }

    public void setGhiChu(String GhiChu) {
        this.GhiChu = GhiChu;
    }
}
