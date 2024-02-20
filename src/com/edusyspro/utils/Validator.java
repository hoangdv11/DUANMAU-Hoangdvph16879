/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.edusyspro.utils;

import com.toedter.calendar.JDateChooser;
import java.awt.Color;
import java.util.Arrays;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.swing.JPasswordField;
import javax.swing.JTextArea;
import javax.swing.JTextField;

/**
 *
 * @author DaiAustinYersin
 */
public class Validator {

    public static boolean isNull(JTextField txt, String mes, StringBuilder sb) {
        if (txt.getText().isEmpty()) {
            sb.append(mes).append("\n");
            txt.setBackground(Color.YELLOW);
            return true;
        } else {
            txt.setBackground(Color.WHITE);
            return false;
        }
    }

    public static boolean isNull(JTextArea txt, String mes, StringBuilder sb) {
        if (txt.getText().isEmpty()) {
            sb.append(mes).append("\n");
            txt.setBackground(Color.YELLOW);
            return true;
        } else {
            txt.setBackground(Color.WHITE);
            return false;
        }
    }

    public static boolean isNull(JPasswordField pass, String mes, StringBuilder sb) {
        if (new String(pass.getPassword()).isEmpty()) {
            sb.append(mes).append("\n");
            pass.setBackground(Color.YELLOW);
            return true;
        } else {
            pass.setBackground(Color.WHITE);
            return false;
        }
    }

    public static boolean checkNgayKG(JDateChooser date, StringBuilder sb) {
        try {
            if (date.getDate() == null) {
                sb.append("Khai giảng chưa nhập").append("\n");
                return false;
            } else if (date.getDate().before(new Date())) {
                sb.append("Ngày khai giảng phải sau ngày hôm nay").append("\n");
                return false;
            } else {
                return true;
            }
        } catch (Exception e) {
            sb.append("Ngày khai giảng không hợp lệ").append("\n");
            return false;
        }
    }

    public static boolean checkNgaySinh(JDateChooser date, StringBuilder sb) {
        try {
            if (date.getDate() == null) {
                sb.append("Ngày sinh chưa nhập").append("\n");
                return false;
            } else if (date.getDate().after(new Date())) {
                sb.append("Ngày sinh không hợp lệ").append("\n");
                return false;
            } else {
                return true;
            }
        } catch (Exception e) {
            sb.append("Ngày sinh không hợp lệ").append("\n");
            return false;
        }
    }

    public static boolean checkId(JTextField txt, String str, StringBuilder sb, String mes) {
        if (txt.getText().equalsIgnoreCase(str)) {
            sb.append(mes).append("\n");
            txt.setBackground(Color.red);
            return false;
        } else {
            txt.setBackground(Color.white);
            return true;
        }
    }

    public static boolean confirmPass(JPasswordField pass1, JPasswordField pass2, StringBuilder sb) {
        if (Arrays.equals(pass1.getPassword(), pass2.getPassword())) {
            pass2.setBackground(Color.white);
            return true;
        } else {
            pass2.setBackground(Color.red);
            sb.append(pass2.getName()).append(" không giống với ").append(pass1.getName());
            return false;
        }
    }

    public static boolean checkEmail(JTextField txt, StringBuilder sb) {
        if (isNull(txt, "Email chưa nhập", sb)) {
            return false;
        }

        Pattern p = Pattern.compile("\\w+@\\w+\\.\\w+");
        Matcher m = p.matcher(txt.getText());

        if (!m.find()) {
            sb.append("Email không hợp lệ\n");
            txt.setBackground(Color.red);
            return false;
        }

        txt.setBackground(Color.white);
        return true;
    }

    public static boolean checkMoney(JTextField txt, StringBuilder sb) {
        boolean ok = true;
        if (isNull(txt, txt.getName() + " chưa nhập", sb)) {
            return false;
        }

        try {
            double tien = XFormater.toDouble(txt);
            if (tien <= 0) {
                sb.append(txt.getName()).append(" phải lớn hơn 0").append("\n");
                txt.setBackground(Color.red);
                ok = false;
            }
        } catch (NumberFormatException e) {
            sb.append(txt.getName()).append(" phải là số dương").append("\n");
            txt.setBackground(Color.red);
            ok = false;
        }

        if (ok) {
            txt.setBackground(Color.white);
        }
        return ok;
    }

    public static boolean checkDiem(String txt, StringBuilder sb) {
        boolean ok = true;
        if (txt.isEmpty()) {
            sb.append("Điểm chưa nhập").append("\n");
            return false;
        }

        try {
            double diem = Double.parseDouble(txt);
            if (diem < -1 || diem > 10) {
                sb.append("Điểm phải từ 1 đến 10").append("\n");
                ok = false;
            }
        } catch (NumberFormatException e) {
            sb.append("Điểm phải là số").append("\n");
            ok = false;
        }

        if (ok) {
        }

        return ok;
    }

    public static boolean checkThoiLuong(JTextField txt, StringBuilder sb) {
        boolean ok = true;
        if (isNull(txt, "Thời lượng chưa nhập", sb)) {
            return false;
        }

        try {
            int thoiLuong = Integer.parseInt(txt.getText());
            if (thoiLuong <= 0) {
                sb.append("Thời lượng phải lơn hơn 0").append("\n");
                txt.setBackground(Color.red);
                ok = false;
            }
        } catch (NumberFormatException e) {
            sb.append("Thời lượng phải là số dương").append("\n");
            txt.setBackground(Color.red);
            ok = false;
        }

        if (ok) {
            txt.setBackground(Color.white);
        }

        return ok;
    }
}
