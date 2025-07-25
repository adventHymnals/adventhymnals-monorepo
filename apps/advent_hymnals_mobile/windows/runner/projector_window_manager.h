#ifndef RUNNER_PROJECTOR_WINDOW_MANAGER_H_
#define RUNNER_PROJECTOR_WINDOW_MANAGER_H_

#include <windows.h>
#include <memory>
#include <vector>
#include <string>

// Structure to hold monitor information
struct MonitorInfo {
    int index;
    std::string name;
    int width;
    int height;
    int x;
    int y;
    bool isPrimary;
    double scaleFactor;
    HMONITOR hMonitor;
};

class ProjectorWindowManager {
public:
    ProjectorWindowManager();
    ~ProjectorWindowManager();
    
    // Initialize the projector window manager (stub for Windows)
    bool Initialize(void* engine);
    
    // Cleanup resources
    void Dispose();
    
    // Get available monitors
    std::vector<MonitorInfo> GetMonitors();
    
    // Open secondary projector window
    bool OpenSecondaryWindow(int monitorIndex = -1, bool fullscreen = true, 
                           int width = 1280, int height = 720, int x = 100, int y = 100);
    
    // Close secondary projector window
    bool CloseSecondaryWindow();
    
    // Update secondary window properties
    bool UpdateSecondaryWindow(int width, int height, int x, int y, bool fullscreen);
    
    // Move window to specific monitor
    bool MoveToMonitor(int monitorIndex);
    
    // Set fullscreen on specific monitor
    bool SetFullscreenOnMonitor(int monitorIndex);
    
    // Update content in secondary window
    bool UpdateContent(const std::string& content);
    
    // Check if secondary window is open
    bool IsSecondaryWindowOpen() const { return secondary_window_ != nullptr; }
    
private:
    // Monitor enumeration callback
    static BOOL CALLBACK MonitorEnumProc(HMONITOR hMonitor, HDC hdcMonitor, 
                                        LPRECT lprcMonitor, LPARAM dwData);
    
    // Window procedure for secondary window
    static LRESULT CALLBACK SecondaryWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
    
    // Create secondary window
    bool CreateSecondaryWindow(int x, int y, int width, int height, bool fullscreen);
    
    // Get monitor by index
    MonitorInfo* GetMonitorByIndex(int index);
    
    // Get primary monitor
    MonitorInfo* GetPrimaryMonitor();
    
    // Convert string to wide string
    std::wstring StringToWideString(const std::string& str);
    
    void* engine_;
    HWND secondary_window_;
    std::vector<MonitorInfo> monitors_;
    
    // Window class name for secondary window
    static const wchar_t* kSecondaryWindowClassName;
    
    // Reference to this instance for static callbacks
    static ProjectorWindowManager* instance_;
};

#endif  // RUNNER_PROJECTOR_WINDOW_MANAGER_H_