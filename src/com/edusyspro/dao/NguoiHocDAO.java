/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.dao;

import com.edusyspro.entity.NguoiHoc;
import com.edusyspro.utils.Auth;
import com.edusyspro.utils.JDBCHelper;
import com.edusyspro.utils.XDate;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author ADMIN
 */
public class NguoiHocDAO extends EduSysProDAO<NguoiHoc, String> {

    final String INSERT_SQL = "INSERT INTO [dbo].[NguoiHoc] ([MaNH],[HoTen],[NgaySinh],[GioiTinh],[Email],[DienThoai],[MaNV],[NgayDK],[GhiChu])\n"
            + "			VALUES (?,?,?,?,?,?,?,?,?)";
    final String UPDATE_SQL = "UPDATE [dbo].[NguoiHoc]\n"
            + "SET [HoTen] = ? ,[NgaySinh] = ?, [GioiTinh] =?,[Email] =?,[DienThoai] =?,[GhiChu] = ?\n"
            + "WHERE [MaNH] = ?";
    final String DELETE_SQL = "DELETE FROM [dbo].[NguoiHoc]\n"
            + "WHERE [MaNH] = ?";
    final String SELECT_ALL_SQL = "SELECT * FROM [dbo].[NguoiHoc]";
    final String SELECT_BY_ID_SQL = "SELECT * FROM [dbo].[NguoiHoc] WHERE [MaNH] =?";

    @Override
    public void insert(NguoiHoc entity) {
        JDBCHelper.update(INSERT_SQL, entity.getMaNH(), entity.getHoTen(), entity.getNgaySinh(), entity.isGioiTinh(), entity.getEmail(), entity.getDienThoai(), Auth.user.getMaNV(), XDate.toString(new Date(), "yyyy/MM/dd"), entity.getGhiChu());
    }

    @Override
    public void update(NguoiHoc entity) {
        JDBCHelper.update(UPDATE_SQL, entity.getHoTen(), entity.getNgaySinh(), entity.isGioiTinh(), entity.getEmail(), entity.getDienThoai(), entity.getGhiChu(), entity.getMaNH());
    }

    @Override
    public void delete(String id) {
        JDBCHelper.update(DELETE_SQL, id);
    }

    @Override
    public NguoiHoc selectById(String id) {
        List<NguoiHoc> list = this.selectBySql(SELECT_BY_ID_SQL, id);
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    @Override
    public List<NguoiHoc> selectAll() {
        return this.selectBySql(SELECT_ALL_SQL);
    }

    @Override
    protected List<NguoiHoc> selectBySql(String sql, Object... args) {
        List<NguoiHoc> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {
                NguoiHoc nh = new NguoiHoc();
                nh.setMaNH(rs.getString("MaNH"));
                nh.setHoTen(rs.getString("HoTen"));
                nh.setNgaySinh(rs.getDate("NgaySinh"));
                nh.setGioiTinh(rs.getBoolean("GioiTinh"));
                nh.setEmail(rs.getString("Email"));
                nh.setDienThoai(rs.getString("DienThoai"));
                nh.setMaNV(rs.getString("MaNV"));
                nh.setNgayDK(rs.getDate("NgayDK"));
                nh.setGhiChu(rs.getString("GhiChu"));
                list.add(nh);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public List<NguoiHoc> selectByKeyword(String keyword) {
        String sql = "select * from NguoiHoc where hoTen like ?";
        return this.selectBySql(sql, "%" + keyword + "%");
    }
    
    public List<NguoiHoc> selectNotInCourse(int maKH, String keyword) {
        String sql = "select * from NguoiHoc "
                + "where HoTen like ? and "
                + "MaNH not in (select MaNH from HocVien where MaKH = ?)";
        return selectBySql(sql, "%" + keyword + "%", maKH);
    }
}
