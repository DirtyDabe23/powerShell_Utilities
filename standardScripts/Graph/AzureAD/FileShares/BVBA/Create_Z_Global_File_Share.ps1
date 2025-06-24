New-PSDrive -Name "T" -PSProvider FileSystem -Root "\\evc-vfs1\Global File Share" -Persist

New-PSDrive -Name "X" -PSProvider FileSystem -Root "\\parentCompanyusers\departments\tech-items" -Persist -Scope Global
SignatureBlock

