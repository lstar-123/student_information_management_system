package com.lingxing.bean;

public class Student {
    private int stuId;
    private String stuNumber;
    private String stuName;
    private String password;
    private String stuClass;

    public Student() {
    }

    public Student(int stuId, String stuNumber, String stuName, String password, String stuClass) {
        this.stuId = stuId;
        this.stuNumber = stuNumber;
        this.stuName = stuName;
        this.password = password;
        this.stuClass = stuClass;
    }

    public int getStuId() {
        return stuId;
    }

    public void setStuId(int stuId) {
        this.stuId = stuId;
    }

    public String getStuNumber() {
        return stuNumber;
    }

    public void setStuNumber(String stuNumber) {
        this.stuNumber = stuNumber;
    }

    public String getStuName() {
        return stuName;
    }

    public void setStuName(String stuName) {
        this.stuName = stuName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getStuClass() {
        return stuClass;
    }

    public void setStuClass(String stuClass) {
        this.stuClass = stuClass;
    }
}


