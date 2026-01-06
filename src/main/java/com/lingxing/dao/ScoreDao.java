package com.lingxing.dao;

import com.lingxing.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ScoreDao {

    public boolean exists(int stuId, int courseId, String examType) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tb_score WHERE stu_id = ? AND course_id = ? AND exam_type = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stuId);
            ps.setInt(2, courseId);
            ps.setString(3, examType);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public boolean addScore(int stuId, int courseId, double score, String examType) throws SQLException {
        String sql = "INSERT INTO tb_score (stu_id, course_id, score, exam_type) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stuId);
            ps.setInt(2, courseId);
            ps.setDouble(3, score);
            ps.setString(4, examType);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateScore(int stuId, int courseId, double score, String examType) throws SQLException {
        String sql = "UPDATE tb_score SET score = ? WHERE stu_id = ? AND course_id = ? AND exam_type = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, score);
            ps.setInt(2, stuId);
            ps.setInt(3, courseId);
            ps.setString(4, examType);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteScore(int stuId, int courseId, String examType) throws SQLException {
        String sql = "DELETE FROM tb_score WHERE stu_id = ? AND course_id = ? AND exam_type = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stuId);
            ps.setInt(2, courseId);
            ps.setString(3, examType);
            return ps.executeUpdate() > 0;
        }
    }
}


