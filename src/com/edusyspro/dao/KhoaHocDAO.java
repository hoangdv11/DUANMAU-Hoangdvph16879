package com.edusyspro.dao;

import com.edusyspro.entity.KhoaHoc;
import com.edusyspro.utils.JDBCHelper;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class KhoaHocDAO extends EduSysProDAO<KhoaHoc, String> {

    final String INSERT_SQL = "INSERT INTO [dbo].[KhoaHoc] ([TenKH],[MaCD],[HocPhi],[ThoiLuong],[NgayKG],[GhiChu],[MaNV],[NgayTao])\n"
            + "			VALUES (?,?,?,?,?,?,?,?)";
    final String UPDATE_SQL = "UPDATE [dbo].[KhoaHoc]\n"
            + "SET [NgayKG] =?,[GhiChu] = ?\n"
            + "WHERE [MaKH] = ?";
    final String DELETE_SQL = "DELETE FROM [dbo].[KhoaHoc]\n"
            + "WHERE [MaKH] = ?";
    final String SELECT_ALL_SQL = "SELECT * FROM [dbo].[KhoaHoc]";
    final String SELECT_BY_ID_SQL = "SELECT * FROM [dbo].[KhoaHoc] WHERE [MaKH] =?";

    @Override
    public void insert(KhoaHoc entity) {
        JDBCHelper.update(INSERT_SQL, entity.getTenKH(), entity.getMaCD(), entity.getHocPhi(), entity.getThoiLuong(), entity.getNgayKG(), entity.getGhiChu(), entity.getMaNV(), entity.getNgayTao());
    }

    @Override
    public void update(KhoaHoc entity) {
        JDBCHelper.update(UPDATE_SQL, entity.getNgayKG(), entity.getGhiChu(), entity.getMaKH());
    }

    @Override
    public void delete(String id) {
        JDBCHelper.update(DELETE_SQL, id);
    }

    @Override
    public KhoaHoc selectById(String id) {
        List<KhoaHoc> list = this.selectBySql(SELECT_BY_ID_SQL, id);
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    @Override
    public List<KhoaHoc> selectAll() {
        return this.selectBySql(SELECT_ALL_SQL);
    }

    public List<KhoaHoc> selectByChuyenDe(String maCD) {
        String sql = "SELECT * FROM KhoaHoc WHERE MaCD = ?";
        return this.selectBySql(sql, maCD);
    }
    
    public List<Integer> selectYears() {
        String sql = "select distinct year(ngayKG) as year from KhoaHoc order by year desc";
        List<Integer> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql);
            while (rs.next()) {                
                list.add(rs.getInt(1));
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected List<KhoaHoc> selectBySql(String sql, Object... args) {
        List<KhoaHoc> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {
                KhoaHoc kh = new KhoaHoc();
                kh.setMaKH(rs.getString("MaKH"));
                kh.setTenKH(rs.getString("TenKH"));
                kh.setMaCD(rs.getString("MaCD"));
                kh.setHocPhi(rs.getDouble("HocPhi"));
                kh.setThoiLuong(rs.getInt("ThoiLuong"));
                kh.setNgayKG(rs.getDate("NgayKG"));
                kh.setGhiChu(rs.getString("GhiChu"));
                kh.setMaNV(rs.getString("MaNV"));
                kh.setNgayTao(rs.getDate("NgayTao"));
                list.add(kh);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
