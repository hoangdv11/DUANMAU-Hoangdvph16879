/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.dao;

import com.edusyspro.entity.NguoiDay;
import com.edusyspro.utils.Auth;
import com.edusyspro.utils.JDBCHelper;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author ADMIN
 */
public class NguoiDayDAO extends EduSysProDAO<NguoiDay, String> {

    final String INSERT_SQL = "INSERT INTO [dbo].[NguoiDay]([MaND],[HoTen],[NgaySinh],[GioiTinh],[DienThoai],[Email],[Luong],[MaNV],[NgayDK],[GhiChu])\n"
            + "     VALUES(?,?,?,?,?,?,?,?,?,?)";
    final String UPDATE_SQL = "UPDATE [dbo].[NguoiDay]\n"
            + "   SET [HoTen] = ?,[NgaySinh] = ?,[GioiTinh] = ?,[DienThoai] = ?,[Email] = ?,[Luong] = ?,[GhiChu] = ?\n"
            + " WHERE [MaND] = ?";
    final String DELETE_SQL = "DELETE FROM [dbo].[NguoiDay]\n"
            + "      WHERE [MaND] = ?";
    final String SELECT_ALL_SQL = "SELECT * FROM [dbo].[NguoiDay]";
    final String SELECT_BY_ID_SQL = "SELECT * FROM [dbo].[NguoiDay] WHERE [MaND] = ?";

    @Override
    public void insert(NguoiDay entity) {
        JDBCHelper.update(INSERT_SQL, entity.getMaND(), entity.getHoTen(), entity.getNgaySinh(), entity.isGioiTinh(), entity.getDienThoai(), entity.getEmail(), entity.getLuong(), Auth.user.getMaNV(), new SimpleDateFormat("yyyy-MM-dd").format(new Date()), entity.getGhiChu());
    }

    @Override
    public void update(NguoiDay entity) {
        JDBCHelper.update(UPDATE_SQL, entity.getHoTen(), entity.getNgaySinh(), entity.isGioiTinh(), entity.getDienThoai(), entity.getEmail(), entity.getLuong(), entity.getGhiChu(), entity.getMaND());
    }

    @Override
    public void delete(String id) {
        JDBCHelper.update(DELETE_SQL, id);
    }

    @Override
    public NguoiDay selectById(String id) {
        List<NguoiDay> list = this.selectBySql(SELECT_BY_ID_SQL, id);
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    @Override
    public List<NguoiDay> selectAll() {
        return this.selectBySql(SELECT_ALL_SQL);
    }

    public List<NguoiDay> selectByKeyword(String keyword) {
        String sql = "SELECT * FROM NguoiDay WHERE HoTen LIKE ?";
        return this.selectBySql(sql, "%" + keyword + "%");
    }

    public List<NguoiDay> selectNotInCoure(int makh, String keyword) {
        String sql = "SELECT * FROM NguoiDay "
                + "WHERE HoTen LIKE ? AND "
                + "MaND NOT IN (SELECT MaND FROM GiangVien WHERE MaKH = ?)";
        return this.selectBySql(sql, "%" + keyword + "%", makh);
    }

    @Override
    protected List<NguoiDay> selectBySql(String sql, Object... args) {
        List<NguoiDay> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {
                NguoiDay nd = new NguoiDay();
                nd.setMaND(rs.getString("MaND"));
                nd.setHoTen(rs.getString("HoTen"));
                nd.setNgaySinh(rs.getDate("NgaySinh"));
                nd.setGioiTinh(rs.getBoolean("GioiTinh"));
                nd.setDienThoai(rs.getString("DienThoai"));
                nd.setEmail(rs.getString("Email"));
                nd.setLuong(rs.getDouble("Luong"));
                nd.setMaNV(rs.getString("MaNV"));
                nd.setNgayDK(rs.getDate("NgayDK"));
                nd.setGhiChu(rs.getString("GhiChu"));
                list.add(nd);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

}
