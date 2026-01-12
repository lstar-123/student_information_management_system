package com.lingxing.dao;

import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * Course Mapper接口（使用MyBatis注解）
 */
@Mapper
public interface CourseMapper {

    /**
     * CourseItem内部类，用于表示课程项
     */
    class CourseItem {
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

    /**
     * 查询所有课程
     */
    @Select("SELECT course_id AS id, course_name AS name FROM tb_course ORDER BY course_id")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "name", column = "name")
    })
    List<CourseItem> findAll();

    /**
     * 检查课程名称是否存在
     */
    @Select("SELECT COUNT(*) FROM tb_course WHERE course_name = #{courseName}")
    int countByName(@Param("courseName") String courseName);

    /**
     * 检查课程名称是否存在（排除指定ID）
     */
    @Select("SELECT COUNT(*) FROM tb_course WHERE course_name = #{courseName} AND course_id <> #{excludeId}")
    int countByNameExcludingId(@Param("courseName") String courseName, @Param("excludeId") int excludeId);

    /**
     * 检查课程名称是否存在
     */
    default boolean existsName(String courseName, Integer excludeId) {
        if (excludeId == null) {
            return countByName(courseName) > 0;
        } else {
            return countByNameExcludingId(courseName, excludeId) > 0;
        }
    }

    /**
     * 添加课程
     */
    @Insert("INSERT INTO tb_course (course_name) VALUES (#{courseName})")
    int insert(@Param("courseName") String courseName);

    /**
     * 更新课程
     */
    @Update("UPDATE tb_course SET course_name = #{courseName} WHERE course_id = #{courseId}")
    int update(@Param("courseId") int courseId, @Param("courseName") String courseName);

    /**
     * 删除课程
     */
    @Delete("DELETE FROM tb_course WHERE course_id = #{courseId}")
    int deleteById(@Param("courseId") int courseId);

    /**
     * 根据课程名称获取ID
     */
    @Select("SELECT course_id FROM tb_course WHERE course_name = #{courseName}")
    int getIdByName(@Param("courseName") String courseName);
}

