:local cPath "MTM/Auto/Tools/Files.rsc";
:local s [:toarray ""];

:set ($s->"getExists") do={

	:local cPath "MTM/Auto/Tools/Files.rsc/getExists";
	:if ([:typeof $0] != "str") do={
		:error ($cPath.": Input has invalid type '".[:typeof $0]."'");
	}
	:if ([:len [/file/find where name=$0]] > 0) do={
		:return true;
	} else={
		:return false;
	}
}
:set ($s->"getContent") do={

	:local cPath "MTM/Auto/Tools/Files.rsc/getContent";
	:if ([:typeof $0] != "str") do={
		:error ($cPath.": Input file name has invalid type '".[:typeof $0]."'");
	}
	
	:global MtmAutoTools;
	:local self ($MtmAutoTools->"files");
	:if ([($self->"getExists") $0] = false) do={
		:error ($cPath.": Cannot get content, file does not exists '".$0."'");
	}
	:if ([($self->"getSize") $0] < 4096) do={
		:return [/file/get [find where name=$0] content];
	} else={
		:error ($cPath.": Cannot get content, file is too large '".$0."'");
	}
}
:set ($s->"getSize") do={

	:local cPath "MTM/Auto/Tools/Files.rsc/getSize";
	:if ([:typeof $0] != "str") do={
		:error ($cPath.": Input file name has invalid type '".[:typeof $0]."'");
	}
	
	:global MtmAutoTools;
	:local self ($MtmAutoTools->"files");
	:if ([($self->"getExists") $0] = false) do={
		:error ($cPath.": File does not exist: '".$0."'");
	}
	:return [:tonum [/file/get [find where name=$0] size]];
}

:global MtmAutoTools;
:set ($MtmAutoTools->"files") $s;
