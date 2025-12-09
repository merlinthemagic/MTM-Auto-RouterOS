##Nimimal toolset required to keep MTM/Auto functioning without external dependance

:local cPath "MTM/Auto/Facts/Tools.rsc";
:local s [:toarray ""];

:set ($s->"getStrings") do={
	:global MtmAutoTools;
	:if ([:typeof ($MtmAutoTools->"strings")] = "nothing") do={
		:global MtmAuto;
		:local mVal ([($MtmAuto->"getEnv") "mtm.auto.root.path"]."/Tools/Strings.rsc");
		:set mVal [($MtmAuto->"importFile") $mVal];
	}
	:return ($MtmAutoTools->"strings");
}
:set ($s->"getFiles") do={
	:global MtmAutoTools;
	:if ([:typeof ($MtmAutoTools->"files")] = "nothing") do={
		:global MtmAuto;
		:local mVal ([($MtmAuto->"getEnv") "mtm.auto.root.path"]."/Tools/Files.rsc");
		:set mVal [($MtmAuto->"importFile") $mVal];
	}
	:return ($MtmAutoTools->"files");
}

:global MtmAutoTools;
:set MtmAutoTools [:toarray ""];

:global MtmAutoFacts;
:set ($MtmAutoFacts->"tools") $s;