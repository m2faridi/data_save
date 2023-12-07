#include "include/data_save/data_save_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "data_save_plugin.h"

void DataSavePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  data_save::DataSavePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
