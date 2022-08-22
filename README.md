# CPU Model FPGA (VHDL)

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/bb9957dba6134edf80206e87f05453aa)](https://www.codacy.com/gh/valerii-martell/CPU-Model-FPGA/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=valerii-martell/CPU-Model-FPGA&amp;utm_campaign=Badge_Grade)

A 16-bit RISC processor core model in VHDL. All including components and testbenches tested on both Xilinx and Altera boards.

The project includes the following subprojects (in various implementation variations), each of which is part of the final processor core:
1. Arithmetic Logic Unit (LSM)
2. Interrupt Controller Type Register (ICTR)
3. Random Access Memory (RAM)
4. Registers-based RAM e.g. Fast Memory (FM)
5. Multiplication Unit (MPU) with Local State Machine (LSM)
6. Arithmetic Unit with Microprogram Control
7. Central Processing Unit (CPU)

Auto-generation electrical circuits are present inside projects.

RAM:

![image](https://user-images.githubusercontent.com/19497575/161587563-00695dc5-21b2-4cae-8d56-b33df81f6283.png)

FM:

![image](https://user-images.githubusercontent.com/19497575/161587610-3be2d9ad-aae5-4015-86fa-cda9b9dec5ef.png)

MPU with FSM:

![image](https://user-images.githubusercontent.com/19497575/161587713-50c90c8a-4736-442e-81d3-1e2b88945c94.png)
![image](https://user-images.githubusercontent.com/19497575/161587758-92e2943a-ba86-4a09-ae70-1aab5d0872cb.png)
![image](https://user-images.githubusercontent.com/19497575/161587795-c47aaab1-8a34-4c16-a756-3d1713cdf16a.png)

AU with Microprogram Control:

![image](https://user-images.githubusercontent.com/19497575/161588617-92a29285-b41b-4a55-bc7e-36f2b65ed501.png)
![image](https://user-images.githubusercontent.com/19497575/161588836-f5bdcfb5-2a2c-4f51-a56c-655b8f85876b.png)
![image](https://user-images.githubusercontent.com/19497575/161587937-8c561498-065e-4d80-8726-cc27df4cbe04.png)
![image](https://user-images.githubusercontent.com/19497575/161587960-82949f77-d7e1-47af-b844-1f7b545dcb66.png)

CPU:

![image](https://user-images.githubusercontent.com/19497575/161588937-6284e64e-e076-46d0-b975-d8018e7386ba.png)
![image](https://user-images.githubusercontent.com/19497575/161588970-b5c19378-12a2-4d1f-9038-e4e47d7fa60a.png)



