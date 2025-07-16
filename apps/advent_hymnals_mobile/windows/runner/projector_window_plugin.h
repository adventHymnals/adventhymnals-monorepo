#ifndef RUNNER_PROJECTOR_WINDOW_PLUGIN_H_
#define RUNNER_PROJECTOR_WINDOW_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

class ProjectorWindowManager;

namespace projector_window {

class ProjectorWindowPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  ProjectorWindowPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~ProjectorWindowPlugin();

  // Disallow copy and assign.
  ProjectorWindowPlugin(const ProjectorWindowPlugin&) = delete;
  ProjectorWindowPlugin& operator=(const ProjectorWindowPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<ProjectorWindowManager> window_manager_;
  
  // Static instance for plugin management
  static std::unique_ptr<ProjectorWindowPlugin> instance_;
};

}  // namespace projector_window

#endif  // RUNNER_PROJECTOR_WINDOW_PLUGIN_H_