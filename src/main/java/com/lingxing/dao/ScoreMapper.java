package com.lingxing.dao;

import org.apache.ibatis.annotations.*;

/**
 * Score Mapper接口（使用MyBatis注解）
 */
@Mapper
public interface ScoreMapper {

    /**
     * 检查成绩是否存在
     */
    @Select("SELECT COUNT(*) FROM tb_score WHERE stu_id = #{stuId} AND course_id = #{courseId} AND exam_type = #{examType}")
    int countByStudentAndCourseAndExamType(@Param("stuId") int stuId, @Param("courseId") int courseId, @Param("examType") String examType);

    /**
     * 检查成绩是否存在（返回boolean）
     */
    default boolean exists(int stuId, int courseId, String examType) {
        return countByStudentAndCourseAndExamType(stuId, courseId, examType) > 0;
    }

    /**
     * 添加成绩
     */
    @Insert("INSERT INTO tb_score (stu_id, course_id, score, exam_type) VALUES (#{stuId}, #{courseId}, #{score}, #{examType})")
    int insert(@Param("stuId") int stuId, @Param("courseId") int courseId, @Param("score") double score, @Param("examType") String examType);

    /**
     * 更新成绩
     */
    @Update("UPDATE tb_score SET score = #{score} WHERE stu_id = #{stuId} AND course_id = #{courseId} AND exam_type = #{examType}")
    int update(@Param("stuId") int stuId, @Param("courseId") int courseId, @Param("score") double score, @Param("examType") String examType);

    /**
     * 删除成绩
     */
    @Delete("DELETE FROM tb_score WHERE stu_id = #{stuId} AND course_id = #{courseId} AND exam_type = #{examType}")
    int delete(@Param("stuId") int stuId, @Param("courseId") int courseId, @Param("examType") String examType);

    /**
     * 根据学生ID删除成绩（用于级联删除）
     */
    @Delete("DELETE FROM tb_score WHERE stu_id = #{stuId}")
    int deleteByStudentId(@Param("stuId") int stuId);

    /**
     * 根据课程ID删除成绩（用于级联删除）
     */
    @Delete("DELETE FROM tb_score WHERE course_id = #{courseId}")
    int deleteByCourseId(@Param("courseId") int courseId);
}

