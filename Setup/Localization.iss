#ifndef _Localization
	#define _Localization

;
; Localization
;

#include "..\Localization\English\EnglishSetup.iss"
#include "..\Localization\Russian\RussianSetup.iss"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: "..\LICENSE.txt"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"; LicenseFile: "..\Localization\Russian\License.txt"

#endif
