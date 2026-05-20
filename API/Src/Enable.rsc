
:local cPath "MTM/Auto/Enable.rsc";

:global MtmAutoLoaded;
:if ([:typeof $MtmAutoLoaded] = "nothing") do={
	:global MtmAutoLoaded false;
	
	##Load Dependencies
	:local mVal "";
	:local mNull "";
	:local appRoot "";
	:local hintFiles [:toarray "mtmAutoRoot.hint"];
	:foreach hintFile in=$hintFiles do={
		:set mVal [/file/find name~$hintFile];
		:if ([:len $mVal] != 1) do={
			:set mVal [/system/script/environment/remove [find where name="MtmAutoLoaded"]];
			:error ($cPath.": Hint file: '".$hintFile."' is invalid");
		}
		:set mVal [/file/get $mVal name];
		:set mVal [:pick $mVal 0 ([:len $mVal] - (([:len $hintFile]) + 1))]; ##Root path

		:if ($hintFile = "mtmAutoRoot.hint") do={
			:set appRoot $mVal;
			:set mNull [/import file-name=($appRoot."/Facts.rsc") verbose=no];
		} else={
			:set mNull [/import file-name=($mVal."/Enable.rsc") verbose=no];
		}
	}

	:global MtmAuto;
	:if ([:typeof $MtmAuto] = "nothing") do={
		:set mVal [/system/script/environment/remove [find where name="MtmAutoLoaded"]];
		:error ($cPath.": Loading MtmAuto failed");
	}


	##load the environment
	:set mVal [($MtmAuto->"setEnv") "mtm.auto.root.path" $appRoot];
	:foreach id in=[/file/find where name~("^".$appRoot."/Envs/")] do={
		:set mVal [($MtmAuto->"loadEnvFile") ([/file/get $id name]) (true)];
	}

	:global MtmAutoLoaded true;
	
} else={
	#App is already loaded or being loaded
	:if ($MtmAutoLoaded = false) do={
		##another process is loading this Enable.rsc
		:for i from=0 to=20 do={
			:global MtmAutoLoaded;
			:if ($MtmAutoLoaded = true) do={
				:break;
			} else={
				:delay 0.5s;
			}
		}
		:if ($MtmAutoLoaded != true) do={
			:error ($cPath.": Failed to load while waiting");
		}
	}
}
