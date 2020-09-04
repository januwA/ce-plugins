// dllmain.cpp : 定义 DLL 应用程序的入口点。
#include "pch.h"
#include <Windows.h>
#include <iostream>
#include <string>

using namespace std;

// 是否注入符号
extern "C"  __declspec(dllexport) BYTE isInjectCE_PluginDLL = 0;

// target窗口句柄
HWND targetWindow = 0;

// target文件路径
wchar_t targetFilePath[1024] = {};

// target文件目录
wchar_t targetFileDir[1024] = L"\0";

BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam)
{
	DWORD  pid = 0;
	GetWindowThreadProcessId(hwnd, &pid);
	if (pid == GetCurrentProcessId()) // 判断pid
	{
		char text[1024];
		GetWindowTextA(hwnd, (LPSTR)text, 1024); // 必须含有标题文字
		if (strlen(text) != 0 && IsWindowVisible(hwnd))
		{
			// printf("%s\n", text);
			targetWindow = hwnd;
			return FALSE;
		}
	}
	return TRUE;
}

int WINAPI Mythread(HMODULE hModule)
{
	EnumWindows(EnumWindowsProc, 0);
	return 0;
}

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		CloseHandle(CreateThread(0, 0, (LPTHREAD_START_ROUTINE)Mythread, hModule, 0, 0));
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

extern "C" {

	// 返回目标进程的窗口句柄
	__declspec(dllexport) HWND __stdcall getTargetWindow()
	{
		if (targetWindow) return targetWindow;
		EnumWindows(EnumWindowsProc, 0);
		return targetWindow;
	}

	// 返回目标进程的文件路径
	__declspec(dllexport) wchar_t* __stdcall getTargetFilePath()
	{
		if (wcslen(targetFilePath) != 0) return targetFilePath;
		GetModuleFileNameW(NULL, targetFilePath, sizeof(targetFilePath));
		return targetFilePath;
	}

	// 返回目标进程的文件目录
	__declspec(dllexport) wchar_t* __stdcall getTargetFileDir()
	{

		if (wcslen(targetFileDir) != 0) return targetFileDir;

		string s = "";
		s.resize(1024);
		if (GetModuleFileNameA(NULL, (LPSTR)s.data(), s.size()))
		{
			// C:\Users\ajanuw\Desktop\game2.exe  to  C:\Users\ajanuw\Desktop\
			//
			string s2 = s.substr(0, s.find_last_of("\\") + 1);

			setlocale(LC_ALL, "chs");
			MultiByteToWideChar(CP_ACP, 0, s2.c_str(), s2.length(), targetFileDir, s2.length());
		}
		return targetFileDir;
	}

	
	/*
		0关机 1重启 2注销
		返回FALSE则失败，否者返回TRUE
		https://www.cnblogs.com/ajanuw/p/13607687.html
	*/
	__declspec(dllexport) BOOL __stdcall exitWindowsEx(DWORD val)
	{
		DWORD uFlags;
		if (val == 0)
		{
			// 关机
			uFlags = EWX_SHUTDOWN | EWX_FORCE;
		}
		else if(val == 1) {
			// 重启
			uFlags = EWX_REBOOT | EWX_FORCE;
		}
		else if (val == 2)
		{
			// 注销
			uFlags = EWX_LOGOFF | EWX_FORCE;
		}
		else {
			return FALSE;
		}


		HANDLE hToken;
		if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken))
			return(FALSE);

		// 获取关闭特权的LUID
		TOKEN_PRIVILEGES tkp;
		LookupPrivilegeValue(NULL, SE_SHUTDOWN_NAME, &tkp.Privileges[0].Luid);

		tkp.PrivilegeCount = 1;  // one privilege to set    
		tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

		// 获取此过程的关闭特权。
		AdjustTokenPrivileges(hToken, FALSE, &tkp, 0, (PTOKEN_PRIVILEGES)NULL, 0);

		if (GetLastError() != ERROR_SUCCESS)
		{
			CloseHandle(hToken);
			return FALSE;
		}

		if (!ExitWindowsEx(uFlags,
			SHTDN_REASON_MAJOR_OPERATINGSYSTEM |
			SHTDN_REASON_MINOR_UPGRADE |
			SHTDN_REASON_FLAG_PLANNED))
		{
			CloseHandle(hToken);
			return FALSE;
		}

		return TRUE;
	}
}
