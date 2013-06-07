---
layout:post
title: $i
tags: ["howto"]
---

office2000:
#import "mso9.dll" no_namespace rename("DocumentProperties", "DocumentPropertiesXL") 
//#import "mso97.dll" no_namespace rename("DocumentProperties", "DocumentPropertiesXL") 
#import "VBE6EXT.OLB" no_namespace 
//#import "vbeext1.olb" no_namespace 
#import "excel9.olb" rename("DialogBox", "DialogBoxXL") rename("RGB", "RBGXL") rename("DocumentProperties", "DocumentPropertiesXL") no_dual_interfaces
//#import "excel8.olb" rename("DialogBox", "DialogBoxXL") rename("RGB", "RBGXL") rename("DocumentProperties", "DocumentPropertiesXL") no_dual_interfaces

 

import <mso97.dll> no_namespace rename("/DocumentProperties",
"DocumentPropertiesXL")
#import <vbeext1.olb> no_namespace
#import excel8.olb> rename(DialogBox", "DialogBoxXL")
rename("RGB", "RBGXL") rename("DocumentProperties",
"DocumentPropertiesXL") no_dual_interfaces 



#import "C:\Program Files\Microsoft Office\Office\MSO9.DLL"
#import "C:\Program Files\Common Files\Microsoft Shared\VBA\VBA6\VBE6EXT.OLB"
#import "C:\Program Files\Microsoft Office\Office\EXCEL9.OLB" \
  rename("DialogBox", "ExcelDialogBox") \
  rename("RGB", "ExcelRGB") \
  no_dual_interfaces


