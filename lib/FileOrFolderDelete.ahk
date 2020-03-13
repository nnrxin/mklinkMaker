;删除文件或者文件夹
FileOrFolderDelete(path)
{
	if InStr(FileExist(path), "D")
		FileRemoveDir, % path, 1 
	else
		FileDelete, % path
}