package com.lingxing.dao;

import com.lingxing.bean.Student;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * Student Mapper接口（使用MyBatis注解）
 */
@Mapper
public interface StudentMapper {

    /**
     * 根据学号和密码查找学生
     */
    @Select("SELECT * FROM tb_student WHERE stu_number = #{number} AND password = #{password}")
    Student findByNumberAndPassword(@Param("number") String number, @Param("password") String password);

    /**
     * 根据ID查找学生
     */
    @Select("SELECT * FROM tb_student WHERE stu_id = #{id}")
    Student findById(@Param("id") int id);

    /**
     * 查询所有学生
     */
    @Select("SELECT * FROM tb_student ORDER BY stu_number")
    List<Student> findAll();

    /**
     * 根据学号查找学生
     */
    @Select("SELECT * FROM tb_student WHERE stu_number = #{stuNumber}")
    Student findByNumber(@Param("stuNumber") String stuNumber);

    /**
     * 根据姓名查找学生
     */
    @Select("SELECT * FROM tb_student WHERE stu_name = #{name}")
    Student findByName(@Param("name") String name);

    /**
     * 添加学生
     */
    @Insert("INSERT INTO tb_student (stu_number, stu_name, password, stu_class) VALUES (#{stuNumber}, #{stuName}, #{password}, #{stuClass})")
    @Options(useGeneratedKeys = true, keyProperty = "stuId", keyColumn = "stu_id")
    int insert(Student student);

    /**
     * 更新学生信息
     */
    @Update("UPDATE tb_student SET stu_number = #{stuNumber}, stu_name = #{stuName}, stu_class = #{stuClass}, password = #{password} WHERE stu_id = #{stuId}")
    int update(Student student);

    /**
     * 删除学生（会级联删除成绩）
     */
    @Delete("DELETE FROM tb_student WHERE stu_id = #{stuId}")
    int deleteById(@Param("stuId") int stuId);

    /**
     * 根据学号获取ID
     */
    @Select("SELECT stu_id FROM tb_student WHERE stu_number = #{stuNumber}")
    int getIdByNumber(@Param("stuNumber") String stuNumber);

    /**
     * 根据姓名获取ID
     */
    @Select("SELECT stu_id FROM tb_student WHERE stu_name = #{stuName}")
    int getIdByName(@Param("stuName") String stuName);

    /**
     * 删除成绩（用于级联删除）
     */
    @Delete("DELETE FROM tb_score WHERE stu_id = #{stuId}")
    int deleteScoresByStudentId(@Param("stuId") int stuId);

    /**
     * 获取最大序号（用于生成学号）
     */
    @Select("SELECT MAX(CAST(SUBSTRING(stu_number, 7, 2) AS UNSIGNED)) AS max_sequence FROM tb_student WHERE stu_number LIKE #{prefix}")
    Integer getMaxSequenceByPrefix(@Param("prefix") String prefix);
}

