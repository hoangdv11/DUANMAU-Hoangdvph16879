/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.dao;

import com.edusyspro.entity.GiangVien;
import com.edusyspro.utils.JDBCHelper;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ADMIN
 */
public class GiangVienDAO extends EduSysProDAO<GiangVien, String> {

    final String INSERT_SQL = "INSERT INTO [dbo].[GiangVien]([MaND],[MaKH],[GhiChu]) VALUES(?,?,?)";
    final String UPDATE_SQL = "UPDATE [dbo].[GiangVien]\n"
            + "   SET [MaND] = ?,[MaKH] = ?,[GhiChu] = ?\n"
            + " WHERE [MaGV] = ?";
    final String DELETE_SQL = "DELETE FROM [dbo].[GiangVien] WHERE [MaGV] = ?";
    final String SELECT_ALL_SQL = "SELECT * FROM [dbo].[GiangVien]";
    final String SELECT_BY_ID_SQL = "SELECT * FROM [dbo].[GiangVien] WHERE [MaGV] = ?";

    @Override
    public void insert(GiangVien entity) {
        JDBCHelper.update(INSERT_SQL, entity.getMaND(), entity.getMaKH(), entity.getGhiChu());
    }

    @Override
    public void update(GiangVien entity) {
        JDBCHelper.update(UPDATE_SQL, entity.getMaND(), entity.getMaKH(), entity.getGhiChu(), entity.getMaGV());
    }

    @Override
    public void delete(String id) {
        JDBCHelper.update(DELETE_SQL, id);
    }

    @Override
    public GiangVien selectById(String id) {
        List<GiangVien> list = this.selectBySql(SELECT_BY_ID_SQL, id);
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    @Override
    public List<GiangVien> selectAll() {
        return this.selectBySql(SELECT_ALL_SQL);
    }

    public List<GiangVien> selectByKhoaHoc(String maKH) {
        String sql = "SELECT * FROM GiangVien WHERE MaKH = ?";
        return this.selectBySql(sql, maKH);
    }

    @Override
    protected List<GiangVien> selectBySql(String sql, Object... args) {
        List<GiangVien> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {
                GiangVien gv = new GiangVien();
                gv.setMaGV(rs.getInt("MaGV"));
                gv.setMaND(rs.getString("MaND"));
                gv.setMaKH(rs.getInt("MaKH"));
                gv.setGhiChu(rs.getString("GhiChu"));
                list.add(gv);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

}
