/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.dao;

import com.edusyspro.entity.ChuyenDe;
import com.edusyspro.utils.JDBCHelper;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ADMIN
 */
public class ChuyenDeDAO extends EduSysProDAO<ChuyenDe, String> {

    final String INSERT_SQL = "INSERT INTO [dbo].[ChuyenDe]([MaCD],[TenCD],[HocPhi],[ThoiLuong],[Hinh],[MoTa])\n"
            + "VALUES(?,?,?,?,?,?)";
    final String UPDATE_SQL = "UPDATE [dbo].[ChuyenDe]\n"
            + "              SET [TenCD] = ?,[HocPhi] = ?,[ThoiLuong] = ?,[Hinh] = ?,[MoTa] = ?\n"
            + "            WHERE [MaCD] = ?";
    final String DELETE_SQL = "DELETE FROM [dbo].[ChuyenDe]\n"
            + "                 WHERE [MaCD] = ?";
    final String SELECT_ALL_SQL = "SELECT * FROM [dbo].[ChuyenDe]";
    final String SELECT_BY_ID_SQL = "SELECT * FROM [dbo].[ChuyenDe] WHERE [MaCD] = ?";

    @Override
    public void insert(ChuyenDe entity) {
        JDBCHelper.update(INSERT_SQL, entity.getMaCD(), entity.getTenCD(), entity.getHocPhi(), entity.getThoiLuong(), entity.getHinh(), entity.getMoTa());
    }

    @Override
    public void update(ChuyenDe entity) {
        JDBCHelper.update(UPDATE_SQL, entity.getTenCD(), entity.getHocPhi(), entity.getThoiLuong(), entity.getHinh(), entity.getMoTa(), entity.getMaCD());
    }

    @Override
    public void delete(String id) {
        JDBCHelper.update(DELETE_SQL, id);
    }

    @Override
    public ChuyenDe selectById(String id) {
        List<ChuyenDe> list = selectBySql(SELECT_BY_ID_SQL, id);
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    @Override
    public List<ChuyenDe> selectAll() {
        return this.selectBySql(SELECT_ALL_SQL);
    }
    
    public List<ChuyenDe> selectByKeyword(String keyword) {
        String sql = "select * from ChuyenDe where TenCD like ?";
        return selectBySql(sql, "%" + keyword + "%");
    }

    @Override
    protected List<ChuyenDe> selectBySql(String sql, Object... args) {
        List<ChuyenDe> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {
                ChuyenDe cd = new ChuyenDe();
                cd.setMaCD(rs.getString("MaCD"));
                cd.setTenCD(rs.getString("TenCD"));
                cd.setHocPhi(rs.getFloat("HocPhi"));
                cd.setThoiLuong(rs.getInt("ThoiLuong"));
                cd.setHinh(rs.getString("Hinh"));
                cd.setMoTa(rs.getString("MoTa"));
                list.add(cd);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

}
