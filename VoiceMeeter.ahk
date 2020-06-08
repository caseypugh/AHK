; Display warnings about poor practices and possible errors
; This should probably only be used during development/debugging...
; TODO: Remove before production release.
#Warn All

; Don't lookup references to undefined variables in the environment
#NoEnv

; If we detect another copy of this script is already running,
; automatically replace the older instance, much like a 'Reload'
#SingleInstance force

#UseHook

global VERSION := "0.0.1"

global VMR_FUNCTIONS := {}
global VMR_DLL_DRIVE := "C:"
global VMR_DLL_DIRPATH := "Program Files (x86)\VB\Voicemeeter"
global VMR_DLL_FILENAME_32 := "VoicemeeterRemote.dll"
global VMR_DLL_FILENAME_64 := "VoicemeeterRemote64.dll"

global VMR_DLL_FULL_PATH := VMR_DLL_DRIVE . "\" . VMR_DLL_DIRPATH . "\"

if (A_Is64bitOS) {
    VMR_DLL_FULL_PATH .= VMR_DLL_FILENAME_64
} else {
    VMR_DLL_FULL_PATH .= VMR_DLL_FILENAME_32
}

; == START OF EXECUTION ==
; ========================

; Load the VoicemeeterRemote DLL:
; This returns a module handle
global VMR_MODULE := DllCall("LoadLibrary", "Str", VMR_DLL_FULL_PATH, "Ptr")
if (ErrorLevel || VMR_MODULE == 0)
    die("Attempt to load VoiceMeeter Remote DLL failed.")

; Populate VMR_FUNCTIONS
add_vmr_function("Login")
add_vmr_function("Logout")
add_vmr_function("RunVoicemeeter")
add_vmr_function("SetParameterFloat")
add_vmr_function("GetParameterFloat")
add_vmr_function("IsParametersDirty")

; "Login" to Voicemeeter, by calling the function in the DLL named 'VBVMR_Login()'...
login_result := DllCall(VMR_FUNCTIONS["Login"], "Int")
if (ErrorLevel || login_result < 0)
    die("VoiceMeeter Remote login failed.")

; If the login returns 1, that apparently means that Voicemeeter isn't running,
; so we start it; pass 1 to run Voicemeeter, or 2 for Voicemeeter Banana:
if (login_result == 1) {
    DllCall(VMR_FUNCTIONS["RunVoicemeeter"], "Int", 2, "Int")
    if (ErrorLevel)
        die("Attempt to run VoiceMeeter failed.")
    Sleep 2000
}

; == Functions ==
; ===============
add_vmr_function(func_name) {
    VMR_FUNCTIONS[func_name] := DllCall("GetProcAddress", "Ptr", VMR_MODULE, "AStr", "VBVMR_" . func_name, "Ptr")
    if (ErrorLevel || VMR_FUNCTIONS[func_name] == 0)
        die("Failed to register VMR function " . func_name . ".")
}

cleanup_before_exit(exit_reason, exit_code) {
    DllCall(VMR_FUNCTIONS["Logout"], "Int")
    ; OnExit functions must return 0 to allow the app to exit.
    return 0
}

die(die_string:="UNSPECIFIED FATAL ERROR.", exit_status:=254) {
    MsgBox 16, FATAL ERROR, %die_string%
    ExitApp exit_status
}

vmSet(func, value) {
    DllCall(VMR_FUNCTIONS["SetParameterFloat"], "AStr", func, "Float", value, "Int")
}

vmToggle(func) {
    togg := vmRead(func)
    if (togg == 1)
        togg := 0
    else
        togg := 1
	DllCall(VMR_FUNCTIONS["SetParameterFloat"], "AStr", func, "Float", togg, "Int")
}


vmRead(loc){
	Loop
	{
		pDirty := DLLCall(VMR_FUNCTIONS["IsParametersDirty"]) ;Check if parameters have changed. 
		if (pDirty==0) ;0 = no new paramters.
			break
		else if (pDirty<0) ;-1 = error, -2 = no server
			return ""
		else ;1 = New parameters -> update your display. (this only applies if YOU have a display, couldn't find any code to update VM display which can get off sometimes)
			if A_Index > 200
				return ""
			sleep, 20
	}
	tParamVal := 0.0
	NumPut(0.0, tParamVal, 0, "Float")
	statusLvl := DllCall(VMR_FUNCTIONS["GetParameterFloat"], "AStr", loc, "Ptr", &tParamVal, "Int")
	tParamVal := NumGet(tParamVal, 0, "Float")
	if (statusLvl < 0)
		return ""
	else
		return tParamVal
}