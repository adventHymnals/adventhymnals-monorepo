#include "projector_window_plugin.h"
#include "projector_window_manager.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace projector_window {

// Static instance of the plugin
std::unique_ptr<ProjectorWindowPlugin> ProjectorWindowPlugin::instance_;

void ProjectorWindowPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "com.adventhymnals.org/projector_window",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ProjectorWindowPlugin>(registrar);

  channel->SetMethodCallHandler([plugin_pointer = plugin.get()](
                                   const auto& call, auto result) {
    plugin_pointer->HandleMethodCall(call, std::move(result));
  });

  registrar->AddPlugin(std::move(plugin));
}

ProjectorWindowPlugin::ProjectorWindowPlugin(
    flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar) {
  window_manager_ = std::make_unique<ProjectorWindowManager>();
  window_manager_->Initialize(nullptr); // We don't need the engine for this simple implementation
}

ProjectorWindowPlugin::~ProjectorWindowPlugin() {
  if (window_manager_) {
    window_manager_->Dispose();
  }
}

void ProjectorWindowPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  const std::string& method_name = method_call.method_name();
  
  if (method_name == "initialize") {
    // Initialize the projector window manager
    bool success = window_manager_->Initialize(nullptr);
    result->Success(flutter::EncodableValue(success));
  } else if (method_name == "getMonitors") {
    // Get available monitors
    auto monitors = window_manager_->GetMonitors();
    flutter::EncodableList monitor_list;
    
    for (const auto& monitor : monitors) {
      flutter::EncodableMap monitor_map;
      monitor_map["index"] = flutter::EncodableValue(monitor.index);
      monitor_map["name"] = flutter::EncodableValue(monitor.name);
      monitor_map["width"] = flutter::EncodableValue(monitor.width);
      monitor_map["height"] = flutter::EncodableValue(monitor.height);
      monitor_map["x"] = flutter::EncodableValue(monitor.x);
      monitor_map["y"] = flutter::EncodableValue(monitor.y);
      monitor_map["isPrimary"] = flutter::EncodableValue(monitor.isPrimary);
      monitor_map["scaleFactor"] = flutter::EncodableValue(monitor.scaleFactor);
      
      monitor_list.push_back(flutter::EncodableValue(monitor_map));
    }
    
    result->Success(flutter::EncodableValue(monitor_list));
  } else if (method_name == "openSecondaryWindow") {
    // Open secondary window
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    
    int monitorIndex = -1;
    bool fullscreen = true;
    int width = 1280;
    int height = 720;
    int x = 100;
    int y = 100;
    
    if (arguments) {
      auto monitor_index_it = arguments->find(flutter::EncodableValue("monitorIndex"));
      if (monitor_index_it != arguments->end()) {
        monitorIndex = std::get<int>(monitor_index_it->second);
      }
      
      auto fullscreen_it = arguments->find(flutter::EncodableValue("fullscreen"));
      if (fullscreen_it != arguments->end()) {
        fullscreen = std::get<bool>(fullscreen_it->second);
      }
      
      auto width_it = arguments->find(flutter::EncodableValue("width"));
      if (width_it != arguments->end()) {
        width = std::get<int>(width_it->second);
      }
      
      auto height_it = arguments->find(flutter::EncodableValue("height"));
      if (height_it != arguments->end()) {
        height = std::get<int>(height_it->second);
      }
      
      auto x_it = arguments->find(flutter::EncodableValue("x"));
      if (x_it != arguments->end()) {
        x = std::get<int>(x_it->second);
      }
      
      auto y_it = arguments->find(flutter::EncodableValue("y"));
      if (y_it != arguments->end()) {
        y = std::get<int>(y_it->second);
      }
    }
    
    bool success = window_manager_->OpenSecondaryWindow(monitorIndex, fullscreen, width, height, x, y);
    result->Success(flutter::EncodableValue(success));
  } else if (method_name == "closeSecondaryWindow") {
    // Close secondary window
    bool success = window_manager_->CloseSecondaryWindow();
    result->Success(flutter::EncodableValue(success));
  } else if (method_name == "moveToMonitor") {
    // Move window to monitor
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    
    if (!arguments) {
      result->Error("MISSING_ARGUMENT", "monitorIndex is required");
      return;
    }
    
    auto monitor_index_it = arguments->find(flutter::EncodableValue("monitorIndex"));
    if (monitor_index_it == arguments->end()) {
      result->Error("MISSING_ARGUMENT", "monitorIndex is required");
      return;
    }
    
    int monitorIndex = std::get<int>(monitor_index_it->second);
    bool success = window_manager_->MoveToMonitor(monitorIndex);
    result->Success(flutter::EncodableValue(success));
  } else if (method_name == "setFullscreenOnMonitor") {
    // Set fullscreen on monitor
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    
    if (!arguments) {
      result->Error("MISSING_ARGUMENT", "monitorIndex is required");
      return;
    }
    
    auto monitor_index_it = arguments->find(flutter::EncodableValue("monitorIndex"));
    if (monitor_index_it == arguments->end()) {
      result->Error("MISSING_ARGUMENT", "monitorIndex is required");
      return;
    }
    
    int monitorIndex = std::get<int>(monitor_index_it->second);
    bool success = window_manager_->SetFullscreenOnMonitor(monitorIndex);
    result->Success(flutter::EncodableValue(success));
  } else if (method_name == "updateContent") {
    // Update content
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    
    std::string content = "";
    if (arguments) {
      auto content_it = arguments->find(flutter::EncodableValue("content"));
      if (content_it != arguments->end()) {
        content = std::get<std::string>(content_it->second);
      }
    }
    
    bool success = window_manager_->UpdateContent(content);
    result->Success(flutter::EncodableValue(success));
  } else {
    result->NotImplemented();
  }
}

}  // namespace projector_window