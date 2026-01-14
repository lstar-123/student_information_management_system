package com.lingxing.dao;

import com.lingxing.bean.Teacher;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * Teacher Mapper接口（使用MyBatis注解）
 */
@Mapper
public interface TeacherMapper {

    /**
     * 根据工号和密码查找教师
     */
    @Select("SELECT * FROM tb_teacher WHERE teacher_number = #{number} AND teacher_password = #{password}")
    Teacher findByNumberAndPassword(@Param("number") String number, @Param("password") String password);

    /**
     * 查询所有教师
     */
    @Select("SELECT * FROM tb_teacher ORDER BY teacher_number")
    List<Teacher> findAll();

    /**
     * 根据工号查找教师
     */
    @Select("SELECT * FROM tb_teacher WHERE teacher_number = #{number}")
    Teacher findByNumber(@Param("number") String number);

    /**
     * 添加教师
     */
    @Insert("INSERT INTO tb_teacher (teacher_number, teacher_name, teacher_password) VALUES (#{teacherNumber}, #{teacherName}, #{password})")
    @Options(useGeneratedKeys = true, keyProperty = "teacherId", keyColumn = "teacher_id")
    int insert(Teacher teacher);

    /**
     * 更新教师信息
     */
    @Update("UPDATE tb_teacher SET teacher_name = #{teacherName}, teacher_password = #{password} WHERE teacher_id = #{teacherId}")
    int update(Teacher teacher);

    /**
     * 删除教师
     */
    @Delete("DELETE FROM tb_teacher WHERE teacher_id = #{teacherId}")
    int deleteById(@Param("teacherId") int teacherId);

    /**
     * 根据工号获取ID
     */
    @Select("SELECT teacher_id FROM tb_teacher WHERE teacher_number = #{number}")
    int getIdByNumber(@Param("number") String number);
}


