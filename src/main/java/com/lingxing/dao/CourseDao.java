package com.lingxing.dao;

import com.lingxing.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseDao {

    public List<CourseItem> findAll() throws SQLException {
        String sql = "SELECT course_id, course_name FROM tb_course ORDER BY course_id";
        List<CourseItem> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new CourseItem(rs.getInt("course_id"), rs.getString("course_name")));
            }
        }
        return list;
    }

    public boolean existsName(String courseName, Integer excludeId) throws SQLException {
        String sql = excludeId == null
                ? "SELECT COUNT(*) FROM tb_course WHERE course_name = ?"
                : "SELECT COUNT(*) FROM tb_course WHERE course_name = ? AND course_id <> ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseName);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public int addCourse(String courseName) throws SQLException {
        String sql = "INSERT INTO tb_course (course_name) VALUES (?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, courseName);
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

    public boolean updateCourse(int courseId, String courseName) throws SQLException {
        String sql = "UPDATE tb_course SET course_name = ? WHERE course_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseName);
            ps.setInt(2, courseId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteCourse(int courseId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psScore = conn.prepareStatement("DELETE FROM tb_score WHERE course_id = ?");
                 PreparedStatement psCourse = conn.prepareStatement("DELETE FROM tb_course WHERE course_id = ?")) {
                psScore.setInt(1, courseId);
                psScore.executeUpdate();
                psCourse.setInt(1, courseId);
                boolean ok = psCourse.executeUpdate() > 0;
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

    public int getIdByName(String courseName) throws SQLException {
        String sql = "SELECT course_id FROM tb_course WHERE course_name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("course_id");
                }
            }
        }
        return -1;
    }

    public static class CourseItem {
        private final int id;
        private final String name;

        public CourseItem(int id, String name) {
            this.id = id;
            this.name = name;
        }

        public int getId() {
            return id;
        }

        public String getName() {
            return name;
        }
    }
}


