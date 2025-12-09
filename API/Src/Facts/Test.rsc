:local mVal	"";


:if (1 = 1) do={
:set mVal [/system/script/environment/remove [find]];
}

##:set mVal [/import file-name=flash/storage/MTM/Auto/Enable.rsc];
##:set mVal [/import file-name=flash/storage/MTM/Connect/Enable.rsc];
:set mVal [/import file-name=flash/storage/Apps/CCM/Enable.rsc];

:global MtmAuto;
[($MtmAuto->"setDebug") (true)];
:global MtmUtils;
:global MtmConns;

:global DcnCcm;


:local connObj [($DcnCcm->"get") "getApis()->getApi()"];
	
:put ("Pepper start");
:put ([($connObj->"getPepper")]);
:put ("Pepper end");
		





