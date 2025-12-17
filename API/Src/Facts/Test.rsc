:local mVal	"";

:if (1 = 2) do={
:set mVal [/system/script/environment/remove [find]];
}

##:set mVal [/import file-name=flash/storage/MTM/Auto/Enable.rsc];
##:set mVal [/import file-name=flash/storage/MTM/Connect/Enable.rsc];
:set mVal [/import file-name=flash/storage/Apps/CCM/Enable.rsc];

:global MtmAuto;
[($MtmAuto->"setDebug") (true)];
:global MtmUtils;
:global MtmConns;

:local tCount 0;
:local timeTool ([($MtmUtils->"get") "getTools()->getTime()->getEpoch()"]);
:local sTime ([($timeTool->"getCurrent")]);


:global DcnCcm;

:local msgObj [($DcnCcm->"get") "getApis()->newRequest()"];
:set mVal ([($msgObj->"setL1") "CCM"]);
:set mVal ([($msgObj->"setL2") "Instances"]);
:set mVal ([($msgObj->"setL3") "Get"]);
:set mVal ([($msgObj->"setL4") "Exists"]);
:set mVal ([($msgObj->"setL5") "ByIdentity"]);

:set mVal ([($msgObj->"addTxData") "identity" "ap-99851.lionstripe.com"]);

#:put ("Dur ".($tCount).": ".(([($timeTool->"getCurrent")]) - $sTime));
#:set tCount ($tCount + 1);


:put ("Pepper start");
:put ([($msgObj->"getResponse")]);
:put ("Pepper end");

:put ("Count ".($tCount).", Duration: ".(([($timeTool->"getCurrent")]) - $sTime));
:set tCount ($tCount + 1);




#:for i from=1 to=100 do={
#:local msgObj [($DcnCcm->"get") "getApis()->newRequest()"];
#:set mVal ([($msgObj->"setL1") "CCM"]);
#:set mVal ([($msgObj->"setL2") "Instances"]);
#:set mVal ([($msgObj->"setL3") "Get"]);
#:set mVal ([($msgObj->"setL4") "Exists"]);
#:set mVal ([($msgObj->"setL5") "ByIdentity"]);

#:set mVal ([($msgObj->"addTxData") "identity" "ap-99851.lionstripe.com"]);
#:put ([($msgObj->"getResponse")]);
#
#:put ("Count: ".($tCount).", Dur:  ".(([($timeTool->"getCurrent")]) - $sTime));
#:set tCount ($tCount + 1);
#} 
