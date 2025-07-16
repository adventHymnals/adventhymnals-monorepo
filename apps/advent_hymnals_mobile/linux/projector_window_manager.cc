#include "projector_window_manager.h"
#include <iostream>

// Stub implementation for Linux - temporarily disabled due to API compatibility issues
ProjectorWindowManager::ProjectorWindowManager() 
    : method_channel_(nullptr), secondary_window_(nullptr), secondary_view_(nullptr) {
    // Suppress unused variable warnings
    (void)method_channel_;
    (void)secondary_window_;
    (void)secondary_view_;
}

ProjectorWindowManager::~ProjectorWindowManager() {
    Dispose();
}

bool ProjectorWindowManager::Initialize(FlView* view) {
    std::cout << "ProjectorWindowManager: Linux implementation currently disabled" << std::endl;
    return false;
}

void ProjectorWindowManager::Dispose() {
    CloseSecondaryWindow();
    monitors_.clear();
}

void ProjectorWindowManager::MethodCallHandler(FlMethodChannel* channel, 
                                             FlMethodCall* method_call, 
                                             gpointer user_data) {
    // Stub implementation
}

void ProjectorWindowManager::HandleMethodCall(FlMethodCall* method_call) {
    // Stub implementation
}

std::vector<MonitorInfo> ProjectorWindowManager::GetMonitors() {
    monitors_.clear();
    
    // Return a single default monitor
    MonitorInfo primary_monitor;
    primary_monitor.index = 0;
    primary_monitor.name = "Primary Monitor";
    primary_monitor.width = 1920;
    primary_monitor.height = 1080;
    primary_monitor.x = 0;
    primary_monitor.y = 0;
    primary_monitor.isPrimary = true;
    primary_monitor.scaleFactor = 1.0;
    
    monitors_.push_back(primary_monitor);
    return monitors_;
}

bool ProjectorWindowManager::OpenSecondaryWindow(int monitorIndex, bool fullscreen, 
                                                int width, int height, int x, int y) {
    std::cout << "ProjectorWindowManager: OpenSecondaryWindow called (stub)" << std::endl;
    return false;
}

bool ProjectorWindowManager::CloseSecondaryWindow() {
    std::cout << "ProjectorWindowManager: CloseSecondaryWindow called (stub)" << std::endl;
    return true;
}

bool ProjectorWindowManager::MoveToMonitor(int monitorIndex) {
    std::cout << "ProjectorWindowManager: MoveToMonitor called (stub)" << std::endl;
    return false;
}

bool ProjectorWindowManager::SetFullscreenOnMonitor(int monitorIndex) {
    std::cout << "ProjectorWindowManager: SetFullscreenOnMonitor called (stub)" << std::endl;
    return false;
}

bool ProjectorWindowManager::UpdateContent(const std::string& content) {
    std::cout << "ProjectorWindowManager: UpdateContent called (stub)" << std::endl;
    return false;
}

bool ProjectorWindowManager::IsSecondaryWindowOpen() const {
    return false;
}

gboolean ProjectorWindowManager::OnSecondaryWindowClose(GtkWidget* widget, GdkEvent* event, gpointer user_data) {
    return 0; // FALSE
}