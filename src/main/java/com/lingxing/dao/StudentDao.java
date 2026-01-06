package com.lingxing.dao;

import com.lingxing.bean.Student;
import com.lingxing.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDao {

    public Student findByNumberAndPassword(String number, String password) throws SQLException {
        String sql = "SELECT * FROM tb_student WHERE stu_number = ? AND password = ?";
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

    public Student findById(int id) throws SQLException {
        String sql = "SELECT * FROM tb_student WHERE stu_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<Student> findAll() throws SQLException {
        String sql = "SELECT * FROM tb_student ORDER BY stu_number";
        List<Student> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public Student findByNumber(String stuNumber) throws SQLException {
        String sql = "SELECT * FROM tb_student WHERE stu_number = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stuNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public Student findByName(String name) throws SQLException {
        String sql = "SELECT * FROM tb_student WHERE stu_name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public int addStudent(String stuNumber, String stuName, String stuClass, String password) throws SQLException {
        String sql = "INSERT INTO tb_student (stu_number, stu_name, password, stu_class) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, stuNumber);
            ps.setString(2, stuName);
            ps.setString(3, password);
            ps.setString(4, stuClass);
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

    public boolean updateStudent(int stuId, String stuNumber, String stuName, String stuClass, String password) throws SQLException {
        String sql = "UPDATE tb_student SET stu_number = ?, stu_name = ?, stu_class = ?, password = ? WHERE stu_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stuNumber);
            ps.setString(2, stuName);
            ps.setString(3, stuClass);
            ps.setString(4, password);
            ps.setInt(5, stuId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteStudent(int stuId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psScore = conn.prepareStatement("DELETE FROM tb_score WHERE stu_id = ?");
                 PreparedStatement psStu = conn.prepareStatement("DELETE FROM tb_student WHERE stu_id = ?")) {
                psScore.setInt(1, stuId);
                psScore.executeUpdate();
                psStu.setInt(1, stuId);
                boolean ok = psStu.executeUpdate() > 0;
                conn.commit();
                return ok;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public int getIdByNumber(String stuNumber) throws SQLException {
        String sql = "SELECT stu_id FROM tb_student WHERE stu_number = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stuNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("stu_id");
                }
            }
        }
        return -1;
    }

    public int getIdByName(String stuName) throws SQLException {
        String sql = "SELECT stu_id FROM tb_student WHERE stu_name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stuName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("stu_id");
                }
            }
        }
        return -1;
    }

    private Student mapRow(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setStuId(rs.getInt("stu_id"));
        s.setStuNumber(rs.getString("stu_number"));
        s.setStuName(rs.getString("stu_name"));
        s.setPassword(rs.getString("password"));
        s.setStuClass(rs.getString("stu_class"));
        return s;
    }
}


