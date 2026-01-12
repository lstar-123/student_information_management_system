package com.lingxing.bean;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Teacher {
    private int teacherId;
    private String teacherNumber;
    private String teacherName;
    private String password;
}


