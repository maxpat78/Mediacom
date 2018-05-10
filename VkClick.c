#include <windows.h>
#include <shlwapi.h>
#include <stdio.h>

#pragma comment(linker,"/DEFAULTLIB:USER32.lib")
#pragma comment(linker,"/DEFAULTLIB:COMDLG32.lib")
#pragma comment(linker,"/DEFAULTLIB:SHLWAPI.lib")

DWORD dwReturnCode  = 0;

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch(uMsg)
	{
	case WM_KEYUP:
		// Please note: POWER button long pressed returns VK_F16
        //printf("WM_KEYUP wParam=%04X, lParam=%08X\n", wParam, lParam);
        if (wParam == VK_LWIN) {
            dwReturnCode = 2;
            DestroyWindow(hWnd);
        }
        if (wParam == VK_VOLUME_UP) {
            dwReturnCode = 1;
            DestroyWindow(hWnd);
        }
        if (wParam == VK_VOLUME_DOWN || wParam == VK_ESCAPE) {
            dwReturnCode = 0;
            DestroyWindow(hWnd);
        }
		return 0;
    case WM_CLOSE:
        DestroyWindow(hWnd);
        return 0;
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    default:
        return DefWindowProc(hWnd, uMsg, wParam, lParam);
    }
}



int main(int argc, char** argv)
{
	WNDCLASSEX wcx;
	HANDLE hInst = GetModuleHandle(0);
    HWND hWnd;
    MSG msg;

	if (! StrStr(GetCommandLine(),"wait"))
		return MessageBox(0,"Use \"VkClick wait\" to ask user for pressing a button on the Tablet.\n\n"\
										"WIN makes the app to return error code 2.\n"\
										"VOLUME+ returns error code 1.\n"\
										"VOLUME- returns error code 0.", "Bad arguments", MB_ICONSTOP);

    ZeroMemory(&wcx, sizeof(wcx));

	// Window class for the main application parent window
	wcx.cbSize			= sizeof(wcx);
	wcx.style			= 0;
	wcx.lpfnWndProc		= WndProc;
	wcx.cbClsExtra		= 0;
	wcx.cbWndExtra		= 0;
	wcx.hInstance		= hInst;
	wcx.hCursor			= LoadCursor (NULL, IDC_ARROW);
	wcx.hbrBackground	= (HBRUSH)0;
	wcx.lpszMenuName	= NULL;
	wcx.lpszClassName	= "ClickKeyClass";

	RegisterClassEx(&wcx);

    hWnd = CreateWindowEx(0,
				"ClickKeyClass",
				"Press a key...",
				WS_CAPTION,
				GetSystemMetrics(SM_CXSCREEN)/2,
				GetSystemMetrics(SM_CYSCREEN)/2,
				400, 50,
				NULL, NULL, GetModuleHandle(0), NULL);

    ShowWindow(hWnd, SW_SHOWNORMAL);

    while(GetMessage(&msg, NULL, 0, 0) > 0)
	{
		if(!TranslateAccelerator(hWnd, 0, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	return dwReturnCode;
}