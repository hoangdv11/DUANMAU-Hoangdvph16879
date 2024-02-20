/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.dao;

import com.edusyspro.entity.NhanVien;
import com.edusyspro.utils.JDBCHelper;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ADMIN
 */
public class NhanVienDAO extends EduSysProDAO<NhanVien, String> {

    final String INSERT_SQL = "{call SP_ThemNhanVien(?,?,?,?,?)}";
    final String UPDATE_SQL = "UPDATE [dbo].[NhanVien] SET [HoTen]= ?,[VaiTro]= ?,[Luong]= ?,[TrangThai]= ? \n"
            + "WHERE [MaNV] = ?";
    final String DELETE_SQL = "DELETE FROM [dbo].[NhanVien]\n"
            + "WHERE [MaNV] = ?";
    final String SELECT_ALL_SQL = "SELECT * FROM [dbo].[NhanVien]";
    final String SELECT_BY_ID_SQL = "SELECT * FROM [dbo].[NhanVien] WHERE [MaNV] = ?";
    final String SELECT_BY_STATUS_SQL = "SELECT * FROM [dbo].[NhanVien] WHERE [TrangThai] = ?";

    @Override
    public void insert(NhanVien entity) {
        JDBCHelper.update(INSERT_SQL, entity.getMaNV(), entity.getMatKhau(), entity.getHoTen(), entity.isVaiTro(), entity.getLuong());
    }

    @Override
    public void update(NhanVien entity) {
        JDBCHelper.update(UPDATE_SQL, entity.getHoTen(), entity.isVaiTro(), entity.getLuong(), entity.isTrangThai(), entity.getMaNV());
    }

    @Override
    public void delete(String id) {
        JDBCHelper.update(DELETE_SQL, id);
    }

    @Override
    public NhanVien selectById(String id) {
        List<NhanVien> list = this.selectBySql(SELECT_BY_ID_SQL, id);
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }
    
    public List<NhanVien> selectByStatus(boolean status) {
        List<NhanVien> list = this.selectBySql(SELECT_BY_STATUS_SQL, status);
        return list;
    }

    @Override
    public List<NhanVien> selectAll() {
        return this.selectBySql(SELECT_ALL_SQL);
    }

    @Override
    protected List<NhanVien> selectBySql(String sql, Object... args) {
        List<NhanVien> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {
                NhanVien nv = new NhanVien();
                nv.setMaNV(rs.getString("MaNV"));
                nv.setMatKhau(rs.getBytes("MatKhau"));
                nv.setHoTen(rs.getString("HoTen"));
                nv.setLuong(rs.getDouble("Luong"));
                nv.setVaiTro(rs.getBoolean("VaiTro"));
                nv.setTrangThai(rs.getBoolean("TrangThai"));
                list.add(nv);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

}
