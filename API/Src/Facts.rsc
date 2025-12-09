:local cPath "MTM/Auto/Facts.rsc";
:local mVal "";

:global MtmAutoLoaded;
:if ([:typeof $MtmAutoLoaded] = "nothing") do={
	##Load the Enable.rsc file before using Facts
	:error ($cPath.": Please load Enable.rsc before using the factory");
}

:global MtmAuto;
:if ([:typeof $MtmAuto] = "nothing") do={

	#static "objects"
	:global MtmAutoEnvs;
	:set MtmAutoEnvs [:toarray ""];
	:set ($MtmAutoEnvs->"mtm.debug.enabled") true; ##pre loading env file default value, if MTM fails to load at all set to true
	
	:global MtmAutoAvps;
	:set MtmAutoAvps [:toarray ""];
	
	:global MtmAutoFacts;
	:set MtmAutoFacts [:toarray ""];
	
	:local s [:toarray ""];
	
	:set ($s->"echo") do={
		:put ($0."\n");
		:return true;
	}
	
	
	:set ($s->"setDebug") do={
		:local cPath "MTM/Auto/Facts.rsc/setDebug";
		:if ([:typeof $0] != "bool") do={
			:error ($cPath.": Parameter must be true or false");
		}
		:global MtmAuto;
		:local mVal [($MtmAuto->"setEnv") "mtm.debug.enabled" ($0)];
		:if ($0 = true) do={
			:set mVal [($MtmAuto->"echo") ("Debug set ON")];
		} else={
			:set mVal [($MtmAuto->"echo") ("Debug set OFF")];
		}
		:return true;
	}
	:set ($s->"getDebug") do={
		:local cPath "MTM/Auto/Facts.rsc/getDebug";
		:global MtmAuto;
		:return [($MtmAuto->"getEnv") "mtm.debug.enabled"];
	}
	
	
	:set ($s->"setEnv") do={
		:local cPath "MTM/Auto/Facts.rsc/setEnv";
		:if ([:len $0] = 0 || [:typeof $0] != "str") do={
			:error ($cPath.": Key is mandatory, must be string value, not: '".[:typeof $0]."'");
		}
		:if ([:typeof $1] != "str" && [:typeof $1] != "num" && [:typeof $1] != "bool") do={
			:error ($cPath.": Value for key: '".$0."' must be a string, number or boolean value, not: '".[:typeof $1]."'");
		}
		:global MtmAutoEnvs;
		:set ($MtmAutoEnvs->$0) $1;
		:return true;
	}
	:set ($s->"getEnv") do={
		:local cPath "MTM/Auto/Facts.rsc/getEnv";
		:if ([:len $0] = 0 || [:typeof $0] != "str") do={
			:error ($cPath.": Key is mandatory, must be string value");
		}
		:global MtmAutoEnvs;
		:local mVal ($MtmAutoEnvs->$0);
		:if ([:typeof $mVal] = "nothing" && $1 != false) do={
			:error ($cPath.": Key '".$0."' does not exist");
		}
		:return $mVal;
	}
	
	:set ($s->"setAvp") do={
		
		##Attribute values can be anything
		:local cPath "MTM/Auto/Facts.rsc/setAvp";
		:if ([:len $0] = 0 || [:typeof $0] != "str") do={
			:error ($cPath.": Attribute is mandatory, must be string value, not: '".[:typeof $0]."'");
		}
		
		:global MtmAutoAvps;
		:set ($MtmAutoAvps->$0) $1;
		:return true;
	}
	:set ($s->"getAvp") do={
		:local cPath "MTM/Auto/Facts.rsc/getAvp";
		:if ([:len $0] = 0 || [:typeof $0] != "str") do={
			:error ($cPath.": Key is mandatory, must be string value");
		}
		:global MtmAutoAvps;
		:local mVal ($MtmAutoAvps->$0);
		:if ([:typeof $mVal] = "nothing" && $1 != false) do={
			:error ($cPath.": Attribute '".$0."' does not exist");
		}
		:return $mVal;
	}
	
	:set ($s->"loadEnvFile") do={
		:local cPath "MTM/Auto/Facts.rsc/loadEnvFile";
		:if ([:len $0] = 0 || [:typeof $0] != "str") do={
			:error ($cPath.": File path is mandatory, must be string value, not: '".[:typeof $1]."'");
		}
		:if ([:len [/file/find name=$0]] = 0) do={
			:error ($cPath.": Environment file does not exist: '".$0."'");
		}
		:local filePath $0;
		:local override true;
		:if ([:typeof $1] = "bool") do={
			##if this is failing for you call this method with the bool in parentheses e.g. (false)
			:set override $1;
		}
		
		:global MtmAuto;
		:local fileTool [($MtmAuto->"get") "getTools()->getFiles()"];
		:local strTool [($MtmAuto->"get") "getTools()->getStrings()"];

		:local mVal "";
		:local mAttr "";
		:local mValue "";
		:local pos 0;
		:local raw [($fileTool->"getContent") $filePath];
		:local lines [($strTool->"split") $raw ("\n")];

		:foreach line in=$lines do={
			:set line [($strTool->"trim") $line];
			:if ([:len $line] > 0 && [:pick $line 0 1] != "#") do={
			
				:set pos [:find $line "=" 0];
				:if ([:typeof $pos] = "num") do={
					:set mAttr [:pick $line 0 $pos];
					:set mValue [:pick $line ($pos + 1) ([:len $line])];
					
					:if ([:typeof $mValue] = "str") do={
						##string bool from env files should be converted to boolean
						:if ($mValue = "true") do={
							:set mValue true;
						} else={
							:if ($mValue = "false") do={
								:set mValue false;
							}
						}
					}
					:if ($override = true || [:typeof [($MtmAuto->"getEnv") $mAttr (false)]] = "nil") do={
						:set mVal [($MtmAuto->"setEnv") $mAttr $mValue];
					}
				}
			}
		}
		:return true;
	}
	:set ($s->"getNullFile") do={
		:local cPath "MTM/Auto/Facts.rsc/getNullFile";
		:local fName "mtmNull.txt";
		:if ([:len [/file/find where name=$fName]] < 1) do= {
			##Cannot use file tool as it depends on this file
			:local mVal [/file/print file=$fName];
			:local isDone false;
			:local mCount 0;
			:while ($isDone = false) do={
				:if ([:len [/file/find where name=$fName]] < 1) do= {
					:if ($mCount < 6) do= {
						:delay 0.5s;
					} else={
						:error ($cPath.": Failed to create null file");
					}
				} else={
					:set isDone true;
				}
				:set mCount ($mCount + 1);
			}
		}
		:return $fName;
	}
	:set ($s->"importFile") do={
		:local cPath "MTM/Auto/Facts.rsc/importFile";
		:if ([:len $0] = 0 || [:typeof $0] != "str") do={
			:error ($cPath.": File path is mandatory, must be string value");
		}
		:global MtmAuto;
		:local isDebug [($MtmAuto->"getDebug")];
		:local mVal "";
		
		:if ($isDebug = true) do={
			#debugging mode
			:set mVal [($MtmAuto->"echo") ("Starting file import: '".$0."'")];
		}
		:if ([:len [/file/find where name=$0]] = 0) do={
			:error ($cPath.": Cannot import '".$0."' file does not exist");
		} else= {
			:if ($isDebug = true) do={
				##dont do verbose or it will print the script
				:set mVal [/import file-name=$0 verbose=no];
			} else={
			
				#delegate job to sub process
				:local scr (":put ".$0."; /import file-name=".$0." verbose=no");
				:local jobId [:execute script=$scr file=([($MtmAuto->"getNullFile")])];
				
				:local tCount 150; ##need more than 30 secs to run an import?
				:local jobType "";
				:while ($tCount > 0) do={
					:set jobType [/system script job get $jobId type];
					:if ([:typeof $jobType] = "nil") do={
						:set tCount 0;
						##validate job done?
					} else={
						:if ($tCount > 0) do={
							:set tCount ($tCount - 1);
							:delay 0.2s;
						} else={
							:error ($cPath.": Importing '".$0."' resulted in timeout");
						}
					}
				}
			}
		}
		:if ($isDebug = true) do={
			#debugging mode
			:set mVal [($MtmAuto->"echo") ("Completed file import: '".$0."'")];
		}
		:return true;
	}
	:set ($s->"get") do={
		:local cPath "MTM/Auto/Facts.rsc/get";
		
		:global MtmAuto;
		:if ([:typeof $0] != "str") do={
			:error ($cPath.": Input has invalid type '".[:typeof $0]."'");
		}
		:local curObj $MtmAuto;
		:if ([:typeof $1] = "array") do={
			:set curObj $1;
		}
		
		:local pos;
		:local pMethod;
		:local rMethod;
		:local rCmd;
		:local rPath $0;
		:local rLen [:len $rPath];
		:local aLen;
		:local args;
		:local fCall;
		:local isDone 0;
		:while ($isDone = 0) do={
			:set pos [:find $rPath "->"];
			:if ([:typeof $pos] = "num") do={
				:set pMethod [($MtmAuto->"parseCall") [:pick $rPath 0 $pos]];
				:set rPath [:pick $rPath ($pos + 2) $rLen];
				:set rLen [:len $rPath];
			} else={
				:set pMethod [($MtmAuto->"parseCall") $rPath];
				:set isDone 1;
			}
			:if ($curObj = "") do={
				:error ($cPath.": Cannot call: '".($pMethod->"method")."' in '".$0."', previous call failed");
			}
			:set rMethod ($pMethod->"method");
			:if ($curObj->"$rMethod" = nil) do={
				:error ($cPath.": Cannot call: '".($pMethod->"method")."' in '".$0."', method does not exist");
			}

			#super hackish, but there does not seem to be a way to pass parameters as a string or array
			:set aLen [:len ($pMethod->"args")];
			:if ($aLen < 1) do={
				#no parameters
				:set curObj [($curObj->"$rMethod")];
			} else={
				:set args ($pMethod->"args");
				:if ($aLen < 2) do={
					:set curObj [($curObj->"$rMethod") ($args->0->"value")];
				} else={
					:if ($aLen < 3) do={
						:set curObj [($curObj->"$rMethod") ($args->0->"value") ($args->1->"value")];
					} else={
						:if ($aLen < 4) do={
							:set curObj [($curObj->"$rMethod") ($args->0->"value") ($args->1->"value") ($args->2->"value")];
						} else={
							:if ($aLen < 5) do={
								:set curObj [($curObj->"$rMethod") ($args->0->"value") ($args->1->"value") ($args->2->"value") ($args->3->"value")];
							} else={
								:error ($cPath.": Cannot complete '".$0."', only support upto 4 parameters");
							}
						}
					}
				}
			}
		}
		:return $curObj;
	}
	:set ($s->"parseCall") do={
		:local cPath "MTM/Auto/Facts.rsc/parseCall";
		:global MtmAuto;
		:if ([:typeof $0] != "str") do={
			:error ($cPath.": Input has invalid type '".[:typeof $0]."'");
		}
		
		:local rData [:toarray ""];
		:set ($rData->"method") "";
		:set ($rData->"args") [:toarray ""];

		:local strTool [($MtmAuto->"getTools")];
		:set strTool [($strTool->"getStrings")];
		:local rStr [($strTool->"trim") [:tostr $0]];
		
		:local pos;
		:local len;
		:local attr;
		:local val;
		
		:set pos [:find $rStr "("]; #returns nil when not found, but a compare with nil does not work as expected
		:if ([:typeof $pos] = "num") do={
			#open parentheses means there may be arguments/parameters in the call
			:set ($rData->"method") [:pick $rStr 0 $pos];
			:set len [:len $rStr];
			:if ([:pick $rStr ($len - 1) $len] != ")") do={
				:error ($cPath.": Malformed method in '".$0."'");
			}
			:set rStr [:pick $rStr ($pos + 1) ($len - 1)];
			:set rStr [($strTool->"trim") [:tostr $rStr]];
			:set len [:len $rStr];
			:if ($len > 0) do={
				#there is arguments in the method call
				:local argCount 0;
				:local isDone 0;
				:while ($isDone = 0) do={
					:set pos [:find $rStr "='"];
					:if ([:typeof $pos] = "num") do={
						:set attr [:pick $rStr 0 $pos];
						:set attr [($strTool->"trim") [:tostr $attr]];
						:set rStr [:pick $rStr ($pos + 2) $len];
						:set pos [:find $rStr "'"];
						:if ([:typeof $pos] = "num") do={
							:set len [:len $rStr];
							:set val [:pick $rStr 0 $pos];
							:set val [($strTool->"trim") [:tostr $val]];
							
							:set ($rData->"args"->$argCount) [:toarray ""];
							:set ($rData->"args"->$argCount->"index") $argCount;
							:set ($rData->"args"->$argCount->"name") $attr;
							:set ($rData->"args"->$argCount->"value") $val;
							:set argCount ($argCount + 1);
							:set rStr [:pick $rStr ($pos + 1) $len];
							
						} else={
							:error ($cPath.": Malformed arguments in '".$0."'");
						}
					} else={
						:set isDone 1;
					}
				}
			}

		} else={
			:set ($rData->"method") $rStr;
		}
		:return $rData;
	}
	
	##factories
	:set ($s->"getTools") do={
		:global MtmAutoFacts;
		:if ([:typeof ($MtmAutoFacts->"tools")] = "nothing") do={
			:global MtmAuto;
			:local mVal ([($MtmAuto->"getEnv") "mtm.auto.root.path"]."/Facts/Tools.rsc");
			:set mVal [($MtmAuto->"importFile") $mVal];
		}
		:return ($MtmAutoFacts->"tools");
	}

	:set MtmAuto $s;
}
