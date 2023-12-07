//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <data_save/data_save_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) data_save_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DataSavePlugin");
  data_save_plugin_register_with_registrar(data_save_registrar);
}
