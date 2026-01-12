package com.lingxing.bean;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Student {
    private int stuId;
    private String stuNumber;
    private String stuName;
    private String password;
    private String stuClass;
}


