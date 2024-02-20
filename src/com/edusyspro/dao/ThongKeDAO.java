/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.dao;

import com.edusyspro.utils.JDBCHelper;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ADMIN
 */
public class ThongKeDAO {

    private List<Object[]> getListOfArray(String sql, String[] cols, Object...args) {
        try {
            List<Object[]> list = new ArrayList<>();
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {                
                Object[] vals = new Object[cols.length];
                for (int i = 0; i < cols.length; i++) {
                    vals[i] = rs.getObject(cols[i]);
                }
                list.add(vals);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    
    public List<Object[]> getBangDiem(Integer MaKH) {
        String sql = "{call SP_BangDiem(?)}";
        String[] cols = {"MaNH", "HoTen", "Diem"};
        return this.getListOfArray(sql, cols, MaKH);
    }
    
    public List<Object[]> getLuongNguoiHoc() {
        String sql = "{call SP_LuongNguoiHoc}";
        String[] cols = {"Nam", "SoLuong", "DangKySomNhat", "DangKyMuonNhat"};
        return this.getListOfArray(sql, cols);
    }
    
    public List<Object[]> getDiemChuyenDe() {
        String sql = "{call SP_DiemChuyenDe}";
        String[] cols = {"ChuyenDe", "SoHocVien", "DiemCaoNhat", "DiemThapNhat", "DiemTrungBinh"};
        return this.getListOfArray(sql, cols);
    }
    
    public List<Object[]> getTopChuyenDeKhoaHoc() {
        String sql = "{call SP_TopChuyenDe}";
        String[] cols = {"maxCD","maxKH","minCD","minKH"};
        return this.getListOfArray(sql, cols);
    }
    
    public List<Object[]> getDoanhThu(int nam) {
        String sql = "{call SP_DoanhThu(?)}";
        String[] cols = {"ChuyenDe", "SoKhoaHoc", "SoHocVien", "DoanhThu", "HocPhiCaoNhat", "HocPhiThapNhat", "HocPhiTrungBinh"};
        return this.getListOfArray(sql, cols, nam);
    }
    
    public List<Object[]> getLoiNhuan(int nam) {
        String sql = "{call SP_DoanhThuLoiNhuan(?)}";
        String[] cols = {"DoanhThu", "ChiPhi", "LoiNhuan"};
        return this.getListOfArray(sql, cols, nam);
    }
}
