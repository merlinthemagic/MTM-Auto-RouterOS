:local cPath "MTM/Auto/Enable.rsc";
:local mVal "";

:global MtmAutoLoaded;
:if ($MtmAutoLoaded != true) do={
	:global MtmAutoLoaded false;

	##Load APP
	:local hintFile "mtmAutoRoot.hint";
	:set mVal [/file/find name~$hintFile];
	:if ([:len $mVal] != 1) do={
		:set mVal [/system/script/environment/remove [find where name="MtmAutoLoaded"]];
		:error ($cPath.": Hint file: '".$hintFile."' is invalid");
	}
	:set mVal [/file/get $mVal name];
	:local rootPath [:pick $mVal 0 ([:len $mVal] - (([:len $hintFile]) + 1))];

	##Load the factory class
	:set mVal [/import file-name=($rootPath."/Facts.rsc") verbose=no];

	:global MtmAuto;
	:if ([:typeof $MtmAuto] = "nothing") do={
		:set mVal [/system/script/environment/remove [find where name="MtmAutoLoaded"]];
		:error ($cPath.": Loading MtmAuto failed");
	}

	##load the environment
	:set mVal [($MtmAuto->"setEnv") "mtm.auto.root.path" $rootPath];
	:foreach id in=[/file/find where name~("^".$rootPath."/Envs/")] do={
		:set mVal [($MtmAuto->"loadEnvFile") ([/file/get $id name]) (true)];
	}

	:global MtmAutoLoaded true;
	
} else={
	#MTM Auto is already loaded
}