package com.lingxing.dao;

import com.lingxing.bean.Teacher;
import com.lingxing.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TeacherDao {

    public Teacher findByNumberAndPassword(String number, String password) throws SQLException {
        String sql = "SELECT * FROM tb_teacher WHERE teacher_number = ? AND teacher_password = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, number);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<Teacher> findAll() throws SQLException {
        String sql = "SELECT * FROM tb_teacher ORDER BY teacher_number";
        List<Teacher> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public Teacher findByNumber(String number) throws SQLException {
        String sql = "SELECT * FROM tb_teacher WHERE teacher_number = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public int addTeacher(String number, String name, String password) throws SQLException {
        String sql = "INSERT INTO tb_teacher (teacher_number, teacher_name, teacher_password) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, number);
            ps.setString(2, name);
            ps.setString(3, password);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    public boolean updateTeacher(int teacherId, String name, String password) throws SQLException {
        String sql = "UPDATE tb_teacher SET teacher_name = ?, teacher_password = ? WHERE teacher_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, password);
            ps.setInt(3, teacherId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteTeacher(int teacherId) throws SQLException {
        String sql = "DELETE FROM tb_teacher WHERE teacher_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            return ps.executeUpdate() > 0;
        }
    }

    public int getIdByNumber(String number) throws SQLException {
        String sql = "SELECT teacher_id FROM tb_teacher WHERE teacher_number = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("teacher_id");
                }
            }
        }
        return -1;
    }

    private Teacher mapRow(ResultSet rs) throws SQLException {
        Teacher t = new Teacher();
        t.setTeacherId(rs.getInt("teacher_id"));
        t.setTeacherNumber(rs.getString("teacher_number"));
        t.setTeacherName(rs.getString("teacher_name"));
        t.setPassword(rs.getString("teacher_password"));
        return t;
    }
}


