:local mVal	"";


:if (1 = 2) do={
:set mVal [/system/script/environment/remove [find]];
}

##:set mVal [/import file-name=flash/storage/MTM/Auto/Enable.rsc];
:set mVal [/import file-name=flash/storage/MTM/Utilities/Enable.rsc];

:global MtmAuto;
[($MtmAuto->"setDebug") (true)];
:global MtmUtils;


:local toolObj [($MtmUtils->"get") "getTools()->getConcurrency()->getMutex()"];
:local lockName "myProc"; 
:local lockHold 5;
:local lockWait 2;
:local key [($toolObj->"lock") $lockName $lockHold $lockWait]; ##error if the lock is already held else the key for the lock
:put ($key);














##remove specific tool from cache
#:local sysId "tool-time-epoch";
#:local objFact [($MtmFacts->"getObjects")];
#:local sObj [($objFact->"getStore") $sysId];
#:set ($sObj->"obj"->($sObj->"hash"));

#:local result [($MtmFacts->"get") "getTools()->getTime()->getEpoch()->getCurrent()"];
#:put ("Current Epoch: ".$result); #epoch time



