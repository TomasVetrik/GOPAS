:: Vypnutie kontroly podpisanych ovladacov
bcdedit -set {default} loadoptions ENABLE_INTEGRITY_CHECKS 
bcdedit -set {default} TESTSIGNING OFF