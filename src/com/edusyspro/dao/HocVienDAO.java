package com.edusyspro.dao;

import com.edusyspro.entity.HocVien;
import com.edusyspro.entity.NguoiHoc;
import com.edusyspro.utils.JDBCHelper;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class HocVienDAO extends EduSysProDAO<HocVien, String> {

    final String INSERT_SQL = "INSERT INTO [dbo].[HocVien] ([MaKH],[MaNH],[Diem])\n"
            + "			VALUES (?,?,?)";
    final String UPDATE_SQL = "UPDATE [dbo].[HocVien]\n"
            + "SET [MaKH] =?, [MaNH] =?, [Diem] =?\n"
            + "WHERE [MaHV] = ?";
    final String DELETE_SQL = "DELETE FROM [dbo].[HocVien]\n"
            + "WHERE [MaHV] = ?";
    final String SELECT_ALL_SQL = "SELECT * FROM [dbo].[HocVien]";
    final String SELECT_BY_ID_SQL = "SELECT * FROM [dbo].[HocVien] WHERE [MaHV] =?";

    @Override
    public void insert(HocVien entity) {
        JDBCHelper.update(INSERT_SQL, entity.getMaKH(), entity.getMaNH(), entity.getDiem());
    }

    @Override
    public void update(HocVien entity) {
        JDBCHelper.update(UPDATE_SQL, entity.getMaKH(), entity.getMaNH(), entity.getDiem(),entity.getMaHV());
    }

    @Override
    public void delete(String id) {
        JDBCHelper.update(DELETE_SQL, id);
    }

    @Override
    public HocVien selectById(String id) {
        List<HocVien> list = this.selectBySql(SELECT_BY_ID_SQL, id);
        if (list.isEmpty()) {
            return null;
        }
        return list.get(0);
    }

    @Override
    public List<HocVien> selectAll() {
        return this.selectBySql(SELECT_ALL_SQL);
    }

    @Override
    protected List<HocVien> selectBySql(String sql, Object... args) {
        List<HocVien> list = new ArrayList<>();
        try {
            ResultSet rs = JDBCHelper.query(sql, args);
            while (rs.next()) {
                HocVien hv = new HocVien();
                hv.setMaHV(rs.getString("MaHV"));
                hv.setMaKH(rs.getString("MaKH"));
                hv.setMaNH(rs.getString("MaNH"));
                hv.setDiem(rs.getDouble("Diem"));
                list.add(hv);
            }
            rs.getStatement().getConnection().close();
            return list;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public List<HocVien> selectByKhoaHoc(String maKH) {
        String sql = "select * from HocVien where MaKH = ?";
        return selectBySql(sql, maKH);
    }
}
