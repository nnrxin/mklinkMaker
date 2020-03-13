class IniSaved
{
	__New(Filename)
	{
		SplitPath, Filename, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		if OutDir and !FileExist(OutDir)
			FileCreateDir, % OutDir
		if !FileExist(Filename)
		{
			file:=FileOpen(Filename, "rw")
			file.Close()
		}
		this.Filename := Filename
		this.VarList := []
	}

	Init(Section := "", Key := "", Default := "")
	{
		global
		IniRead, OutputVar, % this.Filename, % Section, % Key, % (Default = "") ? A_Space : Default
		iniVarName := "ini_" Section "_" Key
		%iniVarName% := OutputVar
		this.VarList.push({iniVarName:iniVarName, Section:Section, Key:Key})
		return OutputVar
	}

	Read(Section := "", Key := "", Default := "")
	{
		IniRead, OutputVar, % this.Filename, % Section, % Key, % (Default = "") ? A_Space : Default
		return OutputVar
	}
	
	SaveAll()
	{	
		for i, v in this.VarList
		{
			iniVarName := v.iniVarName
			IniWrite, % %iniVarName%, % this.Filename, % v.Section, % v.Key
		}
	}
}