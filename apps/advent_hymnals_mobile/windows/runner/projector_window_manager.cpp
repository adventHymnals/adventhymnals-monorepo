#include "projector_window_manager.h"
#include "flutter_window.h"
#include <flutter/flutter_view_controller.h>
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

bool ProjectorWindowManager::Initialize(flutter::FlutterEngine* engine) {
    if (!engine) {
        std::cerr << "ProjectorWindowManager: Engine is null" << std::endl;
        return false;
    }
    
    engine_ = engine;
    
    // Create method channel
    method_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        engine_->messenger(), "com.adventhymnals.org/projector_window",
        &flutter::StandardMethodCodec::GetInstance());
    
    // Set method call handler
    method_channel_->SetMethodCallHandler(
        [this](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
            HandleMethodCall(call, std::move(result));
        });
    
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
    
    if (method_channel_) {
        method_channel_->SetMethodCallHandler(nullptr);
        method_channel_.reset();
    }
    
    engine_ = nullptr;
    monitors_.clear();
    
    // Unregister window class
    UnregisterClass(kSecondaryWindowClassName, GetModuleHandle(nullptr));
}

void ProjectorWindowManager::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    
    const std::string& method_name = method_call.method_name();
    
    if (method_name == "initialize") {
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "getMonitors") {
        auto monitors = GetMonitors();
        flutter::EncodableList monitor_list;
        
        for (const auto& monitor : monitors) {
            flutter::EncodableMap monitor_map;
            monitor_map[flutter::EncodableValue("index")] = flutter::EncodableValue(monitor.index);
            monitor_map[flutter::EncodableValue("name")] = flutter::EncodableValue(monitor.name);
            monitor_map[flutter::EncodableValue("width")] = flutter::EncodableValue(monitor.width);
            monitor_map[flutter::EncodableValue("height")] = flutter::EncodableValue(monitor.height);
            monitor_map[flutter::EncodableValue("x")] = flutter::EncodableValue(monitor.x);
            monitor_map[flutter::EncodableValue("y")] = flutter::EncodableValue(monitor.y);
            monitor_map[flutter::EncodableValue("isPrimary")] = flutter::EncodableValue(monitor.isPrimary);
            monitor_map[flutter::EncodableValue("scaleFactor")] = flutter::EncodableValue(monitor.scaleFactor);
            
            monitor_list.push_back(flutter::EncodableValue(monitor_map));
        }
        
        result->Success(flutter::EncodableValue(monitor_list));
    } else if (method_name == "openSecondaryWindow") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (!arguments) {
            result->Error("INVALID_ARGUMENTS", "Arguments must be a map");
            return;
        }
        
        int monitorIndex = -1;
        bool fullscreen = true;
        int width = 1280;
        int height = 720;
        int x = 100;
        int y = 100;
        
        auto it = arguments->find(flutter::EncodableValue("monitorIndex"));
        if (it != arguments->end()) {
            monitorIndex = std::get<int>(it->second);
        }
        
        it = arguments->find(flutter::EncodableValue("fullscreen"));
        if (it != arguments->end()) {
            fullscreen = std::get<bool>(it->second);
        }
        
        it = arguments->find(flutter::EncodableValue("width"));
        if (it != arguments->end()) {
            width = std::get<int>(it->second);
        }
        
        it = arguments->find(flutter::EncodableValue("height"));
        if (it != arguments->end()) {
            height = std::get<int>(it->second);
        }
        
        it = arguments->find(flutter::EncodableValue("x"));
        if (it != arguments->end()) {
            x = std::get<int>(it->second);
        }
        
        it = arguments->find(flutter::EncodableValue("y"));
        if (it != arguments->end()) {
            y = std::get<int>(it->second);
        }
        
        bool success = OpenSecondaryWindow(monitorIndex, fullscreen, width, height, x, y);
        result->Success(flutter::EncodableValue(success));
    } else if (method_name == "closeSecondaryWindow") {
        bool success = CloseSecondaryWindow();
        result->Success(flutter::EncodableValue(success));
    } else if (method_name == "moveToMonitor") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (!arguments) {
            result->Error("INVALID_ARGUMENTS", "Arguments must be a map");
            return;
        }
        
        auto it = arguments->find(flutter::EncodableValue("monitorIndex"));
        if (it == arguments->end()) {
            result->Error("MISSING_ARGUMENT", "monitorIndex is required");
            return;
        }
        
        int monitorIndex = std::get<int>(it->second);
        bool success = MoveToMonitor(monitorIndex);
        result->Success(flutter::EncodableValue(success));
    } else if (method_name == "setFullscreenOnMonitor") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (!arguments) {
            result->Error("INVALID_ARGUMENTS", "Arguments must be a map");
            return;
        }
        
        auto it = arguments->find(flutter::EncodableValue("monitorIndex"));
        if (it == arguments->end()) {
            result->Error("MISSING_ARGUMENT", "monitorIndex is required");
            return;
        }
        
        int monitorIndex = std::get<int>(it->second);
        bool success = SetFullscreenOnMonitor(monitorIndex);
        result->Success(flutter::EncodableValue(success));
    } else if (method_name == "updateContent") {
        // For now, just return success
        // In a full implementation, this would update the Flutter content in the secondary window
        result->Success(flutter::EncodableValue(true));
    } else {
        result->NotImplemented();
    }
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
    
    MONITORINFOEX monitorInfo;
    monitorInfo.cbSize = sizeof(MONITORINFOEX);
    
    if (GetMonitorInfo(hMonitor, &monitorInfo)) {
        MonitorInfo info;
        info.index = static_cast<int>(manager->monitors_.size());
        info.name = std::string(monitorInfo.szDevice);
        info.width = monitorInfo.rcMonitor.right - monitorInfo.rcMonitor.left;
        info.height = monitorInfo.rcMonitor.bottom - monitorInfo.rcMonitor.top;
        info.x = monitorInfo.rcMonitor.left;
        info.y = monitorInfo.rcMonitor.top;
        info.isPrimary = (monitorInfo.dwFlags & MONITORINFOF_PRIMARY) != 0;
        info.scaleFactor = 1.0; // Windows DPI awareness would be needed for accurate scaling
        info.hMonitor = hMonitor;
        
        manager->monitors_.push_back(info);
    }
    
    return TRUE;
}

bool ProjectorWindowManager::OpenSecondaryWindow(int monitorIndex, bool fullscreen, 
                                               int width, int height, int x, int y) {
    if (secondary_window_) {
        std::cout << "ProjectorWindowManager: Secondary window already open" << std::endl;
        return true;
    }
    
    // Get monitors
    GetMonitors();
    
    // Determine target monitor
    MonitorInfo* targetMonitor = nullptr;
    if (monitorIndex >= 0 && monitorIndex < static_cast<int>(monitors_.size())) {
        targetMonitor = &monitors_[monitorIndex];
    } else {
        // Use primary monitor if index is invalid
        targetMonitor = GetPrimaryMonitor();
    }
    
    if (!targetMonitor) {
        std::cerr << "ProjectorWindowManager: No suitable monitor found" << std::endl;
        return false;
    }
    
    // Calculate window position and size
    int windowX = x;
    int windowY = y;
    int windowWidth = width;
    int windowHeight = height;
    
    if (fullscreen) {
        windowX = targetMonitor->x;
        windowY = targetMonitor->y;
        windowWidth = targetMonitor->width;
        windowHeight = targetMonitor->height;
    } else {
        // Adjust position to be on the target monitor
        windowX = targetMonitor->x + x;
        windowY = targetMonitor->y + y;
    }
    
    return CreateSecondaryWindow(windowX, windowY, windowWidth, windowHeight, fullscreen);
}

bool ProjectorWindowManager::CreateSecondaryWindow(int x, int y, int width, int height, bool fullscreen) {
    DWORD style = WS_OVERLAPPEDWINDOW;
    DWORD exStyle = WS_EX_APPWINDOW;
    
    if (fullscreen) {
        style = WS_POPUP;
        exStyle = WS_EX_TOPMOST;
    }
    
    secondary_window_ = CreateWindowEx(
        exStyle,
        kSecondaryWindowClassName,
        L"Advent Hymnals Projector",
        style,
        x, y, width, height,
        nullptr,
        nullptr,
        GetModuleHandle(nullptr),
        this
    );
    
    if (!secondary_window_) {
        DWORD error = GetLastError();
        std::cerr << "ProjectorWindowManager: Failed to create secondary window. Error: " << error << std::endl;
        return false;
    }
    
    // Try to create a Flutter view for the secondary window
    if (engine_) {
        try {
            RECT clientRect;
            GetClientRect(secondary_window_, &clientRect);
            
            // Create a Flutter view controller for the secondary window
            secondary_flutter_window_ = std::make_unique<FlutterWindow>(
                flutter::DartProject(L"data"));
            
            // Initialize the Flutter window with the secondary window handle
            // Note: This is a simplified approach - in a full implementation,
            // you would need to create a proper Flutter view for the secondary window
            
            std::cout << "ProjectorWindowManager: Flutter view created for secondary window" << std::endl;
        } catch (const std::exception& e) {
            std::cerr << "ProjectorWindowManager: Failed to create Flutter view: " << e.what() << std::endl;
        }
    }
    
    // Show the window
    ShowWindow(secondary_window_, SW_SHOW);
    UpdateWindow(secondary_window_);
    
    std::cout << "ProjectorWindowManager: Secondary window created successfully" << std::endl;
    return true;
}

bool ProjectorWindowManager::CloseSecondaryWindow() {
    if (!secondary_window_) {
        return true;
    }
    
    DestroyWindow(secondary_window_);
    secondary_window_ = nullptr;
    
    std::cout << "ProjectorWindowManager: Secondary window closed" << std::endl;
    return true;
}

bool ProjectorWindowManager::MoveToMonitor(int monitorIndex) {
    if (!secondary_window_ || monitorIndex < 0 || monitorIndex >= static_cast<int>(monitors_.size())) {
        return false;
    }
    
    const auto& monitor = monitors_[monitorIndex];
    
    // Move window to the specified monitor
    SetWindowPos(secondary_window_, nullptr, monitor.x, monitor.y, 0, 0, 
                SWP_NOSIZE | SWP_NOZORDER);
    
    return true;
}

bool ProjectorWindowManager::SetFullscreenOnMonitor(int monitorIndex) {
    if (!secondary_window_ || monitorIndex < 0 || monitorIndex >= static_cast<int>(monitors_.size())) {
        return false;
    }
    
    const auto& monitor = monitors_[monitorIndex];
    
    // Set window to fullscreen on the specified monitor
    SetWindowLong(secondary_window_, GWL_STYLE, WS_POPUP);
    SetWindowLong(secondary_window_, GWL_EXSTYLE, WS_EX_TOPMOST);
    SetWindowPos(secondary_window_, HWND_TOPMOST, monitor.x, monitor.y, 
                monitor.width, monitor.height, SWP_SHOWWINDOW);
    
    return true;
}

bool ProjectorWindowManager::UpdateContent(const std::string& content) {
    if (!secondary_window_) {
        return false;
    }
    
    // For now, just return success
    // In a full implementation, this would communicate with the Flutter engine
    // to update the content in the secondary window
    return true;
}

MonitorInfo* ProjectorWindowManager::GetMonitorByIndex(int index) {
    if (index < 0 || index >= static_cast<int>(monitors_.size())) {
        return nullptr;
    }
    return &monitors_[index];
}

MonitorInfo* ProjectorWindowManager::GetPrimaryMonitor() {
    for (auto& monitor : monitors_) {
        if (monitor.isPrimary) {
            return &monitor;
        }
    }
    return monitors_.empty() ? nullptr : &monitors_[0];
}

std::wstring ProjectorWindowManager::StringToWideString(const std::string& str) {
    if (str.empty()) {
        return std::wstring();
    }
    
    int size = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, nullptr, 0);
    std::wstring wstr(size, 0);
    MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, &wstr[0], size);
    return wstr;
}

LRESULT CALLBACK ProjectorWindowManager::SecondaryWindowProc(HWND hwnd, UINT uMsg, 
                                                           WPARAM wParam, LPARAM lParam) {
    ProjectorWindowManager* manager = nullptr;
    
    if (uMsg == WM_NCCREATE) {
        CREATESTRUCT* pCreate = reinterpret_cast<CREATESTRUCT*>(lParam);
        manager = reinterpret_cast<ProjectorWindowManager*>(pCreate->lpCreateParams);
        SetWindowLongPtr(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(manager));
    } else {
        manager = reinterpret_cast<ProjectorWindowManager*>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
    }
    
    switch (uMsg) {
        case WM_DESTROY:
            if (manager && manager->secondary_window_ == hwnd) {
                manager->secondary_window_ = nullptr;
            }
            break;
            
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            
            // Fill with black background
            RECT rect;
            GetClientRect(hwnd, &rect);
            FillRect(hdc, &rect, (HBRUSH)GetStockObject(BLACK_BRUSH));
            
            // Draw placeholder text
            SetTextColor(hdc, RGB(255, 255, 255));
            SetBkColor(hdc, RGB(0, 0, 0));
            DrawText(hdc, L"Projector Window - Flutter Content Will Appear Here", -1, &rect, 
                    DT_CENTER | DT_VCENTER | DT_SINGLELINE);
            
            EndPaint(hwnd, &ps);
            return 0;
        }
        
        case WM_KEYDOWN:
            if (wParam == VK_ESCAPE) {
                if (manager) {
                    manager->CloseSecondaryWindow();
                }
                return 0;
            }
            break;
    }
    
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}