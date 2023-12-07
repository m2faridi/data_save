#ifndef FLUTTER_PLUGIN_DATA_SAVE_PLUGIN_H_
#define FLUTTER_PLUGIN_DATA_SAVE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace data_save {

class DataSavePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DataSavePlugin();

  virtual ~DataSavePlugin();

  // Disallow copy and assign.
  DataSavePlugin(const DataSavePlugin&) = delete;
  DataSavePlugin& operator=(const DataSavePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace data_save

#endif  // FLUTTER_PLUGIN_DATA_SAVE_PLUGIN_H_
