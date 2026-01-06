package com.lingxing.bean;

public class Teacher {
    private int teacherId;
    private String teacherNumber;
    private String teacherName;
    private String password;

    public Teacher() {
    }

    public Teacher(int teacherId, String teacherNumber, String teacherName, String password) {
        this.teacherId = teacherId;
        this.teacherNumber = teacherNumber;
        this.teacherName = teacherName;
        this.password = password;
    }

    public int getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(int teacherId) {
        this.teacherId = teacherId;
    }

    public String getTeacherNumber() {
        return teacherNumber;
    }

    public void setTeacherNumber(String teacherNumber) {
        this.teacherNumber = teacherNumber;
    }

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}


