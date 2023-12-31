bcdedit /deletevalue allowedinmemorysettings
bcdedit /deletevalue avoidlowmemory
bcdedit /deletevalue bootems
bcdedit /deletevalue bootlog
bcdedit /deletevalue bootmenupolicy
bcdedit /deletevalue bootux
bcdedit /deletevalue debug
bcdedit /deletevalue disabledynamictick
bcdedit /deletevalue disableelamdrivers
bcdedit /deletevalue ems
bcdedit /deletevalue extendedinput
bcdedit /deletevalue firstmegabytepolicy
bcdedit /deletevalue forcefipscrypto
bcdedit /deletevalue forcelegacyplatform
bcdedit /deletevalue halbreakpoint
bcdedit /deletevalue highestmode
bcdedit /deletevalue hypervisorlaunchtype
bcdedit /deletevalue increaseuserva
bcdedit /deletevalue integrityservices
bcdedit /deletevalue isolatedcontext
bcdedit /deletevalue linearaddress57
bcdedit /deletevalue nointegritychecks
bcdedit /deletevalue nolowmem 
bcdedit /deletevalue noumex 
bcdedit /deletevalue nx
bcdedit /deletevalue onecpu
bcdedit /deletevalue pae
bcdedit /deletevalue perfmem
bcdedit /deletevalue quietboot
bcdedit /deletevalue sos
bcdedit /deletevalue testsigning
bcdedit /deletevalue tpmbootentropy
bcdedit /deletevalue tscsyncpolicy
bcdedit /deletevalue usefirmwarepcisettings
bcdedit /deletevalue usephysicaldestination
bcdedit /deletevalue useplatformclock
bcdedit /deletevalue useplatformtick
bcdedit /deletevalue vm
bcdedit /deletevalue vsmlaunchtype
bcdedit /deletevalue {current} safeboot
bcdedit /deletevalue {current} safebootalternateshell
bcdedit /deletevalue {current} removememory
bcdedit /deletevalue {current} truncatememory
bcdedit /deletevalue {current} useplatformclock
bcdedit /deletevalue {current} disabledynamictick
bcdedit /deletevalue {default} safeboot
bcdedit /deletevalue {default} safebootalternateshell
bcdedit /deletevalue {default} removememory
bcdedit /deletevalue {default} truncatememory
bcdedit /deletevalue {default} useplatformclock
bcdedit /deletevalue {default} disabledynamictick
bcdedit /set {current} hypervisorlaunchtype off
Bcdedit /set {current} flightsigning off
bcdedit /set {current} bootems no
bcdedit /set {current} nx AlwaysOn
bcdedit /set {current} bootux disabled
bcdedit /set {current} bootmenupolicy legacy
bcdedit /set {current} tscsyncpolicy Enhanced
bcdedit /set {current} bootstatuspolicy IgnoreAllFailures
bcdedit /set {current} recoveryenabled no
bcdedit /set {current} quietboot yes
bcdedit /set {current} useplatformtick yes
bcdedit /set {current} vsmlaunchtype Off
bcdedit /set {current} vm No
bcdedit /set {globalsettings} custom:16000067 true
bcdedit /set {globalsettings} custom:16000069 true
bcdedit /set {globalsettings} custom:16000068 true
bootsect /nt60 sys /force