#ifndef PROJECTOR_WINDOW_MANAGER_H_
#define PROJECTOR_WINDOW_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
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
};

class ProjectorWindowManager {
public:
    ProjectorWindowManager();
    ~ProjectorWindowManager();
    
    // Initialize the projector window manager
    bool Initialize(FlView* view);
    
    // Cleanup resources
    void Dispose();
    
    // Get available monitors
    std::vector<MonitorInfo> GetMonitors();
    
    // Open secondary projector window
    bool OpenSecondaryWindow(int monitorIndex = -1, bool fullscreen = true, 
                           int width = 1280, int height = 720, int x = 100, int y = 100);
    
    // Close secondary projector window
    bool CloseSecondaryWindow();
    
    // Move window to specific monitor
    bool MoveToMonitor(int monitorIndex);
    
    // Set fullscreen on specific monitor
    bool SetFullscreenOnMonitor(int monitorIndex);
    
    // Check if secondary window is open
    bool IsSecondaryWindowOpen() const { return secondary_window_ != nullptr; }
    
private:
    // Method channel handler
    static void MethodCallHandler(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data);
    
    // Handle method calls
    void HandleMethodCall(FlMethodCall* method_call);
    
    // Window close handler
    static gboolean OnSecondaryWindowClose(GtkWidget* widget, GdkEvent* event, gpointer user_data);
    
    FlMethodChannel* method_channel_;
    GtkWidget* secondary_window_;
    FlView* secondary_view_;
    std::vector<MonitorInfo> monitors_;
};

#endif  // PROJECTOR_WINDOW_MANAGER_H_