;获取path的上级目录地址,相对地址时不齐缺失的路径
GetUpperFolderPath(path)
{
    SplitPath, % path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    if (OutDir == "")
        return A_WorkingDir
    else if (OutDrive == "")
        return A_WorkingDir "\" OutDir
    else
        return OutDir
}