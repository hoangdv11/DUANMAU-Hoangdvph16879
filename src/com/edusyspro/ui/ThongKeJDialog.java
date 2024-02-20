/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.ui;

import com.edusyspro.dao.ChuyenDeDAO;
import com.edusyspro.dao.KhoaHocDAO;
import com.edusyspro.dao.NguoiHocDAO;
import com.edusyspro.dao.ThongKeDAO;
import com.edusyspro.entity.ChuyenDe;
import com.edusyspro.entity.HocVien;
import com.edusyspro.entity.KhoaHoc;
import com.edusyspro.utils.Auth;
import com.edusyspro.utils.MsgBox;
import com.edusyspro.utils.XFormater;
import com.edusyspro.utils.XImage;
import java.io.FileOutputStream;
import java.util.List;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JFileChooser;
import javax.swing.JTable;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.table.DefaultTableModel;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 *
 * @author ADMIN
 */
public class ThongKeJDialog extends javax.swing.JDialog {

    /**
     * Creates new form HuongDanJDialog
     */
    ThongKeDAO thongKeDAO = new ThongKeDAO();
    ChuyenDeDAO chuyenDeDAO = new ChuyenDeDAO();
    KhoaHocDAO khoaHocDAO = new KhoaHocDAO();
    NguoiHocDAO nguoiHocDAO = new NguoiHocDAO();

    public ThongKeJDialog(java.awt.Frame parent, boolean modal) {
//        super(parent, modal);
        initComponents();
        init();
        fillComboBoxChuyenDe();
        fillTableNguoiHoc();
        fillTableDiemChuyenDe();
        fillTableTopChuyenDeKhoaHoc();
        fillComboBoxNam();
    }

    private void init() {
        setLocationRelativeTo(null);
        setIconImage(XImage.getAppIcon());
        this.selectTab(0);
        if (!Auth.isManager()) {
            tbpThongKe.setEnabledAt(3, false);
        }
    }

    public void selectTab(int index) {
        tbpThongKe.setSelectedIndex(index);
    }

    private void fillComboBoxChuyenDe() {
        DefaultComboBoxModel comboBoxModel = (DefaultComboBoxModel) cbbChuyenDe.getModel();
        comboBoxModel.removeAllElements();
        List<ChuyenDe> list = chuyenDeDAO.selectAll();
        for (ChuyenDe cd : list) {
            comboBoxModel.addElement(cd);
        }
        fillComboBoxKhoaHoc();
    }

    private void fillComboBoxKhoaHoc() {
        DefaultComboBoxModel comboBoxModel = (DefaultComboBoxModel) cbbKhoaHoc.getModel();
        comboBoxModel.removeAllElements();
        ChuyenDe cd = (ChuyenDe) cbbChuyenDe.getSelectedItem();
        if (cd != null) {
            List<KhoaHoc> list = khoaHocDAO.selectByChuyenDe(cd.getMaCD());
            for (KhoaHoc kh : list) {
                comboBoxModel.addElement(kh);
            }
            fillTableBangDiem();
        }
    }

    private void fillTableBangDiem() {
        DefaultTableModel tableModel = (DefaultTableModel) tblBangDiem.getModel();
        tableModel.setRowCount(0);
        KhoaHoc kh = (KhoaHoc) cbbKhoaHoc.getSelectedItem();
        if (kh != null) {
            List<Object[]> list = thongKeDAO.getBangDiem(Integer.parseInt(kh.getMaKH()));
            for (Object[] obj : list) {
                double diem = (double) obj[2];
                tableModel.addRow(new Object[]{
                    obj[0], obj[1], diem, HocVien.xepLoai(diem)
                });
            }
        }
    }

    private void fillTableNguoiHoc() {
        DefaultTableModel tableModel = (DefaultTableModel) tblNguoiHoc.getModel();
        tableModel.setRowCount(0);
        List<Object[]> list = thongKeDAO.getLuongNguoiHoc();
        for (Object[] obj : list) {
            tableModel.addRow(obj);
        }
    }

    private void fillTableDiemChuyenDe() {
        DefaultTableModel tableModel = (DefaultTableModel) tblDiemChuyenDe.getModel();
        tableModel.setRowCount(0);
        List<Object[]> list = thongKeDAO.getDiemChuyenDe();
        for (Object[] obj : list) {
            tableModel.addRow(new Object[]{
                obj[0], obj[1], obj[2], obj[3], Math.ceil(Double.parseDouble(obj[4].toString()) * 100) / 100
            });
        }
    }

    private void fillTableTopChuyenDeKhoaHoc() {
        DefaultTableModel tableModel = (DefaultTableModel) tblTopChuyenDeKhoaHoc.getModel();
        tableModel.setRowCount(0);
        List<Object[]> list = thongKeDAO.getTopChuyenDeKhoaHoc();
        for (Object[] obj : list) {
            tableModel.addRow(new Object[]{
                obj[0], obj[1], obj[2], obj[3]
            });
        }
    }

    private void fillComboBoxNam() {
        DefaultComboBoxModel comboBoxModel = (DefaultComboBoxModel) cbbNam.getModel();
        comboBoxModel.removeAllElements();
        List<Integer> list = khoaHocDAO.selectYears();
        for (Integer integer : list) {
            comboBoxModel.addElement(integer);
        }
        fillTableDoanhThu();
    }

    private void fillTableDoanhThu() {
        DefaultTableModel tableModel = (DefaultTableModel) tblDoanhThu.getModel();
        tableModel.setRowCount(0);
        int nam = Integer.parseInt(cbbNam.getSelectedItem().toString());
        List<Object[]> list = thongKeDAO.getDoanhThu(nam);
        for (Object[] obj : list) {
            tableModel.addRow(new Object[]{
                obj[0], obj[1], obj[2], XFormater.toCurrency((double) obj[3]), XFormater.toCurrency((double) obj[4]), XFormater.toCurrency((double) obj[5]), XFormater.toCurrency((double) obj[6])
            });
        }
        fillTableLoiNhuan();
    }

    private void fillTableLoiNhuan() {
        DefaultTableModel tableModel = (DefaultTableModel) tblLoiNhuan.getModel();
        tableModel.setRowCount(0);
        int nam = Integer.parseInt(cbbNam.getSelectedItem().toString());
        List<Object[]> list = thongKeDAO.getLoiNhuan(nam);
        for (Object[] obj : list) {
            tableModel.addRow(new Object[]{
                XFormater.toCurrency((double) obj[0]), XFormater.toCurrency((double) obj[1]), XFormater.toCurrency((double) obj[2])
            });
        }
    }

    private void exportToExcel(JTable tbl, String name) {
        try {
            DefaultTableModel tableModel = (DefaultTableModel) tbl.getModel();
            XSSFWorkbook workbook = new XSSFWorkbook();
            XSSFSheet spreadsheet = workbook.createSheet(tbl.getName());

            XSSFRow row = null;
            Cell cell = null;

            row = spreadsheet.createRow((short) 0);
            row.setHeight((short) 500);
            cell = row.createCell(0, CellType.STRING);
            cell.setCellValue(name);
            spreadsheet.addMergedRegion(new CellRangeAddress(0, 0, cell.getColumnIndex(), tableModel.getColumnCount() - 1));

            row = spreadsheet.createRow((short) 1);
            row.setHeight((short) 500);
            for (int i = 0; i < tableModel.getColumnCount(); i++) {
                cell = row.createCell(i, CellType.STRING);
                cell.setCellValue(tableModel.getColumnName(i));
            }

            for (int i = 0; i < tableModel.getRowCount(); i++) {
                row = spreadsheet.createRow((short) 2 + i);
                row.setHeight((short) 400);
                for (int j = 0; j < tableModel.getColumnCount(); j++) {
                    cell = row.createCell(j);
                    cell.setCellValue(tbl.getValueAt(i, j).toString());
                }
            }

            JFileChooser fileChooser = new JFileChooser();
            fileChooser.setDialogTitle("Save as ...");
            FileNameExtensionFilter extensionFilter = new FileNameExtensionFilter("Files", "xls", "xlsx");
            fileChooser.setFileFilter(extensionFilter);
            int path = fileChooser.showSaveDialog(null);
            if (path != JFileChooser.APPROVE_OPTION) {
                return;
            }
            FileOutputStream out = new FileOutputStream(fileChooser.getSelectedFile() + ".xlsx");
            workbook.write(out);
            out.close();
            MsgBox.alert(this, "Xuất file excel thành công");

        } catch (Exception e) {
            MsgBox.alert(this, "Xuất file excel thất bại");
            e.printStackTrace();
        }
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jLabel1 = new javax.swing.JLabel();
        tbpThongKe = new javax.swing.JTabbedPane();
        pnlBangDiem = new javax.swing.JPanel();
        jScrollPane1 = new javax.swing.JScrollPane();
        tblBangDiem = new javax.swing.JTable();
        jPanel1 = new javax.swing.JPanel();
        cbbChuyenDe = new javax.swing.JComboBox<>();
        jPanel2 = new javax.swing.JPanel();
        cbbKhoaHoc = new javax.swing.JComboBox<>();
        btnExportBangDiem = new javax.swing.JButton();
        pnlLuongNguoiHoc = new javax.swing.JPanel();
        jScrollPane2 = new javax.swing.JScrollPane();
        tblNguoiHoc = new javax.swing.JTable();
        jScrollPane3 = new javax.swing.JScrollPane();
        tblTopChuyenDeKhoaHoc = new javax.swing.JTable();
        btnExportNguoiHoc = new javax.swing.JButton();
        pnlDiemChuyenDe = new javax.swing.JPanel();
        jScrollPane4 = new javax.swing.JScrollPane();
        tblDiemChuyenDe = new javax.swing.JTable();
        btnExportDiemCD = new javax.swing.JButton();
        pnlDoanhThuLoiNhuan = new javax.swing.JPanel();
        jPanel7 = new javax.swing.JPanel();
        cbbNam = new javax.swing.JComboBox<>();
        jScrollPane5 = new javax.swing.JScrollPane();
        tblDoanhThu = new javax.swing.JTable();
        jScrollPane6 = new javax.swing.JScrollPane();
        tblLoiNhuan = new javax.swing.JTable();
        btnExportDoanhThu = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("EduSysPro - Tổng hợp - Thống kê");

        jLabel1.setFont(new java.awt.Font("Tahoma", 1, 18)); // NOI18N
        jLabel1.setForeground(new java.awt.Color(0, 0, 255));
        jLabel1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        jLabel1.setText("TỔNG HỢP - THỐNG KÊ");

        tblBangDiem.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null},
                {null, null, null, null},
                {null, null, null, null},
                {null, null, null, null}
            },
            new String [] {
                "Mã người học", "Họ tên", "Điểm", "Xếp loại"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        tblBangDiem.setName("Bảng điểm"); // NOI18N
        tblBangDiem.setRowHeight(25);
        jScrollPane1.setViewportView(tblBangDiem);

        jPanel1.setBorder(javax.swing.BorderFactory.createTitledBorder(null, "Chuyên đề", javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION, javax.swing.border.TitledBorder.DEFAULT_POSITION, new java.awt.Font("Tahoma", 1, 14), new java.awt.Color(255, 0, 0))); // NOI18N

        cbbChuyenDe.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                cbbChuyenDeItemStateChanged(evt);
            }
        });

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(cbbChuyenDe, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(cbbChuyenDe, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jPanel2.setBorder(javax.swing.BorderFactory.createTitledBorder(null, "Khóa học", javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION, javax.swing.border.TitledBorder.DEFAULT_POSITION, new java.awt.Font("Tahoma", 1, 14), new java.awt.Color(255, 0, 0))); // NOI18N

        cbbKhoaHoc.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                cbbKhoaHocItemStateChanged(evt);
            }
        });

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(cbbKhoaHoc, 0, 278, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(cbbKhoaHoc, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        btnExportBangDiem.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/edusyspro/icon/Upload.png"))); // NOI18N
        btnExportBangDiem.setText("Export to Excel");
        btnExportBangDiem.setCursor(new java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
        btnExportBangDiem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btnExportBangDiemActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout pnlBangDiemLayout = new javax.swing.GroupLayout(pnlBangDiem);
        pnlBangDiem.setLayout(pnlBangDiemLayout);
        pnlBangDiemLayout.setHorizontalGroup(
            pnlBangDiemLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(pnlBangDiemLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(pnlBangDiemLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 645, Short.MAX_VALUE)
                    .addGroup(pnlBangDiemLayout.createSequentialGroup()
                        .addComponent(jPanel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(jPanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, pnlBangDiemLayout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addComponent(btnExportBangDiem)))
                .addContainerGap())
        );
        pnlBangDiemLayout.setVerticalGroup(
            pnlBangDiemLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(pnlBangDiemLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(pnlBangDiemLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(jPanel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 399, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(btnExportBangDiem)
                .addContainerGap())
        );

        tbpThongKe.addTab("BẢNG ĐIỂM", pnlBangDiem);

        tblNguoiHoc.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null},
                {null, null, null, null},
                {null, null, null, null},
                {null, null, null, null}
            },
            new String [] {
                "Năm", "Số người học", "Đăng ký sớm nhất", "Đăng ký muộn nhất"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        tblNguoiHoc.setName("Lượng người học"); // NOI18N
        tblNguoiHoc.setRowHeight(25);
        jScrollPane2.setViewportView(tblNguoiHoc);

        tblTopChuyenDeKhoaHoc.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null}
            },
            new String [] {
                "Chuyên đề nhiều người học nhất", "Khóa học nhiều người học nhất", "Chuyên đề ít người học nhất", "Khóa học ít người học nhất"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        tblTopChuyenDeKhoaHoc.setRowHeight(25);
        jScrollPane3.setViewportView(tblTopChuyenDeKhoaHoc);

        btnExportNguoiHoc.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/edusyspro/icon/Upload.png"))); // NOI18N
        btnExportNguoiHoc.setText("Export to Excel");
        btnExportNguoiHoc.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btnExportNguoiHocActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout pnlLuongNguoiHocLayout = new javax.swing.GroupLayout(pnlLuongNguoiHoc);
        pnlLuongNguoiHoc.setLayout(pnlLuongNguoiHocLayout);
        pnlLuongNguoiHocLayout.setHorizontalGroup(
            pnlLuongNguoiHocLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(pnlLuongNguoiHocLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(pnlLuongNguoiHocLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 645, Short.MAX_VALUE)
                    .addComponent(jScrollPane2)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, pnlLuongNguoiHocLayout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addComponent(btnExportNguoiHoc)))
                .addContainerGap())
        );
        pnlLuongNguoiHocLayout.setVerticalGroup(
            pnlLuongNguoiHocLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, pnlLuongNguoiHocLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 56, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 407, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(btnExportNguoiHoc)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        tbpThongKe.addTab("NGƯỜI HỌC", pnlLuongNguoiHoc);

        tblDiemChuyenDe.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null}
            },
            new String [] {
                "Chuyên đề", "Số lượng người học", "Điểm cao nhất", "Điểm thấp nhất", "Điểm trung bình"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        tblDiemChuyenDe.setName("Điểm chuyên đề"); // NOI18N
        tblDiemChuyenDe.setRowHeight(25);
        jScrollPane4.setViewportView(tblDiemChuyenDe);

        btnExportDiemCD.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/edusyspro/icon/Upload.png"))); // NOI18N
        btnExportDiemCD.setText("Export to Excel");
        btnExportDiemCD.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btnExportDiemCDActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout pnlDiemChuyenDeLayout = new javax.swing.GroupLayout(pnlDiemChuyenDe);
        pnlDiemChuyenDe.setLayout(pnlDiemChuyenDeLayout);
        pnlDiemChuyenDeLayout.setHorizontalGroup(
            pnlDiemChuyenDeLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(pnlDiemChuyenDeLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(pnlDiemChuyenDeLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jScrollPane4, javax.swing.GroupLayout.DEFAULT_SIZE, 645, Short.MAX_VALUE)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, pnlDiemChuyenDeLayout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addComponent(btnExportDiemCD)))
                .addContainerGap())
        );
        pnlDiemChuyenDeLayout.setVerticalGroup(
            pnlDiemChuyenDeLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(pnlDiemChuyenDeLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jScrollPane4, javax.swing.GroupLayout.DEFAULT_SIZE, 478, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(btnExportDiemCD)
                .addContainerGap())
        );

        tbpThongKe.addTab("ĐIỂM CHUYÊN ĐỀ", pnlDiemChuyenDe);

        jPanel7.setBorder(javax.swing.BorderFactory.createTitledBorder(null, "Năm", javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION, javax.swing.border.TitledBorder.DEFAULT_POSITION, new java.awt.Font("Tahoma", 1, 14), new java.awt.Color(255, 0, 0))); // NOI18N

        cbbNam.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                cbbNamItemStateChanged(evt);
            }
        });

        javax.swing.GroupLayout jPanel7Layout = new javax.swing.GroupLayout(jPanel7);
        jPanel7.setLayout(jPanel7Layout);
        jPanel7Layout.setHorizontalGroup(
            jPanel7Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel7Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(cbbNam, 0, 609, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel7Layout.setVerticalGroup(
            jPanel7Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel7Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(cbbNam, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        tblDoanhThu.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null, null, null, null},
                {null, null, null, null, null, null, null},
                {null, null, null, null, null, null, null},
                {null, null, null, null, null, null, null}
            },
            new String [] {
                "Chuyên đề", "Số khóa học", "Số học viên", "Doanh thu", "Học phí cao nhất", "Học phí thấp nhất", "Học phí trung bình"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false, false, false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        tblDoanhThu.setName("Doanh thu"); // NOI18N
        tblDoanhThu.setRowHeight(25);
        jScrollPane5.setViewportView(tblDoanhThu);

        tblLoiNhuan.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null}
            },
            new String [] {
                "Tổng doanh thu", "Tổng chi phí", "Lợi nhuận"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        tblLoiNhuan.setToolTipText("");
        tblLoiNhuan.setRowHeight(25);
        jScrollPane6.setViewportView(tblLoiNhuan);

        btnExportDoanhThu.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/edusyspro/icon/Upload.png"))); // NOI18N
        btnExportDoanhThu.setText("Export to Excel");
        btnExportDoanhThu.setCursor(new java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
        btnExportDoanhThu.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btnExportDoanhThuActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout pnlDoanhThuLoiNhuanLayout = new javax.swing.GroupLayout(pnlDoanhThuLoiNhuan);
        pnlDoanhThuLoiNhuan.setLayout(pnlDoanhThuLoiNhuanLayout);
        pnlDoanhThuLoiNhuanLayout.setHorizontalGroup(
            pnlDoanhThuLoiNhuanLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(pnlDoanhThuLoiNhuanLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(pnlDoanhThuLoiNhuanLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jScrollPane5, javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(jPanel7, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jScrollPane6)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, pnlDoanhThuLoiNhuanLayout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addComponent(btnExportDoanhThu)))
                .addContainerGap())
        );
        pnlDoanhThuLoiNhuanLayout.setVerticalGroup(
            pnlDoanhThuLoiNhuanLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(pnlDoanhThuLoiNhuanLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jPanel7, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jScrollPane6, javax.swing.GroupLayout.PREFERRED_SIZE, 57, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jScrollPane5, javax.swing.GroupLayout.DEFAULT_SIZE, 306, Short.MAX_VALUE)
                .addGap(18, 18, 18)
                .addComponent(btnExportDoanhThu)
                .addContainerGap())
        );

        tbpThongKe.addTab("DOANH THU - LỢI NHUẬN", pnlDoanhThuLoiNhuan);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(tbpThongKe)
                    .addComponent(jLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jLabel1)
                .addGap(18, 18, 18)
                .addComponent(tbpThongKe, javax.swing.GroupLayout.PREFERRED_SIZE, 580, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void cbbChuyenDeItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_cbbChuyenDeItemStateChanged
        fillComboBoxKhoaHoc();
    }//GEN-LAST:event_cbbChuyenDeItemStateChanged

    private void cbbKhoaHocItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_cbbKhoaHocItemStateChanged
        fillTableBangDiem();
    }//GEN-LAST:event_cbbKhoaHocItemStateChanged

    private void cbbNamItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_cbbNamItemStateChanged
        fillTableDoanhThu();
    }//GEN-LAST:event_cbbNamItemStateChanged

    private void btnExportBangDiemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btnExportBangDiemActionPerformed
        exportToExcel(tblBangDiem, "Bảng điểm lớp " + cbbKhoaHoc.getSelectedItem().toString());
    }//GEN-LAST:event_btnExportBangDiemActionPerformed

    private void btnExportNguoiHocActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btnExportNguoiHocActionPerformed
        exportToExcel(tblNguoiHoc, "Lượng người học hàng năm");
    }//GEN-LAST:event_btnExportNguoiHocActionPerformed

    private void btnExportDiemCDActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btnExportDiemCDActionPerformed
        exportToExcel(tblDiemChuyenDe, "Điểm chuyên đề");
    }//GEN-LAST:event_btnExportDiemCDActionPerformed

    private void btnExportDoanhThuActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btnExportDoanhThuActionPerformed
        exportToExcel(tblDoanhThu, "Doanh thu năm " + cbbNam.getSelectedItem().toString());
    }//GEN-LAST:event_btnExportDoanhThuActionPerformed

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;

                }
            }
        } catch (ClassNotFoundException ex) {
            java.util.logging.Logger.getLogger(ThongKeJDialog.class
                    .getName()).log(java.util.logging.Level.SEVERE, null, ex);

        } catch (InstantiationException ex) {
            java.util.logging.Logger.getLogger(ThongKeJDialog.class
                    .getName()).log(java.util.logging.Level.SEVERE, null, ex);

        } catch (IllegalAccessException ex) {
            java.util.logging.Logger.getLogger(ThongKeJDialog.class
                    .getName()).log(java.util.logging.Level.SEVERE, null, ex);

        } catch (javax.swing.UnsupportedLookAndFeelException ex) {
            java.util.logging.Logger.getLogger(ThongKeJDialog.class
                    .getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>
        //</editor-fold>

        /* Create and display the dialog */
        java.awt.EventQueue.invokeLater(() -> {
            ThongKeJDialog dialog = new ThongKeJDialog(new javax.swing.JFrame(), true);
            dialog.addWindowListener(new java.awt.event.WindowAdapter() {
                @Override
                public void windowClosing(java.awt.event.WindowEvent e) {
                    System.exit(0);
                }
            });
            dialog.setVisible(true);
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton btnExportBangDiem;
    private javax.swing.JButton btnExportDiemCD;
    private javax.swing.JButton btnExportDoanhThu;
    private javax.swing.JButton btnExportNguoiHoc;
    private javax.swing.JComboBox<String> cbbChuyenDe;
    private javax.swing.JComboBox<String> cbbKhoaHoc;
    private javax.swing.JComboBox<String> cbbNam;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JPanel jPanel7;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JScrollPane jScrollPane4;
    private javax.swing.JScrollPane jScrollPane5;
    private javax.swing.JScrollPane jScrollPane6;
    private javax.swing.JPanel pnlBangDiem;
    private javax.swing.JPanel pnlDiemChuyenDe;
    private javax.swing.JPanel pnlDoanhThuLoiNhuan;
    private javax.swing.JPanel pnlLuongNguoiHoc;
    private javax.swing.JTable tblBangDiem;
    private javax.swing.JTable tblDiemChuyenDe;
    private javax.swing.JTable tblDoanhThu;
    private javax.swing.JTable tblLoiNhuan;
    private javax.swing.JTable tblNguoiHoc;
    private javax.swing.JTable tblTopChuyenDeKhoaHoc;
    private javax.swing.JTabbedPane tbpThongKe;
    // End of variables declaration//GEN-END:variables
}
