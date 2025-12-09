:local cPath "MTM/Auto/Tools/Strings.rsc";
:local s [:toarray ""];

:set ($s->"split") do={
	
	:local cPath "MTM/Auto/Tools/Strings.rsc/split";
	:if ([:typeof $0] != "str") do={
		:if ([:typeof $0] = "nil") do={
			:return [:toarray ""];
		} else={
			:error ($cPath.": Input has invalid type '".[:typeof $0]."'");
		}
	}
	:if ([:typeof $1] != "str") do={
		:error ($cPath.": Input pattern has invalid type '".[:typeof $1]."'");
	}

	:local rData [:toarray ""];
	:local rCount 0;
	:local sLen [:len $1];
	:if ($sLen = 0) do={
		:set ($rData->$rCount) $0;
	} else= {
	
		:local lData $0;
		:local cData "";
		:local lLen [:len $0];
		:local pos;
		:local isDone 0;
		:while ($isDone = 0) do={
			:set pos [:find $lData $1];
			:if ([:typeof $pos] = "num") do={
				:set cData [:pick $lData 0 $pos];
				:set lData [:pick $lData ($pos + $sLen) $lLen];
				:set lLen [:len $lData];
			} else={
				:set cData $lData;
				:set isDone 1;
			}
			:set ($rData->$rCount) $cData;
			:set rCount ($rCount + 1);
		}
	}
	:return $rData;
}
:set ($s->"trim") do={
	
	:local cPath "MTM/Auto/Tools/Strings.rsc/trim";
	:if ([:typeof $0] != "str") do={
		:if ([:typeof $0] = "nil") do={
			:return "";
		} else={
			:error ($cPath.": Input has invalid type '".[:typeof $0]."'");
		}
	}
	:local p0 $0;
	:local l0 [:len $p0];
	:local r0 "";
	:local ch "";
	:local isDone 0;
	# remove leading spaces
	:for x from=0 to=($l0 - 1) do={
		:set ch [:pick $p0 $x];
		:if ($isDone = 0 && $ch != " " && $ch != "\n" && $ch != "\r") do={
			:set r0 [:pick $p0 $x $l0];
			:set isDone 1;
		}
	}
	:set l0 [:len $r0];
	:local pos $l0;
	:set isDone 0;
	# remove trailing spaces
	:for x from=1 to=($l0 - 1) do={
		:set pos ($l0 - $x);
		:set ch [:pick $r0 $pos];
		:if ($isDone = 0 && $ch != " " && $ch != "\n" && $ch != "\r") do={
			:set r0 [:pick $r0 0 ($pos + 1)];
			:set isDone 1;
		}
	}
	:if ($r0 = [:nothing]) do={
		#always return string, the nil value is a pain
		:set r0 "";
	}
	:return $r0;
}
:global MtmAutoTools;
:set ($MtmAutoTools->"strings") $s;
