#include "projector_window_manager.h"
#include <iostream>
#include <sstream>

const wchar_t* ProjectorWindowManager::kSecondaryWindowClassName = L"AdventHymnalsProjectorWindow";
ProjectorWindowManager* ProjectorWindowManager::instance_ = nullptr;

ProjectorWindowManager::ProjectorWindowManager() 
    : engine_(nullptr), secondary_window_(nullptr) {
    instance_ = this;
}

ProjectorWindowManager::~ProjectorWindowManager() {
    Dispose();
    instance_ = nullptr;
}

bool ProjectorWindowManager::Initialize(void* engine) {
    if (!engine) {
        std::cerr << "ProjectorWindowManager: Engine is null" << std::endl;
        return false;
    }
    
    engine_ = engine;
    
    // Register window class for secondary window
    WNDCLASS wc = {};
    wc.lpfnWndProc = SecondaryWindowProc;
    wc.hInstance = GetModuleHandle(nullptr);
    wc.lpszClassName = kSecondaryWindowClassName;
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
    
    if (!RegisterClass(&wc)) {
        DWORD error = GetLastError();
        if (error != ERROR_CLASS_ALREADY_EXISTS) {
            std::cerr << "ProjectorWindowManager: Failed to register window class. Error: " << error << std::endl;
            return false;
        }
    }
    
    std::cout << "ProjectorWindowManager: Initialized successfully" << std::endl;
    return true;
}

void ProjectorWindowManager::Dispose() {
    CloseSecondaryWindow();
    
    // Unregister window class
    UnregisterClass(kSecondaryWindowClassName, GetModuleHandle(nullptr));
    
    monitors_.clear();
    engine_ = nullptr;
}

std::vector<MonitorInfo> ProjectorWindowManager::GetMonitors() {
    monitors_.clear();
    
    // Enumerate all monitors
    EnumDisplayMonitors(nullptr, nullptr, MonitorEnumProc, reinterpret_cast<LPARAM>(this));
    
    return monitors_;
}

BOOL CALLBACK ProjectorWindowManager::MonitorEnumProc(HMONITOR hMonitor, HDC hdcMonitor, 
                                                     LPRECT lprcMonitor, LPARAM dwData) {
    auto* manager = reinterpret_cast<ProjectorWindowManager*>(dwData);
    
    MONITORINFOEX monitorInfo = {};
    monitorInfo.cbSize = sizeof(MONITORINFOEX);
    
    if (GetMonitorInfo(hMonitor, &monitorInfo)) {
        MonitorInfo info;
        info.index = static_cast<int>(manager->monitors_.size());
        info.hMonitor = hMonitor;
        info.x = monitorInfo.rcMonitor.left;
        info.y = monitorInfo.rcMonitor.top;
        info.width = monitorInfo.rcMonitor.right - monitorInfo.rcMonitor.left;
        info.height = monitorInfo.rcMonitor.bottom - monitorInfo.rcMonitor.top;
        info.isPrimary = (monitorInfo.dwFlags & MONITORINFOF_PRIMARY) != 0;
        info.scaleFactor = 1.0; // Default scale factor
        
        // Convert device name to string
        int size = WideCharToMultiByte(CP_UTF8, 0, monitorInfo.szDevice, -1, nullptr, 0, nullptr, nullptr);
        if (size > 0) {
            std::string result(size - 1, '\0');
            WideCharToMultiByte(CP_UTF8, 0, monitorInfo.szDevice, -1, &result[0], size, nullptr, nullptr);
            info.name = result;
        } else {
            info.name = "Unknown Monitor";
        }
        
        manager->monitors_.push_back(info);
    }
    
    return TRUE;
}

bool ProjectorWindowManager::OpenSecondaryWindow(int monitorIndex, bool fullscreen, 
                                                int width, int height, int x, int y) {
    if (secondary_window_) {
        std::cout << "ProjectorWindowManager: Secondary window already open" << std::endl;
        return false;
    }
    
    // Get monitors
    GetMonitors();
    
    // Determine position and size
    int finalX = x;
    int finalY = y;
    int finalWidth = width;
    int finalHeight = height;
    
    if (monitorIndex >= 0 && monitorIndex < static_cast<int>(monitors_.size())) {
        const auto& monitor = monitors_[monitorIndex];
        finalX = monitor.x;
        finalY = monitor.y;
        
        if (fullscreen) {
            finalWidth = monitor.width;
            finalHeight = monitor.height;
        } else {
            finalX += x;
            finalY += y;
        }
    }
    
    return CreateSecondaryWindow(finalX, finalY, finalWidth, finalHeight, fullscreen);
}

bool ProjectorWindowManager::CreateSecondaryWindow(int x, int y, int width, int height, bool fullscreen) {
    DWORD windowStyle = WS_OVERLAPPEDWINDOW;
    if (fullscreen) {
        windowStyle = WS_POPUP;
    }
    
    secondary_window_ = CreateWindow(
        kSecondaryWindowClassName,
        L"Advent Hymnals Projector",
        windowStyle,
        x, y, width, height,
        nullptr,
        nullptr,
        GetModuleHandle(nullptr),
        this
    );
    
    if (!secondary_window_) {
        std::cerr << "ProjectorWindowManager: Failed to create secondary window" << std::endl;
        return false;
    }
    
    // Set background color to black
    SetClassLongPtr(secondary_window_, GCLP_HBRBACKGROUND, (LONG_PTR)GetStockObject(BLACK_BRUSH));
    
    if (fullscreen) {
        // Remove window decorations for fullscreen
        SetWindowLong(secondary_window_, GWL_STYLE, WS_POPUP);
        SetWindowPos(secondary_window_, HWND_TOPMOST, x, y, width, height, SWP_FRAMECHANGED);
    }
    
    ShowWindow(secondary_window_, SW_SHOW);
    UpdateWindow(secondary_window_);
    
    std::cout << "ProjectorWindowManager: Secondary window created successfully" << std::endl;
    return true;
}

bool ProjectorWindowManager::CloseSecondaryWindow() {
    if (secondary_window_) {
        DestroyWindow(secondary_window_);
        secondary_window_ = nullptr;
        std::cout << "ProjectorWindowManager: Secondary window closed" << std::endl;
        return true;
    }
    return false;
}

bool ProjectorWindowManager::UpdateSecondaryWindow(int width, int height, int x, int y, bool fullscreen) {
    if (!secondary_window_) {
        return false;
    }
    
    DWORD windowStyle = fullscreen ? WS_POPUP : WS_OVERLAPPEDWINDOW;
    SetWindowLong(secondary_window_, GWL_STYLE, windowStyle);
    
    UINT flags = SWP_FRAMECHANGED;
    if (fullscreen) {
        flags |= SWP_NOZORDER;
    }
    
    SetWindowPos(secondary_window_, fullscreen ? HWND_TOPMOST : HWND_NOTOPMOST, 
                 x, y, width, height, flags);
    
    return true;
}

bool ProjectorWindowManager::MoveToMonitor(int monitorIndex) {
    if (!secondary_window_ || monitorIndex < 0 || monitorIndex >= static_cast<int>(monitors_.size())) {
        return false;
    }
    
    const auto& monitor = monitors_[monitorIndex];
    return UpdateSecondaryWindow(monitor.width, monitor.height, monitor.x, monitor.y, true);
}

bool ProjectorWindowManager::SetFullscreenOnMonitor(int monitorIndex) {
    return MoveToMonitor(monitorIndex);
}

bool ProjectorWindowManager::UpdateContent(const std::string& content) {
    if (!secondary_window_) {
        return false;
    }
    
    // For now, just invalidate the window to trigger a repaint
    InvalidateRect(secondary_window_, nullptr, TRUE);
    return true;
}

MonitorInfo* ProjectorWindowManager::GetMonitorByIndex(int index) {
    if (index >= 0 && index < static_cast<int>(monitors_.size())) {
        return &monitors_[index];
    }
    return nullptr;
}

MonitorInfo* ProjectorWindowManager::GetPrimaryMonitor() {
    for (auto& monitor : monitors_) {
        if (monitor.isPrimary) {
            return &monitor;
        }
    }
    return nullptr;
}

std::wstring ProjectorWindowManager::StringToWideString(const std::string& str) {
    int size = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, nullptr, 0);
    if (size > 0) {
        std::wstring result(size - 1, L'\0');
        MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, &result[0], size);
        return result;
    }
    return L"";
}

LRESULT CALLBACK ProjectorWindowManager::SecondaryWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_CREATE: {
            auto* createStruct = reinterpret_cast<CREATESTRUCT*>(lParam);
            auto* manager = reinterpret_cast<ProjectorWindowManager*>(createStruct->lpCreateParams);
            SetWindowLongPtr(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(manager));
            break;
        }
        
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            
            // Fill with black background
            RECT rect;
            GetClientRect(hwnd, &rect);
            FillRect(hdc, &rect, (HBRUSH)GetStockObject(BLACK_BRUSH));
            
            // Draw placeholder text
            SetBkColor(hdc, RGB(0, 0, 0));
            SetTextColor(hdc, RGB(255, 255, 255));
            
            const wchar_t* text = L"Projector Window - Flutter Content Will Appear Here";
            DrawText(hdc, text, -1, &rect, DT_CENTER | DT_VCENTER | DT_SINGLELINE);
            
            EndPaint(hwnd, &ps);
            break;
        }
        
        case WM_CLOSE:
            if (instance_) {
                instance_->CloseSecondaryWindow();
            }
            break;
        
        case WM_DESTROY:
            break;
        
        default:
            return DefWindowProc(hwnd, uMsg, wParam, lParam);
    }
    
    return 0;
}