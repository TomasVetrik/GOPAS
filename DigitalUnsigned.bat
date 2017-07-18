:: Vypnutie kontroly podpisanych ovladacov
bcdedit -set {default} loadoptions DDISABLE_INTEGRITY_CHECKS 
bcdedit -set {default} TESTSIGNING ON