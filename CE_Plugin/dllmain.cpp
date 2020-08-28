﻿// dllmain.cpp : 定义 DLL 应用程序的入口点。
#include "pch.h"
#include <Windows.h>
#include <iostream>

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

extern "C" __declspec(dllexport) HWND targetWindow = 0;
BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam)
{
    DWORD  dwProcessID = 0;
    GetWindowThreadProcessId(hwnd, &dwProcessID);
	if (dwProcessID == GetCurrentProcessId())
    {
        targetWindow = hwnd;
        return false;
    }
    return true;
}

extern "C" {
	__declspec(dllexport) HWND __stdcall getTargetWindow()
    {
        if (targetWindow) return targetWindow;
        EnumWindows(EnumWindowsProc, 0);
        return targetWindow;
    }
}