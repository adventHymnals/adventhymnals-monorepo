#include "projector_window_manager.h"
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <iostream>

// ProjectorWindowManager implementation for Linux
ProjectorWindowManager::ProjectorWindowManager() 
    : method_channel_(nullptr), secondary_window_(nullptr), secondary_view_(nullptr) {}

ProjectorWindowManager::~ProjectorWindowManager() {
    Dispose();
}

bool ProjectorWindowManager::Initialize(FlView* view) {
    if (!view) {
        std::cerr << "ProjectorWindowManager: FlView is null" << std::endl;
        return false;
    }
    
    // Create method channel
    method_channel_ = fl_method_channel_new(
        fl_view_get_engine(view),
        "com.adventhymnals.org/projector_window",
        FL_METHOD_CODEC(fl_standard_method_codec_new())
    );
    
    // Set method call handler
    fl_method_channel_set_method_call_handler(
        method_channel_, 
        MethodCallHandler, 
        this, 
        nullptr
    );
    
    std::cout << "ProjectorWindowManager: Initialized successfully" << std::endl;
    return true;
}

void ProjectorWindowManager::Dispose() {
    CloseSecondaryWindow();
    
    if (method_channel_) {
        g_object_unref(method_channel_);
        method_channel_ = nullptr;
    }
    
    monitors_.clear();
}

void ProjectorWindowManager::MethodCallHandler(FlMethodChannel* channel, 
                                             FlMethodCall* method_call, 
                                             gpointer user_data) {
    ProjectorWindowManager* self = static_cast<ProjectorWindowManager*>(user_data);
    self->HandleMethodCall(method_call);
}

void ProjectorWindowManager::HandleMethodCall(FlMethodCall* method_call) {
    const gchar* method_name = fl_method_call_get_name(method_call);
    
    if (g_strcmp0(method_name, "initialize") == 0) {
        g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
        fl_method_call_respond(method_call, result, nullptr);
    } else if (g_strcmp0(method_name, "getMonitors") == 0) {
        auto monitors = GetMonitors();
        g_autoptr(FlValue) monitor_list = fl_value_new_list();
        
        for (const auto& monitor : monitors) {
            g_autoptr(FlValue) monitor_map = fl_value_new_map();
            fl_value_set_map_take(monitor_map, fl_value_new_string("index"), fl_value_new_int(monitor.index));
            fl_value_set_map_take(monitor_map, fl_value_new_string("name"), fl_value_new_string(monitor.name.c_str()));
            fl_value_set_map_take(monitor_map, fl_value_new_string("width"), fl_value_new_int(monitor.width));
            fl_value_set_map_take(monitor_map, fl_value_new_string("height"), fl_value_new_int(monitor.height));
            fl_value_set_map_take(monitor_map, fl_value_new_string("x"), fl_value_new_int(monitor.x));
            fl_value_set_map_take(monitor_map, fl_value_new_string("y"), fl_value_new_int(monitor.y));
            fl_value_set_map_take(monitor_map, fl_value_new_string("isPrimary"), fl_value_new_bool(monitor.isPrimary));
            fl_value_set_map_take(monitor_map, fl_value_new_string("scaleFactor"), fl_value_new_float(monitor.scaleFactor));
            
            fl_value_append_take(monitor_list, monitor_map);
        }
        
        fl_method_call_respond(method_call, monitor_list, nullptr);
    } else if (g_strcmp0(method_name, "openSecondaryWindow") == 0) {
        FlValue* args = fl_method_call_get_args(method_call);
        
        int monitorIndex = -1;
        bool fullscreen = true;
        int width = 1280;
        int height = 720;
        int x = 100;
        int y = 100;
        
        if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
            FlValue* monitor_index_value = fl_value_lookup_string(args, "monitorIndex");
            if (monitor_index_value) {
                monitorIndex = fl_value_get_int(monitor_index_value);
            }
            
            FlValue* fullscreen_value = fl_value_lookup_string(args, "fullscreen");
            if (fullscreen_value) {
                fullscreen = fl_value_get_bool(fullscreen_value);
            }
            
            FlValue* width_value = fl_value_lookup_string(args, "width");
            if (width_value) {
                width = fl_value_get_int(width_value);
            }
            
            FlValue* height_value = fl_value_lookup_string(args, "height");
            if (height_value) {
                height = fl_value_get_int(height_value);
            }
            
            FlValue* x_value = fl_value_lookup_string(args, "x");
            if (x_value) {
                x = fl_value_get_int(x_value);
            }
            
            FlValue* y_value = fl_value_lookup_string(args, "y");
            if (y_value) {
                y = fl_value_get_int(y_value);
            }
        }
        
        bool success = OpenSecondaryWindow(monitorIndex, fullscreen, width, height, x, y);
        g_autoptr(FlValue) result = fl_value_new_bool(success);
        fl_method_call_respond(method_call, result, nullptr);
    } else if (g_strcmp0(method_name, "closeSecondaryWindow") == 0) {
        bool success = CloseSecondaryWindow();
        g_autoptr(FlValue) result = fl_value_new_bool(success);
        fl_method_call_respond(method_call, result, nullptr);
    } else if (g_strcmp0(method_name, "moveToMonitor") == 0) {
        FlValue* args = fl_method_call_get_args(method_call);
        FlValue* monitor_index_value = fl_value_lookup_string(args, "monitorIndex");
        
        if (!monitor_index_value) {
            g_autoptr(GError) error = g_error_new(
                g_quark_from_string("MISSING_ARGUMENT"), 
                0, 
                "monitorIndex is required"
            );
            fl_method_call_respond_error(method_call, "MISSING_ARGUMENT", "monitorIndex is required", nullptr, error);
            return;
        }
        
        int monitorIndex = fl_value_get_int(monitor_index_value);
        bool success = MoveToMonitor(monitorIndex);
        g_autoptr(FlValue) result = fl_value_new_bool(success);
        fl_method_call_respond(method_call, result, nullptr);
    } else if (g_strcmp0(method_name, "setFullscreenOnMonitor") == 0) {
        FlValue* args = fl_method_call_get_args(method_call);
        FlValue* monitor_index_value = fl_value_lookup_string(args, "monitorIndex");
        
        if (!monitor_index_value) {
            g_autoptr(GError) error = g_error_new(
                g_quark_from_string("MISSING_ARGUMENT"), 
                0, 
                "monitorIndex is required"
            );
            fl_method_call_respond_error(method_call, "MISSING_ARGUMENT", "monitorIndex is required", nullptr, error);
            return;
        }
        
        int monitorIndex = fl_value_get_int(monitor_index_value);
        bool success = SetFullscreenOnMonitor(monitorIndex);
        g_autoptr(FlValue) result = fl_value_new_bool(success);
        fl_method_call_respond(method_call, result, nullptr);
    } else if (g_strcmp0(method_name, "updateContent") == 0) {
        // For now, just return success
        g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
        fl_method_call_respond(method_call, result, nullptr);
    } else {
        fl_method_call_respond_not_implemented(method_call, nullptr);
    }
}

std::vector<MonitorInfo> ProjectorWindowManager::GetMonitors() {
    monitors_.clear();
    
    GdkDisplay* display = gdk_display_get_default();
    if (!display) {
        return monitors_;
    }
    
    int n_monitors = gdk_display_get_n_monitors(display);
    
    for (int i = 0; i < n_monitors; i++) {
        GdkMonitor* monitor = gdk_display_get_monitor(display, i);
        if (!monitor) continue;
        
        MonitorInfo info;
        info.index = i;
        info.name = gdk_monitor_get_model(monitor) ? gdk_monitor_get_model(monitor) : "Unknown Monitor";
        
        GdkRectangle geometry;
        gdk_monitor_get_geometry(monitor, &geometry);
        info.width = geometry.width;
        info.height = geometry.height;
        info.x = geometry.x;
        info.y = geometry.y;
        
        info.isPrimary = gdk_monitor_is_primary(monitor);
        info.scaleFactor = gdk_monitor_get_scale_factor(monitor);
        
        monitors_.push_back(info);
    }
    
    return monitors_;
}

bool ProjectorWindowManager::OpenSecondaryWindow(int monitorIndex, bool fullscreen, 
                                               int width, int height, int x, int y) {
    if (secondary_window_) {
        std::cout << "ProjectorWindowManager: Secondary window already open" << std::endl;
        return true;
    }
    
    // Get monitors
    GetMonitors();
    
    // Create secondary window
    secondary_window_ = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(secondary_window_), "Advent Hymnals Projector");
    
    // Set window properties
    if (fullscreen) {
        gtk_window_fullscreen(GTK_WINDOW(secondary_window_));
    } else {
        gtk_window_set_default_size(GTK_WINDOW(secondary_window_), width, height);
        gtk_window_move(GTK_WINDOW(secondary_window_), x, y);
    }
    
    // Position on specific monitor if requested
    if (monitorIndex >= 0 && monitorIndex < static_cast<int>(monitors_.size())) {
        const auto& monitor = monitors_[monitorIndex];
        gtk_window_move(GTK_WINDOW(secondary_window_), monitor.x + x, monitor.y + y);
    }
    
    // Create a placeholder label for now
    GtkWidget* label = gtk_label_new("Projector Window - Flutter Content Will Appear Here");
    gtk_widget_modify_fg(label, GTK_STATE_NORMAL, &(GdkColor){0, 65535, 65535, 65535}); // White text
    gtk_widget_modify_bg(secondary_window_, GTK_STATE_NORMAL, &(GdkColor){0, 0, 0, 0}); // Black background
    gtk_container_add(GTK_CONTAINER(secondary_window_), label);
    
    // Set up close handler
    g_signal_connect(secondary_window_, "delete-event", G_CALLBACK(OnSecondaryWindowClose), this);
    
    gtk_widget_show_all(secondary_window_);
    
    std::cout << "ProjectorWindowManager: Secondary window created successfully" << std::endl;
    return true;
}

bool ProjectorWindowManager::CloseSecondaryWindow() {
    if (!secondary_window_) {
        return true;
    }
    
    gtk_widget_destroy(secondary_window_);
    secondary_window_ = nullptr;
    secondary_view_ = nullptr;
    
    std::cout << "ProjectorWindowManager: Secondary window closed" << std::endl;
    return true;
}

bool ProjectorWindowManager::MoveToMonitor(int monitorIndex) {
    if (!secondary_window_ || monitorIndex < 0 || monitorIndex >= static_cast<int>(monitors_.size())) {
        return false;
    }
    
    const auto& monitor = monitors_[monitorIndex];
    gtk_window_move(GTK_WINDOW(secondary_window_), monitor.x, monitor.y);
    
    return true;
}

bool ProjectorWindowManager::SetFullscreenOnMonitor(int monitorIndex) {
    if (!secondary_window_ || monitorIndex < 0 || monitorIndex >= static_cast<int>(monitors_.size())) {
        return false;
    }
    
    // Move to monitor first, then set fullscreen
    MoveToMonitor(monitorIndex);
    gtk_window_fullscreen(GTK_WINDOW(secondary_window_));
    
    return true;
}

gboolean ProjectorWindowManager::OnSecondaryWindowClose(GtkWidget* widget, GdkEvent* event, gpointer user_data) {
    ProjectorWindowManager* self = static_cast<ProjectorWindowManager*>(user_data);
    self->secondary_window_ = nullptr;
    self->secondary_view_ = nullptr;
    return FALSE; // Allow the window to close
}